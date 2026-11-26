# thisplot (development version)

* **feat**:
  * Add `annotation_raster_background()` for white-blended images in data
    coordinates and `geom_round_rect()` for rounded rectangles.
  * Add `scatter_layers()`, `plot_scatter3d()`, and `streamline_layers()` for
    reusable scatter layers, interactive 3D scatter plots, and streamlines.
  * Add `contrast_text()` for black or white text over transparent fills.

* **fix**:
  * Fix the missing `rowwise()` error in `geom_sankey_bump()`.
  * Restore the caller's random-number state after seeded plots, including on
    error, and retain variables used in arithmetic mappings and facet expressions.

* **compatibility**:
  * Rename `get_chinese_palettes()` to `chinese_palettes()`.
  * Move `...` to the end of function signatures. Use `palettes = NULL` for
    unrestricted `get_colors()` searches and `value = NULL` for unweighted
    `make_long()` selections.
  * Import `dplyr` and declare the GitHub source for `thisutils` (>= 0.5.4).
    Install optional dependencies on first use and give an install hint on failure.

# thisplot 0.4.6

* **compatibility**:
  * Require ggplot2 >= 4.0.0 and thisutils >= 0.5.0. Optional dependencies
    are checked without installation during plotting. Only hull marks require
    concaveman.

* **feat**:
  * Add `NetworkPlot()` for styled node and edge plots with igraph layouts
    (`fr`, `kk`, `circle`) or supplied coordinates. Keep the strongest duplicate
    edge and drop self-loops.
  * Add `rasterise_plot()` for 300 dpi rasterisation of point and line layers
    in `ggplot` and `patchwork` objects without X11.
  * Add `plot_scatter()` and `plot_histogram()` using `theme_this()` and
    thisplot palettes. Correlation annotation no longer depends on `ggpubr`;
    point density and marginal plots remain optional.
  * `StatPlot()` value bars can show numeric labels through `label = TRUE`.
  * Extend `get_colors()` to return level-to-colour mappings for `ggplot` and
    `patchwork`, and colours with Chinese names for `gtable`, `grob`, `gList`,
    `ComplexHeatmap::Heatmap`, `pheatmap`, and `trellis`. Report unsupported
    object types clearly.
  * Add `print_colored_table()` for ANSI-coloured data frames, with column
    colouring by default, optional row colouring, and plain headers.
  * Add `invert_svg()` and `invert_png()` for dark-mode figures. SVG inversion
    supports `rgb()` colours and includes embedded PNGs by default
    (`invert_raster = FALSE` to skip them).
  * Add `invert_figures()` to process files or directories in batches. PNG
    and batch inversion write `-dark` copies, and batches skip files with
    that suffix.

* **fix**:
  * Invert SVG colour animations while preserving other animations, element
    references, and CSS selectors.
  * Keep endpoints of edges with missing weights and retain zero-weight edges
    in network plots. Exclude zero-weight edges from `fr` and `kk` layout forces.
  * Center the rotated y-axis label along the coordinate arrow in
    `theme_blank()` across panel sizes and custom arrow lengths.
  * Align `get_colors()` and colored-table columns using ANSI-aware terminal
    display widths, including Chinese text.
  * Apply distinct palette colors consistently when printing colored tables.

* **docs**:
  * Streamline documentation for optional `ComplexHeatmap` helpers.

# thisplot 0.4.4

* **fix**:
  * Restore `ComplexHeatmap` as an optional dependency so `thisplot` can be
    installed from repositories that do not package Bioconductor dependencies.
  * Check for `ComplexHeatmap` when heatmap-specific helpers are used and run
    their examples only when the optional package is available.

# thisplot 0.4.3

* **feat**:
  * Add `major_grid()` for reusable major-grid control.
  * Let block heatmap annotations control border colour and line width.

* **fix**:
  * Declare `ComplexHeatmap` as an imported dependency so heatmap examples run on clean check systems.

# thisplot 0.4.1

* **feat**:
  * `StatPlot()`: Added direct x-axis label rotation control via `x_text_angle`.
  * `StatPlot()`: Major panel grid settings now consistently control percent trend plots.

* **docs**:
  * Documented `x_text_angle` validation and updated release metadata.

# thisplot 0.3.9

* **feat**:
  * Add `DimDataPlot()` for supplied 2D coordinates, with grouping, splitting,
    and optional labels and group marks.
  * `StatPlot()`: Added configurable major panel grid lines via `grid_major`, `grid_major_colour`, `grid_major_linetype`, and `grid_major_linewidth`.
  * `StatPlot()`: Added optional `venn_engine = "venny"` support for more flexible 2-4 set Venn diagrams while keeping `ggVennDiagram` as the default.

* **docs**:
  * Document `DimDataPlot()` and the new `StatPlot()` options, with examples
    for `DimDataPlot()` and the `venny` backend.

