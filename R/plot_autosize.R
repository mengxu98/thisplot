#' @title Automatically size a plot
#'
#' @description
#' Build a compact plot by choosing a physical panel size and expanding it for
#' dense in-panel text or overflowing plot labels. A shared point-size baseline
#' harmonizes ggplot, patchwork, and recorded grid text such as wrapped
#' ComplexHeatmap output while preserving their relative hierarchy. Constant
#' data-label text is enlarged conservatively when space permits. The
#' calculation delegates final layout and saving to
#' [panel_fix()] while preserving label content, fixed aspect ratios, patchwork
#' layouts, and that function's behaviour.
#'
#' @md
#'
#' @param x A ggplot object, grob, or combined plot accepted by [panel_fix()].
#' @param panel_width,panel_height Base panel width and height.
#' @param margin Outer margin.
#' @param units Units for panel dimensions and margin. See [grid::unit()].
#' @param save `NULL` or a file name to save the fitted plot.
#' @param dpi Resolution used when saving raster output.
#' @param base_size `"auto"` to harmonize ggplot and grid text to one inferred
#'   base size in points, a positive point size, or `NULL` to preserve each
#'   component's typography.
#' @param label_autosize Whether to enlarge constant `geom_text`, `geom_label`,
#'   and ggrepel label sizes when the panel has enough horizontal space.
#' @param verbose Whether to report messages from [panel_fix()].
#'
#' @return A plot with `size` and `autosize` attributes. Ordinary plots are
#'   returned through [panel_fix()]; wrapped grid content is preserved directly.
#' @export
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) +
#'   geom_point()
#' p1 <- p +
#'   labs(title = "Fuel economy by vehicle weight")
#' p1
#'
#' p2 <- plot_autosize(p)
#' p2
#'
#' attr(p2, "size")
#'
#' plot_autosize(p1)
plot_autosize <- function(
  x,
  panel_width = 45,
  panel_height = 35,
  margin = 2,
  units = "mm",
  save = NULL,
  dpi = 300,
  base_size = "auto",
  label_autosize = TRUE,
  verbose = FALSE
) {
  for (value in list(panel_width, panel_height, dpi)) {
    if (!is.numeric(value) || length(value) != 1 || is.na(value) || value <= 0) {
      stop("Panel dimensions and dpi must be positive numbers.", call. = FALSE)
    }
  }
  if (!is.numeric(margin) || length(margin) != 1 || is.na(margin) || margin < 0) {
    stop("`margin` must be a non-negative number.", call. = FALSE)
  }
  if (!is.logical(label_autosize) || length(label_autosize) != 1 || is.na(label_autosize)) {
    stop("`label_autosize` must be `TRUE` or `FALSE`.", call. = FALSE)
  }
  if (!is.null(base_size) &&
    !(is.character(base_size) && length(base_size) == 1 && identical(base_size, "auto")) &&
    !(is.numeric(base_size) && length(base_size) == 1 && is.finite(base_size) && base_size > 0)) {
    stop("`base_size` must be `\"auto\"`, `NULL`, or a positive point size.", call. = FALSE)
  }
  text_base_pt <- autosize_resolve_text_base(x, base_size)
  if (is.finite(text_base_pt)) {
    x <- autosize_harmonize_text(x, text_base_pt)
  }
  if (label_autosize) {
    x <- autosize_label_text(x, panel_width, units, text_base_pt)
  }
  x <- autosize_unclip_wrapped(x)
  opened_device <- grDevices::dev.cur() == 1L
  if (opened_device) {
    grDevices::pdf(NULL)
    on.exit(grDevices::dev.off(), add = TRUE)
  }

  text_scale <- c(width = 1, height = 1)
  if (autosize_is_wrapped(x)) {
    size <- autosize_wrapped_size(
      x,
      panel_width = panel_width,
      panel_height = panel_height,
      margin = margin,
      units = units
    )
    return(autosize_preserve(
      x, size, panel_width, panel_height, units, text_scale, text_base_pt, save, dpi
    ))
  }

  if (inherits(x, "plot_filler") || autosize_patchwork_needs_preserve(x)) {
    size <- autosize_nested_size(
      x,
      panel_width = panel_width,
      panel_height = panel_height,
      margin = margin,
      units = units
    )
    return(autosize_preserve(
      x, size, panel_width, panel_height, units, text_scale, text_base_pt, save, dpi
    ))
  }

  if (inherits(x, "ggplot")) {
    if (!inherits(x, "patchwork")) {
      text_scale <- autosize_text_scale(x)
    }
    aspect <- autosize_panel_aspect(x)
    if (is.finite(aspect)) {
      panel_width <- panel_width * max(text_scale)
      panel_height <- panel_width * aspect
      size <- autosize_aspect_size(
        x,
        panel_width = panel_width,
        margin = margin,
        units = units
      )
      return(autosize_preserve(
        x, size, panel_width, panel_height, units, text_scale, text_base_pt, save, dpi
      ))
    }
    panel_width <- panel_width * text_scale[["width"]]
    panel_height <- panel_height * text_scale[["height"]]
    panel_width <- autosize_label_width(
      x,
      width = panel_width,
      height = panel_height,
      margin = margin,
      units = units
    )
  }

  out <- panel_fix(
    x,
    width = panel_width,
    height = panel_height,
    margin = margin,
    units = units,
    save = save,
    dpi = dpi,
    verbose = verbose
  )
  attr(out, "autosize") <- list(
    panel_width = panel_width,
    panel_height = panel_height,
    units = units,
    text_scale = text_scale,
    text_base_pt = text_base_pt
  )
  out
}

