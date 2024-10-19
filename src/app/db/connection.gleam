import cake
import cake/dialect/sqlite_dialect as sqlite
import cake/param.{
  type Param, BoolParam, FloatParam, IntParam, NullParam, StringParam,
}
import dot_env/env
import gleam/list
import sqlight

pub fn get_db_path() -> String {
  env.get_string_or("DATABASE", ":memory:")
}

pub fn with_connection(conn_fn: fn(sqlight.Connection) -> t) -> t {
  let connection = sqlight.with_connection(get_db_path(), conn_fn)

  connection
}

pub fn run_query_with(
  query: cake.CakeQuery(a),
  db_conn: sqlight.Connection,
  model_decoder dcdr,
) {
  let prp_stm = sqlite.cake_query_to_prepared_statement(query)
  let sql = cake.get_sql(prp_stm)
  let params = cake.get_params(prp_stm)

  let db_params =
    params
    |> list.map(fn(param: Param) -> sqlight.Value {
      case param {
        BoolParam(param) -> sqlight.bool(param)
        FloatParam(param) -> sqlight.float(param)
        IntParam(param) -> sqlight.int(param)
        StringParam(param) -> sqlight.text(param)
        NullParam -> sqlight.null()
      }
    })

  sql |> sqlight.query(on: db_conn, with: db_params, expecting: dcdr)
}
