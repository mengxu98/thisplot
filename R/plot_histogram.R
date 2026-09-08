#' @title Histogram plot
#'
#' @description
#' Plot a numeric vector as a histogram with `theme_this` and thisplot palettes.
#'
#' @md
#' @param data A numeric vector.
#' @param binwidth Width of the bins.
#' @param show_border Whether to show bin borders.
#' @param border_color Color of the bin borders.
#' @param alpha Transparency of the bins.
#' @param palette Palette name used to fill bins by count. See [show_palettes].
#' @param palcolor Custom colors used to create a color palette.
#' @param xlab,ylab Axis titles.
#' @param legend.position Legend position.
#' @param theme_use Theme function applied to the plot.
#' @param theme_args A named list of arguments passed to `theme_use`.
#'
#' @return A ggplot object.
#'
#' @export
#'
#' @examples
#' set.seed(1)
#' plot_histogram(rnorm(500), binwidth = 0.2)
plot_histogram <- function(
  data,
  binwidth = 0.01,
  show_border = FALSE,
  border_color = "black",
  alpha = 1,
  palette = "viridis",
  palcolor = NULL,
  xlab = "Value",
  ylab = "Count",
  legend.position = "right",
  theme_use = "theme_this",
  theme_args = list()
) {
  values <- suppressWarnings(as.numeric(data))
  values <- values[is.finite(values)]
  if (length(values) == 0L) {
    log_message(
      "{.arg data} must contain finite numeric values",
      message_type = "error"
    )
  }
  plot_data <- data.frame(value = values)
  fill_colors <- palette_colors(palette = palette, palcolor = palcolor, n = 100)
  theme_fun <- if (is.function(theme_use)) {
    theme_use
  } else {
    get(theme_use, mode = "function", inherits = TRUE)
  }
  ggplot(plot_data, aes(x = .data$value)) +
    geom_histogram(
      aes(fill = after_stat(count)),
      binwidth = binwidth,
      color = if (isTRUE(show_border)) border_color else NA,
      alpha = alpha
    ) +
    scale_fill_gradientn(colours = fill_colors, name = ylab) +
    labs(x = xlab, y = ylab) +
    do.call(theme_fun, theme_args) +
    theme(legend.position = legend.position)
}
