#include <iostream>
#include <stdlib.h>
#include <algorithm>
#include <vector>
#include <cmath>
#include <sys/time.h>
using namespace std;

// literal values
#define UNDEF -1
#define TRUE 1
#define FALSE 0

const double MAX_ACT = 1e5;      // maximum activity value
const double ACT_RES = 1e-5;     // activity rescale factor

// clause declaration + typedefs
struct Clause;
typedef Clause* CP;
typedef vector<CP> CPV;
typedef vector<CPV> CPM;

typedef long long LL;
typedef vector<double> DV;
typedef vector<bool> BV;
typedef vector<int> IV;
typedef vector<IV> IM;
typedef pair<double, int> DIP;
typedef vector<DIP> DIPV;


// solver vars
uint numVars;
uint numClauses;
IV model;
IV modelStack;
uint indexOfNextLitToPropagate;
uint decisionLevel;

// counters
LL decisionCnt;
LL propagationCnt;
LL conflictCnt;
struct timeval start, tend;

DV activity;              // activity of a variable (heuristic)
IV litCnt;                // # of literal occurrences
IV level;                 // decision level at which variables were set
CPV reason;               // learnt clause that implied the variable's value
CPV clauses;              // problem clauses
CPV learnts;              // collection of learnt clauses
CPM watches;              // clauses being watched by literal

double varInc;            // variable activity increment - amount to bump with
double varDecay;          // decay factor for variable activity
double claInc;            // variable activity increment - amount to bump with
double claDecay;          // decay factor for variable activity

int learntMax;            // max amount of learnt clauses before a db reduction
int learntMost;           // max allowed # of learnt clauses ever
int reduceCnt;            // how many db reductions since last learntMax increment
int reduceMax;            // # of db reductions before a learntMax increment


// returns the literal's associated index (for arrays)
inline int index(int lit) {
  return numVars+lit;
}

// returns the literal's value according to current model
inline int currentValueInModel(int lit) {
  if (lit>=0) return model[lit];
  else {
    if (model[-lit]==UNDEF) return UNDEF;
    return 1-model[-lit];
  }
}

// set the corresponding lit value in the model
inline void setLiteralToTrue(int lit) {
  if (lit>0) model[lit]=TRUE;
  else model[-lit]=FALSE;		
}

// add literal to model stack, setting its value to true
// 'from' is a ref. to the learnt clause that implied this literal's value
inline void enqueue(int lit, CP from) {
  modelStack.push_back(lit);
  setLiteralToTrue(lit);
  int var = abs(lit);
  level[var] = decisionLevel;
  reason[var] = from;
}

// declaration of bumping functions (needed for Clause struct to compile)
void varBumpActivity(int lit);
void claBumpActivity(CP c);

// implementation of the Clause struct
// provides a means to create and remove constraints for the problem
// and also to propagate and calculate reasons
struct Clause {
  bool learnt;          // learnt clause or problem clause?
  double activity;      // activity value
  IV lits;              // clause's literals
  
  // static helper functions
  static void removeFalse(IV &ps) {
    int i=0; 
    for (int lit : ps) if (currentValueInModel(lit)!=FALSE) ps[i++]=lit;
    ps.resize(i);
  }
  static int highestDecisionLevelLit(IV &ps) {
    int idx = 0;
    for (int i=1; i<(int)ps.size(); ++i) if (level[abs(ps[idx])]<level[abs(ps[i])]) idx=i;
    return idx;
  }
  static void removeElement(CPV &v, CP c) {
    int i=0;
    while (i<(int)v.size() && v[i]!=c) ++i;
    if (i<(int)v.size()) {
      ++i;
      while (i<(int)v.size()) {
	v[i-1]=v[i];
	++i;
      }
      v.pop_back();
    }
  }
  
