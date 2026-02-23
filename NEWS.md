# thisplot

# thisplot 0.3.5

* **func** (Sankey):
  * `make_long()`: Converts a wide data frame to long format for `geom_sankey` / `geom_alluvial`, with optional `value` column for weights.
  * `geom_sankey()`: Sankey diagram layer (nodes and flows).
  * `geom_sankey_label()`, `geom_sankey_text()`: Sankey node label layers.
  * `geom_alluvial()`: Alluvial diagram layer.
  * `geom_alluvial_label()`, `geom_alluvial_text()`: Alluvial label layers.
  * `geom_sankey_bump()`: Sankey bump diagram layer.
  * `theme_sankey()`, `theme_alluvial()`, `theme_sankey_bump()`: Themes for sankey/alluvial plots.

# thisplot 0.3.4

* **func**:
  * `StatPlot()`: New function to visualize data using various plot types including bar plots, rose plots, ring plots, pie charts, trend plots, area plots, dot plots, sankey plots, chord plots, venn diagrams, and upset plots. Supports grouping, splitting, background coloring, and extensive customization options.

* **docs**:
  * `StatPlot()`: Added comprehensive parameter documentation for all function arguments including `group.by`, `split.by`, `palette`, `palcolor`, `title`, `subtitle`, `xlab`, `ylab`, `legend.position`, `legend.direction`, `theme_use`, `theme_args`, `combine`, `nrow`, `ncol`, `byrow`, `force`, and `seed`.
  * `StatPlot()`: Updated examples to use generic test data instead of single-cell specific datasets, making the function more accessible as a general-purpose plotting tool.

# thisplot 0.3.2

* **docs**:
  * `README`: Converted from static Markdown to R Markdown (`README.Rmd`) for dynamic content generation. Code examples now execute and display actual output instead of static images.

# thisplot 0.3.1

* **func**:
  * `check_ci_env()`: New function to detect if the current environment supports browsable HTML output. Now detects local pkgdown builds via `IN_PKGDOWN` environment variable and knitr HTML output contexts. 
  * `head.colors()`: New S3 method for `colors` objects, allowing the use of `head()` function to limit the number of displayed rows (default `n = 6L`).

* **enhancement**:
  * `visual_colors()`: Integrated `htmltools::browsable` functionality. Added `browsable` parameter (default `NULL` for auto-detection) to automatically display widgets in appropriate environments. Automatically detects interactive sessions and GitHub Actions pkgdown workflow, while preventing browser opening during CRAN checks.
  * `ChineseColors$visual_colors()`: Added `browsable` parameter support, consistent with the global `visual_colors()` function.
  * `get_colors()`: Now automatically infers RGB values from hex codes when colors are found in palettes but not in the main dataset. Added internal `hex_to_rgb()` helper function to convert hex color codes to RGB format strings.

# thisplot 0.3.0

* **func**:
  * `get_colors()`: New function to search for colors in the Chinese colors dataset and all available palettes. Supports searching by palette names, color names (pinyin or Chinese), numbers, or hex codes. Automatically reports which palette(s) contain the found colors.
  * `print.colors()`: New print method for colors objects to display color information with ANSI color support in terminal.

* **enhancement**:
  * Updated Chinese color system with improved functionality.

# thisplot 0.2.0

* **func**:
  * Chinese traditional color system
    * `ChineseColors()`: New function to create a Chinese traditional color system object with 1058 representative colors extracted from traditional Chinese color charts. Supports accessing colors by name (pinyin or Chinese), number, or hex code, creating color palettes, and generating segmented colormaps.
    * `visual_colors()`: New function to visualize colors in HTML format with a grid of color swatches, supporting optional names, RGB values, or hex codes.
    * `get_chinese_palettes()`: New function to get Chinese color palettes organized by color categories (blue, green, yellow, red, brown, purple, etc.) with automatic continuous palette generation.

* **data**:
  * `chinese_colors`: New data object containing 1058 Chinese traditional colors.

* **docs**:
  * Added comprehensive documentation for Chinese color system functions.
  * Updated package documentation to include Chinese traditional colors feature.

# thisplot 0.1.0

* initial version
