-module(sprocket_starter_ffi).

-export([configure_logger_backend/0, priv_directory/0, current_timestamp/0, format_unix_timestamp/2]).

configure_logger_backend() ->
    ok = logger:set_primary_config(level, info),
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

current_timestamp() ->
    Now = erlang:system_time(second),
    list_to_binary(calendar:system_time_to_rfc3339(Now)).

format_unix_timestamp(UnixTimestamp, TimeUnit) ->
    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:system_time_to_universal_time(
        UnixTimestamp, TimeUnit
    ),

    % io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w:~3..0w", [
    %     Year, Month, Day, Hour, Minute, Second, Milliseconds
    % ]).

    case TimeUnit of
        millisecond ->
            Milliseconds = UnixTimestamp rem 1000,

            io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w:~3..0w", [
                Year, Month, Day, Hour, Minute, Second, Milliseconds
            ]);
        _ ->
            io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w", [
                Year, Month, Day, Hour, Minute, Second
            ])
    end.
