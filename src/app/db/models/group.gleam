import app/db/connection
import app/db/models/helpers
import app/lib/generic_error
import birl
import cake
import cake/insert
import cake/select
import cake/update
import cake/where
import decode/zero
import gleam/dynamic
import gleam/option.{type Option}
import gleam/result
import sqlight

// 1. record
pub type Group {
  Group(
    id: Int,
    name: String,
    owner_id: Int,
    created_at: String,
    deleted_at: Option(String),
  )
}

// 2. decoder

fn decode_group(row: dynamic.Dynamic) {
  let decoder = {
    use id <- zero.field(0, zero.int)
    use name <- zero.field(1, zero.string)
    use owner_id <- zero.field(2, zero.int)
    use created_at <- zero.field(3, zero.string)
    use deleted_at <- zero.field(4, zero.optional(zero.string))

    zero.success(Group(id:, name:, owner_id:, created_at:, deleted_at:))
  }

  zero.run(row, decoder)
}

// 3. select props init
fn select_group_query_init() {
  select.new()
  |> select.from_table("groups")
  |> select.selects([
    select.col("groups.id"),
    select.col("groups.name"),
    select.col("groups.owner_id"),
    select.col("groups.created_at"),
    select.col("groups.deleted_at"),
  ])
}

// 4. insertable record
pub type InsertableGroup {
  InsertableGroup(name: String, owner_id: Int)
}

// 5. insertable encoder
fn insertable_group_encoder(group: InsertableGroup) {
  [group.name |> insert.string, group.owner_id |> insert.int]
  |> helpers.with_created_at_param
  |> insert.row
}

pub fn insert_group(
  insertable group: InsertableGroup,
  connection conn: sqlight.Connection,
) {
  insert.from_records(
    records: [group],
    table_name: "groups",
    columns: ["name", "owner_id"] |> helpers.with_created_at_column,
    encoder: insertable_group_encoder,
  )
  |> insert.returning(["id", "name", "owner_id", "created_at", "deleted_at"])
  |> insert.to_query
  |> cake.to_write_query
  |> connection.run_query_with(conn, decode_group)
  |> result.map_error(fn(e) { generic_error.new(e) })
  |> helpers.first
}

pub fn find_by_id(id: Int, conn: sqlight.Connection) {
  select_group_query_init()
  |> select.where(where.col("groups.id") |> where.eq(where.int(id)))
  |> select.comment("find group by id")
  |> select.to_query
  |> cake.to_read_query
  |> connection.run_query_with(conn, decode_group)
  |> helpers.first
}

pub fn find_groups_of(user_id: Int, conn: sqlight.Connection) {
  select_group_query_init()
  |> select.where(
    where.and([
      where.col("groups.deleted_at") |> where.is_null(),
      // TODO: query where memberships has user_id = user_id
      where.or([where.col("groups.owner_id") |> where.eq(where.int(user_id))]),
    ]),
  )
  |> select.to_query
  |> cake.to_read_query
  |> connection.run_query_with(conn, decode_group)
  |> generic_error.replace
}

pub type UpdatableGroup {
  UpdateableGroup(name: String)
}

pub fn update_by_id(
  id: Int,
  updateable: UpdatableGroup,
  conn: sqlight.Connection,
) {
  update.new()
  |> update.table("groups")
  |> update.sets(["name" |> update.set_string(updateable.name)])
  |> update.where(where.col("groups.id") |> where.eq(where.int(id)))
  |> update.returning(["id", "name", "owner_id", "created_at", "deleted_at"])
  |> update.to_query
  |> cake.to_write_query
  |> connection.run_query_with(conn, decode_group)
  |> helpers.first
  |> generic_error.replace
}

pub fn discard_by_id(id: Int, conn: sqlight.Connection) {
  update.new()
  |> update.table("groups")
  |> update.where(where.col("groups.id") |> where.eq(where.int(id)))
  |> update.sets([
    "deleted_at"
    |> update.set_string(birl.now() |> birl.to_iso8601),
  ])
  |> update.returning(["id", "name", "owner_id", "created_at", "deleted_at"])
  |> update.to_query
  |> cake.to_write_query
  |> connection.run_query_with(conn, decode_group)
  |> helpers.first
  |> generic_error.replace
}
