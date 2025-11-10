#' @title Slim unused data in the plot
#'
#' @description
#' Remove unused columns from the data in a ggplot or patchwork object.
#' This function keeps only the columns that are actually used in the plot
#' (e.g., in mappings, aesthetics, or facets), which can significantly reduce
#' the object size when the original data contains many unused columns.
#'
#' @md
#' @param p A `ggplot` object or a `patchwork` object.
#'
#' @return A `ggplot` or `patchwork` object with unused data columns removed.
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(
#'   data = mtcars,
#'   aes(x = mpg, y = wt, colour = cyl)
#' ) +
#'   geom_point()
#' object.size(p)
#' colnames(p$data)
#'
#' p_slim <- slim_data(p)
#' object.size(p_slim)
#' colnames(p_slim$data)
slim_data <- function(p) {
  UseMethod(generic = "slim_data", object = p)
}

#' @export
#' @rdname slim_data
#' @method slim_data ggplot
slim_data.ggplot <- function(p) {
  vars <- get_vars(p)
  if (length(vars) > 0) {
    p$data <- p$data[, intersect(colnames(p$data), vars), drop = FALSE]
    for (i in seq_along(p$layers)) {
      if (length(p$layers[[i]]$data) > 0) {
        ids <- intersect(colnames(p$layers[[i]]$data), vars)
        p$layers[[i]]$data <- p$layers[[i]]$data[, ids, drop = FALSE]
      }
    }
  }
  return(p)
}

#' @export
#' @rdname slim_data
#' @method slim_data patchwork
slim_data.patchwork <- function(p) {
  for (i in seq_along(p$patches$plots)) {
    p$patches$plots[[i]] <- slim_data(p$patches$plots[[i]])
  }
  p <- slim_data.ggplot(p)
  return(p)
}

#' @export
#' @method slim_data default
slim_data.default <- function(p) {
  return(p)
}
