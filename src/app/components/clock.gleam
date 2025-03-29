import gleam/erlang
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import sprocket.{type Context, render}
import sprocket/hooks.{dep, effect, state}
import sprocket/html/elements.{fragment, span, text}
import sprocket/internal/utils/timer.{interval}

pub type ClockProps {
  ClockProps(label: Option(String), time_unit: Option(erlang.TimeUnit))
}

pub fn clock(ctx: Context, props: ClockProps) {
  let ClockProps(label, time_unit) = props

  let time_unit =
    time_unit
    |> option.unwrap(erlang.Second)

  // Define a reducer to handle events and update the state
  use ctx, time, set_time <- state(ctx, erlang.system_time(time_unit))

  // Example effect with an empty list of dependencies, runs once on mount
  use ctx <- effect(
    ctx,
    fn() {
      io.println("Clock component mounted!")
      None
    },
    [],
  )

  // Example effect that has a cleanup function and runs whenever `time_unit` changes
  use ctx <- effect(
    ctx,
    fn() {
      let interval_duration = case time_unit {
        erlang.Millisecond -> 1
        _ -> 1000
      }

      let cancel =
        interval(interval_duration, fn() {
          set_time(erlang.system_time(time_unit))
        })

      Some(fn() { cancel() })
    },
    [dep(time_unit)],
  )

  let current_time = int.to_string(time)

  render(
    ctx,
    fragment(case label {
      Some(label) -> [span([], [text(label)]), span([], [text(current_time)])]
      None -> [text(current_time)]
    }),
  )
}
