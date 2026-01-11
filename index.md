# **thisplot**

## **Introduction**

[thisplot](https://mengxu98.github.io/thisplot/) is an *R* package
providing utility functions for data visualization and plotting. It
includes tools for color manipulation (blending, conversion, palettes),
plot customization (themes, grob operations, patchwork building), panel
size control, data optimization for plots, and layout adjustments.
Designed to enhance workflows with
[ggplot2](https://github.com/tidyverse/ggplot2),
[patchwork](https://github.com/thomasp85/patchwork), and
[ComplexHeatmap](https://github.com/jokergoo/ComplexHeatmap).

## **Chinese traditional colors**

[thisplot](https://mengxu98.github.io/thisplot/) provides a
comprehensive *Chinese traditional color* system with **1058**
representative colors. Use
[`ChineseColors()`](https://mengxu98.github.io/thisplot/reference/ChineseColors.md)
to create a color object, access colors by name (pinyin or Chinese),
visualize the collection with
[`visual_colors()`](https://mengxu98.github.io/thisplot/reference/visual_colors.md),
and retrieve specific palettes using
[`get_colors()`](https://mengxu98.github.io/thisplot/reference/get_colors.md).

Example usage:

``` r
library(thisplot)
cc <- ChineseColors()
cc
#> 
#> ── Chinese Traditional Colors System
#> 
#> ── Total 1058 colors
#> • blue: 92 colors
#> • cyan: 51 colors
#> • gray_brown: 323 colors
#> • green: 123 colors
#> • orange: 92 colors
#> • purple: 95 colors
#> • red: 181 colors
#> • yellow: 101 colors
#> 
#> ── Methods:
#> • visual_colors(loc_range, num_per_row, title, name_type)
#> 
#> ── See also:
#> • [get_colors()] for searching colors
```

``` r
cc$visual_colors(
  num_per_row = 30,
  title = "Chinese traditional colors",
  name_type = "chinese"
)
```

Chinese traditional colors

[TABLE]

``` r
get_colors("Paired")
#> 
#> ── Found palette: "Paired"
#>       name             rgb     hex
#> 1  #A6CEE3 (166, 206, 227) #A6CEE3
#> 2  #1F78B4  (31, 120, 180) #1F78B4
#> 3  #B2DF8A (178, 223, 138) #B2DF8A
#> 4  #33A02C   (51, 160, 44) #33A02C
#> 5  #FDBF6F (253, 191, 111) #FDBF6F
#> 6  #FF7F00   (255, 127, 0) #FF7F00
#> 7  #FB9A99 (251, 154, 153) #FB9A99
#> 8  #E31A1C   (227, 26, 28) #E31A1C
#> 9  #CAB2D6 (202, 178, 214) #CAB2D6
#> 10 #6A3D9A  (106, 61, 154) #6A3D9A
#> 11 #FFFF99 (255, 255, 153) #FFFF99
#> 12 #B15928   (177, 89, 40) #B15928
```

``` r
get_colors("cyan", palettes = "ChineseSet64")
#> 
#> ── Searching in palette: "ChineseSet64"
#> 
#> ── Found in:
#> #108B96: "ChineseSet64"
#> #1491A8: "ChineseSet64"
#> #0F95B0: "ChineseSet64"
#> #1E9EB3: "ChineseSet64"
#> #10AEC2: "ChineseSet64"
#> #0EB0C9: "ChineseSet64"
#> #29B7CB: "ChineseSet64"
#>     num        name name_ch            rgb     hex category category_ch
#> 106 106       facui    法翠 (16, 139, 150) #108B96     cyan          青
#> 108 108 jianniaolan  樫鸟蓝 (20, 145, 168) #1491A8     cyan          青
#> 112 112   danfanlan  胆矾蓝 (15, 149, 176) #0F95B0     cyan          青
#> 113 113      cuilan    翠蓝 (30, 158, 179) #1E9EB3     cyan          青
#> 120 120   dianzilan  甸子蓝 (16, 174, 194) #10AEC2     cyan          青
#> 122 122  kongquelan  孔雀蓝 (14, 176, 201) #0EB0C9     cyan          青
#> 125 125      weilan    蔚蓝 (41, 183, 203) #29B7CB     cyan          青
```

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

Install development version from
[GitHub](https://github.com/mengxu98/thisplot) use
[pak](https://github.com/r-lib/pak):

``` r
if (!require("pak", quietly = TRUE)) {
  install.packages("pak")
}
pak::pak("mengxu98/thisplot")
```

## **Usage**

Please reference
[here](https://mengxu98.github.io/thisplot/reference/index.html).
