import app/config.{type Context}
import app/hooks/auth
import wisp

pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  // `_method` query parameter.
  //  let req = wisp.method_override(req)

  // Log information about the request and response.
  use <- wisp.log_request(req)

  // Return a default 500 response if the request handler crashes.
  use <- wisp.rescue_crashes

  // Rewrite HEAD requests to GET requests and return an empty body.
  use req <- wisp.handle_head(req)

  case wisp.path_segments(req) {
    ["auth"] -> {
      let result = auth.hook_auth(req, ctx)

      handle_request(req)
    }
    _ -> handle_request(req)
  }
}
