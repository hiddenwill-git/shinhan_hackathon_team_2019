-module(v1_query_promotion).
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

resource_exists(Req, State = #resource{method = <<"GET">>}) ->
    {Query,_Req} = cowboy_req:qs_vals(Req),
    Fields = [<<"seg">>,<<"profile_sex">>,{<<"profile_job">>,int},{<<"profile_age">>,int},
        {<<"profile_married">>,atom},{<<"profile_children">>,int}],

    Contents = 
        lists:foldl(fun
            ({E,int},Acc)->
                Acc ++ [{E,case ?GET(E,Query) of
                    undefined -> undefined;
                    E0 -> 
                        [boot_util:int(X) || X<-re:split(E0,",")]
                end}];
            ({E,atom},Acc)->
                Acc ++ [{E,case ?GET(E,Query) of
                    undefined -> undefined;
                    E0 -> 
                        [boot_util:atom(X) || X<-re:split(E0,",")]
                end}];
            (E,Acc)->
                Acc ++ [{E,case ?GET(E,Query) of
                    undefined -> undefined;
                    E1 -> re:split(E1,",")
                end}]
        end,[],Fields),
        % "prom_2_4_seg": 5,
        % profile_sex=M,F&profile_job=10,7,6,9,4&profile_age=10,20,30&profile_married=true,profile_children=0,1,2,3&seg=2,4
    
    Values = boot_util:get_value(
      [{required,[]},
       {optional,Fields}],Contents),
    boot_misc:resource({required,Values,State,Req}).
%%====================================================================
%% GET and HEAD callbacks
%%====================================================================
to_json(Req, State = #resource{error_code = A}) when A =/= ?STATUS_NORMAL ->
    boot_misc:handle_exception({Req,State});

to_json(Req, State = #resource{contents=Contents}) ->
    % ?INFO("Contents ~p",[Contents]),
    Contents1 = [X||X<-Contents, boot_util:pget(<<"seg">>,[X]) == undefined],
    Bin = boot_util:pget(<<"seg">>,Contents),
    % "prom_2_4_seg": 5,
    Bin1 = boot_util:binary_join(Bin,<<"_">>),
    Bin2 = << <<"prom_">>/binary, Bin1/binary, $_, <<"seg">>/binary >>,

    Rows = handler:query({?MODULE,Contents1}),
    % ?INFO("~p",[length(Rows)]),
    L = [proplists:get_value(Bin2,E)||E<-Rows],
    Res = lists:map(
        fun(Item) -> {Item, length([Key || Key <- L, Key =:= Item])} end,
    lists:usort(L)),
    boot_misc:reply({Res,Req,State}).

to_html(Req, State) ->
    {[], Req, State}.
%%%===================================================================
%%% Internal functions
%%%===================================================================