# thisplot 0.3.8

* **feat**:
  * Add migration helpers:
    * `to_percent()`: convert values to percentages after unit-sum normalization.
    * `annotate_quadrants()`: add quadrant guide lines and percentage labels to scatter plots.
    * `clip_symmetric_range()`: clip values to symmetric lower and upper limits.
    * `jitter_highlighted_points()`: deterministically jitter highlighted points for stable plotting output.
  * Add adaptive HTML label layouts through `visual_colors(label_mode = ...)`.
    `ChineseColors$visual_colors()` uses `name_type` to select the layout.
  * Use `color_sets$Chinese` as the default in `get_chinese_palettes()`, with a
    fallback for incomplete metadata.

* **docs**:
  * Document the migration helpers and adaptive label layouts. Add examples
    for the helpers and the default Chinese palette.

* **data**:
  * Refresh Chinese colour palette metadata, ordering, and defaults.

# thisplot 0.3.7

* **feat**:
  * `GraphPlot()`: New function for graph visualization with node/edge layers, optional transition arrows, highlighting, labels, palettes, and theme customization.
  * `compute_velocity_on_grid()`: New function to compute smoothed velocity vectors on an embedding grid, with optional adjustment for stream-style visualization.
  * `palette_colors()`: Changed the default `palette` from `"Paired"` to `"Chinese"`.

* **docs**:
  * Heatmap helpers:
    * Refined documentation for `annotation_block_fill_graphics()` and `build_heatmap_annotation()`.

* **deps**:
  * Added `ggnewscale` and `reshape2` to `Imports`.

# thisplot 0.3.6

* **feat**:
  * `StatPlot()`: Optimized venn plot rendering by using `coord_fixed(ratio = 1, clip = "off")`.
  * Heatmap functions:
    * `annotation_block_fill_graphics()`
    * `annotation_block_graphics()`
    * `annotation_graphics()`
    * `build_heatmap_annotation()`
    * `cluster_within_group2()`
    * `heatmap_fixsize()`
    * `heatmap_rendersize()`
    * `normalize_drawable()`

# thisplot 0.3.5

* **feat**:
  * Sankey
    * `make_long()`: Converts a wide data frame to long format for `geom_sankey` / `geom_alluvial`, with optional `value` column for weights.
    * `geom_sankey()`: Sankey diagram layer (nodes and flows).
    * `geom_sankey_label()`, `geom_sankey_text()`: Sankey node label layers.
    * `geom_alluvial()`: Alluvial diagram layer.
    * `geom_alluvial_label()`, `geom_alluvial_text()`: Alluvial label layers.
    * `geom_sankey_bump()`: Sankey bump diagram layer.
    * `theme_sankey()`, `theme_alluvial()`, `theme_sankey_bump()`: Themes for sankey/alluvial plots.

# thisplot 0.3.4

* **feat**:
  * Add `StatPlot()` for statistical plots including bars, trends, Sankey
    diagrams, Venn diagrams, and UpSet plots, with grouping and splitting.

* **docs**:
  * Document `StatPlot()` arguments and use generic data in examples.

# thisplot 0.3.2

* **docs**:
  * `README`: Converted from static Markdown to R Markdown (`README.Rmd`) for dynamic content generation. Code examples now execute and display actual output instead of static images.

# thisplot 0.3.1

* **feat**:
  * Add `check_ci_env()` to detect browsable HTML contexts, including pkgdown
    and knitr builds.
  * Add `head()` support for `colors` objects, showing six rows by default.
  * Add `browsable` to `visual_colors()` and `ChineseColors$visual_colors()`.
    The default (`NULL`) detects when to display HTML and avoids opening a
    browser during CRAN checks.
  * Infer RGB values from hex codes in `get_colors()` for palette entries
    outside the main dataset.

# thisplot 0.3.0

* **feat**:
  * `get_colors()`: New function to search for colors in the Chinese colors dataset and all available palettes. Supports searching by palette names, color names (pinyin or Chinese), numbers, or hex codes. Automatically reports which palette(s) contain the found colors.
  * `print.colors()`: New print method for colors objects to display color information with ANSI color support in terminal.
  * Updated Chinese color system with improved functionality.

# thisplot 0.2.0

* **feat**:
  * Add `ChineseColors()` to look up traditional Chinese colours by Chinese
    name, pinyin, number, or hex code and create palettes and segmented colour maps.
  * Add `visual_colors()` for HTML swatches with optional names, RGB values,
    or hex codes.
  * Add `get_chinese_palettes()` for palettes by colour category, including
    continuous variants.

* **data**:
  * Add `chinese_colors`, a dataset of 1,058 traditional Chinese colours.

* **docs**:
  * Document the traditional Chinese colour tools.

# thisplot 0.1.0

* initial version
