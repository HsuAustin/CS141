my_length([], 0).
my_length([_|T], R) :- my_length(T, R1), R is R1 + 1.

my_member(X, [X|_]).
my_member(X, [_|T]) :- my_member(X, T).

my_append([], L, L).
my_append([H|T], L2, [H|R]) :- my_append(T, L2, R).

my_reverse_helper([], Acc, Acc).
my_reverse_helper([H|T], Acc, R) :- my_reverse_helper(T, [H|Acc], R).
my_reverse(L, R) :- my_reverse_helper(L, [], R).

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

my_add_helper_1(A, B, C, S, Cout) :- Sum is A + B + C, S is Sum mod 10, Cout is Sum // 10.
my_add_helper_2([], [], 0, []).
my_add_helper_2([], [], C, [C]) :- C > 0.
my_add_helper_2([A|TA], [], C, [S|R]) :- my_add_helper_1(A, 0, C, S, C1), my_add_helper_2(TA, [], C1, R).
my_add_helper_2([], [B|TB], C, [S|R]) :- my_add_helper_1(0, B, C, S, C1), my_add_helper_2([], TB, C1, R).
my_add_helper_2([A|TA], [B|TB], C, [S|R]) :- my_add_helper_1(A, B, C, S, C1), my_add_helper_2(TA, TB, C1, R).
my_add(A, B, R) :- my_add_helper_2(A, B, 0, R).

my_merge([], L, L).
my_merge(L, [], L).
my_merge([H1|T1], [H2|T2], [H1|R]) :- H1 =< H2, !, my_merge(T1, [H2|T2], R).
my_merge([H1|T1], [H2|T2], [H2|R]) :- H1 > H2, my_merge([H1|T1], T2, R).

my_sublist_helper(_, []).
my_sublist_helper([H1|T1], [H2|T2]) :- H1 = H2, my_sublist_helper(T1, T2).
my_sublist(S, L) :- my_sublist_helper(L, S).
my_sublist(S, [_|T]) :- my_sublist(S, T).

my_assoc(K, [K,V|_], V) :- !.
my_assoc(K, [_K,_V|T], R) :- my_assoc(K, T, R).

my_replace_helper([K,V|_], K, V) :- !.
my_replace_helper([_|Rest], K, V) :- my_replace_helper(Rest, K, V).
my_replace(_AL, [], []).
my_replace(AL, [H|T], [V|R]) :- my_replace_helper(AL, H, V), !, my_replace(AL, T, R).
my_replace(AL, [H|T], [H|R]) :- my_replace(AL, T, R).
