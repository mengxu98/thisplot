# Build HeatmapAnnotation with safe parameter merge

Build HeatmapAnnotation with safe parameter merge

## Usage

``` r
build_heatmap_annotation(
  annotations,
  which,
  show_annotation_name = TRUE,
  annotation_name_side = NULL,
  border = NULL,
  params = NULL
)
```

## Arguments

- annotations:

  Named list of annotation components (for example, `anno_simple`,
  `anno_block`, `anno_customize`).

- which:

  Annotation direction (`"row"` or `"column"`).

- show_annotation_name:

  Whether to show annotation names.

- annotation_name_side:

  Side for annotation names.

- border:

  Whether to draw a rectangle border around the block.

- params:

  Additional user parameters; duplicated keys are ignored if already set
  explicitly.

## Value

A
[ComplexHeatmap::HeatmapAnnotation](https://rdrr.io/pkg/ComplexHeatmap/man/HeatmapAnnotation.html)
object.

## Examples

``` r
anno <- list(
  group = ComplexHeatmap::anno_simple(
    x = c("A", "B", "A"),
    col = c(A = "#1b9e77", B = "#d95f02"),
    which = "column"
  )
)
ha <- build_heatmap_annotation(
  annotations = anno,
  which = "column",
  show_annotation_name = TRUE,
  annotation_name_side = "left",
  params = list(gap = grid::unit(1, "mm"))
)
ha
#> A HeatmapAnnotation object with 1 annotation
#>   name: heatmap_annotation_0 
#>   position: column 
#>   items: 3 
#>   width: 1npc 
#>   height: 5mm 
#>   this object is subsettable
#>   11.8246333333333mm extension on the left 
#> 
#>   name annotation_type color_mapping height
#>  group   anno_simple()                  5mm
```
