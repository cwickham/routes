.onAttach <- function(...) {
  version <- utils::packageVersion("routes")
  packageStartupMessage("Attaching routes version ", version)
}