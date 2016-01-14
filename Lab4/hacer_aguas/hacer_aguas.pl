%-----------------------------------------------------------
% Como el problema de las garrafas de 'La Jungla III'
%-----------------------------------------------------------

nat(1). 
nat(N):- nat(X), N is X+1.

cubos(5, 8).                              % capacidades cubos

unPaso([_,X], [0,X]).                     % vaciar cubo 5
unPaso([X,_], [X,0]).                     % vaciar cubo 8
unPaso([_,X], [C,X]):- cubos(C, _).       % rellenar cubo 5
unPaso([X,_], [X,C]):- cubos(_, C).       % rellenar cubo 8
unPaso([AX,AY], [SX,SY]):- cubos(C, _),   % pasar del cubo 8 al 5
  SX is min(AX+AY, C), SY is AX+AY-SX.
unPaso([AX,AY], [SX,SY]):- cubos(_, C),   % pasar del cubo 5 al 8
  SY is min(AX+AY, C), SX is AX+AY-SY.

camino(E, E, C, C, _).
camino(EstadoActual, EstadoFinal, CaminoHastaAhora, CaminoTotal, N):-
  length(CaminoHastaAhora, X), X<N, 
  unPaso(EstadoActual, EstSiguiente),
  \+member(EstSiguiente, CaminoHastaAhora),
  camino(EstSiguiente, EstadoFinal, [EstSiguiente|CaminoHastaAhora], CaminoTotal, N).

solucionOptima:- nat(N),                            % Buscamos solucion de "coste" 0; si no, de 1, etc.
  camino([0,0], [0,4], [[0,0]], C, N),              % En "hacer aguas": -un estado es [cubo5,cubo8]
  muestraSolucion(N, C).

muestraSolucion(N, C):- NI is N-1,
  write("Solucion en "), write(NI), write(" pasos\n"),
  displaySol(C, _).
  
displaySol([], 0).
displaySol([X|XS], N):- displaySol(XS, NI), 
  N is NI+1, write(NI), write(" - "), write(X), nl.

main:- solucionOptima, halt.
