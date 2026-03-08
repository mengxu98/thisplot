#' @title Compute fixed heatmap device size
#'
#' @md
#' @param width Optional user-provided target width. If `NULL`, width is
#' estimated from the drawn heatmap layout.
#' @param width_sum Numeric baseline width used when heatmap body size is in
#' `npc` units.
#' @param height Optional user-provided target height. If `NULL`, height is
#' estimated from the drawn heatmap layout.
#' @param height_sum Numeric baseline height used when heatmap body size is in
#' `npc` units.
#' @param units Output unit string passed to grid conversion helpers, such as
#' `"in"`, `"cm"`, or `"mm"`.
#' @param ht_list A `ComplexHeatmap::Heatmap` or
#' `ComplexHeatmap::HeatmapList` object.
#' @param legend_list A list of `ComplexHeatmap::Legend` objects.
#'
#' @return A list with two converted units: `ht_width` and `ht_height`.
#'
#' @export
#'
#' @examples
#' mat <- matrix(rnorm(100), nrow = 10)
#' ht <- ComplexHeatmap::Heatmap(mat, name = "expr")
#' lgd <- list(ComplexHeatmap::Legend(title = "expr", at = c(-2, 0, 2)))
#' out <- heatmap_fixsize(
#'   width = NULL,
#'   width_sum = 6,
#'   height = NULL,
#'   height_sum = 4,
#'   units = "in",
#'   ht_list = ht,
#'   legend_list = lgd
#' )
#' out
heatmap_fixsize <- function(
  width,
  width_sum,
  height,
  height_sum,
  units,
  ht_list,
  legend_list
) {
  unit_value_or_zero <- function(u, units, type = c("width", "height")) {
    type <- match.arg(type)
    if (length(u) == 0) {
      return(0)
    }
    if (type == "width") {
      return(grid::convertWidth(u, units, valueOnly = TRUE))
    }
    grid::convertHeight(u, units, valueOnly = TRUE)
  }

  ht <- ComplexHeatmap::draw(
    ht_list,
    annotation_legend_list = legend_list
  )
  ht_width <- ht@ht_list_param$width
  ht_height <- ht@ht_list_param$height

  if (grid::unitType(ht_width) == "npc") {
    ht_width <- grid::unit(width_sum, units = units)
  }
  if (grid::unitType(ht_height) == "npc") {
    ht_height <- grid::unit(height_sum, units = units)
  }
  if (is.null(width)) {
    legend_size <- ht@annotation_legend_param$size
    ht_width <- max(
      grid::convertWidth(
        ht@layout$max_left_component_width,
        units,
        valueOnly = TRUE
      ) +
        grid::convertWidth(
          ht@layout$max_right_component_width,
          units,
          valueOnly = TRUE
        ) +
        grid::convertWidth(
          sum(ht@layout$max_title_component_width),
          units,
          valueOnly = TRUE
        ) +
        grid::convertWidth(
          grid::unit(
            unit_value_or_zero(
              if (length(legend_size) >= 1) legend_size[1] else legend_size,
              units,
              type = "width"
            ),
            units
          ),
          units,
          valueOnly = TRUE
        ) +
        grid::convertWidth(
          grid::unit(1, "in"),
          units,
          valueOnly = TRUE
        ),
      grid::convertWidth(
        grid::unit(0.95, "npc"),
        units,
        valueOnly = TRUE
      )
    )
    ht_width <- grid::unit(ht_width, units)
  }
  if (is.null(height)) {
    legend_size <- ht@annotation_legend_param$size
    ht_height <- max(
      grid::convertHeight(
        ht@layout$max_top_component_height,
        units,
        valueOnly = TRUE
      ) +
        grid::convertHeight(
          ht@layout$max_bottom_component_height,
          units,
          valueOnly = TRUE
        ) +
        grid::convertHeight(
          sum(ht@layout$max_title_component_height),
          units,
          valueOnly = TRUE
        ) +
        grid::convertHeight(
          grid::unit(1, "in"),
          units,
          valueOnly = TRUE
        ),
      unit_value_or_zero(
        if (length(legend_size) >= 2) legend_size[2] else legend_size,
        units,
        type = "height"
      ),
      grid::convertHeight(
        grid::unit(0.95, "npc"),
        units,
        valueOnly = TRUE
      )
    )
    ht_height <- grid::unit(ht_height, units)
  }
  ht_width <- grid::convertUnit(ht_width, unitTo = units)
  ht_height <- grid::convertUnit(ht_height, unitTo = units)

  list(
    ht_width = ht_width,
    ht_height = ht_height
  )
}

