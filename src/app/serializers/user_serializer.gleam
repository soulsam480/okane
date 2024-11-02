import app/db/models/user
import app/serializers/base_serializer
import gleam/json

pub fn to_json(user: user.User) {
  json.object([
    #("id", json.int(user.id)),
    #("email", json.string(user.email)),
    #("name", json.string(user.name)),
    #("created_at", json.string(user.created_at)),
  ])
}

/// here we can do many things. taking inspirations from rails serializers
/// 1. control visibility of attributes
/// 2. computed attributes that are only needed during response
/// 3. calling and serializing sub queries
pub fn run(user: user.User) {
  to_json(user)
  |> base_serializer.wrap
}
