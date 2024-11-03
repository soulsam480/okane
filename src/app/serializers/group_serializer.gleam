import app/db/models/group
import app/serializers/base_serializer
import gleam/json

pub fn to_json(group: group.Group) {
  json.object([
    #("id", json.int(group.id)),
    #("name", json.string(group.name)),
    #("owner_id", json.int(group.owner_id)),
    #("created_at", json.string(group.created_at)),
    #("deleted_at", json.nullable(group.deleted_at, json.string)),
  ])
}

/// here we can do many things. taking inspirations from rails serializers
/// 1. control visibility of attributes
/// 2. computed attributes that are only needed during response
/// 3. calling and serializing sub queries
pub fn run(group: group.Group) {
  to_json(group)
  |> base_serializer.wrap
}

pub fn run_array(groups: List(group.Group)) {
  json.array(groups, to_json) |> base_serializer.wrap
}
