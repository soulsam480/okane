import app/config
import app/db/models/user
import app/serializers/base
import app/serializers/user as user_serializer
import gleam/http
import gleam/list
import gleam/result
import wisp.{type Request, type Response}

const cookie_max_age = 604_800

const cookie_name = "__session"

type LoginParam {
  LoginParam(email: String, password: String)
}

fn fetch_login_params(
  form_data: wisp.FormData,
  next: fn(LoginParam) -> wisp.Response,
) -> wisp.Response {
  let login_params = {
    use email <- result.try(list.key_find(form_data.values, "email"))
    use password <- result.try(list.key_find(form_data.values, "password"))

    Ok(LoginParam(email, password))
  }

  case login_params {
    Ok(params) -> next(params)
    Error(_) -> wisp.bad_request()
  }
}

fn handle_login(req: Request, ctx: config.Context) -> Response {
  use form_data <- wisp.require_form(req)
  use params <- fetch_login_params(form_data)

  let user_result = params.email |> user.find_by_email(ctx.db)

  case user_result {
    Error(_) -> {
      wisp.bad_request()
      |> wisp.json_body(base.serialize_error(
        "Either email or password is incorrect!",
      ))
    }
    Ok(user) -> {
      case user.password == params.password {
        True -> {
          // TODO: find out how do we hash the cookie value and
          // read it when looking for user in auth hook
          wisp.ok()
          |> wisp.json_body(user_serializer.run(user))
          |> wisp.set_cookie(
            req,
            cookie_name,
            user.email,
            wisp.Signed,
            cookie_max_age,
          )
        }

        False -> {
          wisp.bad_request()
          |> wisp.json_body(base.serialize_error(
            "Either email or password is incorrect !",
          ))
        }
      }
    }
  }
}

fn fetch_register_params(
  form_data: wisp.FormData,
  next: fn(user.InsertableUser) -> wisp.Response,
) -> wisp.Response {
  let register_params = {
    use name <- result.try(list.key_find(form_data.values, "name"))
    use email <- result.try(list.key_find(form_data.values, "email"))
    use password <- result.try(list.key_find(form_data.values, "password"))

    Ok(user.InsertableUser(name, email, password))
  }

  case register_params {
    Ok(params) -> next(params)
    Error(_) -> wisp.bad_request()
  }
}

fn handle_register(req: Request, ctx: config.Context) {
  use form_data <- wisp.require_form(req)
  use params <- fetch_register_params(form_data)

  let my_user = user.insert_user(params, ctx.db)

  case my_user {
    Error(e) -> {
      // TODO: add error specific response messages and codes
      wisp.log_error(e.message)

      wisp.internal_server_error()
      |> wisp.json_body(base.serialize_error("Error signing up!"))
    }

    Ok(new_user) -> {
      wisp.ok() |> wisp.json_body(user_serializer.run(new_user))
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
