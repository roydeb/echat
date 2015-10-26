-module (echat_tables).
-include ("echat_records.hrl").
-export ([init/0,insert_user/2,check_user/2,
			insert_chatroom/1,check_chatroom/0,
			join_chatroom/2,users_in_chatroom/1]).

init() ->
	application:set_env(mnesia,dir,"../db"),
	mnesia:create_schema([node()]),
	io:format("sating from echat ttables~n"),
	mnesia:start(),
	%mnesia:info(),
	io:format("user table = ~p~n",[mnesia:create_table(user,[{attributes,record_info(fields,user)},{disc_copies,[node()]}])]),
	io:format("chatroom table = ~p~n",[mnesia:create_table(chatroom,[{attributes,record_info(fields,chatroom)},{disc_copies,[node()]}])]),
	io:format("chat_messages table = ~p~n",[mnesia:create_table(chat_messages,[{attributes,record_info(fields,chat_messages)},{disc_copies,[node()]}])]),
	mnesia:create_table(in_chatroom,[{attributes,record_info(fields,in_chatroom)},{disc_copies,[node()]}]),
	mnesia:info().

insert_user(Name,Password) ->
	User = #user{name = Name,password = Password},
	Fun = fun() ->
				mnesia:write(User)
		  end,
	Trans_result = mnesia:transaction(Fun),
	case Trans_result of
		{aborted, Reason} ->
			unable_to_insert;
		{atomic, Result} ->
			done;
		_ ->
			unable_to_insert
	end.

check_user(Name,Password) ->
	Fun = fun() ->
				mnesia:read(user,Name)
		  end,
	Lookup = mnesia:transaction(Fun),
	Valid = check_validity(Lookup,Password),
	io:format("validity : ~s~n",[Valid]),
	Valid.

check_validity(Lookup,Password) ->
	case Lookup of
		{atomic,[{user,_,PassCheck}]} ->
			case PassCheck of
				Password ->
					valid;
				_ ->
					password_incorrect
			end;
		_ ->
			no_user
	end.

insert_chatroom(Name) ->
	Chatroom = #chatroom{cname=Name,id=1},
	Fun = fun() ->
				mnesia:write(Chatroom)
		  end,
	Trans_result = mnesia:transaction(Fun),
	case Trans_result of
		{aborted, Reason} ->
			unable_to_insert;
		{atomic, Result} ->
			done;
		_ ->
			unable_to_insert
	end.

check_chatroom() ->
	Fun = fun() ->
				mnesia:all_keys(chatroom)
		  end,
	Lookup = mnesia:transaction(Fun),
	case Lookup of
		{atomic,Chatrooms} ->
					io:format("~p~n",[Chatrooms]);
		_ ->
					io:format("fuck~n"),
					Chatrooms=[]
	end,
	Chatrooms.


chatroom_exists(Cname) ->
	Fun = fun() ->
				mnesia:read(chatroom,Cname)
		  end,
	Lookup = mnesia:transaction(Fun),
	case Lookup of
		{atomic,[]} ->
			not_exist;
		{atomic,_} ->
			exists;
		_ ->
			nopes
	end.

join_chatroom(Cname,Uname) ->
	Exists = chatroom_exists(Cname),
	case Exists of
		exists ->
			Holder = users_in_chatroom(Cname),
			case Holder of
				{atomic,[{in_chatroom,_,UsersList}]} ->
								NewUsersList = [Uname | UsersList],
								Join = #in_chatroom{chatroom=Cname,users=NewUsersList},
								Fun = fun() ->
										mnesia:write(Join)
									  end,
								Trans_result = mnesia:transaction(Fun),
								done;
				{atomic,[]} ->
								Join = #in_chatroom{chatroom=Cname,users=[Uname]},
								Fun = fun() ->
										mnesia:write(Join)
									  end,
								Trans_result = mnesia:transaction(Fun),
								done;
				_ ->
					unable_to_insert
			end;
		not_exist ->
			not_exist;
		_ ->
			nopes
	end.

users_in_chatroom(Croom) ->
	Fun =fun() ->
				mnesia:read(in_chatroom,Croom)
		  end,
	Lookup = mnesia:transaction(Fun),
	Lookup.