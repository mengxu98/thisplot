test_that("theme_blank leaves room for coordinate annotation", {
  theme_layers <- thisplot::theme_blank(add_coord = FALSE, lab_size = 12)
  plot_margin <- theme_layers[[1]][[1]]$plot.margin

  expect_equal(as.numeric(plot_margin), rep(20, 4))
})
