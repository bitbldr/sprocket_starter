import app/app_context.{type AppContext}
import app/components/clock.{ClockProps, clock}
import app/components/counter.{CounterProps, counter}
import app/components/hello_button.{HelloButtonProps, hello_button}
import gleam/option.{Some}
import sprocket.{type Context, component, render}
import sprocket/html/attributes.{class, href, id}

import sprocket/html/elements.{a, div, h1, p, p_text, span, text}

pub type PageProps {
  PageProps(app: AppContext, path: String)
}

pub fn page(ctx: Context, _props: PageProps) {
  render(
    ctx,
    div([id("app"), class("container mx-auto px-4")], [
      div([class("p-2 mt-10 w-full text-center")], [
        h1([class("text-4xl")], [
          span(
            [
              class(
                "inline-block animate-spin repeat-1 delay-500 ease-in-out mr-2",
              ),
            ],
            [text("⚙️")],
          ),
          span([class("font-sprocket-logo italic text-3xl text-[#205a96]")], [
            text("SPROCKET"),
          ]),
        ]),
        div([class("text-gray-500 text-sm")], [
          text("A library for building server components in Gleam ✨"),
        ]),
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
          ClockProps(label: Some("The current system time is: ")),
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
