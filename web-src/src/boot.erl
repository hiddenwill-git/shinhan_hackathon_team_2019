-module(boot).

-behaviour(application).

-export([start/0,start/2, start_link/0, stop/0,stop/1]).


%% ===================================================================
%% Application callbacks
%% ===================================================================
%% @spec start_link() -> {ok,Pid::pid()}
start_link() ->
    boot_sup:start_link().

start() ->
    application:ensure_all_started(boot).

start(_StartType, _StartArgs) ->
	boot_sup:start_link().

stop(_State) ->
    application:stop(boot).

stop() ->
   application:stop(boot).