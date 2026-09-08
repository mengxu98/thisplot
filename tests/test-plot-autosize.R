library(ggplot2)
library(ggrepel)
library(thisplot)

plain <- ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  labs(title = "Fuel economy")
long_title <- plain + labs(title = paste(rep("A measured scientific title", 8), collapse = " "))
labelled <- ggplot(
  transform(mtcars, model = rownames(mtcars)),
  aes(wt, mpg, label = model)
) +
  geom_point() +
  geom_text_repel(max.overlaps = Inf)
bar_labelled <- ggplot(
  transform(mtcars, model = paste0("L", seq_len(nrow(mtcars)))),
  aes(factor(cyl), mpg, label = model)
) +
  geom_point() +
  geom_text_repel(size = 3.5, max.overlaps = Inf)
make_wrapped <- function(columns) {
  wrapped_grob <- grid::grid.grabExpr({
    grid::pushViewport(grid::viewport(
      layout = grid::grid.layout(
        1,
        2,
        widths = grid::unit.c(grid::unit(1, "null"), grid::unit(30, "mm"))
      )
    ))
    grid::pushViewport(grid::viewport(layout.pos.col = 1))
    grid::grid.rect(
      x = grid::unit(rep((seq_len(columns) - 0.5) / columns, each = 12), "npc"),
      y = grid::unit(rep((rev(seq_len(12)) - 0.5) / 12, times = columns), "npc"),
      width = grid::unit(1 / columns, "npc"),
      height = grid::unit(1 / 12, "npc")
    )
    grid::upViewport()
    grid::pushViewport(grid::viewport(layout.pos.col = 2))
    grid::grid.text("Legend")
    grid::upViewport(2)
  }, width = 4, height = 4, wrap = TRUE, wrap.grobs = TRUE)
  patchwork::wrap_elements(full = wrapped_grob)
}
panel_aspect <- function(plot) {
  gt <- ggplotGrob(plot)
  index <- which(gt$layout$name == "panel")[[1]]
  as.numeric(gt$heights[gt$layout$t[[index]]]) /
    as.numeric(gt$widths[gt$layout$l[[index]]])
}
wrapped <- make_wrapped(8)
wide_wrapped <- make_wrapped(100)
wrapped_file <- tempfile(fileext = ".pdf")
fixed <- plain + coord_fixed()
ratioed <- plain + theme(aspect.ratio = 2)
nested <- (plain | plain) / (plain | plain)
flat <- patchwork::wrap_plots(rep(list(plain), 4), ncol = 2)
label_patch <- patchwork::wrap_plots(rep(list(labelled), 3), ncol = 2)
fixed_patch <- fixed | fixed
weighted_patch <- (plain | plain) + patchwork::plot_layout(widths = c(1, 2))
base10 <- plain + theme(text = element_text(size = 10), plot.title = element_text(size = 12))
base14 <- plain + theme(text = element_text(size = 14), plot.title = element_text(size = 16.8))
mixed_text <- base10 | base14
text_grob <- grid::grobTree(
  grid::textGrob("Body", gp = grid::gpar(fontsize = 10)),
  grid::textGrob("Title", gp = grid::gpar(fontsize = 14))
)
mixed_grid <- base14 | patchwork::wrap_elements(full = text_grob)

