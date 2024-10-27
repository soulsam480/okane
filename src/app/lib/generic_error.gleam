import gleam/string

/// This defeats the whole purpose of error handling in gleam
/// but it somewhat helps with collecting all errors and then debugging
pub type GenericError {
  GenericError(message: String)
}

/// create a new generic error which has ambiguos error inside
pub fn new(a) {
  GenericError(a |> string.inspect)
}
