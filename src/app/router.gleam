import app/app_context.{type AppContext}
import app/components/page.{PageProps, page}
import app/layouts/page_layout.{page_layout}
import app/log_requests
import app/static
import app/utils/common.{mist_response}
import app/utils/csrf
import app/utils/logger
import gleam/bytes_tree
import gleam/erlang
import gleam/http.{Get}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/http/service.{type Service}
import gleam/string
import mist.{type Connection, type ResponseData}
import sprocket/component.{component}
import sprocket_mist.{view}

pub fn router(app: AppContext) {
  fn(request: Request(Connection)) -> Response(ResponseData) {
    use <- rescue_crashes()

    case request.method, request.path_segments(request) {
      Get, _ -> {
        let el = component(page, PageProps(app, path: request.path))

        view(
          request,
          page_layout(
            "Welcome to Sprocket!",
            csrf.generate(app.secret_key_base),
          ),
          el,
          app.validate_csrf,
        )
      }

      _, _ ->
        not_found()
        |> response.map(bytes_tree.from_string)
        |> mist_response()
    }
  }
}

pub fn stack(ctx: AppContext) -> Service(Connection, ResponseData) {
  router(ctx)
  |> log_requests.middleware
  |> static.middleware()
  |> service.prepend_response_header("made-with", "Gleam")
}

pub fn method_not_allowed() -> Response(String) {
  response.new(405)
  |> response.set_body("Method not allowed")
  |> response.prepend_header("content-type", "text/plain")
}

pub fn not_found() -> Response(String) {
  response.new(404)
  |> response.set_body("Page not found")
  |> response.prepend_header("content-type", "text/plain")
}

pub fn bad_request() -> Response(String) {
  response.new(400)
  |> response.set_body("Bad request. Please try again")
  |> response.prepend_header("content-type", "text/plain")
}

pub fn internal_server_error() -> Response(String) {
  response.new(500)
  |> response.set_body("Internal Server Error")
  |> response.prepend_header("content-type", "text/plain")
}

pub fn rescue_crashes(
  handler: fn() -> Response(ResponseData),
) -> Response(ResponseData) {
  case erlang.rescue(handler) {
    Ok(response) -> response
    Error(error) -> {
      logger.error(string.inspect(error))

      internal_server_error()
      |> response.map(bytes_tree.from_string)
      |> mist_response()
    }
  }
}
