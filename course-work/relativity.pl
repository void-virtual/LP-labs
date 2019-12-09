load :- 
    consult(output),
    nb_setval(prev_female, noperson),
    nb_setval(prev_male, noperson).

set_prev_person(X) :- 
    male(X),
    nb_setval(prev_male, X).

set_prev_person(X) :- 
    female(X),
    nb_setval(prev_female, X).

concatenate(List,R) :-
    concatenate_impl("", List, R).

concatenate_impl(S,[],S).
concatenate_impl(S, [H|T], R) :-
    string_concat(S,H,R1),
    concatenate_impl(R1, T, R).

request(L) :- 
    question(Tree,L,[]),
    parse_tree(Tree,Arguments),
    %write(Arguments),
    call_relative(Arguments, R),
    print_result(Arguments,R).

print_result([H|T], R) :-
    H = count,
    [H|T] = [_,P,RelList],
    rel_list_to_string(RelList, S, pl),
    atom_string(P,PS),
    atom_string(R,RS),
    concatenate([PS," has ",RS, " ", S], ToPrint),
    write(ToPrint), nl.

print_result([H|T], R) :-
    H = 3,
    R = P2,
    [H|T] = [_,P1,RelList],
    print_impl(P2, P1, RelList, s).


print_impl(P1, P2, RelList, Pl) :-
    rel_list_to_string(RelList, S, Pl),
    atom_string(P1,P1S),
    atom_string(P2,P2S),
    concatenate([P1S," is ",S, " of ", P2S], ToPrint),
    write(ToPrint), nl.

print_result([H|T], R) :-
    H = 2,
    R = P1,
    [H|T] = [_,P2,RelList],
    print_impl(P2, P1, RelList, s).

print_result([H|T], R) :-
    H = 1,
    R = RelList,
    [H|T] = [_,P1,P2],
    print_impl(P1, P2, RelList, s).

print_result([H|T], R) :-
    H = true_or_false,
    R = true,
    [H|T] = [_,P1,P2,RelList],
    print_impl(P2, P1, RelList, s).

print_result([H|T], R) :-
    H = true_or_false,
    R = false,
    [H|T] = [_,P1,P2,RelList],
    rel_list_to_string(RelList, S, s),
    atom_string(P1,P1S),
    atom_string(P2,P2S),
    concatenate([P2S," is not ",S, " of ", P1S], ToPrint),
    write(ToPrint), nl.

rel_list_to_string(RelList, R, s) :-
    RelList = [H|T],
    atom_string(H,S),
    lts_impl(S,T,R,s).

rel_list_to_string(RelList, R, pl) :-
    RelList = [H|T],
    atom_string(H,ST),
    string_concat(ST,"s",S),
    lts_impl(S,T,R,pl).

lts_impl(S,[],S, _).

lts_impl(S,[H|T],R, pl) :-
    atom_string(H,HT),
    string_concat(HT,"s",HS),
    concatenate([S," of ", HS],R1),
    lts_impl(R1,T, R, s).

lts_impl(S,[H|T],R, s) :-
    atom_string(H,HS),
    concatenate([S," of ", HS],R1),
    lts_impl(R1,T, R, s).


call_relative([H|T], R) :-
    H = count,
    [H|T] = [_, P, RelList],
    findall(X, relative(RelList, P, X), List),
    sort(List, L),
    length(L, R).

call_relative([H|T], true) :-
    H = true_or_false,
    [H|T] = [_, P1, P2, RelList],
    relative(RelList, P1, P2),
    !.

call_relative([H|_], false) :-
    H = true_or_false.

call_relative([H|T], R) :-
    H = 1,
    [H|T] = [_, P1, P2],
    relative(R, P2, P1).

call_relative([H|T], R) :-
    H = 2,
    [H|T] = [_, P, RelList],
    relative(RelList, R, P).

call_relative([H|T], R) :-
    H = 3,
    [H|T] = [_, P, RelList],
    relative(RelList, P, R).

get_person(P,R) :-
    member(P,[his,he]),
    nb_getval(prev_male, R),
    male(R).

get_person(P,R) :-
    member(P,[her,she]),
    nb_getval(prev_female, R),
    female(R).

get_person(P,P) :-
    not(member(P,[her,she,his,he])),
    female(P),
    nb_setval(prev_female,P).

get_person(P,P) :-
    not(member(P,[her,she,his,he])),
    male(P),
    nb_setval(prev_male,P).


%по сути список, генерируемый этим предикатом, является смысловой моделью
parse_tree(Tree, [true_or_false,P2,P1,L]) :-
    Tree = question(general_q(person(P1T),relative(person(P2T),L))),
    get_person(P1T,P1),
    get_person(P2T,P2).

parse_tree(Tree, [3, P, RelList]) :-
    Tree = question(subject_q(q_word([who]), relative(person(PT), RelList))),
    get_person(PT,P).


parse_tree(Tree, [2, P, RelList]) :-
    Tree = question(subject_q(q_word([whose]),relative(person(PT), RelList))),
    get_person(PT,P).

parse_tree(Tree, [count, P, RelList]) :-
    Tree = question(special_q(q_word([how,many]),relative(person(PT), RelList))),
    get_person(PT,P).

parse_tree(Tree, [1, P1, P2]) :-
    Tree = question(special_q(q_word([what]),relative(person(P1T), person(P2T)))),
    get_person(P1T,P1),
    get_person(P2T,P2).


question(question(X)) --> subject_q(X).
question(question(X)) --> general_q(X).
question(question(X)) --> special_q(X).

subject_q(subject_q(W1,W2)) --> q_word(W1, subj), addition(W2,W1,subj).

