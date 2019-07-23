#' @export
equal_margins <- function(margin = ggplot2::unit(0.5, "inches")){
  list(
    ggplot2::theme_void(),
    ggplot2::theme(plot.margin = rep(margin, 4)), 
    ggplot2::scale_x_continuous(expand = c(0,0)),
    ggplot2::scale_y_continuous(expand = c(0,0)),
    ggplot2::labs(x = NULL, y = NULL))
}
