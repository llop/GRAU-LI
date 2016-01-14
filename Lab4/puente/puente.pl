
nat(0).
nat(N):- nat(X), N is X+1.

% combinaciones de N elementos de una lista
comb(0, T, T, []):- !.
comb(N, [X|T], CA, [X|CO]):- N1 is N-1, comb(N1, T, CA, CO).
comb(N, [X|T], [X|CA], CO):- comb(N, T, CA, CO).

% une dos listas, manteniendo el orden
merge([], C, C).
merge(B, [], B).
merge([X|XS], [Y|YS], [X|C]):- X=<Y, merge(XS, [Y|YS], C).
merge([X|XS], [Y|YS], [Y|C]):- X>Y, merge([X|XS], YS, C).

% maximo elemento de una lista
listMax([X], X).
listMax([X|XS], N):- listMax(XS, M), N is max(M, X).

% envia 1 o 2 personas de un lado al otro del puente
% las personas salen del lado D1 para ir al I1, con coste C1
cruza(I1-D1-C1, I2-D2-C2):-
  length(D1, N), N1 is min(N, 2),           % que crucen maximo 2 personas
  between(1, N1, A), comb(A, D1, D2, CO),   % combinaciones de A elementos de D1
  merge(I1, CO, I2),                        % anadir a I1 los que cruzan
  listMax(CO, M), C2 is C1+M.               % sumar el coste de cruzar

% existen 2 tipos de paso:
% cruzar de un lado al otro, o del otro al uno
unPaso(a-I1-D1-C1, b-I2-D2-C2):- cruza(I1-D1-C1, I2-D2-C2).
unPaso(b-I1-D1-C1, a-I2-D2-C2):- cruza(D1-I1-C1, D2-I2-C2).

% podamos estados con coste superior a N
poda(_-_-_-C, N):- N>C.

camino(E, E, C, C, _).
camino(EstadoActual, EstadoFinal, CaminoHastaAhora, CaminoTotal, N):-
  poda(EstadoActual, N),
  unPaso(EstadoActual, EstSiguiente),
  \+member(EstSiguiente, CaminoHastaAhora),
  camino(EstSiguiente, EstadoFinal, [EstSiguiente|CaminoHastaAhora], CaminoTotal, N).

solucionOptima:- nat(N), 
  camino(a-[]-[1,2,5,8]-0, b-[1,2,5,8]-[]-N, [a-[]-[1,2,5,8]-0], C, N),
  muestraSolucion(N, C).

muestraSolucion(N, C):-
  write("Solucion de coste "), write(N), nl, 
  displaySol(C, _).
  
displaySol([], -1).
displaySol([X|XS], N):- displaySol(XS, NI), 
  N is NI+1, write(N), write(" - "), write(X), nl.
  
main:- solucionOptima, halt.

