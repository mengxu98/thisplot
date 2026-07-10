#' @title Set major grid lines on a ggplot
#'
#' @description
#' Add or remove major grid lines from a ggplot object.
#'
#' @md
#' @param plot A ggplot object.
#' @param grid_major Whether to show major grid lines. Default is `TRUE`.
#' @param grid_major_colour Grid line colour. Default is `"grey80"`.
#' @param grid_major_linetype Grid line type. Default is `2` (dashed).
#' @param grid_major_linewidth Grid line width. Default is `0.3`.
#'
#' @return A ggplot object with modified `panel.grid.major` theme element.
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
#' major_grid(p, grid_major = TRUE)
major_grid <- function(
  plot,
  grid_major = TRUE,
  grid_major_colour = "grey80",
  grid_major_linetype = 2,
  grid_major_linewidth = 0.3
) {
  grid_major_element <- if (isTRUE(grid_major)) {
    ggplot2::element_line(
      colour = grid_major_colour,
      linetype = grid_major_linetype,
      linewidth = grid_major_linewidth
    )
  } else {
    ggplot2::element_blank()
  }
  plot + ggplot2::theme(panel.grid.major = grid_major_element)
}
