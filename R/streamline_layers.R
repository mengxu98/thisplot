#' @title Draw streamline layers from a vector grid
#'
#' @description
#' Draw streamlines and arrows from a regular two-dimensional vector grid.
#'
#' @md
#' @param x_grid A numeric matrix with two rows containing the x and y grid
#'   coordinates, as returned by [compute_velocity_on_grid()] with
#'   `adjust_for_stream = TRUE`.
#' @param v_grid A numeric array with dimensions `c(2, m, m)`, where `m` is the
#'   number of columns in `x_grid`. Its first dimension identifies the x and y
#'   vector components. Missing grid values are replaced with zero for drawing.
#' @param L Numeric streamline length. Default `5`.
#' @param min.L Numeric minimum streamline length. Default `1`.
#' @param res Numeric streamline resolution. Default `1`.
#' @param n Numeric streamline density. Default `15`.
#' @param linewidth Numeric foreground line widths. Fixed colours use the maximum
#'   value; magnitude colours map streamline steps to the supplied range.
#'   Default `c(0, 0.8)`.
#' @param alpha Numeric transparency of the background and foreground lines.
#'   Default `1`. Arrow-only layers retain their own opacity.
#' @param color A fixed foreground colour, or `NULL` to colour by vector magnitude.
#' @param palette,palcolor Palette name and optional colours used when `color`
#'   is `NULL`. Defaults are `"RdYlBu"` and `NULL`.
#' @param bg.color Background line colour. Default `"white"`.
#' @param bg.stroke Numeric extra width around the foreground lines. Default `0.5`.
#' @param arrow.color Arrow colour. Default `"black"`.
#' @param arrow.angle Numeric arrow angle in degrees. Default `20`.
#' @param legend.title Colour legend title. Default `"Velocity"`.
#' @return A list of three ggplot2 layers, followed by colour and linewidth scales
#'   when `color` is `NULL`. Add the list to a ggplot with `+`.
#' @seealso [compute_velocity_on_grid()]
#' @export
#' @examples
#' coordinates <- seq(-2, 2, length.out = 16)
#' x_grid <- rbind(coordinates, coordinates)
#' v_grid <- array(0, dim = c(2, 16, 16))
#' v_grid[1, , ] <- outer(-coordinates, rep(1, 16))
#' v_grid[2, , ] <- outer(rep(1, 16), coordinates)
#' ggplot2::ggplot() +
#'   streamline_layers(x_grid, v_grid, L = 2, n = 8) +
#'   ggplot2::coord_equal() +
#'   theme_this()
streamline_layers <- function(
  x_grid,
  v_grid,
  L = 5,
  min.L = 1,
  res = 1,
  n = 15,
  linewidth = c(0, 0.8),
  alpha = 1,
  color = NULL,
  palette = "RdYlBu",
  palcolor = NULL,
  bg.color = "white",
  bg.stroke = 0.5,
  arrow.color = "black",
  arrow.angle = 20,
  legend.title = "Velocity"
) {
  if (
    !is.matrix(x_grid) || !is.numeric(x_grid) ||
      nrow(x_grid) != 2L || ncol(x_grid) < 1L
  ) {
    thisutils::log_message(
      "{.arg x_grid} must be a numeric matrix with two rows and at least one column",
      message_type = "error"
    )
  }
  if (
    !is.numeric(v_grid) ||
      !identical(dim(v_grid), c(2L, ncol(x_grid), ncol(x_grid)))
  ) {
    thisutils::log_message(
      "{.arg v_grid} must be a numeric array with dimensions c(2, ncol(x_grid), ncol(x_grid))",
      message_type = "error"
    )
  }
  thisutils::check_r("metR", verbose = FALSE)
  geom_streamline <- thisutils::get_namespace_fun("metR", "geom_streamline")

  data <- expand.grid(x_grid[1, ], x_grid[2, ])
  colnames(data) <- c("x", "y")
  data$u <- reshape2::melt(base::t(v_grid[1, , ]))$value
  data$v <- reshape2::melt(base::t(v_grid[2, , ]))$value
  data[is.na(data)] <- 0

  common <- list(
    data = data,
    mapping = ggplot2::aes(x = x, y = y, dx = .data$u, dy = .data$v),
    L = L,
    min.L = min.L,
    res = res,
    n = n,
    lineend = "round",
    linejoin = "mitre",
    inherit.aes = FALSE
  )
  background <- do.call(geom_streamline, c(common, list(
    linewidth = max(linewidth, na.rm = TRUE) + bg.stroke,
    color = bg.color,
    alpha = alpha,
    arrow.type = "closed",
    arrow.angle = arrow.angle
  )))
  if (!is.null(color)) {
    foreground <- do.call(geom_streamline, c(common, list(
      linewidth = max(linewidth, na.rm = TRUE),
      color = color,
      alpha = alpha,
      arrow.type = "closed",
      arrow.angle = arrow.angle
    )))
  } else {
    magnitude <- common
    magnitude$mapping <- ggplot2::aes(
      x = x, y = y, dx = .data$u, dy = .data$v,
      linewidth = ggplot2::after_stat(.data$step),
      color = sqrt(ggplot2::after_stat(.data$dx)^2 + ggplot2::after_stat(.data$dy)^2)
    )
    foreground <- do.call(geom_streamline, c(magnitude, list(
      alpha = alpha,
      arrow = NULL
    )))
  }
  arrows <- do.call(geom_streamline, c(common, list(
    linetype = 0,
    color = arrow.color,
    arrow.type = "closed",
    arrow.angle = arrow.angle
  )))
  layers <- list(background, foreground, arrows)
  if (is.null(color)) {
    layers <- c(layers, list(
      ggplot2::scale_color_gradientn(
        name = legend.title,
        colors = palette_colors(palette = palette, palcolor = palcolor),
        guide = ggplot2::guide_colorbar(
          frame.colour = "black",
          ticks.colour = "black",
          title.hjust = 0,
          order = 1
        )
      ),
      ggplot2::scale_linewidth(range = range(linewidth), guide = "none")
    ))
  }
  layers
}
