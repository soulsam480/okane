import birl
import cake/insert
import gleam/list

pub const created_at_column_name = "created_at"

/// this helper adds created at column to the end of the insert payload
/// also needs the created_at column name constant to be used alongside
pub fn with_created_at_param(
  params: List(insert.InsertValue),
) -> List(insert.InsertValue) {
  params |> list.append([birl.now() |> birl.to_iso8601 |> insert.string])
}

/// this helper adds created at column to column names list
pub fn with_created_at_column(columns: List(String)) -> List(String) {
  columns |> list.append([created_at_column_name])
}
