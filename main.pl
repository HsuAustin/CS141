eval(N, N) :-
    integer(N), !.

eval(A + B, V) :-
    !,
    eval(A, VA),
    eval(B, VB),
    V is VA + VB.

eval(A - B, V) :-
    !,
    eval(A, VA),
    eval(B, VB),
    V is VA - VB.

eval(A * B, V) :-
    !,
    eval(A, VA),
    eval(B, VB),
    V is VA * VB.

eval(A / B, V) :-
    !,
    eval(A, VA),
    eval(B, VB),
    V is VA // VB.

eval(A ^ B, V) :-
    !,
    eval(A, VA),
    eval(B, VB),
    V is VA ** VB.

append_list([], L, L).

append_list([H|T], L2, [H|R]) :-
    append_list(T, L2, R).

flatten_mul(E, Fs) :-
    (E = A * B ->
        flatten_mul(A, FA),
        flatten_mul(B, FB),
        append_list(FA, FB, Fs);
        Fs = [E]
    ).

build_mul([], 1).

build_mul([X], X).

build_mul([X|Xs], X*Rest) :-
    build_mul(Xs, Rest).

select_elem(X, [X|Xs], Xs).

select_elem(X, [Y|Ys], [Y|Zs]) :-
    select_elem(X, Ys, Zs).

simplify_minus(A, B, S) :-
    (integer(A), integer(B) ->
        N is A - B, S = N, !;
        B = 0 -> S = A, !;
        A = 0 -> S = -B, !;
        A == B -> S = 0, !;
        B = -C -> S = A + C, !;
        S = A - B
    ).

simplify_plus(A, B, S) :-
    (integer(A), integer(B) ->
        N is A + B, S = N;
        A = 0 -> S = B;
        B = 0 -> S = A;
        B = -C -> simplify_minus(A, C, S);
        S = A + B
    ).

simplify_times(A, B, S) :-
    (integer(A), integer(B) ->
        N is A * B, S = N, !;
        A = 0 -> S = 0, !;
        B = 0 -> S = 0, !;
        A = 1 -> S = B, !;
        B = 1 -> S = A, !;
        integer(A), B = C * E, integer(C) ->
            N is A * C,
            S = N * E, !;
        integer(B), A = C * E, integer(C) ->
            N is B * C,
            S = N * E, !;
            S = A * B
    ).

simplify_div(A, x, S) :-
    flatten_mul(A, Fs),
    select_elem(x, Fs, FsNoX),
    !,
    build_mul(FsNoX, P),
    simplify(P, S).

simplify_div(A, B, S) :-
    (integer(A), integer(B), B =\= 0 ->
        N is A // B, S = N, !;
        A = 0 -> S = 0, !;
        B = 1 -> S = A, !;
        A == B -> S = 1, !;
        S = A / B
    ).

simplify_pow(_A, 0, 1) :- !.

simplify_pow(A, 1, S) :-
    !, S = A.

simplify_pow(A, B, S) :-
    (integer(A), integer(B) ->
        N is A ** B,
        S = N, !;
        S = A ^ B
    ).

simplify(E, E) :-
    integer(E), !.

simplify(E, E) :-
    atom(E), !.

simplify(-E, S) :-
    !,
    simplify(E, SE),
    (integer(SE) ->
        N is -SE,
        S = N;
        S = -SE
    ).

simplify(A + B, S) :-
    !,
    simplify(A, SA),
    simplify(B, SB),
    simplify_plus(SA, SB, S).

simplify(A - B, S) :-
    !,
    simplify(A, SA),
    simplify(B, SB),
    simplify_minus(SA, SB, S).

simplify(A * B, S) :-
    !,
    simplify(A, SA),
    simplify(B, SB),
    simplify_times(SA, SB, S).

simplify(A / B, S) :-
    !,
    simplify(A, SA),
    simplify(B, SB),
    simplify_div(SA, SB, S).

simplify(A ^ B, S) :-
    !,
    simplify(A, SA),
    simplify(B, SB),
    simplify_pow(SA, SB, S).

simplify(E, E).

d(N, 0) :-
    integer(N), !.

d(x, 1) :- !.

d(V, 0) :-
    atom(V),
    V \= x, !.

d(-E, -DE) :-
    !,
    d(E, DE).

d(A + B, DA + DB) :-
    !,
    d(A, DA),
    d(B, DB).

d(A - B, DA - DB) :-
    !,
    d(A, DA),
    d(B, DB).

d(C * E, C * DE) :-
    integer(C),
    !,
    d(E, DE).

d(E * C, DE * C) :-
    integer(C),
    !,
    d(E, DE).

d(x ^ N, N * x ^ N1) :-
    integer(N),
    N > 0,
    N1 is N - 1,
    !.

d(C / x, -(C / (x ^ 2))) :-
    integer(C),
    !.

d(C / (x ^ N), -(C * N / (x ^ N1))) :-
    integer(C),
    integer(N),
    N > 0,
    N1 is N + 1,
    !.

d(A * B, DA * B + A * DB) :-
    !,
    d(A, DA),
    d(B, DB).

d(A / B, (DA * B - A * DB) / (B ^ 2)) :-
    !,
    d(A, DA),
    d(B, DB).

deriv(E, D) :-
    simplify(E, SE),
    d(SE, D0),
    simplify(D0, D).

guests(Guests) :-
    setof(M, male(M), Ms),
    setof(F, female(F), Fs),
    append(Ms, Fs, All),
    sort(All, Guests).

no_adjacent_females_linear([_]).

no_adjacent_females_linear([A, B | Rest]) :-
    \+ (female(A), female(B)),
    no_adjacent_females_linear([B | Rest]).

adjacent_language_linear([_]).

adjacent_language_linear([A, B | Rest]) :-
    common_language(A, B),
    adjacent_language_linear([B | Rest]).

common_language(A, B) :-
    speaks(A, Lang),
    speaks(B, Lang),
    !.

last_elem([X], X).

last_elem([_ | Rest], Last) :-
    last_elem(Rest, Last).

no_adjacent_females([First|Rest]) :-
    no_adjacent_females_linear([First|Rest]),
    last_elem([First|Rest], Last),
    \+ (female(Last), female(First)).

adjacent_language_ok([First|Rest]) :-
    adjacent_language_linear([First|Rest]),
    last_elem([First|Rest], Last),
    common_language(Last, First).

valid_seating(L) :-
    no_adjacent_females(L),
    adjacent_language_ok(L).

perm([], []).

perm(L, [X|Xs]) :-
    select_elem(X, L, R),
    perm(R, Xs).

party_seating(L) :-
    guests(Guests),
    Guests = [First|Others],
    perm(Others, Tail),
    L = [First|Tail],
    valid_seating(L),
    !.
