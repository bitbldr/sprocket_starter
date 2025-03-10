import gleam/option.{None}
import sprocket/component.{type Element}
import sprocket/html/attributes.{
  charset, class, content, crossorigin, href, integrity, lang, name,
  referrerpolicy, rel, src,
}
import sprocket/html/elements.{body, head, html, link, meta, script, title}

pub fn page_layout(page_title: String, csrf: String) {
  fn(inner_content: Element) {
    html([lang("en")], [
      head([], [
        title(page_title),
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
        [inner_content, script([src("/app.js")], None)],
      ),
    ])
  }
}
