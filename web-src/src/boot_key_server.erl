-module(boot_key_server).

-behaviour(gen_server).
%% API
-export([start_link/0]).
-export([get/1,get/2,set/2]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
 
-record(state, {}).

%% 이전 value값 반환
set(Key,Vaue) ->
    gen_server:call(?SERVER,{ set , {Key,Vaue}}).

get(Key,Default) ->
    gen_server:call(?SERVER,{ get , {Key,Default}}).

get(Key) ->
    gen_server:call(?SERVER,{ get , {Key}}).
%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    ets:new(key_table, [set, named_table, public]),
    {ok, #state{}}.


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call({set,{Key,Vaue}}, _From, State) ->
    ExistValue = case ets:lookup(key_table, Key) of
                    [] -> undefined;
                    [{_,Value}] -> Value
                end,
    ets:insert(key_table, { Key, Vaue } ),
    {reply,ExistValue,State};

handle_call({get,{Key, Default}}, _From, State) ->
    {reply, case ets:lookup(key_table, Key) of
        [] -> Default;
        [{_,Value}] -> Value
    end, State};

handle_call({get,{Key}}, _From, State) ->
    {reply, case ets:lookup(key_table, Key) of
        [] -> undefined;
        [{_,Value}] -> Value
    end, State};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
%%handle_info({reload}, State=#state{ filter_ko = Dicts_ko , filter_en = Dicts_en , filter_zh_hans = Dicts_zh_hans , filter_ja = Dicts_ja  }) ->
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================