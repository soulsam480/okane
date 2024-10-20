import app/config
import app/controllers/home
import app/controllers/session
import app/hooks/hook
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: config.Context) -> Response {
  use req <- hook.middleware(req, ctx)

  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home.controller(req)

    // responds to session
    ["public", "sessions"] -> session.controller(req)

    _ -> wisp.not_found()
  }
}
