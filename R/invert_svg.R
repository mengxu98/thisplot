#' @title Invert the colours of an SVG file
#'
#' @description
#' Build a dark-mode variant of an SVG image by replacing every hexadecimal
#' colour with its RGB complement. Elements that do not set their own `fill`
#' would keep the SVG default black, so `default_fill` is written on the root
#' `<svg>` element, where those elements inherit it.
#'
#' @md
#' @param path Path to the input SVG file.
#' @param output Path of the output SVG. Defaults to the input name with a
#' `-dark` suffix next to it. Use `NA` to return the modified SVG as a string
#' without writing a file.
#' @param default_fill Fill written on the root `<svg>` element, so elements
#' without their own fill do not stay black. Use `NULL` to leave the root
#' element untouched.
#' @param quiet Whether to suppress the message about the written file.
#' Default is `FALSE`.
#'
#' @return The output path, invisibly, or the modified SVG as a string when
#' `output` is `NA`.
#'
#' @export
#' @examples
#' svg <- tempfile(fileext = ".svg")
#' writeLines(
#'   '<svg viewBox="0 0 10 10"><rect width="10" height="10" fill="#ffffff"/></svg>',
#'   svg
#' )
#' invert_svg(svg)
#' readLines(sub("\\.svg$", "-dark.svg", svg))
invert_svg <- function(path, output = NULL, default_fill = "#ffffff", quiet = FALSE) {
  if (!file.exists(path)) {
    cli::cli_abort("Input file {.file {path}} does not exist.")
  }

  invert_hex <- function(x) {
    vapply(
      x,
      function(one) {
        hex <- sub("^#", "", one)
        if (nchar(hex) == 3) {
          hex <- paste(rep(strsplit(hex, "")[[1]], each = 2), collapse = "")
        }
        rgb <- strtoi(substring(hex, c(1, 3, 5), c(2, 4, 6)), 16L)
        sprintf("#%02x%02x%02x", 255 - rgb[1], 255 - rgb[2], 255 - rgb[3])
      },
      character(1),
      USE.NAMES = FALSE
    )
  }

  svg <- readChar(path, file.info(path)$size, useBytes = TRUE)

  matches <- gregexpr("#[0-9a-fA-F]{6}\\b|#[0-9a-fA-F]{3}\\b", svg, perl = TRUE)
  regmatches(svg, matches) <- list(invert_hex(regmatches(svg, matches)[[1]]))

  if (!is.null(default_fill)) {
    root <- regmatches(svg, regexpr("<svg\\b[^>]*>", svg, perl = TRUE))
    if (length(root) == 1L && !grepl("fill=", root)) {
      svg <- sub(
        "<svg\\b",
        paste0('<svg fill="', default_fill, '"'),
        svg,
        perl = TRUE
      )
    }
  }

  if (length(output) == 1L && is.na(output)) {
    return(svg)
  }

  if (is.null(output)) {
    output <- if (grepl("\\.svg$", path, ignore.case = TRUE)) {
      sub("\\.svg$", "-dark.svg", path, ignore.case = TRUE)
    } else {
      paste0(path, "-dark.svg")
    }
  }

  con <- file(output, open = "wb")
  writeBin(charToRaw(svg), con)
  close(con)
  if (!quiet) {
    cli::cli_alert_success("Wrote {.file {output}}.")
  }

  invisible(output)
}
