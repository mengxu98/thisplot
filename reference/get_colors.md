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

get_colors("cyan")
#> 
#> ── Found in: 
#> #29B7CB: "ChineseSet16", "ChineseSet32", "ChineseSet64", "ChineseSet128", and
#> "ChineseCyan"
#> #108B96: "ChineseSet32", "ChineseSet64", "ChineseSet128", and "ChineseCyan"
#> #1491A8: "ChineseSet64", "ChineseSet128", and "ChineseCyan"
#> #0F95B0: "ChineseSet64", "ChineseSet128", and "ChineseCyan"
#> #1E9EB3: "ChineseSet64", "ChineseSet128", and "ChineseCyan"
#> #10AEC2: "ChineseSet64", "ChineseSet128", and "ChineseCyan"
#> #0EB0C9: "ChineseSet64", "ChineseSet128", and "ChineseCyan"
#> #006D87: "ChineseSet128" and "ChineseCyan"
#> #32788A: "ChineseSet128" and "ChineseCyan"
#> #3B818C: "ChineseSet128" and "ChineseCyan"
#> #2BBABE: "ChineseSet128" and "ChineseCyan"
#> #48C0A3: "ChineseSet128" and "ChineseCyan"
#> #51C4D3: "ChineseSet128" and "ChineseCyan"
#> #13393E: "ChineseCyan"
#> #284852: "ChineseCyan"
#> #424C50: "ChineseCyan"
#> #3B5554: "ChineseCyan"
#> #41555D: "ChineseCyan"
#> #426666: "ChineseCyan"
#> #226B68: "ChineseCyan"
#> #007175: "ChineseCyan"
#> #547689: "ChineseCyan"
#> #6B7D73: "ChineseCyan"
#> #3D8E86: "ChineseCyan"
#> #648E93: "ChineseCyan"
#> #668F8B: "ChineseCyan"
#> #509296: "ChineseCyan"
#> #7397AB: "ChineseCyan"
#> #5DA39D: "ChineseCyan"
#> #869D9D: "ChineseCyan"
#> #5AA4AE: "ChineseCyan"
#> #7F9FAF: "ChineseCyan"
#> #80A492: "ChineseCyan"
#> #6CA8AF: "ChineseCyan"
#> #7CABB1: "ChineseCyan"
#> #88ADA6: "ChineseCyan"
#> #98B6C2: "ChineseCyan"
#> #57C3C2: "ChineseCyan"
#> #99BCAC: "ChineseCyan"
#> #88BFB8: "ChineseCyan"
#> #87C0CA: "ChineseCyan"
#> #A4C9CC: "ChineseCyan"
#> #BACAC6: "ChineseCyan"
#> #BBCDC5: "ChineseCyan"
#> #B1D5C8: "ChineseCyan"
#> #25F8CB: "ChineseCyan"
#> #C0EBD7: "ChineseCyan"
#> #D5EBE1: "ChineseCyan"
#> #E0EEE8: "ChineseCyan"
#> #E0F0E9: "ChineseCyan"
#> #EEF7F2: "ChineseCyan"
#> num  name         name_ch  rgb              hex      category  category_ch   
#> 93   luozidai     螺子黛   (19, 57, 62)     #13393E  cyan      青            
#> 94   qinggua      青緺     (40, 72, 82)     #284852  cyan      青            
#> 95   yaqing       鸦青     (66, 76, 80)     #424C50  cyan      青            
#> 96   daise        黛色     (59, 85, 84)     #3B5554  cyan      青            
#> 97   an           黯       (65, 85, 93)     #41555D  cyan      青            
#> 98   dailv        黛绿     (66, 102, 102)   #426666  cyan      青            
#> 99   daose        䌦色     (34, 107, 104)   #226B68  cyan      青            
#> 100  ruancui      软翠     (0, 109, 135)    #006D87  cyan      青            
#> 101  qingwo       青雘     (0, 113, 117)    #007175  cyan      青            
#> 102  yushiqing    鱼师青   (50, 120, 138)   #32788A  cyan      青            
#> 103  taishiqing   太师青   (84, 118, 137)   #547689  cyan      青            
#> 104  qingtinglan  蜻蜓蓝   (59, 129, 140)   #3B818C  cyan      青            
#> 105  qianshancui  千山翠   (107, 125, 115)  #6B7D73  cyan      青            
#> 106  facui        法翠     (16, 139, 150)   #108B96  cyan      青            
#> 107  tongqing     铜青     (61, 142, 134)   #3D8E86  cyan      青            
#> 108  jianniaolan  樫鸟蓝   (20, 145, 168)   #1491A8  cyan      青            
#> 109  wanbolan     晚波蓝   (100, 142, 147)  #648E93  cyan      青            
#> 110  kongqing     空青     (102, 143, 139)  #668F8B  cyan      青            
#> 111  bianqing     扁青     (80, 146, 150)   #509296  cyan      青            
#> 112  danfanlan    胆矾蓝   (15, 149, 176)   #0F95B0  cyan      青            
#> 113  cuilan       翠蓝     (30, 158, 179)   #1E9EB3  cyan      青            
#> 114  canghei      苍黑     (115, 151, 171)  #7397AB  cyan      青            
#> 115  erlv         二绿     (93, 163, 157)   #5DA39D  cyan      青            
#> 116  xiakeqing    虾壳青   (134, 157, 157)  #869D9D  cyan      青            
#> 117  tianshuibi   天水碧   (90, 164, 174)   #5AA4AE  cyan      青            
#> 118  zhuyue       竹月     (127, 159, 175)  #7F9FAF  cyan      青            
#> 119  piaobi       缥碧     (128, 164, 146)  #80A492  cyan      青            
#> 120  dianzilan    甸子蓝   (16, 174, 194)   #10AEC2  cyan      青            
#> 121  zhengqing    正青     (108, 168, 175)  #6CA8AF  cyan      青            
#> 122  kongquelan   孔雀蓝   (14, 176, 201)   #0EB0C9  cyan      青            
#> 123  shanlan      闪蓝     (124, 171, 177)  #7CABB1  cyan      青            
#> 124  shuise       水色     (136, 173, 166)  #88ADA6  cyan      青            
#> 125  weilan       蔚蓝     (41, 183, 203)   #29B7CB  cyan      青            
#> 126  songshi      松石     (43, 186, 190)   #2BBABE  cyan      青            
#> 127  qingbi       青碧     (72, 192, 163)   #48C0A3  cyan      青            
#> 128  baiqing      白青     (152, 182, 194)  #98B6C2  cyan      青            
#> 129  shilv        石绿     (87, 195, 194)   #57C3C2  cyan      青            
#> 130  canglang     苍筤     (153, 188, 172)  #99BCAC  cyan      青            
#> 131  pubulan      瀑布蓝   (81, 196, 211)   #51C4D3  cyan      青            
#> 132  zongjie      總犗     (136, 191, 184)  #88BFB8  cyan      青            
#> 133  xizi         西子     (135, 192, 202)  #87C0CA  cyan      青            
#> 134  jingtian     井天     (164, 201, 204)  #A4C9CC  cyan      青            
#> 135  laoyin       老银     (186, 202, 198)  #BACAC6  cyan      青            
#> 136  xieqing      蟹青     (187, 205, 197)  #BBCDC5  cyan      青            
#> 137  canglang     沧浪     (177, 213, 200)  #B1D5C8  cyan      青            
#> 138  hulv         湖绿     (37, 248, 203)   #25F8CB  cyan      青            
#> 139  qingbai      青白     (192, 235, 215)  #C0EBD7  cyan      青            
#> 140  tianpiao     天缥     (213, 235, 225)  #D5EBE1  cyan      青            
#> 141  yaluanqing   鸭卵青   (224, 238, 232)  #E0EEE8  cyan      青            
#> 142  su           素       (224, 240, 233)  #E0F0E9  cyan      青            
#> 143  yuebai       月白     (238, 247, 242)  #EEF7F2  cyan      青            
```
