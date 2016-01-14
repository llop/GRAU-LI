:- use_module(library(clpfd)).

sudoku:-
  % problem vars
  L=[ X11, X12, X13, X14, X15, X16, X17, X18, X19,
      X21, X22, X23, X24, X25, X26, X27, X28, X29,
      X31, X32, X33, X34, X35, X36, X37, X38, X39,
      X41, X42, X43, X44, X45, X46, X47, X48, X49,
      X51, X52, X53, X54, X55, X56, X57, X58, X59,
      X61, X62, X63, X64, X65, X66, X67, X68, X69,
      X71, X72, X73, X74, X75, X76, X77, X78, X79,
      X81, X82, X83, X84, X85, X86, X87, X88, X89,
      X91, X92, X93, X94, X95, X96, X97, X98, X99 ],
  % clues (sud22.pl)
  X17=8,
  X21=1, X22=7, X27=2, X28=3,
  X31=5, X32=2, X33=3, X35=1, X38=9, X39=6,
  X41=8, X43=6, X44=5, X49=1,
  X51=2, X53=7, X54=9, X55=3, X57=5, X58=6,
  X62=3, X63=5, X64=6, X65=8, X67=7, X68=2,
  X71=7, X79=3,
  X82=6, X83=4, X89=2,
  X92=5, X93=1, X95=9, X96=2, X97=6, X98=7,
  L ins 1..9,
  % rows
  all_different([X11,X12,X13,X14,X15,X16,X17,X18,X19]),
  all_different([X21,X22,X23,X24,X25,X26,X27,X28,X29]),
  all_different([X31,X32,X33,X34,X35,X36,X37,X38,X39]),
  all_different([X41,X42,X43,X44,X45,X46,X47,X48,X49]),
  all_different([X51,X52,X53,X54,X55,X56,X57,X58,X59]),
  all_different([X61,X62,X63,X64,X65,X66,X67,X68,X69]),
  all_different([X71,X72,X73,X74,X75,X76,X77,X78,X79]),
  all_different([X81,X82,X83,X84,X85,X86,X87,X88,X89]),
  all_different([X91,X92,X93,X94,X95,X96,X97,X98,X99]),
  % cols
  all_different([X12,X22,X32,X42,X52,X62,X72,X82,X92]),
  all_different([X11,X21,X31,X41,X51,X61,X71,X81,X91]),
  all_different([X13,X23,X33,X43,X53,X63,X73,X83,X93]),
  all_different([X14,X24,X34,X44,X54,X64,X74,X84,X94]),
  all_different([X15,X25,X35,X45,X55,X65,X75,X85,X95]),
  all_different([X16,X26,X36,X46,X56,X66,X76,X86,X96]),
  all_different([X17,X27,X37,X47,X57,X67,X77,X87,X97]),
  all_different([X18,X28,X38,X48,X58,X68,X78,X88,X98]),
  all_different([X19,X29,X39,X49,X59,X69,X79,X89,X99]),
  % squares
  all_different([X11,X21,X31,X12,X22,X32,X13,X23,X33]),
  all_different([X14,X24,X34,X15,X25,X35,X16,X26,X36]),
  all_different([X17,X27,X37,X18,X28,X38,X19,X29,X39]),
  all_different([X41,X51,X61,X42,X52,X62,X43,X53,X63]),
  all_different([X44,X54,X64,X45,X55,X65,X46,X56,X66]),
  all_different([X47,X57,X67,X48,X58,X68,X49,X59,X69]),
  all_different([X71,X81,X91,X72,X82,X92,X73,X83,X93]),
  all_different([X74,X84,X94,X75,X85,X95,X76,X86,X96]),
  all_different([X77,X87,X97,X78,X88,X98,X79,X89,X99]),
  % pretty print solution
  label(L), writeSol(L).

% print functions
writeSol(L):- write(" -------------------------"), nl,
  displaySol(L, 9, 9), nl.
  
displayLine(R):- R==1, write(" |-------|-------|-------|"), nl.
displayLine(R):- R\=1.

displaySep(M):- M==0, write(" | ").
displaySep(M):- M\=0, write(' ').

displaySol([], _, _):- write(" |\n -------------------------"), nl.
  
displaySol(L, R, 0):- write(" |"), nl, 
  RJ is R mod 3, displayLine(RJ),
  RI is R-1, displaySol(L, RI, 9).
  
displaySol([X|XS], R, N):- N>0, M is N mod 3, 
  displaySep(M), write(X), 
  NI is N-1, displaySol(XS, R, NI).
  
  
% solve sudoku and halt execution
main:- sudoku, halt.