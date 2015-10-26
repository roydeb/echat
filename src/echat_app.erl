-module(echat_app).

-behaviour(application).

-import (echat_tables, [init/0]).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	echat_tables:init(),
    echat_sup:start_link().

stop(_State) ->
    ok.
