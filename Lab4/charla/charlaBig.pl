% la mejor solucion encontrada va aqui
:- dynamic(solucion/1).

datosEjemplo( [[1,2,6],[1,6,7],[2,3,8],[6,7,9],[6,8,9],[1,2,4],[3,5,6],[3,5,7],
  [5,6,8],[1,6,8],[4,7,9],[4,6,9],[1,4,6],[3,6,9],[2,3,5],[1,4,5],
  [1,6,7],[6,7,8],[1,2,4],[1,5,7],[2,5,6],[2,3,5],[5,7,9],[1,6,8]] ).


comb(0, _, []):- !.
comb(N, [X|T], [X|CO]):- N1 is N-1, comb(N1, T, CO).
comb(N, [_|T], CO):- comb(N, T, CO).


anadeSiNoEsta(X, L, L):- member(X, L).
anadeSiNoEsta(X, L, [X|L]):- \+member(X, L).

queGrupos([], []).
queGrupos([[G1,G2,G3]|XS], LN):- queGrupos(XS, L),
  anadeSiNoEsta(G1, L, L1),
  anadeSiNoEsta(G2, L1, L2),
  anadeSiNoEsta(G3, L2, LN).


estaEnLista(X, L, 1):- member(X, L).
estaEnLista(X, L, 0):- \+member(X, L).

estaEnListas(X, [L1,L2,L3], E1-E2-E3):-
  estaEnLista(X, L1, E1),
  estaEnLista(X, L2, E2),
  estaEnLista(X, L3, E3).

queAsignacion(1-_-_, _-1-_, _-_-1, [a,b,c]).
queAsignacion(1-_-_, _-_-1, _-1-_, [a,c,b]).
queAsignacion(_-1-_, 1-_-_, _-_-1, [b,a,c]).
queAsignacion(_-1-_, _-_-1, 1-_-_, [b,c,a]).
queAsignacion(_-_-1, 1-_-_, _-1-_, [c,a,b]).
queAsignacion(_-_-1, _-1-_, 1-_-_, [c,b,a]).

comprueba([], _, []).
comprueba([[G1,G2,G3]|XS], A, [AA|AAT]):- 
  estaEnListas(G1, A, E11-E12-E13),
  estaEnListas(G2, A, E21-E22-E23),
  estaEnListas(G3, A, E31-E32-E33),
  queAsignacion(E11-E12-E13, E21-E22-E23, E31-E32-E33, AA),
  comprueba(XS, A, AAT).


poda(C, _):- solucion(_-_-BC-_), C<BC.
poda(C, M):- solucion(_-_-BC-BM), C==BC, M<BM.


anade(G, a, [A1,A2,A3], [[G|A1],A2,A3]).
anade(G, b, [A1,A2,A3], [A1,[G|A2],A3]).
anade(G, c, [A1,A2,A3], [A1,A2,[G|A3]]).

asigna(_, [], A-C, A-C).
asigna(G, [X|XS], A-C, AN-CN):-
  anade(G, X, A, AX), CX is C+1,
  asigna(G, XS, AX-CX, AN-CN).

backtrack([], A-C-M):-
  !, poda(C, M),
  datosEjemplo(D), comprueba(D, A, AA),
  retract(solucion(_)),
  assert(solucion(AA-A-C-M)), 
  fail.
backtrack([X|XS], A-C-M):- 
  poda(C, M),
  between(1, 3, N), comb(N, [a,b,c], L),
  asigna(X, L, A-C, AN-CN),
  MN is max(M, N),
  backtrack(XS, AN-CN-MN).

soluciona:- 
  assert(solucion([]-[]-28-4)),
  datosEjemplo(D), queGrupos(D, LG), 
  backtrack(LG, [[],[],[]]-0-0);
  solucion(AA-A-C-M), write(AA), nl, write(A), nl, write(C), nl, write(M), nl.


main:- soluciona, halt.

