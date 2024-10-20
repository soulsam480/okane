import app/db/models/user
import gleam/option.{type Option, None, Some}
import sqlight

/// this is app context. when user is authenticated, it has user
/// or db connection only
pub type Context {
  Context(db: sqlight.Connection, user: Option(user.User))
}

pub fn context_with_connection(db: sqlight.Connection) {
  Context(db, None)
}

pub fn set_user(ctx: Context, user: user.User) {
  let Context(db, ..) = ctx

  Context(db, Some(user))
}
