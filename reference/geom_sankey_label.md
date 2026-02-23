# geom_sankey_label

Creates centered labels or text in nodes of your sankey plot. Needs to
have the exact same aesthetics as the call to \`geom_sankey\` to work.

## Usage

``` r
geom_sankey_label(
  mapping = NULL,
  data = NULL,
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  space = NULL,
  type = "sankey",
  width = 0.1,
  inherit.aes = TRUE,
  ...
)

geom_sankey_text(
  mapping = NULL,
  data = NULL,
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  space = NULL,
  type = "sankey",
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

- type:

  Either \`sankey\` or \`alluvial\`.

- width:

  Width of nodes.

- inherit.aes:

  Should the geom inherit aesthetics.

- ...:

  Other arguments to be passed to the geom.

## Value

A ggplot layer.
