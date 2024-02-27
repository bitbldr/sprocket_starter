import gleam/option.{None, Some}
import sprocket/context.{type Context}
import sprocket/component.{component, render}
import sprocket/html/elements.{
  a, body, div, h1, head, html, link, meta, p, p_text, script, span, text, title,
}
import sprocket/html/attributes.{
  charset, class, content, crossorigin, href, integrity, lang, name,
  referrerpolicy, rel, src,
}
import app/page_route.{type PageRoute}
import app/components/counter.{CounterProps, counter}
import app/components/clock.{ClockProps, clock}
import app/components/hello_button.{HelloButtonProps, hello_button}

pub type IndexViewProps {
  IndexViewProps(route: PageRoute, csrf: String)
}

pub fn index_view(ctx: Context, props: IndexViewProps) {
  let IndexViewProps(csrf: csrf, ..) = props

  render(
    ctx,
    html([lang("en")], [
      head([], [
        title("Welcome to Sprocket!"),
        meta([charset("utf-8")]),
        meta([name("csrf-token"), content(csrf)]),
        meta([name("viewport"), content("width=device-width, initial-scale=1")]),
        meta([name("description"), content("A Sprocket Starter Application")]),
        link([rel("stylesheet"), href("/app.css")]),
        link([
          rel("stylesheet"),
          href(
            "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.1/css/all.min.css",
          ),
          integrity(
            "sha512-MV7K8+y+gLIBoVD59lQIYicR65iaqukzvf/nwasF0nqhPay5w/9lJmVM2hMDcnK1OnMGCdVK+iQrJ7lzPJQd1w==",
          ),
          crossorigin("anonymous"),
          referrerpolicy("no-referrer"),
        ]),
      ]),
      body(
        [
          class(
            "bg-white dark:bg-gray-900 dark:text-white flex flex-col h-screen",
          ),
        ],
        [
          div([class("container mx-auto px-4")], [
            h1([class("text-3xl mt-10 text-center")], [
              span(
                [
                  class(
                    "inline-block animate-spin repeat-1 delay-500 ease-in-out",
                  ),
                ],
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
              "Below are some example components to get you started. Components are rendered on the server and updates are patched into the DOM.",
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
                component(
                  counter,
                  CounterProps(initial: Some(0), enable_reset: True),
                ),
              ]),
              div([class("m-4 w-full")], [
                component(hello_button, HelloButtonProps),
              ]),
            ]),
          ]),
          script([src("/app.js")], None),
        ],
      ),
    ]),
  )
}
