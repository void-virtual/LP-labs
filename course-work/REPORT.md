## по курсу "Логическое программирование"

### студент: Семенов И.М.

## Результат проверки

| Преподаватель | Дата | Оценка |
|-------------------|--------------|---------------|
| Сошников Д.В. | | |
| Левинская М.А.| | |

> *Комментарии проверяющих (обратите внимание, что более подробные комментарии возможны непосредственно в репозитории по тексту программы)*

## Введение
В результате работы над данным курсовым проектом я улучшу навыки программирования на Пролог. Получше узнаю свою родословную и увижу прелести работы с DCG грамматикой на Пролог.
## Задание

1. Создать родословное дерево своего рода на несколько поколений (3-4) назад в стандартном формате GEDCOM с использованием сервиса MyHeritage.com
2. Преобразовать файл в формате GEDCOM в набор утверждений на языке Prolog, используя следующее представление: ...
3. Реализовать предикат проверки/поиска ....
4. Реализовать программу на языке Prolog, которая позволит определять степень родства двух произвольных индивидуумов в дереве
5. [На оценки хорошо и отлично] Реализовать естественно-языковый интерфейс к системе, позволяющий задавать вопросы относительно степеней родства, и получать осмысленные ответы.

## Получение родословного дерева
Я зарегистрировался на MyHeritage.com. Создал на сайте дерево, содержащее 19 человек и импортировал на персональный компютер.

## Конвертация родословного дерева
Для конвертации я использовал язык Prolog. Получилась достаточно объемная программа, использующая рекурсивные предикаты и занесение в базу данных для извлечения всех зависимостей из файла.

## Предикат поиска родственника
Согласно варианту мне нужно реализовать предикат поиска тещи. Крайне просто реализуется с использованием предикатов, полученных из дерева.

wife(X,Y) :-
    male(X), child(X,C), child(Y,C), female(Y).

%Y - теща X
teshcha(X, Y) :- 
    wife(X, W), mother(W, Y).



## Определение степени родства

По аналогии с 3 лабораторной работой, необходимо реализовать поиск. Для своего дерева я выбрал поиск в глубину(в связи с большим количеством переходов и не очень большой глубиной дерева). Определим переходы и напишем поиск.

prolong([X|T], [Y, X|T], teshcha) :-
    teshcha(X,Y), not(member(Y, [X|T])).

prolong([X|T], [Y, X|T], son) :-
    son(X,Y), not(member(Y, [X|T])).

и так далее со всеми определенными в программе отношениями.

У меня была идея реализовать предикат таким образом, но в таком случае увеличивалось время работы поиска.
prolong([X|T], [T, X|T], P, PredList) :-
    member(P, PredList), call(P,X,Y), not(member(Y, [X|T])). 

Сам поиск.
relative([X|T],Y,Z) :-
    !,
    dfs([Y],Z,_,Attitudes),
    [X|T] = Attitudes.

relative(X,Y,Z) :-
    dfs([Y],Z,_,Attitudes),
    [X] = Attitudes.

dfs([X|T], X, [X|T], []).

dfs(P,F,LOP, LOA) :-
    prolong(P, P1, X), dfs(P1, F, LOP, LOA1), append(LOA1,[X], LOA).



## Естественно-языковый интерфейс

Для анализа текста была использована DCG грамматика, расширенные сети переходов, построение смыслового дерева, извлечение его глубинного смысла. Я хотел обрабатывать как можно больше возможных вопросов, но это привело к усложнению программы.

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

Обрабатываются так же вопросы, содержащие несколько родственных связей одновременно, например поиск матери жены. Вопрос задается с помощью предиката request, принимающего список слов запроса(имена должны быть одним атомом). Программа поддерживает использование контекста(his,her), а также множество возможных вариантов вопроса.

Пример: 
?- request([who,is,the,sister,of,'Josuke Higashikata']).
Holly Joestar is sister of Josuke Higashikata
true 

?- request([who,is,the,mother,of,wife,of,'Sadao Kujo']).
Suzi Joestar is mother of wife of Sadao Kujo
true .


## Выводы
Благодаря реферату, я узнал об особенностях типизации в языках логического программирования, а задания курсового проекта позволили прочувствовать все недостатки, связанные с отсутствием типизации в Прологе. 

Благодаря данной курсовой работе я получил огромное количество навыков по обработке текста, списков, баз данных с использованием языка Пролог. Также я узнал об использованиии языков логического программирования в сфере искусственного интеллекта, написал свой небольшой синтаксический анализатор, осуществляющий разбор и обработку предложения на естественном языке. В 3 пункте был выбран поиск в глубину в связи с большим количеством добавленных переходов. Также я получил некоторое удовольствие от написания лабораторных работ. Я рад, что мне предоставилась возможность изучить новую парадигму программирования
 