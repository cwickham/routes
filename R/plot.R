#' @export
equal_margins <- function(margin = unit(0.5, "inches")){
  list(
    theme_void(),
    theme(plot.margin = rep(margin, 4)), 
    scale_x_continuous(expand = c(0,0)),
    scale_y_continuous(expand = c(0,0)),
    labs(x = NULL, y = NULL))
}
