## R CMD check results

0 errors | 0 warnings | 1 note

* This updates the CRAN version 0.4.3 to version 0.4.6.
* Checked the built source tarball with R CMD check --as-cran on macOS arm64
  using R 4.5.3, including examples and the PDF manual.
* The note is "unable to verify current time" because the network time check
  was unavailable. No future file timestamps were reported.
* Remote CRAN incoming checks timed out; the completed local check used
  _R_CHECK_CRAN_INCOMING_REMOTE_=false. Current R-devel and final platform
  checks remain to be run on this candidate before submission.

## Changes

* New plotting and rasterization helpers, SVG and PNG color inversion, and
  fixes for SVG references, zero-weight network layouts and y-axis labels.
* Requires ggplot2 >= 4.0.0 for its public theme completion API and thisutils
  >= 0.5.0 for optional dependency checks without installing packages.
* ComplexHeatmap is optional; heatmap-specific helpers check for it when used.
