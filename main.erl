-module(main).
-compile(export_all).
-compile(nowarn_export_all).

%% implement binary trees
%% every node is a process, even empty trees

%% two kinds of tree processes:
%% empty trees and binary tree nodes

% FOR REFERENCE ----
%
% compGH(F, G) ->
%     receive
%         PID -> PID ! fun(I) -> F(G(I)) end, compGH(F, G)
%     end.

% compG(F, G) ->
%     PID = spawn(?MODULE, compGH, [F, G]),
%     fun(I) -> PID ! self(), receive FG -> FG(I) end end.

empty_tree() ->
    receive
        {is_empty, PID} -> PID ! true, empty_tree();
        {get, _, PID} -> PID ! nothing, empty_tree();
        {put, K, V, PID} -> PID ! done, binary_tree(K, V, empty(), empty());
        {fold, FE, _, PID} ->
            PID ! {folded, FE, self()},
            empty_tree()
    end.

binary_tree(KK, VV, L, R) ->
    Repeat = fun() -> binary_tree(KK, VV, L, R) end, %% don't want to rewrite
    receive

        {is_empty, PID} -> PID ! false, Repeat();

        {get, K, PID} ->
            if
                K < KK -> L ! {get, K, PID}, Repeat(); %% search left
                K > KK -> R ! {get, K, PID}, Repeat(); %% search right
                true -> PID ! {just, VV}, Repeat() %% found K
            end;

        {put, K, V, PID} ->
            PID ! done,
            if
                K < KK -> L ! {put, K, V, PID}, Repeat(); %% go left
                K > KK -> R ! {put, K, V, PID}, Repeat(); %% go right
                true -> binary_tree(K, V, L, R) %% replace node K/V
            end;

        {fold, FE, FB, PID} ->
            L ! {fold, FE, FB, self()},
            LV = receive {folded, RES, _} -> RES end,

            R ! {fold, FE, FB, self()},
            RV = receive {folded, RES2, _} -> RES2 end,
            
            PID ! {folded, FB(LV, KK, VV, RV), self()},

            binary_tree(KK, VV, L, R)
    end.

empty() ->
    spawn(?MODULE, empty_tree, []).

%% Test functions

flush() ->
    receive
            X -> erlang:display(X)
    end.

testTree(X) ->
    X ! {put, d, 5, self()},
    flush(),
    X ! {put, b, 17, self()},
    flush(),
    X ! {put, h, 19, self()},
    flush(),
    X ! {put, c, 12, self()},
    flush().

checkempty(PID) ->
    PID ! {is_empty, self()},
    receive
        X -> X
    end.

% test2(PID) ->
%     PID ! {put, a, 12, self()},
%     receive
%         X -> X
%     end.

% test3(PID) ->
%     PID ! {get, a, self()},
%     receive
%         X -> X
%     end.

getb(PID) ->
    PID ! {get, b, self()},
    receive
        X -> X
    end.

foldtest(PID) ->
    FB = fun(L1, _,V,L2) -> L1 + L2 + V end,
    PID ! {fold, 0, FB, self()},
    receive
        X -> X
    end.

%% For testing
%%
%% X = main:empty().
%% X ! {is_empty, self()}, receive L->L end.
%% X ! {put, a, 120, self()}, receive L->L end.
%% X ! {get, a, self()}, receive L->L end.
%% X ! {get, b, self()}, receive L->L end.
%%
%% spawn(main, binary_tree, [a, 12, main:empty(), main:empty()]).     
%% <0.76.0> ! {get, a, self()}, receive L->L end.
%%
%% X = main:empty().
%% X ! {put, b, 21, self()}, receive L->L end.