:- use_module(library(clpfd)).

% ¿Qué dígitos diferentes tenemos que asignar a las letras S,E,N,D,M,O,R,Y, 
% de manera que se cumpla la suma S E N D + M O R E = M O N E Y?

sendmory([S,E,N,D]+[M,O,R,E]=[M,O,N,E,Y]):-
  V=[S,E,N,D,M,O,R,Y], V ins 0..9,            % try values from 0..9 for letters in V
  M#\=0, S#\=0, all_different(V),             % M and S can't be 0, and all values different
  S*1000+E*100+N*10+D+M*1000+O*100+R*10+E#=M*10000+O*1000+N*100+E*10+Y,   % must be equal!
  label(V).
  
writeSol(A-B-C):-
  write("    [S,E,N,D] =   "), write(A), nl, 
  write("  + [M,O,R,E] =   "), write(B), nl, 
  write("  -------------------------"), nl, 
  write("  [M,O,N,E,Y] = "), write(C), nl.

main:- sendmory(A+B=C), writeSol(A-B-C), halt.