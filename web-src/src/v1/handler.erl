-module(handler).

-export([]).

-include("common.hrl").
-compile(export_all).

-import(boot_util, [pget/2]).
-import(boot_util, [trim/1]).
-import(boot_util, [int/1]).

%% 사용자 포인트 정보 조회
task({v1_user_resource,<<"test1">>}) ->
	[{<<"user_id">>,<<"test1">>},
	{<<"user_name">>,boot_util:characters_to_binary("홍길동")},
	{<<"point">>,5000},
	 {<<"promotions">>,
	 	[<<"/promotions/add_img1.png">>,
		 <<"/promotions/add_img2.png">>,
		 <<"/promotions/add_img3.png">>]
	 }];

task({v1_user_resource,UserID}) ->
	[{<<"user_id">>,UserID},
	{<<"user_name">>,boot_util:characters_to_binary("사용자A")},
	{<<"point">>,5000},
	 {<<"promotions">>,
	 	[<<"/promotions/add_img1.png">>,
		 <<"/promotions/add_img2.png">>,
		 <<"/promotions/add_img3.png">>]
	 }];

task(v1_tag_baskets) ->
	boot_key_server:get("test_basket.json").

query() ->
	Rows = boot_key_server:get("data_set1_re.json"),

	lists:foldl(fun(Row,Acc)->
		case proplists:get_value(<<"profile_address">>,Row) == boot_util:characters_to_binary("서울시") of
			true -> Acc ++ [Row];
			_ -> Acc
		end
	end,[],Rows).