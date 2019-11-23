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
	{<<"user_name">>,boot_util:characters_to_binary("황용식")},
	{<<"point">>,3000},
	 {<<"promotions">>,
	 	[<<"/promotions/add_img1.png">>,
		 <<"/promotions/add_img2.png">>,
		 <<"/promotions/add_img3.png">>]
	 }];

task({v1_user_resource,<<"test2">>}) ->
	[{<<"user_id">>,<<"test1">>},
	{<<"user_name">>,boot_util:characters_to_binary("최향미")},
	{<<"point">>,3000},
	 {<<"promotions">>,
	 	[<<"/promotions/add_img1.png">>,
		 <<"/promotions/add_img2.png">>,
		 <<"/promotions/add_img3.png">>]
	 }];

task({v1_user_resource,<<"test3">>}) ->
	[{<<"user_id">>,<<"test1">>},
	{<<"user_name">>,boot_util:characters_to_binary("노규태")},
	{<<"point">>,3000},
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


% query({v1_query_promotion,_Contents}) ->
% 	boot_key_server:get("data_set2_test_re.json");
%  [{<<"profile_sex">>,[<<"M">>,<<"F">>]},{<<"profile_job">>,[<<"10">>,<<"7">>,<<"6">>,<<"9">>,<<"4">>]},{<<"profile_age">>,[<<"10">>,<<"20">>,<<"30">>]},{<<"profile_married">>,[<<"true">>]},{<<"profile_children">>,[<<"0">>,<<"1">>,<<"2">>,<<"3">>]}]

query(v1_query_promotion_user_status) ->
	Rows = boot_key_server:get("data_set3_time.json"),
	[{<<"PROMOTION_1">>,
	[{<<"target_id">>,1},
	{<<"2">>,
		[{<<"One often sees a cell phone time">>,P1_Phone},
		{<<"Bedtime zone">>,P1_Bed},
		{<<"Time zone with low response rate">>,P1_Time},
		{<<"Positive response rate">>,P1_Rate}]}]},
	{<<"PROMOTION_2">>,
	[{<<"target_id">>,2},
	{<<"2">>,
		[{<<"One often sees a cell phone time">>,P2_Phone},
		{<<"Bedtime zone">>,P2_Bed},
		{<<"Time zone with low response rate">>,P2_Time},
		{<<"Positive response rate">>,P2_Rate}]}]},
	{<<"PROMOTION_3">>,
	[{<<"target_id">>,3},
	{<<"2">>,
		[{<<"One often sees a cell phone time">>,P3_Phone},
		{<<"Bedtime zone">>,P3_Bed},
		{<<"Time zone with low response rate">>,P3_Time},
		{<<"Positive response rate">>,P3_Rate}]}]},
	{<<"PROMOTION_4">>,
	[{<<"target_id">>,4},
	{<<"2">>,
		[{<<"One often sees a cell phone time">>,P4_Phone},
		{<<"Bedtime zone">>,P4_Bed},
		{<<"Time zone with low response rate">>,P4_Time},
		{<<"Positive response rate">>,P4_Rate}]}]}] = Rows,
		
	[{<<"page1">>,[P1_Phone,P1_Bed,P1_Time,P1_Rate]},
	 {<<"page2">>,[P2_Phone,P2_Bed,P2_Time,P2_Rate]},
	 {<<"page3">>,[P3_Phone,P3_Bed,P3_Time,P3_Rate]},
	 {<<"page4">>,[P4_Phone,P4_Bed,P4_Time,P4_Rate]}];
	

query({v1_query_promotion,Contents}) ->
	query({v1_query_target,Contents});
query({v1_query_target,Contents}) ->
	Rows = boot_key_server:get("data_set1_total_10000.json"),
	% Rows = boot_key_server:get("data_set1_total.json"),
	% Rows = boot_key_server:get("data_set1_re.json"),
	filter({Rows,Contents}).

filter({Rows,[]}) -> Rows;
filter({Rows,[{Key,Values}|T]}) ->	
	Rows1 = filter1({sub,Rows,{Key,Values}}),
	% ?INFO("Key ~p, Rows1 ~p",[Key,length(Rows1)]),
	filter({Rows1,T}).

% filter1({sub,Rows,{_Key,[]}}) -> Rows;
filter1({sub,Rows,{_Key,undefined}}) -> Rows;
filter1({sub,Rows,{<<"profile_age">> = Key,Values}}) ->
	Ages = lists:merge([lists:seq(X1-10,X1)||X1<-Values]),
	lists:foldl(fun(Row,Acc)->
		case lists:member(proplists:get_value(Key,Row),Ages) of
			true -> Acc ++ [Row];
			_ -> Acc
		end
	end,[],Rows);

filter1({sub,Rows,{Key,Values}}) ->
	lists:foldl(fun(Row,Acc)->
		% ?INFO("Key ~p, get ~p, values ~p",[Key,proplists:get_value(Key,Row),Values]),
		case lists:member(proplists:get_value(Key,Row),Values) of
			true -> 
				Acc ++ [Row];
			_ -> Acc
		end
	end,[],Rows).