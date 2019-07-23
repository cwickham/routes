#' @export
setup <- function(from, to, shortname = paste0(from, "_", to)){
  path <- fs::path("routes", shortname)
  usethis::use_directory(path)
  
  usethis::use_template(
    template = "setup.R",
    save_as = fs::path(path, "00-setup.R"),
    data = list(to = to, from = from, shortname = shortname),
    package = "routes2019",
    open = TRUE)
}

#' Generate template for getting coordinates for route
#'
#' @export
route <- function(from, to, shortname = paste0(from, "_", to)){
  path <- fs::path("routes", shortname)
  
  usethis::use_template(
    template = "route.Rmd",
    save_as = fs::path(path, "01-route.Rmd"),
    data = list(to = to, from = from, shortname = shortname),
    package = "routes2019",
    open = TRUE)
}


#' Generate template for getting streetview images
#'
#' @export
streetview <- function(from, to, shortname = paste0(from, "_", to)){
  path <- fs::path("routes", shortname)
  usethis::use_directory(fs::path(path, "images"))
  
  usethis::use_template(
    template = "streetview.Rmd",
    save_as = fs::path(path, "02-streetview.Rmd"),
    data = list(to = to, from = from, shortname = shortname),
    package = "routes2019",
    open = TRUE)
}

#' Generate template for clsutering, counting and plotting colors
#'
#' @export
cluster <- function(from, to, shortname = paste0(from, "_", to)){
  path <- fs::path("routes", shortname)
  
  usethis::use_template(
    template = "cluster.Rmd",
    save_as = fs::path(path, "03-cluster.Rmd"),
    data = list(to = to, from = from, shortname = shortname),
    package = "routes2019",
    open = TRUE)
}

