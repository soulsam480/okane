import app/router
import dot_env
import dot_env/env
import gleam/erlang/process
import mist
import radiate
import wisp

pub fn main() {
  // load env vars
  dot_env.load_default()

  // only enable hot-reload in dev
  case env.get_or("MODE", "dev") {
    "dev" -> {
      let _ =
        radiate.new()
        |> radiate.add_dir(".")
        |> radiate.start()

      Nil
    }

    _ -> Nil
  }

  // This sets the logger to print INFO level logs, and other sensible defaults
  // for a web application.
  wisp.configure_logger()

  // Start the Mist web server.
  let assert Ok(_) =
    wisp.mist_handler(
      router.handle_request,
      env.get_or("SECRET", wisp.random_string(64)),
    )
    |> mist.new
    |> mist.port(env.get_int_or("PORT", 8000))
    |> mist.start_http

  // The web server runs in new Erlang process, so put this one to sleep while
  // it works concurrently.

  process.sleep_forever()
}
