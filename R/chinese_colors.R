#' @title Chinese traditional colors system
#'
#' @description
#' A color system based on Chinese traditional colors with 1058 colors.
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
#' [get_colors] for searching colors in dataset and palettes.
#'
#' @examples
#' cc <- ChineseColors()
#' cc
#'
#' # Get a color by pinyin
#' get_colors("pinlan")
#'
#' # By number
#' get_colors(44)
#'
#' # By hex code
#' get_colors("#2B73AF")
#'
#' # Multiple colors
#' get_colors("pinlan", "piao")
#' get_colors(91:100)
#'
#' # Chinese names
#' cc$visual_colors(
#'   title = "Chinese Traditional Colors",
#'   name_type = "chinese"
#' )
#'
#' # pinyin as names
#' cc$visual_colors(
#'   loc_range = c(1, 120),
#'   title = "Chinese Traditional Colors",
#'   name_type = "pinyin"
#' )
#'
#' # rgb as names
#' cc$visual_colors(
#'   loc_range = c(1, 120),
#'   title = "Colors with RGB values",
#'   name_type = "rgb"
#' )
#'
#' # hex as names
#' cc$visual_colors(
#'   loc_range = c(1, 120),
#'   title = "Colors with hex codes",
#'   name_type = "hex"
#' )
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
    } else if (name_type == "pinyin") {
      display_name <- colors_subset$name
    } else if (name_type == "rgb") {
      display_name <- rgb_col
    } else if (name_type == "hex") {
      display_name <- color_col
    } else {
      display_name <- colors_subset$name
    }

    return(
      thisplot::visual_colors(
        colors = color_col,
        names = display_name,
        num_per_row = num_per_row,
        title = title
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

  cc_obj$visual_colors <- visual_colors

  class(cc_obj) <- "ChineseColors"
  return(cc_obj)
}

#' @title Print `ChineseColors` object
#'
#' @md
#' @param x A `ChineseColors` object.
#' @param ... Additional arguments.
#'
#' @return
#' Details of the `ChineseColors` object.
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
    "visual_colors(loc_range, num_per_row, title, name_type)"
  )
  cli::cli_h3("See also:")
  cli::cli_ul("[get_colors()] for searching colors")
}