#' @title Compose plots at their preferred sizes
#'
#' @description
#' Calculate each plot's preferred physical size and keep every plot at that
#' size. The default publication layout searches compact asymmetric placements
#' with aligned edges, while the ordered layout packs shorter rows continuously
#' and centers them. Apply plot-specific styling before composing.
#'
#' @md
#'
#' @param plots A plot or list of plots accepted by [plot_autosize()].
#' @param ncol,nrow Number of columns and rows. Supplying either uses the ordered
#'   row layout.
#' @param target_aspect Preferred overall width-to-height ratio when `ncol` and
#'   `nrow` are both `NULL`.
#' @param target_width Optional publication target width in `units`. Limits canvas
#'   width to fit journal single-column (e.g. 85 mm) or double-column (e.g. 180 mm) constraints.
#' @param layout `"publication"` for compact asymmetric placement or `"rows"`
#'   to preserve input order in rows.
#' @param gutter Space between components in `units` for the publication layout.
#' @inheritParams plot_autosize
#'
#' @return A wrapped plot with `size` and `autosize` attributes. Component sizes
#'   are stored in `attr(x, "autosize")$components`.
#' @export
#'
#' @examples
#' p1 <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
#'   ggplot2::geom_point()
#' p2 <- p1 + ggplot2::labs(title = "A wider plot title")
#' plot_autocompose(list(p1, p2), ncol = 2)
plot_autocompose <- function(
  plots,
  ncol = NULL,
  nrow = NULL,
  panel_width = 45,
  panel_height = 35,
  margin = 2,
  units = "mm",
  save = NULL,
  dpi = 300,
  base_size = "auto",
  label_autosize = TRUE,
  target_aspect = 1.6,
  target_width = NULL,
  layout = c("publication", "rows"),
  gutter = 4
) {
  layout <- match.arg(layout)
  if (inherits(plots, c("ggplot", "grob", "gList"))) {
    plots <- list(plots)
  }
  if (!is.list(plots) || !length(plots)) {
    stop("`plots` must be a plot or a non-empty list of plots.", call. = FALSE)
  }
  for (value in list(ncol, nrow)) {
    if (!is.null(value) &&
      (!is.numeric(value) || length(value) != 1 || !is.finite(value) ||
        value < 1 || value != as.integer(value))) {
      stop("`ncol` and `nrow` must be positive whole numbers.", call. = FALSE)
    }
  }
  if (!is.logical(label_autosize) || length(label_autosize) != 1 || is.na(label_autosize)) {
    stop("`label_autosize` must be `TRUE` or `FALSE`.", call. = FALSE)
  }
  if (!is.numeric(target_aspect) || length(target_aspect) != 1 ||
    !is.finite(target_aspect) || target_aspect <= 0) {
    stop("`target_aspect` must be a positive number.", call. = FALSE)
  }
  if (!is.null(target_width) &&
    (!is.numeric(target_width) || length(target_width) != 1 ||
      !is.finite(target_width) || target_width <= 0)) {
    stop("`target_width` must be a positive number.", call. = FALSE)
  }
  if (!is.numeric(gutter) || length(gutter) != 1 ||
    !is.finite(gutter) || gutter < 0) {
    stop("`gutter` must be a non-negative number.", call. = FALSE)
  }
  if (!is.null(base_size) &&
    !(is.character(base_size) && length(base_size) == 1 && identical(base_size, "auto")) &&
    !(is.numeric(base_size) && length(base_size) == 1 && is.finite(base_size) && base_size > 0)) {
    stop("`base_size` must be `\"auto\"`, `NULL`, or a positive point size.", call. = FALSE)
  }
  n <- length(plots)
  combined <- patchwork::wrap_plots(plots)
  text_base_pt <- autosize_resolve_text_base(combined, base_size)
  prepared <- lapply(plots, function(plot) {
    if (is.finite(text_base_pt)) {
      plot <- autosize_harmonize_text(plot, text_base_pt)
    }
    if (label_autosize) {
      plot <- autosize_label_text(plot, panel_width, units, text_base_pt)
    }
    autosize_unclip_wrapped(plot)
  })
  fitted <- lapply(prepared, function(plot) {
    plot_autosize(
      plot,
      panel_width = panel_width,
      panel_height = panel_height,
      margin = margin,
      units = units,
      dpi = dpi,
      base_size = NULL,
      label_autosize = FALSE
    )
  })
  widths <- vapply(fitted, function(plot) attr(plot, "size")$width, numeric(1))
  heights <- vapply(fitted, function(plot) attr(plot, "size")$height, numeric(1))
  grobs <- lapply(fitted, function(plot) {
    grob <- if (grid::is.grob(plot)) plot else as_grob(plot)
    if (!grid::is.grob(grob)) {
      stop("Every item in `plots` must be drawable.", call. = FALSE)
    }
    grob
  })

  publication <- identical(layout, "publication") && is.null(ncol) && is.null(nrow)
  packed <- if (publication) {
    autosize_compose_publication(widths, heights, target_aspect, gutter, target_width)
  } else {
    NULL
  }
  if (publication && !is.null(packed)) {
    canvas_width <- packed$width
    canvas_height <- packed$height
    cells <- lapply(seq_len(n), function(i) {
      grid::grobTree(
        grobs[[i]],
        vp = grid::viewport(
          x = grid::unit((packed$x[[i]] + widths[[i]] / 2) / canvas_width, "npc"),
          y = grid::unit((canvas_height - packed$y[[i]] - heights[[i]] / 2) / canvas_height, "npc"),
          width = grid::unit(widths[[i]] / canvas_width, "npc"),
          height = grid::unit(heights[[i]] / canvas_height, "npc")
        )
      )
    })
    component_rows <- rep(NA_integer_, n)
    component_cols <- rep(NA_integer_, n)
    component_x <- packed$x
    component_y <- canvas_height - packed$y - heights
    layout_details <- list(
      type = "publication",
      ncol = NA_integer_,
      nrow = NA_integer_,
      target_aspect = target_aspect,
      target_width = target_width,
      gutter = gutter,
      score = packed$score,
      whitespace = packed$whitespace,
      order = packed$order
    )
  } else {
    layout_score <- NA_real_
    if (is.null(ncol) && is.null(nrow)) {
      selected <- autosize_compose_layout(widths, heights, target_aspect, target_width)
      ncol <- selected[["ncol"]]
      nrow <- selected[["nrow"]]
      layout_score <- selected[["score"]]
    }
    if (is.null(ncol)) {
      ncol <- ceiling(n / nrow)
    }
    if (is.null(nrow)) {
      nrow <- ceiling(n / ncol)
    }
    if (ncol * nrow < n) {
      stop("`ncol * nrow` must fit all plots.", call. = FALSE)
    }

    component_rows <- (seq_len(n) - 1L) %/% ncol + 1L
    component_cols <- (seq_len(n) - 1L) %% ncol + 1L
    row_heights <- vapply(seq_len(nrow), function(i) {
      values <- heights[component_rows == i]
      if (length(values)) max(values) else panel_height
    }, numeric(1))
    row_widths <- vapply(seq_len(nrow), function(i) {
      sum(widths[component_rows == i])
    }, numeric(1))
    canvas_width <- max(row_widths)
    canvas_height <- sum(row_heights)
    row_x <- (canvas_width - row_widths) / 2
    row_y <- canvas_height - cumsum(row_heights) + row_heights / 2
    component_x <- vapply(seq_len(n), function(i) {
      row <- component_rows[[i]]
      row_x[[row]] + sum(widths[component_rows == row & seq_len(n) < i])
    }, numeric(1))
    component_y <- row_y[component_rows] - heights / 2
    cells <- lapply(seq_len(n), function(i) {
      grid::grobTree(
        grobs[[i]],
        vp = grid::viewport(
          x = grid::unit((component_x[[i]] + widths[[i]] / 2) / canvas_width, "npc"),
          y = grid::unit((component_y[[i]] + heights[[i]] / 2) / canvas_height, "npc"),
          width = grid::unit(widths[[i]] / canvas_width, "npc"),
          height = grid::unit(heights[[i]] / canvas_height, "npc")
        )
      )
    })
    layout_details <- list(
      type = "rows",
      ncol = ncol,
      nrow = nrow,
      row_widths = row_widths,
      row_heights = row_heights,
      target_aspect = target_aspect,
      score = layout_score
    )
  }
  out <- patchwork::wrap_elements(
    full = do.call(grid::grobTree, cells),
    clip = FALSE
  ) + ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 0, 0))
  out <- autosize_preserve(
    out,
    c(width = canvas_width, height = canvas_height),
    panel_width,
    panel_height,
    units,
    c(width = 1, height = 1),
    text_base_pt,
    save,
    dpi
  )
  attr(out, "autosize")$components <- data.frame(
    plot = seq_len(n),
    row = component_rows,
    column = component_cols,
    x = component_x,
    y = component_y,
    width = widths,
    height = heights,
    units = units
  )
  attr(out, "autosize")$layout <- layout_details
  out
}

