:- use_module(library(clpfd)).

% Now you are flying back from China, and you should write such a program to compute how many
% units of each one of six products you should take in your suitcase with capacity 80Kg, if you want
% to maximize the total value, and the products have the following weights (Kg) and values (Euros):
%           p1  p2  p3  p4  p5  p6
%   ------------------------------
%   weight: 1   2   3   5   6   7
%   value:  1   4   7   11  14  15

china:- L=[A,B,C,D,E,F],                            % variables:    number of units of each product
  L ins 0..80,                                      % domain:       0 to 80 units
  1*A+2*B+3*C+5*D+6*E+7*F#=<80,                     % constraints:  should carry 80Kg or less
  labeling([max(1*A+4*B+7*C+11*D+14*E+15*F)], L),   % solution:     maximize carried weigh
  write(L), nl, !.


main:- china, halt.