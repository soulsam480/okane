import app/config
import app/db/models/group
import app/serializers/base_serializer
import app/serializers/group_serializer
import gleam/http
import gleam/int
import gleam/list
import gleam/result
import wisp

fn fetch_create_group_params(
  form_data: wisp.FormData,
  ctx: config.Context,
  next: fn(group.InsertableGroup) -> wisp.Response,
) -> wisp.Response {
  let group = {
    use name <- result.try(list.key_find(form_data.values, "name"))

    Ok(group.InsertableGroup(name:, owner_id: config.get_user_or_crash(ctx).id))
  }

  case group {
    Ok(params) -> next(params)
    Error(_) -> wisp.bad_request()
  }
}

fn handle_create_group(req: wisp.Request, ctx: config.Context) -> wisp.Response {
  use form <- wisp.require_form(req)
  use create_group_params <- fetch_create_group_params(form, ctx)

  case group.insert_group(create_group_params, ctx.db) {
    Ok(group) -> wisp.ok() |> wisp.json_body(group_serializer.run(group))
    Error(_) ->
      wisp.internal_server_error()
      |> wisp.json_body(base_serializer.serialize_error(
        "Unable to create group!",
      ))
  }
}

fn handle_show_all_groups(ctx: config.Context) -> wisp.Response {
  case group.find_groups_of(config.get_user_or_crash(ctx).id, ctx.db) {
    Ok(groups) ->
      wisp.ok() |> wisp.json_body(group_serializer.run_array(groups))

    Error(_) -> wisp.bad_request()
  }
}

fn fetch_group_id(
  group_id: String,
  handle: fn(Int) -> wisp.Response,
) -> wisp.Response {
  case int.parse(group_id) {
    Ok(id) -> handle(id)
    Error(_) ->
      wisp.bad_request()
      |> wisp.json_body(base_serializer.serialize_error(
        "Invalid group id" <> group_id,
      ))
  }
}

fn handle_show_group(group_id: String, ctx: config.Context) -> wisp.Response {
  use id <- fetch_group_id(group_id)

  case group.find_by_id(id, ctx.db) {
    Ok(group) -> wisp.ok() |> wisp.json_body(group_serializer.run(group))
    Error(_) -> wisp.not_found()
  }
}

pub fn controller(req: wisp.Request, ctx: config.Context) -> wisp.Response {
  case ctx.scoped_segments, req.method {
    [], http.Post -> handle_create_group(req, ctx)

    [], http.Get -> handle_show_all_groups(ctx)

    [group_id], http.Get -> handle_show_group(group_id, ctx)

    [group_id], http.Put -> {
      wisp.not_found()
    }

    [group_id], http.Delete -> wisp.method_not_allowed([http.Delete])

    _, __ -> wisp.not_found()
  }
}
