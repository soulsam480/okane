import gleam/http.{Get}
import gleam/string_builder
import wisp.{type Request, type Response}

fn show_user(_req: Request) -> Response {
  let html = string_builder.from_string("Welcome Okane")

  wisp.ok()
  |> wisp.html_body(html)
}

pub fn controller(req: Request) -> Response {
  case req.method {
    Get -> show_user(req)

    _ -> wisp.method_not_allowed([Get])
  }
}