#' @title Estimate heatmap render size
#'
#' @md
#' @param width Numeric vector of heatmap body widths.
#' Interpretation depends on `flip`.
#' @param height Numeric vector of heatmap body heights.
#' Interpretation depends on `flip`.
#' @param units Unit string for numeric-to-grid conversion (for example, `"in"`, `"cm"`, `"mm"`).
#' @param ha_top_list A list of top annotations (typically `ComplexHeatmap::HeatmapAnnotation` objects).
#' @param ha_left Optional left annotation.
#' @param ha_right Optional right annotation.
#' @param ht_list A `ComplexHeatmap::Heatmap` or
#' `ComplexHeatmap::HeatmapList` object.
#' @param legend_list A list containing legend objects; `NULL` entries are ignored.
#' @param flip Logical; when `TRUE`, width/height interpretation follows the flipped layout branch.
#'
#' @return A list with numeric `width_sum` and `height_sum` in `units`.
#'
#' @export
#'
#' @examples
#' mat <- matrix(rnorm(100), nrow = 10)
#' ht <- ComplexHeatmap::Heatmap(mat, name = "expr")
#' size <- heatmap_rendersize(
#'   width = c(4),
#'   height = c(3),
#'   units = "in",
#'   ha_top_list = list(),
#'   ha_left = NULL,
#'   ha_right = NULL,
#'   ht_list = ht,
#'   legend_list = list(),
#'   flip = FALSE
#' )
#' size
heatmap_rendersize <- function(
  width,
  height,
  units,
  ha_top_list,
  ha_left,
  ha_right,
  ht_list,
  legend_list,
  flip
) {
  legend_list <- legend_list[!vapply(legend_list, is.null, logical(1))]

  width_annotation <- height_annotation <- 0
  if (isTRUE(flip)) {
    width_sum <- width[1] %||%
      grid::convertWidth(
        grid::unit(1, "in"),
        units,
        valueOnly = TRUE
      )
    height_sum <- sum(
      height %||% grid::convertHeight(
        grid::unit(1, "in"),
        units,
        valueOnly = TRUE
      )
    )
    if (length(ha_top_list) > 0) {
      width_annotation <- grid::convertWidth(
        grid::unit(width_annotation, units) +
          ComplexHeatmap::width.HeatmapAnnotation(ha_top_list[[1]]),
        units,
        valueOnly = TRUE
      )
    }
    if (!is.null(ha_left)) {
      height_annotation <- grid::convertHeight(
        grid::unit(height_annotation, units) +
          ComplexHeatmap::height.HeatmapAnnotation(ha_left),
        units,
        valueOnly = TRUE
      )
    }
    if (!is.null(ha_right)) {
      height_annotation <- grid::convertHeight(
        grid::unit(height_annotation, units) +
          ComplexHeatmap::height.HeatmapAnnotation(ha_right),
        units,
        valueOnly = TRUE
      )
    }
  } else {
    width_sum <- sum(
      width %||% grid::convertWidth(
        grid::unit(1, "in"),
        units,
        valueOnly = TRUE
      )
    )
    height_sum <- height[1] %||%
      grid::convertHeight(grid::unit(1, "in"), units, valueOnly = TRUE)
    if (length(ha_top_list) > 0) {
      height_annotation <- grid::convertHeight(
        grid::unit(height_annotation, units) +
          ComplexHeatmap::height.HeatmapAnnotation(ha_top_list[[1]]),
        units,
        valueOnly = TRUE
      )
    }
    if (!is.null(ha_left)) {
      width_annotation <- grid::convertWidth(
        grid::unit(width_annotation, units) +
          ComplexHeatmap::width.HeatmapAnnotation(ha_left),
        units,
        valueOnly = TRUE
      )
    }
    if (!is.null(ha_right)) {
      width_annotation <- grid::convertWidth(
        grid::unit(width_annotation, units) +
          ComplexHeatmap::width.HeatmapAnnotation(ha_right),
        units,
        valueOnly = TRUE
      )
    }
  }
  dend_width <- name_width <- NULL
  dend_height <- name_height <- NULL
  if (inherits(ht_list, "HeatmapList")) {
    for (nm in names(ht_list@ht_list)) {
      ht <- ht_list@ht_list[[nm]]
      dend_width <- max(ht@row_dend_param$width, dend_width)
      dend_height <- max(ht@column_dend_param$height, dend_height)
      name_width <- max(ht@row_names_param$max_width, name_width)
      name_height <- max(ht@column_names_param$max_height, name_height)
    }
  } else if (inherits(ht_list, "Heatmap")) {
    ht <- ht_list
    dend_width <- max(ht@row_dend_param$width, dend_width)
    dend_height <- max(ht@column_dend_param$height, dend_height)
    name_width <- max(ht@row_names_param$max_width, name_width)
    name_height <- max(ht@column_names_param$max_height, name_height)
  } else {
    log_message(
      "{.arg ht_list} is not a class of HeatmapList or Heatmap",
      message_type = "error"
    )
  }

  lgd_width <- numeric(0)
  if (length(legend_list) > 0) {
    legend_widths <- lapply(legend_list, function(x) {
      out <- tryCatch(
        ComplexHeatmap::width.Legends(x),
        error = function(e) NULL
      )
      if (is.null(out) || length(out) == 0) {
        return(NULL)
      }
      out
    })
    legend_widths <- legend_widths[!vapply(legend_widths, is.null, logical(1))]
    if (length(legend_widths) > 0) {
      lgd_width <- vapply(
        legend_widths,
        function(w) grid::convertWidth(w, unitTo = units, valueOnly = TRUE),
        numeric(1)
      )
    }
  }
  width_sum <- grid::convertWidth(
    grid::unit(width_sum, units) +
      grid::unit(width_annotation, units) +
      dend_width +
      name_width,
    units,
    valueOnly = TRUE
  ) +
    sum(lgd_width)
  height_sum <- max(
    grid::convertHeight(
      grid::unit(height_sum, units) +
        grid::unit(height_annotation, units) +
        dend_height +
        name_height,
      units,
      valueOnly = TRUE
    ),
    grid::convertHeight(
      grid::unit(0.95, "npc"),
      units,
      valueOnly = TRUE
    )
  )
  return(
    list(
      width_sum = width_sum,
      height_sum = height_sum
    )
  )
}

