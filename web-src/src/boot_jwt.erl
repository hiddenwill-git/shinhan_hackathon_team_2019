-module(boot_jwt).

%% API
-export([]).

-compile(export_all).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
make(Claims) ->
    Message = jsx:encode(Claims),
	RSAPrivateJWK = boot_key_server:get(jwt_private),

    SignedRS256 = jose_jwk:sign(Message, #{ <<"alg">> => <<"RS256">> }, RSAPrivateJWK),
    CompactSignedRS256 = jose_jws:compact(SignedRS256),

    { _, Bin } = CompactSignedRS256,
    Bin.

get(AccessToken) when is_binary(AccessToken) ->
    RSAPublicJWK = boot_key_server:get(jwt_private),
    try jose_jwk:verify(AccessToken, RSAPublicJWK) of
        {Verified, Message, _} ->
            case Verified of
                true ->
                    _Claims = jsx:decode(Message);
                _ ->
                	access_token_not_verified
            end
    catch
        _:_ -> access_token_not_verified %% from v1_post_comments:is_authorized/2
    end.
