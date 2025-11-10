# Convert RGBA color to RGB with background

Convert an RGBA (Red, Green, Blue, Alpha) color to RGB by compositing it
with a background color based on the alpha channel.

## Usage

``` r
RGBA2RGB(RGBA, BackGround = c(1, 1, 1))
```

## Arguments

- RGBA:

  A list containing RGB values and alpha channel.

- BackGround:

  The background RGB color to composite with. Default is `c(1, 1, 1)`
  (white).

## Value

A numeric vector of RGB values.
