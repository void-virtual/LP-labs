
solve() :- 
    permutation(['Roma','Misha','Kolya','Sonya','Dina'],[Boychenko,Karpenko,Lyisenko,Savchenko,Shevchenko]),
    List = [Boychenko,Karpenko,Lyisenko,Savchenko,Shevchenko],
    statement_1(List),
    statement_2(List),
    statement_3(List),

    write("Boychenko "), write(Boychenko), nl,
    write("Karpenko "), write(Karpenko), nl,
    write("Lyisenko "), write(Lyisenko), nl,
    write("Savchenko "), write(Savchenko), nl,
    write("Shevchenko "), write(Shevchenko), nl.
    
statement_1([Boychenko,_,_,_,Shevchenko]) :- 
    in_one_team(Shevchenko, Boychenko).

statement_2([_,Karpenko,_,_,Shevchenko]) :-
    not(died(mother(Shevchenko))),
    not(died(mother(Karpenko))),
    not(parents_never_met(Shevchenko, Karpenko)),
    not(parents_never_met('Kolya', Karpenko)),
    boy(Karpenko),
    'Kolya' \= Karpenko.

statement_3([Boychenko,_,Lyisenko,_,_]) :- 
    not(died(mother(Lyisenko))),
    not(died(mother(Boychenko))),
    not(parents_never_met(Lyisenko, Boychenko)),
    going_to_marry(Lyisenko, Boychenko).

boy('Roma').
boy('Misha').
boy('Kolya').
girl('Sonya').
girl('Dina').

died(mother('Roma')).

in_one_team(X,Y) :-
    boy(X), boy(Y), !.

in_one_team(X,Y) :-
    girl(X), girl(Y), !.

going_to_marry(X,Y) :-
    boy(X), girl(Y), !.

going_to_marry(X,Y) :-
    girl(X), boy(Y), !.

parents_never_met('Dina','Kolya').
parents_never_met('Kolya','Dina').