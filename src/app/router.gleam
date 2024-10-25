import app/config
import app/controllers/home
import app/controllers/sessions
import app/hooks/hook
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: config.Context) -> Response {
  use req, ctx <- hook.hook_on(req, ctx)

  case wisp.path_segments(req) {
    [] -> home.controller(req)

    ["sessions", ..] -> sessions.controller(req, ctx)

    _ -> {
      wisp.not_found()
    }
  }
}
