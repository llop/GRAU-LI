:-dynamic(zero/1).


%--------------------------------------
% zero and negation
%--------------------------------------

zero(0).

not(\+X, X).
not(X, \+X). 



%--------------------------------------
% Heule at most one clauses
%--------------------------------------

simpleAMO(_, []).
simpleAMO(C, [ X | XS ]):- not(X, Y), writeClause([ C, Y ]), simpleAMO(C, XS).

simpleAMO([]).
simpleAMO([ X | XS ]):- not(X, C), simpleAMO(C, XS), simpleAMO(XS).
	  
heuleAMO([], _).
heuleAMO([_], _).
heuleAMO(C, _):- simpleAMO(C).
heuleAMO([ X, Y, Z, U, V, W | XS ], N):-
  zero(A), K=heule-A-N, simpleAMO([ X, Y, Z, U, K ]),
  append(XS, [ V, W, \+K ], L), M is N+1, heuleAMO(L, M).

heuleAMO(C):- heuleAMO(C, 0).


%--------------------------------------
% Cardinality constraints
%--------------------------------------

exactlyZero([]).
exactlyZero([ X | XS ]):- writeClause([ \+X ]), exactlyZero(XS).

exactlyOne(C):- atLeastOne(C), atMostOne(C).
  
atLeastOne(C):- writeClause(C).

atMostOne([]).
atMostOne(C):- heuleAMO(C), retract(zero(N)), M is N+1, assert(zero(M)), !.
  
  
  