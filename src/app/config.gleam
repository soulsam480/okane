import app/db/models/user
import gleam/option.{type Option, None, Some}
import sqlight

/// this is app context. when user is authenticated, it has user
/// or db connection only
pub type Context {
  Context(
    db: sqlight.Connection,
    user: Option(user.User),
    scoped_segments: List(String),
  )
}

pub fn acquire_context(db: sqlight.Connection, run: fn(Context) -> a) -> a {
  run(Context(db, None, []))
}

pub fn set_user(ctx: Context, user: user.User) {
  let Context(db, _, scope) = ctx

  Context(db, Some(user), scope)
}

pub fn scope_to(ctx: Context, scoped_segments: List(String)) {
  let Context(db, user, ..) = ctx

  Context(db, user, scoped_segments)
}
