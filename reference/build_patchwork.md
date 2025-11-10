# Build a patchwork gtable

Build a gtable from a patchwork object by arranging multiple plots
according to the layout specification.

## Usage

``` r
build_patchwork(
  x,
  guides = "auto",
  table_rows = 18,
  table_cols = 15,
  panel_row = 10,
  panel_col = 8
)
```

## Arguments

- x:

  A patchwork object.

- guides:

  How to handle guides. Default is `"auto"`.

- table_rows:

  The number of rows in the table grid. Default is `18`.

- table_cols:

  The number of columns in the table grid. Default is `15`.

- panel_row:

  The row index for panels. Default is `10`.

- panel_col:

  The column index for panels. Default is `8`.

## Value

A gtable object.
