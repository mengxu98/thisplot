# Make a long data frame for sankey plot

Prepares a 'wide' data frame into a format that \`geom_sankey\` or
\`geom_alluvial\` understands. Useful to show flows between dimensions
in dataset.

## Usage

``` r
make_long(.df, ..., value = NULL)
```

## Arguments

- .df:

  a data frame

- ...:

  unquoted columnnames of df that you want to include in the plot.

- value:

  if each row have a weight this weight could be kept by providing
  column name of weight.

## Value

a longer data frame
