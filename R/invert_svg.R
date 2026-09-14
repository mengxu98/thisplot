#' @title Invert the colours of an SVG file
#'
#' @description
#' Build a dark-mode variant of an SVG image by replacing every colour with its
#' RGB complement. Both the hexadecimal notation used by svglite and the
#' `rgb()` notation written by cairo-based devices such as `grDevices::svg()`
#' are understood. Elements that do not set their own `fill` would keep the SVG
#' default black, so `default_fill` is written on the root `<svg>` element,
#' where those elements inherit it.
#'
#' @md
#' @param path Path to the input SVG file.
#' @param output Path of the output SVG. Defaults to the input name with a
#' `-dark` suffix next to it. Use `NA` to return the modified SVG as a string
#' without writing a file.
#' @param default_fill Fill written on the root `<svg>` element, so elements
#' without their own fill do not stay black. Use `NULL` to leave the root
#' element untouched.
#' @param invert_raster Whether to complement the colours of embedded raster
#' images as well. Default is `TRUE`. Requires the `png` package.
#' @param quiet Whether to suppress the message about the written file.
#' Default is `FALSE`.
#'
#' @return The output path, invisibly, or the modified SVG as a string when
#' `output` is `NA`.
#'
#' @export
invert_svg <- function(
  path,
  output = NULL,
  default_fill = "#ffffff",
  invert_raster = TRUE,
  quiet = FALSE
) {
  if (!file.exists(path)) {
    log_message(
      "Input file {.file {path}} does not exist.",
      message_type = "error"
    )
  }

  svg <- readChar(path, file.info(path)$size, useBytes = TRUE)
  inverted <- invert_svg_colour(svg)

  if (isTRUE(invert_raster)) {
    inverted <- invert_svg_raster(inverted)
  }

  if (identical(svg, inverted)) {
    log_message(
      "No colour or raster was found in {.file {path}}; the output is unchanged. Colours written as names, for instance {.val {fill=\"black\"}}, are not inverted.",
      message_type = "warning"
    )
  }

  if (!is.null(default_fill)) {
    root <- regmatches(inverted, regexpr("<svg\\b[^>]*>", inverted, perl = TRUE))
    if (length(root) == 1L && !grepl("fill=", root)) {
      inverted <- sub(
        "<svg\\b",
        paste0('<svg fill="', default_fill, '"'),
        inverted,
        perl = TRUE
      )
    }
  }

  if (length(output) == 1L && is.na(output)) {
    return(inverted)
  }

  if (is.null(output)) {
    output <- if (grepl("\\.svg$", path, ignore.case = TRUE)) {
      sub("\\.svg$", "-dark.svg", path, ignore.case = TRUE)
    } else {
      paste0(path, "-dark.svg")
    }
  }

  con <- file(output, open = "wb")
  writeBin(charToRaw(inverted), con)
  close(con)
  if (!quiet) {
    log_message(
      "Wrote {.file {output}}.",
      message_type = "success"
    )
  }

  invisible(output)
}

invert_svg_colour <- function(svg) {
  pattern <- paste0(
    "#[0-9a-fA-F]{6}\\b|#[0-9a-fA-F]{3}\\b|",
    "rgba?\\(\\s*[0-9.]+%?\\s*,\\s*[0-9.]+%?\\s*,\\s*[0-9.]+%?",
    "(?:\\s*,\\s*[0-9.]+%?)?\\s*\\)"
  )
  matches <- gregexpr(pattern, svg, perl = TRUE)
  regmatches(svg, matches) <- list(
    vapply(
      regmatches(svg, matches)[[1]],
      function(one) {
        if (substring(one, 1L, 1L) == "#") invert_hex(one) else invert_rgb(one)
      },
      character(1),
      USE.NAMES = FALSE
    )
  )
  svg
}

invert_hex <- function(one) {
  hex <- sub("^#", "", one)
  if (nchar(hex) == 3L) {
    hex <- paste(rep(strsplit(hex, "")[[1]], each = 2), collapse = "")
  }
  rgb <- strtoi(substring(hex, c(1, 3, 5), c(2, 4, 6)), 16L)
  sprintf("#%02x%02x%02x", 255 - rgb[1], 255 - rgb[2], 255 - rgb[3])
}

