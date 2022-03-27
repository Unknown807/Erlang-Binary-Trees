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
        {put, K, V, PID} -> PID ! done, spawn(?MODULE, binary_tree, [K, V, empty(), empty()])
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
            end

    end.

empty() ->
    spawn(?MODULE, empty_tree, []).


