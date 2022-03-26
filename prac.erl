-module(prac).
-compile(export_all).

hello() ->
    io:format("Hello World").

add(A, B) ->
    A + B.

greet_and_add_two(X) ->
    hello(),
    add(X,2).


%% head function
head([H|_]) -> H.
tail([_|XS]) -> XS.
second([_,X|_]) -> X.



greet(male, Name) ->
    io:format("Hello Mr "),
    io:format([Name]);
greet(female, Name) ->
    io:format("Hello Mrs "),
    io:format([Name]);
greet(_, Name) ->
    io:format("Hello Rando "),
    io:format([Name]).


%% Guards

old_enough(X) when X >= 16, X =< 104 -> true;
old_enough(_) -> false.

%% IFs

help_me(Animal) -> 
    Talk = if Animal == cat -> "meow";
              Animal == beef -> "mooo";
              Animal == dog -> "bark";
              Animal == tree -> "bark";
              true -> "arrgh"
           end,
    {Animal, "says " ++ Talk ++ "!"}.

%% In Case ... of

insert(X,[]) ->
    [X];
insert(X,Set) ->
    case lists:member(X,Set) of 
        true -> Set;
        false -> [X|Set]
    end.

beach(Temperature) ->
case Temperature of
    {celsius, N} when N >= 20, N =< 45 ->
        'favorable';
    {kelvin, N} when N >= 293, N =< 318 ->
        'scientifically favorable';
    {fahrenheit, N} when N >= 68, N =< 113 ->
    '   favorable in the US';
    _ ->
        'avoid beach'
end.

fac(0) -> 1;
fac(X) when X > 0 -> X * fac(X-1).

% lengths([]) -> 0;
% lengths([_|XS]) -> 1 + lengths(XS).

tail_fac(N) -> tail_fac(N,1).
tail_fac(0, Acc) -> Acc;
tail_fac(N, Acc) when N > 0 -> tail_fac(N-1, N*Acc).

duplicate(0, _) -> [];
duplicate(N, Term) when N > 0 ->
    [Term | duplicate(N-1, Term)].



%% receving and sending processes

ping(0, Pong_PID) ->
    Pong_PID ! finished,
    io:format("ping finished~n", []);

ping(N, Pong_PID) ->
    Pong_PID ! {ping, self()},
    receive
        pong ->
            io:format("Ping received pong~n", [])
    end,
    ping(N - 1, Pong_PID).

pong() ->
    receive
        finished ->
            io:format("Pong finished~n", []);
        {ping, Ping_PID} ->
            io:format("Pong received ping~n", []),
            Ping_PID ! pong,
            pong()
    end.

start() ->
    Pong_PID = spawn(prac, pong, []),
    spawn(prac, ping, [3, Pong_PID]).

%% mock test

%% 1

funm(_, Y, _) -> Y.


%% 2

divm(_, []) -> [];
divm(K, [H|T]) when (H rem K =/= 0) -> divm(K, T);
divm(K, [H|T]) when (H rem K == 0) ->
    [trunc(H/K) | divm(K, T)]. 

%% 3

mapm({A,B,C}, G) ->
    if B == goleft -> G(A);
       B == goright -> G(C)
    end.

%% 4

% lastm([H|[]]) -> 
%     spawn(prac, lastm)
% lastm([H|T]) ->
%     receive
%         L -> L
%     end,

lastm([H]) -> 
    self() ! H,
    [];

lastm([H|T]) ->
    [H|lastm(T)].

%% X=prac:lastm([1,2,3]), receive L->L end.
%% will store [1,2] in X, but will return 3 in erl terminal

%% Higher order functions

one() -> 1.
two() -> 2.

addF(X, Y) -> X() + Y().

%%R = prac:addF(fun prac:one/0, fun prac:two/0).

higherorder() ->
    prac:addF(fun prac:one/0, fun prac:two/0).

%% map 

map(_, []) -> [];
map(F, [H|T]) -> [F(H)|map(F,T)].

incr(X) -> X+1.
decr(X) -> X-1.

%% anonymous functions

anonfunc(Room) ->
    io:format("Alarm set in ~n~s", [Room]),
    fun() -> 
        io:format("Alarm tripped ~s~n", [Room])
    end.

%% class 7

take(0, _) -> [];
take(_, []) -> [];
take(N, [H|T]) when N > 0 ->
    [H | take(N-1, T)].

applyAll(_, []) -> [];
applyAll(F, [H|T]) ->
    [{H, F(H)} | applyAll(F, T)].

applySend(_, []) -> [];
applySend(F, [H|T]) ->
    self() ! [{H, F(H)} | applySend(F, T)].

% applySend(_,[]) -> ok;
% applySend(F,[H|T])-> self()! {H,F(H)}, applySend(F,T).

%% rvar

% compGH(F, G) ->
%     receive
%         PID -> PID ! fun(I) -> F(G(I)) end, compGH(F, G)
%     end.

% compG(F, G) ->
%     PID = spawn(?MODULE, compGH, [F, G]),
%     fun(I) -> PID ! self(), receive FG -> FG(I) end end.

compG(F, G) ->
    fun(I) -> F(G(I)) end.

% get_val(I) ->
%     PID ! self(),
%     receive
%         Func -> Func(I)
%     end.

%% func func

% compG(F, G) ->
%     F(G()).

% compG(F, G) ->
%     MyFunc = fun(I) -> F(G(I)) end,
%     MyFunc.

% compGH() ->
%     receive
%         {F, G}


% compG(F, G) ->
%     PID = spawn(?MODULE, compGH, [{F, G}]),
%     fun(P) -> PID ! {F, G, P} end.

% compG(F, G) ->
%     receive
%         {X, Y} -> self() ! {X, Y};
%         I -> F(G(I))
%     end,
%     fun(P) -> self() ! P end.