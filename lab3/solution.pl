% состояние - два списка шаров, шары из одного спика отделены от шаров из другого пустой ячейкой
% b - черный шар, w - белый шар
% [b,b,b], [w,w,w] -> [w,w,w], [b,b,b]

% предикат для вставки и удаления из произвольного места в списке
% используется для описания переходов
% ?- remove_index([1,2,3,4,5], L, Elem, 3).
% L = [1, 2, 4, 5],
% Elem = 3 
%
% ?- remove_index(L, [1,2,3], 6, 1).
% L = [6, 1, 2, 3]

remove_index([X|T], T, X, 1).
remove_index([X|T], NewList, RemovedElement, Index) :-
    Index \= 1,
    NewIndex is Index - 1,
    remove_index(T, List, RemovedElement, NewIndex),
    NewList = [X|List].

remove_last([X|T], L, E) :- 
    length([X|T], Length),
    remove_index([X|T], L, E, Length).


% определяем простанство состояний
next_state(state(LList, RList), state(NewLList, NewRList)) :- 
    length(LList, LLength),
    remove_index(LList, NewLList, X, LLength),
    NewRList = [X|RList].

next_state(state(LList, RList), state(NewLList, NewRList)) :- 
    RList = [X|NewRList],
    append(LList, [X], NewLList).
    
next_state(state(LList, RList), state(NewLList, NewRList)) :- 
    remove_last(LList, Temp, Last),
    remove_last(Temp, NewLList, PreLast),
    NewRList = [Last, PreLast|RList].

next_state(state(LList, RList), state(NewLList, NewRList)) :- 
    RList = [First, Second|NewRList],
    append(LList, [Second, First], NewLList).

% предикат для печати результата
print_result([]).
print_result([state(X,Y)|T]) :-
    write(X), write("  "), write(Y), nl,
    print_result(T).

% предикат для решения задачи - запускает рекурсивный поиск в глубину
solve() :-
    get_time(T1),
    dfs([state([b,b,b], [w,w,w])], state([w,w,w], [b,b,b]), List),
    get_time(T2),
    reverse(List, Result),
    T is T2 - T1,
    print_result(Result),
    write("time:"), write(T), nl.

prolong([X|T], [Y, X|T]) :-
    next_state(X, Y), not(member(Y, [X|T])).

dfs([X|T], X, [X|T]).

dfs(P,F,L) :-
    prolong(P, P1), dfs(P1, F, L).