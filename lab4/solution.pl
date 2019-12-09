parent(alexei, tolia).
parent(alexei, volodia).
parent(tolia, tima).

% ?- answer([volodya,brat,toli,'?'], R).
% ?- answer([kto,tolin,brat,'?'], R).
% ?- answer([chei,brat,volodya,'?'], R).

answer(L, R) :- 
    query(L, Tree),
    process_tree(Tree, R).

process_tree(accept(person(P1),relation(Rel),person(P2)), yes) :- 
    call(Rel, P1, P2), !.

process_tree(accept(X,Y,Z), no).

process_tree(find(question(Q), relation(Rel), person(P)),R) :-
    call(Rel, P, R).

brat(X,Y) :-
    parent(P,X), parent(P,Y), X \= Y.

query(L, R) :- query(R,L,[]).

query(accept(Person1,Relation,Person2)) -->
    person(Person1, []), relation(Relation), person(Person2, [i]), ['?'].

query(find(Question,Relation,Person)) -->
    question(Question), {Question = question(chei)}, relation(Relation), person(Person, []), ['?'].

query(find(Question,Relation,Person)) -->
    question(Question), {Question = question(chei)}, person(Person, [i,n]), relation(Relation), ['?'].

is_form(Form, Word, Suffix) :- 
    atom_chars(Form, Fc), atom_chars(Word, Wc),
    append(FormPrefix, Suffix, Fc),
    append(WordPrefix, _, Wc),
    FormPrefix = WordPrefix.

question(question(Q)) --> {member(Q, [chei, kto])}, [Q].
relation(relation(R)) --> {member(R, [brat])}, [R].

person(person(X), Suffix) --> [P], {findall(X,parent(X,_), L1), findall(X, parent(_,X), L2), append(L1, L2, LT), sort(LT, L), member(X,L), is_form(P,X,Suffix)}.