  // constructor function for clauses
  // Post-condition:
  // ps is cleared
  // for learnt clauses, all literals will be false except lits[0] (by design of the analyze method)
  // for the propagation to work, the second watch must be put on the literal which will first be unbound by backtracking
  static void newClause(IV &ps, bool lrnt, CP &outClause) {
    CP c = new Clause();
    c->learnt = lrnt;
    c->activity = 10;
    if (lrnt) {
      if ((int)ps.size()>1) {
	// pick second literal to watch
	int maxI = highestDecisionLevelLit(ps);
	swap(ps[1], ps[maxI]);
	// add clause to watcher lists
	watches[index(-ps[0])].push_back(c);
	watches[index(-ps[1])].push_back(c);
      }
      // bumping
      claBumpActivity(c);                       // newly learnt clauses should be considered active
      for (int lit : ps) varBumpActivity(lit);  // variables in conflict clauses are bumped
    } else {
      for (int i=0; i<min((int)ps.size(), 2); ++i) watches[index(-ps[i])].push_back(c);
    }
    c->lits.swap(ps);
    outClause=c;
  }
  
  // learnt clauses only
  bool locked() {
    return reason[abs(lits[0])]==this;
  }
  
  // remove clause from watcher arrays + free allocated memory
  void remove() {
    for (int i=0; i<min((int)lits.size(), 2); ++i) removeElement(watches[index(-lits[i])], this);
    delete this;
  }
  
  // returns false if all literals in the clause are FALSE
  // the constraint is inserted into the same watcher array if 'lit' is true
  // otherwise, we look for a new literal to watch and add the clause to its watcher array
  bool propagate(int lit) {
    // make sure the false literal is lits[1]
    if (lits[0]==-lit) {
      lits[0]=lits[1];
      lits[1]=-lit;
    }
    // if 0th watch is true, clause is satisfied
    if (currentValueInModel(lits[0])==TRUE) {
      watches[index(lit)].push_back(this);
      return 1;
    }
    // look for a new literal to watch
    for (int i=2; i<(int)lits.size(); ++i) if (currentValueInModel(lits[i])!=FALSE) {
      lits[1]=lits[i];
      lits[i]=-lit;
      watches[index(-lits[1])].push_back(this);    // insert clause into watcher array
      return 1;
    }
    // clause is unit under assignment
    watches[index(lit)].push_back(this);
    int val=currentValueInModel(lits[0]);
    if (val==FALSE) return 0;
    enqueue(lits[0], this);
    return 1;
  }
  
  // this clause is the reason for 'lit' being true
  // an array of literals implying 'lit' is returned through 'outReason'
  // if 'lit' represents no literal, then the reason for the clause being conflicting is returned too
  void calcReason(int lit, IV &outReason) {
    // invariant: lit==0 || lit==lits[0]
    for (int i=lit?1:0; i<(int)lits.size(); ++i) 
      outReason.push_back(lits[i]);     // invariant: currentValueInModel(lits[i])==FALSE
    if (learnt) claBumpActivity(this);
  }
};

// variable and clause activity rescale, bumping, and decaying methods
inline void varRescaleActivity() {
  for (uint i=1; i<=numVars; ++i) activity[i] *= ACT_RES;
  varInc *= ACT_RES;
}
inline void varBumpActivity(int lit) {
  int var = abs(lit);
  activity[var] += varInc;
  if (activity[var]>MAX_ACT) varRescaleActivity();
}
inline void varDecayActivity() {
  varInc *= varDecay;
}
inline void claRescaleActivity() {
  for (CP c : learnts) c->activity *= ACT_RES;
  claInc *= ACT_RES;
}
inline void claBumpActivity(CP c) {
  c->activity += claInc;
  if (c->activity>MAX_ACT) claRescaleActivity();
}
inline void claDecayActivity() {
  claInc *= claDecay;
}
inline void decayActivities() {
  varDecayActivity();
  claDecayActivity();
}

