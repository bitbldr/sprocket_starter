import gleam/int
import gleam/string
import gleam/result
import gleam/erlang/os
import gleam/erlang/process
import mist
import app/router
import app/app_context.{AppContext}
import app/utils/logger
import app/utils/common

pub fn main() {
  logger.configure_backend(logger.Info)

  let secret_key_base = common.random_string(64)

  // TODO: actually validate csrf token
  let validate_csrf = fn(_csrf) { Ok(Nil) }

  let port = load_port()

  router.stack(AppContext(secret_key_base, validate_csrf))
  |> mist.new
  |> mist.port(port)
  |> mist.start_http

  string.concat(["Listening on localhost:", int.to_string(port), " ✨"])
  |> logger.info

  process.sleep_forever()
}

fn load_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(3000)
}
