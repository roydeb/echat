-module (admin_handler).
-behaviour (cowboy_websocket_handler).

-import (echat_tables, [check_chatroom/0,get_all_users/0,delete_all_users/0]).

-export ([init/3]).
-export ([websocket_init/3,websocket_handle/3,websocket_info/3,websocket_terminate/3]).

init({tcp,http},_Req,_Opts) ->
	{upgrade,protocol,cowboy_websocket}.

websocket_init(_TransportName,Req,_Opts) ->
	Pid = self(),
	update_lists(Pid),
	{ok,Req,undefined_state}.


websocket_handle({text,Msg},Req,State) ->
	% {reply,[{text,<<"hello">>}],Req,State};
	Pid = self(),
	StrMsg = erlang:binary_to_list(Msg),
	Token = string:tokens(StrMsg,","),
	[Proc | _] = Token,
	Casa = case Proc of
		"deleteallusers" ->
			Del = echat_tables:delete_all_users(),
			io:format("deleted users: ~p~n",[Del]),
			update_lists(Pid),
			{reply, {text, "all users deleted"}, Req, State};
		_ ->
			{not_ok,Req,State}
		end;

websocket_handle(_Data,Req,State) ->
	{ok,Req,State}.

websocket_info({send_message, _ServerPid, Msg}, Req, State) ->
    {reply, {text, Msg}, Req, State};
websocket_info({send_users, _ServerPid, Msg}, Req, State) ->
	Umsg = "users:"++Msg,
    {reply, {text, Umsg}, Req, State};
websocket_info({send_chatrooms, _ServerPid, Msg}, Req, State) ->
	Uchat = "chatrooms:"++Msg,
    {reply, {text, Uchat}, Req, State};
websocket_info(_Info,Req,State) ->
	{ok,Req,State}.

websocket_terminate(_Reason,_Req,_State) -> 
	ok.

%%internal functions
update_lists(Pid) ->
	Users = echat_tables:get_all_users(),
	Chatrooms = echat_tables:check_chatroom(),
	ChainUsers = chain(Users,""),
	ChainChats = chain(Chatrooms,""),
	io:format("inside admin_handler :~n ~p : ~p~n",[ChainUsers,ChainChats]),
	Pid ! {send_users,self(),ChainUsers},
	Pid ! {send_chatrooms,self(),ChainChats}.

chain([H|T],Str) ->
	NewStr = Str ++ H++",",
	chain(T,NewStr);
chain([],Str) ->
	Str.