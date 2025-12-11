#' @title Get a function from a namespace
#'
#' @md
#' @param pkg The name of the package.
#' @param fun The name of the function.
#'
#' @return Function.
#'
#' @export
get_namespace_fun <- function(pkg, fun) {
  ns <- getNamespace(pkg)
  if (exists(fun, envir = ns, inherits = FALSE)) {
    get(fun, envir = ns, inherits = FALSE)
  } else {
    log_message(
      "Function {.val {fun}} not found in {.pkg {pkg}} namespace",
      message_type = "warning"
    )
    return(NULL)
  }
}

#' @title Get used vars in a ggplot object
#'
#' @md
#' @inheritParams thisutils::log_message
#' @param p A `ggplot` object.
#' @param reverse Whether to return unused vars.
#' Default is `FALSE`.
#'
#' @return A character vector of variable names.
#' If `reverse` is `FALSE`, returns used variables;
#' if `TRUE`, returns unused variables.
#'
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(
#'   data = mtcars,
#'   aes(x = mpg, y = wt, colour = cyl)
#' ) +
#'   geom_point()
#' get_vars(p)
#' get_vars(p, reverse = TRUE)
get_vars <- function(
  p,
  reverse = FALSE,
  verbose = TRUE
) {
  mappings <- c(
    as.character(p$mapping),
    unlist(
      lapply(p$layers, function(x) as.character(x$mapping))
    ),
    unlist(
      lapply(p$layers, function(x) names(p$layers[[1]]$aes_params))
    ),
    names(
      p$facet$params$facets
    ), names(p$facet$params$rows), names(p$facet$params$cols)
  )
  vars <- unique(
    unlist(
      strsplit(
        gsub(
          "[~\\[\\]\\\"\\(\\)]", " ", unique(mappings),
          perl = TRUE
        ), " "
      )
    )
  )
  vars_used <- intersect(
    unique(
      c(
        colnames(p$data), unlist(lapply(p$layers, function(x) colnames(x$data)))
      )
    ), vars
  )

  vars_notused <- setdiff(colnames(p$data), vars_used)
  log_message(
    "vars_used: {.val {vars_used}}\n",
    "vars_notused: {.val {vars_notused}}",
    verbose = verbose
  )
  if (reverse) {
    return(vars_notused)
  } else {
    return(vars_used)
  }
}

#' @title Build a patchwork gtable
#'
#' @description
#' Build a gtable from a patchwork object by arranging multiple plots
#' according to the layout specification.
#'
#' @md
#' @param x A patchwork object.
#' @param guides How to handle guides.
#' Default is `"auto"`.
#' @param table_rows The number of rows in the table grid.
#' Default is `18`.
#' @param table_cols The number of columns in the table grid.
#' Default is `15`.
#' @param panel_row The row index for panels.
#' Default is `10`.
#' @param panel_col The column index for panels.
#' Default is `8`.
#'
#' @return A gtable object.
#'
#' @export
build_patchwork <- function(
  x,
  guides = "auto",
  table_rows = 18,
  table_cols = 15,
  panel_row = 10,
  panel_col = 8
) {
  x$layout <- utils::modifyList(
    get_namespace_fun("patchwork", "default_layout"),
    x$layout[!vapply(x$layout, is.null, logical(1))]
  )

  if (guides == "collect" && x$layout$guides != "keep") {
    guides <- "collect"
  } else {
    guides <- x$layout$guides
  }
  plot_table_fun <- get_namespace_fun(
    "patchwork", "plot_table"
  )
  gt <- lapply(
    x$plots,
    plot_table_fun,
    guides = guides
  )
  fixed_asp <- vapply(
    gt, function(x) isTRUE(x$respect), logical(1)
  )
  guide_grobs <- unlist(
    lapply(gt, `[[`, "collected_guides"),
    recursive = FALSE
  )
  simplify_gt_fun <- get_namespace_fun(
    "patchwork", "simplify_gt"
  )
  gt <- lapply(
    gt,
    simplify_gt_fun
  )
  add_insets_fun <- get_namespace_fun(
    "patchwork", "add_insets"
  )
  gt <- add_insets_fun(gt)
  if (is.null(x$layout$design)) {
    if (is.null(x$layout$ncol) && !is.null(x$layout$widths) && length(x$layout$widths) > 1) {
      x$layout$ncol <- length(x$layout$widths)
    }
    if (is.null(x$layout$nrow) && !is.null(x$layout$heights) && length(x$layout$heights) > 1) {
      x$layout$nrow <- length(x$layout$heights)
    }
    dims <- ggplot2::wrap_dims(
      length(gt),
      nrow = x$layout$nrow,
      ncol = x$layout$ncol
    )
    create_design_fun <- get_namespace_fun(
      "patchwork", "create_design"
    )
    x$layout$design <- create_design_fun(
      dims[2],
      dims[1],
      x$layout$byrow
    )
  } else {
    dims <- c(
      max(x$layout$design$b),
      max(x$layout$design$r)
    )
  }

  gt_new <- gtable::gtable(
    grid::unit(rep(0, table_cols * dims[2]), "null"),
    grid::unit(rep(0, table_rows * dims[1]), "null")
  )
  design <- as.data.frame(unclass(x$layout$design))
  if (nrow(design) < length(gt)) {
    log_message(
      "Too few patch areas to hold all plots. Dropping plots",
      message_type = "warning"
    )
    gt <- gt[seq_len(nrow(design))]
    fixed_asp <- fixed_asp[seq_len(nrow(design))]
  } else {
    design <- design[seq_along(gt), ]
  }
  if (any(design$t < 1)) design$t[design$t < 1] <- 1
  if (any(design$l < 1)) design$l[design$l < 1] <- 1
  if (any(design$b > dims[1])) design$b[design$b > dims[1]] <- dims[1]
  if (any(design$r > dims[2])) design$r[design$r > dims[2]] <- dims[2]
  max_z <- lapply(gt, function(x) max(x$layout$z))
  max_z <- c(0, cumsum(max_z))
  gt_new$layout <- do.call(
    rbind,
    lapply(
      seq_along(gt), function(i) {
        loc <- design[i, ]
        lay <- gt[[i]]$layout
        lay$name <- paste0(lay$name, "-", i)
        lay$t <- lay$t +
          ifelse(
            lay$t <= panel_row, (loc$t - 1) * table_rows,
            (loc$b - 1) * table_rows
          )
        lay$l <- lay$l +
          ifelse(
            lay$l <= panel_col,
            (loc$l - 1) * table_cols,
            (loc$r - 1) * table_cols
          )
        lay$b <- lay$b +
          ifelse(lay$b < panel_row,
            (loc$t - 1) * table_rows,
            (loc$b - 1) * table_rows
          )
        lay$r <- lay$r +
          ifelse(lay$r < panel_col,
            (loc$l - 1) * table_cols,
            (loc$r - 1) * table_cols
          )
        lay$z <- lay$z + max_z[i]
        lay
      }
    )
  )
  table_dims_fun <- get_namespace_fun("patchwork", "table_dims")
  table_dimensions <- table_dims_fun(
    lapply(gt, `[[`, "widths"),
    lapply(gt, `[[`, "heights"),
    design,
    dims[2],
    dims[1]
  )
  set_grob_sizes_fun <- get_namespace_fun("patchwork", "set_grob_sizes")
  gt_new$grobs <- set_grob_sizes_fun(
    gt,
    table_dimensions$widths,
    table_dimensions$heights, design
  )
  gt_new$widths <- table_dimensions$widths
  gt_new$heights <- table_dimensions$heights
  widths <- rep(x$layout$widths, length.out = dims[2])
  heights <- rep(x$layout$heights, length.out = dims[1])
  set_panel_dimensions_fun <- get_namespace_fun("patchwork", "set_panel_dimensions")
  gt_new <- set_panel_dimensions_fun(
    gt_new,
    gt,
    widths,
    heights,
    fixed_asp,
    design
  )
  if (x$layout$guides == "collect") {
    collapse_guides_fun <- get_namespace_fun("patchwork", "collapse_guides")
    guide_grobs <- collapse_guides_fun(guide_grobs)
    if (length(guide_grobs) != 0) {
      theme <- x$annotation$theme
      if (!attr(theme, "complete")) {
        theme <- ggplot2::theme_get() + theme
      }
      assemble_guides_fun <- get_namespace_fun(
        "patchwork", "assemble_guides"
      )
      guide_grobs <- assemble_guides_fun(guide_grobs, theme)
      attach_guides_fun <- get_namespace_fun(
        "patchwork", "attach_guides"
      )
      gt_new <- attach_guides_fun(gt_new, guide_grobs, theme)
    }
  } else {
    gt_new$collected_guides <- guide_grobs
  }

  class(gt_new) <- c("gtable_patchwork", class(gt_new))
  gt_new
}

#' @title Convert a patchwork object to a grob
#'
#' @description
#' Convert a patchwork object to a gtable grob by processing annotations
#' and building the patchwork layout.
#'
#' @md
#' @param x A patchwork object.
#' @param ... Additional arguments passed to other functions.
#'
#' @return A gtable object.
#'
#' @export
patchwork_grob <- function(x, ...) {
  annotation <- utils::modifyList(
    get_namespace_fun("patchwork", "default_annotation"),
    x$patches$annotation[!vapply(x$patches$annotation, is.null, logical(1))]
  )
  recurse_tags_fun <- get_namespace_fun("patchwork", "recurse_tags")
  x <- recurse_tags_fun(
    x,
    annotation$tag_levels,
    annotation$tag_prefix,
    annotation$tag_suffix,
    annotation$tag_sep
  )$patches
  get_patches_fun <- get_namespace_fun("patchwork", "get_patches")
  plot <- get_patches_fun(x)
  gtable <- build_patchwork(plot)
  annotate_table_fun <- get_namespace_fun("patchwork", "annotate_table")
  gtable <- annotate_table_fun(gtable, annotation)
  class(gtable) <- setdiff(class(gtable), "gtable_patchwork")
  gtable
}

#' @title Convert a plot object to a grob
#'
#' @description
#' Convert various plot objects (gList, patchwork, ggplot) to a grob object.
#'
#' @md
#' @param plot A plot object (gList, patchwork, or ggplot).
#' @param ... Additional arguments passed to other functions.
#'
#' @return A grob object.
#'
#' @export
as_grob <- function(plot, ...) {
  if (inherits(plot, "gList")) {
    grid::grobTree(plot)
  } else if (inherits(plot, "patchwork")) {
    patchwork_grob(plot, ...)
  } else if (inherits(plot, "ggplot")) {
    ggplot2::ggplotGrob(plot)
  } else {
    log_message(
      "Cannot convert object of {.cls {class(plot)}} into a grob",
      message_type = "warning"
    )
  }
}

#' @title Convert a plot object to a gtable
#'
#' @description
#' Convert various plot objects (gtable, grob, patchwork, ggplot) to a gtable object.
#'
#' @md
#' @param plot A plot object (gtable, grob, patchwork, or ggplot).
#' @param ... Additional arguments passed to other functions.
#'
#' @return A gtable object.
#'
#' @export
as_gtable <- function(plot, ...) {
  if (inherits(plot, "gtable")) {
    return(plot)
  }
  if (inherits(plot, "grob")) {
    u <- grid::unit(1, "null")
    gt <- gtable::gtable_col(NULL, list(plot), u, u)
    gt$layout$clip <- "inherit"
    return(gt)
  } else {
    grob <- as_grob(plot, ...)
    if (inherits(grob, "gtable")) {
      return(grob)
    } else if (inherits(grob, "grob")) {
      u <- grid::unit(1, "null")
      gt <- gtable::gtable_col(NULL, list(grob), u, u)
      gt$layout$clip <- "inherit"
      return(gt)
    } else {
      log_message(
        "Cannot convert object of {.cls {class(grob)}} into a gtable",
        message_type = "warning"
      )
      return(NULL)
    }
  }
}

#' @title Extract legend from a plot
#'
#' @description
#' Extract the legend grob from a plot object.
#'
#' @md
#' @param plot A plot object.
#'
#' @return The legend grob.
#'
#' @export
get_legend <- function(plot) {
  plot <- as_gtable(plot)
  grob_names <- plot$layout$name
  grobs <- plot$grobs
  grob_index <- which(
    grepl(
      "guide-box-bottom",
      grob_names
    )
  )
  grob_index <- grob_index[1]
  matched_grobs <- grobs[[grob_index]]
  matched_grobs
}

#' @title Add a grob to a gtable
#'
#' @description
#' Add a grob to a gtable at a specified position (top, bottom, left, or right).
#'
#' @md
#' @param gtable A gtable object.
#' @param grob A grob or gtable object to add.
#' @param position The position to add the grob.
#' One of `"top"`, `"bottom"`, `"left"`, `"right"`, or `"none"`.
#' @param space The space to allocate for the grob.
#' If `NULL`, will be calculated automatically.
#' @param clip The clipping mode.
#' Default is `"on"`.
#'
#' @return A gtable object with the grob added.
#'
#' @export
add_grob <- function(
  gtable,
  grob,
  position = c("top", "bottom", "left", "right", "none"),
  space = NULL,
  clip = "on"
) {
  position <- match.arg(position)
  if (position == "none" || is.null(grob)) {
    return(gtable)
  }

  if (is.null(space)) {
    if (gtable::is.gtable(grob)) {
      if (position %in% c("top", "bottom")) {
        space <- sum(grob$heights)
      } else {
        space <- sum(grob$widths)
      }
    } else if (grid::is.grob(grob)) {
      if (position %in% c("top", "bottom")) {
        space <- grid::grobHeight(grob)
      } else {
        space <- grid::grobWidth(grob)
      }
    }
  }

  if (position == "top") {
    gtable <- gtable::gtable_add_rows(
      gtable,
      space,
      0
    )
    gtable <- gtable::gtable_add_grob(
      gtable, grob,
      t = 1,
      l = mean(
        gtable$layout[grepl(pattern = "panel", x = gtable$layout$name), "l"]
      ),
      clip = clip
    )
  }
  if (position == "bottom") {
    gtable <- gtable::gtable_add_rows(
      gtable,
      space,
      -1
    )
    gtable <- gtable::gtable_add_grob(
      gtable, grob,
      t = dim(gtable)[1],
      l = mean(
        gtable$layout[grepl(pattern = "panel", x = gtable$layout$name), "l"]
      ), clip = clip
    )
  }
  if (position == "left") {
    gtable <- gtable::gtable_add_cols(
      gtable,
      space,
      0
    )
    gtable <- gtable::gtable_add_grob(
      gtable,
      grob,
      t = mean(
        gtable$layout[grep("panel", gtable$layout$name), "t"]
      ),
      l = 1,
      clip = clip
    )
  }
  if (position == "right") {
    gtable <- gtable::gtable_add_cols(
      gtable,
      space,
      -1
    )
    gtable <- gtable::gtable_add_grob(
      gtable,
      grob,
      t = mean(
        gtable$layout[grep("panel", gtable$layout$name), "t"]
      ),
      l = dim(gtable)[2],
      clip = clip
    )
  }
  return(gtable)
}

#' @title Check CI environment
#'
#' @md
#' @return
#' A logical value.
#'
#' @export
check_ci_env <- function() {
  if (interactive()) {
    return(TRUE)
  }

  github_actions <- Sys.getenv("GITHUB_ACTIONS", unset = "")
  github_workflow <- Sys.getenv("GITHUB_WORKFLOW", unset = "")

  if (nzchar(github_actions) && github_actions == "true") {
    if (nzchar(github_workflow) && tolower(github_workflow) == "pkgdown") {
      return(TRUE)
    }
  }

  return(FALSE)
}