autosize_compose_publication <- function(widths, heights, target_aspect, gutter, target_width = NULL) {
  n <- length(widths)
  # ponytail: publication figures are small; large grids use the ordered layout.
  if (n > 30) {
    return(NULL)
  }
  orders <- list(
    seq_len(n),
    order(widths * heights, decreasing = TRUE),
    order(heights, decreasing = TRUE),
    order(widths, decreasing = TRUE)
  )
  keys <- vapply(orders, paste, collapse = ",", character(1))
  orders <- orders[!duplicated(keys)]
  packed_widths <- widths + gutter
  min_canvas_width <- max(packed_widths)
  max_canvas_width <- sum(packed_widths)
  if (!is.null(target_width)) {
    if (min_canvas_width > target_width + 1e-4) {
      max_canvas_width <- min_canvas_width
    } else {
      max_canvas_width <- min(max_canvas_width, target_width)
    }
  }
  canvas_widths <- unique(seq(
    min_canvas_width,
    max_canvas_width,
    length.out = min(40, max(12, n * 4))
  ))
  if (!is.null(target_width) && target_width >= min_canvas_width) {
    canvas_widths <- unique(sort(c(canvas_widths, target_width)))
  }
  used_area <- sum(widths * heights)
  best <- NULL
  for (candidate_order in orders) {
    for (canvas_width in canvas_widths) {
      packed <- autosize_pack_rectangles(
        widths,
        heights,
        canvas_width,
        candidate_order,
        gutter
      )
      if (is.null(packed)) {
        next
      }
      packed$whitespace <- 1 - used_area / (packed$width * packed$height)
      width_penalty <- if (!is.null(target_width) && packed$width > target_width + 1e-4) {
        (packed$width - target_width) / target_width * 5
      } else {
        0
      }
      order_penalty <- if (identical(candidate_order, seq_len(n))) 0 else 0.04
      packed$score <- abs(log(packed$width / packed$height / target_aspect)) +
        packed$whitespace + width_penalty + order_penalty
      packed$order <- candidate_order
      tied <- !is.null(best) &&
        isTRUE(all.equal(packed$score, best$score, tolerance = 1e-8))
      if (is.null(best) || packed$score < best$score - 1e-8 ||
        tied && packed$width * packed$height < best$width * best$height) {
        best <- packed
      }
    }
  }
  best
}

