-module(boot_misc).

-export([]).

-compile(export_all).
-include("common.hrl").

resource({binding,Key,State,Req}) ->
    case cowboy_req:binding(Key, Req) of
        {undefined, _} ->
            {true, Req, State#resource{error_code=?OBJECT_NOT_FOUND}};
        {Value, _} ->
            {true, Req, State#resource{contents = Value}}
    end;

resource({required,Values,State,Req}) ->
    {ErrorCode,ErrorMessage} =
        case Values of
            {error, Reason} ->
                ?ERROR("~p ~p ~p",[?MODULE,?LINE,Values]),
                {?REQUIRED_ERROR,Reason};
            _ ->
                {?STATUS_NORMAL,ok}
        end,

    { true, Req, State#resource{
                        contents=Values,
                        error_code=ErrorCode,
                        error_message=ErrorMessage} };

resource({Values,State,Req}) ->
    { true, Req, State#resource{
                        contents=Values,
                        error_code=?STATUS_NORMAL,
                        error_message=ok} }.
no_auth(State,Req) ->
    {Method,Req1} = cowboy_req:method(Req),
    { true, Req1, State#resource{method=Method} }.
                        

%% 같은 method인경우 인증 체크
maybe_auth(State,Req,Methods) ->
    {Method1,_} = cowboy_req:method(Req),
    case lists:member(Method1,Methods) of
        true -> auth(State,Req);
        _ ->    no_auth(State,Req)
    end.

auth(State,Req) ->
    {Method,Req1} = cowboy_req:method(Req),
    { true, Req1, State#resource{method=Method} }.

gen_res_error(#resource{error_code=A,error_message=B}) ->
    {TimeStamp,DateTime} = boot_util:timestamp_f(),
    Response = [
                { <<"result_dt">>, DateTime },
                { <<"result_ts">>, TimeStamp },
                { <<"result_code">> , A },
                { <<"result_msg">> ,  code(A) },
                { <<"result_data">> , [{statck_id,boot_util:uuid()},B] }
    ],
    jsx:encode(Response).

reply({{error,Contents,ResultCode},Req,State}) ->
    reply({Contents,Req,State,ResultCode});
reply({{error,ResultCode},Req,State}) ->
    reply({null,Req,State,ResultCode});
reply({{ok,Contents},Req,State}) ->
    reply({Contents,Req,State,?STATUS_NORMAL});
reply({Contents,Req,State}) ->
    reply({Contents,Req,State,?STATUS_NORMAL});
reply({Contents,Req,State,Resultcode}) ->
    {TimeStamp,DateTime} = boot_util:timestamp_f(),
    Response = [
                { <<"result_dt">>, DateTime },
                { <<"result_ts">>, TimeStamp },
                { <<"result_code">> , Resultcode },
                { <<"result_msg">>  , code(Resultcode) },
                { <<"result_data">> , Contents }
           ],
    Ret = jsx:encode(Response),
    Req1 = cowboy_req:set_resp_body(Ret,Req),

    { case cowboy_req:method(Req) of
        {<<"GET">>,_} -> Ret;
        _   -> true
    end, Req1, State }.

reply2({Contents,Req,State}) ->
    {TimeStamp,DateTime} = boot_util:timestamp_f(),
    Response = [
                { <<"result_dt">>, DateTime },
                { <<"result_ts">>, TimeStamp },
                { <<"result_code">> , 0 },
                { <<"result_msg">>  , code(0) },
                { <<"result_data">> , Contents }
           ],
    Ret = jsx:encode(Response),
    {ok, Req1} = cowboy_req:reply(200, [], Ret, Req),
    { case cowboy_req:method(Req) of
        {<<"GET">>,_} -> Ret;
        _   -> ok
    end, Req1, State }.


handle_exception({Req,State}) ->
    Msg = gen_res_error(State),
    Req1=cowboy_req:set_resp_body(Msg,Req),

    { case cowboy_req:method(Req) of
        { <<"GET">> , _ } -> Msg;
        _   -> true
    end, Req1, State }.


code(0)   -> 'STATUS_NORMAL';
code(101) -> 'REQUIRED_ERROR';
code(102) -> 'OBJECT_NOT_FOUND';
code(103) -> 'UNAUTHORIZED';
code(104) -> 'EXPIRED_TOKEN';
code(105) -> 'COMMENT_NOT_FOUND';
code(106) -> 'ALREADY_LIKED';
code(107) -> 'ALREADY_OBJECT';
code(5000)-> 'ALREADY_OBJECT';
code(108) -> 'INVALID_ROOM_ID';
code(109) -> 'INVALID_DEVICE';
code(110) -> 'INTERNAL_SERVER_ERROR';
code(111) -> 'INVALID_VALUE';
code(112) -> 'ALREADY_FOLLOW';
code(_)   -> 'SQL_ERROR'.