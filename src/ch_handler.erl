-module (ch_handler).
-behaviour (cowboy_websocket_handler).

-import (echat_tables, [insert_chatroom/2,check_chatroom/0,join_chatroom/2]).

-export ([init/3]).
-export ([websocket_init/3,websocket_handle/3,websocket_info/3,websocket_terminate/3]).


init({tcp,http},_Req,_Opts) ->
	{upgrade,protocol,cowboy_websocket}.

websocket_init(_TransportName,Req,_Opts) -> 
	{ok,Req,undefined_state}.

websocket_handle({text,Msg},Req,State) ->
	io:format("handler received ~p~n",[Msg]),
	StrMsg = erlang:binary_to_list(Msg),
	Token = string:tokens(StrMsg,","),
	[Proc | Details] = Token,
	[Detail |_] = Details,
	case Proc of
		"create" ->
			io:format("creating chat room~n"),
			Chatroom = create_chatroom(Detail),
			case Chatroom of
				done ->
					{reply,[{text,<<"done">>}],Req,State};
				_ ->
					{reply,[{text,<<"not_created">>}],Req,State}
			end;
		"show" ->
			Show = show_chatrooms(),
			Chats = loop(Show,[]),
			{reply,Chats,Req,State};
		"join" ->
			io:format("try joining chat room~n"),
			Chatroom = join_chatroom(Details),
			case Chatroom of
				done ->
					{reply,[{text,<<"joined">>}],Req,State};
				not_exist ->
					{reply,[{text,<<"not_exist">>}],Req,State};
				_ ->
					{reply,[{text,<<"not_joined">>}],Req,State}
			end;
		_ ->
			io:format("not creating~n"),
			{reply,[{text,<<"sum_tim_wong">>}],Req,State}
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

create_chatroom(Name) ->
	Done = echat_tables:insert_chatroom(Name),
	Done.

show_chatrooms() ->
	Crooms = echat_tables:check_chatroom(),
	Crooms.

loop([H|T],List) ->
	io:format("~s ~n",[H]),
	loop(T,[{text,H}|List]);
loop([],List) ->
	List.

join_chatroom(Details) ->
	[Cname|Ex] = Details,
	[Uname|_] = Ex,
	Done = echat_tables:join_chatroom(Cname,Uname),
	io:format("~p~n",[Done]),
	Done.