// initialize solver variables
inline void initVars() {
  clauses.resize(numClauses);
  model.resize(numVars+1, UNDEF);
  activity.resize(numVars+1, 0);
  litCnt.resize((numVars<<1)+1, 0);
  level.resize(numVars+1, -1);
  reason.resize(numVars+1, NULL);
  watches.resize((numVars<<1)+1);
  for (CPV &c : watches) c.reserve(100);
  indexOfNextLitToPropagate=decisionLevel=0;
  decisionCnt=propagationCnt=conflictCnt=0;
  varInc=1.0;
  claInc=1.0;
  varDecay=1.0/0.95;
  claDecay=1.0/0.999;
  learntMax=10;
  learntMost=1000;
  reduceCnt=0;
  reduceMax=10;
}

// set variables' activity taking into account how vars from different clauses relate to each other
// does not improve performance for this particular solver
inline void staticVarOrder() {
  // do simple variable activity heuristic
  for (const CP &c : clauses) {
    const IV &lits=c->lits;
    double add=pow(2, -((int)lits.size()));
    for (int lit : lits) activity[abs(lit)]+=add;
  }
  // calculate the initial 'heat' for all clauses
  IV occurs[(numVars+1)<<1];
  DIP heat[numClauses];
  for (uint i=0; i<numClauses; ++i) {
    const IV &lits=clauses[i]->lits;
    double sum=0;
    for (int lit : lits) {
      occurs[index(lit)].push_back(i);
      sum+=activity[abs(lit)];
    }
    heat[i]={sum, i};
  }
  double iterSize=0;
  for (uint i=0; i<numClauses; ++i) for (int lit : clauses[i]->lits) iterSize+=occurs[index(lit)].size();
  // bump heat for clauses whose variables occur in other hot clauses
  int iterations=min(10, (int)(((double)(numVars<<1)/iterSize)*100));
  double disipation=1.0/iterations;
  for (int a=0; a<iterations; ++a) for (uint i=0; i<numClauses; ++i) 
    for (int lit : clauses[i]->lits) for (int clauseIndex : occurs[index(lit)]) 
      heat[i].first+=heat[clauseIndex].first*disipation;
  // set activity according to hot clauses
  sort(heat, heat+numClauses);
  for (uint i=1; i<=numVars; ++i) activity[i]=0;
  double extra=1e10;
  for (int i=numClauses-1; i>=0; --i) for (int lit : clauses[heat[i].second]->lits) if (activity[abs(lit)]==0) {
    activity[abs(lit)]=extra;
    extra*=0.995;
  }
}

// read problem data from standard input
void readClauses() {
  // Skip comments
  char c=cin.get();
  while (c=='c') {
    while (c!='\n') c=cin.get();
    c=cin.get();
  }  
  // Read "cnf numVars numClauses"
  string aux;
  cin>>aux>>numVars>>numClauses;
  initVars();
  // Read clauses
  for (uint i=0; i<numClauses; ++i) {
    IV ps;
    int lit;
    while (cin>>lit && lit!=0) {
      ps.push_back(lit);
      ++litCnt[index(lit)];
      ++activity[abs(lit)];
    }
    Clause::newClause(ps, 0, clauses[i]);
  }  
}

// returns whether propagation created a conflict or not
// if there was indeed a conflict, the clause responsible is returned too
bool propagateGivesConflict(CP &clause) {
  while (indexOfNextLitToPropagate<modelStack.size()) {
    int lit=modelStack[indexOfNextLitToPropagate++];
    int idx=index(lit);
    CPV tmp;
    tmp.reserve(watches[idx].size());
    watches[idx].swap(tmp);
    // each clause in this lit's watcher array
    // is asked if more unit information can be inferred by a call to its propagate method
    for (auto it=tmp.begin(); it!=tmp.end(); ++it) if (!(*it)->propagate(lit)) {
      // clause is conflicting: copy remaining watches to watches[lit] and return clause
      clause=*it;
      watches[idx].insert(watches[idx].end(), ++it, tmp.end());
      ++conflictCnt;
      return 1;
    }
    ++propagationCnt;
  }
  return 0;
}

