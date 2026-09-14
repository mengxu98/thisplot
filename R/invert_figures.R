#' @title Invert the colours of a set of figures
#'
#' @description
#' Build dark-mode variants of several figures at once, dispatching on the file
#' extension: SVG files are inverted with `invert_svg()` and PNG files with
#' `invert_png()`. Every output is written next to its input, or into
#' `output_dir`, with a `-dark` suffix added to the name. Files that already
#' carry the suffix are skipped, so running the function twice does not
#' complement the dark variants again.
#'
#' @details
#' Other formats are not supported: there is no way to rewrite the colours of a
#' PDF from R without rasterising it first. Re-render the figure as SVG or PNG
#' where possible, for instance with `ggsave()`, or rasterise the PDF before
#' inverting it. Unsupported files are only reported when they are passed as a
#' file; a directory is scanned for the supported extensions.
#'
#' @md
#' @param path Path(s) to figure files, or to directories holding them.
#' @param output_dir Directory the dark variants are written to. Default is
#' next to each input file.
#' @param suffix Suffix added to the file name of every dark variant. Default
#' is `-dark`.
#' @param recursive Whether a directory is scanned recursively. Default is
#' `FALSE`.
#' @param quiet Whether to suppress the per-file messages. Default is `FALSE`.
#'
#' @return The paths of the written files, invisibly.
#'
#' @export
invert_figures <- function(
  path,
  output_dir = NULL,
  suffix = "-dark",
  recursive = FALSE,
  quiet = FALSE
) {
  files <- figure_files(path, suffix = suffix, recursive = recursive)
  if (length(files) == 0L) {
    log_message(
      "No figure to invert was found in {.file {path}}.",
      message_type = "warning"
    )
    return(invisible(character(0)))
  }

  if (!is.null(output_dir) && !dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  written <- character(0)
  skipped <- character(0)
  failed <- character(0)
  for (file in files) {
    extension <- tolower(sub("^.*\\.", "", file))
    dark <- file.path(
      if (is.null(output_dir)) dirname(file) else output_dir,
      paste0(sub("\\.[^.]+$", "", basename(file)), suffix, ".", extension)
    )
    result <- tryCatch(
      switch(extension,
        svg = invert_svg(file, output = dark, quiet = TRUE),
        png = invert_png(file, output = dark, quiet = TRUE),
        NULL
      ),
      error = function(e) e
    )
    if (is.null(result)) {
      skipped <- c(skipped, file)
    } else if (inherits(result, "error")) {
      failed <- c(failed, paste0(file, ": ", conditionMessage(result)))
    } else {
      written <- c(written, result)
      if (!quiet) {
        log_message(
          "Wrote {.file {result}}.",
          message_type = "success"
        )
      }
    }
  }

  if (length(skipped) > 0L) {
    log_message(
      "{.file {skipped}} cannot be inverted; only `.svg` and `.png` are supported. Re-render the figure as SVG or PNG where possible, for instance with {.fn ggsave}, or rasterise the PDF first.",
      message_type = "warning"
    )
  }
  for (problem in failed) {
    log_message("{problem}", message_type = "warning")
  }
  if (length(written) == 0L) {
    log_message("No figure was inverted.", message_type = "error")
  }

  invisible(written)
}

figure_files <- function(path, suffix = "-dark", recursive = FALSE) {
  files <- character(0)
  for (one in path) {
    if (dir.exists(one)) {
      files <- c(
        files,
        list.files(
          one,
          pattern = "\\.(svg|png)$",
          ignore.case = TRUE,
          recursive = recursive,
          full.names = TRUE
        )
      )
    } else if (file.exists(one)) {
      files <- c(files, one)
    } else {
      log_message(
        "Input file {.file {one}} does not exist.",
        message_type = "error"
      )
    }
  }

  files <- unique(files)
  stem <- sub("\\.[^.]+$", "", basename(files))
  files[!endsWith(stem, suffix)]
}
