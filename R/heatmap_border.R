#' @title Normalize ComplexHeatmap border settings
#'
#' @description
#' Normalize a heatmap border flag, optional colour override, and line width
#' into values accepted by `ComplexHeatmap::Heatmap` and
#' `ComplexHeatmap::Legend`.
#'
#' @param border `NULL`, a logical border flag, or a non-empty colour string.
#' @param palcolor Fallback border colour when `border` is not a colour string.
#' @param size Border line width. Invalid or negative values use `1`.
#'
#' @return A list with `enabled`, `color`, `size`, `gp`, and `legend_border`.
#'
#' @export
heatmap_border_spec <- function(border = NULL, palcolor = "black", size = 1) {
  enabled <- !is.null(border) && !isFALSE(border)
  color <- if (is.character(border) && length(border) > 0L && nzchar(border[[1]])) {
    border[[1]]
  } else if (is.null(palcolor)) {
    "black"
  } else {
    palcolor
  }
  size <- suppressWarnings(as.numeric(size)[1])
  if (!is.finite(size) || size < 0) {
    size <- 1
  }
  list(
    enabled = enabled,
    color = color,
    size = size,
    gp = grid::gpar(col = if (isTRUE(enabled)) color else NA, lwd = size),
    legend_border = if (isTRUE(enabled)) color else FALSE
  )
}

#' @rdname heatmap_border_spec
#' @export
heatmap_border_enabled <- function(border) {
  heatmap_border_spec(border = border)$enabled
}

#' @rdname heatmap_border_spec
#' @export
heatmap_border_color <- function(border, palcolor = "black") {
  heatmap_border_spec(border = border, palcolor = palcolor)$color
}

#' @rdname heatmap_border_spec
#' @export
heatmap_border_size_value <- function(size) {
  heatmap_border_spec(size = size)$size
}

#' @rdname heatmap_border_spec
#' @export
heatmap_border_gp <- function(border, color, size = 1) {
  heatmap_border_spec(border = border, palcolor = color, size = size)$gp
}

#' @rdname heatmap_border_spec
#' @export
heatmap_legend_border <- function(border, color) {
  heatmap_border_spec(border = border, palcolor = color)$legend_border
}
