#' @title Plot three-dimensional scatter data
#'
#' @description
#' Draw interactive three-dimensional points with optional highlights.
#'
#' @md
#' @param data A data frame containing numeric coordinate columns.
#' @param x,y,z Single column names for the three coordinates. Defaults are
#'   `"x"`, `"y"`, and `"z"`.
#' @param text Optional hover text for the observations.
#' @param color Optional values passed to Plotly's categorical colour mapping.
#' @param colors Optional colours for that mapping.
#' @param marker A Plotly marker list. Default `list(size = 1.5)`. Continuous
#'   colours and their colourbar can be supplied through this list.
#' @param name Optional name of the main trace.
#' @param highlight An optional data frame with the same coordinate columns.
#'   A non-NULL, zero-row data frame still creates a highlight trace.
#' @param highlight_text Optional hover text for highlighted observations.
#' @param highlight_marker A Plotly marker list for highlights. The default uses
#'   black open circles of size `2`.
#' @param title A Plotly title string or title list. Default `NULL`.
#' @param xlab,ylab,zlab Axis titles. Defaults are the coordinate column names.
#' @param legend A Plotly legend list. Default `list()`.
#' @param font An optional Plotly font list. Default `NULL`.
#' @param width,height Optional widget dimensions in pixels.
#' @return A Plotly htmlwidget. Add traces with [plotly::add_trace()] or change
#'   its layout with [plotly::layout()].
#' @seealso [plot_scatter()], [DimDataPlot()]
#' @export
#' @examples
#' points <- data.frame(
#'   x = c(0, 1, 2, 0, 1, 2),
#'   y = c(0, 0.5, 0, 1, 1.5, 1),
#'   z = c(0, 0.5, 1, 1.5, 2, 2.5),
#'   group = factor(rep(c("A", "B"), each = 3)),
#'   value = seq_len(6)
#' )
#' plot_scatter3d(
#'   points,
#'   color = points$group,
#'   colors = palette_colors(x = c("A", "B"), palette = "Chinese")
#' )
#' plot_scatter3d(
#'   points,
#'   marker = list(color = points$value, size = 3, showscale = TRUE),
#'   highlight = points[c(1, 5), ],
#'   title = "Continuous values with highlighted observations"
#' )
plot_scatter3d <- function(
  data,
  x = "x",
  y = "y",
  z = "z",
  text = NULL,
  color = NULL,
  colors = NULL,
  marker = list(size = 1.5),
  name = NULL,
  highlight = NULL,
  highlight_text = NULL,
  highlight_marker = list(size = 2, color = "black", symbol = "circle-open"),
  title = NULL,
  xlab = x,
  ylab = y,
  zlab = z,
  legend = list(),
  font = NULL,
  width = NULL,
  height = NULL
) {
  if (!all(vapply(list(x, y, z), function(column) {
    is.character(column) && length(column) == 1L && !is.na(column)
  }, logical(1)))) {
    thisutils::log_message(
      "{.arg x}, {.arg y}, and {.arg z} must each name one coordinate column",
      message_type = "error"
    )
  }
  coordinates <- c(x, y, z)
  frames <- list(data = data)
  if (!is.null(highlight)) {
    frames$highlight <- highlight
  }
  for (argument in names(frames)) {
    frame <- frames[[argument]]
    if (
      !is.data.frame(frame) || !all(coordinates %in% names(frame)) ||
        !all(vapply(frame[coordinates], is.numeric, logical(1)))
    ) {
      thisutils::log_message(
        "{.arg {argument}} must be a data frame with numeric coordinate columns named by {.arg x}, {.arg y}, and {.arg z}",
        message_type = "error"
      )
    }
  }
  thisutils::check_r("plotly", verbose = FALSE)
  plot_ly <- thisutils::get_namespace_fun("plotly", "plot_ly")
  add_trace <- thisutils::get_namespace_fun("plotly", "add_trace")
  layout <- thisutils::get_namespace_fun("plotly", "layout")

  p <- plot_ly(data = data, width = width, height = height)
  trace <- list(
    p = p,
    data = data,
    x = data[[x]],
    y = data[[y]],
    z = data[[z]],
    text = text,
    type = "scatter3d",
    mode = "markers"
  )
  if (!is.null(color)) {
    trace$color <- color
  }
  if (!is.null(colors)) {
    trace$colors <- colors
  }
  trace$marker <- marker
  if (!is.null(name)) {
    trace$name <- name
  }
  trace$showlegend <- TRUE
  trace$visible <- TRUE
  p <- do.call(add_trace, trace)
  if (!is.null(highlight)) {
    p <- add_trace(
      p = p,
      x = highlight[[x]],
      y = highlight[[y]],
      z = highlight[[z]],
      text = highlight_text,
      type = "scatter3d",
      mode = "markers",
      marker = highlight_marker,
      name = "highlight",
      showlegend = TRUE,
      visible = TRUE
    )
  }
  scene <- list()
  labels <- list(xlab, ylab, zlab)
  for (i in seq_along(coordinates)) {
    values <- data[[coordinates[i]]]
    scene[[paste0(c("x", "y", "z")[i], "axis")]] <- list(
      title = labels[[i]],
      range = c(min(values, na.rm = TRUE), max(values, na.rm = TRUE))
    )
  }
  scene$aspectratio <- list(x = 1, y = 1, z = 1)
  layout_args <- list(p = p, title = title)
  if (!is.null(font)) {
    layout_args$font <- font
  }
  layout_args <- c(layout_args, list(
    showlegend = TRUE,
    legend = legend,
    scene = scene,
    autosize = FALSE
  ))
  do.call(layout, layout_args)
}
