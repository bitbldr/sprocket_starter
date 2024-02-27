-module(sprocket_starter_ffi).

-export([configure_logger_backend/1, priv_directory/0]).

configure_logger_backend(Level) ->
    ok = logger:set_primary_config(level, Level),
    ok = logger:set_handler_config(
        default,
        formatter,
        {logger_formatter, #{
            template => [level, ": ", msg, "\n"]
        }}
    ),
    ok = logger:set_application_level(stdlib, notice),
    nil.

priv_directory() ->
    list_to_binary(code:priv_dir(sprocket_starter)).
