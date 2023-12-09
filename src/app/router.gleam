import gleam/bytes_builder.{type BytesBuilder}
import gleam/string
import gleam/bit_array
import gleam/result
import gleam/erlang
import gleam/http.{Get}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import gleam/http/service.{type Service}
import app/log_requests
import app/static
import app/utils/csrf
import app/utils/logger
import app/utils/common.{mist_response}
import app/app_context.{type AppContext}
import app/views/index_view.{IndexViewProps, index_view}
import app/page_route
import mist_sprocket

pub fn router(app_ctx: AppContext) {
  fn(request: Request(Connection)) -> Response(ResponseData) {
    use <- rescue_crashes()

    case request.method, request.path_segments(request) {
      Get, _ ->
        mist_sprocket.live(
          request,
          app_ctx.ca,
          index_view,
          IndexViewProps(
            route: page_route.from_string(request.path),
            csrf: csrf.generate(app_ctx.secret_key_base),
          ),
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
  // |> string_body_middleware
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
