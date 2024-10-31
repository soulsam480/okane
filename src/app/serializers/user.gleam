import app/db/models/user
import app/serializers/base
import gleam/json

pub fn run(user: user.User) {
  json.object([
    #("id", json.int(user.id)),
    #("email", json.string(user.email)),
    #("name", json.string(user.name)),
    #("created_at", json.string(user.created_at)),
  ])
  |> base.wrap
}
