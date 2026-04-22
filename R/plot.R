#' Shorten and offset the segment
#'
#' This function takes a data frame representing segments in a plot and shortens
#' and offsets them based on the provided arguments.
#'
#' @param data A data frame containing the segments.
#' It should have columns 'x', 'y', 'xend', and 'yend' representing the start and end points of each segment.
#' @param shorten_start The amount to shorten the start of each segment by.
#' @param shorten_end The amount to shorten the end of each segment by.
#' @param offset The amount to offset each segment by.
#'
#' @return The modified data frame with the shortened and offset segments.
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#' temp_nodes <- data.frame(
#'   "x" = c(10, 40),
#'   "y" = c(10, 30)
#' )
#' data <- data.frame(
#'   "x" = c(10, 40),
#'   "y" = c(10, 30),
#'   "xend" = c(40, 10),
#'   "yend" = c(30, 10)
#' )
#'
#' ggplot(temp_nodes, aes(x = x, y = y)) +
#'   geom_point(size = 12) +
#'   xlim(0, 50) +
#'   ylim(0, 50) +
#'   geom_segment(
#'     data = data,
#'     aes(x = x, xend = xend, y = y, yend = yend)
#'   )
#'
#' ggplot(temp_nodes, aes(x = x, y = y)) +
#'   geom_point(size = 12) +
#'   xlim(0, 50) +
#'   ylim(0, 50) +
#'   geom_segment(
#'     data = segements_df(
#'       data,
#'       shorten_start = 2,
#'       shorten_end = 3,
#'       offset = 1
#'     ),
#'     aes(x = x, xend = xend, y = y, yend = yend)
#'   )
segements_df <- function(
  data,
  shorten_start,
  shorten_end, offset
) {
  data$dx <- data$xend - data$x
  data$dy <- data$yend - data$y
  data$dist <- sqrt(data$dx^2 + data$dy^2)
  data$px <- data$dx / data$dist
  data$py <- data$dy / data$dist

  data$x <- data$x + data$px * shorten_start
  data$y <- data$y + data$py * shorten_start
  data$xend <- data$xend - data$px * shorten_end
  data$yend <- data$yend - data$py * shorten_end
  data$x <- data$x - data$py * offset
  data$xend <- data$xend - data$py * offset
  data$y <- data$y + data$px * offset
  data$yend <- data$yend + data$px * offset

  data
}

#' @title Extract grobs from a list
#'
#' @description
#' Extract grobs from a named list of grobs based on the specified x and y indices.
#'
#' @md
#' @param vlnplots A named list of grobs.
#' @param x_nm A character vector of names for the x dimension.
#' @param y_nm A character vector of names for the y dimension.
#' @param x An integer index for the x dimension.
#' @param y An integer index for the y dimension.
#'
#' @return The extracted grob(s).
#'
#' @export
extractgrobs <- function(vlnplots, x_nm, y_nm, x, y) {
  grobs <- vlnplots[paste0(x_nm[x], ":", y_nm[y])]
  if (length(grobs) == 1) {
    grobs <- grobs[[1]]
  }
  grobs
}

#' @title Draw grobs at specified positions
#'
#' @description
#' Draw a list of grobs at specified positions with given widths and heights.
#'
#' @md
#' @param groblist A grob or a list of grobs to draw.
#' @param x A numeric vector of x positions for each grob.
#' @param y A numeric vector of y positions for each grob.
#' @param width A numeric vector of widths for each grob.
#' @param height A numeric vector of heights for each grob.
#'
#' @return No return value, called for side effects (drawing grobs).
#'
#' @export
grid_draw <- function(groblist, x, y, width, height) {
  if (grid::is.grob(groblist)) {
    groblist <- list(groblist)
  }
  for (i in seq_along(groblist)) {
    groblist[[i]]$vp <- grid::viewport(
      x = x[i],
      y = y[i],
      width = width[i],
      height = height[i]
    )
    grid::grid.draw(groblist[[i]])
  }
}

#' @title Standardize data by rows
#'
#' @description
#' Standardize each row of a data matrix by subtracting the mean and dividing by the standard deviation.
#'
#' @md
#' @param data A matrix or data frame to standardize.
#'
#' @return The standardized data with the same structure as input.
#'
#' @export
standardise <- function(data) {
  data[] <- t(apply(data, 1, scale))
  data
}

#' @title Estimate the fuzzifier parameter m
#'
#' @description
#' Estimate the fuzzifier parameter m for fuzzy clustering based on the data dimensions.
#'
#' @md
#' @param data A matrix or data frame.
#'
#' @return The estimated fuzzifier parameter m.
#'
#' @export
mestimate <- function(data) {
  N <- nrow(data)
  D <- ncol(data)
  m.sj <- 1 +
    (1418 / N + 22.05) * D^(-2) +
    (12.33 / N + 0.243) *
      D^(-0.0406 * log(N) - 0.1134)
  m.sj
}