#' @title Cluster within group
#'
#' @param mat A matrix of data
#' @param factor A factor
#'
#' @return A dendrogram with ordered leaves
#'
#' @export
#'
#' @examples
#' mat <- matrix(rnorm(100), 10, 10)
#' factor <- factor(rep(1:2, each = 5))
#' dend <- cluster_within_group2(mat, factor)
#' dend
#' plot(dend)
cluster_within_group2 <- function(mat, factor) {
  if (!is.factor(factor)) {
    factor <- factor(factor, levels = unique(factor))
  }
  dend_list <- list()
  order_list <- list()
  for (le in unique(levels(factor))) {
    m <- mat[, factor == le, drop = FALSE]
    if (ncol(m) == 1) {
      order_list[[le]] <- which(factor == le)
      dend_list[[le]] <- structure(
        which(factor == le),
        class = "dendrogram",
        leaf = TRUE,
        label = 1,
        members = 1
      )
    } else if (ncol(m) > 1) {
      hc1 <- stats::hclust(
        stats::as.dist(
          proxyC::dist(Matrix::t(m))
        )
      )
      dend_list[[le]] <- stats::as.dendrogram(hc1)
      dend_order <- stats::order.dendrogram(dend_list[[le]])
      order_list[[le]] <- which(factor == le)[dend_order]
      dendextend::order.dendrogram(dend_list[[le]]) <- order_list[[le]]
    }
    attr(dend_list[[le]], ".class_label") <- le
  }
  parent <- stats::as.dendrogram(
    stats::hclust(
      stats::as.dist(
        proxyC::dist(
          Matrix::t(sapply(
            order_list,
            function(x) rowMeans(mat[, x, drop = FALSE])
          ))
        )
      )
    )
  )
  dend_list <- lapply(dend_list, function(dend) {
    stats::dendrapply(
      dend,
      function(node) {
        if (is.null(attr(node, "height"))) {
          attr(node, "height") <- 0
        }
        node
      }
    )
  })

  dend <- ComplexHeatmap::merge_dendrogram(parent, dend_list)
  dendextend::order.dendrogram(dend) <- unlist(
    order_list[stats::order.dendrogram(parent)]
  )
  dend
}

