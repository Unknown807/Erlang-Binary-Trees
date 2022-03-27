-module(main).
-compile(export_all).
-compile(nowarn_export_all).

empty_tree() ->
    receive
        {is_empty, PID} -> PID ! true, empty_tree();
        {get, _, PID} -> PID ! nothing, empty_tree();
        {put, K, V, PID} -> PID ! done, binary_tree(K, V, empty(), empty());
        {fold, FE, _, PID} -> PID ! {folded, FE, self()}, empty_tree()
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

empty() -> spawn(?MODULE, empty_tree, []).

get(T, K) ->
    T ! {get, K, self()},
    receive RESP -> RESP end.

put(T, K, V) ->
    T ! {put, K, V, self()},
    receive RESP -> RESP end.

is_empty(T) ->
    T ! {is_empty, self()},
    receive RESP -> RESP end.

fold(T, FE, FB) ->
    T ! {fold, FE, FB, self()},
    receive {folded, RES, _} -> RES end.

%% Testing

%% X=main:empty(), main:put(X,d,5), main:put(X,b,17), main:put(X,h,19), main:put(X,c,12).
%% main:fold(X,0,fun(L,_,V,R)->L+V+R end).