original_title <- long_title$labels$title
original_label_size <- bar_labelled$layers[[2]]$aes_params$size
adjusted_labels <- thisplot:::autosize_label_text(bar_labelled, 45, "mm")
text_base <- thisplot:::autosize_resolve_text_base(mixed_text, "auto")
grid_base <- thisplot:::autosize_resolve_text_base(mixed_grid, "auto")
harmonized_text <- thisplot:::autosize_harmonize_text(mixed_text, text_base)
harmonized_grid <- thisplot:::autosize_harmonize_text(mixed_grid, grid_base)
plain_fit <- plot_autosize(plain)
title_fit <- plot_autosize(long_title)
label_fit <- plot_autosize(labelled)
bar_fit <- plot_autosize(bar_labelled)
wrapped_fit <- plot_autosize(wrapped, save = wrapped_file)
wide_wrapped_fit <- plot_autosize(wide_wrapped)
fixed_fit <- plot_autosize(fixed)
ratioed_fit <- plot_autosize(ratioed)
nested_fit <- plot_autosize(nested)
flat_fit <- plot_autosize(flat)
label_patch_fit <- plot_autosize(label_patch)
fixed_patch_fit <- plot_autosize(fixed_patch)
weighted_patch_fit <- plot_autosize(weighted_patch)
mixed_text_fit <- plot_autosize(mixed_text)
composed_fit <- plot_autocompose(
  list(plain, long_title),
  ncol = 2,
  label_autosize = FALSE
)
auto_six_fit <- plot_autocompose(
  rep(list(plain), 6),
  label_autosize = FALSE
)
ordered_six_fit <- plot_autocompose(
  rep(list(plain), 6),
  layout = "rows",
  label_autosize = FALSE
)
packed_fit <- plot_autocompose(
  list(long_title, plain, plain),
  ncol = 2,
  label_autosize = FALSE
)
mixed_layout <- thisplot:::autosize_compose_layout(
  c(179, 279, 259, 110.2, 110.2, 110.2, 117.3, 117.3),
  c(114, 164, 169, 79.5, 79.5, 79.5, 75.6, 75.6),
  1.6
)
publication_widths <- c(179, 279, 259, 110.2, 110.2, 110.2, 117.3, 117.3)
publication_heights <- c(114, 164, 169, 79.5, 79.5, 79.5, 75.6, 75.6)
publication_layout <- thisplot:::autosize_compose_publication(
  publication_widths,
  publication_heights,
  1.6,
  4
)
publication_overlap <- FALSE
for (i in seq_len(length(publication_widths) - 1L)) {
  for (j in seq.int(i + 1L, length(publication_widths))) {
    publication_overlap <- publication_overlap || !(
      publication_layout$x[[i]] + publication_widths[[i]] <= publication_layout$x[[j]] |
        publication_layout$x[[j]] + publication_widths[[j]] <= publication_layout$x[[i]] |
        publication_layout$y[[i]] + publication_heights[[i]] <= publication_layout$y[[j]] |
        publication_layout$y[[j]] + publication_heights[[j]] <= publication_layout$y[[i]]
    )
  }
}
composed_components <- attr(composed_fit, "autosize")$components
composed_layout <- attr(composed_fit, "autosize")$layout
packed_components <- attr(packed_fit, "autosize")$components
packed_layout <- attr(packed_fit, "autosize")$layout
plain_panel_fit <- panel_fix(plain, width = 45, height = 35, margin = 2, units = "mm")

# Regression test: Global theme inheritance
old_theme <- theme_get()
theme_set(theme_this())
global_plain <- ggplot(mtcars, aes(wt, mpg)) + geom_point() + labs(title = "Title")
global_harm <- thisplot:::autosize_harmonize_text(global_plain, base_size = 7)
eff_global_harm <- ggplot2:::plot_theme(global_harm)
theme_set(old_theme)

# Regression test: Top-to-bottom, left-to-right reading order
four_plots <- list(plain, plain, plain, plain)
comp_four <- plot_autocompose(four_plots, layout = "publication", target_aspect = 1.0, label_autosize = FALSE)
comp_four_df <- attr(comp_four, "autosize")$components

# Regression test: Target width publication constraint
target_width_fit <- plot_autocompose(
  rep(list(plain), 6),
  target_width = 180,
  label_autosize = FALSE
)

# Regression test: Patchwork design span calculation
pw_design <- (plain + plain + plain + plain) + patchwork::plot_layout(design = "112\n344")
pw_design_size <- thisplot:::autosize_nested_size(pw_design, 45, 35, 2, "mm")

