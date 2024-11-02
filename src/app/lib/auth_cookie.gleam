import app/db/models/user
import gleam/option
import wisp

pub const cookie_max_age = 604_800

pub const cookie_name = "__session"

pub fn get_cookie(req: wisp.Request) -> option.Option(String) {
  wisp.get_cookie(req, cookie_name, wisp.Signed) |> option.from_result
}

pub fn set_cookie(res: wisp.Response, req: wisp.Request, user: user.User) {
  wisp.set_cookie(
    res,
    req,
    cookie_name,
    user.email,
    wisp.Signed,
    cookie_max_age,
  )
}
