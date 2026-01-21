# -*- coding: utf-8 -*-

#' @title Utility Functions for Data Visualization and Plotting
#'
#' @description
#' Provides utility functions for data visualization and plotting in R. Includes functions for color manipulation, plot customization, panel size control, data optimization for plots, and layout adjustments. Designed to enhance workflows with ggplot2, patchwork, and ComplexHeatmap.
#'
#' @author Meng Xu (Maintainer), \email{mengxu98@qq.com}
#'
#' @source \url{https://mengxu98.github.io/thisplot/}
#'
#' @md
#' @docType package
#' @name thisplot-package
"_PACKAGE"

#' @title The logo of thisplot
#'
#' @description
#' The thisplot logo, using ASCII or Unicode characters
#' Use [cli::ansi_strip] to get rid of the colors.
#'
#' @md
#' @param unicode Unicode symbols on UTF-8 platforms.
#' Default is [cli::is_utf8_output].
#'
#' @return
#' A character vector with class `thisplot_logo`.
#'
#' @references
#' \url{https://github.com/tidyverse/tidyverse/blob/main/R/logo.R}
#'
#' @export
#' @examples
#' thisplot_logo()
thisplot_logo <- function(unicode = cli::is_utf8_output()) {
  logo <- c(
    "          0          1        2             3     4
             __  __    _              __       __
            / /_/ /_  (_)_____ ____  / /____  / /_
           / __/ __ ./ // ___// __ ./ // __ ./ __/
          / /_/ / / / /(__  )/ /_/ / // /_/ / /_
          .__/_/ /_/_//____// .___/_/ .____/.__/
                           /_/
      5               6      7        8          9"
  )

  hexa <- c("*", ".", "o", "*", ".", "o", "*", ".", "o", "*")
  if (unicode) {
    hexa <- c("*" = "\u2b22", "o" = "\u2b21", "." = ".")[hexa]
  }

  cols <- c(
    "red", "yellow", "green", "magenta", "cyan",
    "yellow", "green", "white", "magenta", "cyan"
  )

  col_hexa <- mapply(
    function(x, y) cli::make_ansi_style(y)(x),
    hexa, cols,
    SIMPLIFY = FALSE
  )

  for (i in 0:9) {
    pat <- paste0("\\b", i, "\\b")
    logo <- sub(pat, col_hexa[[i + 1]], logo)
  }

  structure(
    cli::col_blue(logo),
    class = "thisplot_logo"
  )
}

#' @title Print logo
#'
#' @param x Input information.
#' @param ... Other parameters.
#'
#' @return Print the ASCII logo
#'
#' @method print thisplot_logo
#'
#' @export
#'
print.thisplot_logo <- function(x, ...) {
  cat(x, ..., sep = "\n")
  invisible(x)
}

.onAttach <- function(libname, pkgname) {
  verbose <- thisutils::get_verbose()
  if (isTRUE(verbose)) {
    version <- utils::packageVersion(pkgname)
    date <- utils::packageDate(pkgname)
    url <- utils::packageDescription(
      pkgname, fields = "URL"
    )

    msg <- paste0(
      cli::col_grey(strrep("-", 60)),
      "\n",
      cli::col_blue("Version: ", version, " (", date, " update)"),
      "\n",
      cli::col_blue("Website: ", cli::style_italic(url)),
      "\n\n",
      cli::col_grey("This message can be suppressed by:"),
      "\n",
      cli::col_grey("  suppressPackageStartupMessages(library(thisplot))"),
      "\n",
      cli::col_grey("  or options(log_message.verbose = FALSE)"),
      "\n",
      cli::col_grey(strrep("-", 60))
    )

    packageStartupMessage(thisplot_logo())
    packageStartupMessage(msg)
  }
}
