#' @title Scatter plot
#'
#' @description
#' Plot two- or three-column data as a scatter plot with `theme_this` and
#' thisplot palettes. Optional smoothing, correlation annotation, point density,
#' and marginal plots are available.
#'
#' @md
#' @param data A data frame with 2 columns (`x`, `y`) or 3 columns
#' (`x`, `y`, and a grouping column). Extra columns are ignored.
#' @param smoothing_method Smoothing method passed to [ggplot2::geom_smooth].
#' Can be `"lm"` or `"loess"`.
#' @param palette Palette name used for groups or point-density coloring.
#' See [show_palettes].
#' @param palcolor Custom colors used to create a color palette.
#' @param title,xlab,ylab Plot titles.
#' @param legend.title Legend title.
#' @param legend.position Legend position.
#' @param theme_use Theme function applied to the plot.
#' @param theme_args A named list of arguments passed to `theme_use`.
#' @param margins,marginal_type,margins_size Marginal plot controls used when
#' `ggExtra` is installed. `marginal_type` can be `"density"`, `"histogram"`,
#' `"boxplot"`, `"violin"`, or `"densigram"`.
#' @param compute_correlation Whether to annotate Pearson or Spearman correlation.
#' @param compute_correlation_method Correlation method: `"pearson"` or `"spearman"`.
#' @param keep_aspect_ratio Whether to use a 1:1 aspect ratio.
#' @param facet Whether to facet by the grouping column when `data` has 3 columns.
#' @param se Whether to show smoothing uncertainty.
#' @param pointdensity Whether to color ungrouped points by local density when
#' `ggpointdensity` is installed.
#'
#' @return A ggplot object, or a `ggExtra` grob when marginal plots are added.
#'
#' @export
#'
#' @examples
#' set.seed(1)
#' plot_scatter(data.frame(x = rnorm(80), y = rnorm(80)))
#' plot_scatter(
#'   data.frame(
#'     x = rnorm(80),
#'     y = rnorm(80),
#'     cluster = rep(c("A", "B"), each = 40)
#'   )
#' )
plot_scatter <- function(
  data,
  smoothing_method = c("lm", "loess"),
  palette = "Chinese",
  palcolor = NULL,
  title = NULL,
  xlab = NULL,
  ylab = NULL,
  legend.title = NULL,
  legend.position = "right",
  theme_use = "theme_this",
  theme_args = list(),
  margins = c("both", "x", "y"),
  marginal_type = NULL,
  margins_size = 10,
  compute_correlation = TRUE,
  compute_correlation_method = c("pearson", "spearman"),
  keep_aspect_ratio = TRUE,
  facet = FALSE,
  se = FALSE,
  pointdensity = TRUE
) {
  smoothing_method <- match.arg(smoothing_method)
  compute_correlation_method <- match.arg(compute_correlation_method)
  margins <- match.arg(margins)
  if (!is.data.frame(data) || ncol(data) < 2L) {
    log_message(
      "{.arg data} must be a data frame with 2 or 3 columns",
      message_type = "error"
    )
  }
  plot_data <- data.frame(
    x = suppressWarnings(as.numeric(data[[1]])),
    y = suppressWarnings(as.numeric(data[[2]])),
    stringsAsFactors = FALSE
  )
  grouped <- ncol(data) >= 3L
  if (grouped) {
    plot_data$cluster <- as.character(data[[3]])
    plot_data$cluster[is.na(plot_data$cluster) | !nzchar(plot_data$cluster)] <- "NA"
    plot_data$cluster <- factor(plot_data$cluster, levels = unique(plot_data$cluster))
    group_colors <- palette_colors(
      levels(plot_data$cluster),
      palette = palette,
      palcolor = palcolor,
      type = "discrete",
      matched = TRUE
    )
    p <- ggplot(plot_data, aes(x = .data$x, y = .data$y, color = .data$cluster)) +
      geom_point() +
      geom_smooth(
        method = smoothing_method,
        formula = "y ~ x",
        se = se
      ) +
      scale_color_manual(values = group_colors, name = legend.title)
    marginal_group_colour <- TRUE
    marginal_group_fill <- TRUE
  } else if (ncol(data) == 2L) {
    point_color <- palette_colors(
      "A",
      palette = palette,
      palcolor = palcolor,
      type = "discrete",
      matched = TRUE
    )[[1]]
    p <- ggplot(plot_data, aes(x = .data$x, y = .data$y))
    if (
      isTRUE(pointdensity) &&
        requireNamespace("ggpointdensity", quietly = TRUE)
    ) {
      density_colors <- palette_colors(palette = palette, palcolor = palcolor, n = 100)
      p <- p +
        ggpointdensity::geom_pointdensity() +
        ggplot2::scale_color_gradientn(colours = density_colors, name = legend.title)
    } else {
      p <- p + geom_point(color = point_color)
    }
    p <- p +
      geom_smooth(
        method = smoothing_method,
        color = point_color,
        formula = "y ~ x",
        se = se
      )
    marginal_group_colour <- FALSE
    marginal_group_fill <- FALSE
  } else {
    log_message(
      "{.arg data} must be a data frame with 2 or 3 columns",
      message_type = "error"
    )
  }

  theme_fun <- if (is.function(theme_use)) {
    theme_use
  } else {
    get(theme_use, mode = "function", inherits = TRUE)
  }
  p <- p +
    do.call(theme_fun, theme_args) +
    labs(title = title, x = xlab, y = ylab) +
    theme(legend.position = legend.position)
  if (isTRUE(keep_aspect_ratio)) {
    p <- p + coord_fixed(ratio = 1)
  }
  if (isTRUE(compute_correlation)) {
    p <- plot_scatter_add_correlation(
      p,
      plot_data,
      method = compute_correlation_method,
      grouped = grouped
    )
  }
  if (isTRUE(facet)) {
    if (!grouped) {
      log_message(
        "{.arg facet} requires a grouping column in {.arg data}",
        message_type = "error"
      )
    }
    return(p + facet_wrap(~cluster))
  }
  if (!is.null(marginal_type)) {
    if (!requireNamespace("ggExtra", quietly = TRUE)) {
      log_message(
        "Package {.pkg ggExtra} is required for marginal plots",
        message_type = "error"
      )
    }
    marginal_type <- match.arg(
      marginal_type,
      c("density", "histogram", "boxplot", "violin", "densigram")
    )
    p <- suppressMessages(
      ggExtra::ggMarginal(
        p,
        margins = margins,
        type = marginal_type,
        groupColour = marginal_group_colour,
        groupFill = marginal_group_fill,
        size = margins_size
      )
    )
  }
  p
}

