#' @title Visualize colors in HTML format
#'
#' @description
#' Display a grid of color swatches with optional names or color codes.
#'
#' @md
#' @param colors A character vector of color codes (hex format, e.g., "#FF0000").
#' @param names Optional. A character vector of names for each color.
#' Default is `NULL`, which means color codes will be displayed.
#' @param num_per_row Number of colors per row.
#' Default is `30`.
#' @param title Optional title for the visualization.
#' Default is `NULL`.
#' @param rgb Optional. A character vector of RGB values (e.g., "(255, 0, 0)").
#' If provided and `names` is `NULL`, RGB values will be displayed as names.
#' @param hex Optional. A logical or character vector. If `TRUE` and `names` is `NULL`,
#' hex codes will be displayed as names. If a character vector is provided,
#' it will be used as names.
#'
#' @return
#' An HTML widget that can be displayed with [htmltools::browsable].
#'
#' @export
#'
#' @examples
#' # Visualize a simple color palette
#' colors <- c("#FF0000", "#00FF00", "#0000FF")
#' widget <- visual_colors(colors, names = c("Red", "Green", "Blue"))
#' htmltools::browsable(widget)
#'
#' # Visualize a built-in palette
#' widget2 <- visual_colors(thisplot::palette_list$Paired)
#' htmltools::browsable(widget2)
#'
#' # Use with ChineseColors
#' cc <- ChineseColors()
#' widget3 <- visual_colors(
#'   colors = cc$blue[1:60],
#'   title = "Chinese Blue Colors"
#' )
#' htmltools::browsable(widget3)
visual_colors <- function(
  colors,
  names = NULL,
  num_per_row = 30,
  title = NULL,
  rgb = NULL,
  hex = NULL
) {
  if (is.null(colors) || length(colors) == 0) {
    log_message(
      "No colors provided",
      message_type = "warning"
    )
    return(NULL)
  }

  if (is.null(names)) {
    if (!is.null(rgb) && length(rgb) == length(colors)) {
      names <- rgb
    } else if (isTRUE(hex) || (!is.null(hex) && is.character(hex) && length(hex) == length(colors))) {
      if (is.character(hex)) {
        names <- hex
      } else {
        names <- colors
      }
    } else {
      names <- colors
    }
  }

  if (length(names) != length(colors)) {
    if (length(names) < length(colors)) {
      names <- c(names, colors[(length(names) + 1):length(colors)])
    } else {
      names <- names[seq_along(colors)]
    }
  }

  n_colors <- length(colors)

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

  cell_width_px <- 21
  cell_height_px <- 50

  format_text_display <- function(text) {
    if (is_chinese(text)) {
      chars <- strsplit(text, "")[[1]]
      if (length(chars) == 1) {
        return(chars[1])
      }
      html_str <- paste(chars, collapse = "<br>")
      return(htmltools::HTML(html_str))
    } else {
      return(text)
    }
  }

  get_text_style <- function(text, text_color) {
    base_style <- paste0(
      "color:", text_color, ";",
      "font-size:8px;",
      "font-family:'Noto Sans SC','PingFang SC','Microsoft YaHei',sans-serif;",
      "letter-spacing:0.2px;",
      "line-height:1.2;"
    )

    if (is_chinese(text)) {
      return(
        paste0(
          base_style,
          "display:block;",
          "text-align:center;",
          "width:100%;"
        )
      )
    } else {
      return(
        paste0(
          base_style,
          "display:inline-block;",
          "white-space:nowrap;"
        )
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
        text_style <- get_text_style(names[i], text_color)
        text_content <- format_text_display(names[i])
        is_chinese_text <- is_chinese(names[i])

        container_style <- if (is_chinese_text) {
          "display:flex;align-items:center;justify-content:center;width:100%;height:100%;"
        } else {
          "display:flex;align-items:center;justify-content:center;width:100%;height:100%;transform:rotate(-90deg);transform-origin:center;"
        }

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
            "display:table-cell;",
            "position:relative;",
            "overflow:hidden;"
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
              "text-align:center;"
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

  table_html
}
