#' @title Get colors from Chinese colors dataset or palettes
#'
#' @description
#' Search for colors in the Chinese colors dataset and all available palettes.
#' This function can search by palette names, color names (pinyin or Chinese), numbers, or hex codes.
#' It automatically searches in all palettes and reports which palette(s) contain the found colors.
#'
#' @md
#' @param ... One or more search values.
#' Can be palette names, color names (pinyin or Chinese), numbers, or hex codes.
#' If NULL, using all Chinese colors.
#' Can also be `ggplot`, `patchwork`, or other renderable plot objects
#' (`gtable`, `grob`, `gList`, `ComplexHeatmap::Heatmap`, `pheatmap`, `trellis`)
#' to get the colors used in the plots.
#' @param palettes Optional. A named list of palettes to search in.
#' If `NULL` (default), searches in all available palettes.
#'
#' @return A data frame with class `colors` containing matching color information.
#' The result is automatically printed using [print.colors()].
#' For `ggplot` or `patchwork` objects, returns a two-column `colors` data frame
#' with the factor levels (`factor`) and their mapped colors (`color`).
#' For other renderable plot objects, returns a two-column `colors` data frame
#' with the colors used in the plot (`color`) and their Chinese names (`name`).
#'
#' @export
#'
#' @seealso
#' [chinese_colors] for the dataset of Chinese traditional colors.
#' [get_chinese_palettes] for getting Chinese color palettes.
#' [ChineseColors] for the ChineseColors object.
#'
#' @examples
#' get_colors("Paired")
#'
#' get_colors("#FF7F00")
#'
#' get_colors("pinlan")
#' get_colors(44)
#' get_colors("#2B73AF")
#'
#' get_colors("cyan", palettes = "ChineseSet64")
#'
#' # Get the factor-color mapping used in a ggplot object
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(mpg, wt, color = factor(cyl))) +
#'   geom_point() +
#'   scale_color_manual(values = get_colors("Paired")$hex)
#' get_colors(p)
get_colors <- function(..., palettes = NULL) {
  args <- list(...)

  colors_df <- thisplot::chinese_colors
  available_columns <- colnames(colors_df)

  all_palettes <- c(
    thisplot::palette_list,
    get_chinese_palettes()
  )
  specified_palette_names <- character(0)
  if (!is.null(palettes)) {
    if (is.character(palettes)) {
      all_palettes_list <- c(
        thisplot::palette_list,
        get_chinese_palettes()
      )
      specified_palette_names <- palettes
      all_palettes <- all_palettes_list[names(all_palettes_list) %in% palettes]
      if (length(all_palettes) == 0) {
        log_message(
          "No matching palettes found for: {.val {palettes}}",
          message_type = "error"
        )
      }
    } else {
      log_message(
        "Invalid palettes argument: {.val {palettes}}",
        message_type = "error"
      )
    }
  }

  is_plot <- vapply(
    args,
    function(x) inherits(x, "ggplot") || inherits(x, "patchwork"),
    logical(1)
  )

  if (any(is_plot)) {
    if (!all(is_plot)) {
      log_message(
        "Mixing plot objects with search values is not supported. ",
        "Only colors from {length(which(is_plot))} plot object{?s} will be returned.",
        message_type = "warning"
      )
    }
    result <- do.call(rbind, lapply(args[is_plot], extract_plot_factors))
    result <- unique(result)
    rownames(result) <- NULL

    if (length(specified_palette_names) > 0 && nrow(result) > 0) {
      palette_hexes <- unique(toupper(unlist(all_palettes)))
      result <- result[toupper(result$color) %in% palette_hexes, , drop = FALSE]
    }

    if (nrow(result) == 0) {
      log_message(
        "No factor-color mapping found in {length(which(is_plot))} plot{?s}",
        message_type = "warning"
      )
    }
    class(result) <- c("colors", "data.frame")
    return(result)
  }

  is_render <- vapply(
    args,
    function(x) {
      inherits(x, c("gtable", "grob", "gList")) ||
        inherits(x, c("Heatmap", "HeatmapList")) ||
        inherits(x, "pheatmap") ||
        inherits(x, "trellis")
    },
    logical(1)
  )

  if (any(is_render)) {
    if (!all(is_render)) {
      log_message(
        "Mixing plot objects with search values is not supported. ",
        "Only colors from {length(which(is_render))} plot object{?s} will be returned.",
        message_type = "warning"
      )
    }
    render_hexes <- unique(to_hex(unlist(lapply(args[is_render], function(x) {
      if (inherits(x, "gList")) {
        return(collect_grob_colors(grid::grobTree(x)))
      }
      if (inherits(x, "grob")) {
        return(collect_grob_colors(x))
      }
      if (inherits(x, c("Heatmap", "HeatmapList"))) {
        check_r("ComplexHeatmap", verbose = FALSE)
        # Anchor colors of the color mapping, e.g. from colorRamp2()
        anchor_colors <- tryCatch(
          attr(x@matrix_color_mapping@col_fun, "colors"),
          error = function(e) NULL
        )
        gt <- tryCatch(
          grid::grid.grabExpr(ComplexHeatmap::draw(x)),
          error = function(e) NULL
        )
        return(c(
          collect_grob_colors(gt),
          if (is.null(anchor_colors)) character(0) else anchor_colors
        ))
      }
      if (inherits(x, c("pheatmap", "trellis"))) {
        gt <- tryCatch(
          grid::grid.grabExpr(print(x)),
          error = function(e) NULL
        )
        return(collect_grob_colors(gt))
      }
      character(0)
    }))))

    if (length(specified_palette_names) > 0 && length(render_hexes) > 0) {
      palette_hexes <- unique(toupper(unlist(all_palettes)))
      render_hexes <- render_hexes[toupper(render_hexes) %in% palette_hexes]
    }

    if (length(render_hexes) > 0) {
      dataset_hex_upper <- toupper(colors_df$hex)
      matched_positions <- match(toupper(render_hexes), dataset_hex_upper)
      result <- do.call(rbind, lapply(seq_along(render_hexes), function(i) {
        pos <- matched_positions[i]
        if (!is.na(pos)) {
          data.frame(
            color = render_hexes[i],
            name = colors_df$name_ch[pos],
            stringsAsFactors = FALSE
          )
        } else {
          data.frame(
            color = render_hexes[i],
            name = render_hexes[i],
            stringsAsFactors = FALSE
          )
        }
      }))
    } else {
      result <- data.frame(
        color = character(0),
        name = character(0),
        stringsAsFactors = FALSE
      )
    }
    result <- result[order(result$name == result$color), , drop = FALSE]
    rownames(result) <- NULL

    if (nrow(result) == 0) {
      log_message(
        "No colors found in {length(which(is_render))} plot object{?s}",
        message_type = "warning"
      )
    }
    class(result) <- c("colors", "data.frame")
    return(result)
  }

  unsupported <- vapply(args, function(a) {
    if (isS4(a)) {
      return(TRUE)
    }
    if (is.list(a) && !is.object(a)) {
      return(!all(vapply(a, is.atomic, logical(1))))
    }
    !is.atomic(a)
  }, logical(1))
  if (any(unsupported)) {
    bad_arg <- args[unsupported][[1]]
    log_message(
      "Cannot search with an object of {.cls {class(bad_arg)}}. ",
      "Supported inputs: search values, ggplot/patchwork, or renderable ",
      "plot objects (gtable, grob, gList, ComplexHeatmap::Heatmap, pheatmap, trellis).",
      message_type = "error"
    )
  }

  if (length(args) == 0) {
    if (length(specified_palette_names) > 0) {
      palette_colors_list <- character(0)
      for (pal_name in specified_palette_names) {
        if (pal_name %in% names(all_palettes)) {
          palette_colors_list <- c(palette_colors_list, all_palettes[[pal_name]])
        }
      }
      palette_colors_list <- unique(palette_colors_list)

      if (length(palette_colors_list) > 0) {
        palette_hex_upper <- toupper(palette_colors_list)
        colors_hex_upper <- toupper(colors_df$hex)
        palette_color_indices <- which(colors_hex_upper %in% palette_hex_upper)

        if (length(palette_color_indices) > 0) {
          result <- colors_df[palette_color_indices, , drop = FALSE]
        } else {
          result <- data.frame(
            name = palette_colors_list,
            rgb = hex_to_rgb(palette_colors_list),
            hex = palette_colors_list,
            stringsAsFactors = FALSE
          )
        }
      } else {
        result <- colors_df[integer(0), , drop = FALSE]
      }
    } else {
      result <- colors_df
    }
    class(result) <- c("colors", "data.frame")
    return(result)
  }

  search_values <- unlist(args, use.names = FALSE)
  all_matches <- integer(0)
  found_hex_codes <- character(0)

  palette_names_found <- character(0)
  palette_names_not_found <- character(0)
  palette_colors_found <- character(0)
  remaining_search_values <- character(0)

  looks_like_palette_name <- function(s) {
    if (grepl("^[A-Z][A-Z0-9]*$", s)) {
      return(TRUE)
    }
    if (grepl("^[A-Z][a-zA-Z0-9]*$", s)) {
      return(TRUE)
    }
    return(FALSE)
  }

  for (val in search_values) {
    val_char <- as.character(val)
    if (val_char %in% names(all_palettes)) {
      palette_names_found <- c(palette_names_found, val_char)
      palette_colors_found <- c(palette_colors_found, all_palettes[[val_char]])
    } else {
      is_hex <- grepl("^#[0-9A-Fa-f]{6}$", val_char)
      is_number <- !is.na(suppressWarnings(as.numeric(val_char)))
      if (!is_hex && !is_number && looks_like_palette_name(val_char)) {
        palette_names_not_found <- c(palette_names_not_found, val_char)
      }
      remaining_search_values <- c(remaining_search_values, val_char)
    }
  }

  if (length(palette_names_found) > 0) {
    palette_colors_found <- unique(palette_colors_found)
    if (length(remaining_search_values) == 0) {
      if (length(palette_colors_found) > 0) {
        palette_hex_upper <- toupper(palette_colors_found)
        colors_hex_upper <- toupper(colors_df$hex)
        hex_matches <- which(colors_hex_upper %in% palette_hex_upper)
        if (length(hex_matches) > 0) {
          result <- colors_df[hex_matches, , drop = FALSE]
        } else {
          result <- data.frame(
            name = palette_colors_found,
            rgb = hex_to_rgb(palette_colors_found),
            hex = palette_colors_found,
            stringsAsFactors = FALSE
          )
        }
        class(result) <- c("colors", "data.frame")
        cli::cli_h3("Found palette{?s}: {.val {palette_names_found}}")
        return(result)
      }
    }
    if (length(palette_colors_found) > 0) {
      palette_hex_upper <- toupper(palette_colors_found)
      colors_hex_upper <- toupper(colors_df$hex)
      palette_color_indices <- which(colors_hex_upper %in% palette_hex_upper)
      colors_df <- colors_df[palette_color_indices, , drop = FALSE]
      cli::cli_h3("Searching in palette{?s}: {.val {palette_names_found}}")
    }
  }

  if (length(specified_palette_names) > 0 && length(remaining_search_values) > 0) {
    cli::cli_h3("Searching in palette{?s}: {.val {specified_palette_names}}")
  }

  if (length(remaining_search_values) > 0) {
    search_values <- remaining_search_values
  } else {
    search_values <- character(0)
  }

  for (val in search_values) {
    val_char <- as.character(val)

    for (col in available_columns) {
      if (col == "num") {
        val_num <- suppressWarnings(as.numeric(val_char))
        if (!is.na(val_num)) {
          matches <- which(colors_df[[col]] == val_num)
          all_matches <- c(all_matches, matches)
        }
      } else {
        matches <- which(colors_df[[col]] == val_char)
        all_matches <- c(all_matches, matches)
      }
    }
  }

  idx <- unique(all_matches)

  if (length(search_values) > 1 && length(idx) > 0) {
    ordered_idx <- integer(0)
    for (val in search_values) {
      val_char <- as.character(val)
      for (col in available_columns) {
        if (col == "num") {
          val_num <- suppressWarnings(as.numeric(val_char))
          if (!is.na(val_num)) {
            match_idx <- which(colors_df[[col]] == val_num)
          } else {
            match_idx <- integer(0)
          }
        } else {
          match_idx <- which(colors_df[[col]] == val_char)
        }
        if (length(match_idx) > 0) {
          ordered_idx <- c(ordered_idx, match_idx)
        }
      }
    }
    idx <- unique(ordered_idx)
  }

  palette_matches <- list()
  if (length(search_values) > 0) {
    if (length(idx) > 0) {
      found_hex_codes <- unique(colors_df$hex[idx])
    }

    for (val in search_values) {
      val_char <- as.character(val)
      if (grepl("^#[0-9A-Fa-f]{6}$", val_char)) {
        found_hex_codes <- c(found_hex_codes, toupper(val_char))
      }
    }
    found_hex_codes <- unique(found_hex_codes)

    for (pal_name in names(all_palettes)) {
      pal_colors <- all_palettes[[pal_name]]
      if (is.null(pal_colors) || length(pal_colors) == 0) {
        next
      }

      pal_colors_upper <- toupper(pal_colors)

      for (hex_code in found_hex_codes) {
        hex_upper <- toupper(hex_code)
        matches <- which(pal_colors_upper == hex_upper)
        if (length(matches) > 0) {
          if (!hex_code %in% names(palette_matches)) {
            palette_matches[[hex_code]] <- list()
          }
          palette_matches[[hex_code]][[pal_name]] <- matches
        }
      }
    }
  }

  if (length(palette_matches) > 0) {
    cli::cli_h3("Found in:")
    unique_hex_codes <- unique(names(palette_matches))
    for (hex_code in unique_hex_codes) {
      pal_info <- palette_matches[[hex_code]]
      pal_names <- unique(names(pal_info))
      cli::cli_text("{.strong {hex_code}}: {.val {pal_names}}")
    }

    if (length(idx) == 0) {
      palette_hex_codes <- unique(names(palette_matches))
      result <- data.frame(
        name = palette_hex_codes,
        rgb = hex_to_rgb(palette_hex_codes),
        hex = palette_hex_codes,
        stringsAsFactors = FALSE
      )
      if (length(palette_hex_codes) == 1) {
        result <- result[1, , drop = FALSE]
        result$hex <- palette_hex_codes[1]
      } else {
        result <- result[rep(1, length(palette_hex_codes)), , drop = FALSE]
        result$hex <- palette_hex_codes
      }
      class(result) <- c("colors", "data.frame")
      return(result)
    }
  }

  if (length(idx) == 0 && length(search_values) > 0) {
    palette_like_values <- character(0)
    for (val in search_values) {
      val_char <- as.character(val)
      is_hex <- grepl("^#[0-9A-Fa-f]{6}$", val_char)
      is_number <- !is.na(suppressWarnings(as.numeric(val_char)))
      if (!is_hex && !is_number && looks_like_palette_name(val_char)) {
        palette_like_values <- c(palette_like_values, val_char)
      }
    }

    if (length(palette_like_values) > 0 &&
      length(palette_like_values) == length(search_values)) {
      available_palette_names <- names(all_palettes)
      suggestions <- character(0)
      for (not_found in palette_like_values) {
        prefix_matches <- available_palette_names[grepl(
          paste0("^", not_found), available_palette_names,
          ignore.case = TRUE
        )]
        if (length(prefix_matches) > 0) {
          suggestions <- c(
            suggestions, prefix_matches[1:min(3, length(prefix_matches))]
          )
        }
      }
      suggestions <- unique(suggestions)

      if (length(suggestions) > 0) {
        log_message(
          "No matching palettes found for: {.val {palette_like_values}}. ",
          "Did you mean: {.val {suggestions}}?",
          message_type = "error"
        )
      } else {
        log_message(
          "No matching palettes found for: {.val {palette_like_values}}. ",
          "Available palettes include: {.val {available_palette_names}}. ",
          "Use {.code show_palettes(return_palettes = TRUE)} to see all available palettes.",
          message_type = "error"
        )
      }
    } else {
      log_message(
        "No matching color{?s} found for: {.val {search_values}}",
        message_type = "error"
      )
    }
  }

  if (length(idx) > 0) {
    result <- colors_df[idx, , drop = FALSE]

    if (length(specified_palette_names) > 0) {
      if (length(palette_matches) > 0) {
        palette_hex_codes <- unique(names(palette_matches))
        result_hex_upper <- toupper(result$hex)
        palette_hex_upper <- toupper(palette_hex_codes)
        keep_indices <- which(result_hex_upper %in% palette_hex_upper)
        if (length(keep_indices) > 0) {
          result <- result[keep_indices, , drop = FALSE]
        } else {
          result <- result[integer(0), , drop = FALSE]
        }
      } else {
        result <- result[integer(0), , drop = FALSE]
      }
    }
  } else {
    result <- colors_df[integer(0), , drop = FALSE]
  }

  class(result) <- c("colors", "data.frame")
  return(result)
}

