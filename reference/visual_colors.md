# Visualize colors in HTML format

Display a grid of color swatches with optional names or color codes.

## Usage

``` r
visual_colors(
  colors,
  names = NULL,
  num_per_row = 30,
  title = NULL,
  rgb = NULL,
  hex = NULL
)
```

## Arguments

- colors:

  A character vector of color codes (hex format, e.g., "#FF0000").

- names:

  Optional. A character vector of names for each color. Default is
  `NULL`, which means color codes will be displayed.

- num_per_row:

  Number of colors per row. Default is `30`.

- title:

  Optional title for the visualization. Default is `NULL`.

- rgb:

  Optional. A character vector of RGB values (e.g., "(255, 0, 0)"). If
  provided and `names` is `NULL`, RGB values will be displayed as names.

- hex:

  Optional. A logical or character vector. If `TRUE` and `names` is
  `NULL`, hex codes will be displayed as names. If a character vector is
  provided, it will be used as names.

## Value

An HTML widget that can be displayed with
[htmltools::browsable](https://rstudio.github.io/htmltools/reference/browsable.html).

## Examples

``` r
# Visualize a simple color palette
colors <- c("#FF0000", "#00FF00", "#0000FF")
widget <- visual_colors(colors, names = c("Red", "Green", "Blue"))
htmltools::browsable(widget)

  

          
            Red
          
        
```

Green

Blue

\# Visualize a built-in palette widget2 \<-
visual_colors(thisplot::[palette_list](https://mengxu98.github.io/thisplot/reference/palette_list.md)\$Paired)
htmltools::[browsable](https://rstudio.github.io/htmltools/reference/browsable.html)(widget2)

[TABLE]

\# Use with ChineseColors cc \<-
[ChineseColors](https://mengxu98.github.io/thisplot/reference/ChineseColors.md)()
widget3 \<- visual_colors( colors = cc\$blue\[1:60\], title = "Chinese
Blue Colors" )
htmltools::[browsable](https://rstudio.github.io/htmltools/reference/browsable.html)(widget3)

Chinese Blue Colors

[TABLE]
