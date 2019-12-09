% Стандартные предикаты

l_member(X,[X|T]).
l_member(X,[H|T]):-member(X,T).

l_length([], 0).
l_length([X|Y], S) :- 
    l_length(Y, S1), S is S1 + 1.

l_remove(X,[X|T],T).
l_remove(X,[H|T],[H|R]):-l_remove(X,T,R).

l_append([],L,L).
l_append([X|T],L,[X|L1]):-append(T,L,L1).

l_continious_sublist(R,L):-append(_,K,L),append(R,_,K).

l_sublist(Sub, List) :-
	l_sublist_(List, Sub).

l_sublist_([], []).
l_sublist_([H|T], Sub) :-
	l_sublist__(T, H, Sub).

l_sublist__([], H, [H]).
l_sublist__([], _, []).
l_sublist__([H|T], X, [X|Sub]) :-
	l_sublist__(T, H, Sub).
l_sublist__([H|T], _, Sub) :-
	l_sublist__(T, H, Sub).

l_permute([],[]).
l_permute(L,[X|T]):- l_remove(X,L,R), l_permute(R,T).

% Особый предикат 1 - удаление последнего элемента

l_remove_last([X|[]], []) :- !.
l_remove_last([X|T], R) :- 
    l_remove_last(T, R1), R = [X|R1].

l_remove_last2([X|[]], []) :- !.
l_remove_last2([X|T], R) :- 
    l_remove_last2(T, R1), append([X], R1, R).


% Особый предикат 2 для обработки числовых списков - вычисление числа четных элементов

l_count_even([], 0) :- !.
l_count_even([X|T], R) :-
	X mod 2 =:= 0, l_count_even(T, R1), R is R1 + 1, !.
l_count_even([X|T], R) :-
	X mod 2 =\= 0, l_count_even(T, R), !.

l_count_even2([], 0) :- !.
l_count_even2([X|T], R) :-
	X mod 2 =:= 0, remove(X,[X|T],T1),l_count_even(T1, R1), R is R1 + 1, !.
l_count_even2([X|T], R) :-
	X mod 2 =\= 0, remove(X,[X|T],T1),l_count_even(T1, R),!.

% Содержательный пример - удаление 
