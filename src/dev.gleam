/// dev only scripts
import app/css/tailwind
import filepath
import gleam/list
import gleam/result
import gleam/string
import radiate
import wisp

pub fn run() -> Nil {
  tailwind.start()

  let _ =
    radiate.new()
    // |> radiate.add_dir("src")
    //TODO: handle mac
    |> radiate.add_dir(filepath.join(
      "/Users/sambitsahoo/",
      "projects/okane/src",
    ))
    |> radiate.on_reload(fn(_, path) {
      wisp.log_info(
        "[HOT RELOAD]: "
        <> path
        |> string.split("/")
        |> list.last()
        |> result.unwrap("unknown"),
      )
    })
    |> radiate.start()

  Nil
}
