#' @export
read_pixels <- function(file){
  img <- jpeg::readJPEG(file)
  
  # One pixel per row, columns are RGB
  dim(img) <- c(prod(dim(img)[1:2]), dim(img)[3])
  colnames(img) <- c("R", "G", "B")
  img
}

#' @export
sample_pixels <- function(file, sample_size = 50){
  img <- read_pixels(file)
  # Sample rows
  img[sample(1:nrow(img), size = sample_size), , drop = FALSE] %>% 
    tibble::as_tibble()
}

#' @export
pal <- function(col, border = "light gray", ...){
  n <- length(col)
  graphics::plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1),
    axes = FALSE, xlab = "", ylab = "", ...)
  graphics::rect(0:(n-1)/n, 0, 1:n/n, 1, col = col, border = border)
}

#' @export
count_colours <- function(colours, centers, colorspace){
  stopifnot(inherits(colours, "RGB"))
  colours <- methods::as(colours, colorspace)
  centers <- methods::as(centers, colorspace)
  
  centers_m <- methods::as(centers, colorspace)@coords
  colours_m <- colours@coords[stats::complete.cases(colours@coords), ]
  preds <- class::knn(centers_m, colours_m, 
    cl = 1:nrow(centers_m), k = 1)
  
  freqs <- table(preds)
  
  tibble::tibble(freq = as.numeric(freqs), hex = colorspace::hex(centers)) %>% 
    dplyr::bind_cols(tibble::as_tibble(centers@coords))
}