autosize_pack_rectangles <- function(widths, heights, canvas_width, order, gutter) {
  n <- length(widths)
  packed_widths <- widths + gutter
  packed_heights <- heights + gutter
  positions <- matrix(NA_real_, nrow = n, ncol = 2)
  placed <- integer(0)
  for (i in order) {
    xs <- unique(c(0, positions[placed, 1] + packed_widths[placed]))
    ys <- unique(c(0, positions[placed, 2] + packed_heights[placed]))
    candidates <- expand.grid(x = sort(xs), y = sort(ys))
    candidates <- candidates[order(candidates$y, candidates$x), , drop = FALSE]
    keep <- candidates$x + packed_widths[[i]] <= canvas_width + 1e-8
    if (length(placed)) {
      keep <- keep & vapply(seq_len(nrow(candidates)), function(j) {
        x <- candidates$x[[j]]
        y <- candidates$y[[j]]
        all(
          x + packed_widths[[i]] <= positions[placed, 1] |
            positions[placed, 1] + packed_widths[placed] <= x |
            y + packed_heights[[i]] <= positions[placed, 2] |
            positions[placed, 2] + packed_heights[placed] <= y
        )
      }, logical(1))
    }
    if (!any(keep)) {
      return(NULL)
    }
    chosen <- which(keep)[[1]]
    positions[i, ] <- unlist(candidates[chosen, ], use.names = FALSE)
    placed <- c(placed, i)
  }
  list(
    x = positions[, 1],
    y = positions[, 2],
    width = max(positions[, 1] + packed_widths) - gutter,
    height = max(positions[, 2] + packed_heights) - gutter
  )
}

autosize_compose_layout <- function(widths, heights, target_aspect, target_width = NULL) {
  n <- length(widths)
  used_area <- sum(widths * heights)
  candidates <- vapply(seq_len(n), function(ncol) {
    nrow <- ceiling(n / ncol)
    rows <- (seq_len(n) - 1L) %/% ncol + 1L
    row_widths <- vapply(seq_len(nrow), function(i) {
      sum(widths[rows == i])
    }, numeric(1))
    row_heights <- vapply(seq_len(nrow), function(i) {
      max(heights[rows == i], 0)
    }, numeric(1))
    width <- max(row_widths)
    height <- sum(row_heights)
    whitespace <- 1 - used_area / (width * height)
    width_penalty <- if (!is.null(target_width) && width > target_width + 1e-4) {
      (width - target_width) / target_width * 5
    } else {
      0
    }
    score <- abs(log(width / height / target_aspect)) + whitespace + width_penalty
    c(
      ncol = ncol,
      nrow = nrow,
      score = score
    )
  }, numeric(3))
  candidates[, which.min(candidates["score", ])]
}

autosize_preserve <- function(
  plot,
  size,
  panel_width,
  panel_height,
  units,
  text_scale,
  text_base_pt,
  save,
  dpi
) {
  attr(plot, "size") <- list(
    width = size[["width"]],
    height = size[["height"]],
    units = units
  )
  attr(plot, "autosize") <- list(
    panel_width = panel_width,
    panel_height = panel_height,
    units = units,
    text_scale = text_scale,
    text_base_pt = text_base_pt
  )
  if (!is.null(save) && is.character(save) && length(save) == 1 && nzchar(save)) {
    dir.create(dirname(save), recursive = TRUE, showWarnings = FALSE)
    ggplot2::ggsave(
      filename = save,
      plot = plot,
      width = size[["width"]],
      height = size[["height"]],
      units = units,
      dpi = dpi,
      limitsize = FALSE
    )
  }
  plot
}

