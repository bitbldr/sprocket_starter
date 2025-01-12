import app/hooks/double_click.{double_click}
import gleam/int
import gleam/option.{type Option, None, Some}
import sprocket/component.{component, render}
import sprocket/context.{type Context}
import sprocket/hooks.{reducer}
import sprocket/html/attributes.{class, classes}
import sprocket/html/elements.{button_text, div, span, text}
import sprocket/html/events

type Model =
  Int

type Msg {
  UpdateCounter(Int)
  ResetCounter
}

fn init(count: Int) {
  #(count, [])
}

fn update(_model: Model, msg: Msg) {
  case msg {
    UpdateCounter(count) -> {
      #(count, [])
    }
    ResetCounter -> #(0, [])
  }
}

pub type CounterProps {
  CounterProps(initial: Option(Int), enable_reset: Bool)
}

pub fn counter(ctx: Context, props: CounterProps) {
  let CounterProps(initial: initial, enable_reset: enable_reset) = props

  // Define a reducer to handle events and update the state
  use ctx, count, dispatch <- reducer(
    ctx,
    init(option.unwrap(initial, 0)),
    update,
  )

  render(
    ctx,
    div([class("flex flex-row m-4")], [
      component(
        button,
        StyledButtonProps(class: "rounded-l", label: "-", on_click: fn() {
          dispatch(UpdateCounter(count - 1))
        }),
      ),
      component(
        display,
        DisplayProps(
          count: count,
          on_reset: Some(fn() {
            case enable_reset {
              True -> dispatch(ResetCounter)
              False -> Nil
            }
          }),
        ),
      ),
      component(
        button,
        StyledButtonProps(class: "rounded-r", label: "+", on_click: fn() {
          dispatch(UpdateCounter(count + 1))
        }),
      ),
    ]),
  )
}

pub type ButtonProps {
  ButtonProps(label: String, on_click: fn() -> Nil)
  StyledButtonProps(class: String, label: String, on_click: fn() -> Nil)
}

pub fn button(ctx: Context, props: ButtonProps) {
  let #(class, label, on_click) = case props {
    ButtonProps(label, on_click) -> #(None, label, on_click)
    StyledButtonProps(class, label, on_click) -> #(Some(class), label, on_click)
  }

  render(
    ctx,
    button_text(
      [
        events.on_click(fn(_) { on_click() }),
        classes([
          class,
          Some(
            "p-1 px-2 border dark:border-gray-500 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 active:bg-gray-300 dark:active:bg-gray-600",
          ),
        ]),
      ],
      label,
    ),
  )
}

pub type DisplayProps {
  DisplayProps(count: Int, on_reset: Option(fn() -> Nil))
}

pub fn display(ctx: Context, props: DisplayProps) {
  let DisplayProps(count: count, on_reset: on_reset) = props

  use ctx, client_doubleclick <- double_click(ctx, fn() {
    case on_reset {
      Some(on_reset) -> on_reset()
      None -> Nil
    }
  })

  render(
    ctx,
    span(
      [
        client_doubleclick(),
        class(
          "p-1 px-2 w-10 bg-white dark:bg-gray-900 border-t border-b dark:border-gray-500 align-center text-center select-none",
        ),
      ],
      [text(int.to_string(count))],
    ),
  )
}