#' @title Print colors object
#'
#' @md
#' @param x A colors object (data frame with color information).
#' @param ... Additional arguments passed to print.
#'
#' @return
#' Details of the colors objec.
#'
#' @method print colors
#' @export
print.colors <- function(x, ...) {
  color_col <- if ("hex" %in% colnames(x)) {
    "hex"
  } else if ("color" %in% colnames(x)) {
    "color"
  } else {
    NULL
  }
  has_color <- cli::num_ansi_colors() > 1 && !is.null(color_col)

  display_width <- function(s) {
    if (is.na(s) || length(s) == 0) {
      return(0)
    }
    cli::ansi_nchar(s, type = "width")
  }

  if (has_color) {
    col_names <- colnames(x)

    format_cell <- function(val) {
      format(val, trim = TRUE)
    }

    pad_cell <- function(value, width) {
      paste0(
        cli::ansi_align(value, width = width, align = "left", type = "width"),
        "  "
      )
    }

    col_widths <- vapply(col_names, function(nm) {
      name_width <- display_width(nm)
      data_widths <- vapply(x[[nm]], function(val) {
        if (is.na(val)) {
          return(2)
        }
        display_width(format_cell(val))
      }, numeric(1))
      max(name_width, max(data_widths, na.rm = TRUE), na.rm = TRUE)
    }, numeric(1))

    header_parts <- vapply(seq_along(col_names), function(i) {
      nm <- col_names[i]
      width <- as.integer(col_widths[i])
      pad_cell(nm, width)
    }, character(1))
    cat(paste(header_parts, collapse = ""), "\n")

    for (i in seq_len(nrow(x))) {
      hex_val <- x[[color_col]][i]

      if (!is.na(hex_val) && nchar(hex_val) > 0) {
        row_style <- cli::make_ansi_style(hex_val)
      } else {
        row_style <- function(x) x
      }

      row_parts <- vapply(
        seq_along(col_names), function(j) {
          col_name <- col_names[j]
          val <- x[[col_name]][i]
          formatted_val <- format_cell(val)

          width <- as.integer(col_widths[j])
          pad_cell(formatted_val, width)
        }, character(1)
      )

      row_text <- paste(row_parts, collapse = "")
      styled_row <- row_style(row_text)
      cat(styled_row, "\n")
    }
  } else {
    print.data.frame(x, ...)
  }

  invisible(x)
}

