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