// comparator function to sort clauses by activity value
inline bool claActCmp(const CP &a, const CP &b) {
  return a->activity<b->activity;
}

// shrinks the number of learnt clauses when the upper limit is reached
// clauses that are the reason for variable assignment are said to be locked and cannot be removed
// all other clauses in the lower half are removed
// clauses in the upper half are kept if their actvity is high enough
void reduceDB() {
  int i=0;
  int j=0;
  double lim=claInc/(int)learnts.size();
  sort(learnts.begin(), learnts.end(), claActCmp);
  while (i<(int)learnts.size()>>1) {
    if (!learnts[i]->locked()) learnts[i]->remove();
    else learnts[j++]=learnts[i];
    ++i;
  }
  while (i<(int)learnts.size()) {
    if (!learnts[i]->locked() && learnts[i]->activity<lim) learnts[i]->remove();
    else learnts[j++]=learnts[i];
    ++i;
  }
  learnts.resize(j);
}

// removes the last literal from the propagation queue
inline void undoOne() {
  int var=abs(modelStack.back());
  model[var]= UNDEF;
  level[var]=-1;
  reason[var]=NULL;
  modelStack.pop_back();
}

// undoes literal assignments done on higher levels than 'btLevel'
// also known as backjumping
inline void backtrack(uint btLevel) {
  while (decisionLevel>btLevel) {
    while (modelStack.back()!=0) undoOne();  // 0 is the DL mark
    modelStack.pop_back();                   // remove the DL mark
    --decisionLevel;
    indexOfNextLitToPropagate = modelStack.size();
  }
}

// heuristics:
// find the unassigned variable with a higher activity
// then return corresponding literal that appears the most in problem clauses
// if all variables are already assigned, returns 0
inline int getNextDecisionLiteral() {
  /*
  // about 1% of the times, a random litreal is selected instead of the most active one
  // this simple strategy sometimes cracks the harder problems faster
  if (!(rand()%100)) {
    IV all;
    all.reserve(numVars);
    for (uint i=1; i<=numVars; ++i) if (model[i]==UNDEF) all.push_back(i);
    if (all.empty()) return 0;
    int var=all[rand()%all.size()];
    return rand()%2?var:-var;
  }
  */
  int bestLit = 0;
  double bestCnt = 0;
  for (uint i=1; i<=numVars; ++i) if (model[i]==UNDEF && bestCnt<activity[i]) {
    bestLit = litCnt[index(i)]>=litCnt[index(-i)]?i:-i;
    bestCnt = activity[i];
  }
  return bestLit;
}

// makes sure all clauses are satisfied
void checkmodel() {
  for (uint i=0; i<numClauses; ++i) {
    bool someTrue=0;
    int siz=clauses[i]->lits.size();
    for (int j=0; !someTrue && j<siz; ++j) someTrue=currentValueInModel(clauses[i]->lits[j])==TRUE;
    if (!someTrue) {
      cout<<"Error in model, clause is not satisfied:";
      for (int j=0; j<siz; ++j) cout<<clauses[i]->lits[j]<<" ";
      cout<<endl;
      exit(1);
    }
  }  
}

