#' @title Data Dimensional Plot
#'
#' @description
#' Visualize observations on precomputed two-dimensional coordinates.
#'
#' @md
#' @param data A data frame containing coordinates and optional grouping columns.
#' @param x Name of the column used as the x-axis coordinate.
#' @param y Name of the column used as the y-axis coordinate.
#' @param group.by Name of the column used to color observations.
#' Default is `NULL`.
#' @param split.by Name of the column used to split the plot into facets.
#' Default is `NULL`.
#' @param shape.by Name of the column used to map point shapes.
#' Default is `NULL`.
#' @param show_na Whether to keep missing values in `group.by`, `split.by`,
#' or `shape.by` as an explicit `"NA"` level. Default is `FALSE`.
#' @param palette Color palette name. Available palettes can be found in
#' [show_palettes]. Default is `"Chinese"`.
#' @param palcolor Custom colors used to create a color palette.
#' Default is `NULL`.
#' @param NA_color Color used for missing values.
#' @param pt.size Point size.
#' @param pt.alpha Point transparency.
#' @param shape.values Point shapes used when `shape.by` is set.
#' @param add_mark Whether to add marks around groups. Default is `FALSE`.
#' @param mark_type Type of mark to add around groups.
#' One of `"hull"`, `"ellipse"`, `"rect"`, or `"circle"`.
#' Default is `"hull"`. `"ellipse"` uses [ggplot2::stat_ellipse]
#' with `type = "norm"` and `level = 0.95`; the other mark types use ggforce marks.
#' @param mark_expand Expansion of the mark around each group.
#' This is used for `"hull"`, `"rect"`, and `"circle"` marks.
#' Default is `grid::unit(3, "mm")`.
#' @param mark_alpha Transparency of the mark.
#' Default is `0.1`.
#' @param mark_linetype Line type of the mark border.
#' Default is `1`.
#' @param label Whether to label group centers.
#' @param label.size Size of labels.
#' @param label.fg Foreground color of labels.
#' @param label.bg Background color of labels.
#' @param label.bg.r Background ratio of labels.
#' @param label_repel Whether labels repel from their group centers.
#' @param label_repulsion Repulsion force for labels.
#' @param label_point_size Size of center points for repelled labels.
#' @param label_point_color Color of center points for repelled labels.
#' @param label_segment_color Color of label segments.
#' @param add_origin Whether to add dashed x = 0 and y = 0 reference lines.
#' @param origin.color Color of origin reference lines.
#' @param origin.linetype Line type of origin reference lines.
#' @param origin.linewidth Line width of origin reference lines.
#' @param aspect.ratio Aspect ratio passed to `theme()`.
#' @param title Plot title.
#' @param subtitle Plot subtitle.
#' @param xlab Label for the x axis.
#' @param ylab Label for the y axis.
#' @param legend.position Position of the legend.
#' @param legend.direction Direction of the legend.
#' @param legend.title Title of the group legend.
#' @param theme_use Theme function applied to the plot.
#' @param theme_args A named list of arguments passed to `theme_use`.
#' @param seed Random seed.
#'
#' @return A ggplot object.
#'
#' @export
#'
#' @examples
#' set.seed(1)
#' plot_data <- data.frame(
#'   x = c(rnorm(40, -1), rnorm(40, 1)),
#'   y = c(rnorm(40, 0), rnorm(40, 1)),
#'   group = rep(c("A", "B"), each = 40)
#' )
#' DimDataPlot(
#'   plot_data,
#'   x = "x",
#'   y = "y",
#'   group.by = "group",
#'   add_mark = TRUE
#' )
#'
#' DimDataPlot(
#'   plot_data,
#'   x = "x",
#'   y = "y",
#'   group.by = "group",
#'   add_mark = TRUE,
#'   add_origin = TRUE,
#'   mark_type = "ellipse"
#' )
#'
#' DimDataPlot(
#'   plot_data,
#'   x = "x",
#'   y = "y",
#'   group.by = "group",
#'   add_mark = TRUE,
#'   mark_type = "circle",
#'   mark_alpha = 0.3,
#'   mark_expand = grid::unit(1, "mm"),
#'   mark_linetype = 2
#' )
DimDataPlot <- function(
    data,
    x,
    y,
    group.by = NULL,
    split.by = NULL,
    shape.by = NULL,
    show_na = FALSE,
    palette = "Chinese",
    palcolor = NULL,
    NA_color = "grey80",
    pt.size = 2,
    pt.alpha = 1,
    shape.values = NULL,
    add_mark = FALSE,
    mark_type = c("hull", "ellipse", "rect", "circle"),
    mark_expand = grid::unit(3, "mm"),
    mark_alpha = 0.1,
    mark_linetype = 1,
    label = FALSE,
    label.size = 4,
    label.fg = "black",
    label.bg = "white",
    label.bg.r = 0.1,
    label_repel = FALSE,
    label_repulsion = 20,
    label_point_size = 1,
    label_point_color = "black",
    label_segment_color = "black",
    add_origin = FALSE,
    origin.color = "grey30",
    origin.linetype = "dashed",
    origin.linewidth = 0.4,
    aspect.ratio = 1,
    title = NULL,
    subtitle = NULL,
    xlab = NULL,
    ylab = NULL,
    legend.position = "right",
    legend.direction = "vertical",
    legend.title = NULL,
    theme_use = "theme_this",
    theme_args = list(),
    seed = 11) {
  set.seed(seed)
  mark_type <- match.arg(mark_type)

  data <- as.data.frame(data)
  column_args <- list(
    x = x,
    y = y,
    group.by = group.by,
    split.by = split.by,
    shape.by = shape.by
  )
  optional_args <- c("group.by", "split.by", "shape.by")
  for (arg in names(column_args)) {
    column <- column_args[[arg]]
    if (is.null(column) && arg %in% optional_args) {
      next
    }
    if (!is.character(column) || length(column) != 1L || is.na(column)) {
      log_message(
        "{.arg {arg}} must be one column name.",
        message_type = "error"
      )
    }
    if (!column %in% colnames(data)) {
      log_message(
        "{.val {column}} is not in {.arg data}.",
        message_type = "error"
      )
    }
  }

  has_group <- !is.null(group.by)
  has_split <- !is.null(split.by)
  has_shape <- !is.null(shape.by)

  plot_data <- data
  plot_data[[".plot_x"]] <- suppressWarnings(as.numeric(plot_data[[x]]))
  plot_data[[".plot_y"]] <- suppressWarnings(as.numeric(plot_data[[y]]))
  keep <- is.finite(plot_data[[".plot_x"]]) &
    is.finite(plot_data[[".plot_y"]])
  if (any(!keep)) {
    log_message(
      "Rows with non-finite coordinate values were removed.",
      message_type = "warning"
    )
  }
  plot_data <- plot_data[keep, , drop = FALSE]
  if (nrow(plot_data) == 0) {
    log_message(
      "No rows remain after removing non-finite coordinates.",
      message_type = "error"
    )
  }

  if (has_group) {
    group_info <- dim_data_plot_factor(
      plot_data[[group.by]],
      show_na = show_na,
      arg = "group.by"
    )
    plot_data <- plot_data[group_info[["keep"]], , drop = FALSE]
    plot_data[[".plot_group"]] <- group_info[["value"]]
  } else {
    plot_data[[".plot_group"]] <- factor("All", levels = "All")
  }
  if (nrow(plot_data) == 0) {
    log_message(
      "No rows remain after removing missing group values.",
      message_type = "error"
    )
  }

  if (has_split) {
    split_info <- dim_data_plot_factor(
      plot_data[[split.by]],
      show_na = show_na,
      arg = "split.by"
    )
    plot_data <- plot_data[split_info[["keep"]], , drop = FALSE]
    plot_data[[".plot_split"]] <- split_info[["value"]]
  } else {
    plot_data[[".plot_split"]] <- factor("All", levels = "All")
  }
  if (nrow(plot_data) == 0) {
    log_message(
      "No rows remain after removing missing split values.",
      message_type = "error"
    )
  }

  if (has_shape) {
    shape_info <- dim_data_plot_factor(
      plot_data[[shape.by]],
      show_na = show_na,
      arg = "shape.by"
    )
    plot_data <- plot_data[shape_info[["keep"]], , drop = FALSE]
    plot_data[[".plot_shape"]] <- shape_info[["value"]]
  }
  if (nrow(plot_data) == 0) {
    log_message(
      "No rows remain after removing missing shape values.",
      message_type = "error"
    )
  }

  group_levels <- levels(plot_data[[".plot_group"]])
  colors <- if (has_group) {
    palette_colors(
      group_levels,
      palette = palette,
      palcolor = palcolor,
      NA_keep = TRUE
    )
  } else {
    stats::setNames("#1F1F1F", group_levels)
  }
  colors <- colors[group_levels]

  plot_data <- plot_data[
    order(plot_data[[".plot_group"]], plot_data[[".plot_split"]]),
    ,
    drop = FALSE
  ]

  mark_layers <- NULL
  if (isTRUE(add_mark)) {
    if (identical(mark_type, "ellipse")) {
      mark_layers <- list(
        ggplot2::stat_ellipse(
          data = plot_data,
          mapping = ggplot2::aes(
            x = .data[[".plot_x"]],
            y = .data[[".plot_y"]],
            group = .data[[".plot_group"]],
            fill = .data[[".plot_group"]]
          ),
          geom = "polygon",
          type = "norm",
          level = 0.95,
          alpha = mark_alpha,
          color = NA,
          show.legend = FALSE,
          inherit.aes = FALSE
        ),
        ggplot2::stat_ellipse(
          data = plot_data,
          mapping = ggplot2::aes(
            x = .data[[".plot_x"]],
            y = .data[[".plot_y"]],
            color = .data[[".plot_group"]]
          ),
          geom = "path",
          type = "norm",
          level = 0.95,
          linetype = mark_linetype,
          show.legend = FALSE,
          inherit.aes = FALSE
        )
      )
    } else {
      mark_fun <- switch(
        EXPR = mark_type,
        "hull" = ggforce::geom_mark_hull,
        "rect" = ggforce::geom_mark_rect,
        "circle" = ggforce::geom_mark_circle
      )
      mark_layers <- list(
        do.call(
          mark_fun,
          list(
            data = plot_data,
            mapping = ggplot2::aes(
              x = .data[[".plot_x"]],
              y = .data[[".plot_y"]],
              color = .data[[".plot_group"]],
              fill = .data[[".plot_group"]]
            ),
            expand = mark_expand,
            alpha = mark_alpha,
            linetype = mark_linetype,
            show.legend = FALSE,
            inherit.aes = FALSE
          )
        )
      )
    }
  }

  fill_scale <- NULL
  if (isTRUE(add_mark)) {
    fill_scale <- list(
      ggplot2::scale_fill_manual(values = colors, guide = "none")
    )
  }

  origin_layers <- NULL
  if (isTRUE(add_origin)) {
    origin_layers <- list(
      ggplot2::geom_vline(
        xintercept = 0,
        color = origin.color,
        linetype = origin.linetype,
        linewidth = origin.linewidth
      ),
      ggplot2::geom_hline(
        yintercept = 0,
        color = origin.color,
        linetype = origin.linetype,
        linewidth = origin.linewidth
      )
    )
  }

  point_mapping <- ggplot2::aes(
    x = .data[[".plot_x"]],
    y = .data[[".plot_y"]],
    color = .data[[".plot_group"]]
  )
  if (has_shape) {
    point_mapping <- ggplot2::aes(
      x = .data[[".plot_x"]],
      y = .data[[".plot_y"]],
      color = .data[[".plot_group"]],
      shape = .data[[".plot_shape"]]
    )
  }

  legend_title_use <- legend.title %||% group.by %||% ""
  p <- ggplot2::ggplot(plot_data) +
    mark_layers +
    fill_scale +
    origin_layers +
    ggplot2::geom_point(
      mapping = point_mapping,
      size = pt.size,
      alpha = pt.alpha
    ) +
    ggplot2::scale_color_manual(
      name = legend_title_use,
      values = colors,
      na.value = NA_color,
      guide = if (has_group) {
        ggplot2::guide_legend(
          title.hjust = 0,
          order = 1,
          override.aes = list(size = 4, alpha = 1)
        )
      } else {
        "none"
      }
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = xlab %||% x,
      y = ylab %||% y
    ) +
    do.call(theme_use, theme_args) +
    ggplot2::theme(
      aspect.ratio = aspect.ratio,
      legend.position = legend.position,
      legend.direction = legend.direction
    )

  if (has_shape) {
    shape_levels <- levels(plot_data[[".plot_shape"]])
    shape_values <- dim_data_plot_shapes(shape_levels, shape.values)
    p <- p +
      ggplot2::scale_shape_manual(
        name = if (identical(shape.by, group.by)) {
          legend_title_use
        } else {
          shape.by
        },
        values = shape_values
      )
  }

  if (has_split) {
    p <- p + ggplot2::facet_grid(. ~ .plot_split)
  }

  if (isTRUE(label) && has_group) {
    label_data <- stats::aggregate(
      plot_data[, c(".plot_x", ".plot_y"), drop = FALSE],
      by = list(
        .plot_group = plot_data[[".plot_group"]],
        .plot_split = plot_data[[".plot_split"]]
      ),
      FUN = stats::median
    )
    label_data[[".plot_label"]] <- as.character(label_data[[".plot_group"]])

    if (isTRUE(label_repel)) {
      p <- p +
        ggplot2::geom_point(
          data = label_data,
          mapping = ggplot2::aes(
            x = .data[[".plot_x"]],
            y = .data[[".plot_y"]]
          ),
          shape = "circle",
          color = label_point_color,
          size = label_point_size,
          inherit.aes = FALSE
        ) +
        ggrepel::geom_text_repel(
          data = label_data,
          mapping = ggplot2::aes(
            x = .data[[".plot_x"]],
            y = .data[[".plot_y"]],
            label = .data[[".plot_label"]]
          ),
          fontface = "bold",
          min.segment.length = 0,
          segment.color = label_segment_color,
          point.size = label_point_size,
          max.overlaps = 100,
          force = label_repulsion,
          color = label.fg,
          bg.color = label.bg,
          bg.r = label.bg.r,
          size = label.size,
          inherit.aes = FALSE
        )
    } else {
      p <- p +
        ggrepel::geom_text_repel(
          data = label_data,
          mapping = ggplot2::aes(
            x = .data[[".plot_x"]],
            y = .data[[".plot_y"]],
            label = .data[[".plot_label"]]
          ),
          fontface = "bold",
          min.segment.length = 0,
          point.size = NA,
          max.overlaps = 100,
          force = 0,
          color = label.fg,
          bg.color = label.bg,
          bg.r = label.bg.r,
          size = label.size,
          inherit.aes = FALSE
        )
    }
  }

  attr(p, "data") <- plot_data
  p
}

