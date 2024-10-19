import gleam/bit_array
import gleam/crypto.{Sha256}

pub fn generate(secret_key_base: String) {
  crypto.strong_random_bytes(26)
  |> crypto.sign_message(bit_array.from_string(secret_key_base), Sha256)
}

pub fn validate(csrf_token: String, secret_key_base: String) {
  case
    crypto.verify_signed_message(
      csrf_token,
      bit_array.from_string(secret_key_base),
    )
  {
    Ok(_token) -> Ok(Nil)
    Error(_) -> Error(Nil)
  }
}
