# Get used vars in a ggplot object

Get used vars in a ggplot object

## Usage

``` r
get_vars(p, reverse = FALSE, verbose = TRUE)
```

## Arguments

- p:

  A `ggplot` object.

- reverse:

  Whether to return unused vars. Default is `FALSE`.

- verbose:

  Whether to print the message. Default is `TRUE`.

## Examples

``` r
library(ggplot2)
p <- ggplot(
  data = mtcars,
  aes(x = mpg, y = wt, colour = cyl)
) +
  geom_point()
get_vars(p)
#> ℹ [2025-11-10 02:55:02] Vars_used: "mpg", "cyl", and "wt"
#> ℹ                       vars_notused: "disp", "hp", "drat", "qsec", "vs", "am", "gear", and "carb"
#> [1] "mpg" "cyl" "wt" 
get_vars(p, reverse = TRUE)
#> ℹ [2025-11-10 02:55:02] Vars_used: "mpg", "cyl", and "wt"
#> ℹ                       vars_notused: "disp", "hp", "drat", "qsec", "vs", "am", "gear", and "carb"
#> [1] "disp" "hp"   "drat" "qsec" "vs"   "am"   "gear" "carb"
```