autosize_nested_size <- function(plot, panel_width, panel_height, margin, units) {
  plots <- autosize_patchwork_plots(plot)
  if (!length(plots)) {
    return(c(width = panel_width, height = panel_height))
  }
  sizes <- lapply(plots, function(x) {
    attr(plot_autosize(
      x,
      panel_width = panel_width,
      panel_height = panel_height,
      margin = margin,
      units = units,
      base_size = NULL,
      label_autosize = FALSE
    ), "size")
  })
  n <- length(sizes)
  widths <- vapply(sizes, `[[`, numeric(1), "width")
  heights <- vapply(sizes, `[[`, numeric(1), "height")

  des <- plot$patches$layout$design
  if (inherits(des, "patch_area") && length(des$l) >= n) {
    ncol <- max(des$r)
    nrow <- max(des$b)
    col_spans <- des$r[seq_len(n)] - des$l[seq_len(n)] + 1L
    row_spans <- des$b[seq_len(n)] - des$t[seq_len(n)] + 1L

    col_min <- vapply(seq_len(ncol), function(col) {
      active <- which(des$l[seq_len(n)] <= col & des$r[seq_len(n)] >= col)
      if (length(active)) max(widths[active] / col_spans[active], 0) else 0
    }, numeric(1))

    row_min <- vapply(seq_len(nrow), function(row) {
      active <- which(des$t[seq_len(n)] <= row & des$b[seq_len(n)] >= row)
      if (length(active)) max(heights[active] / row_spans[active], 0) else 0
    }, numeric(1))

    col_weight <- plot$patches$layout$widths
    row_weight <- plot$patches$layout$heights
    if (!is.numeric(col_weight) || length(col_weight) != ncol) {
      col_weight <- rep(1, ncol)
    }
    if (!is.numeric(row_weight) || length(row_weight) != nrow) {
      row_weight <- rep(1, nrow)
    }
    return(c(
      width = max(col_min / col_weight) * sum(col_weight) + 2 * margin,
      height = max(row_min / row_weight) * sum(row_weight) + 2 * margin
    ))
  }

  ncol <- plot$patches$layout$ncol
  nrow <- plot$patches$layout$nrow
  if (is.null(ncol) && is.null(nrow)) {
    ncol <- ceiling(sqrt(n))
  }
  if (is.null(ncol)) {
    ncol <- ceiling(n / nrow)
  }
  if (is.null(nrow)) {
    nrow <- ceiling(n / ncol)
  }
  byrow <- !identical(plot$patches$layout$byrow, FALSE)
  rows <- if (byrow) (seq_len(n) - 1L) %/% ncol + 1L else (seq_len(n) - 1L) %% nrow + 1L
  cols <- if (byrow) (seq_len(n) - 1L) %% ncol + 1L else (seq_len(n) - 1L) %/% nrow + 1L
  col_min <- vapply(seq_len(ncol), function(i) max(widths[cols == i], 0), numeric(1))
  row_min <- vapply(seq_len(nrow), function(i) max(heights[rows == i], 0), numeric(1))
  col_weight <- plot$patches$layout$widths
  row_weight <- plot$patches$layout$heights
  if (!is.numeric(col_weight) || length(col_weight) != ncol) {
    col_weight <- rep(1, ncol)
  }
  if (!is.numeric(row_weight) || length(row_weight) != nrow) {
    row_weight <- rep(1, nrow)
  }
  c(
    width = max(col_min / col_weight) * sum(col_weight) + 2 * margin,
    height = max(row_min / row_weight) * sum(row_weight) + 2 * margin
  )
}

autosize_patchwork_plots <- function(plot) {
  plots <- plot$patches$plots
  if (!inherits(plot, "plot_filler")) {
    active <- plot
    active$patches <- NULL
    class(active) <- setdiff(class(active), "patchwork")
    plots <- c(plots, list(active))
  }
  plots
}

autosize_patchwork_needs_preserve <- function(plot) {
  if (!inherits(plot, "patchwork") || autosize_is_wrapped(plot)) {
    return(FALSE)
  }
  layout <- plot$patches$layout
  if (!is.null(layout$widths) || !is.null(layout$heights) || !is.null(layout$design)) {
    return(TRUE)
  }
  any(vapply(
    autosize_patchwork_plots(plot),
    function(x) {
      if (autosize_is_wrapped(x)) {
        TRUE
      } else if (inherits(x, "patchwork")) {
        autosize_patchwork_needs_preserve(x)
      } else {
        is.finite(autosize_panel_aspect(x))
      }
    },
    logical(1)
  ))
}

autosize_is_wrapped <- function(plot) {
  inherits(plot, "wrapped_patch") && !inherits(plot, "patchwork")
}

autosize_unclip_wrapped <- function(plot) {
  if (inherits(plot, "wrapped_patch")) {
    attr(plot, "patch_settings")$clip <- "off"
  }
  if (inherits(plot, "patchwork")) {
    plot$patches$plots <- lapply(plot$patches$plots, autosize_unclip_wrapped)
  }
  plot
}

autosize_theme_base <- function(plot) {
  theme <- ggplot2::theme_get() + plot$theme
  size <- ggplot2::calc_element("text", theme)$size
  if (is.numeric(size) && length(size) == 1 && is.finite(size)) size else numeric(0)
}

