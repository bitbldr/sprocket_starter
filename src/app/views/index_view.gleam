import gleam/option.{None, Some}
import sprocket/context.{Context}
import sprocket/component.{component, render}
import sprocket/html.{
  body, div, h1, head, html, link, meta, p_text, script, text, title,
}
import sprocket/html/attributes.{
  charset, class, content, crossorigin, href, integrity, lang, name,
  referrerpolicy, rel, src,
}
import app/components/header.{HeaderProps, MenuItem, header}
import app/page_route.{PageRoute}
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
    [
      html(
        [lang("en")],
        [
          head(
            [],
            [
              title("Welcome to Sprocket!"),
              meta([charset("utf-8")]),
              meta([name("csrf-token"), content(csrf)]),
              meta([
                name("viewport"),
                content("width=device-width, initial-scale=1"),
              ]),
              meta([
                name("description"),
                content("A Sprocket Starter Application"),
              ]),
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
            ],
          ),
          body(
            [
              class(
                "bg-white dark:bg-gray-900 dark:text-white flex flex-col h-screen",
              ),
            ],
            [
              div(
                [],
                [
                  component(
                    header,
                    HeaderProps(menu_items: [
                      MenuItem("Docs", "https://sprocket.live"),
                    ]),
                  ),
                ],
              ),
              div(
                [class("container mx-auto px-4")],
                [
                  h1(
                    [class("text-3xl my-10 text-center")],
                    [text("Hello from Sprocket!")],
                  ),
                  div(
                    [],
                    [
                      component(
                        clock,
                        ClockProps(
                          label: Some("The current time is: "),
                          time_unit: None,
                        ),
                      ),
                    ],
                  ),
                  div(
                    [],
                    [
                      component(
                        counter,
                        CounterProps(initial: Some(0), enable_reset: True),
                      ),
                      component(hello_button, HelloButtonProps),
                    ],
                  ),
                ],
              ),
              script([src("/app.js")], None),
            ],
          ),
        ],
      ),
    ],
  )
}
