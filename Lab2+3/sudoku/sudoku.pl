:-include('../utils').
:-include('sud78'). 
:-dynamic(varNumber/3).
symbolicOutput(0).       % set to 1 to see symbolic output only; 0 otherwise.


%------------------------------------------
% Restriction clauses
%   1 - every cell has a number (1-9)
%   2 - No row has repeated numbers
%   2 - No column has repeated numbers
%   2 - No 3x3 square has repeated numbers
%------------------------------------------

cellClauses:- 
  between(1, 9, I), between(1, 9, J),
  findall(x-I-J-N, between(1, 9, N), L), exactlyOne(L),
  fail.
cellClauses.

rowClauses:-
  between(1, 9, I), between(1, 9, N),
  findall(x-I-J-N, between(1, 9, J), L), exactlyOne(L),
  fail.
rowClauses.

colClauses:- 
  between(1, 9, J), between(1, 9, N),
  findall(x-I-J-N, between(1, 9, I), L), exactlyOne(L),
  fail.
colClauses.

squareClauses:-
  between(0, 2, I), between(0, 2, J),
  IS is I*3+1, JS is J*3+1, 
  IE is IS+2,  JE is JS+2,  
  between(1, 9, N),
  between(IS, IE, I1), between(JS, JE, J1),
  between(IS, IE, I2), between(JS, JE, J2),
  I1<I2, J1\=J2,
  writeClause([ \+x-I1-J1-N, \+x-I2-J2-N ]),
  fail.
squareClauses.


%------------------------------------------
% Add problem clues
%------------------------------------------

fill:- filled(I, J, N), writeClause([ x-I-J-N ]), fail.
fill.

writeClauses:- cellClauses, rowClauses, colClauses, squareClauses, fill.


%------------------------------------------
% Display functions (print solution)
%------------------------------------------

writeSep(0).
writeSep(N):- write('-'), M is N-1, writeSep(M), !.

displaySol(S):- 
  between(1, 9, I), between(1, 9, J), between(1, 9, N),
  var2num(x-I-J-N, V), member(V, S),
  IM is mod(I-1, 3), (IM=0, J=1 -> write(' '), writeSep(25), nl; true),
  JM is mod(J-1, 3), (JM=0 -> write(' | '); write(' ')),
  write(N), (J=9 -> write(' |'), nl; true),
  fail.
displaySol(_):- write(' '), writeSep(25), nl.



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
