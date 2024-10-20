import app/config
import app/router
import gleam/option
import gleeunit
import gleeunit/should
import sqlight
import wisp/testing

pub fn main() {
  gleeunit.main()
}

fn get_connection() -> config.Context {
  use conn <- sqlight.with_connection(":memory:")

  config.Context(conn, option.None)
}

pub fn get_home_page_test() {
  let request = testing.get("/", [])
  let response = router.handle_request(request, get_connection())

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "text/html")])

  response
  |> testing.string_body
  |> should.equal("Welcome to Okane")
}

pub fn post_home_page_test() {
  let request = testing.post("/", [], "a body")
  let response = router.handle_request(request, get_connection())

  response.status
  |> should.equal(405)
}

pub fn page_not_found_test() {
  let request = testing.get("/nothing-here", [])
  let response = router.handle_request(request, get_connection())

  response.status
  |> should.equal(404)
}

pub fn page_session_show_test() {
  let request = testing.get("/session", [])

  let response = router.handle_request(request, get_connection())

  response.status |> should.equal(200)

  response |> testing.string_body |> should.equal("Welcome Okane")
}
