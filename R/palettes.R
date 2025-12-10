#' @title Color palettes collected
#'
#' @description This function creates a color palette for a given vector of values.
#'
#' @md
#' @param x A vector of character/factor or numeric values.
#' If missing, numeric values 1:n will be used as x.
#' @param n The number of colors to return for numeric values.
#' @param palette Palette name.
#' All available palette names can be queried with [show_palettes].
#' @param palcolor Custom colors used to create a color palette.
#' @param type Type of `x`.
#' Can be one of `"auto"`, `"discrete"` or `"continuous"`.
#' The default is `"auto"`, which automatically detects if `x` is a numeric value.
#' @param matched Whether to return a color vector of the same length as `x`.
#' Default is `FALSE`.
#' @param reverse Whether to invert the colors.
#' Default is `FALSE`.
#' @param NA_keep Whether to keep the color assignment to NA in `x`.
#' Default is `FALSE`.
#' @param NA_color Color assigned to NA if `NA_keep` is `TRUE`.
#' Default is `"grey80"`.
#'
#' @return A character vector of color codes (hexadecimal format) corresponding to the input values `x`. The length and structure depend on the `matched` parameter.
#'
#' @seealso [show_palettes], [palette_list]
#'
#' @export
#'
#' @examples
#' x <- c(1:3, NA, 3:5)
#' (pal1 <- palette_colors(
#'   x,
#'   palette = "Spectral"
#' ))
#' (pal2 <- palette_colors(
#'   x,
#'   palcolor = c("red", "white", "blue")
#' ))
#' (pal3 <- palette_colors(
#'   x,
#'   palette = "Spectral",
#'   n = 10
#' ))
#' (pal4 <- palette_colors(
#'   x,
#'   palette = "Spectral",
#'   n = 10,
#'   reverse = TRUE
#' ))
#' (pal5 <- palette_colors(
#'   x,
#'   palette = "Spectral",
#'   matched = TRUE
#' ))
#' (pal6 <- palette_colors(
#'   x,
#'   palette = "Spectral",
#'   matched = TRUE,
#'   NA_keep = TRUE
#' ))
#' show_palettes(
#'   list(pal1, pal2, pal3, pal4, pal5, pal6)
#' )
#'
#' # Use Chinese color palettes
#' palette_colors(
#'   x = letters[1:5],
#'   palette = "Chinese_red",
#'   type = "discrete"
#' )
#' palette_colors(
#'   x = letters[1:5],
#'   palette = "Chinese",
#'   type = "discrete"
#' )
#'
#' all_palettes <- show_palettes(return_palettes = TRUE)
#' names(all_palettes)
palette_colors <- function(
  x,
  n = 100,
  palette = "Paired",
  palcolor = NULL,
  type = c("auto", "discrete", "continuous"),
  matched = FALSE,
  reverse = FALSE,
  NA_keep = FALSE,
  NA_color = "grey80"
) {
  palette_list <- c(
    thisplot::palette_list,
    get_chinese_palettes()
  )
  if (missing(x)) {
    x <- 1:n
    type <- "continuous"
  }
  if (!palette %in% names(palette_list)) {
    log_message(
      "The palette {.val {palette}} is invalid.\n",
      "Check the available palette names with {.fn show_palettes}.\n",
      "Or pass palette colors via the {.arg palcolor} parameter",
      message_type = "error"
    )
  }
  if (is.list(palcolor)) {
    palcolor <- unlist(palcolor)
  }
  if (all(palcolor == "")) {
    palcolor <- palette_list[[palette]]
  }
  if (is.null(palcolor) || length(palcolor) == 0) {
    palcolor <- palette_list[[palette]]
  }
  if (!is.null(names(palcolor))) {
    if (all(x %in% names(palcolor))) {
      palcolor <- palcolor[intersect(names(palcolor), x)]
    }
  }
  pal_n <- length(palcolor)
  type <- match.arg(type)

  if (type == "auto") {
    if (is.numeric(x)) {
      type <- "continuous"
    } else {
      type <- "discrete"
    }
  }

  if (type == "discrete") {
    if (!is.factor(x)) {
      x <- factor(x, levels = unique(x))
    }
    n_x <- nlevels(x)
    if (isTRUE(attr(palcolor, "type") == "continuous")) {
      color <- grDevices::colorRampPalette(palcolor)(n_x)
    } else {
      color <- ifelse(rep(n_x, n_x) <= pal_n,
        palcolor[1:n_x],
        grDevices::colorRampPalette(palcolor)(n_x)
      )
    }
    names(color) <- levels(x)
    if (any(is.na(x))) {
      color <- c(color, stats::setNames(NA_color, "NA"))
    }
    if (isTRUE(matched)) {
      color <- color[x]
      color[is.na(color)] <- NA_color
    }
  } else if (type == "continuous") {
    if (!is.numeric(x) && all(!is.na(x))) {
      log_message(
        "'x' must be type of numeric when use continuous color palettes.",
        message_type = "error"
      )
    }
    if (all(is.na(x))) {
      values <- as.factor(rep(0, n))
    } else if (length(unique(stats::na.omit(as.numeric(x)))) == 1) {
      values <- as.factor(rep(unique(stats::na.omit(as.numeric(x))), n))
    } else {
      if (isTRUE(matched)) {
        values <- cut(
          x,
          breaks = seq(min(x, na.rm = TRUE),
            max(x, na.rm = TRUE),
            length.out = n + 1
          ),
          include.lowest = TRUE
        )
      } else {
        values <- cut(
          1:100,
          breaks = seq(min(x, na.rm = TRUE),
            max(x, na.rm = TRUE),
            length.out = n + 1
          ),
          include.lowest = TRUE
        )
      }
    }

    n_x <- nlevels(values)
    color <- ifelse(rep(n_x, n_x) <= pal_n,
      palcolor[1:n_x],
      grDevices::colorRampPalette(palcolor)(n_x)
    )
    names(color) <- levels(values)
    if (any(is.na(x))) {
      color <- c(color, stats::setNames(NA_color, "NA"))
    }
    if (isTRUE(matched)) {
      if (all(is.na(x))) {
        color <- NA_color
      } else if (length(unique(stats::na.omit(x))) == 1) {
        color <- color[as.character(unique(stats::na.omit(x)))]
        color[is.na(color)] <- NA_color
      } else {
        color <- color[as.character(values)]
        color[is.na(color)] <- NA_color
      }
    }
  }

  if (isTRUE(reverse)) {
    color <- rev(color)
  }
  if (isFALSE(NA_keep)) {
    color <- color[names(color) != "NA"]
  }
  return(color)
}

