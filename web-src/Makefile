BASE_DIR = $(shell pwd)
REBAR    = $(BASE_DIR)/rebar
ERL ?= erl
APP := geochat_server

.PHONY: deps test

# deps 빌드무시
1:
	@$(REBAR) compile skip_deps=true

all: deps
	@rebar compile

deps:
	@rebar get-deps

clean:
	@rebar clean

distclean: clean
	@rebar delete-deps

docs:
	@erl -noshell -run edoc_run application '$(APP)' '"."' '[]'

test:
	rebar skip_deps=true eunit
