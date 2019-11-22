-module(v1_tag_baskets).
-export([init/3, rest_init/2, rest_terminate/2, known_methods/2,
         service_available/2, allowed_methods/2, is_authorized/2,
         forbidden/2, content_types_provided/2, content_types_accepted/2,
         resource_exists/2]).
-export([to_json/2, to_html/2]).

-include("common.hrl").
%%====================================================================
%% General Callbacks
%%====================================================================
init(_Transport, _Req, _) ->
    {upgrade, protocol, cowboy_rest}.

rest_init(Req, Opts) ->
    {ok, Req, #resource{opts=Opts}}.

rest_terminate(_, _) ->
    ok.

service_available(Req, Opts) ->
    {not application:get_env(app, lockdown, false), Req, Opts}.

known_methods(Req, State) ->
    {[<<"GET">>], Req, State}.

allowed_methods(Req, State) ->
    {[<<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    {[
      {{<<"application">>, <<"json">>, '*'}, to_json},
      {{<<"text">>, <<"html">>, '*'}, to_html}
     ],Req, State}.

content_types_accepted(Req, State) ->
    {[
      {{<<"application">>, <<"json">>, '*' }, handle_post}
     ],
     Req, State}.

is_authorized(Req, State) ->
    boot_misc:no_auth(State,Req).

forbidden(Req, State) ->
    {false, Req, State}.

resource_exists(Req, State)  ->
    {true, Req, State}.

%%====================================================================
%% GET and HEAD callbacks
%%====================================================================
to_json(Req, State = #resource{error_code = A}) when A =/= ?STATUS_NORMAL ->
    boot_misc:handle_exception({Req,State});

to_json(Req, State) ->
    Res = handler:task(?MODULE),
    boot_misc:reply({Res,Req,State}).

to_html(Req, State) ->
    {[], Req, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================