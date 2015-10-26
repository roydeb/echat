-module (ws_handler).
-behaviour (cowboy_websocket_handler).

-import (echat_tables, [insert_user/2,check_user/2]).

-export ([init/3]).
-export ([websocket_init/3,websocket_handle/3,websocket_info/3,websocket_terminate/3]).


init({tcp,http},_Req,_Opts) ->
	{upgrade,protocol,cowboy_websocket}.

websocket_init(_TransportName,Req,_Opts) -> 
	{ok,Req,undefined_state}.

websocket_handle({text,Msg},Req,State) ->
	Valid_user = check_user(Msg),
	case Valid_user of
		valid ->
			io:format("valid~n"),
			{reply,[{text,<<"valid">>}],Req,State};
		password_incorrect ->
			io:format("password_incorrect print~n"),
			{reply,[{text,<<"password_incorrect">>}],Req,State};
		no_user ->
			io:format("no user print~n"),
			{reply,[{text,<<"no_existing_user">>}],Req,State};
		_ ->
			io:format("random shit~n"),
			{reply,[{text,<<"please_try_again">>}],Req,State}
	end;
websocket_handle(_Data,Req,State) ->
	{ok,Req,State}.

websocket_info({send_message, _ServerPid, Msg}, Req, State) ->
    {reply, {text, Msg}, Req, State};
websocket_info(_Info,Req,State) ->
	{ok,Req,State}.

websocket_terminate(_Reason,_Req,_State) -> 
	ok.


%%internal functions
check_user(Msg) ->
	StrMsg = erlang:binary_to_list(Msg),
	Token = string:tokens(StrMsg,","),
	[Uname | PassL] = Token,
	[Pass | _] = PassL,
	io:format("checking~n"),
	Valid = echat_tables:check_user(Uname,Pass),
	Valid.