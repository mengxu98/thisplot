#' @title Invert the colours of a PNG file
#'
#' @description
#' Build a dark-mode variant of a PNG image by replacing every colour channel
#' with its RGB complement. The alpha channel is kept as it is, so a
#' transparent background stays transparent.
#'
#' @md
#' @param path Path to the input PNG file.
#' @param output Path of the output PNG. Defaults to the input name with a
#' `-dark` suffix next to it.
#' @param quiet Whether to suppress the message about the written file.
#' Default is `FALSE`.
#'
#' @return The output path, invisibly.
#'
#' @export
invert_png <- function(path, output = NULL, quiet = FALSE) {
  if (!file.exists(path)) {
    log_message(
      "Input file {.file {path}} does not exist.",
      message_type = "error"
    )
  }
  if (!requireNamespace("png", quietly = TRUE)) {
    log_message(
      "Package {.pkg png} is required to invert a PNG file.",
      message_type = "error"
    )
  }

  if (is.null(output)) {
    output <- if (grepl("\\.png$", path, ignore.case = TRUE)) {
      sub("\\.png$", "-dark.png", path, ignore.case = TRUE)
    } else {
      paste0(path, "-dark.png")
    }
  }

  png::writePNG(invert_pixels(png::readPNG(path)), target = output)
  if (!quiet) {
    log_message(
      "Wrote {.file {output}}.",
      message_type = "success"
    )
  }

  invisible(output)
}

invert_pixels <- function(image) {
  if (length(dim(image)) < 3L) {
    return(1 - image)
  }
  channels <- seq_len(if (dim(image)[3L] > 2L) 3L else 1L)
  image[, , channels] <- 1 - image[, , channels]
  image
}
