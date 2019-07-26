#' Setup directory and file for generating a route
#' 
#' The first step in creating a new route landscape.  
#' @param from address, or latitude and longitude of the start of the route.
#' @param to address, or latitude and longitude of the end of the route.
#' @param shortname string suitable for use as directory name and in file names.
#' @return Called for it's side effects only. Creates a directory called 
#'  `shortname`, creates a file in this directory
#'  called `00-setup.R` populated with a template.  
#' @export
setup <- function(from, to, shortname = paste0(from, "_", to)){
  path <- fs::path(shortname)
  usethis::use_directory(path)
  
  usethis::use_template(
    template = "setup.R",
    save_as = fs::path(path, "00-setup.R"),
    data = list(to = to, from = from, shortname = shortname),
    package = "routes",
    open = TRUE)
}

#' Generate template for getting coordinates for route
#'
#' @param from address, or latitude and longitude of the start of the route.
#' @param to address, or latitude and longitude of the end of the route.
#' @param shortname string suitable for use as directory name and in file names.
#'
#' @export
route <- function(from, to, shortname = paste0(from, "_", to)){
  path <- fs::path(shortname)
  usethis::use_directory(fs::path(path, "data"))
  
  usethis::use_template(
    template = "route.Rmd",
    save_as = fs::path(path, "01-route.Rmd"),
    data = list(to = to, from = from, shortname = shortname),
    package = "routes",
    open = TRUE)
}


#' Generate template for getting street view images
#'
#' @param from address, or latitude and longitude of the start of the route.
#' @param to address, or latitude and longitude of the end of the route.
#' @param shortname string suitable for use as directory name and in file names.
#' @export
streetview <- function(from, to, shortname = paste0(from, "_", to)){
  path <- fs::path(shortname)
  usethis::use_directory(fs::path(path, "images"))
  usethis::use_git_ignore("*.jpg", directory = fs::path(path, "images"))
  
  usethis::use_template(
    template = "streetview.Rmd",
    save_as = fs::path(path, "02-streetview.Rmd"),
    data = list(to = to, from = from, shortname = shortname),
    package = "routes",
    open = TRUE)
}

#' Generate template for clustering, counting and plotting colors
#' @param from address, or latitude and longitude of the start of the route.
#' @param to address, or latitude and longitude of the end of the route.
#' @param shortname string suitable for use as directory name and in file names.
#' @export
cluster <- function(from, to, shortname = paste0(from, "_", to)){
  path <- fs::path(shortname)
  
  usethis::use_template(
    template = "cluster.Rmd",
    save_as = fs::path(path, "03-cluster.Rmd"),
    data = list(to = to, from = from, shortname = shortname),
    package = "routes",
    open = TRUE)
}

