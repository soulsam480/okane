import app/config
import app/db/models/user
import app/lib/auth_cookie
import app/serializers/user_serializer
import gleam/json
import gleam/option
import gleam/result
import gleam/string_builder
import wisp

fn make_ssr_data(user: option.Option(user.User)) {
  json.object([
    #("user", case user {
      option.Some(u) -> user_serializer.to_json(u)
      _ -> json.null()
    }),
  ])
  |> json.to_string_builder
}

fn app_shell(user: option.Option(user.User)) {
  string_builder.new()
  |> string_builder.append(
    "<!doctype html>
<html lang='en'>
  <head>
    <meta charset='UTF-8' />
    <meta name='viewport' content='width=device-width, initial-scale=1.0' />
    <link rel='stylesheet' href='/css/index.css' />
    <title>Okane | A Bill splitting app</title>
  </head>

  <body>
    <div id='app'>
  <form>
    <input
      type='text'
      placeholder='Type here'
      className='input w-full max-w-xs'
    />
  </form>
	</div>
  </body>

  <div id='APP_DATA'>",
  )
  |> string_builder.append_builder(make_ssr_data(user))
  |> string_builder.append(
    "</div>

  <script type='module'>
    import sprae from 'https://unpkg.com/sprae/dist/sprae.min.js';

    const container = document.querySelector('#app');
    const hydrate_el = document.querySelector('#APP_DATA')

    const state = sprae(container, {
	...JSON.parse(hydrate_el?.textContent ?? '{}')
	});
	
    hydrate_el.remove()
  </script>
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

  // TODO: find ways to improve this
  let user =
    user_email
    |> option.to_result(Nil)
    |> result.map(fn(email) {
      user.find_by_email(email, ctx.db) |> result.replace_error(Nil)
    })
    |> result.flatten
    |> option.from_result

  case wisp.path_segments(req) {
    [] -> {
      wisp.ok() |> wisp.html_body(app_shell(user))
    }
    _ ->
      handle(case user {
        option.Some(u) -> config.set_user(ctx, u)
        _ -> ctx
      })
  }
}
