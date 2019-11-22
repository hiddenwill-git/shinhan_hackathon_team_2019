-module(boot_util).

-export([]).
-include("common.hrl").
-compile(export_all).

%% 이상함
%% ((latitude >= 38.23) AND (latitude <= 38.239999999999995)
trunc(Num, Decimals) ->
    Prec = math:pow(10, Decimals),
    erlang:trunc(Num*Prec)/Prec.


% Lat1 = 36.7611751.
% Lng1 = 125.2000072.

% Lat2 = Lat1 + 0.0072.
% Lng2 = Lng1 + 0.0072.
% boot_util:distance(Lng1, Lat1, Lng2, Lat2).
distance(Lng1, Lat1, Lng2, Lat2) ->
    Deg2rad = fun(Deg) -> math:pi()*Deg/180 end,
    [RLng1, RLat1, RLng2, RLat2] = [Deg2rad(Deg) || Deg <- [Lng1, Lat1, Lng2, Lat2]],

    DLon = RLng2 - RLng1,
    DLat = RLat2 - RLat1,

    A = math:pow(math:sin(DLat/2), 2) + math:cos(RLat1) * math:cos(RLat2) * math:pow(math:sin(DLon/2), 2),

    C = 2 * math:asin(math:sqrt(A)),

    %% suppose radius of Earth is 6372.8 km
    Km = 6372.8 * C,
    Km.

get_random_string(Length, AllowedChars) ->
    seed(),
    lists:foldl(fun(_, Acc) ->
                        [lists:nth(random:uniform(length(AllowedChars)),
                                   AllowedChars)]
                            ++ Acc
                end, [], lists:seq(1, Length)).

get_random_string(Length) ->
  get_random_string(Length,"1234567890qwertyuiopasdfghjklzxcvbnm").

random_number({Min,Max}) when Min >= Max -> Min;
random_number({Min,Max}) ->
    seed(),
    crypto:rand_uniform(Min, Max);

random_number(MaxNumber) ->
    seed(),
    random:uniform(MaxNumber).
%% @doc Convert anything to String
string(Value) when is_list(Value) ->
    Value;
string(Value) when is_binary(Value) ->
    binary_to_list(Value);
string(Value) when is_integer(Value) ->
    integer_to_list(Value);
string(Value) when is_float(Value) ->
    lists:flatten(io_lib:format("~p",[Value]));
string(Value) when is_atom(Value) ->
  atom_to_list(Value).

int(Value) when is_binary(Value) ->
    case string:to_integer(binary_to_list(Value)) of
        {error, no_integer} ->
            -1;

        {Int, _} ->
            Int
    end;

int(Value) when is_atom(Value) ->
    int(atom_to_list(Value));

int(Value) when is_list(Value) ->
    case string:to_integer(Value) of
        {error, no_integer} ->
            -1;

        {Int, _} ->
            Int
    end;
int(Value) when is_integer(Value) ->
    Value;
int(undefined)->
    -1.

int(Value,Replace) ->
  case int(Value) of -1 -> Replace; _ = R -> R end.

%% @doc Convert anything to Binary
binary(Value) when is_binary(Value) ->
    Value;
binary(Value) when is_list(Value) ->
    list_to_binary(Value);
binary(Value) when is_float(Value) ->
    binary(lists:flatten(io_lib:format("~p",[Value])));
    % binary(float_to_list(Value,[{decimals, 2}]));
binary(Value) when is_integer(Value) ->
    list_to_binary(integer_to_list(Value));
binary(Value) when is_atom(Value) ->
  atom_to_binary(Value, utf8).

characters_to(Value) when is_binary(Value) ->
    unicode:characters_to_list(Value);
characters_to(Value) ->
    unicode:characters_to_binary(Value).

characters_to_list(Value) when is_binary(Value) ->
    unicode:characters_to_list(Value);
characters_to_list(Value) ->
    Value.

characters_to_binary(Value) when is_list(Value) ->
    unicode:characters_to_binary(Value);
characters_to_binary(Value) ->
    Value.

atom(V) when is_list(V) ->
    try
        list_to_existing_atom(V)
    catch
        _:_ -> list_to_atom(V)
    end;
atom(V) when is_binary(V) ->
    atom(binary_to_list(V));
atom(V) when is_atom(V) orelse is_integer(V) orelse is_float(V)  ->
    V.

body(Req) -> body(Req, <<>>).
body(Req, Acc) ->
    case cowboy_req:body(Req,[{length, infinity}]) of
        {ok, Bin, Req2} -> {ok, <<Acc/binary, Bin/binary>>, Req2};
        {more, Bin, Req2} -> body(Req2, <<Acc/binary, Bin/binary>>);
        Other -> Other
    end.

env(Key) ->
   env(boot,Key).

env(Module,Key) ->
    case application:get_env(Module, Key) of
        {ok, Val} -> Val;
        undefined -> undefined
    end.

env(Module,Key,Default) ->
    case application:get_env(Module, Key) of
        {ok, Val} -> Val;
        undefined -> Default
    end.

uuid() ->
  {V1uuid, _} = uuid:get_v1(uuid:new(self(), erlang)),
  list_to_binary(uuid:uuid_to_string(V1uuid)).

is_uuid(Value) ->
    is_uuid(v1,Value).

is_uuid(v1,Value) ->
    try
        uuid:is_v1(uuid:string_to_uuid(string(Value)))
    catch _:_ ->
        false
    end.
%% -----------------------------------------------------------------
pget(Key, Proplists) ->
    proplists:get_value(Key, Proplists).
pget(Key, Proplists,string) ->
    string(proplists:get_value(Key, Proplists));
pget(Key, Proplists, Default) ->
    proplists:get_value(Key, Proplists, Default).
pgets(List, Proplists, Default) ->
    [pget(Key,Proplists,Default)||Key<-List].

%% {ok,[{key,value} ... ]}
%% {error, Reason}
% get_value([{required,_},{optional,_}],undefined) ->
%     {error, {key_not_found,<<"object_is_undefined">>} };

get_value([{required,Required},{optional,Optional}],Context) ->
    case get_value({required,Required,Context},[]) of
        {key_not_found,Key}  -> {error, {key_not_found,Key}};
        {deny_nil_value,Key} -> {error, {deny_nil_value,Key}};
        {invalid_value,Key}  -> {error, {invalid_value,Key}};
        Reqs -> Reqs ++ get_value({optional,Optional,Context},[])
    end;

get_value({required,[H|T],Context},Acc) ->
    case pget(binary(H), Context, key_not_found) of
        key_not_found -> {key_not_found,H};
        Value when Value == <<>> -> {deny_nil_value,H};
        Value when Value == undefined -> {invalid_value,H};
        Value -> get_value({required,T,Context},Acc ++ [{H,Value}])
    end;

get_value({optional,[{Key,Default}|T],Context},Acc) ->
    Value = pget(binary(Key), Context, Default),
    get_value({optional,T,Context},Acc ++ [{Key,Value}]);

get_value({optional,[Key|T],Context},Acc) ->
    case pget(binary(Key), Context) of
        undefined ->
            get_value({optional,T,Context},Acc);
        Value ->
            get_value({optional,T,Context},Acc ++ [{Key,Value}])
    end;
    %get_value({optional,[{H,<<>>}|T],Context},Acc);

get_value({_,[],_},Acc) -> Acc.

md5(Val) ->
     binary(lists:flatten([io_lib:format("~2.16.0b",[N])
        || N <- binary_to_list(erlang:md5(binary(Val)))])).

clean(Val) ->
    try
        re:replace(re:replace(Val, "\\s+$", "", [global,{return,binary}]), "^\\s+", "", [global,{return,binary}])
    catch _:_ ->
        Val
    end.

split_list(List, Max) ->
    element(1, lists:foldl(fun
        (E, {[Buff|Acc], C}) when C < Max ->
            {[[E|Buff]|Acc], C+1};
        (E, {[Buff|Acc], _}) ->
            {[[E],Buff|Acc], 1};
        (E, {[], _}) ->
            {[[E]], 1}
    end, {[], 0}, List)).

part(List,Max) ->
     RevList = split_list(List, Max),
     lists:foldl(fun(E, Acc) ->
         [lists:reverse(E)|Acc]
     end, [], RevList).

trim(Val) ->
  re:replace(re:replace(Val, "\\s+$", "", [global,{return,binary}]), "^\\s+", "", [global,{return,binary}]).

number(Val) ->
  int(re:replace(Val,"[^0-9]+", "", [global,{return,binary}])).
%% -----------------------------------------------------------------
%% TIME
%% -----------------------------------------------------------------
seed() ->
    case erlang:function_exported(erlang, timestamp, 0) of
        true  -> random:seed(erlang:timestamp()); %% R18
        false -> random:seed(os:timestamp()) %% Compress now() deprecated warning...
    end.

now_to_secs() -> now_to_secs(os:timestamp()).

now_to_secs({MegaSecs, Secs, _MicroSecs}) ->
    MegaSecs * 1000000 + Secs.

now_to_ms() -> now_to_ms(os:timestamp()).

now_to_ms({MegaSecs, Secs, MicroSecs}) ->
    (MegaSecs * 1000000 + Secs) * 1000 + round(MicroSecs/1000).

timestamp(yyyymmdd) ->
    {Y, M, D} = erlang:date(),
    list_to_binary(lists:flatten(io_lib:format("~w~2.2.0w~2.2.0w", [Y, M, D])));

timestamp(yyyymmddhh) ->
    Now = os:timestamp(),
    {{Y, M, D}, {H, _Min, _S}} = calendar:now_to_local_time(Now),
    list_to_binary(lists:flatten(io_lib:format("~w~2.2.0w~2.2.0w~2.2.0w",
     [Y, M, D, H])));

timestamp(yyyymmddhhmm) ->
    Now = os:timestamp(),%now(),
    {{Y, M, D}, {H, Min, _S}} = calendar:now_to_local_time(Now),
    list_to_binary(lists:flatten(io_lib:format("~w~2.2.0w~2.2.0w~2.2.0w~2.2.0w",
     [Y, M, D, H, Min]))).

timestamp_f() ->
    Now = os:timestamp(),%now(),
    {{Y, M, D}, {H, Min, S}} = calendar:now_to_local_time(Now),
    A = list_to_binary(lists:flatten(io_lib:format("~w-~2.2.0w-~2.2.0w ~w:~2.2.0w:~2.2.0w",
     [Y, M, D, H, Min, S]))),
    {now_to_ms(Now),A}.

gen_date_info_object([Y,M,D,H,MM,Original]) ->
    [M1,D1,H1,MM1] = [lists:flatten(io_lib:format("~2.2.0w",[int(X)])) || X <- [M,D,H,MM]],
    Y1 = string(Y),
    [{<<"yyyymm">>,int(Y1 ++ M1)},
      {<<"yyyymmdd">>,int(Y1 ++ M1 ++ D1)},
      {<<"yyyymmdd_h">>,int(Y1 ++ M1 ++ D1 ++ H1)},
      {<<"yyyymmdd_hm">>,int(Y1 ++ M1 ++ D1 ++ H1 ++ MM1)},
      {<<"year">>,int(Y)},
      {<<"month">>,int(M)},
      {<<"day">>,int(D)},
      {<<"hour">>,int(H)},
      {<<"minute">>,int(MM)},
      {<<"original">>,Original}].

type_check(Val,yyyymmdd_hh) ->
    case Val of
        << _A:4/binary, _B:2/binary , _C:2/binary, _D:2/binary >> -> Val;
        _ -> undefined
    end;

type_check(Val,yyyymmdd) ->
    case Val of
        << _A:4/binary, _B:2/binary , _C:2/binary >> -> Val;
        _ -> undefined
    end;
type_check(Val,yyyymm) ->
    case Val of
        << A:4/binary, B:2/binary , _:2/binary >> -> << A/binary, B/binary >>;
        << _A:4/binary, _B:2/binary  >> -> Val;
        _ -> undefined
    end;
type_check(Val,yyyy) ->
    case Val of
        << A:4/binary, _:2/binary , _:2/binary >> -> A;
        << A:4/binary, _:2/binary  >> -> A;
        << A:4/binary  >> -> A;
        _ -> undefined
    end.

merge(_,[],Acc) -> Acc;
merge(Column,[H|T],Acc) ->
    ?INFO("~n1 ~p",[H]),
    ?INFO("~n2 ~p",[Acc]),
    merge(Column,T,[Acc ++ lists:zip(Column,H)]).

% boot_util:append_binary([1,2,<<"clien">>,<<"text">>]).
append_binary(L) ->
    append_binary(L,<<"^">>).

append_binary(L,Delemeter) ->
    lists:foldl(fun(Val,Acc)->
        << Acc/binary, Delemeter/binary, (binary(Val))/binary >>
    end,<<>>,L).



% httpc:request(post, {"http://localhost:3000/foo", [],
%                     "application/x-www-form-urlencoded",
%                     url_encode([{"username", "bob"}, {"password", "123456"}])}
%              ,[],[])

% -spec(url_encode(formdata()) -> string()).
url_encode(Data) ->
    url_encode(Data,"").

url_encode([],Acc) ->
    Acc;

url_encode([{Key,Value}|R],"") ->
    url_encode(R, edoc_lib:escape_uri(Key) ++ "=" ++ edoc_lib:escape_uri(Value));
url_encode([{Key,Value}|R],Acc) ->
    url_encode(R, Acc ++ "&" ++ edoc_lib:escape_uri(Key) ++ "=" ++ edoc_lib:escape_uri(Value)).

%% input validator

%% 2016123001,20
%% boot_util:date_time_hour_calc(2016123012,10).
date_time_hour_calc(DateTimeHour,ToSize) ->
    DateTime = boot_util:string(DateTimeHour),
    Y = boot_util:int(string:substr(DateTime,1,4)),
    M = boot_util:int(string:substr(DateTime,5,2)),
    D = boot_util:int(string:substr(DateTime,7,2)),
    H = boot_util:int(string:substr(DateTime,9,2)),
    DT = { {Y,M,D}, {H,0,0} },
    Seconds = calendar:datetime_to_gregorian_seconds({ {Y,M,D}, {H,0,0} }) - 62167219200,
    Seconds1 = Seconds - 32400, %% -9시간
    %% -1시간씩 이동, 12시간 표현
    Secs = [Seconds1 - (60*60*N)||N<-lists:seq(1,ToSize-1)],

    lists:foldl(fun(Sec,Acc)->
        SecStr = boot_util:string(Sec),
        A = boot_util:int(string:substr(SecStr,1,4)),
        B = boot_util:int(string:substr(SecStr,5,6)),
        {{YYYY,MM,DD},{HH,_,_}} = calendar:now_to_local_time({A,B,0}),
        DTStr =list_to_binary(lists:flatten(io_lib:format("~w~2.2.0w~2.2.0w~2.2.0w",[YYYY, MM, DD, HH]))),
        Acc ++ [DTStr]
    end,[boot_util:binary(DateTime)],Secs).

%% 날짜 차이 계산
% {2017,2,5} ~ {2017,3,5}
day_of_ranges({StartDay,EndDay}) ->
    day_of_ranges({StartDay,EndDay,[edate:shift(StartDay, 0,day)]});

day_of_ranges({StartDay,EndDay,L}) when StartDay == EndDay -> L;

day_of_ranges({StartDay,EndDay,L}) ->
    IncDay = edate:shift(StartDay, + 1, day),
    day_of_ranges({IncDay, EndDay, L ++ [IncDay]}).

get_email({get,Val}) ->
    case get_email({default,Val}) of
        {match,L} -> 
            lists:nth(1,lists:last(L));
        _ ->
            case get_email({Val,with_out_domain}) of
                {match,L1} -> 
                    lists:nth(1,lists:last(L1));
                _ -> 
                    <<>>
            end
    end;

get_email({default,Val}) ->
    re:run(Val, 
        "\\b[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*\\b",
        [global,{capture, all, binary}]);
get_email({Val,with_out_domain}) ->
    re:run(Val, 
        "\\b[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@",
        [global,{capture, all, binary}]).

get_domain(<<>>) -> undefined;
get_domain(Val) ->
    try
        % http_uri:parse("https://m.localhost.com:8080?x=a").
        % {ok,{https,[],"m.localhost.com",8080,"/","?x=a"}}
        {ok,Result} = http_uri:parse(string(Val)),
        {_Scheme, _UserInfo, Host, _Port, _Path, _Query} = Result,
        Host
    catch _:_ ->
        undefined
    end.
% binary_join([<<"Hello">>, <<"World">>], <<", ">>) % => <<"Hello, World">>
% binary_join([<<"Hello">>], <<"...">>) % => <<"Hello">>
-spec binary_join([binary()], binary()) -> binary().
binary_join([], _Sep) ->
  <<>>;
binary_join([Part], _Sep) ->
  Part;
binary_join(List, Sep) ->
  lists:foldr(fun (A, B) ->
    if
      bit_size(B) > 0 -> <<A/binary, Sep/binary, B/binary>>;
      true -> A
    end
  end, <<>>, List).

binary_join(Bin) ->
    binary_join(Bin,<<",">>).