stopifnot(
  attr(plain_fit, "size")$width > 0,
  isTRUE(all.equal(attr(plain_fit, "size"), attr(plain_panel_fit, "size"))),
  attr(title_fit, "size")$width > attr(plain_fit, "size")$width,
  identical(long_title$labels$title, original_title),
  identical(bar_labelled$layers[[2]]$aes_params$size, original_label_size),
  adjusted_labels$layers[[2]]$aes_params$size > original_label_size,
  adjusted_labels$layers[[2]]$aes_params$size < 4.5,
  is.na(thisplot:::autosize_resolve_text_base(mixed_text, NULL)),
  identical(thisplot:::autosize_resolve_text_base(mixed_text, 9), 9),
  isTRUE(all.equal(text_base, 12)),
  isTRUE(all.equal(grid_base, 12)),
  identical(sort(thisplot:::autosize_text_bases(harmonized_text)), c(12, 12)),
  identical(sort(thisplot:::autosize_text_bases(harmonized_grid)), c(12, 12)),
  identical(sort(thisplot:::autosize_text_bases(mixed_text)), c(10, 14)),
  thisplot:::autosize_patchwork_needs_preserve(mixed_grid),
  isTRUE(all.equal(attr(mixed_text_fit, "autosize")$text_base_pt, 12)),
  nrow(composed_components) == 2,
  identical(composed_layout$ncol, 2),
  identical(attr(auto_six_fit, "autosize")$layout$type, "publication"),
  attr(ordered_six_fit, "autosize")$layout$ncol == 3,
  mixed_layout[["ncol"]] == 3,
  publication_layout$width < 600,
  publication_layout$whitespace < 0.2,
  !publication_overlap,
  isTRUE(all.equal(composed_layout$row_widths, sum(composed_components$width))),
  isTRUE(all.equal(packed_layout$row_widths[[2]], packed_components$width[[3]])),
  isTRUE(all.equal(attr(composed_fit, "size")$width, sum(composed_components$width))),
  attr(composed_fit, "size")$width < 2 * max(composed_components$width),
  attr(label_fit, "autosize")$text_scale[["width"]] > 1,
  identical(attr(bar_fit, "autosize")$text_scale, c(width = 1, height = 1)),
  attr(label_fit, "autosize")$panel_width > 45,
  file.exists(wrapped_file),
  identical(attr(wrapped_fit, "patch_settings")$clip, "off"),
  attr(wrapped_fit, "size")$width >= 80,
  attr(wrapped_fit, "size")$height >= 80,
  attr(wide_wrapped_fit, "size")$width < 250,
  isTRUE(all.equal(
    attr(fixed_fit, "autosize")$panel_height /
      attr(fixed_fit, "autosize")$panel_width,
    panel_aspect(fixed)
  )),
  isTRUE(all.equal(
    attr(ratioed_fit, "autosize")$panel_height /
      attr(ratioed_fit, "autosize")$panel_width,
    2
  )),
  attr(nested_fit, "size")$width >= attr(flat_fit, "size")$width * 0.8,
  attr(nested_fit, "size")$height >= attr(flat_fit, "size")$height * 0.8,
  identical(attr(label_patch_fit, "autosize")$text_scale, c(width = 1, height = 1)),
  identical(
    fixed_patch_fit$patches$plots[[1]]$coordinates$ratio,
    fixed_patch$patches$plots[[1]]$coordinates$ratio
  ),
  identical(
    weighted_patch_fit$patches$layout$widths,
    weighted_patch$patches$layout$widths
  ),
  calc_element("text", eff_global_harm)$size == 7,
  calc_element("plot.title", eff_global_harm)$size < 10,
  calc_element("axis.title", eff_global_harm)$size < 9,
  calc_element("axis.text", eff_global_harm)$size < 8,
  comp_four_df$y[1] > comp_four_df$y[3],
  comp_four_df$x[1] < comp_four_df$x[2],
  attr(target_width_fit, "size")$width <= 180 + 1e-4,
  pw_design_size[["width"]] > 150
)
