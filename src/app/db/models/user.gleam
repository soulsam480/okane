import app/db/connection
import app/db/models/helpers
import app/lib/generic_error
import cake
import cake/insert
import cake/select
import cake/where
import decode/zero
import gleam/dynamic
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import sqlight

pub type User {
  User(
    id: Int,
    name: String,
    email: String,
    password: String,
    created_at: String,
  )
}

fn decode_user(row: dynamic.Dynamic) {
  row |> string.inspect |> io.println

  let decoder = {
    use id <- zero.field(0, zero.int)
    use name <- zero.field(1, zero.string)
    use email <- zero.field(2, zero.string)
    use password <- zero.field(3, zero.string)
    use created_at <- zero.field(4, zero.string)

    zero.success(User(id:, name:, email:, password:, created_at:))
  }

  zero.run(row, decoder)
}

fn get_user_props() {
  select.new()
  |> select.from_table("users")
  |> select.selects([
    select.col("users.id"),
    select.col("users.name"),
    select.col("users.email"),
    select.col("users.password"),
    select.col("users.created_at"),
  ])
}

pub fn find_by_id(id: Int, conn: sqlight.Connection) {
  get_user_props()
  |> select.where(where.col("users.id") |> where.eq(where.int(id)))
  |> select.comment("Find user by id")
  |> select.to_query
  |> cake.to_read_query
  |> connection.run_query_with(conn, decode_user)
  |> result.map(fn(users) { users |> list.first })
  |> result.replace_error(Nil)
  |> result.flatten
}

pub fn find_by_email(email: String, conn: sqlight.Connection) {
  get_user_props()
  |> select.where(where.col("users.email") |> where.eq(where.string(email)))
  |> select.comment("Find user by email")
  |> select.to_query
  |> cake.to_read_query
  |> connection.run_query_with(conn, decode_user)
  |> result.map(fn(users) {
    users |> list.first |> result.replace_error(generic_error.new("empty user"))
  })
  |> result.map_error(fn(e) { generic_error.new(e) })
  |> result.flatten
}

// insert user

pub type InsertableUser {
  InsertableUser(name: String, email: String, password: String)
}

fn insertable_user_encoder(user: InsertableUser) {
  [
    user.name |> insert.string,
    user.email |> insert.string,
    // TODO: implement lib for password hashing here
    user.password |> insert.string,
  ]
  |> helpers.with_created_at_param
  |> insert.row
}

pub fn insert_user(
  insertable user: InsertableUser,
  connection conn: sqlight.Connection,
) {
  use _ <- result.try(
    insert.from_records(
      records: [user],
      table_name: "users",
      columns: ["name", "email", "password"] |> helpers.with_created_at_column,
      encoder: insertable_user_encoder,
    )
    |> insert.to_query
    |> cake.to_write_query
    |> connection.run_query_with(conn, dynamic.dynamic)
    |> result.map_error(fn(e) { generic_error.new(e) }),
  )

  find_by_email(user.email, conn)
}
