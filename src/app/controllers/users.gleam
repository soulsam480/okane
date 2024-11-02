import app/config
import app/serializers/user_serializer
import gleam/http
import gleam/option
import wisp

fn handle_current_user(_req: wisp.Request, ctx: config.Context) {
  case ctx.user {
    option.Some(user) -> wisp.ok() |> wisp.json_body(user_serializer.run(user))
    option.None -> wisp.not_found()
  }
}

pub fn controller(req: wisp.Request, ctx: config.Context) {
  case ctx.scoped_segments, req.method {
    ["current"], http.Get -> handle_current_user(req, ctx)

    _, _ -> wisp.not_found()
  }
}
