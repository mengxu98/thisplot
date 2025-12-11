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
  or Chinese), numbers, or hex codes. If NULL, using all Chinese colors.

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
#> name     rgb              hex       
#> #A6CEE3  (166, 206, 227)  #A6CEE3   
#> #1F78B4  (31, 120, 180)   #1F78B4   
#> #B2DF8A  (178, 223, 138)  #B2DF8A   
#> #33A02C  (51, 160, 44)    #33A02C   
#> #FDBF6F  (253, 191, 111)  #FDBF6F   
#> #FF7F00  (255, 127, 0)    #FF7F00   
#> #FB9A99  (251, 154, 153)  #FB9A99   
#> #E31A1C  (227, 26, 28)    #E31A1C   
#> #CAB2D6  (202, 178, 214)  #CAB2D6   
#> #6A3D9A  (106, 61, 154)   #6A3D9A   
#> #FFFF99  (255, 255, 153)  #FFFF99   
#> #B15928  (177, 89, 40)    #B15928   

get_colors("#FF7F00")
#> 
#> ── Found in: 
#> #FF7F00: "Paired" and "Set1"
#> name     rgb            hex       
#> #FF7F00  (255, 127, 0)  #FF7F00   

get_colors("pinlan")
#> 
#> ── Found in: 
#> #2B73AF: "ChineseSet128" and "ChineseBlue"
#> num  name    name_ch  rgb             hex      category  category_ch   
#> 44   pinlan  品蓝     (43, 115, 175)  #2B73AF  blue      蓝            
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

get_colors("cyan", palettes = "ChineseSet64")
#> 
#> ── Searching in palette: "ChineseSet64" 
#> 
#> ── Found in: 
#> #108B96: "ChineseSet64"
#> #1491A8: "ChineseSet64"
#> #0F95B0: "ChineseSet64"
#> #1E9EB3: "ChineseSet64"
#> #10AEC2: "ChineseSet64"
#> #0EB0C9: "ChineseSet64"
#> #29B7CB: "ChineseSet64"
#> num  name         name_ch  rgb             hex      category  category_ch   
#> 106  facui        法翠     (16, 139, 150)  #108B96  cyan      青            
#> 108  jianniaolan  樫鸟蓝   (20, 145, 168)  #1491A8  cyan      青            
#> 112  danfanlan    胆矾蓝   (15, 149, 176)  #0F95B0  cyan      青            
#> 113  cuilan       翠蓝     (30, 158, 179)  #1E9EB3  cyan      青            
#> 120  dianzilan    甸子蓝   (16, 174, 194)  #10AEC2  cyan      青            
#> 122  kongquelan   孔雀蓝   (14, 176, 201)  #0EB0C9  cyan      青            
#> 125  weilan       蔚蓝     (41, 183, 203)  #29B7CB  cyan      青            
```
