import gleam/http.{Get}
import gleam/string_builder
import wisp.{type Request, type Response}

fn show(_req: Request) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  // use <- wisp.require_method(req, Get)

  let html = string_builder.from_string("Welcome to Okane")

  wisp.ok()
  |> wisp.html_body(html)
}

pub fn controller(req: Request) -> Response {
  case req.method {
    Get -> show(req)

    _ -> wisp.method_not_allowed([Get])
  }
}