#' @title Return the first part of a colors object
#'
#' @description
#' Returns the first part of a colors object, similar to [head()] for data frames.
#'
#' @md
#' @param x A colors object (data frame with color information).
#' @param n Number of rows to return. Default is `6`.
#' @param ... Additional arguments passed to [head()].
#'
#' @return
#' A colors object with the first `n` rows.
#'
#' @method head colors
#' @importFrom utils head
#'
#' @export
#' @examples
#' head(get_colors())
#'
#' head(get_colors(), n = 10)
head.colors <- function(x, n = 6L, ...) {
  if (nrow(x) == 0) {
    return(x)
  }
  result <- x[seq_len(min(n, nrow(x))), , drop = FALSE]
  class(result) <- c("colors", "data.frame")
  return(result)
}

hex_to_rgb <- function(hex_colors) {
  vapply(hex_colors, function(hex) {
    rgb_vals <- grDevices::col2rgb(hex)
    paste0(
      "(", rgb_vals[1], ", ", rgb_vals[2], ", ", rgb_vals[3], ")"
    )
  }, character(1), USE.NAMES = FALSE)
}

# Convert a color vector to uppercase hex codes, dropping invalid values
to_hex <- function(colors) {
  # Strip the alpha channel from 8-digit hex codes
  colors <- sub("^#([0-9A-Fa-f]{6})[0-9A-Fa-f]{2}$", "#\\1", colors)
  hexes <- vapply(colors, function(col) {
    tryCatch(
      {
        rgb_mat <- grDevices::col2rgb(col)
        grDevices::rgb(
          red = rgb_mat[1, ] / 255,
          green = rgb_mat[2, ] / 255,
          blue = rgb_mat[3, ] / 255
        )
      },
      error = function(e) NA_character_
    )
  }, character(1), USE.NAMES = FALSE)
  toupper(hexes[!is.na(hexes)])
}