plot_scatter_add_correlation <- function(p, data, method, grouped) {
  make_label <- function(d) {
    ok <- is.finite(d$x) & is.finite(d$y)
    if (sum(ok) < 3L) {
      return(NULL)
    }
    ct <- stats::cor.test(d$x[ok], d$y[ok], method = method)
    data.frame(
      x = min(d$x[ok], na.rm = TRUE),
      y = max(d$y[ok], na.rm = TRUE),
      label = sprintf("R = %.2f, p = %.3g", unname(ct$estimate), ct$p.value),
      stringsAsFactors = FALSE
    )
  }
  if (isTRUE(grouped)) {
    corr_df <- do.call(
      rbind,
      lapply(split(data, data$cluster, drop = TRUE), function(d) {
        out <- make_label(d)
        if (is.null(out)) {
          return(NULL)
        }
        out$cluster <- d$cluster[[1]]
        out
      })
    )
    if (is.null(corr_df) || nrow(corr_df) == 0L) {
      return(p)
    }
    y_range <- diff(range(data$y, na.rm = TRUE))
    if (!is.finite(y_range) || y_range == 0) {
      y_range <- 1
    }
    corr_df$y <- corr_df$y - (seq_len(nrow(corr_df)) - 1L) * y_range * 0.08
    return(
      p +
        geom_text(
          data = corr_df,
          aes(x = .data$x, y = .data$y, label = .data$label),
          inherit.aes = FALSE,
          hjust = 0,
          vjust = 1,
          size = 3
        )
    )
  }
  corr_df <- make_label(data)
  if (is.null(corr_df)) {
    return(p)
  }
  p +
    annotate(
      "text",
      x = corr_df$x,
      y = corr_df$y,
      label = corr_df$label,
      hjust = 0,
      vjust = 1,
      size = 3.5
    )
}
