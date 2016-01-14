% la mejor solucion encontrada va aqui
:- dynamic(solucion/1).

datosEjemplo( [[1,2,6],[1,6,7],[2,3,8],[6,7,9],[6,8,9],[1,2,4],[3,5,6],[3,5,7],
  [5,6,8],[1,6,8],[4,7,9],[4,6,9],[1,4,6],[3,6,9],[2,3,5],[1,4,5],
  [1,6,7],[6,7,8],[1,2,4],[1,5,7],[2,5,6],[2,3,5],[5,7,9],[1,6,8]] ).

% La poda consiste en descartar estados con mas charlas,
% o con el mismo numero de charlas y mayor maximo de charlas por grupo
% que la mejor solucion encontrada
poda(CH, _):- solucion(_-_-BCH-_-_), CH<BCH.
poda(CH, MS):- solucion(_-_-BCH-_-BMS), CH==BCH, MS<BMS.

% permutaciones de una lista
perm([], []):- !.
perm(L, [X|XS]):- delete(X, L, T), perm(T, XS).

delete(X, [X|T], T).
delete(X, [H|T], [H|NT]):- delete(X, T, NT).

% incrementa el numero de charlas del estado, y actualiza el maximo de charlas por grupo
inc(1, [SG|SGT]-MS, [SGN|SGT]-MSN):- SGN is SG+1, MSN is max(MS, SGN).
inc(N, [SG|SGT]-MS, [SG|SGTN]-MSN):- N1 is N-1, inc(N1, SGT-MS, SGTN-MSN).

% une dos listas, manteniendo el orden
merge([], C, C).
merge(B, [], B).
merge([X|XS], [Y|YS], [X|C]):- X=<Y, merge(XS, [Y|YS], C).
merge([X|XS], [Y|YS], [Y|C]):- X>Y, merge([X|XS], YS, C).

% anade el grupo G a los del slot AS, actualizando otros datos si es necesario
add(G, AS, CH-SG-MS, AS, CH-SG-MS):- member(G, AS).
add(G, AS, CH-SG-MS, ASN, CHN-SGN-MSN):- \+member(G, AS), merge([G], AS, ASN), CHN is CH+1, inc(G, SG-MS, SGN-MSN).

% anade el grupo G a los del slot especificado, actualizando otros datos si es necesario
anade(G, a, [A1,A2,A3]-CH-SG-MS, [AN,A2,A3]-CHN-SGN-MSN):- add(G, A1, CH-SG-MS, AN, CHN-SGN-MSN).
anade(G, b, [A1,A2,A3]-CH-SG-MS, [A1,AN,A3]-CHN-SGN-MSN):- add(G, A2, CH-SG-MS, AN, CHN-SGN-MSN).
anade(G, c, [A1,A2,A3]-CH-SG-MS, [A1,A2,AN]-CHN-SGN-MSN):- add(G, A3, CH-SG-MS, AN, CHN-SGN-MSN).

% asigna los grupos [C1,C2,C3] a los slots [A1,A2,A3]
asigna([C1,C2,C3], [A1,A2,A3], AS-CH-SG-MS, ASN-CHN-SGN-MSN):-
  anade(C1, A1, AS-CH-SG-MS, ASX-CHX-SGX-MSX),
  anade(C2, A2, ASX-CHX-SGX-MSX, ASY-CHY-SGY-MSY),
  anade(C3, A3, ASY-CHY-SGY-MSY, ASN-CHN-SGN-MSN).

% solucion encontrada
backtrack([], AA-AS-CH-SG-MS):- 
  !, poda(CH, MS),                    % cut aqui, no queremos repetir estados
  retract(solucion(_)),               % si esta solucion es mejor que la anterior
  assert(solucion(AA-AS-CH-SG-MS)),   % establecer la nueva mejor solucion (retract y assert)
  fail.                               % hay que fallar si queremos seguir buscando

% asigna slots para los grupos del siguiente estudiante
% AA - lista de los 3 slots correspondientes a los grupos de los estudiantes
% AS - lista de los grupos que daran charlas en cada uno de los 3 slots
% CH - total de charlas largas
% SG - lista que indica cuantas charlas dara cada uno de los 9 grupos
% MS - maximo numero de charlas que dara un solo grupo
backtrack([X|XS], AA-AS-CH-SG-MS):- 
  poda(CH, MS), perm([a,b,c], L),               % permutaciones de los 3 slots
  asigna(X, L, AS-CH-SG-MS, ASN-CHN-SGN-MSN),   % asignar slots a los grupos
  backtrack(XS, [L|AA]-ASN-CHN-SGN-MSN).        % recursion

soluciona:- 
  assert(solucion([]-[]-28-[]-4)),                                        % solucion inicial muy mala
  datosEjemplo(D), backtrack(D, []-[[],[],[]]-0-[0,0,0,0,0,0,0,0,0]-0);   % ; detiene el bactracking
  solucion(AA-AS-CH-SG-MS), muestraSolucion(AA-AS-CH-SG-MS).              % imprimir la solucion

repes3Veces(_, [], []).
repes3Veces(N, [3|XS], [N|L]):- N1 is N+1, repes3Veces(N1, XS, L).
repes3Veces(N, [_|XS], L):- N1 is N+1, repes3Veces(N1, XS, L).

muestraSeRepiten(SG-3):- repes3Veces(1, SG, L), 
  write("Grupos que dan la charla larga 3 veces: "), write(L).
muestraSeRepiten(_-_):- write("No es necesario dar ninguna charla larga 3 veces.").

escribeSlot(a):- write('A').
escribeSlot(b):- write('B').
escribeSlot(c):- write('C').

escribeSlots([S1,S2,S3]):- write('['), escribeSlot(S1), write(','), 
  escribeSlot(S2), write(','), 
  escribeSlot(S3), write(']').

muestraAsignaciones(0, [], D):- datosEjemplo(D).
muestraAsignaciones(N, [X|XS], DS):- muestraAsignaciones(N1, XS, [D|DS]), N is N1+1,
  write(N), write("\t"), write(D), write("\t  "), escribeSlots(X), nl.

muestraSolucion(AA-[AS1,AS2,AS3]-CH-SG-MS):-
  write("Numero minimo de charlas: "), write(CH), nl, nl,
  write("Grupos slot A: "), write(AS1), nl,
  write("Grupos slot B: "), write(AS2), nl,
  write("Grupos slot C: "), write(AS3), nl, nl,
  muestraSeRepiten(SG-MS), nl, nl,
  write("Est.\tGrupos\t  Slots"), nl,
  write("====\t======\t  ====="), nl,
  muestraAsignaciones(_, AA, _).

main:- soluciona, halt.



        