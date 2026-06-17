make_stat_plot_data <- function() {
  data.frame(
    Type = factor(c("A", "B", "A", "B")),
    Group = factor(c("G1", "G1", "G2", "G2"))
  )
}

test_that("StatPlot exposes direct x-axis text angle control", {
  plot <- StatPlot(
    make_stat_plot_data(),
    stat.by = "Type",
    group.by = "Group",
    plot_type = "trend",
    x_text_angle = 0
  )

  expect_identical(plot$theme$axis.text.x$angle, 0)
})

test_that("StatPlot validates x_text_angle", {
  expect_error(
    StatPlot(
      make_stat_plot_data(),
      stat.by = "Type",
      group.by = "Group",
      plot_type = "trend",
      x_text_angle = c(45, Inf)
    ),
    "finite number"
  )
})

test_that("StatPlot uses grid_major for percent trend plots", {
  plot_on <- StatPlot(
    make_stat_plot_data(),
    stat.by = "Type",
    group.by = "Group",
    plot_type = "trend",
    stat_type = "percent",
    grid_major = TRUE,
    grid_major_colour = "red",
    grid_major_linetype = 3,
    grid_major_linewidth = 0.7
  )
  plot_off <- StatPlot(
    make_stat_plot_data(),
    stat.by = "Type",
    group.by = "Group",
    plot_type = "trend",
    stat_type = "percent",
    grid_major = FALSE
  )

  expect_s3_class(plot_on$theme$panel.grid.major, "element_line")
  expect_identical(plot_on$theme$panel.grid.major$colour, "red")
  expect_identical(plot_on$theme$panel.grid.major$linetype, 3)
  expect_identical(plot_on$theme$panel.grid.major$linewidth, 0.7)
  expect_s3_class(plot_off$theme$panel.grid.major, "element_blank")
})
