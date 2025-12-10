#' @title Convert color names to hexadecimal format
#'
#' @description
#' Convert color names to hexadecimal RGB color codes.
#'
#' @md
#' @param cname A character vector of color names.
#'
#' @return A character vector of hexadecimal color codes.
#'
#' @export
col2hex <- function(cname) {
  col_mat <- grDevices::col2rgb(cname)
  grDevices::rgb(
    red = col_mat[1, ] / 255,
    green = col_mat[2, ] / 255,
    blue = col_mat[3, ] / 255
  )
}

#' @title Convert a color with specified alpha level
#'
#' @md
#' @param colors Color vectors.
#' @param alpha Alpha level in `[0,1]`.
#'
#' @return A character vector of hexadecimal color codes with the specified alpha level.
#'
#' @export
#'
#' @examples
#' colors <- c("red", "blue", "green")
#' adjcolors(colors, 0.5)
#' ggplot2::alpha(colors, 0.5)
#'
#' show_palettes(
#'   list(
#'     "raw" = colors,
#'     "adjcolors" = adjcolors(colors, 0.5),
#'     "ggplot2::alpha" = ggplot2::alpha(colors, 0.5)
#'   )
#' )
adjcolors <- function(colors, alpha) {
  color_df <- as.data.frame(
    grDevices::col2rgb(colors) / 255
  )
  colors_out <- sapply(
    color_df, function(color) {
      color_rgb <- RGBA2RGB(list(color, alpha))
      grDevices::rgb(color_rgb[1], color_rgb[2], color_rgb[3])
    }
  )
  colors_out
}

#' @title Blends a list of colors using the specified blend mode
#'
#' @md
#' @param colors Color vectors.
#' @param mode Blend mode.
#' One of `"blend"`, `"average"`, `"screen"`, or `"multiply"`.
#'
#' @return A character vector of hexadecimal color codes representing the blended color.
#'
#' @export
#'
#' @examples
#' blend <- c(
#'   "red",
#'   "green",
#'   blendcolors(c("red", "green"),
#'     mode = "blend"
#'   )
#' )
#' average <- c(
#'   "red",
#'   "green",
#'   blendcolors(c("red", "green"),
#'     mode = "average"
#'   )
#' )
#' screen <- c(
#'   "red",
#'   "green",
#'   blendcolors(c("red", "green"),
#'     mode = "screen"
#'   )
#' )
#' multiply <- c(
#'   "red",
#'   "green",
#'   blendcolors(c("red", "green"),
#'     mode = "multiply"
#'   )
#' )
#' show_palettes(
#'   list(
#'     "blend" = blend,
#'     "average" = average,
#'     "screen" = screen,
#'     "multiply" = multiply
#'   )
#' )
blendcolors <- function(
  colors,
  mode = c("blend", "average", "screen", "multiply")
) {
  mode <- match.arg(mode)
  colors <- colors[!is.na(colors)]
  if (length(colors) == 0) {
    return(NA)
  }
  if (length(colors) == 1) {
    return(colors)
  }
  rgb <- as.list(
    as.data.frame(
      grDevices::col2rgb(colors) / 255
    )
  )
  Clist <- lapply(
    rgb, function(x) {
      list(x, 1)
    }
  )
  blend_color <- BlendRGBList(Clist, mode = mode)
  blend_color <- grDevices::rgb(
    blend_color[1], blend_color[2], blend_color[3]
  )
  return(blend_color)
}

#' @title Convert RGBA color to RGB with background
#'
#' @description
#' Convert an RGBA (Red, Green, Blue, Alpha) color to RGB by compositing
#' it with a background color based on the alpha channel.
#'
#' @md
#' @param RGBA A list containing RGB values and alpha channel.
#' @param BackGround The background RGB color to composite with.
#' Default is `c(1, 1, 1)` (white).
#'
#' @return A numeric vector of RGB values.
#'
#' @export
RGBA2RGB <- function(RGBA, BackGround = c(1, 1, 1)) {
  A <- RGBA[[length(RGBA)]]
  RGB <- RGBA[[-length(RGBA)]] * A + BackGround * (1 - A)
  return(RGB)
}

#' @title Blend two colors using a specified mode
#'
#' @description
#' Blend two colors with alpha channels using one of several blending modes:
#' blend, average, screen, or multiply.
#'
#' @md
#' @param C1 A list containing the first color RGB values and alpha channel.
#' @param C2 A list containing the second color RGB values and alpha channel.
#' @param mode The blending mode to use.
#' One of `"blend"`, `"average"`, `"screen"`, or `"multiply"`.
#' Default is `"blend"`.
#'
#' @return A list containing the blended RGB values and alpha channel.
#'
#' @export
Blend2Color <- function(C1, C2, mode = "blend") {
  c1 <- C1[[1]]
  c1a <- C1[[2]]
  c2 <- C2[[1]]
  c2a <- C2[[2]]
  A <- 1 - (1 - c1a) * (1 - c2a)
  if (A < 1.0e-6) {
    return(list(c(0, 0, 0), 1))
  }
  if (mode == "blend") {
    out <- (c1 * c1a + c2 * c2a * (1 - c1a)) / A
    A <- 1
  }
  if (mode == "average") {
    out <- (c1 + c2) / 2
    out[out > 1] <- 1
  }
  if (mode == "screen") {
    out <- 1 - (1 - c1) * (1 - c2)
  }
  if (mode == "multiply") {
    out <- c1 * c2
  }
  return(list(out, A))
}

