writeHeaderPS:-
    writeln('%!PS'),
    writeln('matrix currentmatrix /originmat exch def'),
    writeln('/umatrix {originmat matrix concatmatrix setmatrix} def'),
    writeln('[28.3465 0 0 28.3465 10.5 100.0] umatrix').

writeGrid:-
    writeln('0.01 setlinewidth'),
    writeVertGrid,
    writeHorizGrid.

writeVertGrid:-
    rows(R), columns(C), C1 is C+1,
    between(1,R,I), between(1,C1,J), drawVertical(I,J),fail.
writeVertGrid.

writeHorizGrid:-
    rows(R), columns(C), R1 is R+1,
    between(1,R1,I), between(1,C,J), drawHorizontal(I,J),fail.
writeHorizGrid.

drawVertical(I,J):-
    rows(R),columns(C),
    Size is min(22/R,18/C),
    X is 1+(J-1)*Size,
    Y is 23-(I-1)*Size,
    write(X), write(' '), write(Y), write(' moveto'),nl,
    Y1 is Y-Size,
    write(X), write(' '), write(Y1), write(' lineto'),nl,
    writeln('stroke').

drawHorizontal(I,J):-
    rows(R),columns(C),
    Size is min(22/R,18/C),
    X is 1+(J-1)*Size,
    Y is 23-(I-1)*Size,
    write(X), write(' '), write(Y), write(' moveto'),nl,
    X1 is X+Size,
    write(X1), write(' '), write(Y), write(' lineto'),nl,
    writeln('stroke').

writeNumbers:-
    num(I,J,K),
    writeNumber(I,J,K),
    fail.
writeNumbers.

writeNumber(I,J,K):-
    rows(R),columns(C),
    Size is min(22/R,18/C),
    X is 1+(J-1)*Size + 3*Size/7,
    Y is 23-(I-1)*Size - 5*Size/7,
    writeln('0.001 setlinewidth'),
    S is Size/2,
    write('/Times-Roman findfont '), write(S), writeln(' scalefont setfont'),
    write(X), write(' '), write(Y), write(' moveto ('), write(K), writeln(') show').

writeSolution([X|M]):-
    writeLine(X),
    writeSolution(M).
writeSolution([]).
    
writeLine(X):-num2var(X,h-I-J),!,
    rows(R), columns(C), T is max(R,C),
    W is 2/T,
    write(W), 
    writeln(' setlinewidth'),
    drawHorizontal(I,J).
writeLine(X):-num2var(X,v-I-J),!,
    rows(R), columns(C), T is max(R,C),
    W is 2/T,
    write(W), 
    writeln(' setlinewidth'),
    drawVertical(I,J).
writeLine(_).

displaySol(M):-
    tell('graph.ps'),
    writeHeaderPS,
    writeGrid,
    writeNumbers,
    writeSolution(M),
    writeln('showpage'),
    told.
