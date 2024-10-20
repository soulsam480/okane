import gleam/http/response
import wisp

pub fn unauthorized() -> wisp.Response {
  response.Response(422, [], wisp.Empty)
}
