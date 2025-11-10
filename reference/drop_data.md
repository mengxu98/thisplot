# Drop unused data in the plot

Drop unused data points from a ggplot or patchwork object while
preserving the plot structure. This function keeps only a single row of
data for each unique combination of used variables, which can
significantly reduce the object size when the original data contains
many rows that are not displayed in the plot (e.g., due to scale limits
or filtering).

## Usage

``` r
drop_data(p)

# S3 method for class 'ggplot'
drop_data(p)

# S3 method for class 'patchwork'
drop_data(p)

# Default S3 method
drop_data(p)
```

## Arguments

- p:

  A `ggplot` object or a `patchwork` object.

## Value

A `ggplot` or `patchwork` object with unused data points removed.

## Examples

``` r
library(ggplot2)
library(patchwork)
p <- ggplot(
  data = mtcars,
  aes(x = mpg, y = wt, colour = cyl)
) +
  geom_point() +
  scale_x_continuous(limits = c(10, 30)) +
  scale_y_continuous(limits = c(1, 6))
object.size(p)
#> 368016 bytes

p_drop <- drop_data(p)
object.size(p_drop)
#> 362968 bytes

p / p_drop
#> Warning: Removed 4 rows containing missing values or values outside the scale range
#> (`geom_point()`).
```
