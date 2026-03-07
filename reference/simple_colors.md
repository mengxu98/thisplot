# Simple random color selection

Simple random color selection

## Usage

``` r
simple_colors(n = 10, palette = NULL)
```

## Arguments

- n:

  The number of colors to return. Default is `10`.

- palette:

  The name of the palette to use. Default is `NULL`, colors will be
  selected from ChineseColors. Otherwise, colors will be selected from
  the specified palette. Available palette names can be queried with
  [show_palettes](https://mengxu98.github.io/thisplot/reference/show_palettes.md).

## Value

A character vector of hexadecimal color codes.

## Examples

``` r
simple_colors()
#>  [1] "#CF929E" "#D4D3C1" "#513C20" "#36292F" "#BBA1CB" "#20A162" "#EB9A9A"
#>  [8] "#D11A2D" "#DAD4CB" "#F8C6B5"

show_palettes(simple_colors(n = 5))

#> [1] "1" "2" "3" "4" "5"

# Get colors from a specific palette
simple_colors(n = 10, palette = "Paired")
#>  [1] "#6A3D9A" "#A6CEE3" "#1F78B4" "#33A02C" "#B2DF8A" "#FFFF99" "#FF7F00"
#>  [8] "#FDBF6F" "#E31A1C" "#CAB2D6"
simple_colors(n = 10, palette = "ChineseBlue")
#>  [1] "#45465E" "#BCD4E7" "#06436F" "#134857" "#A2D2E2" "#4F64AE" "#1A2847"
#>  [8] "#213A70" "#1661AB" "#2177B8"
simple_colors(n = 10, palette = "Spectral")
#>  [1] "#F46D43" "#66C2A5" "#5E4FA2" "#9E0142" "#3288BD" "#E6F598" "#FEE08B"
#>  [8] "#ABDDA4" "#FFFFBF" "#D53E4F"
```
