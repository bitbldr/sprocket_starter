import app/utils/logger
import gleam/string

pub type Page {
  Page(title: String, route: PageRoute)
}

pub type PageRoute {
  Index
  Unknown
}

pub fn from_string(route: String) -> PageRoute {
  let route = case string.ends_with(route, "/live") {
    True -> string.slice(route, 0, string.length(route) - 5)
    False -> route
  }

  let route = case route {
    "" -> "/"
    _ -> route
  }

  case route {
    "/" -> Index
    _ -> Unknown
  }
}

pub fn href(route: PageRoute) -> String {
  case route {
    Index -> "/"
    Unknown -> {
      logger.error("Unknown page route")
      panic
    }
  }
}
