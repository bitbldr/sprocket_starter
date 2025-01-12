import app/app_context.{AppContext}
import app/router
import app/utils/csrf
import app/utils/logger
import envoy
import gleam/erlang/process
import gleam/int
import gleam/result
import mist

pub fn main() {
  logger.configure_backend(logger.Info)

  let secret_key_base = load_secret_key_base()
  let port = load_port()

  let assert Ok(_) =
    router.stack(AppContext(secret_key_base, csrf.validate(_, secret_key_base)))
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}

fn load_port() -> Int {
  envoy.get("PORT")
  |> result.then(int.parse)
  |> result.unwrap(3000)
}

fn load_secret_key_base() -> String {
  envoy.get("SECRET_KEY_BASE")
  |> result.unwrap("change_me")
}
