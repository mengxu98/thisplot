# Color palettes collected

This function creates a color palette for a given vector of values.

## Usage

``` r
palette_colors(
  x,
  n = 100,
  palette = "Paired",
  palcolor = NULL,
  type = c("auto", "discrete", "continuous"),
  matched = FALSE,
  reverse = FALSE,
  NA_keep = FALSE,
  NA_color = "grey80"
)
```

## Arguments

- x:

  A vector of character/factor or numeric values. If missing, numeric
  values 1:n will be used as x.

- n:

  The number of colors to return for numeric values.

- palette:

  Palette name. All available palette names can be queried with
  [show_palettes](https://mengxu98.github.io/thisplot/reference/show_palettes.md).

- palcolor:

  Custom colors used to create a color palette.

- type:

  Type of `x`. Can be one of `"auto"`, `"discrete"` or `"continuous"`.
  The default is `"auto"`, which automatically detects if `x` is a
  numeric value.

- matched:

  Whether to return a color vector of the same length as `x`. Default is
  `FALSE`.

- reverse:

  Whether to invert the colors. Default is `FALSE`.

- NA_keep:

  Whether to keep the color assignment to NA in `x`. Default is `FALSE`.

- NA_color:

  Color assigned to NA if `NA_keep` is `TRUE`. Default is `"grey80"`.

## Value

A character vector of color codes (hexadecimal format) corresponding to
the input values `x`. The length and structure depend on the `matched`
parameter.

## See also

[show_palettes](https://mengxu98.github.io/thisplot/reference/show_palettes.md),
[palette_list](https://mengxu98.github.io/thisplot/reference/palette_list.md)

## Examples

``` r
x <- c(1:3, NA, 3:5)
(pal1 <- palette_colors(
  x,
  palette = "Spectral"
))
#>    [1,1.04] (1.04,1.08] (1.08,1.12] (1.12,1.16]  (1.16,1.2]  (1.2,1.24] 
#>   "#5E4FA2"   "#5954A4"   "#555AA7"   "#5060AA"   "#4C66AC"   "#476BAF" 
#> (1.24,1.28] (1.28,1.32] (1.32,1.36]  (1.36,1.4]  (1.4,1.44] (1.44,1.48] 
#>   "#4371B2"   "#3E77B5"   "#3A7DB7"   "#3682BA"   "#3288BC"   "#378EBA" 
#> (1.48,1.52] (1.52,1.56]  (1.56,1.6]  (1.6,1.64] (1.64,1.68] (1.68,1.72] 
#>   "#3D94B7"   "#429AB5"   "#47A0B3"   "#4CA5B0"   "#52ABAE"   "#57B1AB" 
#> (1.72,1.76]  (1.76,1.8]  (1.8,1.84] (1.84,1.88] (1.88,1.92] (1.92,1.96] 
#>   "#5CB7A9"   "#61BDA6"   "#67C2A4"   "#6EC5A4"   "#75C8A4"   "#7CCAA4" 
#>    (1.96,2]    (2,2.04] (2.04,2.08] (2.08,2.12] (2.12,2.16]  (2.16,2.2] 
#>   "#83CDA4"   "#8AD0A4"   "#91D2A4"   "#98D5A4"   "#9FD8A4"   "#A6DBA4" 
#>  (2.2,2.24] (2.24,2.28] (2.28,2.32] (2.32,2.36]  (2.36,2.4]  (2.4,2.44] 
#>   "#ACDDA3"   "#B2E0A2"   "#B8E2A1"   "#BEE5A0"   "#C4E79E"   "#CAE99D" 
#> (2.44,2.48] (2.48,2.52] (2.52,2.56]  (2.56,2.6]  (2.6,2.64] (2.64,2.68] 
#>   "#D0EC9C"   "#D6EE9B"   "#DCF199"   "#E2F398"   "#E7F599"   "#E9F69D" 
#> (2.68,2.72] (2.72,2.76]  (2.76,2.8]  (2.8,2.84] (2.84,2.88] (2.88,2.92] 
#>   "#ECF7A1"   "#EEF8A5"   "#F1F9A9"   "#F3FAAD"   "#F6FBB1"   "#F8FCB5" 
#> (2.92,2.96]    (2.96,3]    (3,3.04] (3.04,3.08] (3.08,3.12] (3.12,3.16] 
#>   "#FBFDB9"   "#FDFEBD"   "#FEFDBC"   "#FEFAB7"   "#FEF7B1"   "#FEF4AC" 
#>  (3.16,3.2]  (3.2,3.24] (3.24,3.28] (3.28,3.32] (3.32,3.36]  (3.36,3.4] 
#>   "#FEF0A7"   "#FEEDA2"   "#FEEA9C"   "#FEE797"   "#FEE492"   "#FEE18D" 
#>  (3.4,3.44] (3.44,3.48] (3.48,3.52] (3.52,3.56]  (3.56,3.6]  (3.6,3.64] 
#>   "#FDDC88"   "#FDD784"   "#FDD27F"   "#FDCD7B"   "#FDC877"   "#FDC373" 
#> (3.64,3.68] (3.68,3.72] (3.72,3.76]  (3.76,3.8]  (3.8,3.84] (3.84,3.88] 
#>   "#FDBE6F"   "#FDB96A"   "#FDB466"   "#FDAF62"   "#FCA95E"   "#FBA25B" 
#> (3.88,3.92] (3.92,3.96]    (3.96,4]    (4,4.04] (4.04,4.08] (4.08,4.12] 
#>   "#FA9C58"   "#F99555"   "#F88F52"   "#F7884F"   "#F6824C"   "#F67B49" 
#> (4.12,4.16]  (4.16,4.2]  (4.2,4.24] (4.24,4.28] (4.28,4.32] (4.32,4.36] 
#>   "#F57446"   "#F46E43"   "#F16943"   "#EE6445"   "#EB5F46"   "#E85A47" 
#>  (4.36,4.4]  (4.4,4.44] (4.44,4.48] (4.48,4.52] (4.52,4.56]  (4.56,4.6] 
#>   "#E45648"   "#E1514A"   "#DE4C4B"   "#DB474C"   "#D8434D"   "#D53E4E" 
#>  (4.6,4.64] (4.64,4.68] (4.68,4.72] (4.72,4.76]  (4.76,4.8]  (4.8,4.84] 
#>   "#CF384D"   "#CA324C"   "#C42C4B"   "#BF2549"   "#B91F48"   "#B41947" 
#> (4.84,4.88] (4.88,4.92] (4.92,4.96]    (4.96,5] 
#>   "#AE1345"   "#A90D44"   "#A30743"   "#9E0142" 
(pal2 <- palette_colors(
  x,
  palcolor = c("red", "white", "blue")
))
#>    [1,1.04] (1.04,1.08] (1.08,1.12] (1.12,1.16]  (1.16,1.2]  (1.2,1.24] 
#>   "#FF0000"   "#FF0505"   "#FF0A0A"   "#FF0F0F"   "#FF1414"   "#FF1919" 
#> (1.24,1.28] (1.28,1.32] (1.32,1.36]  (1.36,1.4]  (1.4,1.44] (1.44,1.48] 
#>   "#FF1E1E"   "#FF2424"   "#FF2929"   "#FF2E2E"   "#FF3333"   "#FF3838" 
#> (1.48,1.52] (1.52,1.56]  (1.56,1.6]  (1.6,1.64] (1.64,1.68] (1.68,1.72] 
#>   "#FF3D3D"   "#FF4242"   "#FF4848"   "#FF4D4D"   "#FF5252"   "#FF5757" 
#> (1.72,1.76]  (1.76,1.8]  (1.8,1.84] (1.84,1.88] (1.88,1.92] (1.92,1.96] 
#>   "#FF5C5C"   "#FF6161"   "#FF6767"   "#FF6C6C"   "#FF7171"   "#FF7676" 
#>    (1.96,2]    (2,2.04] (2.04,2.08] (2.08,2.12] (2.12,2.16]  (2.16,2.2] 
#>   "#FF7B7B"   "#FF8080"   "#FF8585"   "#FF8B8B"   "#FF9090"   "#FF9595" 
#>  (2.2,2.24] (2.24,2.28] (2.28,2.32] (2.32,2.36]  (2.36,2.4]  (2.4,2.44] 
#>   "#FF9A9A"   "#FF9F9F"   "#FFA4A4"   "#FFAAAA"   "#FFAFAF"   "#FFB4B4" 
#> (2.44,2.48] (2.48,2.52] (2.52,2.56]  (2.56,2.6]  (2.6,2.64] (2.64,2.68] 
#>   "#FFB9B9"   "#FFBEBE"   "#FFC3C3"   "#FFC8C8"   "#FFCECE"   "#FFD3D3" 
#> (2.68,2.72] (2.72,2.76]  (2.76,2.8]  (2.8,2.84] (2.84,2.88] (2.88,2.92] 
#>   "#FFD8D8"   "#FFDDDD"   "#FFE2E2"   "#FFE7E7"   "#FFECEC"   "#FFF2F2" 
#> (2.92,2.96]    (2.96,3]    (3,3.04] (3.04,3.08] (3.08,3.12] (3.12,3.16] 
#>   "#FFF7F7"   "#FFFCFC"   "#FCFCFF"   "#F7F7FF"   "#F2F2FF"   "#ECECFF" 
#>  (3.16,3.2]  (3.2,3.24] (3.24,3.28] (3.28,3.32] (3.32,3.36]  (3.36,3.4] 
#>   "#E7E7FF"   "#E2E2FF"   "#DDDDFF"   "#D8D8FF"   "#D3D3FF"   "#CECEFF" 
#>  (3.4,3.44] (3.44,3.48] (3.48,3.52] (3.52,3.56]  (3.56,3.6]  (3.6,3.64] 
#>   "#C8C8FF"   "#C3C3FF"   "#BEBEFF"   "#B9B9FF"   "#B4B4FF"   "#AFAFFF" 
#> (3.64,3.68] (3.68,3.72] (3.72,3.76]  (3.76,3.8]  (3.8,3.84] (3.84,3.88] 
#>   "#A9A9FF"   "#A4A4FF"   "#9F9FFF"   "#9A9AFF"   "#9595FF"   "#9090FF" 
#> (3.88,3.92] (3.92,3.96]    (3.96,4]    (4,4.04] (4.04,4.08] (4.08,4.12] 
#>   "#8B8BFF"   "#8585FF"   "#8080FF"   "#7B7BFF"   "#7676FF"   "#7171FF" 
#> (4.12,4.16]  (4.16,4.2]  (4.2,4.24] (4.24,4.28] (4.28,4.32] (4.32,4.36] 
#>   "#6C6CFF"   "#6767FF"   "#6161FF"   "#5C5CFF"   "#5757FF"   "#5252FF" 
#>  (4.36,4.4]  (4.4,4.44] (4.44,4.48] (4.48,4.52] (4.52,4.56]  (4.56,4.6] 
#>   "#4D4DFF"   "#4848FF"   "#4242FF"   "#3D3DFF"   "#3838FF"   "#3333FF" 
#>  (4.6,4.64] (4.64,4.68] (4.68,4.72] (4.72,4.76]  (4.76,4.8]  (4.8,4.84] 
#>   "#2E2EFF"   "#2929FF"   "#2424FF"   "#1E1EFF"   "#1919FF"   "#1414FF" 
#> (4.84,4.88] (4.88,4.92] (4.92,4.96]    (4.96,5] 
#>   "#0F0FFF"   "#0A0AFF"   "#0505FF"   "#0000FF" 
(pal3 <- palette_colors(
  x,
  palette = "Spectral",
  n = 10
))
#>   [1,1.4] (1.4,1.8] (1.8,2.2] (2.2,2.6]   (2.6,3]   (3,3.4] (3.4,3.8] (3.8,4.2] 
#> "#5E4FA2" "#3288BD" "#66C2A5" "#ABDDA4" "#E6F598" "#FFFFBF" "#FEE08B" "#FDAE61" 
#> (4.2,4.6]   (4.6,5] 
#> "#F46D43" "#D53E4F" 
(pal4 <- palette_colors(
  x,
  palette = "Spectral",
  n = 10,
  reverse = TRUE
))
#>   (4.6,5] (4.2,4.6] (3.8,4.2] (3.4,3.8]   (3,3.4]   (2.6,3] (2.2,2.6] (1.8,2.2] 
#> "#D53E4F" "#F46D43" "#FDAE61" "#FEE08B" "#FFFFBF" "#E6F598" "#ABDDA4" "#66C2A5" 
#> (1.4,1.8]   [1,1.4] 
#> "#3288BD" "#5E4FA2" 
(pal5 <- palette_colors(
  x,
  palette = "Spectral",
  matched = TRUE
))
#>  [1,1.04]  (1.96,2]  (2.96,3]      <NA>  (2.96,3]  (3.96,4]  (4.96,5] 
#> "#5E4FA2" "#83CDA4" "#FDFEBD"        NA "#FDFEBD" "#F88F52" "#9E0142" 
(pal6 <- palette_colors(
  x,
  palette = "Spectral",
  matched = TRUE,
  NA_keep = TRUE
))
#>  [1,1.04]  (1.96,2]  (2.96,3]      <NA>  (2.96,3]  (3.96,4]  (4.96,5] 
#> "#5E4FA2" "#83CDA4" "#FDFEBD"  "grey80" "#FDFEBD" "#F88F52" "#9E0142" 
show_palettes(
  list(pal1, pal2, pal3, pal4, pal5, pal6)
)

#> [1] "1" "2" "3" "4" "5" "6"

# Use Chinese color palettes
palette_colors(
  x = letters[1:5],
  palette = "ChineseRed",
  type = "discrete"
)
#>         a         b         c         d         e 
#> "#4C1E1A" "#631216" "#62102E" "#622A1D" "#662B1F" 
palette_colors(
  x = letters[1:5],
  palette = "Chinese",
  type = "discrete"
)
#>         a         b         c         d         e 
#> "#1772B4" "#0AA344" "#F9BD10" "#F97D1C" "#ED5736" 

all_palettes <- show_palettes(return_palettes = TRUE)

names(all_palettes)
#>   [1] "BrBG"                   "PiYG"                   "PRGn"                  
#>   [4] "PuOr"                   "RdBu"                   "RdGy"                  
#>   [7] "RdYlBu"                 "RdYlGn"                 "Spectral"              
#>  [10] "Accent"                 "Dark2"                  "Paired"                
#>  [13] "Pastel1"                "Pastel2"                "Set1"                  
#>  [16] "Set2"                   "Set3"                   "Blues"                 
#>  [19] "BuGn"                   "BuPu"                   "GnBu"                  
#>  [22] "Greens"                 "Greys"                  "Oranges"               
#>  [25] "OrRd"                   "PuBu"                   "PuBuGn"                
#>  [28] "PuRd"                   "Purples"                "RdPu"                  
#>  [31] "Reds"                   "YlGn"                   "YlGnBu"                
#>  [34] "YlOrBr"                 "YlOrRd"                 "npg"                   
#>  [37] "aaas"                   "nejm"                   "lancet"                
#>  [40] "jama"                   "jco"                    "ucscgb"                
#>  [43] "d3-category10"          "d3-category20"          "d3-category20b"        
#>  [46] "d3-category20c"         "igv"                    "locuszoom"             
#>  [49] "uchicago-default"       "uchicago-light"         "uchicago-dark"         
#>  [52] "cosmic"                 "simpsons"               "futurama"              
#>  [55] "rickandmorty"           "startrek"               "tron"                  
#>  [58] "frontiers"              "flatui"                 "gsea"                  
#>  [61] "material-red"           "material-pink"          "material-purple"       
#>  [64] "material-deep-purple"   "material-indigo"        "material-blue"         
#>  [67] "material-light-blue"    "material-cyan"          "material-teal"         
#>  [70] "material-green"         "material-light-green"   "material-lime"         
#>  [73] "material-yellow"        "material-amber"         "material-orange"       
#>  [76] "material-deep-orange"   "material-brown"         "material-grey"         
#>  [79] "material-blue-grey"     "dPBIYlBu"               "dPBIYlPu"              
#>  [82] "dPBIPuGn"               "dPBIPuOr"               "dPBIRdBu"              
#>  [85] "dPBIRdGy"               "dPBIRdGn"               "qMSOStd"               
#>  [88] "qMSO12"                 "qMSO15"                 "qMSOBuWarm"            
#>  [91] "qMSOBu"                 "qMSOBu2"                "qMSOBuGn"              
#>  [94] "qMSOGn"                 "qMSOGnYl"               "qMSOYl"                
#>  [97] "qMSOYlOr"               "qMSOOr"                 "qMSOOrRd"              
#> [100] "qMSORdOr"               "qMSORd"                 "qMSORdPu"              
#> [103] "qMSOPu"                 "qMSOPu2"                "qMSOMed"               
#> [106] "qMSOPap"                "qMSOMrq"                "qMSOSlp"               
#> [109] "qMSOAsp"                "qPBI"                   "sPBIGn"                
#> [112] "sPBIGy1"                "sPBIRd"                 "sPBIYl"                
#> [115] "sPBIGy2"                "sPBIBu"                 "sPBIOr"                
#> [118] "sPBIPu"                 "sPBIYlGn"               "sPBIRdPu"              
#> [121] "ag_GrnYl"               "ag_Sunset"              "ArmyRose"              
#> [124] "Earth"                  "Fall"                   "Geyser"                
#> [127] "TealRose"               "Temps"                  "Tropic"                
#> [130] "Antique"                "Bold"                   "Pastel"                
#> [133] "Prism"                  "Safe"                   "Vivid"                 
#> [136] "BluGrn"                 "BluYl"                  "BrwnYl"                
#> [139] "Burg"                   "BurgYl"                 "DarkMint"              
#> [142] "Emrld"                  "Magenta"                "Mint"                  
#> [145] "OrYel"                  "Peach"                  "PinkYl"                
#> [148] "Purp"                   "PurpOr"                 "RedOr"                 
#> [151] "Sunset"                 "SunsetDark"             "Teal"                  
#> [154] "TealGrn"                "polarnight"             "snowstorm"             
#> [157] "frost"                  "aurora"                 "lumina"                
#> [160] "mountain_forms"         "silver_mine"            "lake_superior"         
#> [163] "victory_bonds"          "halifax_harbor"         "moose_pond"            
#> [166] "algoma_forest"          "rocky_mountain"         "red_mountain"          
#> [169] "baie_mouton"            "afternoon_prarie"       "magma"                 
#> [172] "inferno"                "plasma"                 "viridis"               
#> [175] "cividis"                "rocket"                 "mako"                  
#> [178] "turbo"                  "ocean.algae"            "ocean.deep"            
#> [181] "ocean.dense"            "ocean.gray"             "ocean.haline"          
#> [184] "ocean.ice"              "ocean.matter"           "ocean.oxy"             
#> [187] "ocean.phase"            "ocean.solar"            "ocean.thermal"         
#> [190] "ocean.turbid"           "ocean.balance"          "ocean.curl"            
#> [193] "ocean.delta"            "ocean.amp"              "ocean.speed"           
#> [196] "ocean.tempo"            "BrowntoBlue.10"         "BrowntoBlue.12"        
#> [199] "BluetoDarkOrange.12"    "BluetoDarkOrange.18"    "DarkRedtoBlue.12"      
#> [202] "DarkRedtoBlue.18"       "BluetoGreen.14"         "BluetoGray.8"          
#> [205] "BluetoOrangeRed.14"     "BluetoOrange.10"        "BluetoOrange.12"       
#> [208] "BluetoOrange.8"         "LightBluetoDarkBlue.10" "LightBluetoDarkBlue.7" 
#> [211] "Categorical.12"         "GreentoMagenta.16"      "SteppedSequential.5"   
#> [214] "jcolors-default"        "jcolors-pal2"           "jcolors-pal3"          
#> [217] "jcolors-pal4"           "jcolors-pal5"           "jcolors-pal6"          
#> [220] "jcolors-pal7"           "jcolors-pal8"           "jcolors-pal9"          
#> [223] "jcolors-pal10"          "jcolors-pal11"          "jcolors-pal12"         
#> [226] "jcolors-rainbow"        "jet"                    "simspec"               
#> [229] "GdRd"                   "Chinese"                "ChineseContinuous"     
#> [232] "ChineseSet8"            "ChineseSet16"           "ChineseSet32"          
#> [235] "ChineseSet64"           "ChineseSet128"          "ChineseBlue"           
#> [238] "ChineseCyan"            "ChineseGray_brown"      "ChineseGreen"          
#> [241] "ChineseOrange"          "ChinesePurple"          "ChineseRed"            
#> [244] "ChineseYellow"         
```
