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

/// creates base context with the db connection
pub fn acquire_context(db: sqlight.Connection, run: fn(Context) -> a) -> a {
  run(Context(db, None, []))
}

pub fn set_user(ctx: Context, user: user.User) {
  Context(..ctx, user: Some(user))
}

/// scope this router context to following path
/// basically this eliminates the need to pattern match the prefix
/// e.g.
/// for a path /auth/users/home -> if auth is already matched -> context can be narrowed to ["users","home"]
pub fn scope_to(ctx: Context, scoped_segments: List(String)) {
  Context(..ctx, scoped_segments:)
}

/// get user from context or crash
/// ! Only intended to be used in places where auth is taken care prior in the chain
pub fn get_user_or_crash(ctx: Context) {
  let assert Some(u) = ctx.user
  u
}
