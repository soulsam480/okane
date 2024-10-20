import app/config
import app/db/models/user
import app/lib/response_helpers
import gleam/http/request
import gleam/int
import gleam/iterator
import gleam/result
import wisp

pub fn hook_auth(
  req: wisp.Request,
  ctx: config.Context,
) -> Result(wisp.Response, wisp.Response) {
  let header = request.get_header(req, "authorization")

  case header {
    Ok(res) -> {
      let user =
        res |> int.parse |> result.try(fn(id) { user.find_by_id(id, ctx.db) })

      case user {
        Ok(u) -> {
          let user = u |> iterator.from_list |> iterator.at(0)
          Ok(wisp.ok() |> wisp.string_body("Hello ?" <> user.name))
        }
        _ -> Ok(wisp.not_found() |> wisp.string_body("Not found !!!"))
      }
    }
    _ -> {
      Error(
        response_helpers.unauthorized()
        |> wisp.string_body("No Access Token found"),
      )
    }
  }
}
