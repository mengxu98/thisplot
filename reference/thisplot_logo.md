# The logo of thisplot

The thisplot logo, using ASCII or Unicode characters Use
[cli::ansi_strip](https://cli.r-lib.org/reference/ansi_strip.html) to
get rid of the colors.

## Usage

``` r
thisplot_logo(unicode = cli::is_utf8_output())
```

## Arguments

- unicode:

  Unicode symbols on UTF-8 platforms. Default is
  [cli::is_utf8_output](https://cli.r-lib.org/reference/is_utf8_output.html).

## References

<https://github.com/tidyverse/tidyverse/blob/main/R/logo.R>

## Examples

``` r
thisplot_logo()
#>           ⬢          .        ⬡             ⬢     .
#>              __  __    _              __       __
#>             / /_/ /_  (_)_____ ____  / /____  / /_
#>            / __/ __ ./ // ___// __ ./ // __ ./ __/
#>           / /_/ / / / /(__  )/ /_/ / // /_/ / /_
#>           .__/_/ /_/_//____// .___/_/ .____/.__/
#>                            /_/
#>       ⬡               ⬢      .        ⬡          ⬢
```
