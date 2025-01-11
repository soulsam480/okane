import filepath
import filespy
import gleam/list
import gleam/string
import tailwind
import wisp

fn input_file() {
  filepath.join("/Users/sambitsahoo", "/projects/okane/src/app/css/app.css")
}

fn output_file() {
  filepath.join("/Users/sambitsahoo", "/projects/okane/priv/ui/css/index.css")
}

pub fn build() {
  wisp.log_info("[HOT CSS]: starting tailwind build....")

  let assert Ok(_) =
    [
      "--minify",
      "--config=tailwind.config.js",
      "--input=" <> input_file(),
      "--output=" <> output_file(),
    ]
    |> tailwind.run()

  wisp.log_info("[HOT CSS]: done building css with tailwind.")
}

pub fn start() {
  // 1. build tailwind on start
  build()

  // 2. watch and rebuild on further changes
  let _ =
    filespy.new()
    |> filespy.add_dir(filepath.join(
      "/Users/sambitsahoo",
      "/projects/okane/src/app/css",
    ))
    |> filespy.add_dir(filepath.join(
      "/Users/sambitsahoo",
      "/projects/okane/priv/ui",
    ))
    |> filespy.set_handler(fn(path, event) {
      let is_path =
        !string.ends_with(path, "index.css")
        && {
          [".gleam", ".css", ".html", ".js"]
          |> list.any(fn(el) { string.ends_with(path, el) })
        }

      case event {
        filespy.Closed | filespy.Closed -> {
          case is_path {
            True -> build()
            _ -> Nil
          }
        }
        _ -> Nil
      }

      Nil
    })
    |> filespy.start()

  Nil
}
