import app/config
import app/controllers/groups
import app/controllers/sessions
import app/controllers/users
import app/hooks/hook
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: config.Context) -> Response {
  use req, ctx <- hook.hook_on(req, ctx)

  case wisp.path_segments(req) {
    ["sessions", ..session_segments] ->
      sessions.controller(req, ctx |> config.scope_to(session_segments))

    ["auth", "users", ..user_segments] ->
      users.controller(req, ctx |> config.scope_to(user_segments))

    ["auth", "groups", ..group_segments] ->
      groups.controller(
        req,
        ctx
          |> config.scope_to(group_segments),
      )

    _ -> {
      wisp.not_found()
    }
  }
}
