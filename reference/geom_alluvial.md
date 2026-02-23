# geom_alluvial

Creates an alluvial plot which visualize flows between nodes. Each
observation needs to have a \`x\` aesthetic as well as a \`next_x\`
column which declares where that observation should flow. Also each
observation should have a \`node\` and a \`next_node\` aesthetic which
provide information about which group in the y-direction.

## Usage

``` r
geom_alluvial(
  mapping = NULL,
  data = NULL,
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  space = 0,
  width = 0.1,
  smooth = 8,
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

- smooth:

  How much smooth should the curve have? More means steeper curve.

- inherit.aes:

  Should the geom inherit aesthetics.

- ...:

  Other arguments to be passed to the geom.

## Value

A ggplot layer.
