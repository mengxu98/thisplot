#' @title Chinese traditional colors system
#'
#' @description
#' A color system based on Chinese traditional colors with 1058 representative colors.
#' This system provides functions to access colors by name,
#' create color palettes, and generate segmented colormaps.
#'
#' @md
#' @return
#' A `ChineseColors` object.
#' Detailed information can be found in [print.ChineseColors()].
#'
#' @importFrom grDevices rgb colorRampPalette col2rgb rgb2hsv
#' @export
#'
#' @seealso
#' [chinese_colors] for the dataset of Chinese traditional colors.
#' [get_chinese_palettes] for getting Chinese color palettes.
#' [visual_colors] for visualizing any color vector.
#'
#' @examples
#' cc <- ChineseColors()
#' cc
#'
#' # Get a color by pinyin name
#' cc$get_color("pinlan")
#'
#' # Or by Chinese name
#' cc$get_color("品蓝")
#'
#' # By number
#' cc$get_color(44)
#'
#' # By hex code
#' cc$get_color("#2B73AF")
#'
#' # Multiple colors
#' cc$get_color("pinlan", "piao")
#'
#' cc$get_color(91:100)
#'
#' # Chinese names
#' widget_ch <- cc$visual_colors(
#'   title = "中国传统颜色",
#'   name_type = "chinese"
#' )
#' htmltools::browsable(widget_ch)
#'
#' # pinyin as names
#' widget <- cc$visual_colors(
#'   loc_range = c(1, 90),
#'   title = "Chinese Traditional Colors",
#'   name_type = "pinyin"
#' )
#' htmltools::browsable(widget)
#'
#' # rgb as names
#' widget_rgb <- cc$visual_colors(
#'   loc_range = c(1, 90),
#'   title = "Colors with RGB values",
#'   name_type = "rgb"
#' )
#' htmltools::browsable(widget_rgb)
#'
#' # hex as names
#' widget_hex <- cc$visual_colors(
#'   loc_range = c(1, 90),
#'   title = "Colors with hex codes",
#'   name_type = "hex"
#' )
#' htmltools::browsable(widget_hex)
ChineseColors <- function() {
  colors_df <- thisplot::chinese_colors
  category_ranges <- list()
  unique_categories <- unique(colors_df$category)
  for (cat in unique_categories) {
    cat_indices <- which(colors_df$category == cat)
    if (length(cat_indices) > 0) {
      category_ranges[[cat]] <- cat_indices
    }
  }

  color_ranges <- list()
  for (cat in names(category_ranges)) {
    cat_indices <- category_ranges[[cat]]
    n_cat <- length(cat_indices)

    if (n_cat <= 20) {
      color_ranges[[paste0(cat, "1")]] <- cat_indices
    } else if (n_cat <= 50) {
      mid <- ceiling(n_cat / 2)
      color_ranges[[paste0(cat, "1")]] <- cat_indices[1:mid]
      color_ranges[[paste0(cat, "2")]] <- cat_indices[(mid + 1):n_cat]
    } else if (n_cat <= 100) {
      third1 <- ceiling(n_cat / 3)
      third2 <- ceiling(2 * n_cat / 3)
      color_ranges[[paste0(cat, "1")]] <- cat_indices[1:third1]
      color_ranges[[paste0(cat, "2")]] <- cat_indices[(third1 + 1):third2]
      color_ranges[[paste0(cat, "3")]] <- cat_indices[(third2 + 1):n_cat]
    } else {
      quarter1 <- ceiling(n_cat / 4)
      quarter2 <- ceiling(2 * n_cat / 4)
      quarter3 <- ceiling(3 * n_cat / 4)
      color_ranges[[paste0(cat, "1")]] <- cat_indices[1:quarter1]
      color_ranges[[paste0(cat, "2")]] <- cat_indices[(quarter1 + 1):quarter2]
      color_ranges[[paste0(cat, "3")]] <- cat_indices[(quarter2 + 1):quarter3]
      color_ranges[[paste0(cat, "4")]] <- cat_indices[(quarter3 + 1):n_cat]
    }
  }

  sub_palettes <- lapply(
    color_ranges, function(range) {
      valid_range <- range[range >= 1 & range <= nrow(colors_df)]
      if (length(valid_range) == 0) {
        return(character(0))
      }
      indices <- valid_range[valid_range <= nrow(colors_df)]
      colors_df$hex[indices]
    }
  )

  main_palettes <- list()
  for (cat in unique_categories) {
    cat_sub_pals <- sub_palettes[grepl(paste0("^", cat), names(sub_palettes))]
    if (length(cat_sub_pals) > 0) {
      main_palettes[[cat]] <- unlist(cat_sub_pals, use.names = FALSE)
    }
  }

  get_color <- function(...) {
    args <- list(...)

    if (length(args) == 0) {
      result <- colors_df
      class(result) <- c("ChineseColorInfo", "data.frame")
      return(result)
    }

    search_values <- unlist(args, use.names = FALSE)

    available_columns <- colnames(colors_df)

    all_matches <- integer(0)

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

    if (length(idx) == 0) {
      log_message(
        "No matching colors found for {.val {search_values}} in any column",
        message_type = "warning"
      )
      return(NULL)
    }

    if (length(search_values) > 1) {
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

    result <- colors_df[idx, , drop = FALSE]
    class(result) <- c("ChineseColorInfo", "data.frame")
    return(result)
  }

  visual_colors <- function(
    loc_range = c(1, nrow(colors_df)),
    num_per_row = 30,
    title = NULL,
    name_type = c("pinyin", "chinese", "rgb", "hex")
  ) {
    name_type <- match.arg(name_type)

    start_idx <- if (loc_range[1] == 0) 1 else max(1, loc_range[1])
    end_idx <- min(nrow(colors_df), loc_range[2])
    if (loc_range[2] == 0) {
      end_idx <- nrow(colors_df)
    }
    indices <- start_idx:end_idx

    colors_subset <- colors_df[indices, ]
    color_col <- colors_subset$hex
    rgb_col <- colors_subset$rgb
    if (name_type == "chinese") {
      display_name <- colors_subset$name_ch
      rgb_param <- NULL
      hex_param <- NULL
    } else if (name_type == "pinyin") {
      display_name <- colors_subset$name
      rgb_param <- NULL
      hex_param <- NULL
    } else if (name_type == "rgb") {
      display_name <- NULL
      rgb_param <- rgb_col
      hex_param <- NULL
    } else if (name_type == "hex") {
      display_name <- NULL
      rgb_param <- NULL
      hex_param <- TRUE
    } else {
      display_name <- colors_subset$name
      rgb_param <- NULL
      hex_param <- NULL
    }

    return(
      thisplot::visual_colors(
        colors = color_col,
        names = display_name,
        num_per_row = num_per_row,
        title = title,
        rgb = rgb_param,
        hex = hex_param
      )
    )
  }

  cc_obj <- list(
    colors = colors_df
  )

  for (cat in names(main_palettes)) {
    cc_obj[[cat]] <- main_palettes[[cat]]
  }

  for (sub_name in names(sub_palettes)) {
    cc_obj[[sub_name]] <- sub_palettes[[sub_name]]
  }

  cc_obj$get_color <- get_color
  cc_obj$visual_colors <- visual_colors

  class(cc_obj) <- "ChineseColors"
  return(cc_obj)
}

#' @title Print ChineseColors object
#'
#' @md
#' @param x A ChineseColors object.
#' @param ... Additional arguments (not used).
#'
#' @return
#' Details of the ChineseColors object.
#'
#' @method print ChineseColors
#' @export
print.ChineseColors <- function(x, ...) {
  cli::cli_h3("Chinese Traditional Colors System")
  cli::cli_h3("Total {nrow(x$colors)} colors")
  cli::cli_ul(
    c(
      "blue: {length(x$blue)} colors",
      "cyan: {length(x$cyan)} colors",
      "gray_brown: {length(x$gray_brown)} colors",
      "green: {length(x$green)} colors",
      "orange: {length(x$orange)} colors",
      "purple: {length(x$purple)} colors",
      "red: {length(x$red)} colors",
      "yellow: {length(x$yellow)} colors"
    )
  )
  cli::cli_h3("Methods:")
  cli::cli_ul(
    c(
      "get_color(...): Get color information",
      "visual_colors(loc_range, num_per_row, title, name_type)"
    )
  )
}

#' @title Print ChineseColorInfo object
#'
#' @md
#' @param x A ChineseColorInfo object.
#' @param ... Additional arguments passed to print.
#'
#' @return
#' Details of the ChineseColorInfo object.
#'
#' @method print ChineseColorInfo
#' @export
print.ChineseColorInfo <- function(x, ...) {
  if (nrow(x) == 0) {
    log_message("Empty color information", message_type = "warning")
    return(invisible(x))
  }

  has_color <- cli::num_ansi_colors() > 1 && "hex" %in% colnames(x)

  display_width <- function(s) {
    if (is.na(s) || length(s) == 0) {
      return(0)
    }
    plain_s <- cli::ansi_strip(s)
    nchar(plain_s, type = "width")
  }

  if (has_color) {
    col_names <- colnames(x)

    col_widths <- vapply(col_names, function(nm) {
      name_width <- display_width(nm)
      data_widths <- vapply(x[[nm]], function(val) {
        if (is.na(val)) {
          return(2)
        }
        display_width(format(val))
      }, numeric(1))
      max(name_width, max(data_widths, na.rm = TRUE), na.rm = TRUE)
    }, numeric(1))

    header_parts <- vapply(seq_along(col_names), function(i) {
      nm <- col_names[i]
      width <- as.integer(col_widths[i])
      current_width <- display_width(nm)
      padding <- max(0, width - current_width)
      paste0(nm, strrep(" ", padding + 2))
    }, character(1))
    cat(paste(header_parts, collapse = ""), "\n")

    for (i in seq_len(nrow(x))) {
      hex_val <- x$hex[i]

      if (!is.na(hex_val) && nchar(hex_val) > 0) {
        row_style <- cli::make_ansi_style(hex_val)
      } else {
        row_style <- function(x) x
      }

      row_parts <- vapply(
        seq_along(col_names), function(j) {
          col_name <- col_names[j]
          val <- x[[col_name]][i]
          formatted_val <- format(val)

          width <- as.integer(col_widths[j])
          current_width <- display_width(formatted_val)
          padding <- max(0, width - current_width)

          cell_content <- paste0(formatted_val, strrep(" ", padding + 2))
          return(cell_content)
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
