#' @title Statistic Plot
#'
#' @description
#' Visualizes data using various plot types such as bar plots,
#' rose plots, ring plots, pie charts, trend plots, area plots,
#' dot plots, sankey plots, chord plots, venn diagrams, and upset plots.
#'
#' @md
#' @param meta.data The data frame containing the data to be plotted.
#' @param stat.by The column name(s) in `meta.data` specifying the variable(s) to be plotted.
#' @param bg.by The column name in `meta.data` specifying the background variable for bar plots.
#' @param flip Whether to flip the plot.
#' Default is `FALSE`.
#' @param NA_color The color to use for missing values.
#' @param NA_stat Whether to include missing values in the plot.
#' Default is `TRUE`.
#' @param keep_empty Whether to keep empty groups in the plot.
#' Default is `FALSE`.
#' @param individual Whether to plot individual groups separately.
#' Default is `FALSE`.
#' @param stat_level The level(s) of the variable(s) specified in `stat.by` to include in the plot.
#' Default is `NULL`.
#' @param plot_type The type of plot to create.
#' Can be one of `"bar"`, `"rose"`, `"ring"`, `"pie"`, `"trend"`,
#' `"area"`, `"dot"`, `"sankey"`, `"chord"`, `"venn"`, or `"upset"`.
#' @param stat_type The type of statistic to compute for the plot.
#' Can be one of `"percent"` or `"count"`.
#' @param position The position adjustment for the plot.
#' Can be one of `"stack"` or `"dodge"`.
#' @param alpha The transparency level for the plot.
#' @param bg_palette The name of the background color palette to use for bar plots.
#' @param bg_palcolor The color to use in the background color palette.
#' @param bg_alpha The transparency level for the background color in bar plots.
#' @param label Whether to add labels on the plot.
#' Default is `FALSE`.
#' @param label.size The size of the labels.
#' @param label.fg The foreground color of the labels.
#' @param label.bg The background color of the labels.
#' @param label.bg.r The radius of the rounded corners of the label background.
#' @param aspect.ratio Aspect ratio of the panel. Default is `NULL`.
#' @param group.by The column name(s) in `meta.data` specifying the grouping variable(s).
#' Default is `NULL`.
#' @param split.by The column name in `meta.data` specifying the variable to split plots by.
#' Default is `NULL`.
#' @param palette The name of the color palette to use.
#' Default is `"Paired"`.
#' @param palcolor Custom colors to use instead of palette.
#' Default is `NULL`.
#' @param title The title of the plot.
#' Default is `NULL`.
#' @param subtitle The subtitle of the plot.
#' Default is `NULL`.
#' @param xlab The label for the x-axis.
#' Default is `NULL`.
#' @param ylab The label for the y-axis.
#' Default is `NULL`.
#' @param legend.position The position of the legend.
#' Can be one of `"none"`, `"left"`, `"right"`, `"bottom"`, `"top"`,
#' or a two-element numeric vector.
#' Default is `"right"`.
#' @param legend.direction The direction of the legend.
#' Can be one of `"vertical"` or `"horizontal"`.
#' Default is `"vertical"`.
#' @param theme_use The theme to use for the plot.
#' Default is `"theme_this"`.
#' @param theme_args Additional arguments to pass to the theme function.
#' Default is `list()`.
#' @param combine Whether to combine multiple plots into one.
#' Default is `TRUE`.
#' @param nrow Number of rows when combining plots.
#' Default is `NULL`.
#' @param ncol Number of columns when combining plots.
#' Default is `NULL`.
#' @param byrow Whether to fill plots by row when combining.
#' Default is `TRUE`.
#' @param force Whether to force plotting even when variables have more than 100 levels.
#' Default is `FALSE`.
#' @param seed Random seed for reproducibility.
#' Default is `11`.
#'
#' @export
#'
#' @examples
#' set.seed(1)
#' meta_data <- data.frame(
#'   Type = factor(
#'     sample(c("A", "B", "C"),
#'       50,
#'       replace = TRUE,
#'       prob = c(0.5, 0.3, 0.2)
#'     )
#'   ),
#'   Group = factor(sample(c("X", "Y", "Z"), 50, replace = TRUE)),
#'   Batch = factor(sample(c("B1", "B2"), 50, replace = TRUE))
#' )
#' meta_data$Region <- factor(
#'   ifelse(meta_data$Group %in% c("X", "Y"), "R1", "R2"),
#'   levels = c("R1", "R2")
#' )
#'
#' StatPlot(
#'   meta_data,
#'   stat.by = "Type",
#'   group.by = "Group",
#'   split.by = "Batch",
#'   plot_type = "bar",
#'   position = "dodge"
#' )
#'
#' StatPlot(
#'   meta_data,
#'   stat.by = "Type",
#'   group.by = "Group",
#'   stat_type = "count",
#'   plot_type = "ring",
#'   position = "dodge"
#' )
#'
#' StatPlot(
#'   meta_data,
#'   stat.by = "Type",
#'   group.by = "Group",
#'   stat_type = "count"
#' )
#'
#' StatPlot(
#'   meta_data,
#'   stat.by = "Type",
#'   plot_type = "pie"
#' )
#'
#' StatPlot(
#'   meta_data,
#'   stat.by = "Type",
#'   group.by = "Group",
#'   stat_type = "count",
#'   plot_type = "area"
#' )
#'
#' StatPlot(
#'   meta_data,
#'   stat.by = "Type",
#'   group.by = "Group",
#'   plot_type = "dot"
#' )
#'
#' StatPlot(
#'   meta_data,
#'   stat.by = "Type",
#'   group.by = "Group",
#'   stat_type = "count",
#'   plot_type = "trend"
#' )
StatPlot <- function(
  meta.data,
  stat.by,
  group.by = NULL,
  split.by = NULL,
  bg.by = NULL,
  flip = FALSE,
  NA_color = "grey",
  NA_stat = TRUE,
  keep_empty = FALSE,
  individual = FALSE,
  stat_level = NULL,
  plot_type = c(
    "bar",
    "rose",
    "ring",
    "pie",
    "trend",
    "area",
    "dot",
    "sankey",
    "chord",
    "venn",
    "upset"
  ),
  stat_type = c("percent", "count"),
  position = c("stack", "dodge"),
  palette = "Paired",
  palcolor = NULL,
  alpha = 1,
  bg_palette = "Paired",
  bg_palcolor = NULL,
  bg_alpha = 0.2,
  label = FALSE,
  label.size = 3.5,
  label.fg = "black",
  label.bg = "white",
  label.bg.r = 0.1,
  aspect.ratio = NULL,
  title = NULL,
  subtitle = NULL,
  xlab = NULL,
  ylab = NULL,
  legend.position = "right",
  legend.direction = "vertical",
  theme_use = "theme_this",
  theme_args = list(),
  combine = TRUE,
  nrow = NULL,
  ncol = NULL,
  byrow = TRUE,
  force = FALSE,
  seed = 11
) {
  set.seed(seed)

  stat_type <- match.arg(stat_type)
  plot_type <- match.arg(plot_type)
  position <- match.arg(position)

  if (nrow(meta.data) == 0) {
    log_message(
      "{.arg meta.data} is empty",
      message_type = "error"
    )
  }
  if (is.null(group.by)) {
    group.by <- "All.groups"
    xlab <- ""
    meta.data[[group.by]] <- factor("")
  }
  if (is.null(split.by)) {
    split.by <- "All.groups"
    meta.data[[split.by]] <- factor("")
  }

  for (i in unique(c(group.by, split.by, bg.by))) {
    if (!i %in% colnames(meta.data)) {
      log_message(
        "{.val {i}} is not in the {.arg meta.data}",
        message_type = "error"
      )
    }
    if (!is.factor(meta.data[[i]])) {
      meta.data[[i]] <- factor(meta.data[[i]], levels = unique(meta.data[[i]]))
    }
  }

  bg_map <- NULL
  if (!is.null(bg.by)) {
    for (g in group.by) {
      df_table <- table(meta.data[[g]], meta.data[[bg.by]])
      if (max(rowSums(df_table > 0), na.rm = TRUE) > 1) {
        log_message(
          "{.arg group.by} must be a part of {.arg bg.by}",
          message_type = "error"
        )
      } else {
        bg_map[[g]] <- stats::setNames(
          colnames(df_table)[apply(df_table, 1, function(x) which(x > 0))],
          rownames(df_table)
        )
      }
    }
  } else {
    for (g in group.by) {
      bg_map[[g]] <- stats::setNames(
        levels(meta.data[[g]]), levels(meta.data[[g]])
      )
    }
  }

  for (i in unique(stat.by)) {
    if (!i %in% colnames(meta.data)) {
      log_message(
        "{.val {i}} is not in the {.arg meta.data}",
        message_type = "error"
      )
    }
    if (plot_type %in% c("venn", "upset")) {
      if (!is.factor(meta.data[[i]]) && !is.logical(meta.data[[i]])) {
        meta.data[[i]] <- factor(
          meta.data[[i]],
          levels = unique(meta.data[[i]])
        )
      }
    } else if (!is.factor(meta.data[[i]])) {
      meta.data[[i]] <- factor(meta.data[[i]], levels = unique(meta.data[[i]]))
    }
  }

  plot_types <- c("sankey", "chord", "venn", "upset")
  if (length(stat.by) >= 2) {
    if (!plot_type %in% plot_types) {
      log_message(
        "{.arg plot_type} must be one of {.val {plot_types}} when multiple {.arg stat.by} provided",
        message_type = "error"
      )
    }
    if (length(stat.by) > 2 && plot_type == "chord") {
      log_message(
        "{.arg stat.by} can only be a vector of length 2 when {.arg plot_type = 'chord'}",
        message_type = "error"
      )
    }
    if (length(stat.by) > 7 && plot_type == "venn") {
      log_message(
        "{.arg stat.by} can only be a vector of length <= 7 when {.arg plot_type = 'venn'}",
        message_type = "error"
      )
    }
  }

  levels <- unique(
    unlist(
      lapply(
        meta.data[, stat.by, drop = FALSE],
        function(x) {
          if (is.factor(x)) {
            return(levels(x))
          }
          if (is.logical(x)) {
            return(as.character(unique(x)))
          }
        }
      )
    )
  )

  if (plot_type %in% c("venn", "upset")) {
    if (is.null(stat_level)) {
      stat_level <- lapply(stat.by, function(stat) {
        levels(meta.data[[stat]])[1] %||% sort(unique(meta.data[[stat]]))[1]
      })
      log_message(
        "{.arg stat_level} is set to {.val {stat_level}}"
      )
    } else {
      if (length(stat_level) == 1) {
        stat_level <- rep(stat_level, length(stat.by))
      }
      if (length(stat_level) != length(stat.by)) {
        log_message(
          "{.arg stat_level} must be of length 1 or the same length as {.arg stat.by}",
          message_type = "error"
        )
      }
    }
    if (is.null(names(stat_level))) {
      names(stat_level) <- stat.by
    }
    for (i in stat.by) {
      meta.data[[i]] <- meta.data[[i]] %in% stat_level[[i]]
    }
  }

  if (plot_type %in% c("rose", "ring", "pie")) {
    aspect.ratio <- 1
  }

  if (any(group.by != "All.groups") && plot_type %in% plot_types) {
    log_message(
      "{.arg group.by} is not used when plot {.val {plot_types}}",
      message_type = "warning"
    )
  }
  if (stat_type == "percent" && plot_type %in% plot_types) {
    log_message(
      "{.arg stat_type} is forcibly set to {.val count} when plot {.val {plot_types}}",
      message_type = "warning"
    )
    stat_type <- "count"
  }

  dat_all <- meta.data[,
    unique(c(stat.by, group.by, split.by, bg.by)),
    drop = FALSE
  ]
  nlev <- sapply(dat_all, nlevels)
  nlev <- nlev[nlev > 100]
  if (length(nlev) > 0 && isFALSE(force)) {
    log_message(
      "The following variables have more than 100 levels: {.val {names(nlev)}}",
      message_type = "warning"
    )
    answer <- utils::askYesNo("Are you sure to continue?", default = FALSE)
    if (isFALSE(answer)) {
      return(invisible(NULL))
    }
  }

  dat_split <- split.data.frame(dat_all, dat_all[[split.by]])
  plist <- list()
  if (plot_type %in% c("bar", "rose", "ring", "pie", "trend", "area", "dot")) {
    xlab <- xlab %||% group.by
    ylab <- ylab %||% ifelse(stat_type == "count", "Count", "Percentage")
    if (identical(theme_use, "theme_blank")) {
      theme_args[["xlab"]] <- xlab
      theme_args[["ylab"]] <- ylab
      if (plot_type %in% c("rose", "ring", "pie")) {
        theme_args[["add_coord"]] <- FALSE
      }
    }
    colors <- palette_colors(
      dat_all[[stat.by]],
      palette = palette,
      palcolor = palcolor,
      NA_color = NA_color,
      NA_keep = TRUE
    )

    comb_list <- list()
    comb <- expand.grid(
      stat_name = stat.by,
      group_name = group.by,
      stringsAsFactors = FALSE
    )
    if (isTRUE(individual)) {
      for (g in group.by) {
        comb_list[[g]] <- merge(
          comb,
          expand.grid(
            group_name = g,
            group_element = levels(dat_all[[g]]),
            split_name = levels(dat_all[[split.by]]),
            stringsAsFactors = FALSE
          ),
          by = "group_name"
        )
      }
    } else {
      for (g in group.by) {
        comb_list[[g]] <- merge(
          comb,
          expand.grid(
            group_name = g,
            group_element = list(levels(dat_all[[g]])),
            split_name = levels(dat_all[[split.by]]),
            stringsAsFactors = FALSE
          ),
          by = "group_name"
        )
      }
    }
    comb <- do.call(rbind, comb_list)
    rownames(comb) <- paste0(
      comb[["group_name"]],
      ":",
      sapply(comb[["group_element"]], function(x) paste0(x, collapse = ",")),
      ":",
      comb[["split_name"]]
    )

    plist <- lapply(
      stats::setNames(rownames(comb), rownames(comb)), function(i) {
        stat.by <- comb[i, "stat_name"]
        sp <- comb[i, "split_name"]
        g <- comb[i, "group_name"]
        single_group <- comb[[i, "group_element"]]
        dat_split_use <- dat_split[[ifelse(split.by == "All.groups", 1, sp)]]
        colors_use <- colors[
          names(colors) %in%
            dat_split_use[[stat.by]]
        ]
        if (
          any(is.na(dat_split_use[[
            stat.by
          ]])) &&
            isTRUE(NA_stat)
        ) {
          colors_use <- c(colors_use, colors["NA"])
        }
        if (stat_type == "percent") {
          dat_use <- dat_split_use |>
            stats::xtabs(
              formula = paste0("~", stat.by, "+", g),
              addNA = NA_stat
            ) |>
            as.data.frame() |>
            dplyr::group_by(
              dplyr::across(
                dplyr::all_of(g)
              ),
              .drop = FALSE
            ) |>
            dplyr::mutate(groupn = sum(Freq)) |>
            dplyr::group_by(
              dplyr::across(
                dplyr::all_of(
                  c(stat.by, g)
                )
              ),
              .drop = FALSE
            ) |>
            dplyr::mutate(value = Freq / groupn) |>
            as.data.frame()
        } else {
          dat_use <- dat_split_use |>
            stats::xtabs(
              formula = paste0("~", stat.by, "+", g),
              addNA = NA_stat
            ) |>
            as.data.frame() |>
            dplyr::mutate(value = Freq)
        }
        dat <- dat_use[dat_use[[g]] %in% single_group, , drop = FALSE]
        dat[[g]] <- factor(
          dat[[g]],
          levels = levels(dat[[g]])[levels(dat[[g]]) %in% dat[[g]]]
        )
        dat <- dat[!is.na(dat[["value"]]), , drop = FALSE]
        if (!is.null(bg.by)) {
          bg <- bg.by
          bg_color <- palette_colors(
            levels(dat_all[[bg]]),
            palette = bg_palette,
            palcolor = bg_palcolor
          )
        } else {
          bg <- g
          bg_color <- palette_colors(
            levels(dat_all[[bg]]),
            palcolor = bg_palcolor %||%
              rep(c("transparent", "grey85"), nlevels(dat_all[[bg]]))
          )
        }

        if (isTRUE(flip)) {
          dat[[g]] <- factor(dat[[g]], levels = rev(levels(dat[[g]])))
          aspect.ratio <- 1 / aspect.ratio
          if (length(aspect.ratio) == 0 || is.na(aspect.ratio)) {
            aspect.ratio <- NULL
          }
        }
        if (plot_type == "ring") {
          dat[[g]] <- factor(dat[[g]], levels = c("   ", levels(dat[[g]])))
          dat <- rbind(dat, dat[nrow(dat) + 1, , drop = FALSE])
          dat[nrow(dat), g] <- "   "
        }
        if (plot_type == "dot") {
          position_use <- position_identity()
          scalex <- scale_x_discrete(drop = !keep_empty)
        } else {
          if (position == "stack") {
            position_use <- position_stack(vjust = 0.5)
            scalex <- scale_x_discrete(drop = !keep_empty, expand = c(0, 0))
            scaley <- scale_y_continuous(
              labels = if (stat_type == "count") {
                scales::number
              } else {
                scales::percent
              },
              expand = c(0, 0)
            )
          } else if (position == "dodge") {
            if (plot_type == "area") {
              position_use <- position_dodge2(width = 0.9, preserve = "total")
            } else {
              position_use <- position_dodge2(width = 0.9, preserve = "single")
            }
            scalex <- scale_x_discrete(drop = !keep_empty)
            scaley <- scale_y_continuous(
              limits = c(0, max(dat[["value"]], na.rm = TRUE) * 1.1),
              labels = if (stat_type == "count") {
                scales::number
              } else {
                scales::percent
              },
              expand = c(0, 0)
            )
          }
        }
        if (position == "stack") {
          bg_layer <- NULL
        } else {
          bg_data <- stats::na.omit(unique(dat[, g, drop = FALSE]))
          bg_data[["x"]] <- as.numeric(bg_data[[g]])
          bg_data[["xmin"]] <- ifelse(
            bg_data[["x"]] == min(bg_data[["x"]]),
            -Inf,
            bg_data[["x"]] - 0.5
          )
          bg_data[["xmax"]] <- ifelse(
            bg_data[["x"]] == max(bg_data[["x"]]),
            Inf,
            bg_data[["x"]] + 0.5
          )
          bg_data[["ymin"]] <- -Inf
          bg_data[["ymax"]] <- Inf
          bg_data[["fill"]] <- bg_color[bg_map[[g]][as.character(bg_data[[g]])]]
          bg_layer <- geom_rect(
            data = bg_data,
            xmin = bg_data[["xmin"]],
            xmax = bg_data[["xmax"]],
            ymin = bg_data[["ymin"]],
            ymax = bg_data[["ymax"]],
            fill = bg_data[["fill"]],
            alpha = bg_alpha,
            inherit.aes = FALSE
          )
        }

        if (plot_type == "bar") {
          p <- ggplot(
            dat,
            aes(x = .data[[g]], y = value, group = .data[[stat.by]])
          ) +
            bg_layer +
            geom_col(
              aes(fill = .data[[stat.by]]),
              width = 0.8,
              color = "black",
              alpha = alpha,
              position = position_use
            ) +
            scalex +
            scaley
        }
        if (plot_type == "trend") {
          dat_area <- dat[rep(seq_len(nrow(dat)), each = 2), , drop = FALSE]
          dat_area[[g]] <- as.numeric(dat_area[[g]])
          dat_area[seq(1, nrow(dat_area), 2), g] <- dat_area[
            seq(1, nrow(dat_area), 2),
            g
          ] -
            0.3
          dat_area[seq(2, nrow(dat_area), 2), g] <- dat_area[
            seq(2, nrow(dat_area), 2),
            g
          ] +
            0.3
          p <- ggplot(
            dat,
            aes(x = .data[[g]], y = value, fill = .data[[stat.by]])
          ) +
            bg_layer +
            geom_area(
              data = dat_area,
              mapping = aes(x = .data[[g]], fill = .data[[stat.by]]),
              alpha = alpha / 2,
              color = "grey50",
              position = position_use
            ) +
            geom_col(
              aes(fill = .data[[stat.by]]),
              width = 0.6,
              color = "black",
              alpha = alpha,
              position = position_use
            ) +
            scalex +
            scaley
        }

        textpath_layer <- NULL
        if (plot_type == "rose" && g != "All.groups") {
          group_levels <- levels(dat[[g]])
          group_levels <- group_levels[group_levels != ""]
          n_grp <- length(group_levels)
          if (n_grp > 0) {
            if (position == "stack") {
              y_total <- stats::aggregate(
                dat[["value"]],
                by = list(dat[[g]]), FUN = sum, na.rm = TRUE
              )
            } else {
              y_total <- stats::aggregate(
                dat[["value"]],
                by = list(dat[[g]]), FUN = max, na.rm = TRUE
              )
            }
            colnames(y_total) <- c("group", "y_max")
            y_total <- y_total[y_total[["group"]] %in% group_levels, , drop = FALSE]
            y_max_global <- max(y_total[["y_max"]], na.rm = TRUE)
            y_outer <- y_max_global * 1.15
            npt <- 40
            path_margin <- 0.04
            path_df <- do.call(
              rbind, lapply(seq_along(group_levels), function(idx) {
                lev <- group_levels[idx]
                x_idx <- which(levels(dat[[g]]) == lev)
                x_start <- x_idx - 0.5 + path_margin
                x_end <- x_idx + 0.5 - path_margin
                data.frame(
                  x = seq(x_start, x_end, length.out = npt),
                  y = y_outer,
                  label = lev,
                  group = idx
                )
              })
            )
            if (!is.null(path_df) && nrow(path_df) > 0) {
              textpath_layer <- geomtextpath::geom_textpath(
                aes(x = x, y = y, label = label, group = group),
                data = path_df,
                inherit.aes = FALSE,
                size = label.size,
                color = label.fg,
                linewidth = 0,
                upright = TRUE
              )
              y_lim_max <- max(
                y_outer * 1.05,
                if (position == "dodge") max(dat[["value"]], na.rm = TRUE) * 1.1 else max(dat[["value"]], na.rm = TRUE)
              )
              scaley <- scale_y_continuous(
                limits = c(0, y_lim_max),
                labels = if (stat_type == "count") scales::number else scales::percent,
                expand = c(0, 0)
              )
            }
          }
        }

        if (plot_type == "rose") {
          p <- ggplot(
            dat,
            aes(x = .data[[g]], y = value, group = .data[[stat.by]])
          ) +
            bg_layer +
            geom_col(
              aes(fill = .data[[stat.by]]),
              width = 0.8,
              color = "black",
              alpha = alpha,
              position = position_use
            ) +
            scalex +
            scaley +
            coord_polar(theta = "x", start = ifelse(flip, pi / 2, 0)) +
            textpath_layer
        }
        if (plot_type == "ring" || plot_type == "pie") {
          p <- ggplot(
            dat,
            aes(x = .data[[g]], y = value, group = .data[[stat.by]])
          ) +
            bg_layer +
            geom_col(
              aes(fill = .data[[stat.by]]),
              width = 0.8,
              color = "black",
              alpha = alpha,
              position = position_use
            ) +
            scalex +
            scaley +
            coord_polar(theta = "y", start = ifelse(flip, pi / 2, 0))
        }
        if (plot_type == "area") {
          p <- ggplot(
            dat,
            aes(x = .data[[g]], y = value, group = .data[[stat.by]])
          ) +
            bg_layer +
            geom_area(
              aes(fill = .data[[stat.by]]),
              color = "black",
              alpha = alpha,
              position = position_use
            ) +
            scalex +
            scaley
        }
        if (plot_type == "dot") {
          p <- ggplot(dat, aes(x = .data[[g]], y = .data[[stat.by]])) +
            bg_layer +
            geom_point(
              aes(fill = .data[[stat.by]], size = value),
              color = "black",
              alpha = alpha,
              shape = 21,
              position = position_use
            ) +
            scalex +
            scale_size_area(name = capitalize(stat_type), max_size = 12) +
            guides(size = guide_legend(override.aes = list(fill = "grey30")))
        }
        if (isTRUE(label)) {
          if (plot_type == "dot") {
            p <- p +
              ggrepel::geom_text_repel(
                aes(
                  x = .data[[g]],
                  y = .data[[stat.by]],
                  label = if (stat_type == "count") {
                    value
                  } else {
                    paste0(round(value * 100, 1), "%")
                  },
                ),
                colour = label.fg,
                size = label.size,
                bg.color = label.bg,
                bg.r = label.bg.r,
                point.size = NA,
                max.overlaps = 100,
                min.segment.length = 0,
                force = 0,
                position = position_use
              )
          } else {
            p <- p +
              ggrepel::geom_text_repel(
                aes(
                  label = if (stat_type == "count") {
                    value
                  } else {
                    paste0(round(value * 100, 1), "%")
                  },
                  y = value
                ),
                colour = label.fg,
                size = label.size,
                bg.color = label.bg,
                bg.r = label.bg.r,
                point.size = NA,
                max.overlaps = 100,
                min.segment.length = 0,
                force = 0,
                position = position_use
              )
          }
        }
        if (plot_type %in% c("rose")) {
          axis_text_x <- if (!is.null(textpath_layer)) element_blank() else element_text()
        } else if (plot_type %in% c("ring", "pie")) {
          axis_text_x <- element_text()
        } else {
          axis_text_x <- element_text(
            angle = 45, hjust = 1, vjust = 1
          )
        }
        title <- title %||% sp
        p <- p +
          labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
          scale_fill_manual(
            name = paste0(stat.by, ":"),
            values = colors_use,
            na.value = colors_use["NA"],
            drop = FALSE,
            limits = names(colors_use),
            na.translate = TRUE
          ) +
          do.call(theme_use, theme_args) +
          theme(
            aspect.ratio = aspect.ratio,
            axis.text.x = axis_text_x,
            legend.position = legend.position,
            legend.direction = legend.direction,
            panel.grid.major = if (plot_type == "trend" & stat_type == "percent") {
              element_blank()
            } else {
              element_line(colour = "grey80", linetype = 2)
            }
          ) +
          guides(
            fill = guide_legend(
              title.hjust = 0,
              order = 1,
              override.aes = list(size = 4, color = "black", alpha = 1)
            )
          )
        if (isTRUE(flip) && !plot_type %in% c("pie", "rose")) {
          p <- p + coord_flip()
        }
        return(p)
      }
    )
  } else if (plot_type %in% c("chord", "sankey", "venn", "upset")) {
    colors <- palette_colors(stat.by, palette = palette, palcolor = palcolor)
    nlev <- nlevels(dat_all[[split.by]])
    chord_use_temp <- plot_type == "chord" && isTRUE(combine) && nlev > 1L
    if (plot_type == "chord" && isTRUE(combine)) {
      if (chord_use_temp) {
        temp <- tempfile(fileext = "png")
        grDevices::png(temp)
        grDevices::dev.control("enable")
        if (is.null(nrow) && is.null(ncol)) {
          nrow <- ceiling(sqrt(nlev))
          ncol <- ceiling(nlev / nrow)
        }
        if (is.null(nrow)) {
          nrow <- ceiling(sqrt(ncol))
        }
        if (is.null(ncol)) {
          ncol <- ceiling(sqrt(nrow))
        }
        graphics::par(mfrow = c(nrow, ncol))
      } else {
        grDevices::dev.control("enable")
      }
    }

    for (sp in levels(dat_all[[split.by]])) {
      dat_use <- dat_split[[ifelse(split.by == "All.groups", 1, sp)]]
      if (plot_type == "venn") {
        dat_list <- as.list(dat_use[, stat.by])
        dat_list <- lapply(
          stats::setNames(
            names(dat_list), names(dat_list)
          ),
          function(x) {
            lg <- dat_list[[x]]
            names(lg) <- rownames(dat_use)
            cellkeep <- names(lg)[lg]
            cellkeep
          }
        )
        venn <- ggVennDiagram::Venn(dat_list)
        data <- ggVennDiagram::process_data(venn)
        dat_venn_region <- ggVennDiagram::venn_region(data)
        idname <- dat_venn_region[["name"]][
          dat_venn_region[["name"]] %in% stat.by
        ]
        names(idname) <- dat_venn_region[["id"]][
          dat_venn_region[["name"]] %in% stat.by
        ]
        idcomb <- strsplit(dat_venn_region[["id"]], split = "")
        colorcomb <- lapply(idcomb, function(x) colors[idname[as.character(x)]])
        dat_venn_region[["colors"]] <- sapply(
          colorcomb,
          function(x) blendcolors(x, mode = "blend")
        )
        dat_venn_region[["label"]] <- paste0(
          dat_venn_region[["count"]],
          "\n",
          round(
            dat_venn_region[["count"]] / sum(dat_venn_region[["count"]]) * 100,
            1
          ),
          "%"
        )
        dat_venn_setedge <- ggVennDiagram::venn_setedge(data)
        dat_venn_setedge[["colors"]] <- colors[stat.by[as.numeric(
          dat_venn_setedge[["id"]]
        )]]

        venn_regionedge_data <- ggVennDiagram::venn_regionedge(data)
        venn_regionedge_data[["colors"]] <- dat_venn_region[["colors"]][match(
          venn_regionedge_data[["id"]], dat_venn_region[["id"]]
        )]

        p <- ggplot() +
          geom_polygon(
            data = venn_regionedge_data,
            aes(X, Y, fill = colors, group = id),
            alpha = alpha
          ) +
          geom_path(
            data = dat_venn_setedge,
            aes(X, Y, group = id),
            color = "black",
            linewidth = 1,
            show.legend = FALSE
          ) +
          ggrepel::geom_text_repel(
            data = ggVennDiagram::venn_setlabel(data),
            aes(X, Y, label = paste0(
              name, "\n(", count, ")"
            )),
            fontface = "bold",
            colour = label.fg,
            size = label.size + 0.5,
            bg.color = label.bg,
            bg.r = label.bg.r,
            point.size = NA,
            max.overlaps = 100,
            force = 0,
            min.segment.length = 0,
            segment.colour = "black"
          ) +
          ggrepel::geom_text_repel(
            data = ggVennDiagram::venn_regionlabel(data),
            aes(X, Y, label = count),
            colour = label.fg,
            size = label.size,
            bg.color = label.bg,
            bg.r = label.bg.r,
            point.size = NA,
            max.overlaps = 100,
            force = 0,
            min.segment.length = 0,
            segment.colour = "black"
          ) +
          scale_fill_identity() +
          coord_equal() +
          theme(
            plot.title = element_text(hjust = 0.5),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title.y = element_blank(),
            axis.text = element_blank(),
            axis.ticks = element_blank()
          )
        p <- p + labs(x = sp, title = title, subtitle = subtitle)
      }

      if (plot_type == "upset") {
        for (n in seq_len(nrow(dat_use))) {
          dat_use[["intersection"]][n] <- list(
            stat.by[unlist(dat_use[
              n,
              stat.by
            ])]
          )
        }
        dat_use <- dat_use[
          sapply(dat_use[["intersection"]], length) > 0, ,
          drop = FALSE
        ]
        p <- ggplot(
          dat_use, aes(x = intersection)
        ) +
          geom_bar(
            aes(fill = after_stat(count)),
            color = "black",
            width = 0.5,
            show.legend = FALSE
          ) +
          ggrepel::geom_text_repel(
            aes(label = after_stat(count)),
            stat = "count",
            colour = label.fg,
            size = label.size,
            bg.color = label.bg,
            bg.r = label.bg.r,
            point.size = NA,
            max.overlaps = 100,
            force = 0,
            min.segment.length = 0,
            segment.colour = "black"
          ) +
          labs(
            title = title,
            subtitle = subtitle,
            x = sp,
            y = "Intersection size"
          ) +
          ggupset::scale_x_upset(sets = stat.by, n_intersections = 20) +
          scale_fill_gradientn(
            colors = palette_colors(palette = "material-indigo")
          ) +
          theme_this(
            aspect.ratio = 0.6,
            panel.grid.major = element_line(colour = "grey80", linetype = 2)
          ) +
          ggupset::theme_combmatrix(
            combmatrix.label.text = element_text(size = 12, color = "black"),
            combmatrix.label.extra_spacing = 6
          )
        p <- p + labs(title = title, subtitle = subtitle)
      }

      if (plot_type == "sankey") {
        colors <- palette_colors(
          c(
            unique(
              unlist(
                lapply(
                  dat_all[, stat.by, drop = FALSE],
                  levels
                )
              )
            ),
            NA
          ),
          palette = palette,
          palcolor = palcolor,
          NA_keep = TRUE,
          NA_color = NA_color
        )

        legend_list <- list()
        for (l in stat.by) {
          df <- data.frame(
            factor(levels(dat_use[[l]]), levels = levels(dat_use[[l]]))
          )
          colnames(df) <- l

          legend_list[[l]] <- get_legend(
            ggplot(data = df) +
              geom_col(
                aes(x = 1, y = 1, fill = .data[[l]]),
                color = "black"
              ) +
              scale_fill_manual(
                values = colors[levels(dat_use[[l]])]
              ) +
              guides(
                fill = guide_legend(
                  title.hjust = 0,
                  title.vjust = 0,
                  order = 1,
                  override.aes = list(size = 4, color = "black", alpha = 1)
                )
              ) +
              theme_this(
                legend.position = "bottom",
                legend.direction = legend.direction
              )
          )

          if (any(is.na(dat_use[[l]]))) {
            raw_levels <- levels(dat_use[[l]])
            dat_use[[l]] <- as.character(dat_use[[l]])
            dat_use[[l]][is.na(dat_use[[l]])] <- "NA"
            dat_use[[l]] <- factor(dat_use[[l]], levels = c(raw_levels, "NA"))
          }
        }

        if (legend.direction == "vertical") {
          legend <- do.call(cbind, legend_list)
        } else {
          legend <- do.call(rbind, legend_list)
        }

        dat <- suppressWarnings(
          make_long(
            dat_use,
            dplyr::all_of(stat.by)
          )
        )
        dat$node <- factor(dat$node, levels = rev(names(colors)))
        p0 <- ggplot(
          dat,
          aes(
            x = x,
            next_x = next_x,
            node = node,
            next_node = next_node,
            fill = node
          )
        ) +
          geom_sankey(
            color = "black",
            flow.alpha = alpha,
            show.legend = FALSE,
            na.rm = FALSE
          ) +
          scale_fill_manual(values = colors, drop = FALSE) +
          scale_x_discrete(expand = c(0, 0.2)) +
          theme_void() +
          theme(axis.text.x = element_text())
        gtable <- as_grob(p0)
        gtable <- add_grob(
          gtable = gtable,
          grob = legend,
          position = legend.position
        )
        p <- patchwork::wrap_plots(gtable)
      }

      if (plot_type == "chord") {
        colors <- palette_colors(
          c(
            unique(
              unlist(
                lapply(
                  dat_all[, stat.by, drop = FALSE],
                  levels
                )
              )
            ),
            NA
          ),
          palette = palette,
          palcolor = palcolor,
          NA_keep = TRUE,
          NA_color = NA_color
        )
        M <- table(
          dat_use[[stat.by[1]]],
          dat_use[[stat.by[2]]],
          useNA = "ifany"
        )
        m <- matrix(M, ncol = ncol(M), dimnames = dimnames(M))
        colnames(m)[is.na(colnames(m))] <- "NA"
        circlize::chordDiagram(
          m,
          grid.col = colors,
          transparency = 0.2,
          link.lwd = 1,
          link.lty = 1,
          link.border = 1
        )
        circlize::circos.clear()
        p <- grDevices::recordPlot()
      }

      plist[[sp]] <- p
    }
  }
  if (isTRUE(combine) && plot_type == "chord") {
    plot <- grDevices::recordPlot()
    if (chord_use_temp) {
      grDevices::dev.off()
      unlink(temp)
    }
    return(plot)
  }
  if (isTRUE(combine) && plot_type != "chord") {
    if (length(plist) > 1) {
      plot <- patchwork::wrap_plots(
        plotlist = plist,
        nrow = nrow,
        ncol = ncol,
        byrow = byrow
      )
    } else {
      plot <- plist[[1]]
    }
    return(plot)
  } else {
    return(plist)
  }
}
