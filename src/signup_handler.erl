-module (signup_handler).
-behaviour (cowboy_websocket_handler).

-import (echat_tables, [insert_user/2]).

-export ([init/3]).
-export ([websocket_init/3,websocket_handle/3,websocket_info/3,websocket_terminate/3]).



init({tcp,http},_Req,_Opts) ->
	{upgrade,protocol,cowboy_websocket}.

websocket_init(_TransportName,Req,_Opts) -> 
	{ok,Req,undefined_state}.

websocket_handle({text,Msg},Req,State) ->
	Add = add_user(Msg),
	case Add of
		already_exists ->
			io:format("existing user, try with a different name~n"),
			{reply,[{text,<<"existing_user">>}],Req,State};
		done ->
			io:format("now we're talking!!~n"),
			{reply,[{text,<<"approved">>}],Req,State};
		_ ->
			io:format("something went wrong, please try again!!~n"),
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
add_user(Msg) ->
	StrMsg = erlang:binary_to_list(Msg),
	Token = string:tokens(StrMsg,","),
	[Uname | Pass] = Token,
	[EPass | _] = Pass,
	Existing_user = echat_tables:check_user(Uname,EPass),
	case Existing_user of
		valid ->
			already_exists;
		password_incorrect ->
			already_exists;
		_ ->
			Insertion = echat_tables:insert_user(Uname,EPass),
			case Insertion of
				done ->
					done;
				_ ->	
					nopes
			end
	end.