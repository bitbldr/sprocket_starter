import app/app_context.{type AppContext}
import app/components/clock.{ClockProps, clock}
import app/components/counter.{CounterProps, counter}
import app/components/hello_button.{HelloButtonProps, hello_button}
import gleam/option.{None, Some}
import sprocket/component.{component, render}
import sprocket/context.{type Context}
import sprocket/html/attributes.{class, href, id}

import sprocket/html/elements.{a, div, h1, p, p_text, span, text}

pub type PageProps {
  PageProps(app: AppContext, path: String)
}

pub fn page(ctx: Context, _props: PageProps) {
  render(
    ctx,
    div([id("app"), class("container mx-auto px-4")], [
      h1([class("text-3xl mt-10 text-center")], [
        span(
          [class("inline-block animate-spin repeat-1 delay-500 ease-in-out")],
          [text("⚙️")],
        ),
        span([class("italic bold")], [text("Sprocket")]),
      ]),
      div([class("text-gray-500 text-center mt-1 mb-10")], [
        text("Real-time server UI components in Gleam ✨"),
      ]),
      p([class("my-5 text-center")], [
        text("Check out the "),
        a(
          [
            href("https://sprocket.live"),
            attributes.target("_blank"),
            class("underline text-blue-500 hover:text-blue-600"),
          ],
          [text("Sprocket docs")],
        ),
        text(" and the full "),
        a(
          [
            href("https://hexdocs.pm/sprocket"),
            attributes.target("_blank"),
            class("underline text-blue-500 hover:text-blue-600"),
          ],
          [text("API Reference")],
        ),
      ]),
      p_text(
        [class("my-5 text-center")],
        "Below are some example components to get you started. Components are rendered on the server and updates are sent over a websocket and patched into the DOM.",
      ),
      div([class("my-5 text-center")], [
        component(
          clock,
          ClockProps(
            label: Some("The current system time is: "),
            time_unit: None,
          ),
        ),
      ]),
      div([class("grid grid-cols-2 gap-8 justify-items-end")], [
        div([class("m-1")], [
          component(counter, CounterProps(initial: Some(0), enable_reset: True)),
        ]),
        div([class("m-4 w-full")], [component(hello_button, HelloButtonProps)]),
      ]),
    ]),
  )
}