autosize_text_bases <- function(plot) {
  grob_fonts <- function(x) {
    out <- numeric(0)
    if (inherits(x, "text") && is.numeric(x$gp$fontsize)) {
      out <- c(out, as.numeric(x$gp$fontsize))
    }
    if (inherits(x, "recordedGrob") && !is.null(x$list$x)) {
      out <- c(out, grob_fonts(x$list$x))
    }
    if (!is.null(x$children)) {
      out <- c(out, unlist(lapply(x$children, grob_fonts), use.names = FALSE))
    }
    if (!is.null(x$grobs)) {
      out <- c(out, unlist(lapply(x$grobs, grob_fonts), use.names = FALSE))
    }
    out[is.finite(out) & out > 0]
  }
  grob_base <- function(x) {
    sizes <- round(grob_fonts(x), 3)
    if (!length(sizes)) {
      return(numeric(0))
    }
    counts <- table(sizes)
    as.numeric(names(counts)[which.max(counts)])
  }

  if (autosize_is_wrapped(plot)) {
    return(grob_base(attr(plot, "grobs")$full))
  }
  if (inherits(plot, "patchwork")) {
    return(unlist(
      lapply(autosize_patchwork_plots(plot), autosize_text_bases),
      use.names = FALSE
    ))
  }
  if (inherits(plot, "ggplot")) {
    return(autosize_theme_base(plot))
  }
  if (grid::is.grob(plot)) {
    return(grob_base(plot))
  }
  numeric(0)
}

autosize_resolve_text_base <- function(plot, base_size) {
  if (is.null(base_size)) {
    return(NA_real_)
  }
  if (is.numeric(base_size)) {
    return(as.numeric(base_size))
  }
  sizes <- autosize_text_bases(plot)
  if (!length(sizes)) 10 else stats::median(sizes)
}

autosize_harmonize_text <- function(plot, base_size) {
  scale_grob <- function(x, factor) {
    if (inherits(x, "text") && is.numeric(x$gp$fontsize)) {
      x$gp$fontsize <- x$gp$fontsize * factor
    }
    if (inherits(x, "recordedGrob") && !is.null(x$list$x)) {
      x$list$x <- scale_grob(x$list$x, factor)
    }
    if (!is.null(x$children)) {
      x$children <- do.call(grid::gList, lapply(x$children, scale_grob, factor = factor))
    }
    if (!is.null(x$grobs)) {
      x$grobs <- lapply(x$grobs, scale_grob, factor = factor)
    }
    x
  }

  if (autosize_is_wrapped(plot)) {
    current <- autosize_text_bases(plot)
    if (length(current) && !isTRUE(all.equal(current[[1]], base_size))) {
      grobs <- attr(plot, "grobs")
      grobs <- lapply(grobs, function(x) {
        if (is.null(x)) x else scale_grob(x, base_size / current[[1]])
      })
      attr(plot, "grobs") <- grobs
    }
    return(plot)
  }
  if (inherits(plot, "patchwork")) {
    plot$patches$plots <- lapply(
      plot$patches$plots,
      autosize_harmonize_text,
      base_size = base_size
    )
    if (!inherits(plot, "plot_filler")) {
      active <- plot
      active$patches <- NULL
      class(active) <- setdiff(class(active), "patchwork")
      active <- autosize_harmonize_text(active, base_size)
      plot$layers <- active$layers
      plot$theme <- active$theme
      if (inherits(active, "wrapped_patch")) {
        attr(plot, "grobs") <- attr(active, "grobs")
      }
    }
    return(plot)
  }
  if (inherits(plot, "ggplot")) {
    current <- autosize_theme_base(plot)
    if (!length(current) || isTRUE(all.equal(current[[1]], base_size))) {
      return(plot)
    }
    factor <- base_size / current[[1]]
    eff_theme <- ggplot2:::plot_theme(plot)
    overrides <- list()
    for (name in names(eff_theme)) {
      element <- eff_theme[[name]]
      if (inherits(element, "element_text") &&
        is.numeric(element$size) && !inherits(element$size, "rel")) {
        overrides[[name]] <- ggplot2::element_text(size = element$size * factor)
      }
    }
    overrides$text <- ggplot2::element_text(size = base_size)
    plot <- plot + do.call(ggplot2::theme, overrides)
    return(plot)
  }
  if (grid::is.grob(plot)) {
    current <- autosize_text_bases(plot)
    if (length(current)) {
      return(scale_grob(plot, base_size / current[[1]]))
    }
  }
  plot
}

autosize_panel_aspect <- function(plot) {
  if (inherits(plot, "patchwork")) {
    return(NA_real_)
  }
  gt <- ggplot2::ggplotGrob(plot)
  if (!isTRUE(gt$respect)) {
    return(NA_real_)
  }
  index <- grep("^panel($|-)", gt$layout$name)[[1]]
  width <- gt$widths[gt$layout$l[[index]]:gt$layout$r[[index]]]
  height <- gt$heights[gt$layout$t[[index]]:gt$layout$b[[index]]]
  if (!all(grid::unitType(width) == "null") || !all(grid::unitType(height) == "null")) {
    return(NA_real_)
  }
  sum(as.numeric(height)) / sum(as.numeric(width))
}

