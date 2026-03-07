# Normalize drawable objects to grobs

Normalize drawable objects to grobs

## Usage

``` r
normalize_drawable(obj)
```

## Arguments

- obj:

  A drawable object, such as a ggplot, patchwork, or grid grob.

## Value

A grid grob object. If the input is not drawable, returns a null grob.

## Examples

``` r
library(ggplot2)
p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
  ggplot2::geom_point()
g <- normalize_drawable(p)
p + g
```
