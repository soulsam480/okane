import app/config
import app/lib/response_helpers
import gleam/http/request
import wisp

pub fn hook_auth(
  req: wisp.Request,
  ctx: config.Context,
) -> Result(wisp.Response, wisp.Response) {
  let header = request.get_header(req, "authorization")

  case header {
    Ok(res) -> {
      Ok(wisp.ok())
    }
    _ -> {
      Error(
        response_helpers.unauthorized()
        |> wisp.string_body("No Access Token found"),
      )
    }
  }
}
