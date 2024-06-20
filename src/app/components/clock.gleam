import gleam/erlang
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import sprocket/component.{render}
import sprocket/context.{type Context, dep}
import sprocket/hooks.{effect, reducer}
import sprocket/html/elements.{fragment, span, text}
import sprocket/internal/utils/timer.{interval}

type Model {
  Model(time: Int, timezone: String)
}

type Msg {
  UpdateTime(Int)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UpdateTime(time) -> {
      Model(..model, time: time)
    }
  }
}

fn initial() -> Model {
  Model(time: erlang.system_time(erlang.Second), timezone: "UTC")
}

pub type ClockProps {
  ClockProps(label: Option(String), time_unit: Option(erlang.TimeUnit))
}

pub fn clock(ctx: Context, props: ClockProps) {
  let ClockProps(label, time_unit) = props

  // Define a reducer to handle events and update the state
  use ctx, Model(time: time, ..), dispatch <- reducer(ctx, initial(), update)

  // Example effect with an empty list of dependencies, runs once on mount
  use ctx <- effect(
    ctx,
    fn() {
      io.println("Clock component mounted!")
      None
    },
    [],
  )

  let time_unit =
    time_unit
    |> option.unwrap(erlang.Second)

  // Example effect that runs whenever the `time` variable changes and has a cleanup function
  use ctx <- effect(
    ctx,
    fn() {
      let interval_duration = case time_unit {
        erlang.Millisecond -> 1
        _ -> 1000
      }
      let update_time = fn() {
        dispatch(UpdateTime(erlang.system_time(time_unit)))
      }
      update_time()
      let cancel = interval(interval_duration, update_time)
      Some(fn() { cancel() })
    },
    [dep(time), dep(time_unit)],
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
