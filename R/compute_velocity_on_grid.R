#' @title Compute velocity on grid
#'
#' @md
#' @param x_emb A matrix of dimension n_obs x n_dim specifying the embedding coordinates of the cells.
#' @param v_emb A matrix of dimension n_obs x n_dim specifying the velocity vectors of the cells.
#' @param density A numeric value specifying the density of the grid points along each dimension.
#' Default is `1`.
#' @param smooth A numeric value specifying the smoothing factor for the velocity vectors.
#' Default is `0.5`.
#' @param n_neighbors A numeric value specifying the number of nearest neighbors for each grid point.
#' Default is `ceiling(n_obs / 50)`.
#' @param min_mass A numeric value specifying the minimum mass required for a grid point to be considered.
#' Default is `1`.
#' @param scale A numeric value specifying the scaling factor for the velocity vectors.
#' Default is `1`.
#' @param adjust_for_stream Whether to adjust the velocity vectors for streamlines.
#' Default is `FALSE`.
#' @param cutoff_perc A numeric value specifying the percentile cutoff for removing low-density grid points.
#' Default is `5`.
#'
#' @return
#' A list with two components:
#' `x_grid`, the grid coordinates, and `v_grid`, the smoothed velocity vectors on the grid.
#'
#' @references
#' \url{https://github.com/theislab/scvelo/blob/master/scvelo/plotting/velocity_embedding_grid.py}
#'
#' @export
#'
#' @examples
#' x_emb <- matrix(
#'   c(
#'     0, 0,
#'     1, 0,
#'     0, 1,
#'     1, 1
#'   ),
#'   ncol = 2,
#'   byrow = TRUE
#' )
#' v_emb <- matrix(
#'   c(
#'     1, 0,
#'     1, 0,
#'     0, 1,
#'     0, 1
#'   ),
#'   ncol = 2,
#'   byrow = TRUE
#' )
#'
#' velocity_grid <- compute_velocity_on_grid(
#'   x_emb = x_emb,
#'   v_emb = v_emb,
#'   density = 0.1,
#'   n_neighbors = 2,
#'   adjust_for_stream = TRUE
#' )
#'
#' names(velocity_grid)
#' dim(velocity_grid$x_grid)
#' dim(velocity_grid$v_grid)
#' head(velocity_grid$x_grid)
#' head(velocity_grid$v_grid)
#'
#' grid_df <- expand.grid(
#'   x = velocity_grid$x_grid[1, ],
#'   y = velocity_grid$x_grid[2, ]
#' )
#'
#' plot_df <- data.frame(
#'   x = grid_df$x,
#'   y = grid_df$y,
#'   xend = grid_df$x + c(velocity_grid$v_grid[1, , ]) * 0.2,
#'   yend = grid_df$y + c(velocity_grid$v_grid[2, , ]) * 0.2
#' )
#'
#' ggplot2::ggplot(plot_df) +
#'   ggplot2::geom_segment(
#'     ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
#'     arrow = grid::arrow(length = grid::unit(0.12, "inches")),
#'     na.rm = TRUE
#'   ) +
#'   ggplot2::coord_equal()
compute_velocity_on_grid <- function(
  x_emb,
  v_emb,
  density = 1,
  smooth = 0.5,
  n_neighbors = ceiling(n_obs / 50),
  min_mass = 1,
  scale = 1,
  adjust_for_stream = FALSE,
  cutoff_perc = 5
) {
  reshape_rowmajor <- function(x, dim) {
    values <- if (is.null(dim(x))) {
      as.vector(x)
    } else {
      as.vector(aperm(x, rev(seq_along(dim(x)))))
    }
    aperm(array(values, dim = rev(dim)), rev(seq_along(dim)))
  }

  n_obs <- nrow(x_emb)
  n_dim <- ncol(x_emb)

  grs <- list()
  for (dim_i in 1:n_dim) {
    m1 <- min(x_emb[, dim_i], na.rm = TRUE)
    m2 <- max(x_emb[, dim_i], na.rm = TRUE)
    # m1 <- m1 - 0.01 * abs(m2 - m1)
    # m2 <- m2 + 0.01 * abs(m2 - m1)
    gr <- seq(m1, m2, length.out = ceiling(50 * density))
    grs <- c(grs, list(gr))
  }
  x_grid <- as_matrix(expand.grid(grs))

  d <- proxyC::dist(
    x = thisutils::as_matrix(x_emb, return_sparse = TRUE),
    y = thisutils::as_matrix(x_grid, return_sparse = TRUE),
    method = "euclidean",
    use_nan = TRUE
  )
  neighbors <- Matrix::t(
    as_matrix(
      apply(
        d,
        2,
        function(x) {
          order(x, decreasing = FALSE)[1:n_neighbors]
        }
      )
    )
  )
  dists <- Matrix::t(
    as_matrix(
      apply(
        d,
        2,
        function(x) {
          x[order(x, decreasing = FALSE)[1:n_neighbors]]
        }
      )
    )
  )

  weight <- stats::dnorm(
    dists,
    sd = mean(sapply(grs, function(g) g[2] - g[1])) * smooth
  )
  p_mass <- p_mass_v <- Matrix::rowSums(weight)
  p_mass_v[p_mass_v < 1] <- 1

  neighbors_emb <- array(
    v_emb[neighbors, seq_len(ncol(v_emb))],
    dim = c(dim(neighbors), dim(v_emb)[2])
  )
  v_grid <- apply((neighbors_emb * c(weight)), c(1, 3), sum)
  v_grid <- v_grid / p_mass_v

  if (isTRUE(adjust_for_stream)) {
    x_grid <- matrix(
      c(unique(x_grid[, 1]), unique(x_grid[, 2])),
      nrow = 2,
      byrow = TRUE
    )
    ns <- floor(sqrt(length(v_grid[, 1])))
    v_grid <- reshape_rowmajor(Matrix::t(v_grid), c(2, ns, ns))

    mass <- sqrt(apply(v_grid**2, c(2, 3), sum))
    min_mass <- 10**(min_mass - 6) # default min_mass = 1e-5
    min_mass[min_mass > max(mass, na.rm = TRUE) * 0.9] <- max(
      mass,
      na.rm = TRUE
    ) *
      0.9
    cutoff <- reshape_rowmajor(mass, c(ns, ns)) < min_mass

    length <- Matrix::t(apply(apply(abs(neighbors_emb), c(1, 3), mean), 1, sum))
    length <- reshape_rowmajor(length, c(ns, ns))
    cutoff <- cutoff | length < stats::quantile(length, cutoff_perc / 100)
    v_grid[1, , ][cutoff] <- NA
  } else {
    min_mass <- min_mass * stats::quantile(p_mass, 0.99) / 100
    x_grid <- x_grid[p_mass > min_mass, ]
    v_grid <- v_grid[p_mass > min_mass, ]
    if (!is.null(scale)) {
      v_grid <- v_grid * scale
    }
  }
  return(list(x_grid = x_grid, v_grid = v_grid))
}
