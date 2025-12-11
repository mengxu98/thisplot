# Changelog

## thisplot 0.3.1

- **func**:
  - [`check_ci_env()`](https://mengxu98.github.io/thisplot/reference/check_ci_env.md):
    New function to detect if the current environment supports browsable
    HTML output. Now detects local pkgdown builds via `IN_PKGDOWN`
    environment variable and knitr HTML output contexts.
  - [`head.colors()`](https://mengxu98.github.io/thisplot/reference/head.colors.md):
    New S3 method for `colors` objects, allowing the use of
    [`head()`](https://rdrr.io/r/utils/head.html) function to limit the
    number of displayed rows (default `n = 6L`).
- **enhancement**:
  - [`visual_colors()`](https://mengxu98.github.io/thisplot/reference/visual_colors.md):
    Integrated
    [`htmltools::browsable`](https://rstudio.github.io/htmltools/reference/browsable.html)
    functionality. Added `browsable` parameter (default `NULL` for
    auto-detection) to automatically display widgets in appropriate
    environments. Automatically detects interactive sessions and GitHub
    Actions pkgdown workflow, while preventing browser opening during
    CRAN checks.
  - `ChineseColors$visual_colors()`: Added `browsable` parameter
    support, consistent with the global
    [`visual_colors()`](https://mengxu98.github.io/thisplot/reference/visual_colors.md)
    function.
  - [`get_colors()`](https://mengxu98.github.io/thisplot/reference/get_colors.md):
    Now automatically infers RGB values from hex codes when colors are
    found in palettes but not in the main dataset. Added internal
    `hex_to_rgb()` helper function to convert hex color codes to RGB
    format strings.

## thisplot 0.3.0

- **func**:
  - [`get_colors()`](https://mengxu98.github.io/thisplot/reference/get_colors.md):
    New function to search for colors in the Chinese colors dataset and
    all available palettes. Supports searching by palette names, color
    names (pinyin or Chinese), numbers, or hex codes. Automatically
    reports which palette(s) contain the found colors.
  - [`print.colors()`](https://mengxu98.github.io/thisplot/reference/print.colors.md):
    New print method for colors objects to display color information
    with ANSI color support in terminal.
- **enhancement**:
  - Updated Chinese color system with improved functionality.

## thisplot 0.2.0

- **func**:
  - Chinese traditional color system
    - [`ChineseColors()`](https://mengxu98.github.io/thisplot/reference/ChineseColors.md):
      New function to create a Chinese traditional color system object
      with 1058 representative colors extracted from traditional Chinese
      color charts. Supports accessing colors by name (pinyin or
      Chinese), number, or hex code, creating color palettes, and
      generating segmented colormaps.
    - [`visual_colors()`](https://mengxu98.github.io/thisplot/reference/visual_colors.md):
      New function to visualize colors in HTML format with a grid of
      color swatches, supporting optional names, RGB values, or hex
      codes.
    - [`get_chinese_palettes()`](https://mengxu98.github.io/thisplot/reference/get_chinese_palettes.md):
      New function to get Chinese color palettes organized by color
      categories (blue, green, yellow, red, brown, purple, etc.) with
      automatic continuous palette generation.
- **data**:
  - `chinese_colors`: New data object containing 1058 Chinese
    traditional colors.
- **docs**:
  - Added comprehensive documentation for Chinese color system
    functions.
  - Updated package documentation to include Chinese traditional colors
    feature.

## thisplot 0.1.0

- initial version
