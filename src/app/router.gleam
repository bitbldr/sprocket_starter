import app/app_context.{type AppContext}
import app/components/page.{PageProps, page}
import app/layouts/page_layout.{page_layout}
import app/log_requests
import app/static
import app/utils/common.{mist_response}
import app/utils/csrf
import app/utils/logger
import gleam/bit_array
import gleam/bytes_builder.{type BytesBuilder}
import gleam/erlang
import gleam/http.{Get}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/http/service.{type Service}
import gleam/option.{None}
import gleam/result
import gleam/string
import mist.{type Connection, type ResponseData}
import mist_sprocket.{view}

pub fn router(app: AppContext) {
  fn(request: Request(Connection)) -> Response(ResponseData) {
    use <- rescue_crashes()

    case request.method, request.path_segments(request) {
      Get, _ ->
        view(
          request,
          page_layout(
            "Welcome to Sprocket!",
            csrf.generate(app.secret_key_base),
          ),
          page,
          fn(_) { PageProps(app, path: request.path) },
          app.validate_csrf,
          None,
        )

      _, _ ->
        not_found()
        |> response.map(bytes_builder.from_string)
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

pub fn string_body_middleware(
  service: Service(String, String),
) -> Service(BitArray, BytesBuilder) {
  fn(request: Request(BitArray)) {
    case bit_array.to_string(request.body) {
      Ok(body) -> service(request.set_body(request, body))
      Error(_) -> bad_request()
    }
    |> response.map(bytes_builder.from_string)
  }
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

pub fn http_service(
  req: Request(Connection),
  service: Service(BitArray, BytesBuilder),
) -> Response(ResponseData) {
  req
  |> mist.read_body(1024 * 1024 * 10)
  |> result.map(fn(http_req: Request(BitArray)) {
    http_req
    |> service()
    |> mist_response()
  })
  |> result.unwrap(
    response.new(500)
    |> response.set_body(mist.Bytes(bytes_builder.new())),
  )
}

pub fn rescue_crashes(
  handler: fn() -> Response(ResponseData),
) -> Response(ResponseData) {
  case erlang.rescue(handler) {
    Ok(response) -> response
    Error(error) -> {
      logger.error(string.inspect(error))

      internal_server_error()
      |> response.map(bytes_builder.from_string)
      |> mist_response()
    }
  }
}
