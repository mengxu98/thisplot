#' @title Print a data frame as a color-highlighted aligned table
#'
#' @description
#' Prints a data frame as an aligned console table with ANSI colors. By default
#' each column receives one distinct color from `palette`; set `by = "row"`
#' to use one color per row. Custom `color_by` specifications can still color
#' individual values. Column widths are computed from visible ANSI text, so
#' escape sequences and Chinese text do not break alignment in the console.
#' Colors are emitted only when
#' the output supports ANSI colors (a terminal or RStudio, or when
#' `options(thisplot.colors = TRUE)` is set); captured output stays clean.
#'
#' @param x A data frame.
#' @param color_by A character vector of column names to color, or a named list
#' of color sources. If `NULL` (default), colors are assigned according to
#' `by`.
#' @param colors Optional color source used for all `color_by` columns unless
#' overridden by a named list in `color_by`: a named hex vector whose names
#' match the values of the colored columns, a plain hex vector recycled per
#' row, or `NA` to fall back to `palette`.
#' @param palette Palette name passed to `palette_colors()` for default row
#' or column colors, or columns without explicit colors.
#' @param by Whether default palette colors are assigned by `"col"` (default)
#' or `"row"`.
#' @param ... Additional arguments passed to `format()`.
#'
#' @return `x` invisibly.
#' @export
#'
#' @examples
#' t1 <- data.frame(
#'   name = c("a", "b", "c"),
#'   col1 = c(1L, 2L, 3L),
#'   col2 = c(4L, 5L, 6L)
#' )
#'
#' print_colored_table(t1)
print_colored_table <- function(
  x,
  color_by = NULL,
  colors = NULL,
  palette = "Chinese",
  by = "col",
  ...
) {
  if (!is.data.frame(x)) {
    log_message("{.arg x} must be a data frame", message_type = "error")
  }
  if (nrow(x) == 0L || ncol(x) == 0L) {
    print.data.frame(x, ...)
    return(invisible(x))
  }
  by <- match.arg(by, c("row", "col"))
  if (is.null(color_by)) {
    columns <- colnames(x)
    color_values <- if (by == "row") {
      as.character(seq_len(nrow(x)))
    } else {
      columns
    }
    assigned <- if (is.null(palette)) {
      rep(NA_character_, length(color_values))
    } else {
      unname(palette_colors(
        color_values,
        palette = palette,
        type = "discrete"
      ))
    }
    per_column <- if (by == "row") {
      rep(list(assigned), length(columns))
    } else {
      lapply(assigned, rep, nrow(x))
    }
    color_specs <- Map(
      function(column, per_row) {
        list(column = column, per_row = per_row)
      },
      columns,
      per_column
    )
  } else {
    if (is.character(color_by)) {
      color_by <- stats::setNames(rep(list(colors), length(color_by)), color_by)
    }
    if (!is.list(color_by)) {
      log_message(
        "{.arg color_by} must be a character vector or a named list",
        message_type = "error"
      )
    }
    color_specs <- lapply(names(color_by), function(column) {
      values <- as.character(x[[column]])
      source <- color_by[[column]]
      if (is.null(source) || length(source) == 0L) {
        source <- NA_character_
      }
      if (length(source) == 1L && is.na(source)) {
        if (is.null(palette)) {
          per_row <- rep(NA_character_, length(values))
        } else {
          unique_values <- unique(values[!is.na(values) & nzchar(values)])
          if (length(unique_values) == 0L) {
            per_row <- rep(NA_character_, length(values))
          } else {
            assigned <- palette_colors(unique_values, palette = palette)
            per_row <- unname(assigned[values])
          }
        }
      } else if (is.null(names(source))) {
        if (length(source) == length(values)) {
          per_row <- source
        } else {
          per_row <- rep(source[1], length(values))
        }
      } else {
        per_row <- rep(NA_character_, length(values))
        matched <- match(values, names(source))
        hit <- !is.na(matched)
        per_row[hit] <- unname(source[matched[hit]])
      }
      list(column = column, per_row = per_row)
    })
  }
  use_color <- (
    isTRUE(getOption("thisplot.colors", FALSE)) ||
      cli::num_ansi_colors() > 1L
  ) && length(color_specs) > 0L

  plain <- vapply(
    colnames(x),
    function(col) {
      values <- x[[col]]
      justify <- if (is.numeric(values) || is.integer(values)) {
        "right"
      } else {
        "left"
      }
      format(values, trim = TRUE, justify = justify, ...)
    },
    character(nrow(x))
  )
  if (nrow(x) == 1L) {
    plain <- matrix(plain, nrow = 1L)
    colnames(plain) <- colnames(x)
  }
  widths <- vapply(
    seq_len(ncol(x)),
    function(j) {
      max(vapply(
        c(colnames(x)[j], plain[, j]),
        function(value) {
          if (is.na(value)) {
            return(0L)
          }
          as.integer(cli::ansi_nchar(value, type = "width"))
        },
        integer(1)
      ))
    },
    integer(1)
  )

  pad <- function(s, w) {
    s <- as.character(s)
    mapply(
      function(value, width) {
        cli::ansi_align(value, width = width, align = "left", type = "width")
      },
      s,
      w,
      USE.NAMES = FALSE
    )
  }

  header <- colnames(x)
  body <- plain
  if (use_color) {
    for (spec in color_specs) {
      j <- match(spec$column, colnames(x))
      if (is.na(j)) {
        next
      }
      row_hex <- spec$per_row
      if (length(row_hex) == 1L && is.na(row_hex)) {
        row_hex <- rep(NA_character_, nrow(x))
      }
      styled <- vapply(
        seq_len(nrow(x)),
        function(i) {
          value <- body[i, j]
          hex <- row_hex[i]
          if (is.na(hex) || !nzchar(hex)) {
            return(pad(value, widths[j]))
          }
          cli::make_ansi_style(hex)(pad(value, widths[j]))
        },
        character(1)
      )
      body[, j] <- styled
    }
  }

  header_line <- paste(pad(header, widths), collapse = "  ")
  lines <- header_line
  if (nrow(body) > 0L) {
    for (i in seq_len(nrow(body))) {
      lines <- c(lines, paste(pad(body[i, ], widths), collapse = "  "))
    }
  }
  writeLines(lines)
  invisible(x)
}
