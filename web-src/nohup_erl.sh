nohup erl -pa ebin deps/*/ebin -config $PWD/priv/boot.config -noshell -detached -s clien main clien free
nohup erl -pa ebin deps/*/ebin -config $PWD/priv/boot.config -noshell -detached -s ddanzi main ddanzi all
nohup erl -pa ebin deps/*/ebin -config $PWD/priv/boot.config -noshell -detached -s cook main 82cook free
nohup erl -pa ebin deps/*/ebin -config $PWD/priv/boot.config -noshell -detached -s mlbpark main mlbpark bullpen2
nohup erl -pa ebin deps/*/ebin -config $PWD/priv/boot.config -noshell -detached -s naver main naver_news empty
nohup erl -pa ebin deps/*/ebin -config $PWD/priv/boot.config -noshell -detached -s yahoo_jp_news main yahoo_jp all

# nohup erl -pa ebin deps/*/ebin -config $PWD/priv/boot.config -noshell -detached -s crate_to_couch_migration main clien free