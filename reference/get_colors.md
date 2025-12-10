# Get colors from Chinese colors dataset or palettes

Search for colors in the Chinese colors dataset and all available
palettes. This function can search by palette names, color names (pinyin
or Chinese), numbers, or hex codes. It automatically searches in all
palettes and reports which palette(s) contain the found colors.

## Usage

``` r
get_colors(..., palettes = NULL)
```

## Arguments

- ...:

  One or more search values. Can be palette names, color names (pinyin
  or Chinese), numbers, or hex codes.

- palettes:

  Optional. A named list of palettes to search in. If `NULL` (default),
  searches in all available palettes.

## Value

A data frame with class `colors` containing matching color information.
The result is automatically printed using
[`print.colors()`](https://mengxu98.github.io/thisplot/reference/print.colors.md).

## See also

[chinese_colors](https://mengxu98.github.io/thisplot/reference/chinese_colors.md)
for the dataset of Chinese traditional colors.
[get_chinese_palettes](https://mengxu98.github.io/thisplot/reference/get_chinese_palettes.md)
for getting Chinese color palettes.
[ChineseColors](https://mengxu98.github.io/thisplot/reference/ChineseColors.md)
for the ChineseColors object.

## Examples

``` r
get_colors("Paired")
#> 
#> ── Found palette: "Paired" 
#> num  name  name_ch  rgb  hex      category  category_ch   
#> NA   NA    NA       NA   #A6CEE3  NA        NA            
#> NA   NA    NA       NA   #1F78B4  NA        NA            
#> NA   NA    NA       NA   #B2DF8A  NA        NA            
#> NA   NA    NA       NA   #33A02C  NA        NA            
#> NA   NA    NA       NA   #FDBF6F  NA        NA            
#> NA   NA    NA       NA   #FF7F00  NA        NA            
#> NA   NA    NA       NA   #FB9A99  NA        NA            
#> NA   NA    NA       NA   #E31A1C  NA        NA            
#> NA   NA    NA       NA   #CAB2D6  NA        NA            
#> NA   NA    NA       NA   #6A3D9A  NA        NA            
#> NA   NA    NA       NA   #FFFF99  NA        NA            
#> NA   NA    NA       NA   #B15928  NA        NA            

get_colors("pinlan")
#> Error in get_colors("pinlan"): No matching palettes found for: "pinlan". Available palettes include:
#> "BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral",
#> "Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2", "Set3",
#> "Blues", …, "ChineseRed", and "ChineseYellow". Use
#> `show_palettes(return_palettes = TRUE)` to see all available palettes.
get_colors(44)
#> 
#> ── Found in: 
#> #2B73AF: "ChineseSet128" and "ChineseBlue"
#> num  name    name_ch  rgb             hex      category  category_ch   
#> 44   pinlan  品蓝     (43, 115, 175)  #2B73AF  blue      蓝            
get_colors("#2B73AF")
#> 
#> ── Found in: 
#> #2B73AF: "ChineseSet128" and "ChineseBlue"
#> num  name    name_ch  rgb             hex      category  category_ch   
#> 44   pinlan  品蓝     (43, 115, 175)  #2B73AF  blue      蓝            

get_colors("cyan")
#> Error in get_colors("cyan"): No matching palettes found for: "cyan". Available palettes include:
#> "BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral",
#> "Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2", "Set3",
#> "Blues", …, "ChineseRed", and "ChineseYellow". Use
#> `show_palettes(return_palettes = TRUE)` to see all available palettes.
```
