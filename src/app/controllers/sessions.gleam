import app/config
import app/db/models/user
import gleam/http
import gleam/json
import gleam/list
import gleam/result
import wisp.{type Request, type Response}

const cookie_max_age = 432_000

type LoginParam {
  LoginParam(email: String, password: String)
}

fn handle_login(req: Request, ctx: config.Context) -> Response {
  // get email, password from body
  use form_data <- wisp.require_form(req)

  let login_params = {
    use email <- result.try(list.key_find(form_data.values, "email"))
    use password <- result.try(list.key_find(form_data.values, "password"))

    Ok(LoginParam(email, password))
  }

  case login_params {
    Ok(params) -> {
      let user_result = params.email |> user.find_by_email(ctx.db)

      case user_result {
        Error(_) -> wisp.not_found()
        Ok(user) -> {
          // TODO: find out how do we hash the cookie value and
          // read it when looking for user in auth hook

          wisp.ok()
          |> wisp.set_cookie(
            req,
            "__session",
            user.email,
            wisp.Signed,
            cookie_max_age,
          )
        }
      }
    }

    Error(_) -> wisp.bad_request()
  }
}

fn handle_register(req: Request, ctx: config.Context) {
  use form_data <- wisp.require_form(req)

  let register_params = {
    use name <- result.try(list.key_find(form_data.values, "name"))
    use email <- result.try(list.key_find(form_data.values, "email"))
    use password <- result.try(list.key_find(form_data.values, "password"))

    Ok(user.InsertableUser(name, email, password))
  }

  case register_params {
    Error(_) -> wisp.bad_request()

    Ok(params) -> {
      let my_user = user.insert_user(params, ctx.db)

      case my_user {
        Error(_) -> wisp.internal_server_error()

        Ok(new_user) -> {
          let user_obj =
            json.object([
              #("id", json.int(new_user.id)),
              #("email", json.string(new_user.email)),
              #("name", json.string(new_user.name)),
            ])

          wisp.ok() |> wisp.json_body(json.to_string_builder(user_obj))
        }
      }
    }
  }
}

pub fn controller(req: Request, ctx: config.Context) -> Response {
  case wisp.path_segments(req), req.method {
    ["sessions", "login"], http.Post -> handle_login(req, ctx)
    ["sessions", "register"], http.Post -> handle_register(req, ctx)
    _, _ -> wisp.not_found()
  }
}
