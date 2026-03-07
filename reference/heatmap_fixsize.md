# Compute fixed heatmap device size

Compute fixed heatmap device size

## Usage

``` r
heatmap_fixsize(
  width,
  width_sum,
  height,
  height_sum,
  units,
  ht_list,
  legend_list
)
```

## Arguments

- width:

  Optional user-provided target width. If `NULL`, width is estimated
  from the drawn heatmap layout.

- width_sum:

  Numeric baseline width used when heatmap body size is in `npc` units.

- height:

  Optional user-provided target height. If `NULL`, height is estimated
  from the drawn heatmap layout.

- height_sum:

  Numeric baseline height used when heatmap body size is in `npc` units.

- units:

  Output unit string passed to grid conversion helpers, such as `"in"`,
  `"cm"`, or `"mm"`.

- ht_list:

  A
  [`ComplexHeatmap::Heatmap`](https://rdrr.io/pkg/ComplexHeatmap/man/Heatmap.html)
  or
  [`ComplexHeatmap::HeatmapList`](https://rdrr.io/pkg/ComplexHeatmap/man/HeatmapList.html)
  object.

- legend_list:

  A list of
  [`ComplexHeatmap::Legend`](https://rdrr.io/pkg/ComplexHeatmap/man/Legend.html)
  objects.

## Value

A list with two converted units: `ht_width` and `ht_height`.

## Examples

``` r
mat <- matrix(rnorm(100), nrow = 10)
ht <- ComplexHeatmap::Heatmap(mat, name = "expr")
lgd <- list(ComplexHeatmap::Legend(title = "expr", at = c(-2, 0, 2)))
out <- heatmap_fixsize(
  width = NULL,
  width_sum = 6,
  height = NULL,
  height_sum = 4,
  units = "in",
  ht_list = ht,
  legend_list = lgd
)

out
#> $ht_width
#> [1] 6.33333333333333inches
#> 
#> $ht_height
#> [1] 6.33333333333333inches
#> 
```