# Extract factor level-color mappings used in a ggplot or patchwork object
extract_plot_factors <- function(p) {
  rows <- data.frame(
    factor = character(0),
    color = character(0),
    stringsAsFactors = FALSE
  )

  if (inherits(p, "patchwork")) {
    patches <- tryCatch(
      get_namespace_fun("patchwork", "get_patches")(p),
      error = function(e) NULL
    )
    sub_plots <- if (!is.null(patches) && !is.null(patches$plots)) {
      patches$plots
    } else {
      p$plots
    }
    if (is.null(sub_plots)) {
      sub_plots <- list()
    }
    for (sub_plot in sub_plots) {
      rows <- rbind(rows, extract_plot_factors(sub_plot))
    }
    return(unique(rows))
  }
  if (!inherits(p, "ggplot")) {
    return(rows)
  }

  built <- tryCatch(ggplot2::ggplot_build(p), error = function(e) NULL)
  if (is.null(built)) {
    return(rows)
  }

  # Trained discrete color/fill scales give the factor levels and their colors
  for (scale in built$plot$scales$scales) {
    aes <- scale$aesthetics
    is_color_scale <- any(aes %in% c("colour", "color", "fill")) ||
      any(grepl("^(colou?r|fill)_ggnewscale_", aes))
    if (!is_color_scale) next
    if (!tryCatch(scale$is_discrete(), error = function(e) FALSE)) next

    limits <- tryCatch(scale$get_limits(), error = function(e) NULL)
    if (is.null(limits) || length(limits) == 0) next
    colors <- tryCatch(scale$map(limits), error = function(e) NULL)
    if (is.null(colors)) next

    rows <- rbind(rows, data.frame(
      factor = as.character(limits),
      color = to_hex(colors),
      stringsAsFactors = FALSE
    ))
  }

  unique(rows)
}

collect_grob_colors <- function(g) {
  if (!inherits(g, "grob")) {
    return(character(0))
  }
  cols <- character(0)

  gp <- g$gp
  if (!is.null(gp)) {
    for (nm in c("col", "fill")) {
      vals <- gp[[nm]]
      if (!is.null(vals) && is.character(vals)) {
        vals <- vals[!is.na(vals) & vals != "transparent"]
        cols <- c(cols, vals)
      }
    }
  }

  if (!is.null(g$grobs) && is.list(g$grobs)) {
    for (child in g$grobs) {
      cols <- c(cols, collect_grob_colors(child))
    }
  }
  if (!is.null(g$children)) {
    for (child in g$children) {
      cols <- c(cols, collect_grob_colors(child))
    }
  }

  cols
}
