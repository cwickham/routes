#' Read pixels from JPEG
#'
#' Reads pixels from a JPEG file into a matrix with RGB columns
#'
#' @param file path to JPEG file
#'
#' @return matrix with three columns, R, G and B, and as many rows as there are 
#' pixels in the JPEG.
#' @export
#'
#' @examples
#' example_jpg <- system.file("extdata", "example.JPG", package = "routes")
#' read_pixels(example_jpg)
read_pixels <- function(file){
  img <- jpeg::readJPEG(file)
  
  # One pixel per row, columns are RGB
  dim(img) <- c(prod(dim(img)[1:2]), dim(img)[3])
  colnames(img) <- c("R", "G", "B")
  img
}

#' Display JPEG in graphics device
#'
#' A way to quickly check the contents of a JPEG file on disk.
#'
#' @param file path to JPEG file
#'
#' @return Invisibly the native JPEG object.
#' 
#' @export
#'
#' @examples
#' example_jpg <- system.file("extdata", "example.JPG", package = "routes")
#' display_jpeg(example_jpg)
display_jpeg <- function(file){
  img <- jpeg::readJPEG(file, native = TRUE)
  graphics::plot(1:ncol(img), 1:nrow(img), type = 'n', axes = FALSE, 
    xlab = "", ylab = "", asp = nrow(img)/ncol(img))
  graphics::rasterImage(img, 1, 1, ncol(img), nrow(img))
  invisible(img)
}


#' Sample pixels from a JPEG file
#' 
#' Takes a simple random sample of `sample_size` pixels from a JPEG file.
#'
#' @param file path to JPEG file
#' @param sample_size Number of pixels to sample
#'
#' @return tibble with `sample_size` rows, and columns R, G and B
#' @export
#'
#' @examples
#' example_jpg <- system.file("extdata", "example.JPG", package = "routes")
#' set.seed(4891)
#' sample_pixels(example_jpg, 10)
#' sample_pixels(example_jpg, 10) %>% 
#'   with(colorspace::RGB(R, G, B)) %>% 
#'   colorspace::hex() %>% 
#'   pal()
sample_pixels <- function(file, sample_size = 50){
  img <- read_pixels(file)
  # Sample rows
  img[sample(1:nrow(img), size = sample_size), , drop = FALSE] %>% 
    tibble::as_tibble()
}


#' Plot a palette of colors
#' 
#' Plot colors, `col`, as a single row of swatches.
#'
#' @param col character vector of hex color codes
#' @param border color for border around swatches 
#' @param ... additional arguments passed to `plot()`
#'
#' @export
#'
#' @examples
#' pal(c("#8FA5DB", "#AB9F83", "#95B9E5"))
pal <- function(col, border = "light gray", ...){
  n <- length(col)
  graphics::plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1),
    axes = FALSE, xlab = "", ylab = "", ...)
  graphics::rect(0:(n-1)/n, 0, 1:n/n, 1, col = col, border = border)
}


#' Count colors based on proximity to centers
#' 
#' Colors in `colors` are binned to the closest colors in `centers` based 
#' on Euclidean distance in the color space provided in `colorspace`.  These 
#' are then tabulated to give the number of pixels of each color in `centers`.
#'
#' @param colors colors to be tabulated as a [colorspace::color-class] object, 
#' e.g. [colorspace::RGB].
#' @param centers colors to be used for binning as a [colorspace::color-class] object, 
#' e.g. [colorspace::RGB].
#' @param colorspace string describing the colorspace in which distances should 
#' be calculated, e.g. `"RGB"`, `"LAB"`, `"LUV"`. 
#'
#' @return tibble with as many rows as `centers` with the columns `freq` and
#' `hex`, as well as columns corresponding to the dimensions of `colorspace`
#' @export
#'
#' @examples
#' example_jpg <- system.file("extdata", "example.JPG", package = "routes")
#' read_pixels(example_jpg) %>% 
#'   colorspace::RGB() %>%
#'   count_colors(centers = colorspace::RGB(c(1, 0, 0), c(0, 1, 0),  c(0, 0, 1)),
#'     colorspace = "RGB") 
count_colors <- function(colors, centers, colorspace){
  stopifnot(inherits(colors, "RGB"))
  colors <- methods::as(colors, colorspace)
  centers <- methods::as(centers, colorspace)
  
  centers_m <- methods::as(centers, colorspace)@coords
  colors_m <- colors@coords[stats::complete.cases(colors@coords), ]
  preds <- class::knn(centers_m, colors_m, 
    cl = 1:nrow(centers_m), k = 1)
  
  freqs <- table(preds)
  
  tibble::tibble(freq = as.numeric(freqs), hex = colorspace::hex(centers)) %>% 
    dplyr::bind_cols(tibble::as_tibble(centers@coords))
}

