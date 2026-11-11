#' @title Choose contrasting text colors
#'
#' @description
#' Choose black or white text using the larger relative-luminance contrast
#' ratio. Transparent fills are composited over an opaque background first.
#' @md
#' @param colors A vector of R colors. Missing colors are transparent.
#' @param alpha NULL to use each color's alpha channel, or a finite numeric
#'   opacity in `[0, 1]`, either one value or one per color.
#' @param background One opaque R background color. Default is white.
#' @return A character vector of black or white, with the names of colors.
#' @references
#' [W3C contrast definition](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html).
#' @export
#' @examples
#' contrast_text(c("navy", "ivory"))
#' contrast_text(c("black", "black"), alpha = c(1, 0.2))
contrast_text <- function(colors, alpha = NULL, background = "white") {
  if (length(background) != 1L || is.na(background)) {
    stop("background must be one opaque color.", call. = FALSE)
  }
  back <- grDevices::col2rgb(background, alpha = TRUE) / 255
  if (back[4L] != 1) {
    stop("background must be one opaque color.", call. = FALSE)
  }
  n <- length(colors)
  if (!is.null(alpha) && (!is.numeric(alpha) ||
    !length(alpha) %in% c(1L, n) || any(!is.finite(alpha) | alpha < 0 | alpha > 1))) {
    stop("alpha must be finite and between 0 and 1, with one value or one per color.", call. = FALSE)
  }
  if (!n) {
    return(stats::setNames(character(), names(colors)))
  }
  rgba <- grDevices::col2rgb(colors, alpha = TRUE) / 255
  opacity <- if (is.null(alpha)) rgba[4L, ] else rep(alpha, length.out = n)
  opacity[is.na(colors)] <- 0
  rgb <- sweep(rgba[1:3, , drop = FALSE], 2L, opacity, "*") +
    tcrossprod(back[1:3], 1 - opacity)
  linear <- ifelse(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  luminance <- as.vector(c(0.2126, 0.7152, 0.0722) %*% linear)
  stats::setNames(ifelse(1.05 / (luminance + 0.05) >=
    (luminance + 0.05) / 0.05, "white", "black"), names(colors))
}
