#' @title The default theme for scop plot function.
#'
#' @md
#' @param aspect.ratio Aspect ratio of the panel.
#' @param base_size Base font size
#' @param ... Arguments passed to the [ggplot2::theme].
#'
#' @return A ggplot2 theme object (class `theme`, `gg`).
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(
#'   data = mtcars,
#'   aes(x = wt, y = mpg, colour = factor(cyl))
#' ) +
#'   geom_point()
#' p + theme_this()
theme_this <- function(
  aspect.ratio = NULL,
  base_size = 12,
  ...
) {
  text_size_scale <- base_size / 12
  args1 <- list(
    aspect.ratio = aspect.ratio,
    text = element_text(
      size = 12 * text_size_scale,
      color = "black"
    ),
    plot.title = element_text(
      size = 14 * text_size_scale,
      colour = "black", vjust = 1
    ),
    plot.subtitle = element_text(
      size = 13 * text_size_scale,
      hjust = 0,
      margin = margin(b = 3)
    ),
    plot.background = element_rect(
      fill = "white",
      color = "white"
    ),
    axis.line = element_blank(),
    axis.title = element_text(
      size = 13 * text_size_scale,
      colour = "black"
    ),
    axis.text = element_text(
      size = 12 * text_size_scale,
      colour = "black"
    ),
    strip.text = element_text(
      size = 12.5 * text_size_scale,
      colour = "black",
      hjust = 0.5,
      margin = margin(3, 3, 3, 3)
    ),
    strip.background = element_rect(
      fill = "transparent", linetype = 0
    ),
    strip.switch.pad.grid = grid::unit(-1, "pt"),
    strip.switch.pad.wrap = grid::unit(-1, "pt"),
    strip.placement = "outside",
    legend.title = element_text(
      size = 12 * text_size_scale,
      colour = "black",
      hjust = 0
    ),
    legend.text = element_text(
      size = 11 * text_size_scale,
      colour = "black"
    ),
    legend.key = element_rect(
      fill = "transparent",
      color = "transparent"
    ),
    legend.key.size = grid::unit(10, "pt"),
    legend.background = element_blank(),
    panel.background = element_rect(
      fill = "white",
      color = "white"
    ),
    panel.border = element_rect(
      fill = "transparent",
      colour = "black",
      linewidth = 1
    )
  )
  args2 <- as.list(match.call())[-1]
  call_envir <- parent.frame(1)
  args2 <- lapply(
    args2, function(arg) {
      if (is.symbol(arg)) {
        eval(arg, envir = call_envir)
      } else if (is.call(arg)) {
        eval(arg, envir = call_envir)
      } else {
        arg
      }
    }
  )
  for (n in names(args2)) {
    args1[[n]] <- args2[[n]]
  }
  args <- args1[names(args1) %in% methods::formalArgs(theme)]
  out <- do.call(
    what = theme,
    args = args
  )
  return(out)
}

#' @title Blank theme
#'
#' @description This function creates a theme with all elements blank except for axis lines and labels.
#' It can optionally add coordinate axes in the plot.
#'
#' @md
#' @param add_coord Whether to add coordinate arrows. Default is `TRUE`.
#' @param xlen_npc The length of the x-axis arrow in "npc".
#' @param ylen_npc The length of the y-axis arrow in "npc".
#' @param xlab The label of the x-axis.
#' @param ylab The label of the y-axis.
#' @param lab_size The size of the axis labels.
#' @param ... Arguments passed to the [ggplot2::theme].
#'
#' @return A list containing ggplot2 theme objects and annotation objects.
#' If `add_coord` is `TRUE`, returns a list with coordinate arrows;
#' otherwise returns a list with theme only.
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(x = wt, y = mpg, colour = factor(cyl))) +
#'   geom_point()
#' p + theme_blank()
#' p + theme_blank(xlab = "x-axis", ylab = "y-axis", lab_size = 16)
theme_blank <- function(
  add_coord = TRUE,
  xlen_npc = 0.15,
  ylen_npc = 0.15,
  xlab = "",
  ylab = "",
  lab_size = 12, ...
) {
  args1 <- list(
    panel.border = element_blank(),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    legend.background = element_blank(),
    legend.box.margin = margin(0, 0, 0, 0),
    legend.margin = margin(0, 0, 0, 0),
    legend.key.size = grid::unit(10, "pt"),
    plot.margin = margin(
      lab_size + 2,
      lab_size + 2,
      lab_size + 2,
      lab_size + 2,
      unit = "points"
    )
  )
  args2 <- as.list(match.call())[-1]
  call_envir <- parent.frame(1)
  args2 <- lapply(
    args2, function(arg) {
      if (is.symbol(arg)) {
        eval(arg, envir = call_envir)
      } else if (is.call(arg)) {
        eval(arg, envir = call_envir)
      } else {
        arg
      }
    }
  )
  for (n in names(args2)) {
    args1[[n]] <- args2[[n]]
  }
  args <- args1[names(args1) %in% methods::formalArgs(theme)]
  out <- do.call(
    what = theme,
    args = args
  )
  if (isTRUE(add_coord)) {
    g <- grid::grobTree(
      grid::gList(
        grid::linesGrob(
          x = grid::unit(c(0, xlen_npc), "npc"),
          y = grid::unit(c(0, 0), "npc"),
          arrow = grid::arrow(
            length = grid::unit(0.02, "npc")
          ),
          gp = grid::gpar(lwd = 2)
        ),
        grid::textGrob(
          label = xlab,
          x = grid::unit(0, "npc"),
          y = grid::unit(0, "npc"),
          vjust = 4 / 3,
          hjust = 0,
          gp = grid::gpar(fontsize = lab_size)
        ),
        grid::linesGrob(
          x = grid::unit(c(0, 0), "npc"),
          y = grid::unit(c(0, ylen_npc), "npc"),
          arrow = grid::arrow(length = grid::unit(0.02, "npc")),
          gp = grid::gpar(lwd = 2)
        ),
        grid::textGrob(
          label = ylab, x = grid::unit(0, "npc"),
          y = grid::unit(0, "npc"),
          vjust = -2 / 3,
          hjust = 0,
          rot = 90,
          gp = grid::gpar(fontsize = lab_size)
        )
      )
    )
    return(list(
      list(ggplot2::annotation_custom(g)),
      list(theme_this() + out),
      list(ggplot2::coord_cartesian(clip = "off"))
    ))
  } else {
    return(list(
      list(theme_this() + out)
    ))
  }
}