autosize_aspect_size <- function(plot, panel_width, margin, units) {
  gt <- ggplot2::ggplotGrob(plot)
  panels <- grep("^panel($|-)", gt$layout$name)
  panel_cols <- unique(unlist(Map(
    seq,
    gt$layout$l[panels],
    gt$layout$r[panels]
  )))
  panel_rows <- unique(unlist(Map(
    seq,
    gt$layout$t[panels],
    gt$layout$b[panels]
  )))
  width_scale <- panel_width / as.numeric(gt$widths[panel_cols[[1]]])
  body_width <- sum(as.numeric(gt$widths[panel_cols])) * width_scale
  body_height <- sum(as.numeric(gt$heights[panel_rows])) * width_scale
  fixed_widths <- gt$widths[grid::unitType(gt$widths) != "null"]
  fixed_heights <- gt$heights[grid::unitType(gt$heights) != "null"]
  fixed_width <- grid::convertWidth(sum(fixed_widths), units, valueOnly = TRUE)
  fixed_height <- grid::convertHeight(sum(fixed_heights), units, valueOnly = TRUE)
  c(
    width = body_width + fixed_width + 2 * margin,
    height = body_height + fixed_height + 2 * margin
  )
}

autosize_wrapped_size <- function(plot, panel_width, panel_height, margin, units) {
  grob <- attr(plot, "grobs")$full
  if (is.null(grob) || is.null(grob$children)) {
    return(c(width = panel_width, height = panel_height))
  }

  drawn <- list()
  layouts <- list()
  for (child in grob$children) {
    call <- if (is.call(child$expr)) as.character(child$expr[[1]]) else ""
    if (identical(call, "grid.draw")) {
      drawn[[length(drawn) + 1L]] <- child$list$x
    } else if (identical(call, "pushViewport") && !is.null(child$list$vp$layout)) {
      layouts[[length(layouts) + 1L]] <- child$list$vp$layout
    }
  }

  matrix_like <- drawn[vapply(
    drawn,
    function(x) length(x$x) > 4 && length(x$y) > 4,
    logical(1)
  )]
  columns <- sum(vapply(
    matrix_like,
    function(x) length(unique(as.character(x$x))),
    numeric(1)
  ))
  rows <- max(
    0,
    vapply(
      matrix_like,
      function(x) length(unique(as.character(x$y))),
      numeric(1)
    )
  )

  fixed <- function(layout, dimension) {
    value <- layout[[dimension]]
    keep <- !grid::unitType(value) %in% c("null", "npc")
    if (!any(keep)) {
      return(0)
    }
    converter <- if (identical(dimension, "widths")) {
      grid::convertWidth
    } else {
      grid::convertHeight
    }
    converter(sum(value[keep]), "mm", valueOnly = TRUE)
  }
  layout_widths <- vapply(layouts, fixed, numeric(1), dimension = "widths")
  layout_heights <- vapply(layouts, fixed, numeric(1), dimension = "heights")
  fixed_width <- sum(head(sort(layout_widths, decreasing = TRUE), 2))
  fixed_height <- max(0, layout_heights)

  legends <- drawn[vapply(drawn, inherits, logical(1), "packed_legends")]
  legend_height <- max(
    0,
    vapply(
      legends,
      function(x) grid::convertHeight(x$vp$height, "mm", valueOnly = TRUE),
      numeric(1)
    )
  )
  panel_width_mm <- grid::convertWidth(
    grid::unit(panel_width, units), "mm",
    valueOnly = TRUE
  )
  panel_height_mm <- grid::convertHeight(
    grid::unit(panel_height, units), "mm",
    valueOnly = TRUE
  )
  margin_mm <- grid::convertWidth(grid::unit(margin, units), "mm", valueOnly = TRUE)

  # ponytail: recorded grid grobs expose constraints, not a bounding box;
  # use readable cell sizes and keep panel_width/panel_height as calibration.
  matrix_width_mm <- min(columns * 7, panel_width_mm * 4)
  matrix_height_mm <- min(rows * 6, panel_height_mm * 4)
  width_mm <- max(panel_width_mm, matrix_width_mm) + fixed_width + 2 * margin_mm + 2
  height_mm <- max(
    max(panel_height_mm, matrix_height_mm) + fixed_height,
    legend_height
  ) + 2 * margin_mm + 10
  size_mm <- ceiling(c(width = width_mm, height = height_mm) / 5) * 5
  c(
    width = grid::convertWidth(grid::unit(size_mm[["width"]], "mm"), units, valueOnly = TRUE),
    height = grid::convertHeight(grid::unit(size_mm[["height"]], "mm"), units, valueOnly = TRUE)
  )
}