dim_data_plot_factor <- function(x, show_na = FALSE, arg = "group") {
  keep <- rep(TRUE, length(x))
  if (isTRUE(show_na)) {
    x_chr <- as.character(x)
    levels_use <- if (is.factor(x)) {
      levels(x)
    } else {
      unique(x_chr[!is.na(x_chr)])
    }
    levels_use <- unique(c(levels_use, "NA"))
    x_chr[is.na(x_chr)] <- "NA"
    value <- factor(x_chr, levels = levels_use)
  } else {
    keep <- !is.na(x)
    if (any(!keep)) {
      log_message(
        "Rows with missing {.arg {arg}} values were removed.",
        message_type = "warning"
      )
    }
    x <- x[keep]
    value <- if (is.factor(x)) {
      factor(as.character(x), levels = levels(x))
    } else {
      factor(as.character(x), levels = unique(as.character(x)))
    }
  }
  list(value = value, keep = keep)
}

dim_data_plot_shapes <- function(levels_use, shape.values = NULL) {
  if (is.null(shape.values)) {
    shape.values <- c(16, 17, 15, 18, 3, 7, 8, 0, 1, 2, 5, 6)
  }
  if (!is.null(names(shape.values)) && all(levels_use %in% names(shape.values))) {
    return(shape.values[levels_use])
  }
  shape.values <- rep(shape.values, length.out = length(levels_use))
  stats::setNames(shape.values, levels_use)
}
