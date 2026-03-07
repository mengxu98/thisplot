# Build block panel function

Build block panel function

## Usage

``` r
annotation_block_graphics(subplot, name, border = TRUE)
```

## Arguments

- subplot:

  A single drawable subplot object.

- name:

  A name assigned to the generated grob.

- border:

  Whether to draw a rectangle border around the block.

## Value

A function with signature `(index, levels)` suitable for `panel_fun` in
[ComplexHeatmap::anno_block](https://rdrr.io/pkg/ComplexHeatmap/man/anno_block.html).

## Examples

``` r
library(ggplot2)
p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
  ggplot2::geom_point()
panel_fun <- annotation_block_graphics(
  subplot = p, name = "demo-block"
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
