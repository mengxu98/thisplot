# Build block fill panel function

Build block fill panel function

## Usage

``` r
annotation_block_fill_graphics(
  levels,
  palette = NULL,
  palcolor = NULL,
  fill_values = NULL,
  border = TRUE
)
```

## Arguments

- levels:

  Character/factor levels used as keys for fill mapping.

- palette:

  Palette name. All available palette names can be queried with
  [show_palettes](https://mengxu98.github.io/thisplot/reference/show_palettes.md).

- palcolor:

  Custom colors used to create a color palette.

- fill_values:

  Optional named fill vector. Names should match `levels`.

- border:

  Whether to draw block border.

## Value

A function with signature `(index, levels)` suitable for `panel_fun` in
[ComplexHeatmap::anno_block](https://rdrr.io/pkg/ComplexHeatmap/man/anno_block.html).

## Examples

``` r
library(ggplot2)
lv <- c("A", "B", "C")
panel_fun <- annotation_block_fill_graphics(
  levels = lv,
  fill_values = c(A = "#1b9e77", B = "#d95f02", C = "#7570b3")
)
ComplexHeatmap::anno_block(panel_fun = panel_fun)
#> An AnnotationFunction object
#>   function: anno_block()
#>   position: column 
#>   items: NA 
#>   width: 1npc 
#>   height: 5mm 
#>   imported variable: labels, labels_gp, labels_offset, labels_rot, gp, panel_fun, which, labels_just, align_to 
#>   this object is subsettable
```
