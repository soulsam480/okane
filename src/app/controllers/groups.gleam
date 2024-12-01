import app/config
import app/db/models/group
import app/serializers/base_serializer
import app/serializers/group_serializer
import gleam/http
import gleam/int
import gleam/list
import gleam/result
import gleam/string
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

    Error(error) -> {
      wisp.log_error(string.inspect(error))

      wisp.internal_server_error()
      |> wisp.json_body(base_serializer.serialize_error(
        "Unable to create group!",
      ))
    }
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

fn handle_update_group(
  group_id: Int,
  req: wisp.Request,
  ctx: config.Context,
) -> wisp.Response {
  use form <- wisp.require_form(req)
  use update_group_params <- fetch_create_group_params(form, ctx)

  case
    group.update_by_id(
      group_id,
      group.UpdateableGroup(update_group_params.name),
      ctx.db,
    )
  {
    Ok(group) -> wisp.ok() |> wisp.json_body(group_serializer.run(group))

    Error(error) -> {
      wisp.log_error(string.inspect(error))

      wisp.internal_server_error()
      |> wisp.json_body(base_serializer.serialize_error(
        "Unable to update group!",
      ))
    }
  }
}

fn handle_delete_group(group_id: Int, ctx: config.Context) {
  case group.discard_by_id(group_id, ctx.db) {
    Ok(_) -> wisp.no_content()
    Error(error) -> {
      wisp.log_error(string.inspect(error))

      wisp.internal_server_error()
      |> wisp.json_body(base_serializer.serialize_error(
        "Unable to delete group!",
      ))
    }
  }
}

pub fn controller(req: wisp.Request, ctx: config.Context) -> wisp.Response {
  case ctx.scoped_segments, req.method {
    [], http.Post -> handle_create_group(req, ctx)

    [], http.Get -> handle_show_all_groups(ctx)

    [group_id], http.Get -> handle_show_group(group_id, ctx)

    [group_id], http.Put ->
      handle_update_group(int.parse(group_id) |> result.unwrap(0), req, ctx)

    [group_id], http.Delete ->
      handle_delete_group(int.parse(group_id) |> result.unwrap(0), ctx)

    // TODO: implement this next
    [group_id, "invite"], http.Post -> wisp.method_not_allowed([http.Post])
    [group_id, "remove"], http.Post -> wisp.method_not_allowed([http.Post])

    _, __ -> wisp.not_found()
  }
}
