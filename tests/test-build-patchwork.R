library(ggplot2)
library(patchwork)
library(thisplot)

grDevices::pdf(NULL)

panel <- function(title) {
  ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    ggplot2::geom_point(ggplot2::aes(colour = factor(cyl))) +
    ggplot2::labs(title = title, x = "x", y = "y")
}

pw <- patchwork::wrap_plots(
  lapply(c("A", "B", "C", "D"), panel),
  ncol = 2,
  axes = "collect",
  axis_titles = "collect",
  guides = "collect"
) +
  patchwork::plot_annotation(title = "Main title")

built <- thisplot::build_patchwork(pw)

warned <- FALSE
built_tall <- withCallingHandlers(
  thisplot::build_patchwork(pw, table_rows = 36),
  warning = function(w) {
    warned <<- TRUE
    invokeRestart("muffleWarning")
  }
)

grob <- thisplot::patchwork_grob(pw)
reference <- patchwork::patchworkGrob(pw)

stopifnot(
  inherits(built, "gtable"),
  inherits(built, "gtable_patchwork"),
  sum(built$layout$name == "panel-area") == 1,
  all(built$layout$t >= 1),
  all(built$layout$l >= 1),
  all(built$layout$b <= nrow(built)),
  all(built$layout$r <= ncol(built)),
  warned,
  identical(dim(built_tall), dim(built)),
  inherits(grob, "gtable"),
  !inherits(grob, "gtable_patchwork"),
  identical(dim(grob), dim(reference))
)

grDevices::dev.off()
