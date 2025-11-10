# Adjust graph layout to avoid node overlaps

Adjust the layout of a graph to prevent node overlaps by considering
node widths and heights.

## Usage

``` r
adjustlayout(graph, layout, width, height = 2, scale = 100, iter = 100)
```

## Arguments

- graph:

  An igraph graph object.

- layout:

  A matrix with two columns representing the initial layout coordinates.

- width:

  A numeric vector of node widths.

- height:

  The height constraint for nodes. Default is `2`.

- scale:

  The scaling factor for the layout. Default is `100`.

- iter:

  The number of iterations for the adjustment algorithm. Default is
  `100`.

## Value

A matrix with adjusted layout coordinates.
