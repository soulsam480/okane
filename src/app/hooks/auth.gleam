import app/config
import app/db/models/user
import app/lib/response_helpers
import wisp

pub fn hook(
  req: wisp.Request,
  ctx: config.Context,
) -> Result(config.Context, wisp.Response) {
  let session_cookie_res = wisp.get_cookie(req, "__session", wisp.Signed)

  case session_cookie_res {
    Ok(user_email) -> {
      let user = user.find_by_email(user_email, ctx.db)

      case user {
        Ok(user) -> {
          Ok(ctx |> config.set_user(user))
        }
        _ ->
          Error(
            wisp.not_found()
            |> wisp.string_body("Invalid token or Token not found"),
          )
      }
    }
    _ -> {
      Error(
        response_helpers.unauthorized()
        |> wisp.string_body("Invalid token or Token not found"),
      )
    }
  }
}
