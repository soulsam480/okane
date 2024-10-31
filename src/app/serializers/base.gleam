import gleam/json

pub fn wrap(data: json.Json) {
  json.object([#("data", data)])
  |> json.to_string_builder
}

pub fn serialize_error(error: String) {
  json.object([#("error", json.string(error))])
  |> json.to_string_builder
}
