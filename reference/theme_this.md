# The default theme for scop plot function.

The default theme for scop plot function.

## Usage

``` r
theme_this(aspect.ratio = NULL, base_size = 12, ...)
```

## Arguments

- aspect.ratio:

  Aspect ratio of the panel.

- base_size:

  Base font size

- ...:

  Arguments passed to the
  [ggplot2::theme](https://ggplot2.tidyverse.org/reference/theme.html).

## Examples

``` r
library(ggplot2)
p <- ggplot(
  data = mtcars,
  aes(x = wt, y = mpg, colour = factor(cyl))
) +
  geom_point()
p + theme_this()
```
