# Blends a list of colors using the specified blend mode

Blends a list of colors using the specified blend mode

## Usage

``` r
blendcolors(colors, mode = c("blend", "average", "screen", "multiply"))
```

## Arguments

- colors:

  Color vectors.

- mode:

  Blend mode. One of `"blend"`, `"average"`, `"screen"`, or
  `"multiply"`.

## Examples

``` r
blend <- c(
  "red",
  "green",
  blendcolors(c("red", "green"),
    mode = "blend"
  )
)
average <- c(
  "red",
  "green",
  blendcolors(c("red", "green"),
    mode = "average"
  )
)
screen <- c(
  "red",
  "green",
  blendcolors(c("red", "green"),
    mode = "screen"
  )
)
multiply <- c(
  "red",
  "green",
  blendcolors(c("red", "green"),
    mode = "multiply"
  )
)
show_palettes(
  list(
    "blend" = blend,
    "average" = average,
    "screen" = screen,
    "multiply" = multiply
  )
)

#> [1] "blend"    "average"  "screen"   "multiply"
```
