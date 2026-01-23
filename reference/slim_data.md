# Slim unused data in the plot

Remove unused columns from the data in a ggplot or patchwork object.
This function keeps only the columns that are actually used in the plot
(e.g., in mappings, aesthetics, or facets), which can significantly
reduce the object size when the original data contains many unused
columns.

## Usage

``` r
slim_data(p)

# S3 method for class 'ggplot'
slim_data(p)

# S3 method for class 'patchwork'
slim_data(p)
```

## Arguments

- p:

  A `ggplot` object or a `patchwork` object.

## Value

A `ggplot` or `patchwork` object with unused data columns removed.

## Examples

``` r
library(ggplot2)
p <- ggplot(
  data = mtcars,
  aes(x = mpg, y = wt, colour = cyl)
) +
  geom_point()
object.size(p)
#> 368016 bytes
colnames(p$data)
#>  [1] "mpg"  "cyl"  "disp" "hp"   "drat" "wt"   "qsec" "vs"   "am"   "gear"
#> [11] "carb"

p_slim <- slim_data(p)
#> ℹ [2026-01-23 13:30:08] Vars_used: "mpg", "cyl", and "wt"
#> ℹ                       vars_notused: "disp", "hp", "drat", "qsec", "vs", "am", "gear", and "carb"
object.size(p_slim)
#> 364944 bytes
colnames(p_slim$data)
#> [1] "mpg" "cyl" "wt" 
```