#' @title Show the color palettes
#'
#' @description This function displays color palettes using ggplot2.
#'
#' @md
#' @param palettes A list of color palettes.
#' Default is `NULL`.
#' @param type The type of palettes to include.
#' Default is `"discrete"`.
#' @param index The indices of the palettes to include.
#' Default is `NULL`.
#' @param palette_names The names of the palettes to include.
#' Default is `NULL`.
#' @param return_names Whether to return the names of the selected palettes.
#' Default is `TRUE`.
#' @param return_palettes Whether to return the colors of selected palettes.
#' Default is `FALSE`.
#'
#' @return If `return_palettes` is `TRUE`, returns a list of color palettes. If `return_names` is `TRUE` (default), returns a character vector of palette names. Otherwise, returns `NULL` (called for side effects to display the plot).
#'
#' @seealso [palette_colors], [palette_list]
#'
#' @export
#'
#' @examples
#' show_palettes(
#'   palettes = list(
#'     c("red", "blue", "green"),
#'     c("yellow", "purple", "orange")
#'   )
#' )
#' all_palettes <- show_palettes(return_palettes = TRUE)
#' names(all_palettes)
#' all_palettes[["simspec"]]
#' show_palettes(index = 1:10)
#' show_palettes(
#'   type = "discrete",
#'   index = 1:10
#' )
#' show_palettes(
#'   type = "continuous",
#'   index = 1:10
#' )
#' show_palettes(
#'   palette_names = c(
#'     "Paired", "nejm", "simspec", "Spectral", "jet", "Chinese"
#'   ),
#'   return_palettes = TRUE
#' )
#' # Include Chinese palettes via prefix
#' show_palettes(
#'   palette_names = c("Chinese_red", "Chinese_blue"),
#'   return_palettes = TRUE
#' )
show_palettes <- function(
  palettes = NULL,
  type = c("discrete", "continuous"),
  index = NULL,
  palette_names = NULL,
  return_names = TRUE,
  return_palettes = FALSE
) {
  palette_list <- c(
    thisplot::palette_list,
    get_chinese_palettes()
  )
  if (!is.null(palettes)) {
    palette_list <- palettes
  } else {
    choose <- unlist(
      lapply(
        palette_list, function(x) isTRUE(attr(x, "type") %in% type)
      )
    )
    palette_list <- palette_list[choose]
  }
  index <- index[index %in% seq_along(palette_list)]
  if (!is.null(index)) {
    palette_list <- palette_list[index]
  }
  if (is.null(names(palette_list))) {
    names(palette_list) <- seq_along(palette_list)
  }
  if (is.null(palette_names)) {
    palette_names <- palette_names %||% names(palette_list)
  }
  palette_not_found <- !palette_names %in% names(palette_list)
  if (any(palette_not_found)) {
    log_message(
      "Can not find the palettes: {.val {palette_names[palette_not_found]}}",
      message_type = "error"
    )
  }
  palette_list <- palette_list[palette_names]

  df <- data.frame(
    palette = rep(
      names(palette_list), sapply(palette_list, length)
    ), color = unlist(palette_list)
  )
  df[["palette"]] <- factor(
    df[["palette"]],
    levels = rev(unique(df[["palette"]]))
  )
  df[["color_order"]] <- factor(
    seq_len(nrow(df)),
    levels = seq_len(nrow(df))
  )
  df[["proportion"]] <- as.numeric(
    1 / table(df$palette)[df$palette]
  )

  p <- ggplot(
    data = df,
    aes(
      y = .data[["palette"]],
      x = .data[["proportion"]],
      fill = .data[["color_order"]]
    )
  ) +
    geom_col(show.legend = FALSE) +
    scale_fill_manual(values = df[["color"]]) +
    scale_x_continuous(expand = c(0, 0), trans = "reverse") +
    theme_this(
      axis.title = element_blank(),
      axis.ticks = element_blank(),
      axis.text.x = element_blank(),
      panel.border = element_blank()
    )
  print(p)

  if (isTRUE(return_palettes)) {
    return(palette_list)
  }
  if (isTRUE(return_names)) {
    return(palette_names)
  }
}

