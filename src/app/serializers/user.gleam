import app/db/models/user
import app/serializers/base
import gleam/json

/// here we can do many things. taking inspirations from rails serializers
/// 1. control visibility of attributes
/// 2. computed attributes that are only needed during response
/// 3. calling and serializing sub queries
pub fn run(user: user.User) {
  json.object([
    #("id", json.int(user.id)),
    #("email", json.string(user.email)),
    #("name", json.string(user.name)),
    #("created_at", json.string(user.created_at)),
  ])
  |> base.wrap
}
