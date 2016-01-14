
nat(1).
nat(N):- nat(X), N is X+1.

canoa(2).               % capacidad de la canoa
 
mayoria(0, _).          % si no hay misioneros, o hay tantos como canibales, 
mayoria(M, C):- M>=C.   % el estado es legal

% envia misioneros y/o canibales de una orilla a la otra; de [MA2,CA2] a [MA1,CA1]
% el estado resultante es [MB1,CB1]-[MB2,CB2]
cruza([MA1,CA1]-[MA2,CA2], [MB1,CB1]-[MB2,CB2]):- 
  canoa(A), between(0, A, M), between(0, A, C),   % enviar M misioneros y C canibales
  MC is M+C, MC>0, MC=<A,                         % entre 1 y 2 tripulantes en la canoa
  MB2 is MA2-M, MB2>=0, CB2 is CA2-C, CB2>=0,     % calcular cuantos quedan en la orilla de origen,
  mayoria(MB2, CB2),                              % asegurarse que los canibales no pueden comer en la orilla origen
  MB1 is MA1+M, CB1 is CA1+C,                     % cuantos quedan en la orilla destino,
  mayoria(MB1, CB1).                              % asegurarse que los canibales no pueden comer en la orilla destino

% solo 2 tipos de pasos:
% cruzar de una orilla a otra, o de la otra a la una
unPaso(a-[MA1,CA1]-[MA2,CA2], b-[MB1,CB1]-[MB2,CB2]):-
  cruza([MA1,CA1]-[MA2,CA2], [MB1,CB1]-[MB2,CB2]).
unPaso(b-[MA1,CA1]-[MA2,CA2], a-[MB1,CB1]-[MB2,CB2]):-
  cruza([MA2,CA2]-[MA1,CA1], [MB2,CB2]-[MB1,CB1]).

camino(E, E, C, C, _).
camino(EstadoActual, EstadoFinal, CaminoHastaAhora, CaminoTotal, N):-
  length(CaminoHastaAhora, X), X<N, 
  unPaso(EstadoActual, EstSiguiente),
  \+member(EstSiguiente, CaminoHastaAhora),
  camino(EstSiguiente, EstadoFinal, [EstSiguiente|CaminoHastaAhora], CaminoTotal, N).

solucionOptima:- nat(N), 
  camino(a-[0,0]-[3,3], b-[3,3]-[0,0], [a-[0,0]-[3,3]], C, N),
  muestraSolucion(N, C).

muestraSolucion(N, C):- NI is N-1,
  write("Solucion en "), write(NI), write(" pasos\n"), 
  displaySol(C, _).
  
displaySol([], 0).
displaySol([X|XS], N):- displaySol(XS, NI), 
  N is NI+1, write(NI), write(" - "), write(X), nl.

main:- solucionOptima, halt.
