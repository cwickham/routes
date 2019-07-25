#' Set equal ggplot2 margins
#' 
#' Sets theme and scales so that the blank area around the plotting area is the
#' same width on all four sides.  
#'
#' @param margin [ggplot2::unit()] object with required margin size.
#'
#' @return list appropriate for adding directly to ggplot2 object
#' @export
#'
#' @examples
#' library(ggplot2)
#' rect <- data.frame(x = 0, y = 0)
#' p <- rect %>% 
#'   ggplot(aes(xmin = x, xmax = x + 1, ymin = y, ymax = y + 1)) +
#'     geom_rect(fill = "black")
#' p     
#' p + equal_margins()
equal_margins <- function(margin = ggplot2::unit(0.5, "inches")){
  list(
    ggplot2::theme_void(),
    ggplot2::theme(plot.margin = rep(margin, 4)), 
    ggplot2::scale_x_continuous(expand = c(0,0)),
    ggplot2::scale_y_continuous(expand = c(0,0)),
    ggplot2::labs(x = NULL, y = NULL))
}
