import app/config
import gleam/option
import sqlight

pub fn get_connection() -> config.Context {
  use conn <- sqlight.with_connection(":memory:")

  config.Context(conn, option.None, [])
}
