## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new release.

* This patch release restores `ComplexHeatmap` to `Suggests` because it is
  required only by heatmap-specific helpers. Those helpers now check for the
  optional package when called, and their examples run conditionally when it is
  available.
