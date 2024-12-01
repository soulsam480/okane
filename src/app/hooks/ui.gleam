import app/config
import app/db/models/user
import app/lib/auth_cookie
import app/serializers/user_serializer
import gleam/json
import gleam/option
import gleam/result
import gleam/string_builder
import wisp

fn make_modules() {
  json.object([
    #(
      "htm",
      json.string(
        "https://cdn.jsdelivr.net/npm/preact-htm-signals-standalone/dist/standalone.js",
      ),
    ),
    #("tinydate", json.string("https://esm.sh/tinydate@1.3.0")),
    #("toastify-js", json.string("https://esm.sh/toastify-js@1.12.0")),
  ])
  |> json.to_string_builder
}

fn make_ssr_data(user: option.Option(user.User)) {
  json.object([
    #("user", case user {
      option.Some(u) -> user_serializer.to_json(u)
      _ -> json.null()
    }),
  ])
  |> json.to_string_builder
}

/// 1. render app shell html
/// 2. put session user info inside document
fn render_app_shell(user: option.Option(user.User)) {
  string_builder.new()
  |> string_builder.append(
    "<!doctype html>
<html lang='en'>
  <head>
    <meta charset='UTF-8' />
    <meta name='viewport' content='width=device-width, initial-scale=1.0' />
    <link rel='stylesheet' href='/css/index.css' />
    <title>Okane | A Bill splitting app</title>
    <link media='none' onload=\"if(media!='all')media='all'\" href='https://cdn.jsdelivr.net/npm/toastify-js@1.12.0/src/toastify.css' rel='stylesheet'>
  </head>

  <body>
    <div id='app'></div>
  </body>

  <div id='APP_DATA' style='display: none;'>",
  )
  |> string_builder.append_builder(make_ssr_data(user))
  |> string_builder.append(
    "</div>
<script type='importmap'>
{
  \"imports\":",
  )
  |> string_builder.append_builder(make_modules())
  |> string_builder.append(
    "}
</script>
  <script type='module' src='/js/boot.js'></script>
</html>
",
  )
}

/// this hook handles UI and related redirects
/// 1. render app shell with SSR'ed user session
/// 2. serve ui from priv/ui
pub fn hook(
  req: wisp.Request,
  ctx: config.Context,
  handle: fn(config.Context) -> wisp.Response,
) -> wisp.Response {
  let assert Ok(priv) = wisp.priv_directory("okane")

  use <- wisp.serve_static(req, "/", priv <> "/ui")

  let user_email = auth_cookie.get_cookie(req)

  let user =
    user_email
    |> option.to_result(Nil)
    |> result.map(fn(email) {
      user.find_by_email(email, ctx.db) |> result.nil_error
    })
    |> result.flatten
    |> option.from_result

  // 1. render app shell on base. this way we don't need to redirect random URLs to base.
  case wisp.path_segments(req) {
    [] -> wisp.ok() |> wisp.html_body(render_app_shell(user))
    // 2. for rest, just set user to content and proceed
    _ -> {
      handle(case user {
        option.Some(u) -> config.set_user(ctx, u)
        _ -> ctx
      })
    }
  }
}
