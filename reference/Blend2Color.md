# Blend two colors using a specified mode

Blend two colors with alpha channels using one of several blending
modes: blend, average, screen, or multiply.

## Usage

``` r
Blend2Color(C1, C2, mode = "blend")
```

## Arguments

- C1:

  A list containing the first color RGB values and alpha channel.

- C2:

  A list containing the second color RGB values and alpha channel.

- mode:

  The blending mode to use. One of `"blend"`, `"average"`, `"screen"`,
  or `"multiply"`. Default is `"blend"`.

## Value

A list containing the blended RGB values and alpha channel.
