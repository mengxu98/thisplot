# Convert a color with specified alpha level

Convert a color with specified alpha level

## Usage

``` r
adjcolors(colors, alpha)
```

## Arguments

- colors:

  Color vectors.

- alpha:

  Alpha level in `[0,1]`.

## Value

A character vector of hexadecimal color codes with the specified alpha
level.

## Examples

``` r
colors <- c("red", "blue", "green")
adjcolors(colors, 0.5)
#>        V1        V2        V3 
#> "#FF8080" "#8080FF" "#80FF80" 
ggplot2::alpha(colors, 0.5)
#> [1] "#FF000080" "#0000FF80" "#00FF0080"

show_palettes(
  list(
    "raw" = colors,
    "adjcolors" = adjcolors(colors, 0.5),
    "ggplot2::alpha" = ggplot2::alpha(colors, 0.5)
  )
)

#> [1] "raw"            "adjcolors"      "ggplot2::alpha"
```
