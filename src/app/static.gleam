import app/utils/common.{mist_response}
import gleam/bytes_builder
import gleam/http/request.{type Request}
import gleam/http/response.{type Response, Response}
import gleam/http/service.{type Service}
import gleam/list
import gleam/result
import gleam/string
import mist.{type ResponseData}
import simplifile

pub fn middleware(
  service: Service(in, ResponseData),
) -> Service(in, ResponseData) {
  fn(request: Request(in)) -> Response(ResponseData) {
    let request_path = case request.path {
      "/" -> "/index.html"
      path -> path
    }

    let path =
      request_path
      |> string.replace(each: "..", with: "")
      |> string.replace(each: "//", with: "/")
      |> string.append("/static", _)
      |> string.append(priv_directory(), _)

    let file_contents =
      path
      |> simplifile.read_bits
      |> result.nil_error
      |> result.map(bytes_builder.from_bit_array)

    let extension =
      path
      |> string.split(on: ".")
      |> list.last
      |> result.unwrap("")

    case file_contents {
      Ok(bits) -> {
        let content_type = case extension {
          "html" -> "text/html"
          "css" -> "text/css"
          "js" -> "application/javascript"
          "png" | "jpg" -> "image/jpeg"
          "gif" -> "image/gif"
          "svg" -> "image/svg+xml"
          "ico" -> "image/x-icon"
          _ -> "octet-stream"
        }
        Response(200, [#("content-type", content_type)], bits)
        |> mist_response()
      }
      Error(_) -> service(request)
    }
  }
}

@external(erlang, "sprocket_starter_ffi", "priv_directory")
pub fn priv_directory() -> String
