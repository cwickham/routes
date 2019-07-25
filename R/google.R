#' Get Google Maps API Key
#' 
#' Looks for API key in environment variable `"GOOGLE_API_KEY"`
#' 
#' routes assumes you have a Google API key stored in the environment variable 
#' `GOOGLE_API_KEY`.  First, get an [API key from google](https://developers.google.com/maps/documentation/streetview/get-api-key), 
#' then run:
#' ```{r, eval = FALSE}
#' usethis::edit_r_environ()
#' ```
#' to open your `.Renviron` file and add a line of the form:
#'  ```
#' GOOGLE_API_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
#' ```
maps_api_key <- function(){
  key <- Sys.getenv("GOOGLE_API_KEY")
  if (key == ""){
    stop("No google API key found.  See `?maps_api_key` for help.", call. = FALSE)
  }
  key
}

# From: https://gist.github.com/cwickham/1ea84d1db2226722bb0c
# Originally by: https://gist.github.com/diegovalle/916889 
# Google polyline decoder borrowed from:
# http://facstaff.unca.edu/mcmcclur/GoogleMaps/EncodePolyline/decode.js
DecodeLineR <- function(encoded) {
  len <- stringr::str_length(encoded)
  encoded <- strsplit(encoded, NULL)[[1]]
  index <- 1
  N <- 100000
  df.index <- 1
  array <- matrix(nrow = N, ncol = 2)
  lat  <- 0
  dlat <- 0
  lng  <- 0
  dlng  <- 0
  b  <- 0
  shift  <- 0
  result  <- 0
  
  while(index <= len) {
    shift <- 0
    result <- 0
    
    repeat {
      b <- as.integer(charToRaw(encoded[index])) - 63
      index <- index + 1
      result <- bitops::bitOr(result, bitops::bitShiftL(bitops::bitAnd(b, 0x1f), shift))
      shift <- shift + 5
      if(b < 0x20) break
    }
    dlat = ifelse(bitops::bitAnd(result, 1),
      -(result - (bitops::bitShiftR(result, 1))),
      bitops::bitShiftR(result, 1))
    lat <- lat + dlat;
    
    shift <- 0
    result <- 0
    b <- 0
    repeat {
      b <- as.integer(charToRaw(encoded[index])) - 63
      index <- index + 1
      result <- bitops::bitOr(result, bitops::bitShiftL(bitops::bitAnd(b, 0x1f), shift))
      shift <- shift + 5
      if(b < 0x20) break
    }
    dlng <- ifelse(bitops::bitAnd(result, 1),
      -(result - (bitops::bitShiftR(result, 1))),
      bitops::bitShiftR(result, 1))
    lng <- lng + dlng
    
    array[df.index,] <- c(lat = lat * 1e-05, lng = lng * 1e-5)
    df.index <- df.index + 1
  }
  
  ret <- data.frame(array[1:df.index - 1,])
  names(ret) <- c("lat", "lon")
  return(ret)
}


#' Get route from Google Directions API
#' 
#' Coordinates of a route from two locations from the Google Directions API.  
#' 
#' The coordinates match instructions in the route and they will not 
#' be equispaced along the route.
#'
#' @param from Character string for start of route: "The address, textual latitude/longitude 
#' value, or place ID from which you wish to calculate directions".
#' @param to Character string for end of route
#' @param api_key Character string of your API key.  By default, looks for 
#' `GOOGLE_API_KEY` environment variable, see [maps_api_key()].
#' @param ... Other parameters passed to the 
#' [Directions API](https://developers.google.com/maps/documentation/directions/intro)
#'
#' @return tibble with `lat`, `lon` and `order` columns for each step in the 
#' route.
#' @export
#'
#' @examples
#' \dontrun{
#' get_route("Corvallis, OR", "Portland, OR")
#' get_route("37.2341762,-112.8726299", "37.2174425,-112.973322")
#' }
get_route <- function(from, to, api_key = maps_api_key(), ...){
  dir_json <- httr::GET("https://maps.googleapis.com/maps/api/directions/json?",
    query = list(origin = from, destination = to,
      key = maps_api_key(), ...))
  
  httr::stop_for_status(dir_json)
  
  route_points_string <- httr::content(dir_json)$routes[[1]]$overview_polyline$points
  
  DecodeLineR(route_points_string) %>% 
    dplyr::mutate(order = dplyr::row_number()) %>% 
    tibble::as_tibble()
}


#' Get Street View image from Google Street View API
#'
#' Download Street View image at given latitude, longitude location.
#'
#' See the [Google Street View Static API Docs](https://developers.google.com/maps/documentation/streetview/intro#url_parameters)
#' for more info on available parameters.
#' 
#' @param lat latitude 
#' @param lon longitude
#' @param dir path to directory image should be downloaded to
#' @param api_key Character string of your API key.  By default, looks for 
#' `GOOGLE_API_KEY` environment variable, see [maps_api_key()].
#' @param size dimensions in pixels of file to download as a string, e.g. "100x100"
#' @param suffix string to be appended to the end of the file name
#' @param ... other parameters passed along to the Google Street View Static API, 
#' e.g. heading, pitch.
#'
#' @return file path of downloaded file, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' img <- get_img(lat = 37.2341762, lon = -112.8726299, dir = tempdir())
#' display_jpeg(img)
#' }
get_img <- function(lat, lon, dir, api_key = maps_api_key(), size = "100x100", suffix = "", ...){
  file_name <- paste0(lat, "_", lon, suffix, ".jpg")
  file_path <- fs::path(dir, file_name)
  
  # Don't re-request if I already have it
  if(file.exists(file_path)){
    return(invisible(file_path))
  }
  
  base_url <- "http://maps.googleapis.com/maps/api/streetview"
  r <- httr::GET(base_url, 
    query = list(
      size = size, 
      location = paste(lat, lon, sep = ","), 
      key = api_key, 
      ...))
  
  httr::stop_for_status(r)
  bin <- httr::content(r, "raw")
  writeBin(bin, file_path)
  invisible(file_path)
}