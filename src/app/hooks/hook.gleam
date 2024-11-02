import app/config.{type Context}
import app/hooks/auth
import app/hooks/ui
import wisp

pub fn hook_on(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request, config.Context) -> wisp.Response,
) -> wisp.Response {
  // `_method` query parameter.
  //  let req = wisp.method_override(req)

  // Log information about the request and response.
  use <- wisp.log_request(req)

  // Return a default 500 response if the request handler crashes.
  use <- wisp.rescue_crashes

  // Rewrite HEAD requests to GET requests and return an empty body.
  use req <- wisp.handle_head(req)

  // serve UI
  // NOTE: this will add user to context if present
  use ctx <- ui.hook(req, ctx)

  case wisp.path_segments(req) {
    ["auth"] -> {
      use auth_ctx <- auth.hook(req, ctx)
      handle_request(req, auth_ctx)
    }
    _ -> handle_request(req, ctx)
  }
}
