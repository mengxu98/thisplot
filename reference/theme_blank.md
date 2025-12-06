# Blank theme

This function creates a theme with all elements blank except for axis
lines and labels. It can optionally add coordinate axes in the plot.

## Usage

``` r
theme_blank(
  add_coord = TRUE,
  xlen_npc = 0.15,
  ylen_npc = 0.15,
  xlab = "",
  ylab = "",
  lab_size = 12,
  ...
)
```

## Arguments

- add_coord:

  Whether to add coordinate arrows. Default is `TRUE`.

- xlen_npc:

  The length of the x-axis arrow in "npc".

- ylen_npc:

  The length of the y-axis arrow in "npc".

- xlab:

  The label of the x-axis.

- ylab:

  The label of the y-axis.

- lab_size:

  The size of the axis labels.

- ...:

  Arguments passed to the
  [ggplot2::theme](https://ggplot2.tidyverse.org/reference/theme.html).

## Value

A list containing ggplot2 theme objects and annotation objects. If
`add_coord` is `TRUE`, returns a list with coordinate arrows; otherwise
returns a list with theme only.

## Examples

``` r
library(ggplot2)
p <- ggplot(mtcars, aes(x = wt, y = mpg, colour = factor(cyl))) +
  geom_point()
p + theme_blank()

p + theme_blank(xlab = "x-axis", ylab = "y-axis", lab_size = 16)
```
