# ***thisplot*** <img src="man/figures/logo.svg" align="right" width="120"/>

<!-- badges: start -->

[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/thisplot)](https://CRAN.R-project.org/package=thisplot) [![develop-ver](https://img.shields.io/github/r-package/v/mengxu98/thisplot?label=develop-ver)](https://github.com/mengxu98/thisplot/) [![R-CMD-check](https://github.com/mengxu98/thisplot/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mengxu98/thisplot/actions/workflows/R-CMD-check.yaml) [![test-coverage](https://github.com/mengxu98/thisplot/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/mengxu98/thisplot/actions/workflows/test-coverage.yaml) [![pkgdown](https://github.com/mengxu98/thisplot/actions/workflows/pkgdown.yaml/badge.svg)](https://mengxu98.github.io/thisplot/reference/index.html) [![RStudio CRAN mirror downloads](https://cranlogs.r-pkg.org/badges/grand-total/thisplot)](https://CRAN.R-project.org/package=thisplot)

<!-- badges: end -->

## **Introduction**

[thisplot](https://mengxu98.github.io/thisplot/) is an R package providing utility functions for data visualization and plotting. It includes tools for color manipulation (blending, conversion, palettes), plot customization (themes, grob operations, patchwork building), panel size control, data optimization for plots, and layout adjustments. Designed to enhance workflows with ggplot2, patchwork, and ComplexHeatmap.

## **Chinese traditional colors**

The package includes a comprehensive Chinese traditional color system with 1058 representative colors. You can access colors by name (pinyin or Chinese), create color palettes, and visualize color collections.

Example usage:

```r
library(thisplot)
cc <- ChineseColors()
cc$visual_colors(
  num_per_row = 30,
  title = "Chinese traditional colors",
  name_type = "chinese"
)
```

<img src="man/figures/ChineseColors.png" align="center"/>

```r
show_palettes(
  palettes = get_chinese_palettes()
)
```

<img src="man/figures/ChineseColors_palettes.svg" align="center" width="700"/>

## **Installation**

Install CRAN version:

``` r
install.packages("thisplot")
# or
if (!require("pak", quietly = TRUE)) {
  install.packages("pak")
}
pak::pak("thisplot")
```

Install development version from [GitHub](https://github.com/mengxu98/thisplot) use [pak](https://github.com/r-lib/pak):

``` r
if (!require("pak", quietly = TRUE)) {
  install.packages("pak")
}
pak::pak("mengxu98/thisplot")
```

## **Usage**

Please reference [here](https://mengxu98.github.io/thisplot/reference/index.html).
