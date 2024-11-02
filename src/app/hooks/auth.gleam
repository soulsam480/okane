import app/config
import app/db/models/user
import app/lib/response_helpers
import app/serializers/base_serializer
import gleam/result
import wisp

pub const cookie_max_age = 604_800

pub const cookie_name = "__session"

pub fn get_cookie(
  req: wisp.Request,
  with: fn(String) -> wisp.Response,
) -> wisp.Response {
  let cookie_res = wisp.get_cookie(req, cookie_name, wisp.Signed)

  case cookie_res {
    Ok(c) -> with(c)
    Error(_) -> {
      response_helpers.unauthorized()
      |> wisp.json_body(base_serializer.serialize_error(
        "Invalid token or token not found",
      ))
    }
  }
}

pub fn set_cookie(res: wisp.Response, req: wisp.Request, user: user.User) {
  wisp.set_cookie(
    res,
    req,
    cookie_name,
    user.email,
    wisp.Signed,
    cookie_max_age,
  )
}

/// session/auth hook
/// 1. check if cookie is present
/// 2. find user if there and put it inside context
/// 3. error out otherwise. 
pub fn hook(
  req: wisp.Request,
  ctx: config.Context,
  handle: fn(config.Context) -> wisp.Response,
) -> wisp.Response {
  use user_email <- get_cookie(req)

  user.find_by_email(user_email, ctx.db)
  |> result.map_error(fn(_) {
    response_helpers.unauthorized()
    |> wisp.json_body(base_serializer.serialize_error(
      "Invalid token or token not found",
    ))
  })
  |> result.map(fn(user) { config.set_user(ctx, user) |> handle })
  |> result.unwrap_error(wisp.internal_server_error())
}
