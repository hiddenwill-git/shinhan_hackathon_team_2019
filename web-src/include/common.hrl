%-define(MSGHEAD(Color), " \e[0;32m<<-- " ++ "APP_NAME" ++ " log -->> " ++ Color).
-define(MSGHEAD(Color), " \e[0;32m<log> " ++ Color).
-define(MSGTAIL(), "\e[0;38m").
-define(DEBUG(Msg, Args), lager:log(debug,[{module, ?MODULE}], ?MSGHEAD("\e[0;38m") ++ Msg ++ ?MSGTAIL(), Args)).
-define(INFO(Msg, Args), lager:log(info,[{module, ?MODULE}],   ?MSGHEAD("\e[1;37m") ++ Msg ++ ?MSGTAIL(), Args)).
-define(NOTICE(Msg, Args), lager:log(notice,[{module, ?MODULE}], ?MSGHEAD("\e[1;36m") ++ "-------------------- " ++ Msg ++ " --------------------" ++ ?MSGTAIL(), Args)).
-define(WARNING(Msg, Args), lager:log(warning,[{module, ?MODULE}], ?MSGHEAD("\e[1;33m") ++ Msg ++ ?MSGTAIL(), Args)).
-define(ERROR(Msg, Args), lager:log(error,[{module, ?MODULE}], ?MSGHEAD("\e[1;31m") ++ Msg ++ ?MSGTAIL(), Args)).
-define(CRITICAL(Msg, Args), lager:log(critical,[{module, ?MODULE}], ?MSGHEAD("\e[1;35m") ++ Msg ++ ?MSGTAIL(), Args)).

-define(record_to_tuplelist(Rec, Ref), lists:zip(record_info(fields, Rec),tl(tuple_to_list(Ref)))).

-define(NOW(),boot_util:now_to_ms()).
-define(INT(Val),boot_util:int(Val)).
-define(GET(Key,Proplists),boot_util:pget(Key,Proplists)).
-define(GET(Key,Proplists,Default),boot_util:pget(Key,Proplists,Default)).
-define(GETT(Key,Proplists),{Key,boot_util:pget(Key,Proplists)}).
-define(GETT(Key,Proplists,Default),{Key,boot_util:pget(Key,Proplists,Default)}).
-define(STATUS_NORMAL,0).
-define(REQUIRED_ERROR,101).
-define(OBJECT_NOT_FOUND,102).
-define(DOCUMENT_ALREADY_EXISTS,5000).
-define(UNAUTHORIZED,103).
-define(EXPIRED_TOKEN,104).
-define(COMMENT_NOT_FOUND,105).
-define(ALREADY_LIKED,106).
-define(ALREADY_OBJECT,107).
-define(ALREADY_FOLLOW,112).
%% chat
-define(INVALID_ROOM_ID,108).
-define(INVALID_DEVICE,109).
-define(INTERNAL_SERVER_ERROR,110).
-define(INVALID_VALUE,111).

-define(ALL_DOMAINS,
	[]).

-define(ALL_DOMAIN_NAMES,
	[]).

-record(resource, {contents,method,error_code = ?STATUS_NORMAL,opts,
							error_message,app_ver,user_id,level=0}).
