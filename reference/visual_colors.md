# Visualize colors in HTML widget

Display a grid of color swatches with optional names or color codes.

## Usage

``` r
visual_colors(colors, names = NULL, num_per_row = 30, title = NULL)
```

## Arguments

- colors:

  A character vector of hex color codes.

- names:

  Optional. A character vector of names for each color. Default is
  `NULL`, which means hex color codes will be displayed. You can pass
  any labels (e.g., RGB values, custom names) via this parameter.

- num_per_row:

  Number of colors per row. Default is `30`.

- title:

  Optional title for the visualization. Default is `NULL`.

## Value

An HTML widget.

## Examples

``` r
# Visualize a simple color palette
visual_colors(
  colors = c("#FF0000", "#00FF00", "#0000FF"),
  names = c("Red", "Green", "Blue")
)

  

          
            Red
          
        
```

Green

Blue

visual_colors( colors = [c](https://rdrr.io/r/base/c.html)("#FF0000",
"#00FF00"), names = [c](https://rdrr.io/r/base/c.html)("(255, 0, 0)",
"(0, 255, 0)") )

[TABLE]

visual_colors(thisplot::[palette_list](https://mengxu98.github.io/thisplot/reference/palette_list.md)\$Paired)

[TABLE]

\# Use with ChineseColors cc \<-
[ChineseColors](https://mengxu98.github.io/thisplot/reference/ChineseColors.md)()
visual_colors( colors = cc\$blue\[1:60\], title = "Chinese Blue Colors"
)

Chinese Blue Colors

[TABLE]
