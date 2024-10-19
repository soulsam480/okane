import app/config
import app/controllers/home
import app/controllers/session
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: config.Context) -> Response {
  use req <- config.middleware(req, ctx)

  // Wisp doesn't have a special router abstraction, instead we recommend using
  // regular old pattern matching. This is faster than a router, is type safe,
  // and means you don't have to learn or be limited by a special DSL.
  //
  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home.controller(req)

    // responds to session
    ["public", "sessions"] -> session.controller(req)

    _ -> wisp.not_found()
  }
}
