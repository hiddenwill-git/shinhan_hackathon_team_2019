-module(boot_cowboy).

-behaviour(gen_server).

-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-export([crate/0]).

-export([update_dispatch/0,
         update/0,
         error_response/4]).

-define(SERVER, ?MODULE).

-record(state, {craterl_ref}).

-include("common.hrl").

%%%===================================================================
%%% API
%%%===================================================================


%%--------------------------------------------------------------------
%% @doc Starts the server.
%%
%% @spec start_link(Port::integer()) -> {ok, Pid}
%% where
%%  Pid = pid()
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
crate() ->
    gen_server:call(?SERVER,crate).

init([]) ->
    Ref = read_json(),
    start_cowboy(Ref),

    %start_ssdb(),
    process_flag(trap_exit, true),
    {ok, #state{craterl_ref = Ref}}.

handle_call(crate, _From, State = #state{craterl_ref = CraterlClient}) ->
    {reply,CraterlClient,State};

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{craterl_ref = CraterlClient}) ->
    craterl:stop_client(CraterlClient),
    cowboy:stop_listener(http),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dispatch(HandlerOpts) ->
  [   
      {"/api/v1/echo",v1_echo, HandlerOpts },
      %% front end
      %% 사용자 아이디별 데이터 조회
      {"/api/v1/resource/:user_id",v1_user_resource, HandlerOpts },
      {"/api/v1/query/target",v1_query_target, HandlerOpts },
      {"/api/v1/query/promotion",v1_query_promotion, HandlerOpts },
      {"/api/v1/query/promotion_user_status",v1_query_promotion_user_status, HandlerOpts }
  ].
%%%===================================================================
%%% Internal functions
%%%===================================================================
read_json() ->
    Path = "priv/data/",
   {ok,Files} = file:list_dir(Path),

  lists:foldl(fun(File,_Acc)->
      ?INFO("... Fetch File > ~p",[Path++File]),
      {ok,Data} = file:read_file(Path++File),
      boot_key_server:set(File,jsx:decode(Data))
      % Acc ++ [jsx:decode(Data)]
  end,[],Files),
  ok.

update() ->
   update_dispatch().

update_dispatch() ->
    ?INFO("UPDATE DISPATCH!!!!",[]),
    Ref = ref,
    Port = boot_util:env(port),
    Dispatch = dispatch([{craterl, Ref}]),
    VHosts = boot_util:env(vhosts),
    VHosts1 = VHosts ++ [ [{name,http},{domain,'_'},{port,Port},{static,"priv/www/vhost/hackathon"}] ],
    T = 
    lists:foldl(fun([{name,Name},{domain,Domain},{port,_Port},{static,Static}],Acc)->
        StaticFile = [{"/", cowboy_static, {file, Static ++ "/index.html"}},
                    {"/[...]", cowboy_static, { dir, Static , 
                                [{mimetypes, cow_mimetypes, all}]}} ],
        ?INFO("Start Cowboy Web Server Name > ~p Domain > ~p, Static > ~p, Port > ~p",[Name,Domain,Static,_Port]),
        Route = Dispatch ++ StaticFile,
        Acc ++   [{Domain,Route}]
    end,[],VHosts1),
    cowboy:set_env(http, dispatch, cowboy_router:compile(T)).

vhost_cowboy(HandlerOpts) ->
    Port = boot_util:env(port),
    NumAcceptors = boot_util:env(num_acceptors),
    Dispatch = dispatch(HandlerOpts),
    VHosts = boot_util:env(vhosts),

    VHosts1 = VHosts ++ [ [{name,http},{domain,'_'},{port,Port},{static,"priv/www/vhost/hackathon"}] ],
    % io:format("======VHosts1 ~p~n",[VHosts1]),
    T = 
    lists:foldl(fun([{name,Name},{domain,Domain},{port,_Port},{static,Static}],Acc)->
        StaticFile = [{"/", cowboy_static, {file, Static ++ "/index.html"}},
                    {"/[...]", cowboy_static, { dir, Static , 
                                [{mimetypes, cow_mimetypes, all}]}} ],

        ?INFO("Start Cowboy Web Server Name > ~p Domain > ~p, Static > ~p, Port > ~p",[Name,Domain,Static,_Port]),
        Route = Dispatch ++ StaticFile,
        Acc ++   [{Domain,Route}]  
    end,[],VHosts1),
    
    T1 = cowboy_router:compile(T),
    Options = [{env,[{dispatch,T1}]},
            {onresponse, fun ?MODULE:error_response/4},
            {max_keepalive,70},
            {middlewares,[cowboy_router,boot_cowboy_middleware,cowboy_handler]}],
    cowboy:start_http(http, NumAcceptors,[{port, Port}],Options).

start_cowboy(Ref) ->
    _VHosts = vhost_cowboy([{craterl, Ref}]).
  
error_response(Status, _Headers, <<>>, Req) when Status == 404 ->
      % boot_metrics:inc({status,Status}),
      % boot_metrics:sent(<<>>),
      Req;

error_response(Status, Headers, <<>>, Req) when Status >= 400 ->
  {_Headers1,_} = cowboy_req:headers(Req),

  Message = if
    Status < 500 -> <<"invalid request">>;
    true -> <<"something went wrong">>
  end,

  {TimeStamp,DateTime} = boot_util:timestamp_f(),
  Response = [
              { <<"result_dt">>, DateTime },
              { <<"result_ts">>, TimeStamp },
              { <<"result_code">> , Status },
              { <<"result_msg">> ,  Status },
              { <<"result_data">> , Message }
  ],
  Body = jsx:encode(Response),
  
  Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
    {<<"content-length">>, integer_to_list(byte_size(Body))}),
  {ok, Req2} = cowboy_req:reply(Status, Headers2, Body, Req),
  Req2;

error_response(_Status, _Headers, _Body, Req) ->
  Req.