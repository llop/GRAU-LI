:- use_module(library(clpfd)).

% Tenemos 5 ordenadores idénticos que pueden ejecutar tareas de computación, una detrás de otra. 
% ¿Cuánto tiempo necesitaré como mínimo para ejecutar las siguientes 14 tareas (cada una en al menos un ordenador)? 
% task 1 takes 8 minutes 
% task 2 takes 6 minutes 
% task 3 takes 7 minutes 
% task 4 takes 5 minutes 
% task 5 takes 2 minutes 
% task 6 takes 3 minutes 
% task 7 takes 8 minutes 
% task 8 takes 6 minutes 
% task 9 takes 2 minutes 
% task 10 takes 6 minutes 
% task 11 takes 1 minutes 
% task 12 takes 2 minutes 
% task 13 takes 6 minutes 
% task 14 takes 4 minutes 

ordenadores([C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14]):- 
  
  L=[A011, A012, A013, A014, A015,                      % Aij determina si la tarea i la hace el ordenador j
    A021, A022, A023, A024, A025,
    A031, A032, A033, A034, A035,
    A041, A042, A043, A044, A045,
    A051, A052, A053, A054, A055,
    A061, A062, A063, A064, A065,
    A071, A072, A073, A074, A075,
    A081, A082, A083, A084, A085,
    A091, A092, A093, A094, A095,
    A101, A102, A103, A104, A105,
    A111, A112, A113, A114, A115,
    A121, A122, A123, A124, A125,
    A131, A132, A133, A134, A135,
    A141, A142, A143, A144, A145],
  L ins 0..1,                                           % Aij es 0 ó 1
  
  % otra forma de hacer las restricciones (es peor, tarda más en solucionar):
  % T=[T01,T02,T03,T04,T05,T06,T07,T08,T09,T10,T11,T12,T13,T14],      % Ti indica qué ordenador realiza la tarea i
  % T ins 1..5,                                                       % valores entre 1 y 5
  % T01#=1 #<==> A011#=1, T01#=2 #<==> A012#=1, T01#=3 #<==> A013#=1, T01#=4 #<==> A014#=1, T01#=5 #<==> A015#=1,
  % T02#=1 #<==> A021#=1, T02#=2 #<==> A022#=1, T02#=3 #<==> A023#=1, T02#=4 #<==> A024#=1, T02#=5 #<==> A025#=1,
  % T03#=1 #<==> A031#=1, T03#=2 #<==> A032#=1, T03#=3 #<==> A033#=1, T03#=4 #<==> A034#=1, T03#=5 #<==> A035#=1,
  % T04#=1 #<==> A041#=1, T04#=2 #<==> A042#=1, T04#=3 #<==> A043#=1, T04#=4 #<==> A044#=1, T04#=5 #<==> A045#=1,
  % T05#=1 #<==> A051#=1, T05#=2 #<==> A052#=1, T05#=3 #<==> A053#=1, T05#=4 #<==> A054#=1, T05#=5 #<==> A055#=1,
  % T06#=1 #<==> A061#=1, T06#=2 #<==> A062#=1, T06#=3 #<==> A063#=1, T06#=4 #<==> A064#=1, T06#=5 #<==> A065#=1,
  % T07#=1 #<==> A071#=1, T07#=2 #<==> A072#=1, T07#=3 #<==> A073#=1, T07#=4 #<==> A074#=1, T07#=5 #<==> A075#=1,
  % T08#=1 #<==> A081#=1, T08#=2 #<==> A082#=1, T08#=3 #<==> A083#=1, T08#=4 #<==> A084#=1, T08#=5 #<==> A085#=1,
  % T09#=1 #<==> A091#=1, T09#=2 #<==> A092#=1, T09#=3 #<==> A093#=1, T09#=4 #<==> A094#=1, T09#=5 #<==> A095#=1,
  % T10#=1 #<==> A101#=1, T10#=2 #<==> A102#=1, T10#=3 #<==> A103#=1, T10#=4 #<==> A104#=1, T10#=5 #<==> A105#=1,
  % T11#=1 #<==> A111#=1, T11#=2 #<==> A112#=1, T11#=3 #<==> A113#=1, T11#=4 #<==> A114#=1, T11#=5 #<==> A115#=1,
  % T12#=1 #<==> A121#=1, T12#=2 #<==> A122#=1, T12#=3 #<==> A123#=1, T12#=4 #<==> A124#=1, T12#=5 #<==> A125#=1,
  % T13#=1 #<==> A131#=1, T13#=2 #<==> A132#=1, T13#=3 #<==> A133#=1, T13#=4 #<==> A134#=1, T13#=5 #<==> A135#=1,
  % T14#=1 #<==> A141#=1, T14#=2 #<==> A142#=1, T14#=3 #<==> A143#=1, T14#=4 #<==> A144#=1, T14#=5 #<==> A145#=1,
  
  
  % A011+A012+A013+A014+A015#=1,                % una tarea la realiza 1 solo ordenador
  % A021+A022+A023+A024+A025#=1,                % expresado como suma
  % A031+A032+A033+A034+A035#=1,
  % A041+A042+A043+A044+A045#=1,
  % A051+A052+A053+A054+A055#=1,
  % A061+A062+A063+A064+A065#=1,
  % A071+A072+A073+A074+A075#=1,
  % A081+A082+A083+A084+A085#=1,
  % A091+A092+A093+A094+A095#=1,
  % A101+A102+A103+A104+A105#=1,
  % A111+A112+A113+A114+A115#=1,
  % A121+A122+A123+A124+A125#=1,
  % A131+A132+A133+A134+A135#=1,
  % A141+A142+A143+A144+A145#=1,
  
  sum([A011,A012,A013,A014,A015], #=, 1),       % una tarea la realiza 1 solo ordenador
  sum([A021,A022,A023,A024,A025], #=, 1),       % expresado con la función sum
  sum([A031,A032,A033,A034,A035], #=, 1),
  sum([A041,A042,A043,A044,A045], #=, 1),
  sum([A051,A052,A053,A054,A055], #=, 1),
  sum([A061,A062,A063,A064,A065], #=, 1),
  sum([A071,A072,A073,A074,A075], #=, 1),
  sum([A081,A082,A083,A084,A085], #=, 1),
  sum([A091,A092,A093,A094,A095], #=, 1),
  sum([A101,A102,A103,A104,A105], #=, 1),
  sum([A111,A112,A113,A114,A115], #=, 1),
  sum([A121,A122,A123,A124,A125], #=, 1),
  sum([A131,A132,A133,A134,A135], #=, 1),
  sum([A141,A142,A143,A144,A145], #=, 1),
  
  % Oi es el tiempo de ejecución del i-ésimo ordenador 
  C1*A011+C2*A021+C3*A031+C4*A041+C5*A051+C6*A061+C7*A071+C8*A081+C9*A091+C10*A101+C11*A111+C12*A121+C13*A131+C14*A141#=O1,
  C1*A012+C2*A022+C3*A032+C4*A042+C5*A052+C6*A062+C7*A072+C8*A082+C9*A092+C10*A102+C11*A112+C12*A122+C13*A132+C14*A142#=O2,
  C1*A013+C2*A023+C3*A033+C4*A043+C5*A053+C6*A063+C7*A073+C8*A083+C9*A093+C10*A103+C11*A113+C12*A123+C13*A133+C14*A143#=O3,
  C1*A014+C2*A024+C3*A034+C4*A044+C5*A054+C6*A064+C7*A074+C8*A084+C9*A094+C10*A104+C11*A114+C12*A124+C13*A134+C14*A144#=O4,
  C1*A015+C2*A025+C3*A035+C4*A045+C5*A055+C6*A065+C7*A075+C8*A085+C9*A095+C10*A105+C11*A115+C12*A125+C13*A135+C14*A145#=O5,
  
  max(O1,max(O2,max(O3,max(O4,O5))))#=O,    % O es el tiempo del ordenador que más tarda
  labeling([min(O)], L),                    % minimizar O
  writeSol(L, O, [O1,O2,O3,O4,O5]).


% imprimir resultados
writeSol(L, O, T):- 
  write("Tiempo mínimo: "), write(O), write(" minutos"), nl, 
  write("Ordenador\tTiempo\t\tTareas"), nl,
  write("---------\t------\t\t------"), nl, 
  tareasOrdenador(L, 1, 1, S), displaySol(1, S, T).

% anade la tarea T a la lista del ordenador correspondiente
anadeTarea(1, T, [T1,T2,T3,T4,T5], [[T|T1],T2,T3,T4,T5]).
anadeTarea(2, T, [T1,T2,T3,T4,T5], [T1,[T|T2],T3,T4,T5]).
anadeTarea(3, T, [T1,T2,T3,T4,T5], [T1,T2,[T|T3],T4,T5]).
anadeTarea(4, T, [T1,T2,T3,T4,T5], [T1,T2,T3,[T|T4],T5]).
anadeTarea(5, T, [T1,T2,T3,T4,T5], [T1,T2,T3,T4,[T|T5]]).

% llena una lista con las tareas para cada ordenador
tareasOrdenador([], 14, 6, [[],[],[],[],[]]).
tareasOrdenador(L, T, 6, S):- TI#=T+1, tareasOrdenador(L, TI, 1, S).
tareasOrdenador([1|XS], T, O, S):- OI#=O+1, tareasOrdenador(XS, T, OI, SI), anadeTarea(O, T, SI, S).
tareasOrdenador([0|XS], T, O, S):- OI#=O+1, tareasOrdenador(XS, T, OI, S).

displaySol(_, [], []).
displaySol(O, [X|XS], [T|TS]):- 
  write(O), write("\t\t"), write(T), write("min.\t\t"), write(X), nl,
  OI#=O+1, displaySol(OI, XS, TS).


% solucion para C1=8,C2=6,C3=7,C4=5,C5=2,C6=3,C7=8,C8=6,C9=2,C10=6,C11=1,C12=2,C13=6,C14=4 
main:- ordenadores([8,6,7,5,2,3,8,6,2,6,1,2,6,4]), halt.

% Resultado esperado:
% O1 = 6+4     = 10
% O2 = 6+6+2   = 14 
% O3 = 3+8+2+1 = 14
% O4 = 7+5+2   = 14
% O5 = 8+6     = 14