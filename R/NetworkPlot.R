#' @title Network Plot
#'
#' @md
#' @param edge A data frame with one row per edge.
#' @param node Optional data frame with one row per node. Node identifiers are
#' taken from `node_name`, from a column named `name`, or from the row names.
#' @param from,to Column names in `edge` holding the edge endpoints.
#' @param weight Column name in `edge` holding edge weights. Use `NULL` for
#' unweighted edges.
#' @param node_name Column name in `node` holding node identifiers.
#' @param edge_group Optional column name in `edge` used to colour edges.
#' @param edge_palcolor,edge_palette Custom colors or palette name for
#' `edge_group`.
#' @param node_group Optional column name in `node` used to fill nodes.
#' @param node_palcolor,node_palette Custom colors or palette name for
#' `node_group`.
#' @param node_shape Optional node shapes. Either a column name in `node` or a
#' named vector of grid shapes keyed by node name.
#' @param node_shape_values Named vector mapping `node_shape` levels to shapes.
#' @param node_size Optional node sizes. Either a column name in `node` or a
#' numeric value used for every node.
#' @param node_size_range Optional size range used to rescale a numeric column
#' supplied to `node_size`; `NULL` keeps the supplied values.
#' @param layout Layout used when `node` has no coordinates. One of `"fr"`,
#' `"kk"`, `"circle"` or `"none"`.
#' @param node_coord Column names in `node` holding x and y coordinates. Used
#' when `layout = "none"`.
#' @param edge_width Width range for the edges; `NULL` keeps the ggplot2
#' default width scale.
#' @param edge_width_legend Whether to show the edge width legend. Default is
#' `FALSE`.
#' @param edge_alpha Edge alpha.
#' @param edge_curvature Edge curvature passed to `geom_curve`; `0` draws
#' straight segments.
#' @param edge_arrow Whether to draw arrow heads on edges.
#' @param label Whether to draw node labels.
#' @param label_nodes Nodes to label. Default labels every node.
#' @param label.size Label text size.
#' @param label_size Optional per-node label sizes. Either a column name in
#' `node`, a named vector keyed by node name, or `NULL` to use `label.size`.
#' @param label_face Optional per-node label faces. Either a column name in
#' `node`, a named vector keyed by node name, or `NULL` for plain text.
#' @param label.fg,label.bg,label.bg.r Label foreground color, outline color and
#' outline radius.
#' @param highlight Optional node names drawn with an extra ring.
#' @param highlight.color,highlight.size Color and size of the highlight ring.
#' @param title Optional plot title.
#' @param aspect.ratio Aspect ratio passed to the theme.
#' @param legend.position Legend position passed to the theme.
#' @param theme_use Theme function name, one of `"theme_this"`,
#' `"theme_blank"` or `"theme_void"`.
#' @param theme_args A named list of arguments passed to `theme_use`.
#' @param seed Optional integer seed for the layout.
#'
#' @return A `ggplot` object.
#' @export
#'
#' @examples
#' edge <- data.frame(
#'   from = c("A", "A", "B", "C"),
#'   to = c("B", "C", "C", "D"),
#'   weight = c(1, -2, 3, 1)
#' )
#' NetworkPlot(edge)
#'
#' node <- data.frame(
#'   name = c("A", "B", "C", "D"),
#'   group = c("g1", "g2", "g2", "g3"),
#'   shape = c("hub", "leaf", "leaf", "leaf")
#' )
#' NetworkPlot(
#'   edge,
#'   node = node,
#'   node_group = "group",
#'   node_shape = "shape",
#'   node_shape_values = c("hub" = 23, "leaf" = 21),
#'   label_nodes = c("A", "B")
#' )
NetworkPlot <- function(
  edge,
  node = NULL,
  from = "from",
  to = "to",
  weight = "weight",
  node_name = NULL,
  edge_group = NULL,
  edge_palcolor = NULL,
  edge_palette = "Chinese",
  node_group = NULL,
  node_palcolor = NULL,
  node_palette = "Chinese",
  node_shape = NULL,
  node_shape_values = NULL,
  node_size = NULL,
  node_size_range = NULL,
  layout = c("fr", "kk", "circle", "none"),
  node_coord = c("x", "y"),
  edge_width = c(0.2, 1),
  edge_width_legend = FALSE,
  edge_alpha = 0.7,
  edge_curvature = 0,
  edge_arrow = FALSE,
  label = TRUE,
  label_nodes = NULL,
  label.size = 3.5,
  label_size = NULL,
  label_face = NULL,
  label.fg = "black",
  label.bg = "white",
  label.bg.r = 0.1,
  highlight = NULL,
  highlight.color = "red",
  highlight.size = 6,
  title = NULL,
  aspect.ratio = 1,
  legend.position = "right",
  theme_use = "theme_this",
  theme_args = list(),
  seed = 42
) {
  layout <- match.arg(layout)
  if (!is.data.frame(edge)) {
    log_message("'edge' must be a data.frame object.", message_type = "error")
  }
  if (!all(c(from, to) %in% colnames(edge))) {
    log_message(
      "Cannot find the edge column(s) ",
      paste(setdiff(c(from, to), colnames(edge)), collapse = ","),
      " in 'edge'.",
      message_type = "error"
    )
  }
  edge <- as.data.frame(edge, stringsAsFactors = FALSE)
  edge[["..from"]] <- as.character(edge[[from]])
  edge[["..to"]] <- as.character(edge[[to]])
  edge <- edge[edge[["..from"]] != edge[["..to"]], , drop = FALSE]
  if (nrow(edge) == 0) {
    log_message("No edge remains after removing self-loops.", message_type = "error")
  }
  if (!is.null(weight) && weight %in% colnames(edge)) {
    edge[["..weight"]] <- as.numeric(edge[[weight]])
  } else {
    edge[["..weight"]] <- 1
  }
  edge_key <- ifelse(
    edge[["..from"]] <= edge[["..to"]],
    paste(edge[["..from"]], edge[["..to"]], sep = "\r"),
    paste(edge[["..to"]], edge[["..from"]], sep = "\r")
  )
  edge$.edge_key <- edge_key
  edge <- edge[order(abs(edge[["..weight"]]), decreasing = TRUE), , drop = FALSE]
  edge <- edge[!duplicated(edge$.edge_key), , drop = FALSE]
  edge$.edge_key <- NULL

  node_names <- unique(c(edge[["..from"]], edge[["..to"]]))
  if (is.null(node)) {
    node <- data.frame(name = node_names, stringsAsFactors = FALSE)
    node_name <- "name"
  }
  if (!is.data.frame(node)) {
    log_message("'node' must be a data.frame object.", message_type = "error")
  }
  node <- as.data.frame(node, stringsAsFactors = FALSE)
  if (is.null(node_name) && "name" %in% colnames(node)) {
    node_name <- "name"
  }
  if (!is.null(node_name) && node_name %in% colnames(node)) {
    node[["..name"]] <- as.character(node[[node_name]])
  } else if (any(nzchar(rownames(node)))) {
    node[["..name"]] <- rownames(node)
  } else {
    log_message(
      "Cannot determine node identifiers; supply 'node_name' or a 'name' column.",
      message_type = "error"
    )
  }
  missing_nodes <- setdiff(node_names, node[["..name"]])
  if (length(missing_nodes) > 0) {
    pad <- node[rep(NA_integer_, length(missing_nodes)), , drop = FALSE]
    pad[["..name"]] <- missing_nodes
    node <- rbind(node, pad)
  }
  node <- node[!duplicated(node[["..name"]]), , drop = FALSE]

  if (identical(layout, "none")) {
    if (!all(node_coord %in% colnames(node))) {
      log_message(
        "layout = 'none' requires the coordinate columns ",
        paste(node_coord, collapse = ", "),
        " in 'node'.",
        message_type = "error"
      )
    }
    node[["..x"]] <- as.numeric(node[[node_coord[1]]])
    node[["..y"]] <- as.numeric(node[[node_coord[2]]])
  } else {
    graph_edges <- data.frame(
      from = edge[["..from"]],
      to = edge[["..to"]],
      weight = abs(edge[["..weight"]]),
      stringsAsFactors = FALSE
    )
    graph <- igraph::graph_from_data_frame(
      graph_edges,
      directed = FALSE,
      vertices = data.frame(name = node[["..name"]])
    )
    if (!is.null(seed)) {
      set.seed(seed)
    }
    xy <- switch(layout,
      fr = igraph::layout_with_fr(graph),
      kk = igraph::layout_with_kk(graph),
      circle = igraph::layout_in_circle(graph)
    )
    rownames(xy) <- igraph::V(graph)$name
    xy <- xy[node[["..name"]], , drop = FALSE]
    node[["..x"]] <- xy[, 1]
    node[["..y"]] <- xy[, 2]
  }

  edge[["..x"]] <- node[["..x"]][match(edge[["..from"]], node[["..name"]])]
  edge[["..y"]] <- node[["..y"]][match(edge[["..from"]], node[["..name"]])]
  edge[["..xend"]] <- node[["..x"]][match(edge[["..to"]], node[["..name"]])]
  edge[["..yend"]] <- node[["..y"]][match(edge[["..to"]], node[["..name"]])]

  node[["..size"]] <- if (is.null(node_size)) {
    4
  } else if (length(node_size) == 1L && is.numeric(node_size)) {
    node_size
  } else if (length(node_size) == 1L && node_size %in% colnames(node)) {
    as.numeric(node[[node_size]])
  } else {
    unname(as.numeric(node_size[node[["..name"]]]))
  }
  if (all(is.na(node[["..size"]]))) {
    node[["..size"]] <- 4
  }
  if (!is.null(node_size_range)) {
    size_range <- range(node[["..size"]], na.rm = TRUE)
    if (all(is.finite(size_range)) && diff(size_range) > 0) {
      node[["..size"]] <- node_size_range[1] +
        (node[["..size"]] - size_range[1]) / diff(size_range) * diff(node_size_range)
    } else {
      node[["..size"]] <- mean(node_size_range)
    }
  }
  node[["..fill_group"]] <- if (is.null(node_group)) {
    "Node"
  } else if (length(node_group) == 1L && node_group %in% colnames(node)) {
    as.character(node[[node_group]])
  } else {
    as.character(node_group[node[["..name"]]])
  }
  node[["..shape"]] <- if (is.null(node_shape)) {
    21
  } else if (length(node_shape) == 1L && node_shape %in% colnames(node)) {
    node[[node_shape]]
  } else {
    node_shape[node[["..name"]]]
  }
  if (!is.numeric(node[["..shape"]])) {
    shape_levels <- unique(as.character(node[["..shape"]]))
    if (is.null(node_shape_values)) {
      shapes <- c(21, 23, 24, 22, 25)
      node_shape_values <- stats::setNames(
        rep(shapes, length.out = length(shape_levels)),
        shape_levels
      )
    }
    node[["..shape"]] <- unname(node_shape_values[as.character(node[["..shape"]])])
  }
  node[["..shape"]] <- as.numeric(node[["..shape"]])

  if (is.null(edge_group)) {
    edge[["..edge_group"]] <- "edge"
  } else if (length(edge_group) == 1L && edge_group %in% colnames(edge)) {
    edge[["..edge_group"]] <- as.character(edge[[edge_group]])
  } else {
    edge[["..edge_group"]] <- as.character(edge_group)
  }

  node_label <- if (isTRUE(label)) {
    if (is.null(label_nodes)) node[["..name"]] else intersect(as.character(label_nodes), node[["..name"]])
  } else {
    character(0)
  }
  label_df <- node[node[["..name"]] %in% node_label, , drop = FALSE]
  if (nrow(label_df) > 0L) {
    label_df[["..label_size"]] <- if (is.null(label_size)) {
      label.size
    } else if (length(label_size) == 1L && label_size %in% colnames(node)) {
      as.numeric(label_df[[label_size]])
    } else {
      unname(as.numeric(label_size[label_df[["..name"]]]))
    }
    label_df[["..label_size"]][!is.finite(label_df[["..label_size"]])] <- label.size
    label_df[["..label_face"]] <- if (is.null(label_face)) {
      "plain"
    } else if (length(label_face) == 1L && label_face %in% colnames(node)) {
      as.character(label_df[[label_face]])
    } else {
      unname(as.character(label_face[label_df[["..name"]]]))
    }
    label_df[["..label_face"]][is.na(label_df[["..label_face"]])] <- "plain"
  }

  p <- ggplot2::ggplot()
  if (nrow(edge) > 0) {
    edge_mapping <- ggplot2::aes(
      x = .data[["..x"]],
      y = .data[["..y"]],
      xend = .data[["..xend"]],
      yend = .data[["..yend"]],
      linewidth = abs(.data[["..weight"]]),
      colour = .data[["..edge_group"]]
    )
    if (isTRUE(edge_curvature != 0)) {
      p <- p + ggplot2::geom_curve(
        data = edge,
        mapping = edge_mapping,
        curvature = edge_curvature,
        alpha = edge_alpha,
        lineend = "round",
        arrow = if (isTRUE(edge_arrow)) grid::arrow(length = grid::unit(2, "mm")) else NULL,
        inherit.aes = FALSE
      )
    } else {
      p <- p + ggplot2::geom_segment(
        data = edge,
        mapping = edge_mapping,
        alpha = edge_alpha,
        lineend = "round",
        arrow = if (isTRUE(edge_arrow)) grid::arrow(length = grid::unit(2, "mm")) else NULL,
        inherit.aes = FALSE
      )
    }
    if (!is.null(edge_width)) {
      p <- p + ggplot2::scale_linewidth(
        range = edge_width,
        name = "Edge weight",
        guide = if (isTRUE(edge_width_legend)) "legend" else "none"
      )
    }
    edge_levels <- unique(edge[["..edge_group"]])
    if (is.null(edge_palcolor)) {
      edge_palcolor <- palette_colors(edge_levels, palette = edge_palette)
      if (is.null(names(edge_palcolor))) {
        names(edge_palcolor) <- edge_levels
      }
    }
    p <- p + ggplot2::scale_colour_manual(
      values = edge_palcolor,
      name = if (is.null(edge_group)) NULL else edge_group
    )
  }

  p <- p + ggplot2::geom_point(
    data = node,
    mapping = ggplot2::aes(
      x = .data[["..x"]],
      y = .data[["..y"]],
      fill = .data[["..fill_group"]],
      shape = .data[["..shape"]]
    ),
    size = node[["..size"]],
    colour = "grey20",
    stroke = 0.5,
    inherit.aes = FALSE
  )
  fill_levels <- unique(node[["..fill_group"]])
  if (is.null(node_palcolor)) {
    node_palcolor <- palette_colors(fill_levels, palette = node_palette)
    if (is.null(names(node_palcolor))) {
      names(node_palcolor) <- fill_levels
    }
  }
  p <- p + ggplot2::scale_fill_manual(
    values = node_palcolor,
    name = if (is.null(node_group)) NULL else node_group,
    na.value = "#CFD8DC"
  )
  if (!is.null(node_group)) {
    p <- p + ggplot2::guides(
      fill = ggplot2::guide_legend(
        override.aes = list(shape = 21, colour = "grey20", size = 3.5)
      )
    )
  }
  p <- p + ggplot2::scale_shape_identity()

  if (!is.null(highlight) && length(highlight) > 0L) {
    highlight_df <- node[node[["..name"]] %in% as.character(highlight), , drop = FALSE]
    if (nrow(highlight_df) > 0L) {
      p <- p + ggplot2::geom_point(
        data = highlight_df,
        mapping = ggplot2::aes(x = .data[["..x"]], y = .data[["..y"]]),
        shape = 21,
        fill = NA,
        colour = highlight.color,
        size = highlight.size,
        stroke = 0.9,
        inherit.aes = FALSE,
        show.legend = FALSE
      )
    }
  }

  if (nrow(label_df) > 0) {
    if (requireNamespace("ggrepel", quietly = TRUE)) {
      p <- p + ggrepel::geom_text_repel(
        data = label_df,
        mapping = ggplot2::aes(
          x = .data[["..x"]],
          y = .data[["..y"]],
          label = .data[["..name"]],
          size = .data[["..label_size"]],
          fontface = .data[["..label_face"]]
        ),
        colour = label.fg,
        bg.color = label.bg,
        bg.r = label.bg.r,
        segment.colour = NA,
        max.overlaps = Inf,
        box.padding = 0.35,
        point.padding = 0.28,
        show.legend = FALSE,
        inherit.aes = FALSE
      ) + ggplot2::scale_size_identity()
    } else {
      p <- p + ggplot2::geom_text(
        data = label_df,
        mapping = ggplot2::aes(
          x = .data[["..x"]],
          y = .data[["..y"]],
          label = .data[["..name"]],
          size = .data[["..label_size"]],
          fontface = .data[["..label_face"]]
        ),
        colour = label.fg,
        inherit.aes = FALSE
      ) + ggplot2::scale_size_identity()
    }
  }

  theme_fun <- switch(theme_use,
    theme_this = theme_this,
    theme_blank = theme_blank,
    theme_void = ggplot2::theme_void
  )
  if ("aspect.ratio" %in% names(formals(theme_fun))) {
    theme_args[["aspect.ratio"]] <- aspect.ratio
  }
  p <- p + do.call(theme_fun, theme_args) +
    ggplot2::theme(aspect.ratio = aspect.ratio) +
    ggplot2::theme(
      axis.line = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank(),
      legend.position = legend.position
    )
  p <- p + ggplot2::coord_fixed()
  if (!is.null(title)) {
    p <- p + ggplot2::ggtitle(title)
  }
  p
}
