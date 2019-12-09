:-dynamic id/2.
:-dynamic child/2.
:-dynamic wife/2.
:-dynamic husband/2.

main :- 
	open("joestars2.ged", read, Input),
	open("output.pl", write, Out),
    write(Out, ":- discontiguous male/1.\n"),
    write(Out, ":- discontiguous female/1.\n"),
	process_file(Input, Out),
    /*listing(id),
    listing(husband),
    listing(wife),
    listing(child),*/
	close(Out).

process_file(Input, Out) :- 
	at_end_of_stream(Input), !.
	
process_file(Input, Out) :- 
	read_string(Input, "\n", "\r", End, String),
	split_string(String, " ", "", Splitted),
	process_line(Input, Splitted, Out),
	process_file(Input, Out).

process_line(Input, [H,Y,Z|_], Out) :-
    H = "0",
    Z = "FAM",
    FamilyId = Y,
    read_string(Input, "\n", "\r", _, _), /*считываем ненужную нам дату*/
    read_string(Input, "\n", "\r", _, String),
    split_string(String, " ", "", List),
    process_family(Input, List, FamilyId),  
    findall(X, child(FamilyId, X), Childs),
    findall(X,write_family(FamilyId, Childs, Out, X),_).
    

write_family(FamilyId, [], Out, X) :- !.

write_family(FamilyId, [X|Y], Out, print_father) :- 
    husband(FamilyId, Husband),
    HusbandList = ["child(\'", Husband,"\',\'", X, "\').\n"],
	concatenate(HusbandList, Result),
	write(Out, Result),
    write_family(FamilyId, Y, Out, print_father).

write_family(FamilyId, [X|Y], Out, print_mother) :- 
    wife(FamilyId, Wife),
    WifeList = ["child(\'", Wife,"\',\'", X, "\').\n"],
	concatenate(WifeList, Result),
	write(Out, Result),
    write_family(FamilyId, Y, Out, print_mother).

process_line(Input, [H,Y,Z|_], Out) :- 
    H = "0",
    Z = "INDI",
    read_string(Input, "\n", "\r", _, String),
    split_string(String, " ", "", List),
    find_str(Input, ["GIVN"], Name),
	find_str(Input, ["SURN", "_MARNM"], Surname),
	find_str(Input, ["SEX"], Sex),
	StringList = [Name, " ", Surname],
	concatenate(StringList, FullName),
	write_person(Out, FullName, Sex),
	assertz(id(Y, FullName)).

process_line(Input, X, Out) :- !.

write_person(Out, Name, Sex) :-
	Sex = "M",
	WriteList = ["male(\'", Name, "\').\n"],
	concatenate(WriteList, Result),
	write(Out, Result), !.

write_person(Out, Name, Sex) :-
	Sex = "F",
	WriteList = ["female(\'", Name, "\').\n"],
	concatenate(WriteList, Result),
	write(Out, Result), !.


find_str(Input, What, Result) :- 
	read_string(Input, "\n", "\r", End, String),
	split_string(String, " ", "", Splitted),
	Splitted = [_,StringContainment|_],
    member(StringContainment, What) ->
	Splitted = [_,_,StringData|_],
	Result = StringData, !;
	find_str(Input, What, Result1),
	Result = Result1.

process_family(Input, [X,Y,T|_], FamilyId) :- 
    Y = "HUSB",
    id(T, Name),
    assertz(husband(FamilyId,Name)),
    read_string(Input, "\n", "\r", _, String),
    split_string(String, " ", "", List),
    process_family(Input, List, FamilyId), !.    

process_family(Input, [X,Y,T|_], FamilyId) :- 
    Y = "WIFE",
    id(T, Name),
    assertz(wife(FamilyId,Name)),
    read_string(Input, "\n", "\r", _, String),
    split_string(String, " ", "", List),
    process_family(Input, List, FamilyId), !.
    
process_family(Input, [X,Y,T|_], FamilyId) :- 
    Y = "CHIL",
    id(T, Name),
    assertz(child(FamilyId, Name)),
    read_string(Input, "\n", "\r", _, String),
    split_string(String, " ", "", List),
    process_family(Input, List, FamilyId), !.
    
process_family(Input, [X,Y,T|_], FamilyId) :- !.
    
concatenate(StringList, StringResult) :-
    maplist(atom_chars, StringList, Lists),
    append(Lists, List),
    string_chars(StringResult, List).