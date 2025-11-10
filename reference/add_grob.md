# Add a grob to a gtable

Add a grob to a gtable at a specified position (top, bottom, left, or
right).

## Usage

``` r
add_grob(
  gtable,
  grob,
  position = c("top", "bottom", "left", "right", "none"),
  space = NULL,
  clip = "on"
)
```

## Arguments

- gtable:

  A gtable object.

- grob:

  A grob or gtable object to add.

- position:

  The position to add the grob. One of `"top"`, `"bottom"`, `"left"`,
  `"right"`, or `"none"`.

- space:

  The space to allocate for the grob. If `NULL`, will be calculated
  automatically.

- clip:

  The clipping mode. Default is `"on"`.

## Value

A gtable object with the grob added.
