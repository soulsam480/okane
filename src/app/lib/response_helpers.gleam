import gleam/http/response
import wisp

/// wisp response with status code 401
pub fn unauthorized() -> wisp.Response {
  response.Response(422, [], wisp.Empty)
}
