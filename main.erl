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
        {get, _, PID} -> PID ! nothing, empty_tree()
    end.

empty() ->
    spawn(?MODULE, empty_tree, []).