invert_rgb <- function(one) {
  components <- trimws(strsplit(
    sub("\\)$", "", sub("^rgba?\\(", "", one)),
    ",",
    fixed = TRUE
  )[[1]])
  colours <- vapply(components[1:3], invert_rgb_component, character(1))
  if (length(components) > 3L) {
    colours <- c(colours, components[4L])
  }
  suffix <- if (grepl("^rgba", one)) "rgba" else "rgb"
  paste0(suffix, "(", paste(colours, collapse = ", "), ")")
}

invert_rgb_component <- function(one) {
  percent <- grepl("%$", one)
  value <- sub("%$", "", one)
  digits <- nchar(sub("^[^.]*\\.?", "", value))
  inverted <- formatC(
    if (percent) 100 - as.numeric(value) else 255 - as.numeric(value),
    digits = digits,
    format = "f"
  )
  if (percent) paste0(inverted, "%") else inverted
}

b64_codes <- utf8ToInt(paste(c(LETTERS, letters, 0:9, "+", "/"), collapse = ""))

invert_svg_raster <- function(svg) {
  mimes <- regmatches(svg, gregexpr("data:image/[^;]+;base64,", svg))[[1]]
  mimes <- sub("^data:image/", "", sub(";base64,$", "", mimes))
  if (any(tolower(mimes) != "png")) {
    log_message(
      "Embedded {.val {unique(mimes[tolower(mimes) != 'png'])}} raster is left untouched; only PNG payloads can be inverted.",
      message_type = "warning"
    )
  }

  matches <- gregexpr(
    "(?i)(?<=data:image/png;base64,)[A-Za-z0-9+/=\\s]+",
    svg,
    perl = TRUE
  )
  payloads <- regmatches(svg, matches)[[1]]
  if (length(payloads) == 0L) {
    return(svg)
  }

  unique_payloads <- unique(payloads)
  inverted <- vapply(
    unique_payloads,
    invert_png_payload,
    character(1),
    USE.NAMES = FALSE
  )
  regmatches(svg, matches) <- list(inverted[match(payloads, unique_payloads)])
  svg
}

invert_png_payload <- function(payload) {
  if (!requireNamespace("png", quietly = TRUE)) {
    log_message(
      "Package {.pkg png} is required to invert the raster images of an SVG.",
      message_type = "warning"
    )
    return(payload)
  }

  image <- png::readPNG(base64_decode(payload))
  base64_encode(png::writePNG(invert_pixels(image)))
}

base64_decode <- function(x) {
  payload <- gsub("[^A-Za-z0-9+/]", "", x)
  values <- match(utf8ToInt(payload), b64_codes) - 1L
  if (anyNA(values)) {
    log_message(
      "Embedded image payload is not valid base64.",
      message_type = "error"
    )
  }
  remainder <- length(values) %% 4L
  if (remainder == 1L) {
    log_message(
      "Embedded image payload is not valid base64.",
      message_type = "error"
    )
  }
  if (remainder > 0L) {
    values <- c(values, rep(0L, 4L - remainder))
  }

  values <- matrix(values, nrow = 4L)
  bytes <- c(rbind(
    values[1L, ] * 4L + values[2L, ] %/% 16L,
    (values[2L, ] %% 16L) * 16L + values[3L, ] %/% 4L,
    (values[3L, ] %% 4L) * 64L + values[4L, ]
  ))
  bytes <- bytes[seq_len(length(bytes) - c(0L, 3L, 2L, 1L)[remainder + 1L])]
  as.raw(bytes)
}

base64_encode <- function(x) {
  bytes <- as.integer(x)
  pad <- (3L - length(bytes) %% 3L) %% 3L
  bytes <- matrix(c(bytes, integer(pad)), nrow = 3L)
  values <- rbind(
    bytes[1L, ] %/% 4L,
    (bytes[1L, ] %% 4L) * 16L + bytes[2L, ] %/% 16L,
    (bytes[2L, ] %% 16L) * 4L + bytes[3L, ] %/% 64L,
    bytes[3L, ] %% 64L
  )

  encoded <- intToUtf8(b64_codes[as.vector(values) + 1L])
  if (pad > 0L) {
    encoded <- paste0(substr(encoded, 1L, nchar(encoded) - pad), strrep("=", pad))
  }
  encoded
}
