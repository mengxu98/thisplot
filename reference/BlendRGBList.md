# Blend a list of colors

Blend multiple colors with alpha channels into a single color using a
specified blending mode.

## Usage

``` r
BlendRGBList(Clist, mode = "blend", RGB_BackGround = c(1, 1, 1))
```

## Arguments

- Clist:

  A list of colors, where each color is a list containing RGB values and
  alpha channel.

- mode:

  The blending mode to use. One of `"blend"`, `"average"`, `"screen"`,
  or `"multiply"`. Default is `"blend"`.

- RGB_BackGround:

  The background RGB color to composite with. Default is `c(1, 1, 1)`
  (white).

## Value

A numeric vector of RGB values.