q_word(q_word([X]), subj) --> [X], {member(X,[who,whose])}.
q_word(q_word([what]), spec) --> [what].
q_word(q_word([how,many]), spec) --> [how, many]. 
q_word(q_word([is]), gen) --> [is].

aux_verb(X) -->  [is], {member(X, [gen, subj])}.
aux_verb(X) -->  [does], {member(X, [spec])}.

addition(W2, q_word([who]), QT) --> aux_verb(QT), article, person(P, posessive), rec_relative(W1,s), {W1 = relative(noperson, List), W2 = relative(P, List)}.
addition(W1, q_word([who]), QT) --> aux_verb(QT), article, rec_relative(W1,s), {W1 \= relative(noperson,_)}.

addition(W2, q_word([whose]), QT) --> rec_relative(W1,s), aux_verb(QT), person(P, common), {W1 = relative(noperson, List), W2 = relative(P, List)}. 


relative_noun(X,s) --> [X], {member(X, [brother,sister,mother,child,teshcha,svekrov,shurin,father,zolovka,wife,husband,son,daughter])}.
relative_noun(R,pl) --> [X], {atom_chars(X,C), append(RT,[s],C), atom_chars(R,RT), relative_noun(R,s,[R],[])}.

rec_relative(relative(P,L), Pl) --> relative_noun(X, Pl), [of], rec_relative(relative(P,L1),Pl), {append([X], L1, L)}.
rec_relative(relative(P,[]), _) --> person(P, common).
rec_relative(relative(noperson,[X]), Pl) --> relative_noun(X,Pl).

verb() --> [X], {member(X, [have,has])}.

person(X) :- male(X); female(X).
person(person(P), common) --> [P], {person(P)}.
person(person(P), common) --> [P], {member(P,[he,she,her,his])}.
person(person(X), posessive) --> [P], {atom_string(P,S), string_concat(S1,"\'s", S), atom_string(X,S1),person(X)}. %'
person(person(P), posessive) --> [P], {member(P,[his,her])}.

special_q(special_q(W1,W2)) --> q_word(W1,spec), {W1 = q_word([how,many])}, rec_relative(WT2,pl), aux_verb(spec), person(X,common), verb, {WT2 = relative(noperson, List), W2 = relative(X, List)}. 
special_q(special_q(W1,W)) --> q_word(W1,spec), {W1 = q_word([what])}, what_after_q, person(X,common), [and], person(Y,common), {W = relative(X,Y)}. 

general_q(general_q(W2,W3)) --> aux_verb(gen), person(W2,common), rec_relative(W3,s).
general_q(general_q(W2,W3)) --> aux_verb(gen), person(W2,common), person(WT,posessive), rec_relative(WT2,s), {WT2 = relative(noperson, List), W3 = relative(WT,List)}.


what_after_q --> synonym(kind), [of], synonym(relation), synonym(between).

synonym(A,B) :- member(X,[[kind,type],[relation,relations, relationship], [among, between]]), member(A,X), member(B,X).
synonym(A) --> [B], {synonym(A,B)}.

article --> [X], {member(X,[a,the])}.
article --> [].

relative([X|T],Y,Z) :-
    !,
    dfs([Y],Z,_,Attitudes),
    [X|T] = Attitudes.

relative(X,Y,Z) :-
    dfs([Y],Z,_,Attitudes),
    [X] = Attitudes.


% Хотел сделать что то вроде 
% prolong([X|T], [T, X|T], P, PredList) :-
%    member(P, PredList), call(P,X,Y), not(member(Y, [X|T])). 
% но работало дольше ¯\_(ツ)_/¯
%
% aux_verb subject_clause verb_clause
% modal_verb subject_clause verb_clause
% question_сlause aux_verb subject_clause object_clause verb_clause

prolong([X|T], [Y, X|T], teshcha) :-
    teshcha(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], son) :-
    son(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], daughter) :-
    daughter(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], mother) :-
    mother(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], father) :-
    father(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], brother) :-
    brother(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], sister) :-
    sister(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], wife) :-
    wife(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], husband) :-
    husband(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], shurin) :-
    shurin(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], zolovka) :-
    zolovka(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], svekrov) :-
    svekrov(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], child) :-
    child(X,Y), not(member(Y, [X|T])).

dfs([X|T], X, [X|T], []).

dfs(P,F,LOP, LOA) :-
    prolong(P, P1, X), dfs(P1, F, LOP, LOA1), append(LOA1,[X], LOA).

%Y - отец X
father(X, Y) :-
    child(Y, X), male(Y).

%Y - мать X
mother(X, Y) :-
    child(Y, X), female(Y).

son(X,Y) :- 
    child(X,Y), male(Y).

daughter(X,Y) :- 
    child(X,Y), female(Y).

brother_or_sister(X,Y) :-
    child(P,X), child(P,Y).

%Y - брат X
brother(X,Y) :-
    brother_or_sister(X, Y), male(Y).

%Y - сестра X
sister(X,Y) :-
    brother_or_sister(X, Y), female(Y).

%Y - жена X
wife(X,Y) :-
    male(X), child(X,C), child(Y,C), female(Y).

husband(X,Y) :-
    female(X), child(X,C), child(Y,C), male(Y).

%Y - теща X
teshcha(X, Y) :- 
    wife(X, W), mother(W, Y).

%Y - шурин X
shurin(X, Y) :- 
    wife(X, W), brother(W, Y).

%Y - деверь X, деверь - брат мужа
dever(X, Y) :- 
    wife(H, X), brother(H, Y).

%Y - сестра мужа X
zolovka(X, Y) :-
    wife(H, X), sister(H, Y).

first_cousin(X, Y) :- 
    child(P, X), brother_or_sister(P, BS), P \= BS, child(BS, Y), male(Y).    

svekrov(X, Y) :-
    wife(H, X), mother(H, Y).

