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
#' @param palettes Optional. A named list of palettes to search in.
#' If `NULL` (default), searches in all available palettes.
#'
#' @return A data frame with class `colors` containing matching color information.
#' The result is automatically printed using [print.colors()].
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
#' get_colors("pinlan")
#' get_colors(44)
#' get_colors("#2B73AF")
#'
#' get_colors("cyan")
get_colors <- function(..., palettes = NULL) {
  args <- list(...)

  colors_df <- thisplot::chinese_colors
  available_columns <- colnames(colors_df)

  if (length(args) == 0) {
    result <- colors_df
    class(result) <- c("colors", "data.frame")
    return(result)
  }

  search_values <- unlist(args, use.names = FALSE)
  all_matches <- integer(0)
  found_hex_codes <- character(0)

  if (is.null(palettes)) {
    all_palettes <- c(
      thisplot::palette_list,
      get_chinese_palettes()
    )
  } else {
    all_palettes <- palettes
  }

  palette_names_found <- character(0)
  palette_names_not_found <- character(0)
  palette_colors_found <- character(0)
  remaining_search_values <- character(0)

  for (val in search_values) {
    val_char <- as.character(val)
    if (val_char %in% names(all_palettes)) {
      palette_names_found <- c(palette_names_found, val_char)
      palette_colors_found <- c(palette_colors_found, all_palettes[[val_char]])
    } else {
      is_hex <- grepl("^#[0-9A-Fa-f]{6}$", val_char)
      is_number <- !is.na(suppressWarnings(as.numeric(val_char)))
      if (!is_hex && !is_number) {
        palette_names_not_found <- c(palette_names_not_found, val_char)
      }
      remaining_search_values <- c(remaining_search_values, val_char)
    }
  }

  if (length(palette_names_found) > 0) {
    palette_colors_found <- unique(palette_colors_found)
    if (length(palette_colors_found) > 0) {
      palette_hex_upper <- toupper(palette_colors_found)
      colors_hex_upper <- toupper(colors_df$hex)
      hex_matches <- which(colors_hex_upper %in% palette_hex_upper)
      if (length(hex_matches) > 0) {
        result <- colors_df[hex_matches, , drop = FALSE]
      } else {
        result <- data.frame(
          num = NA_integer_,
          name = NA_character_,
          name_ch = NA_character_,
          rgb = NA_character_,
          hex = palette_colors_found,
          category = NA_character_,
          category_ch = NA_character_,
          stringsAsFactors = FALSE
        )
      }
      class(result) <- c("colors", "data.frame")
      cli::cli_h3("Found palette{?s}: {.val {palette_names_found}}")
      return(result)
    }
  }

  if (length(palette_names_not_found) > 0 &&
    length(palette_names_found) == 0 &&
    length(remaining_search_values) == length(palette_names_not_found)) {
    available_palette_names <- names(all_palettes)
    suggestions <- character(0)
    for (not_found in palette_names_not_found) {
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
        "No matching palettes found for: {.val {palette_names_not_found}}. ",
        "Did you mean: {.val {suggestions}}?",
        message_type = "error"
      )
    } else {
      log_message(
        "No matching palettes found for: {.val {palette_names_not_found}}. ",
        "Available palettes include: {.val {available_palette_names}}. ",
        "Use {.code show_palettes(return_palettes = TRUE)} to see all available palettes.",
        message_type = "error"
      )
    }
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
  }

  if (length(idx) == 0 && length(search_values) > 0) {
    log_message(
      "No matching color{?s} found for: {.val {search_values}}",
      message_type = "error"
    )
  }

  if (length(idx) > 0) {
    result <- colors_df[idx, , drop = FALSE]
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
