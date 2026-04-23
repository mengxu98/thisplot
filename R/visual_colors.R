#' @title Visualize colors in HTML widget
#'
#' @description
#' Display a grid of color swatches with optional names or color codes.
#'
#' @md
#' @param colors A character vector of hex color codes.
#' @param names Optional. A character vector of names for each color.
#' Default is `NULL`, which means hex color codes will be displayed.
#' You can pass any labels (e.g., RGB values, custom names) via this parameter.
#' @param num_per_row Number of colors per row.
#' Default is `30`.
#' @param title Optional title for the visualization.
#' Default is `NULL`.
#' @param label_mode Label layout mode. Default is `"auto"`, which detects
#' the label type from `names`. Use `"chinese"`, `"pinyin"`, `"rgb"`,
#' or `"hex"` to force a layout optimized for that label style.
#'
#' @return
#' An HTML widget.
#'
#' @export
#'
#' @examples
#' # Visualize a simple color palette
#' visual_colors(
#'   colors = c("#FF0000", "#00FF00", "#0000FF"),
#'   names = c("Red", "Green", "Blue")
#' )
#'
#' visual_colors(
#'   colors = c("#FF0000", "#00FF00"),
#'   names = c("(255, 0, 0)", "(0, 255, 0)")
#' )
#'
#' visual_colors(thisplot::palette_list$Paired)
#'
#' # Use with ChineseColors
#' cc <- ChineseColors()
#' visual_colors(
#'   colors = cc$blue[1:60],
#'   title = "Chinese Blue Colors"
#' )
visual_colors <- function(
  colors,
  names = NULL,
  num_per_row = 30,
  title = NULL,
  label_mode = c("auto", "chinese", "pinyin", "rgb", "hex")
) {
  label_mode <- match.arg(label_mode)

  if (is.null(colors) || length(colors) == 0) {
    log_message(
      "No colors provided",
      message_type = "error"
    )
  }

  if (is.null(names)) {
    names <- colors
  }

  if (length(names) != length(colors)) {
    if (length(names) < length(colors)) {
      names <- c(names, colors[(length(names) + 1):length(colors)])
    } else {
      names <- names[seq_along(colors)]
    }
  }

  n_colors <- length(colors)
  display_names <- as.character(names)

  luminance <- function(hex_color) {
    rgb <- grDevices::col2rgb(hex_color) / 255
    0.299 * rgb[1, ] + 0.587 * rgb[2, ] + 0.114 * rgb[3, ]
  }

  text_color_for <- function(hex_color) {
    ifelse(luminance(hex_color) > 0.5, "#000000", "#FFFFFF")
  }

  is_chinese <- function(text) {
    if (is.null(text) || length(text) == 0 || is.na(text)) {
      return(FALSE)
    }
    grepl("[\u4e00-\u9fff]", text, perl = TRUE)
  }

  is_hex_label <- function(text) {
    if (is.null(text) || length(text) == 0 || is.na(text)) {
      return(FALSE)
    }
    grepl("^#[A-Fa-f0-9]{6}$", text)
  }

  is_rgb_label <- function(text) {
    if (is.null(text) || length(text) == 0 || is.na(text)) {
      return(FALSE)
    }
    grepl("^\\(\\s*\\d{1,3}\\s*,\\s*\\d{1,3}\\s*,\\s*\\d{1,3}\\s*\\)$", text)
  }

  detect_label_mode <- function(texts) {
    valid_texts <- texts[!is.na(texts) & nzchar(texts)]
    if (length(valid_texts) == 0) {
      return("hex")
    }
    if (all(vapply(valid_texts, is_chinese, logical(1)))) {
      return("chinese")
    }
    if (all(vapply(valid_texts, is_hex_label, logical(1)))) {
      return("hex")
    }
    if (all(vapply(valid_texts, is_rgb_label, logical(1)))) {
      return("rgb")
    }
    if (all(grepl("^[A-Za-z]+$", valid_texts))) {
      return("pinyin")
    }
    "pinyin"
  }

  get_label_layout <- function(mode, texts) {
    switch(
      mode,
      chinese = list(
        cell_width = 21,
        cell_height = 50,
        font_size = 8.5,
        line_height = 1.08,
        letter_spacing = "0.2px",
        rotate = FALSE,
        white_space = "normal",
        font_weight = 500
      ),
      pinyin = list(
        cell_width = 21,
        cell_height = 50,
        font_size = 9,
        line_height = 1,
        letter_spacing = "0px",
        rotate = FALSE,
        white_space = "nowrap",
        font_weight = 500
      ),
      rgb = list(
        cell_width = 21,
        cell_height = 50,
        font_size = 8.8,
        line_height = 1,
        letter_spacing = "0px",
        rotate = FALSE,
        white_space = "nowrap",
        font_weight = 500
      ),
      hex = list(
        cell_width = 21,
        cell_height = 50,
        font_size = 9,
        line_height = 1,
        letter_spacing = "0px",
        rotate = FALSE,
        white_space = "nowrap",
        font_weight = 600
      ),
      list(
        cell_width = 21,
        cell_height = 50,
        font_size = 8.8,
        line_height = 1,
        letter_spacing = "0px",
        rotate = FALSE,
        white_space = "nowrap",
        font_weight = 500
      )
    )
  }

  layout_mode <- if (identical(label_mode, "auto")) {
    detect_label_mode(display_names)
  } else {
    label_mode
  }
  label_layout <- get_label_layout(layout_mode, display_names)
  cell_width_px <- label_layout$cell_width
  cell_height_px <- label_layout$cell_height

  format_text_display <- function(text) {
    if (identical(layout_mode, "chinese") && is_chinese(text)) {
      chars <- strsplit(text, "", fixed = TRUE)[[1]]
      if (length(chars) == 1) {
        return(chars[1])
      }
      htmltools::HTML(paste(chars, collapse = "<br>"))
    } else {
      text
    }
  }

  get_text_style <- function(text, text_color) {
    base_style <- paste0(
      "color:", text_color, ";",
      "font-size:", label_layout$font_size, "px;",
      "font-family:'Noto Sans SC','PingFang SC','Microsoft YaHei',sans-serif;",
      "letter-spacing:", label_layout$letter_spacing, ";",
      "line-height:", label_layout$line_height, ";",
      "font-weight:", label_layout$font_weight, ";"
    )

    if (identical(layout_mode, "chinese") && is_chinese(text)) {
      paste0(
        base_style,
        "display:block;",
        "text-align:center;",
        "width:100%;",
        "white-space:normal;"
      )
    } else {
      paste0(
        base_style,
        "display:block;",
        "white-space:", label_layout$white_space, ";",
        "writing-mode:vertical-rl;",
        "text-orientation:mixed;",
        "transform:rotate(180deg);",
        "transform-origin:center center;",
        "text-align:center;"
      )
    }
  }

  idx_list <- split(
    seq_len(n_colors), ceiling(seq_len(n_colors) / num_per_row)
  )
  rows_html <- lapply(
    idx_list, function(idxs) {
      cells <- lapply(idxs, function(i) {
        text_color <- text_color_for(colors[i])
        text_style <- get_text_style(display_names[i], text_color)
        text_content <- format_text_display(display_names[i])
        container_base <- paste0(
          "display:flex;",
          "align-items:center;",
          "justify-content:center;",
          "width:100%;",
          "height:100%;",
          "box-sizing:border-box;",
          "padding:2px 0;",
          "overflow:hidden;"
        )
        container_style <- container_base

        htmltools::tags$td(
          style = paste0(
            "padding:2px 2px;",
            "width:", cell_width_px, "px;",
            "min-width:", cell_width_px, "px;",
            "max-width:", cell_width_px, "px;",
            "height:", cell_height_px, "px;",
            "min-height:", cell_height_px, "px;",
            "border-radius:3px;",
            "background:", colors[i], ";",
            "box-shadow:0 1px 2px rgba(0,0,0,0.2);",
            "text-align:center;",
            "vertical-align:middle;",
            "position:relative;",
            "overflow:hidden;",
            "box-sizing:border-box;"
          ),
          htmltools::tags$div(
            style = container_style,
            htmltools::tags$div(
              style = text_style,
              text_content
            )
          )
        )
      })

      if (length(cells) < num_per_row) {
        empties <- replicate(
          num_per_row - length(cells),
          htmltools::tags$td(
            style = paste0(
              "padding:2px 2px;",
              "width:", cell_width_px, "px;",
              "min-width:", cell_width_px, "px;",
              "max-width:", cell_width_px, "px;",
              "height:", cell_height_px, "px;",
              "min-height:", cell_height_px, "px;",
              "border-radius:3px;",
              "background:transparent;",
              "text-align:center;",
              "box-sizing:border-box;"
            ),
            ""
          ),
          simplify = FALSE
        )
        cells <- c(cells, empties)
      }

      htmltools::tags$tr(cells)
    }
  )

  header <- NULL
  if (!is.null(title)) {
    header <- htmltools::tags$div(
      style = paste0(
        "font-family:'Noto Sans SC','PingFang SC','Microsoft YaHei',sans-serif;",
        "font-size:13px;font-weight:600;",
        "color:inherit;margin-bottom:3px;"
      ),
      title
    )
  }

  table_html <- htmltools::tags$div(
    style = paste0(
      "background:transparent;",
      "padding:12px;",
      "border-radius:12px;",
      "border:1px solid rgba(0,0,0,0.1);",
      "box-shadow:none;",
      "display:inline-block;",
      "overflow-x:auto;"
    ),
    header,
    htmltools::tags$table(
      style = "border-collapse:separate;border-spacing:3px;",
      htmltools::tags$tbody(rows_html)
    )
  )

  if (check_ci_env()) {
    htmltools::browsable(table_html)
  } else {
    invisible(table_html)
  }
}
