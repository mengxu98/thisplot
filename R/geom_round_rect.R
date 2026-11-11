#' @title Rectangles with a physical corner radius
#'
#' @md
#' @description
#' Draw rectangles from `xmin`, `xmax`, `ymin`, and `ymax` aesthetics. The
#' corner radius is measured in millimetres and stays fixed when axis limits
#' change. Fill, alpha, colour, linewidth, and linetype follow rectangle
#' aesthetics. Cartesian coordinates and coordinate flipping are supported.
#'
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes
#'   Standard ggplot2 layer arguments.
#' @param ... Arguments passed to other functions.
#' @param radius One finite, nonnegative corner radius in millimetres.
#' @return A ggplot2 layer.
#' @export
#' @examples
#' bands <- data.frame(xmin = c(0, 2), xmax = c(1, 3), ymin = 0, ymax = 1)
#' ggplot2::ggplot(bands, ggplot2::aes(
#'   xmin = xmin, xmax = xmax,
#'   ymin = ymin, ymax = ymax
#' )) +
#'   geom_round_rect(fill = "grey80", colour = NA)
geom_round_rect <- function(
  mapping = NULL, data = NULL, stat = "identity", position = "identity",
  radius = 2, na.rm = FALSE, show.legend = NA, inherit.aes = TRUE, ...
) {
  if (!is.numeric(radius) || length(radius) != 1L || !is.finite(radius) || radius < 0) {
    stop("radius must be one finite nonnegative number in millimetres.", call. = FALSE)
  }
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = GeomRoundRect,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(radius = radius, na.rm = na.rm, ...)
  )
}

GeomRoundRect <- ggplot2::ggproto(
  "GeomRoundRect", ggplot2::GeomRect,
  draw_panel = function(data, panel_params, coord, radius = 2) {
    if (!coord$is_linear()) {
      stop("geom_round_rect requires Cartesian coordinates.", call. = FALSE)
    }
    coords <- coord$transform(data, panel_params)
    grobs <- lapply(seq_len(nrow(coords)), function(i) {
      grid::roundrectGrob(
        x = (coords$xmin[i] + coords$xmax[i]) / 2,
        y = (coords$ymin[i] + coords$ymax[i]) / 2,
        width = abs(coords$xmax[i] - coords$xmin[i]),
        height = abs(coords$ymax[i] - coords$ymin[i]),
        default.units = "native", r = grid::unit(radius, "mm"),
        gp = grid::gpar(
          fill = ggplot2::alpha(coords$fill[i], coords$alpha[i]),
          col = ggplot2::alpha(coords$colour[i], coords$alpha[i]),
          lwd = coords$linewidth[i] * 72.27 / 25.4, lty = coords$linetype[i]
        )
      )
    })
    do.call(grid::grobTree, grobs)
  }
)