#' @title Normalize drawable objects to grobs
#'
#' @param obj A drawable object, such as a ggplot, patchwork, or grid grob.
#'
#' @return A grid grob object. If the input is not drawable, returns a null grob.
#' @export
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
#'   ggplot2::geom_point()
#' g <- normalize_drawable(p)
#' p + g
normalize_drawable <- function(obj) {
  x <- obj
  while (is.list(x) && length(x) > 0) {
    x <- x[[1]]
  }
  if (is.null(x)) {
    return(grid::nullGrob())
  }
  if (inherits(x, "patchwork")) {
    return(patchwork::patchworkGrob(x))
  }
  if (ggplot2::is.ggplot(x)) {
    x <- x + ggplot2::theme_void() + ggplot2::theme(
      plot.title = ggplot2::element_blank(),
      plot.subtitle = ggplot2::element_blank(),
      legend.position = "none",
      axis.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      strip.text = ggplot2::element_blank(),
      strip.background = ggplot2::element_blank()
    )
    return(ggplot2::ggplotGrob(x))
  }
  if (inherits(x, c("grob", "gTree"))) {
    return(x)
  }
  grid::nullGrob()
}

#' @title Build graphics callback list for anno_customize
#'
#' @md
#' @param subplots A named list of subplot objects.
#' @param prefix Prefix used to generate stable grob names.
#'
#' @return A named list of callback functions accepted by [ComplexHeatmap::anno_customize].
#'
#' @export
annotation_graphics <- function(subplots, prefix) {
  graphics <- list()
  for (nm in names(subplots)) {
    graphics[[nm]] <- local({
      p0 <- subplots[[nm]]
      g_name <- paste0(prefix, "-", nm)
      function(x, y, w, h) {
        g <- tryCatch(
          normalize_drawable(p0),
          error = function(e) grid::nullGrob()
        )
        g$name <- g_name
        tryCatch(
          grid::grid.draw(g),
          error = function(e) {
            grid::grid.draw(grid::nullGrob())
          }
        )
      }
    })
  }
  graphics
}