#' @title Adjust graph layout to avoid node overlaps
#'
#' @description
#' Adjust the layout of a graph to prevent node overlaps by considering node widths and heights.
#'
#' @md
#' @param graph An igraph graph object.
#' @param layout A matrix with two columns representing the initial layout coordinates.
#' @param width A numeric vector of node widths.
#' @param height The height constraint for nodes.
#' Default is `2`.
#' @param scale The scaling factor for the layout.
#' Default is `100`.
#' @param iter The number of iterations for the adjustment algorithm.
#' Default is `100`.
#'
#' @return A matrix with adjusted layout coordinates.
#'
#' @export
adjustlayout <- function(
  graph,
  layout,
  width,
  height = 2,
  scale = 100,
  iter = 100
) {
  w <- width / 2
  layout[, 1] <- layout[, 1] / diff(range(layout[, 1])) * scale
  layout[, 2] <- layout[, 2] / diff(range(layout[, 2])) * scale

  adjusted <- c()
  for (v in order(igraph::degree(graph), decreasing = TRUE)) {
    adjusted <- c(adjusted, v)
    neighbors <- as.numeric(
      igraph::neighbors(
        graph, igraph::V(graph)[v]
      )
    )
    neighbors <- setdiff(neighbors, adjusted)
    x <- layout[v, 1]
    y <- layout[v, 2]
    r <- w[v]
    for (neighbor in neighbors) {
      nx <- layout[neighbor, 1]
      ny <- layout[neighbor, 2]
      ndist <- sqrt((nx - x)^2 + (ny - y)^2)
      nr <- w[neighbor]
      expect <- r + nr
      if (ndist < expect) {
        dx <- (x - nx) * (expect - ndist) / ndist
        dy <- (y - ny) * (expect - ndist) / ndist
        layout[neighbor, 1] <- nx - dx
        layout[neighbor, 2] <- ny - dy
        adjusted <- c(adjusted, neighbor)
      }
    }
  }

  for (i in seq_len(iter)) {
    dist_obj <- stats::dist(layout, method = "euclidean")
    dist_matrix <- as_matrix(dist_obj)
    nearest_neighbors <- apply(
      dist_matrix,
      2,
      function(x) which(x == min(x[x > 0])),
      simplify = FALSE
    )

    for (v in sample(seq_len(nrow(layout)))) {
      neighbors <- unique(nearest_neighbors[[v]])
      x <- layout[v, 1]
      y <- layout[v, 2]
      r <- w[v]
      for (neighbor in neighbors) {
        nx <- layout[neighbor, 1]
        ny <- layout[neighbor, 2]
        nr <- w[neighbor]
        if (abs(nx - x) < (r + nr) && abs(ny - y) < height) {
          dx <- r + nr - (nx - x)
          dy <- height - (ny - y)
          if (sample(c(1, 0), 1) == 1) {
            dx <- 0
          } else {
            dy <- 0
          }
          layout[neighbor, 1] <- nx - dx
          layout[neighbor, 2] <- ny - dy
        }
      }
    }
  }
  return(layout)
}