#' @title Get Chinese color palettes
#'
#' @param prefix The prefix of the palette names.
#' Default is `"Chinese_"`.
#'
#' @return A list of Chinese color palettes.
#' @export
#'
#' @examples
#' show_palettes(get_chinese_palettes())
get_chinese_palettes <- function(
  prefix = "Chinese"
) {
  cc_obj <- ChineseColors()

  category_names <- c(
    "blue", "cyan", "green", "gray_brown",
    "orange", "purple", "red", "yellow"
  )

  palettes <- list()

  all_palette_colors <- list()
  for (name in category_names) {
    discrete_cols <- cc_obj[[name]]
    all_palette_colors[[name]] <- discrete_cols
    attr(discrete_cols, "type") <- "discrete"
    palettes[[paste0(prefix, thisutils::capitalize(name))]] <- discrete_cols
  }

  if (length(all_palette_colors) > 1) {
    all_colors_vec <- unlist(all_palette_colors)
    dup_colors <- all_colors_vec[duplicated(all_colors_vec)]

    if (length(dup_colors) > 0) {
      for (dup_color in unique(dup_colors)) {
        containing_palettes <- names(all_palette_colors)[
          sapply(all_palette_colors, function(x) dup_color %in% x)
        ]

        if (length(containing_palettes) > 1) {
          keep_in <- sort(containing_palettes)[1]
          remove_from <- containing_palettes[containing_palettes != keep_in]

          for (pal_name in remove_from) {
            pal_key <- paste0(prefix, thisutils::capitalize(pal_name))
            if (pal_key %in% names(palettes)) {
              palettes[[pal_key]] <- palettes[[pal_key]][palettes[[pal_key]] != dup_color]
            }
          }
        }
      }
    }
  }

  color_sets <- attr(thisplot::chinese_colors, "color_sets", exact = TRUE)
  chinese_default <- color_sets$ChineseSet8
  for (set_name in names(color_sets)) {
    palettes[[set_name]] <- color_sets[[set_name]]
  }

  attr(chinese_default, "type") <- "discrete"
  palettes[["Chinese"]] <- chinese_default

  continuous_cols <- grDevices::colorRampPalette(chinese_default)(256)
  attr(continuous_cols, "type") <- "continuous"
  palettes[["ChineseContinuous"]] <- continuous_cols

  palette_names <- names(palettes)
  special_names <- c("Chinese", "ChineseContinuous")
  set_names <- grep("^ChineseSet[0-9]+$", palette_names, value = TRUE)

  if (length(set_names) > 0) {
    set_numbers <- as.numeric(gsub("ChineseSet", "", set_names))
    set_names <- set_names[order(set_numbers)]
  }

  other_names <- setdiff(palette_names, c(special_names, set_names))
  sorted_names <- c(
    intersect(special_names, palette_names),
    set_names,
    sort(other_names)
  )
  palettes <- palettes[sorted_names]
  palettes
}