#' @title Build block panel function
#'
#' @md
#' @param subplot A single drawable subplot object.
#' @param name A name assigned to the generated grob.
#' @param border Whether to draw a rectangle border around the block.
#'
#' @return A function with signature `(index, levels)` suitable for `panel_fun` in [ComplexHeatmap::anno_block].
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#' p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
#'   ggplot2::geom_point()
#' panel_fun <- annotation_block_graphics(
#'   subplot = p, name = "demo-block"
#' )
#' ComplexHeatmap::anno_block(panel_fun = panel_fun)
annotation_block_graphics <- function(
  subplot, name, border = TRUE
) {
  p0 <- subplot
  g_name <- name
  function(index, levels) {
    g <- tryCatch(
      normalize_drawable(p0),
      error = function(e) grid::nullGrob()
    )
    g$name <- g_name
    tryCatch(
      grid::grid.draw(g),
      error = function(e) {
        grid::grid.draw(grid::nullGrob())
      }
    )
    if (isTRUE(border)) {
      grid::grid.rect(
        gp = grid::gpar(fill = "transparent", col = "black")
      )
    }
  }
}

#' @title Build block fill panel function
#'
#' @md
#' @inheritParams palette_colors
#' @param levels Character/factor levels used as keys for fill mapping.
#' @param fill_values Optional named fill vector. Names should match `levels`.
#' @param border Whether to draw block border.
#'
#' @return A function with signature `(index, levels)` suitable for `panel_fun` in [ComplexHeatmap::anno_block].
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#' lv <- c("A", "B", "C")
#' panel_fun <- annotation_block_fill_graphics(
#'   levels = lv,
#'   fill_values = c(A = "#1b9e77", B = "#d95f02", C = "#7570b3")
#' )
#' ComplexHeatmap::anno_block(panel_fun = panel_fun)
annotation_block_fill_graphics <- function(
  levels,
  palette = NULL,
  palcolor = NULL,
  fill_values = NULL,
  border = TRUE
) {
  if (is.null(fill_values)) {
    fill_values <- palette_colors(
      levels,
      type = "discrete",
      palette = palette,
      palcolor = palcolor,
      matched = TRUE
    )
  }
  names(fill_values) <- as.character(levels)

  function(index, levels) {
    level_key <- as.character(levels[1])
    fill <- unname(fill_values[[level_key]])
    if (is.null(fill) || length(fill) == 0 || is.na(fill)) {
      fill <- "transparent"
    }
    grid::grid.rect(
      gp = grid::gpar(
        fill = fill, col = if (isTRUE(border)) "black" else NA
      )
    )
  }
}

#' @title Build HeatmapAnnotation with safe parameter merge
#'
#' @md
#' @inheritParams annotation_block_graphics
#' @param annotations Named list of annotation components (for example, `anno_simple`, `anno_block`, `anno_customize`).
#' @param which Annotation direction (`"row"` or `"column"`).
#' @param show_annotation_name Whether to show annotation names.
#' @param annotation_name_side Side for annotation names.
#' @param params Additional user parameters; duplicated keys are ignored if already set explicitly.
#'
#' @return A [ComplexHeatmap::HeatmapAnnotation] object.
#'
#' @export
#'
#' @examples
#' anno <- list(
#'   group = ComplexHeatmap::anno_simple(
#'     x = c("A", "B", "A"),
#'     col = c(A = "#1b9e77", B = "#d95f02"),
#'     which = "column"
#'   )
#' )
#' ha <- build_heatmap_annotation(
#'   annotations = anno,
#'   which = "column",
#'   show_annotation_name = TRUE,
#'   annotation_name_side = "left",
#'   params = list(gap = grid::unit(1, "mm"))
#' )
#' ha
build_heatmap_annotation <- function(
  annotations,
  which,
  show_annotation_name = TRUE,
  annotation_name_side = NULL,
  border = NULL,
  params = NULL
) {
  anno_args <- c(
    annotations,
    which = which,
    show_annotation_name = show_annotation_name
  )
  if (!is.null(annotation_name_side)) {
    anno_args[["annotation_name_side"]] <- annotation_name_side
  }
  if (!is.null(border)) {
    anno_args[["border"]] <- border
  }
  if (!is.null(params) && length(params) > 0) {
    anno_args <- c(
      anno_args,
      params[setdiff(names(params), names(anno_args))]
    )
  }
  do.call(
    ComplexHeatmap::HeatmapAnnotation,
    args = anno_args
  )
}
