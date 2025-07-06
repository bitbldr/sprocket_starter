import birl
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/string
import sprocket.{type Context, render}
import sprocket/hooks.{effect, state}
import sprocket/html/elements.{fragment, span, text}
import sprocket/internal/utils/timer.{interval}

pub type ClockProps {
  ClockProps(label: Option(String))
}

pub fn clock(ctx: Context, props: ClockProps) {
  let ClockProps(label) = props

  // Define a reducer to handle events and update the state
  use ctx, time, set_time <- state(ctx, birl.now())

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
      let interval_duration = 1000

      let cancel = interval(interval_duration, fn() { set_time(birl.now()) })

      Some(fn() { cancel() })
    },
    [],
  )

  let current_time = birl.to_naive_time_string(time) |> string.drop_end(4)

  render(
    ctx,
    fragment(case label {
      Some(label) -> [span([], [text(label)]), span([], [text(current_time)])]
      None -> [text(current_time)]
    }),
  )
}
