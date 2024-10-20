import app/db/connection
import cake
import cake/select
import cake/where
import decode/zero
import gleam/dynamic
import gleam/iterator
import gleam/result
import sqlight

pub opaque type User {
  User(
    id: Int,
    name: String,
    email: String,
    password: String,
    created_at: String,
  )
}

fn decode_user(row: dynamic.Dynamic) {
  let decoder = {
    use id <- zero.field("id", zero.int)
    use name <- zero.field("name", zero.string)
    use email <- zero.field("email", zero.string)
    use password <- zero.field("password", zero.string)
    use created_at <- zero.field("created_at", zero.string)
    zero.success(User(id:, name:, email:, password:, created_at:))
  }

  zero.run(row, decoder)
}

pub fn find_by_id(id: Int, conn: sqlight.Connection) {
  select.new()
  |> select.selects([
    select.col("users.id"),
    select.col("users.name"),
    select.col("users.email"),
    select.col("users.password"),
    select.col("users.created_at"),
  ])
  |> select.from_table("users")
  |> select.where(where.col("users.id") |> where.eq(where.int(id)))
  |> select.comment("Find user by id")
  |> select.to_query
  |> cake.to_read_query
  |> connection.run_query_with(conn, decode_user)
  // |> result.try(fn(res) { res |> iterator.from_list |> iterator.at(0) })
}
