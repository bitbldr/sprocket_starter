import app/app_context.{AppContext}
import app/router
import app/utils/common
import app/utils/logger
import gleam/erlang/os
import gleam/erlang/process
import gleam/int
import gleam/result
import mist

pub fn main() {
  logger.configure_backend(logger.Info)

  let secret_key_base = common.random_string(64)

  // TODO: actually validate csrf token
  let validate_csrf = fn(_csrf) { Ok(Nil) }

  let port = load_port()

  let assert Ok(_) =
    router.stack(AppContext(secret_key_base, validate_csrf))
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}

fn load_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(3000)
}
