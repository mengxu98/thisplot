# geom_alluvial_label

Creates centered labels or text in nodes of your alluvial plot. Needs to
have the exact same aesthetics as the call to \`geom_alluvial\` to work.

## Usage

``` r
geom_alluvial_text(
  mapping = NULL,
  data = NULL,
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  space = 0,
  width = 0.1,
  inherit.aes = TRUE,
  ...
)

geom_alluvial_label(
  mapping = NULL,
  data = NULL,
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  space = 0,
  width = 0.1,
  inherit.aes = TRUE,
  ...
)
```

## Arguments

- mapping:

  Provide you own mapping. Both x and y need to be numeric.

- data:

  Provide you own data.

- position:

  Change position.

- na.rm:

  Remove missing values.

- show.legend:

  Show legend in plot.

- space:

  Space between nodes in the y-direction.

- width:

  Width of nodes.

- inherit.aes:

  Should the geom inherit aesthetics.

- ...:

  Other arguments to be passed to the geom.

## Value

A ggplot layer.

## Details

Other important arguments are; \`space\` which provides the space
between nodes in the y-direction; \`shift\` which shifts nodes in the
y-direction.
