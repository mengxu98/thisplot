library(thisplot)

(function() {
  output <- tempfile(fileext = ".pdf")
  grDevices::pdf(output, width = 7, height = 7)
  on.exit({
    grDevices::dev.off()
    unlink(output)
  })
  for (panel_height in c(40, 80, 120)) {
    for (arrow_length in c(0.1, 0.15, 0.3)) {
      for (label_size in c(10, 16)) {
        grid::pushViewport(grid::viewport(
          width = grid::unit(80, "mm"), height = grid::unit(panel_height, "mm")
        ))
        annotation <- theme_blank(xlab = "UMAP_1", ylab = "UMAP_2",
                                  ylen_npc = arrow_length, lab_size = label_size)[[1L]][[1L]]
        children <- as.list(annotation$geom_params$grob$children)
        label <- Filter(function(g) inherits(g, "text") && identical(g$label, "UMAP_2"), children)[[1L]]
        axis <- Filter(function(g) inherits(g, "lines") && all(as.numeric(g$x) == 0), children)[[1L]]
        label_center <- grid::convertY(label$y, "mm", valueOnly = TRUE)
        axis_center <- mean(grid::convertY(axis$y, "mm", valueOnly = TRUE))
        if (abs(label_center - axis_center) > 1e-7) {
          stop(sprintf("Y label center %.3f mm differs from arrow midpoint %.3f mm", label_center, axis_center))
        }
        stopifnot(label$rot == 90, label$hjust == 0.5, label$vjust == 0.5)
        grid::popViewport()
      }
    }
  }
})()
