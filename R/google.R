# Look for API key in environment variable `"GOOGLE_API_KEY"`
maps_api_key <- function(){
  Sys.getenv("GOOGLE_API_KEY")
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

#' @export
get_route <- function(from, to, api_key = maps_api_key(), ...){
  dir_json <- httr::GET("https://maps.googleapis.com/maps/api/directions/json?",
    query = list(origin = start, destination = end,
      key = maps_api_key(), ...))
  
  httr::stop_for_status(dir_json)
  
  route_points_string <- httr::content(dir_json)$routes[[1]]$overview_polyline$points
  
  DecodeLineR(route_points_string) %>% 
    dplyr::mutate(order = row_number())
}

#' @export
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