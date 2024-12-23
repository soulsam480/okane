import app/config
import app/db/connection
import app/db/migrator
import app/router
import dev
import dot_env
import dot_env/env
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  // load env vars
  dot_env.load_default()

  // This sets the logger to print INFO level logs, and other sensible defaults
  // for a web application.
  wisp.configure_logger()

  // only enable hot-reload in dev
  case env.get_string_or("MODE", "dev") {
    "dev" -> dev.run()
    _ -> Nil
  }

  let assert Ok(_) = migrator.migrate_to_latest()

  use db <- connection.with_connection()
  use context <- config.acquire_context(db)

  // Start the Mist web server.
  let assert Ok(_) =
    wisp_mist.handler(
      router.handle_request(_, context),
      env.get_string_or("SECRET", wisp.random_string(64)),
    )
    |> mist.new
    |> mist.port(env.get_int_or("PORT", 8000))
    |> mist.start_http

  // The web server runs in new Erlang process, so put this one to sleep while
  // it works concurrently.

  process.sleep_forever()
}
