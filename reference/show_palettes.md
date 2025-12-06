# Show the color palettes

This function displays color palettes using ggplot2.

## Usage

``` r
show_palettes(
  palettes = NULL,
  type = c("discrete", "continuous"),
  index = NULL,
  palette_names = NULL,
  return_names = TRUE,
  return_palettes = FALSE
)
```

## Arguments

- palettes:

  A list of color palettes. Default is `NULL`.

- type:

  The type of palettes to include. Default is `"discrete"`.

- index:

  The indices of the palettes to include. Default is `NULL`.

- palette_names:

  The names of the palettes to include. Default is `NULL`.

- return_names:

  Whether to return the names of the selected palettes. Default is
  `TRUE`.

- return_palettes:

  Whether to return the colors of selected palettes. Default is `FALSE`.

## Value

If `return_palettes` is `TRUE`, returns a list of color palettes. If
`return_names` is `TRUE` (default), returns a character vector of
palette names. Otherwise, returns `NULL` (called for side effects to
display the plot).

## See also

[palette_colors](https://mengxu98.github.io/thisplot/reference/palette_colors.md),
[palette_list](https://mengxu98.github.io/thisplot/reference/palette_list.md)

## Examples

``` r
show_palettes(
  palettes = list(
    c("red", "blue", "green"),
    c("yellow", "purple", "orange")
  )
)

#> [1] "1" "2"
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
#> [229] "GdRd"                   "Chinese"                "Chinese_continuous"    
#> [232] "Chinese_blue"           "Chinese_cyan"           "Chinese_gray_brown"    
#> [235] "Chinese_green"          "Chinese_orange"         "Chinese_purple"        
#> [238] "Chinese_red"            "Chinese_yellow"        
all_palettes[["simspec"]]
#>  [1] "#c22b86" "#f769a1" "#fcc5c1" "#253777" "#1d92c0" "#9ec9e1" "#015b33"
#>  [8] "#42aa5e" "#d9f0a2" "#E66F00" "#f18c28" "#FFBB61"
#> attr(,"type")
#> [1] "discrete"
show_palettes(index = 1:10)

#>  [1] "BrBG"     "PiYG"     "PRGn"     "PuOr"     "RdBu"     "RdGy"    
#>  [7] "RdYlBu"   "RdYlGn"   "Spectral" "Accent"  
show_palettes(
  type = "discrete",
  index = 1:10
)

#>  [1] "Accent"  "Dark2"   "Paired"  "Pastel1" "Pastel2" "Set1"    "Set2"   
#>  [8] "Set3"    "npg"     "aaas"   
show_palettes(
  type = "continuous",
  index = 1:10
)

#>  [1] "BrBG"     "PiYG"     "PRGn"     "PuOr"     "RdBu"     "RdGy"    
#>  [7] "RdYlBu"   "RdYlGn"   "Spectral" "Blues"   
show_palettes(
  palette_names = c(
    "Paired", "nejm", "simspec", "Spectral", "jet", "Chinese"
  ),
  return_palettes = TRUE
)

#> $Paired
#>  [1] "#A6CEE3" "#1F78B4" "#B2DF8A" "#33A02C" "#FDBF6F" "#FF7F00" "#FB9A99"
#>  [8] "#E31A1C" "#CAB2D6" "#6A3D9A" "#FFFF99" "#B15928"
#> attr(,"type")
#> [1] "discrete"
#> 
#> $nejm
#>      TallPoppy   DeepCerulean           Zest     Eucalyptus WildBlueYonder 
#>      "#BC3C29"      "#0072B5"      "#E18727"      "#20854E"      "#7876B1" 
#>         Gothic        Salomie     FrenchRose 
#>      "#6F99AD"      "#FFDC91"      "#EE4C97" 
#> attr(,"type")
#> [1] "discrete"
#> 
#> $simspec
#>  [1] "#c22b86" "#f769a1" "#fcc5c1" "#253777" "#1d92c0" "#9ec9e1" "#015b33"
#>  [8] "#42aa5e" "#d9f0a2" "#E66F00" "#f18c28" "#FFBB61"
#> attr(,"type")
#> [1] "discrete"
#> 
#> $Spectral
#>  [1] "#5E4FA2" "#3288BD" "#66C2A5" "#ABDDA4" "#E6F598" "#FFFFBF" "#FEE08B"
#>  [8] "#FDAE61" "#F46D43" "#D53E4F" "#9E0142"
#> attr(,"type")
#> [1] "continuous"
#> 
#> $jet
#>   [1] "#00007A" "#000085" "#00008F" "#000099" "#0000A3" "#0000AD" "#0000B8"
#>   [8] "#0000C2" "#0000CC" "#0000D6" "#0000E0" "#0000EB" "#0000F5" "#0000FF"
#>  [15] "#000AFF" "#0014FF" "#001FFF" "#0029FF" "#0033FF" "#003DFF" "#0047FF"
#>  [22] "#0052FF" "#005CFF" "#0066FF" "#0070FF" "#007AFF" "#0085FF" "#008FFF"
#>  [29] "#0099FF" "#00A3FF" "#00ADFF" "#00B8FF" "#00C2FF" "#00CCFF" "#00D6FF"
#>  [36] "#00E0FF" "#00EBFF" "#00F5FF" "#00FFFF" "#0AFFF5" "#14FFEB" "#1FFFE0"
#>  [43] "#29FFD6" "#33FFCC" "#3DFFC2" "#47FFB8" "#52FFAD" "#5CFFA3" "#66FF99"
#>  [50] "#70FF8F" "#7AFF85" "#85FF7A" "#8FFF70" "#99FF66" "#A3FF5C" "#ADFF52"
#>  [57] "#B8FF47" "#C2FF3D" "#CCFF33" "#D6FF29" "#E0FF1F" "#EBFF14" "#F5FF0A"
#>  [64] "#FFFF00" "#FFF500" "#FFEB00" "#FFE000" "#FFD600" "#FFCC00" "#FFC200"
#>  [71] "#FFB800" "#FFAD00" "#FFA300" "#FF9900" "#FF8F00" "#FF8500" "#FF7A00"
#>  [78] "#FF7000" "#FF6600" "#FF5C00" "#FF5200" "#FF4700" "#FF3D00" "#FF3300"
#>  [85] "#FF2900" "#FF1F00" "#FF1400" "#FF0A00" "#FF0000" "#F50000" "#EB0000"
#>  [92] "#E00000" "#D60000" "#CC0000" "#C20000" "#B80000" "#AD0000" "#A30000"
#>  [99] "#990000" "#8F0000"
#> attr(,"type")
#> [1] "continuous"
#> 
#> $Chinese
#> [1] "#004EA2" "#007175" "#1A6840" "#FECC11" "#ED5736" "#BC172D" "#AA6A4C"
#> [8] "#8A1874"
#> attr(,"type")
#> [1] "discrete"
#> 
# Include Chinese palettes via prefix
show_palettes(
  palette_names = c("Chinese_red", "Chinese_blue"),
  return_palettes = TRUE
)

#> $Chinese_red
#>   [1] "#4C1E1A" "#631216" "#62102E" "#622A1D" "#662B1F" "#662B2F" "#7C1823"
#>   [8] "#7C191E" "#82111F" "#82202B" "#822327" "#8F1D22" "#873424" "#95302E"
#>  [15] "#9E2A22" "#A61B29" "#8F3D2C" "#A72126" "#AB1D22" "#AC1F18" "#954024"
#>  [22] "#B81A35" "#AF2E2B" "#894E54" "#BC172D" "#AB372F" "#A73766" "#C21F30"
#>  [29] "#B13B2E" "#C8161D" "#C12C1F" "#C02C38" "#9E4E56" "#CF002D" "#B93A26"
#>  [36] "#C91F37" "#CC163A" "#B83570" "#B04552" "#BF3553" "#A6522C" "#B0436F"
#>  [43] "#D11A2D" "#D70440" "#A7535A" "#D42517" "#BD482A" "#C83C23" "#BD482C"
#>  [50] "#C04851" "#DE1C31" "#E60012" "#DE2A18" "#E61030" "#DC3023" "#D9333F"
#>  [57] "#D2357D" "#CF4813" "#D13C74" "#C25160" "#EB261A" "#F00056" "#B95A89"
#>  [64] "#EC2B24" "#C45A65" "#EE2746" "#E8382C" "#C35C6A" "#C35691" "#ED3321"
#>  [71] "#DE3F7C" "#EC2C64" "#ED3333" "#CE576D" "#ED2F6A" "#EC2D7A" "#ED3B2F"
#>  [78] "#EE2C79" "#CC5595" "#D85916" "#E94709" "#CD6227" "#F03752" "#CB5C83"
#>  [85] "#EF3473" "#F13C22" "#EB3C70" "#F03F24" "#D2568C" "#EE3F4D" "#F33B1F"
#>  [92] "#F5391C" "#F23E23" "#F43E06" "#F1441D" "#CE5E8A" "#ED4845" "#FF0097"
#>  [99] "#F2481B" "#F34718" "#FF3300" "#EF475D" "#F04B22" "#EE4863" "#F04A3A"
#> [106] "#FF2D51" "#EE4866" "#ED5126" "#EB507E" "#EA517F" "#EF498B" "#ED5736"
#> [113] "#EC4E8A" "#C5708B" "#F35336" "#ED556A" "#F15642" "#E16723" "#ED5A65"
#> [120] "#F05A46" "#BB7A8C" "#F25A47" "#DD6B7B" "#DC6B82" "#CC73A0" "#C27C88"
#> [127] "#E16C96" "#D276A3" "#DD7694" "#DE7897" "#EB6EA5" "#EA7293" "#F17666"
#> [134] "#CE8892" "#EC7696" "#E77C8E" "#EF7A82" "#DE82A7" "#F47983" "#F07C82"
#> [141] "#CF929E" "#EF82A0" "#D993AB" "#EC8AA4" "#F1908C" "#F091A0" "#F1939C"
#> [148] "#F19790" "#EB9A9A" "#D9A0B3" "#EC9BAD" "#E2A2AC" "#EEA08C" "#ED9DB2"
#> [155] "#EBA0B3" "#DAA9A9" "#EEA2A4" "#F0A1A8" "#EEA6B7" "#EFAA9C" "#E3ADB9"
#> [162] "#F0ADA0" "#EFAFAD" "#E3B4B8" "#ECB0C1" "#E4B8D5" "#EEB8C3" "#F2B9B2"
#> [169] "#F6BEC8" "#EFC4CE" "#F1C4CD" "#F4C7BA" "#E7CAD3" "#F0C9CF" "#F2CAC9"
#> [176] "#F6CEC1" "#EDD1D8" "#F0CFE3" "#F3D3E7" "#F9D3E3" "#F8EBE6"
#> attr(,"type")
#> [1] "discrete"
#> 
#> $Chinese_blue
#>  [1] "#0F1423" "#131824" "#101F30" "#142334" "#12264F" "#1C2938" "#132C33"
#>  [8] "#1A2847" "#003460" "#19325F" "#21373D" "#003371" "#213A70" "#003D74"
#> [15] "#38308E" "#1C3F73" "#22406A" "#06436F" "#134857" "#144A74" "#454659"
#> [22] "#45465E" "#354E6B" "#12507B" "#2E4E7E" "#26499D" "#004EA2" "#535164"
#> [29] "#2A5390" "#424D99" "#15559A" "#0F59A4" "#1661AB" "#11659A" "#106898"
#> [36] "#126E82" "#4B5CC4" "#126BAE" "#4F64AE" "#346C9C" "#3170A7" "#1772B4"
#> [43] "#3271AE" "#2B73AF" "#2474B5" "#1177B0" "#1677B3" "#2376B7" "#2177B8"
#> [50] "#5E7987" "#4E7CA1" "#5976BA" "#6B798E" "#1781B5" "#4182A4" "#2983BB"
#> [57] "#2486B9" "#158BB8" "#2F90B9" "#1A94BC" "#4994C4" "#5698C3" "#6F94CD"
#> [64] "#619AC3" "#22A2C3" "#8D93C8" "#6E9BC5" "#66A9C9" "#8BA3C7" "#5CB3CC"
#> [71] "#8AABCC" "#88ABDA" "#8FB2C9" "#63BBD0" "#3CBEE7" "#93B5CF" "#8ABCD1"
#> [78] "#85C0DB" "#A3BBDB" "#BACCD9" "#93D5DC" "#A2D2E2" "#30DFF3" "#AED0EE"
#> [85] "#B0D5DF" "#C7D2D4" "#BCD4E7" "#C3D7DF" "#3EEDE7" "#D0DFE6" "#C6E6E8"
#> [92] "#D2F0F4"
#> attr(,"type")
#> [1] "discrete"
#> 
```
