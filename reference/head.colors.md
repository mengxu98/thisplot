# Return the first part of a colors object

Returns the first part of a colors object, similar to
[`head()`](https://rdrr.io/r/utils/head.html) for data frames.

## Usage

``` r
# S3 method for class 'colors'
head(x, n = 6L, ...)
```

## Arguments

- x:

  A colors object (data frame with color information).

- n:

  Number of rows to return. Default is `6`.

- ...:

  Additional arguments passed to
  [`head()`](https://rdrr.io/r/utils/head.html).

## Value

A colors object with the first `n` rows.

## Examples

``` r
head(get_colors())
#> num  name       name_ch  rgb           hex      category  category_ch   
#> 1    ganglan    钢蓝     (15, 20, 35)  #0F1423  blue      蓝            
#> 2    yanhanlan  燕颔蓝   (19, 24, 36)  #131824  blue      蓝            
#> 3    anlan      暗蓝     (16, 31, 48)  #101F30  blue      蓝            
#> 4    gangqing   钢青     (20, 35, 52)  #142334  blue      蓝            
#> 5    qilin      骐驎     (18, 38, 79)  #12264F  blue      蓝            
#> 6    gelan      鸽蓝     (28, 41, 56)  #1C2938  blue      蓝            

head(get_colors(), n = 10)
#> num  name        name_ch  rgb           hex      category  category_ch   
#> 1    ganglan     钢蓝     (15, 20, 35)  #0F1423  blue      蓝            
#> 2    yanhanlan   燕颔蓝   (19, 24, 36)  #131824  blue      蓝            
#> 3    anlan       暗蓝     (16, 31, 48)  #101F30  blue      蓝            
#> 4    gangqing    钢青     (20, 35, 52)  #142334  blue      蓝            
#> 5    qilin       骐驎     (18, 38, 79)  #12264F  blue      蓝            
#> 6    gelan       鸽蓝     (28, 41, 56)  #1C2938  blue      蓝            
#> 7    shenhuilan  深灰蓝   (19, 44, 51)  #132C33  blue      蓝            
#> 8    huaqing     花青     (26, 40, 71)  #1A2847  blue      蓝            
#> 9    dishiqing   帝释青   (0, 52, 96)   #003460  blue      蓝            
#> 10   futouqing   佛头青   (25, 50, 95)  #19325F  blue      蓝            
```
