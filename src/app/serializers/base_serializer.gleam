import gleam/json

/// wrap produces uniform structure for all json response bodies
/// {ab: cd} -> {data: {ab: cd}}
pub fn wrap(data: json.Json) {
  json.object([#("data", data)])
  |> json.to_string_builder
}

/// produces an uniform json error from provided string
/// bad -> {error: bad}
pub fn serialize_error(error: String) {
  json.object([#("error", json.string(error))])
  |> json.to_string_builder
}
