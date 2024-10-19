import dot_env/env
import sqlight

pub fn with_connection(conn_fn: fn(sqlight.Connection) -> t) -> t {
  let connection =
    sqlight.with_connection(env.get_string_or("DATABASE", ":memory:"), conn_fn)

  connection
}