// Creates a learnt clause to prohibit the current conflict, whose literals are returned in 'outLearnt'
// if our conflicting clause is {x,y,z}, we call ¬x^¬y^¬z the reason of the conflict
// ¬x is false cos it was propagated from some clause {¬x,u,v}
// then, ¬y^¬z^¬u^¬u must lead to a conflict too
// so we can add {y,z,u,v} to avoid that conflict.
// The process of expanding literals with their reason sets can be continued.
// In a breadth-first manner, continue to expand literals of the current decision level until only 1 remains
// 'outBTLevel' returns the lowest decision level for which the conflict clause is unit
void analyze(CP confl, IV &outLearnt, int &outBTLevel) {
  BV seen(numVars+1, 0);
  int cnt = 0;
  int lit = 0;
  IV litReason;
  litReason.reserve(4);
  outLearnt.reserve(4);
  outLearnt.push_back(0);
  outBTLevel = 0;
  do {
    litReason.clear();
    confl->calcReason(lit, litReason);               // invariant: confl!=NULL
    // trace reason for lit
    for (int rLit : litReason) {
      int var=abs(rLit);
      if (!seen[var]) {
	seen[var]=1;
	if (level[var]==(int)decisionLevel) ++cnt;
	else if (level[var]>0) {                     // exclude variables from decision level 0
	  outLearnt.push_back(rLit);
	  outBTLevel=max(outBTLevel, level[var]);
	}
      }
    }
    // select next literal to look at
    do {
      lit = modelStack.back();
      confl = reason[abs(lit)];
      undoOne();
    } while (!seen[abs(lit)]);
    --cnt;
  } while (cnt);
  outLearnt[0] = -lit;
}

// creates a new learnt clause
void record(IV &clause) {
  CP c;
  Clause::newClause(clause, 1, c);
  learnts.push_back(c);
  enqueue(c->lits[0], c);
}

// handles learnt clauses reductions when appropriate
// start off with a small learnt clause db
// and incrementally increase size
inline void checkDBSize() {
  if ((int)learnts.size()>learntMax) {
    reduceDB();
    if (learntMax<=learntMost) {
      if (reduceCnt>=reduceMax) reduceCnt=0,++learntMax;
      ++reduceCnt;
    }
  }
}

// benchmark + print summary + return exit code
inline int finish(bool satisfiable) {
  gettimeofday(&tend, NULL);
  LL ttime = (tend.tv_sec*(uint)1e6+tend.tv_usec) - (start.tv_sec*(uint)1e6+start.tv_usec);
  cout << (satisfiable ? "SATISFIABLE" : "UNSATISFIABLE") << endl;
  cout << "Decisions:    " << decisionCnt << endl;
  cout << "Propagations: " << propagationCnt << endl;
  cout << "Conflicts:    " << conflictCnt << endl;
  cout << "Time (s):     " << (double)ttime/1000000 << endl;
  return satisfiable ? 20 : 10;
}


/**
 * MyMiniSAT solver
 * A conflict-driven SAT solver
 * 
 * http://www.princeton.edu/~chaff/publication/DAC2001v56.pdf
 * http://www.eecs.berkeley.edu/~alanmi/courses/2007_290N/papers/intro_een_sat03.pdf
 */
int main() {
  // read data and initialize everything
  gettimeofday(&start, NULL);
  readClauses();
  //staticVarOrder();
  
  // Take care of initial unit clauses, if any
  for (uint i=0; i<numClauses; ++i) if ((int)clauses[i]->lits.size()==1) {
    int lit=clauses[i]->lits[0];
    int val=currentValueInModel(lit);
    if (val==FALSE) return finish(0);
    if (val==UNDEF) enqueue(lit, NULL);
  }
  
  // DPLL algorithm
  while (1) {
    CP clause;
    while (propagateGivesConflict(clause)) {
      if (decisionLevel==0) return finish(0);
      IV learntClause;
      int btLevel;
      analyze(clause, learntClause, btLevel);
      backtrack(btLevel);
      record(learntClause);
      decayActivities();
    }
    checkDBSize();
    int decisionLit=getNextDecisionLiteral();
    if (decisionLit==0) return finish(1);
    // start new decision level:
    modelStack.push_back(0);       // push mark indicating new DL
    ++indexOfNextLitToPropagate;
    ++decisionLevel;
    ++decisionCnt;
    enqueue(decisionLit, NULL);    // now push decisionLit on top of the mark
  }
  return 0;
}  
