-module(boot_cowboy_middleware).

-behaviour(cowboy_middleware).

-include("common.hrl").

-export([execute/2]).

execute(Req, Env) ->
    {ok, ReqWithCorsHeaders} = set_cors_headers(Req),
    {Method, ReqMethod} = cowboy_req:method(ReqWithCorsHeaders),
    {Headers,_} = cowboy_req:headers(Req),
    Referer = boot_util:pget(<<"referer">>,Headers),
    case Referer == undefined of
    	true -> next;
    	_ -> 
    		case re:run(Referer,["127.0.0.1"]) of
    			nomatch -> nothing;
    			_ -> next
    		end
    end,

    case Method of
	<<"OPTIONS">> ->
	    {ok, ReqFinal} = cowboy_req:reply(200, ReqMethod),
	    {halt, ReqFinal};
	_ ->
		{{Peer, _}, Req2} = cowboy_req:peer(Req),
	    {Method, Req3} = cowboy_req:method(Req2),
	    {Path, _Req4} = cowboy_req:path(Req3),
	    
	    case re:run(Path,["/css|/img|/js|.js|.ico"]) of
	    	nomatch ->  nothing;
	    		% ?INFO("######### ~p, ~p, ~p",[Peer,Method,Path]);
	    	_ ->
	    		next
	    end,
		{ok, ReqMethod, Env}
    end.

%% ===================================================================
%% Helpers
%% ===================================================================

set_headers(Headers, Req) ->
    ReqWithHeaders = lists:foldl(fun({Header, Value}, ReqIn) ->
					 ReqWithHeader = cowboy_req:set_resp_header(Header, Value, ReqIn),
					 ReqWithHeader
				 end, Req, Headers),
    {ok, ReqWithHeaders}.


set_cors_headers(Req) ->
    Headers = [{<<"access-control-allow-origin">>, <<"*">>},
	       {<<"access-control-allow-methods">>, <<"PUT,DELETE,POST,GET,OPTIONS">>},
	       {<<"access-control-allow-headers">>, <<"Origin,x-access-token, X-Requested-With, Content-Type, Accept">>},
	       {<<"access-control-max-age">>, <<"2000">>}],
    {ok, Req2} = set_headers(Headers, Req),
    {ok, Req2}.