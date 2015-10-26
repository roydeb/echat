-module (mc_handler).
-behaviour (cowboy_websocket_handler).

-import (echat_tables, [users_in_chatroom/1]).

-export ([init/3]).
-export ([websocket_init/3,websocket_handle/3,websocket_info/3,websocket_terminate/3]).

init({tcp,http},_Req,_Opts) ->
	{upgrade,protocol,cowboy_websocket}.

websocket_init(_TransportName,Req,_Opts) ->
	{ok,Req,undefined_state}.

websocket_info({send_message, _ServerPid, Msg}, Req, State) ->
    {reply, {text, Msg}, Req, State};
websocket_info(_Info,Req,State) ->
	{ok,Req,State}.

websocket_handle({text,Msg},Req,State) ->
	io:format("mc handler received ~p~n",[Msg]),
	StrMsg = erlang:binary_to_list(Msg),
	Token = string:tokens(StrMsg,","),
	[Proc | Details] = Token,
	[Detail |_] = Details,
	Pid = self(),
	case Proc of
		"showusers" ->
				Show = showusers(Detail),
				Chats = loop(Show,[]),
				{reply,Chats,Req,State};
		"message" ->
				[Uname|CroomMsg] = Details,
				[Croom|Msgm] = CroomMsg,
				[Message] = Msgm,
				io:format("~s : ~s : ~s~n",[Uname,Croom,Message]),
				send_message(Croom,Uname,Message),
				{reply,[{text,<<"none">>}],Req,State};
		_ ->
			{reply,[{text,<<"none">>}],Req,State}
	end;
websocket_handle(_Data,Req,State) ->
	{ok,Req,State}.

websocket_terminate(_Reason,_Req,_State) ->
	ok.

%%INTERNAL FUNCTIONS
showusers(Croom)->
	Crooms = echat_tables:users_in_chatroom(Croom),
	case Crooms of
		{atomic,[]} ->
				no_users;
		{atomic,[{in_chatroom,_,UsersList}]} ->
				UsersList
	end.

loop([H|T],List) ->
	loop(T,[{text,H}|List]);
loop([],List) ->
	List.