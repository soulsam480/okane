import gleam/dynamic

pub opaque type User {
  User(
    id: String,
    name: String,
    email: String,
    password: String,
    created_at: String,
  )
}

pub fn decode_user(row: dynamic.Dynamic) {
  todo
}
