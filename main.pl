my_length([], 0).
my_length([_|T], R) :- my_length(T, R1), R is R1 + 1.

my_member(X, [X|_]).
my_member(X, [_|T]) :- my_member(X, T).

my_append([], L, L).
my_append([H|T], L2, [H|R]) :- my_append(T, L2, R).

my_reverse(L, R) :- my_rev(L, [], R).

my_rev([], Acc, Acc).
my_rev([H|T], Acc, R) :- my_rev(T, [H|Acc], R).

my_nth(L, 1, L) :- !.
my_nth([], _N, []) :- !.
my_nth([_|T], N, R) :- N > 1, N1 is N - 1, my_nth(T, N1, R).

my_remove(_X, [], []).
my_remove(X, [H|T], R) :- (X == H -> my_remove(X, T, R); R = [H|R1], my_remove(X, T, R1)).

my_subst(_X, _Y, [], []).
my_subst(X, Y, [H|T], [Y|R]) :- H == X, !, my_subst(X, Y, T, R).
my_subst(X, Y, [H|T], [H1|R]) :- (nonvar(H), H = [_|_] -> my_subst(X, Y, H, H1); H1 = H), my_subst(X, Y, T, R).

my_subset(_P, [], []).
my_subset(P, [H|T], [H|R]) :- Goal =.. [P, H], call(Goal), !, my_subset(P, T, R).
my_subset(P, [_|T], R) :- my_subset(P, T, R).

my_add(A, B, R) :- my_add_carry(A, B, 0, R).

my_add_carry([], [], 0, []).
my_add_carry([], [], C, [C]) :- C > 0.
my_add_carry([A|TA], [], C, [S|R]) :- add_digits(A, 0, C, S, C1), my_add_carry(TA, [], C1, R).
my_add_carry([], [B|TB], C, [S|R]) :- add_digits(0, B, C, S, C1), my_add_carry([], TB, C1, R).
my_add_carry([A|TA], [B|TB], C, [S|R]) :- add_digits(A, B, C, S, C1), my_add_carry(TA, TB, C1, R).

add_digits(A, B, C, S, Cout) :- Sum is A + B + C, S is Sum mod 10, Cout is Sum // 10.

my_merge([], L, L).
my_merge(L, [], L).
my_merge([H1|T1], [H2|T2], [H1|R]) :- H1 =< H2, !, my_merge(T1, [H2|T2], R).
my_merge([H1|T1], [H2|T2], [H2|R]) :- H1 > H2, my_merge([H1|T1], T2, R).

my_sublist(S, L) :- my_append(_, Rest, L), my_append(S, _, Rest).

my_assoc(K, [K,V|_], V) :- !.
my_assoc(K, [_K,_V|T], R) :- my_assoc(K, T, R).

my_replace(_AL, [], []).
my_replace(AL, [H|T], [V|R]) :- key_value(AL, H, V), !, my_replace(AL, T, R).
my_replace(AL, [H|T], [H|R]) :- my_replace(AL, T, R).

key_value([K,V|_], K, V) :- !.
key_value([_|Rest], K, V) :- key_value(Rest, K, V).