#' @title Annotate plot quadrants with percentages
#'
#' @param plot A `ggplot` object.
#' @param x Name of the x variable in `plot$data`.
#' @param y Name of the y variable in `plot$data`.
#' @param cutoffs Cut points for x and y axes. Can be a numeric vector of length
#'   1 or 2, or a list with the x and y cut points.
#' @param line_color Quadrant line color.
#' @param line_type Quadrant line type.
#' @param line_width Quadrant line width.
#' @param label_size Label size.
#' @param group Optional grouping column used to compute percentages within each
#'   group.
#'
#' @return A `ggplot` object.
#'
#' @export
#' @examples
#' df <- data.frame(
#'   x = c(0.1, 0.2, 0.8, 0.9),
#'   y = c(0.1, 0.8, 0.2, 0.9)
#' )
#' p <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
#'   ggplot2::geom_point()
#' p
#'
#' annotate_quadrants(p, x = "x", y = "y", cutoffs = 0.5)
annotate_quadrants <- function(
  plot,
  x,
  y,
  cutoffs,
  line_color = "grey30",
  line_type = "solid",
  line_width = 0.5,
  label_size = 3,
  group = NULL
) {
  cutoffs_x <- NULL
  cutoffs_y <- NULL
  if (is.list(cutoffs)) {
    cutoffs_x <- cutoffs[[1]]
    cutoffs_y <- cutoffs[[2]]
  } else if (is.numeric(cutoffs)) {
    if (length(cutoffs) == 1) {
      cutoffs_x <- cutoffs
      cutoffs_y <- cutoffs
    } else {
      cutoffs_x <- cutoffs[1]
      cutoffs_y <- cutoffs[2]
    }
  }

  if (!is.null(cutoffs_x)) {
    plot <- plot +
      ggplot2::geom_vline(
        xintercept = cutoffs_x,
        linetype = line_type,
        color = line_color,
        linewidth = line_width
      )
  }
  if (!is.null(cutoffs_y)) {
    plot <- plot +
      ggplot2::geom_hline(
        yintercept = cutoffs_y,
        linetype = line_type,
        color = line_color,
        linewidth = line_width
      )
  }

  plot_data <- plot$data
  plot_limits <- ggplot2::ggplot_build(plot)$layout$panel_params[[1]]

  x_breaks <- c(plot_limits$x.range[1], cutoffs_x, plot_limits$x.range[2])
  x_breaks <- unique(sort(x_breaks))
  y_breaks <- c(plot_limits$y.range[1], cutoffs_y, plot_limits$y.range[2])
  y_breaks <- unique(sort(y_breaks))

  x_breaks <- x_breaks[
    x_breaks >= plot_limits$x.range[1] & x_breaks <= plot_limits$x.range[2]
  ]
  y_breaks <- y_breaks[
    y_breaks >= plot_limits$y.range[1] & y_breaks <= plot_limits$y.range[2]
  ]

  x_pos <- (utils::head(x_breaks, -1) + utils::tail(x_breaks, -1)) / 2
  y_pos <- (utils::head(y_breaks, -1) + utils::tail(y_breaks, -1)) / 2

  plot_data$x_cat <- as.integer(cut(
    plot_data[[x]],
    breaks = x_breaks,
    include.lowest = TRUE
  ))
  plot_data$y_cat <- as.integer(cut(
    plot_data[[y]],
    breaks = y_breaks,
    include.lowest = TRUE
  ))

  if (is.null(group)) {
    counts <- as.data.frame(
      table(plot_data[, c("x_cat", "y_cat")]),
      stringsAsFactors = FALSE
    )
    counts$value <- to_percent(counts$Freq)
  } else {
    counts <- as.data.frame(
      table(plot_data[, c(group, "x_cat", "y_cat")]),
      stringsAsFactors = FALSE
    )
    counts_list <- split(counts, counts[[group]])
    counts <- do.call(
      rbind,
      lapply(counts_list, function(df) {
        df$value <- to_percent(df$Freq)
        df
      })
    )
  }

  counts$x_cat <- as.integer(counts$x_cat)
  counts$y_cat <- as.integer(counts$y_cat)

  annot_df <- counts[counts$Freq > 0, , drop = FALSE]
  if (nrow(annot_df) == 0) {
    return(plot)
  }

  annot_df$x <- x_pos[annot_df$x_cat]
  annot_df$y <- y_pos[annot_df$y_cat]
  annot_df$label <- paste0(round(annot_df$value, 1), "%")

  plot +
    ggplot2::geom_text(
      data = annot_df,
      ggplot2::aes(x = x, y = y, label = label),
      size = label_size
    )
}

#' @title Clip values to a symmetric range
#'
#' @param data A data frame.
#' @param value_col Name of the numeric column to clip.
#'
#' @return A list containing the clipped data frame and clipping limits.
#'
#' @export
#' @examples
#' df <- data.frame(avg_log2FC = c(-10, -2, 0, 2, 10))
#' clip_symmetric_range(df)
clip_symmetric_range <- function(data, value_col = "avg_log2FC") {
  values <- data[[value_col]][is.finite(data[[value_col]])]
  if (length(values) == 0) {
    return(list(data = data, limits = c(-1, 1)))
  }

  upper <- stats::quantile(values, c(0.99, 1))
  lower <- stats::quantile(values, c(0.01, 0))
  upper <- ifelse(upper[1] > 0, upper[1], upper[2])
  lower <- ifelse(lower[1] < 0, lower[1], lower[2])

  if (upper > 0 && lower < 0) {
    value_range <- min(abs(c(upper, lower)), na.rm = TRUE)
    upper <- value_range
    lower <- -value_range
  }

  data[data[[value_col]] > upper, value_col] <- upper
  data[data[[value_col]] < lower, value_col] <- lower

  list(data = data, limits = c(lower, upper))
}

#' @title Jitter highlighted points deterministically
#'
#' @param data A data frame containing `x`, `y`, and `border` columns.
#' @param jitter_width Width of the x jitter.
#' @param jitter_height Height of the y jitter.
#' @param seed Numeric value used to offset the deterministic sequence.
#'
#' @return A data frame with `x_plot` and `y_plot` columns.
#'
#' @export
#' @examples
#' df <- data.frame(
#'   x = c(0, 1),
#'   y = c(0, 1),
#'   border = c(FALSE, TRUE)
#' )
#' jitter_highlighted_points(df, jitter_width = 0.2, jitter_height = 0.2)
jitter_highlighted_points <- function(
  data,
  jitter_width = 0.2,
  jitter_height = 0.2,
  seed = 11
) {
  data[, "x_plot"] <- data[, "x"]
  data[, "y_plot"] <- data[, "y"]

  border_idx <- which(
    data[, "border"] & is.finite(data[, "x"]) & is.finite(data[, "y"])
  )
  if (length(border_idx) == 0) {
    return(data)
  }

  idx <- seq_along(border_idx)
  x_offset <- ((((idx * 0.61803398875) + (seed * 0.01)) %% 1) - 0.5) *
    2 *
    jitter_width
  y_offset <- ((((idx * 0.41421356237) + (seed * 0.01)) %% 1) - 0.5) *
    2 *
    jitter_height

  data[border_idx, "x_plot"] <- data[border_idx, "x"] + x_offset
  data[border_idx, "y_plot"] <- data[border_idx, "y"] + y_offset
  data
}