#' @title Blend a list of colors
#'
#' @description
#' Blend multiple colors with alpha channels into a single color using
#' a specified blending mode.
#'
#' @md
#' @param Clist A list of colors, where each color is a list containing
#' RGB values and alpha channel.
#' @param mode The blending mode to use.
#' One of `"blend"`, `"average"`, `"screen"`, or `"multiply"`.
#' Default is `"blend"`.
#' @param RGB_BackGround The background RGB color to composite with.
#' Default is `c(1, 1, 1)` (white).
#'
#' @return A numeric vector of RGB values.
#'
#' @export
BlendRGBList <- function(
  Clist,
  mode = "blend",
  RGB_BackGround = c(1, 1, 1)
) {
  n <- length(Clist)
  clist_use <- Clist
  while (n != 1) {
    temp <- clist_use
    clist_use <- list()
    for (C in temp[1:(length(temp) - 1)]) {
      c1 <- C[[1]]
      a1 <- C[[2]]
      c2 <- temp[[length(temp)]][[1]]
      a2 <- temp[[length(temp)]][[2]]
      clist_use <- append(
        clist_use,
        list(
          Blend2Color(
            C1 = list(c1, a1 * (1 - 1 / n)),
            C2 = list(c2, a2 * 1 / n),
            mode = mode
          )
        )
      )
    }
    n <- length(clist_use)
  }
  result <- list(clist_use[[1]][[1]], clist_use[[1]][[2]])
  result <- RGBA2RGB(result, BackGround = RGB_BackGround)
  return(result)
}

#' @title Simple random color selection
#'
#' @description
#' Randomly select a specified number of colors from ChineseColors or other palettes.
#'
#' @md
#' @param n The number of colors to return. Default is `10`.
#' @param palette The name of the palette to use.
#' If `NULL` (default), colors will be selected from ChineseColors.
#' Otherwise, colors will be selected from the specified palette.
#' Available palette names can be queried with [show_palettes].
#'
#' @return A character vector of hexadecimal color codes.
#'
#' @export
#'
#' @examples
#' simple_colors()
#'
#' show_palettes(simple_colors(n = 5))
#'
#' # Get colors from a specific palette
#' simple_colors(n = 10, palette = "Paired")
#' simple_colors(n = 10, palette = "ChineseBlue")
#' simple_colors(n = 10, palette = "Spectral")
simple_colors <- function(n = 10, palette = NULL) {
  if (!is.numeric(n) || n < 1) {
    log_message(
      "Parameter 'n' must be a positive integer",
      message_type = "error"
    )
  }
  n <- as.integer(n)

  if (is.null(palette)) {
    cc_obj <- tryCatch(
      ChineseColors(),
      error = function(e) {
        log_message(
          "Failed to initialize {.fn ChineseColors}: {.val {conditionMessage(e)}}",
          message_type = "warning"
        )
        NULL
      }
    )

    if (is.null(cc_obj)) {
      log_message(
        "Cannot access ChineseColors. Please specify a palette name.",
        message_type = "error"
      )
    }

    all_colors <- cc_obj$colors$hex
    if (length(all_colors) == 0) {
      log_message(
        "No colors available in ChineseColors.",
        message_type = "error"
      )
    }

    # Randomly sample colors
    if (n > length(all_colors)) {
      log_message(
        "Requested {.val {n}} colors but only {.val {length(all_colors)}} available. Returning all colors.",
        message_type = "warning"
      )
      return(sample(all_colors, length(all_colors)))
    }

    return(sample(all_colors, n))
  } else {
    # Get colors from specified palette
    palette_list <- c(
      thisplot::palette_list,
      get_chinese_palettes()
    )

    if (!palette %in% names(palette_list)) {
      log_message(
        "The palette {.val {palette}} is invalid.\n",
        "Check the available palette names with {.fn show_palettes}.",
        message_type = "error"
      )
    }

    palette_colors <- palette_list[[palette]]
    if (length(palette_colors) == 0) {
      log_message(
        "The palette {.val {palette}} is empty.",
        message_type = "error"
      )
    }

    # Randomly sample colors
    if (n > length(palette_colors)) {
      log_message(
        "Requested {.val {n}} colors but only {.val {length(palette_colors)}} available in palette {.val {palette}}. Returning all colors.",
        message_type = "warning"
      )
      return(sample(palette_colors, length(palette_colors)))
    }

    return(sample(palette_colors, n))
  }
}
