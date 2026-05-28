statplot_venn_data <- function() {
  data.frame(
    A = c(TRUE, TRUE, FALSE, FALSE, TRUE, FALSE),
    B = c(TRUE, FALSE, TRUE, FALSE, TRUE, FALSE),
    C = c(FALSE, TRUE, TRUE, FALSE, TRUE, FALSE),
    D = c(FALSE, FALSE, TRUE, TRUE, TRUE, FALSE),
    E = c(TRUE, FALSE, FALSE, TRUE, FALSE, TRUE),
    Split = factor(c("S1", "S1", "S1", "S2", "S2", "S2"))
  )
}

test_that("StatPlot venn keeps ggVennDiagram as the default engine", {
  skip_if_not_installed("ggVennDiagram")

  p <- StatPlot(
    meta.data = statplot_venn_data(),
    stat.by = c("A", "B", "C"),
    stat_level = TRUE,
    plot_type = "venn"
  )

  expect_s3_class(p, "ggplot")
  expect_null(attr(p, "venny_detail", exact = TRUE))
})

test_that("StatPlot venn can use the venny engine", {
  skip_if_not_installed("venny")

  p <- StatPlot(
    meta.data = statplot_venn_data(),
    stat.by = c("A", "B", "C"),
    stat_level = TRUE,
    plot_type = "venn",
    venn_engine = "venny"
  )

  expect_s3_class(p, "ggplot")
})

test_that("StatPlot preserves venny detail results", {
  skip_if_not_installed("venny")

  p <- StatPlot(
    meta.data = statplot_venn_data(),
    stat.by = c("A", "B", "C"),
    stat_level = TRUE,
    plot_type = "venn",
    venn_engine = "venny",
    venn_args = list(detail = TRUE)
  )

  detail <- attr(p, "venny_detail", exact = TRUE)
  expect_type(detail, "list")
  expect_true(all(c("venn", "ellipse_path", "table", "subset_elements") %in% names(detail)))
})

test_that("StatPlot preserves split venny detail results on combined plots", {
  skip_if_not_installed("venny")

  p <- StatPlot(
    meta.data = statplot_venn_data(),
    stat.by = c("A", "B", "C"),
    split.by = "Split",
    stat_level = TRUE,
    plot_type = "venn",
    venn_engine = "venny",
    venn_args = list(detail = TRUE)
  )

  detail <- attr(p, "venny_detail", exact = TRUE)
  expect_type(detail, "list")
  expect_named(detail, c("S1", "S2"))
  expect_true(all(vapply(
    detail,
    function(x) all(c("venn", "ellipse_path", "table", "subset_elements") %in% names(x)),
    logical(1)
  )))
})

test_that("StatPlot rejects venny venns with more than four sets", {
  expect_error(
    StatPlot(
      meta.data = statplot_venn_data(),
      stat.by = c("A", "B", "C", "D", "E"),
      stat_level = TRUE,
      plot_type = "venn",
      venn_engine = "venny"
    ),
    "2 to 4"
  )
})
