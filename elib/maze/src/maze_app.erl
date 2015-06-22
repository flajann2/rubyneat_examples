-module(maze_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    io:format("Maze Evaluation |~10w| ~n", [_StartArgs]),
    maze_sup:start_link().

stop(_State) ->
    ok.

-ifdef(TEST).

simple_test() ->
    ok = application:start(maze),
    ?assertNot(undefined == whereis(maze_sup)).

-endif.
