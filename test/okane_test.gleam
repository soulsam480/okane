import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn base_test() {
  10 |> should.equal(10)
}
