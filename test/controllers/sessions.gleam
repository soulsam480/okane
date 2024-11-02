import app/router
import gleeunit
import gleeunit/should
import helpers/context
import wisp/testing

pub fn main() {
  gleeunit.main()
}

pub fn sessions_register_missing_form_test() {
  let response =
    testing.post_form("/sessions/register", [], [])
    |> router.handle_request(context.get_connection())

  response.status |> should.equal(400)
}

pub fn sessions_register_form_test() {
  let response =
    testing.post_form("/sessions/register", [], [
      #("name", "zoro"),
      #("email", "test@some.com"),
      #("password", "123"),
    ])
    |> router.handle_request(context.get_connection())

  response.status |> should.equal(201)
}