autosize_label_text <- function(plot, panel_width, units, base_size = NA_real_) {
  if (!inherits(plot, "ggplot")) {
    return(plot)
  }
  if (inherits(plot, "patchwork")) {
    plot$patches$plots <- lapply(
      plot$patches$plots,
      autosize_label_text,
      panel_width = panel_width,
      units = units,
      base_size = base_size
    )
    if (!inherits(plot, "plot_filler")) {
      active <- plot
      active$patches <- NULL
      class(active) <- setdiff(class(active), "patchwork")
      active <- autosize_label_text(active, panel_width, units, base_size)
      plot$layers <- active$layers
    }
    return(plot)
  }

  text_layers <- autosize_text_layers(plot)
  if (!any(text_layers)) {
    return(plot)
  }
  built <- tryCatch(ggplot2::ggplot_build(plot), error = function(error) NULL)
  if (is.null(built)) {
    return(plot)
  }
  panel_width_mm <- grid::convertWidth(
    grid::unit(panel_width, units), "mm",
    valueOnly = TRUE
  )
  if (length(base_size) != 1 || !is.finite(base_size)) {
    base_size <- autosize_theme_base(plot)
  }
  if (!length(base_size)) {
    return(plot)
  }
  base_size_mm <- as.numeric(base_size) * 25.4 / 72.27

  for (i in which(text_layers)) {
    layer <- plot$layers[[i]]
    if (!is.null(layer$mapping$size) || !is.null(plot$mapping$size)) {
      next
    }
    data <- built$data[[i]]
    labels <- as.character(data$label)
    keep <- !is.na(labels) & nzchar(labels)
    if (!any(keep)) {
      next
    }
    current <- layer$aes_params$size
    if (is.null(current)) {
      current <- unique(data$size[keep])
    }
    if (!is.numeric(current) || length(current) != 1 || !is.finite(current)) {
      next
    }
    size_unit <- layer$geom_params$size.unit
    if (is.null(size_unit)) {
      size_unit <- "mm"
    }
    current_mm <- grid::convertWidth(
      grid::unit(current, size_unit), "mm",
      valueOnly = TRUE
    )
    panel <- data$PANEL
    if (is.null(panel)) {
      panel <- rep(1, nrow(data))
    }
    groups <- split(seq_len(nrow(data))[keep], panel[keep])
    slots <- max(vapply(
      groups,
      function(index) length(unique(data$x[index][!is.na(data$x[index])])),
      numeric(1)
    ))
    max_characters <- max(nchar(labels[keep]))

    # ponytail: conservative width heuristic; rendered collision solving belongs in ggrepel.
    target_mm <- min(
      base_size_mm,
      current_mm * 1.15,
      panel_width_mm / max(1, slots * max_characters * 0.45)
    )
    if (target_mm <= current_mm) {
      next
    }
    target <- grid::convertWidth(
      grid::unit(target_mm, "mm"), size_unit,
      valueOnly = TRUE
    )
    aes_params <- layer$aes_params
    aes_params$size <- target
    plot$layers[[i]] <- ggplot2::ggproto(NULL, layer, aes_params = aes_params)
  }
  plot
}

autosize_text_layers <- function(plot) {
  vapply(
    plot$layers,
    function(layer) {
      inherits(
        layer$geom,
        c("GeomText", "GeomLabel", "GeomTextRepel", "GeomLabelRepel")
      )
    },
    logical(1)
  )
}

autosize_text_scale <- function(plot) {
  text_layers <- vapply(
    plot$layers,
    function(layer) inherits(layer$geom, c("GeomTextRepel", "GeomLabelRepel")),
    logical(1)
  )
  if (!any(text_layers)) {
    return(c(width = 1, height = 1))
  }

  built <- ggplot2::ggplot_build(plot)
  discrete <- function(scales) {
    length(scales) && all(vapply(scales, function(scale) scale$is_discrete(), logical(1)))
  }
  if (discrete(built$layout$panel_scales_x) || discrete(built$layout$panel_scales_y)) {
    return(c(width = 1, height = 1))
  }
  density <- lapply(built$data[text_layers], function(data) {
    if (is.null(data$label)) {
      return(c(labels = 0, characters = 0))
    }
    panel <- data$PANEL
    if (is.null(panel)) {
      panel <- rep(1, nrow(data))
    }
    labels <- split(as.character(data$label), panel)
    c(
      labels = max(vapply(labels, function(x) sum(!is.na(x) & nzchar(x)), numeric(1))),
      characters = max(vapply(labels, function(x) sum(nchar(x), na.rm = TRUE), numeric(1)))
    )
  })
  density <- do.call(rbind, density)
  max_labels <- max(density[, "labels"], 0)
  max_characters <- max(density[, "characters"], 0)

  # ponytail: density scaling is limited to repelled labels; fixed-position
  # labels keep their geometry and rely on the width check above.
  c(
    width = min(2.5, sqrt(max(1, max_labels / 4, max_characters / 50))),
    height = min(2.5, sqrt(max(1, max_labels / 5, max_characters / 70)))
  )
}

autosize_label_width <- function(plot, width, height, margin, units) {
  gt <- panel_fix(
    plot,
    width = width,
    height = height,
    margin = margin,
    units = units,
    return_grob = TRUE
  )
  metrics <- autosize_label_metrics(gt, units)
  ratios <- vapply(
    metrics,
    function(x) if (x$slot > 0) x$need / x$slot else 1,
    numeric(1)
  )
  width * max(1, ratios, na.rm = TRUE)
}

autosize_label_metrics <- function(gt, units) {
  out <- stats::setNames(vector("list", 3), c("title", "subtitle", "caption"))
  for (name in names(out)) {
    index <- which(gt$layout$name == name)
    if (!length(index) || inherits(gt$grobs[[index[[1]]]], "zeroGrob")) {
      out[[name]] <- list(need = 0, slot = 0)
      next
    }
    index <- index[[1]]
    grob <- gt$grobs[[index]]
    out[[name]] <- list(
      need = grid::convertWidth(grid::grobWidth(grob), units, valueOnly = TRUE),
      slot = grid::convertWidth(
        sum(gt$widths[gt$layout$l[[index]]:gt$layout$r[[index]]]),
        units,
        valueOnly = TRUE
      )
    )
  }
  out
}
