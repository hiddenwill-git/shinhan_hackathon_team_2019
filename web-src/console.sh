#!/bin/sh
./rebar compile skip_deps=true
#!/bin/sh
cd `dirname $0`
exec erl -pa $PWD/ebin $PWD/deps/*/ebin \
-boot start_sasl \
-s reloader \
-s boot \
-config $PWD/priv/boot.config  \
-name boot@localhost \
-setcookie boot \
-smp true \
+W w \
+K true \
+A 64 \
+P 2097152 \
+Q 1048576 \
-env ERL_MAX_PORTS 1048576 \
-env ERTS_MAX_PORTS 1048576 \
-env ERL_MAX_ETS_TABLES 1024 \
-env ERL_FULLSWEEP_AFTER 1000
