#' @title Rasterise the layers of a plot
#'
#' @description
#' Render the point and line layers of a `ggplot` or `patchwork` object as
#' raster images, while the axes, text, legends and the remaining layers stay
#' vector. A figure with a large number of elements then stays small and quick
#' to draw, in the file and in the browser. For a `patchwork` composite the
#' sub-plots are rasterised as well, because a composite carries only the first
#' sub-plot's layers itself. The rasterisation is done by
#' [ggrastr::rasterise()].
#'
#' @md
#' @param plot A `ggplot` or `patchwork` object.
#' @param layers Layer types to rasterise, named without the `Geom` prefix, so
#' the default `"Point"` matches `geom_point()` layers. Add `"Violin"`,
#' `"Boxplot"` or `"Crossbar"` to rasterise those layers as well.
#' @param dpi Resolution of the rasterised layers, in dots per inch.
#' Default is `300`.
#' @param dev Graphic device used to render the rasterised layers, passed to
#' [ggrastr::rasterise()]. Default is `"ragg"`, which does not need X11; the
#' `"cairo"` device of the underlying package does, and is unavailable on many
#' headless machines.
#' @param recurse Whether to rasterise the sub-plots of a `patchwork`
#' composite. Default is `TRUE`.
#'
#' @return The plot object with its heavy layers rasterised. Objects that are
#' neither a `ggplot` nor a `patchwork` are returned unchanged, with a warning.
#'
#' @seealso [invert_svg()]
#'
#' @examples
#' panel <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
#'   ggplot2::geom_point() +
#'   ggplot2::facet_wrap(~cyl)
#'
#' rasterise_plot(panel)
#'
#' rasterise_plot(patchwork::wrap_plots(panel, panel), dpi = 150)
#'
#' @export
rasterise_plot <- function(
  plot,
  layers = c("Point", "Tile", "Path", "Line", "Segment"),
  dpi = 300,
  dev = "ragg",
  recurse = TRUE
) {
  if (!inherits(plot, c("ggplot", "patchwork"))) {
    log_message(
      "Object of class {.cls {class(plot)[1]}} is not a {.cls ggplot} or a {.cls patchwork}; returned unchanged.",
      message_type = "warning"
    )
    return(plot)
  }
  if (!is.numeric(dpi) || length(dpi) != 1L || is.na(dpi) || dpi <= 0) {
    log_message(
      "{.arg dpi} must be a single positive number.",
      message_type = "error"
    )
  }
  check_r("ggrastr", verbose = FALSE)

  if (
    isTRUE(recurse) &&
      inherits(plot, "patchwork") &&
      !is.null(plot$patches$plots)
  ) {
    plot$patches$plots <- lapply(
      plot$patches$plots,
      rasterise_plot,
      layers = layers,
      dpi = dpi,
      dev = dev,
      recurse = TRUE
    )
  }
  if (length(plot$layers) > 0) {
    plot <- ggrastr::rasterise(plot, layers = layers, dpi = dpi, dev = dev)
  }

  plot
}
