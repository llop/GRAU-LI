:-include('../utils').
:-include('entradaRodear9'). 
:-include('displayRodear'). 
:-dynamic(varNumber/3).
symbolicOutput(0).       % set to 1 to see symbolic output only; 0 otherwise.


%--------------------------------------
% Board size
%--------------------------------------

cells(R, C):- rows(R), columns(C).


%--------------------------------------
% Cardinality constraints
% BDDs translated into CNFs
%--------------------------------------

atLeastTwo([ X, Y, Z, W ]):-
  writeClause([ X, Y, Z ]),
  writeClause([ \+X, Y, Z, W ]),
  writeClause([ X, \+Y, Z, W ]),
  writeClause([ X, Y, \+Z, W ]).

atMostTwo([ _, _ ]).
atMostTwo([ X, Y, Z ]):- writeClause([ \+X, \+Y, \+Z ]).
atMostTwo([ X, Y, Z, W ]):-
  writeClause([ \+X, \+Y, \+Z ]),
  writeClause([ \+X, Y, \+Z, \+W ]),
  writeClause([ \+X, \+Y, Z, \+W ]),
  writeClause([ X, \+Y, \+Z, \+W ]).


atLeastThree([ X, Y, Z, W]):-
  writeClause([ X, Y ]),
  writeClause([ X, \+Y, Z ]),
  writeClause([ X, \+Y, \+Z, W ]),
  writeClause([ \+X, Y, Z ]),
  writeClause([ \+X, \+Y, Z, W ]),
  writeClause([ \+X, Y, \+Z, W ]).
      
atMostThree([ X, Y, Z, W ]):- writeClause([ \+X, \+Y, \+Z, \+W ]).

exactlyTwo(C):- atMostTwo(C), atLeastTwo(C).
exactlyThree(C):- atMostThree(C), atLeastThree(C).


%--------------------------------------
% Directions
%--------------------------------------

up(1, _, []):- !.
up(I, J, [v-X-J]):- X is I-1.
down(I, _, []):- rows(R), X is I-1, X >= R, !.
down(I, J, [v-I-J]).
left(_, 1, []):- !.
left(I, J, [h-I-Y]):- Y is J-1.
right(_, J, []):- columns(C), Y is J-1, Y >= C, !.
right(I, J, [h-I-J]).
directions(I, J, U, D, L, R):- up(I, J, U), down(I, J, D), left(I, J, L), right(I, J, R).


%--------------------------------------
% Adjacent edges
%-------------------------------------- 

vertexAdj(I, J, A):- directions(I, J, U, D, L, R), append(U, D, L1), append(L1, L, L2), append(L2, R, A).
cellAdj(I, J, [ h-I-J, v-I-J, h-X-J, v-I-Y ]):- X is I+1, Y is J+1.
  

%------------------------------------------------
% Cycle clauses
% To create cycles and avoid shared edges, 
% just make sure vertex degrees are 0 or 2
%------------------------------------------------

makeCycle([ X | XS ]):- makeCycle([], X, XS).
makeCycle(P, C, []):- not(C, N), writeClause([ N | P ]).
makeCycle(P, C, [ X | XS ]):- 
  not(C, N), append(P, XS, L), writeClause([ N, X | L ]),
  makeCycle([ C | P ], X, XS).

createCycle(C):- atMostTwo(C), makeCycle(C).

cycleClauses:- 
  cells(R, C), X is R+1, Y is C+1,
  between(1, X, I), between(1, Y, J),
  vertexAdj(I, J, A), createCycle(A), 
  fail.
cycleClauses.


%------------------------------------------------------------------
% Number clauses
% Make sure cells with numbers have the right number of edges
%------------------------------------------------------------------

cellEdges(0, A):- exactlyZero(A).
cellEdges(1, A):- exactlyOne(A).
cellEdges(2, A):- exactlyTwo(A).
cellEdges(3, A):- exactlyThree(A).

numberClauses:- cells(R, C),
  between(1, R, I), between(1, C, J),
  num(I, J, N), cellAdj(I, J, A), cellEdges(N, A),
  fail.
numberClauses.


writeClauses:- cycleClauses, numberClauses.



% ========== No need to change the following: =====================================

main:- symbolicOutput(1), !, writeClauses, halt. % escribir bonito, no ejecutar
main:-  assert(numClauses(0)), assert(numVars(0)),
  tell(clauses), writeClauses, told,
  tell(header),  writeHeader,  told,
  unix('cat header clauses > infile.cnf'),
  unix('picosat -v -o model infile.cnf'),
  unix('cat model'),
  see(model), readModel(M), seen, displaySol(M),
  halt.

var2num(T,N):- hash_term(T,Key), varNumber(Key,T,N),!.
var2num(T,N):- retract(numVars(N0)), N is N0+1, assert(numVars(N)), hash_term(T,Key),
  assert(varNumber(Key,T,N)), assert( num2var(N,T) ), !.

writeHeader:- numVars(N),numClauses(C),write('p cnf '),write(N), write(' '),write(C),nl.

countClause:-  retract(numClauses(N)), N1 is N+1, assert(numClauses(N1)),!.
writeClause([]):- symbolicOutput(1),!, nl.
writeClause([]):- countClause, write(0), nl.
writeClause([Lit|C]):- w(Lit), writeClause(C),!.
w( Lit ):- symbolicOutput(1), write(Lit), write(' '),!.
w(\+Var):- var2num(Var,N), write(-), write(N), write(' '),!.
w(  Var):- var2num(Var,N),           write(N), write(' '),!.
unix(Comando):-shell(Comando),!.
unix(_).

readModel(L):- get_code(Char), readWord(Char,W), readModel(L1), addIfPositiveInt(W,L1,L),!.
readModel([]).

addIfPositiveInt(W,L,[N|L]):- W = [C|_], between(48,57,C), number_codes(N,W), N>0, !.
addIfPositiveInt(_,L,L).

readWord(99,W):- repeat, get_code(Ch), member(Ch,[-1,10]), !, get_code(Ch1), readWord(Ch1,W),!.
readWord(-1,_):-!, fail. %end of file
readWord(C,[]):- member(C,[10,32]), !. % newline or white space marks end of word
readWord(Char,[Char|W]):- get_code(Char1), readWord(Char1,W), !.
%========================================================================================
