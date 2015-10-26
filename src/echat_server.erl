-module (echat_server).
-behaviour (gen_server).

-export ([start_link/0]).

%%gen_server callbacks
-export ([init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).

-define (SERVER, ?MODULE).

-record (state, {}).

%%API
start_link() ->
	gen_server:start_link({local,?SERVER},?MODULE,[],[]).

%%gen_server callbacks
init([]) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, echat, "index.html"}},
			{"/index.html", cowboy_static, {priv_file, echat, "index.html"}},
			%%{"/[...]", cowboy_static, {priv_dir, echat, "",
			%%	[{mimetypes, cow_mimetypes, all}]}},
			{"/ws", ws_handler, []},
			{"/ch",ch_handler,[]},
			{"/signup",signup_handler,[]},
			{"/mc",mc_handler,[]},
			{"/chat_page.html",cowboy_static,{priv_file,echat,"chat_page.html"}},
			{"/sign_up.html",cowboy_static,{priv_file,echat,"sign_up.html"}},
			{"/main_chat.html",cowboy_static,{priv_file,echat,"main_chat.html"}}
		]}
	]),
	{ok, _} = cowboy:start_http(http, 100, [{port, 8080}], [
		{env, [{dispatch, Dispatch}]}
	]),
	io:format("wow! dispatched!!~n"),
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.