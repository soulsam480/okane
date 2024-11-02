import filespy
import gleam/list
import gleam/string
import tailwind
import wisp

pub fn build() {
  wisp.log_info("[HOT CSS]: starting tailwind build....")

  let _ =
    [
      "--config=tailwind.config.js", "--input=./src/app/css/app.css",
      "--output=./priv/ui/css/index.css",
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
    |> filespy.add_dir("./src/app/css")
    |> filespy.add_dir("./priv/ui")
    |> filespy.set_handler(fn(path, event) {
      let is_path =
        !string.ends_with(path, "index.css")
        && {
          [".gleam", ".css", ".html"]
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
