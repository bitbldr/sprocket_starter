import gleam/bit_builder.{BitBuilder}
import gleam/http/response.{Response}
import gleam/crypto
import gleam/base
import gleam/string
import mist.{ResponseData}

pub fn mist_response(response: Response(BitBuilder)) -> Response(ResponseData) {
  response.new(response.status)
  |> response.set_body(mist.Bytes(response.body))
}

/// Generate a random string of the given length
pub fn random_string(length: Int) -> String {
  crypto.strong_random_bytes(length)
  |> base.url_encode64(False)
  |> string.slice(0, length)
}
