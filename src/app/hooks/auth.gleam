import app/config
import app/db/models/user
import app/lib/auth_cookie
import app/lib/response_helpers
import app/serializers/base_serializer
import gleam/option
import gleam/result
import wisp

fn get_cookie(
  req: wisp.Request,
  with: fn(String) -> wisp.Response,
) -> wisp.Response {
  case auth_cookie.get_cookie(req) {
    option.Some(c) -> with(c)
    option.None -> {
      response_helpers.unauthorized()
      |> wisp.json_body(base_serializer.serialize_error(
        "Invalid token or token not found",
      ))
    }
  }
}

/// re-use user from ui hook if present
/// else move to auth hook
fn reuse_ui_auth_user(
  ctx: config.Context,
  handle: fn(config.Context) -> wisp.Response,
  next: fn() -> wisp.Response,
) -> wisp.Response {
  case ctx.user {
    option.None -> next()
    option.Some(_) -> handle(ctx)
  }
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
  use <- reuse_ui_auth_user(ctx, handle)
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
