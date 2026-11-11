#' @title Draw scatter point layers
#'
#' @description
#' Draw vector or raster points with optional outlines.
#'
#' @md
#' @param data A data frame, or `NULL` to inherit the plot data.
#' @param mapping A ggplot2 aesthetic mapping containing x and y coordinates
#'   and optional point colours. Defaults to `NULL` to inherit the plot mapping.
#' @param pt.size Numeric vector point size. Default `1`.
#' @param pt.alpha Numeric point transparency. Default `1`.
#' @param raster Whether to use scattermore raster points. Default `FALSE`.
#' @param raster.pt.size Numeric raster point size in pixels. Defaults to `pt.size`.
#' @param raster.dpi Two positive finite raster dimensions, or `NULL`.
#'   Default `c(512, 512)`.
#' @param color Optional fixed point colour. Omit it to retain mapped colours.
#' @param stroke Numeric vector point stroke width. Default `0`; `NULL` uses
#'   the ggplot2 default.
#' @param outline Whether to draw a larger point beneath each foreground point.
#'   Default `FALSE`.
#' @param outline.color Outline point colour. Default `"black"`.
#' @param outline.stroke Extra size added to outline points. Default `0.5`.
#' @return A list containing one ggplot2 point layer, or two layers when
#'   `outline = TRUE`. Add the list to a ggplot with `+`.
#' @export
#' @examples
#' observations <- data.frame(
#'   x = c(0, 1, 2, 0.5, 1.5), y = c(0, 1, 0, 1.5, 1.5),
#'   value = c(1, 2, 3, 2, 1)
#' )
#' ggplot2::ggplot(observations) +
#'   scatter_layers(mapping = ggplot2::aes(x, y, color = value), pt.size = 3) +
#'   scatter_layers(
#'     data = observations[c(2, 4), ],
#'     mapping = ggplot2::aes(x, y, color = value),
#'     pt.size = 4, stroke = NULL, outline = TRUE
#'   ) +
#'   theme_this()
scatter_layers <- function(
  data = NULL,
  mapping = NULL,
  pt.size = 1,
  pt.alpha = 1,
  raster = FALSE,
  raster.pt.size = pt.size,
  raster.dpi = c(512, 512),
  color = NULL,
  stroke = 0,
  outline = FALSE,
  outline.color = "black",
  outline.stroke = 0.5
) {
  if (!is.logical(raster) || length(raster) != 1L || is.na(raster)) {
    thisutils::log_message("{.arg raster} must be TRUE or FALSE", message_type = "error")
  }
  if (!is.logical(outline) || length(outline) != 1L || is.na(outline)) {
    thisutils::log_message("{.arg outline} must be TRUE or FALSE", message_type = "error")
  }
  args <- list(data = data, mapping = mapping)
  if (raster) {
    if (
      !is.null(raster.dpi) &&
        (!is.numeric(raster.dpi) || length(raster.dpi) != 2L ||
          anyNA(raster.dpi) || any(!is.finite(raster.dpi)) || any(raster.dpi <= 0))
    ) {
      thisutils::log_message(
        "{.arg raster.dpi} must contain two positive finite numbers or NULL",
        message_type = "error"
      )
    }
    thisutils::check_r("scattermore", verbose = FALSE)
    geom <- thisutils::get_namespace_fun("scattermore", "geom_scattermore")
  } else {
    geom <- ggplot2::geom_point
    args$shape <- "circle"
  }
  if (!missing(color)) {
    args["color"] <- list(color)
  }
  size_name <- if (raster) "pointsize" else "size"
  args[[size_name]] <- if (raster) raster.pt.size else pt.size
  if (!raster && !is.null(stroke)) {
    args$stroke <- stroke
  }
  args$alpha <- pt.alpha
  if (raster) {
    args["pixels"] <- list(raster.dpi)
  }
  foreground <- do.call(geom, args)
  if (!outline) {
    return(list(foreground))
  }
  args["mapping"] <- list(if (is.null(mapping)) {
    NULL
  } else {
    ggplot2::aes(x = !!mapping$x, y = !!mapping$y)
  })
  if ("color" %in% names(args)) {
    args["color"] <- list(outline.color)
  } else {
    args <- append(args, list(color = outline.color), after = if (raster) 2L else 3L)
  }
  args[[size_name]] <-
    if (raster) raster.pt.size + outline.stroke else pt.size + outline.stroke
  list(do.call(geom, args), foreground)
}
