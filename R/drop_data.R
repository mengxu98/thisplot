#' @title Drop unused data in the plot
#'
#' @description
#' Drop unused data points from a ggplot or patchwork object while preserving
#' the plot structure. This function keeps only a single row of data for each
#' unique combination of used variables, which can significantly reduce the
#' object size when the original data contains many rows that are not displayed
#' in the plot (e.g., due to scale limits or filtering).
#'
#' @md
#' @param p A `ggplot` object or a `patchwork` object.
#'
#' @return A `ggplot` or `patchwork` object with unused data points removed.
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#' library(patchwork)
#' p <- ggplot(
#'   data = mtcars,
#'   aes(x = mpg, y = wt, colour = cyl)
#' ) +
#'   geom_point() +
#'   scale_x_continuous(limits = c(10, 30)) +
#'   scale_y_continuous(limits = c(1, 6))
#' object.size(p)
#'
#' p_drop <- drop_data(p)
#' object.size(p_drop)
#'
#' p / p_drop
drop_data <- function(p) {
  UseMethod(generic = "drop_data", object = p)
}

plot_clone <- function(plot) {
  p <- plot
  p@scales <- plot@scales$clone()
  p
}

#' @export
#' @rdname drop_data
#' @method drop_data ggplot
drop_data.ggplot <- function(p) {
  p <- plot_clone(p)

  # fix the scales for x/y axis and 'fill', 'color', 'shape',...
  for (i in seq_along(p$scales$scales)) {
    if (inherits(p$scales$scales[[i]], "ScaleDiscrete")) {
      p$scales$scales[[i]][["drop"]] <- FALSE
    }
    if (inherits(p$scales$scales[[i]], "ScaleContinuous")) {
      limits <- p$scales$scales[[i]]$get_limits()
      if (p$scales$scales[[i]]$aesthetics[1] == "x") {
        p$coordinates$limits$x <- limits
      }
      if (p$scales$scales[[i]]$aesthetics[1] == "y") {
        p$coordinates$limits$y <- limits
      }
    }
  }

  vars <- get_vars(p, verbose = FALSE)
  if (length(p$data) > 0) {
    vars_modified <- names(
      which(
        sapply(
          p$data[, intersect(colnames(p$data), vars), drop = FALSE], class
        ) == "character"
      )
    )
    for (v in vars_modified) {
      p$data[[v]] <- as.factor(p$data[[v]])
    }
    p$data <- p$data[1, , drop = FALSE]
  }

  for (i in seq_along(p$layers)) {
    if (length(p$layers[[i]]$data) > 0) {
      vars_modified <- names(
        which(
          sapply(
            p$layers[[i]]$data[, intersect(colnames(p$layers[[i]]$data), vars), drop = FALSE], class
          ) == "character"
        )
      )
      for (v in vars_modified) {
        p$layers[[i]]$data[[v]] <- as.factor(p$layers[[i]]$data[[v]])
      }
      p$layers[[i]]$data <- p$layers[[i]]$data[1, , drop = FALSE]
    }
  }

  return(p)
}

#' @export
#' @rdname drop_data
#' @method drop_data patchwork
drop_data.patchwork <- function(p) {
  for (i in seq_along(p$patches$plots)) {
    p$patches$plots[[i]] <- drop_data(p$patches$plots[[i]])
  }
  drop_data.ggplot(p)
}

#' @export
#' @rdname drop_data
#' @method drop_data default
drop_data.default <- function(p) {
  p
}
