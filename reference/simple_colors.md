# Simple random color selection

Randomly select a specified number of colors from ChineseColors or other
palettes.

## Usage

``` r
simple_colors(n = 10, palette = NULL)
```

## Arguments

- n:

  The number of colors to return. Default is `10`.

- palette:

  The name of the palette to use. If `NULL` (default), colors will be
  selected from ChineseColors. Otherwise, colors will be selected from
  the specified palette. Available palette names can be queried with
  [show_palettes](https://mengxu98.github.io/thisplot/reference/show_palettes.md).

## Value

A character vector of hexadecimal color codes.

## Examples

``` r
simple_colors()
#>  [1] "#1C2938" "#F2CE2B" "#E1C199" "#FDF371" "#C8B5B3" "#003371" "#1E131D"
#>  [8] "#E07B37" "#964D22" "#91828F"

show_palettes(simple_colors(n = 5))

#> [1] "1" "2" "3" "4" "5"

# Get colors from a specific palette
simple_colors(n = 10, palette = "Paired")
#>  [1] "#1F78B4" "#FDBF6F" "#33A02C" "#A6CEE3" "#E31A1C" "#FF7F00" "#6A3D9A"
#>  [8] "#FFFF99" "#B15928" "#B2DF8A"
simple_colors(n = 10, palette = "ChineseBlue")
#>  [1] "#1661AB" "#535164" "#126BAE" "#5698C3" "#454659" "#2376B7" "#1C2938"
#>  [8] "#003D74" "#C3D7DF" "#93D5DC"
simple_colors(n = 10, palette = "Spectral")
#>  [1] "#9E0142" "#ABDDA4" "#66C2A5" "#F46D43" "#D53E4F" "#FDAE61" "#FFFFBF"
#>  [8] "#E6F598" "#FEE08B" "#3288BD"
```
