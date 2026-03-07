# Estimate heatmap render size

Estimate heatmap render size

## Usage

``` r
heatmap_rendersize(
  width,
  height,
  units,
  ha_top_list,
  ha_left,
  ha_right,
  ht_list,
  legend_list,
  flip
)
```

## Arguments

- width:

  Numeric vector of heatmap body widths. Interpretation depends on
  `flip`.

- height:

  Numeric vector of heatmap body heights. Interpretation depends on
  `flip`.

- units:

  Unit string for numeric-to-grid conversion (for example, `"in"`,
  `"cm"`, `"mm"`).

- ha_top_list:

  A list of top annotations (typically
  [`ComplexHeatmap::HeatmapAnnotation`](https://rdrr.io/pkg/ComplexHeatmap/man/HeatmapAnnotation.html)
  objects).

- ha_left:

  Optional left annotation.

- ha_right:

  Optional right annotation.

- ht_list:

  A
  [`ComplexHeatmap::Heatmap`](https://rdrr.io/pkg/ComplexHeatmap/man/Heatmap.html)
  or
  [`ComplexHeatmap::HeatmapList`](https://rdrr.io/pkg/ComplexHeatmap/man/HeatmapList.html)
  object.

- legend_list:

  A list containing legend objects; `NULL` entries are ignored.

- flip:

  Logical; when `TRUE`, width/height interpretation follows the flipped
  layout branch.

## Value

A list with numeric `width_sum` and `height_sum` in `units`.

## Examples

``` r
mat <- matrix(rnorm(100), nrow = 10)
ht <- ComplexHeatmap::Heatmap(mat, name = "expr")
size <- heatmap_rendersize(
  width = c(4),
  height = c(3),
  units = "in",
  ha_top_list = list(),
  ha_left = NULL,
  ha_right = NULL,
  ht_list = ht,
  legend_list = list(),
  flip = FALSE
)
size
#> $width_sum
#> [1] 6.854331
#> 
#> $height_sum
#> [1] 6.333333
#> 
```
