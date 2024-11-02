import app/router
import gleeunit
import gleeunit/should
import helpers/context
import wisp/testing

pub fn main() {
  gleeunit.main()
}

pub fn get_home_page_test() {
  let request = testing.get("/", [])
  let response = router.handle_request(request, context.get_connection())

  response.status
  |> should.equal(200)

  response.headers
  |> should.equal([#("content-type", "text/html; charset=utf-8")])

  response
  |> testing.string_body
  |> should.equal("Welcome to Okane")
}

pub fn post_home_page_test() {
  let request = testing.post("/", [], "a body")
  let response = router.handle_request(request, context.get_connection())

  response.status
  |> should.equal(405)
}

pub fn page_not_found_test() {
  let request = testing.get("/nothing-here", [])
  let response = router.handle_request(request, context.get_connection())

  response.status
  |> should.equal(404)
}
