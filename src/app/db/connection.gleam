import cake
import cake/dialect/sqlite_dialect as sqlite
import cake/param.{
  type Param, BoolParam, FloatParam, IntParam, NullParam, StringParam,
}
import dot_env/env
import gleam/io
import gleam/list
import gleam/string
import sqlight

// ============= private ============

fn tap_debug(v: a, str: String) -> a {
  str |> io.print
  io.debug(v)
}

fn tap_println(v: a) -> a {
  v |> string.inspect |> io.println
  v
}

// ============= private ============

pub fn get_db_path() -> String {
  env.get_string_or("DATABASE", ":memory:")
}

pub fn with_connection(run: fn(sqlight.Connection) -> t) -> t {
  sqlight.with_connection(get_db_path(), run)
}

pub fn run_query_with(
  query: cake.CakeQuery(a),
  db_conn: sqlight.Connection,
  model_decoder dcdr,
) {
  io.println("---- query start ----")

  let prp_stm = sqlite.cake_query_to_prepared_statement(query)
  let sql = cake.get_sql(prp_stm) |> tap_println
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
    |> tap_debug("with params:: ")

  sql |> sqlight.query(on: db_conn, with: db_params, expecting: dcdr)
}
