# Chinese traditional colors system

A color system based on Chinese traditional colors with 1058
representative colors. This system provides functions to access colors
by name, create color palettes, and generate segmented colormaps.

## Usage

``` r
ChineseColors()
```

## Value

A `ChineseColors` object. Detailed information can be found in
[`print.ChineseColors()`](https://mengxu98.github.io/thisplot/reference/print.ChineseColors.md).

## See also

[chinese_colors](https://mengxu98.github.io/thisplot/reference/chinese_colors.md)
for the dataset of Chinese traditional colors.
[get_chinese_palettes](https://mengxu98.github.io/thisplot/reference/get_chinese_palettes.md)
for getting Chinese color palettes.
[visual_colors](https://mengxu98.github.io/thisplot/reference/visual_colors.md)
for visualizing any color vector.
[get_colors](https://mengxu98.github.io/thisplot/reference/get_colors.md)
for searching colors in dataset and palettes.

## Examples

``` r
cc <- ChineseColors()
cc
#> 
#> ── Chinese Traditional Colors System 
#> 
#> ── Total 1058 colors 
#> • blue: 92 colors
#> • cyan: 51 colors
#> • gray_brown: 323 colors
#> • green: 123 colors
#> • orange: 92 colors
#> • purple: 95 colors
#> • red: 181 colors
#> • yellow: 101 colors
#> 
#> ── Methods: 
#> • get_color(...): Get color information (searches only in dataset)
#> • visual_colors(loc_range, num_per_row, title, name_type)
#> 
#> ── See also: 
#> [get_colors()] for searching colors in dataset and palettes

# Get a color by pinyin name
cc$get_color("pinlan")
#> Error in get_colors(...): No matching palettes found for: "pinlan". Available palettes include:
#> "BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral",
#> "Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2", "Set3",
#> "Blues", …, "ChineseRed", and "ChineseYellow". Use
#> `show_palettes(return_palettes = TRUE)` to see all available palettes.
# Or use external function
get_colors("pinlan")
#> Error in get_colors("pinlan"): No matching palettes found for: "pinlan". Available palettes include:
#> "BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral",
#> "Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2", "Set3",
#> "Blues", …, "ChineseRed", and "ChineseYellow". Use
#> `show_palettes(return_palettes = TRUE)` to see all available palettes.

# By number
cc$get_color(44)
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

# By hex code
cc$get_color("#2B73AF")
#> 
#> ── Found in: 
#> #2B73AF: "ChineseSet128" and "ChineseBlue"
#> num  name    name_ch  rgb             hex      category  category_ch   
#> 44   pinlan  品蓝     (43, 115, 175)  #2B73AF  blue      蓝            
get_colors("#2B73AF") # Also searches in palettes
#> 
#> ── Found in: 
#> #2B73AF: "ChineseSet128" and "ChineseBlue"
#> num  name    name_ch  rgb             hex      category  category_ch   
#> 44   pinlan  品蓝     (43, 115, 175)  #2B73AF  blue      蓝            

# Multiple colors
cc$get_color("pinlan", "piao")
#> Error in get_colors(...): No matching palettes found for: "pinlan" and "piao". Available palettes
#> include: "BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn",
#> "Spectral", "Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2",
#> "Set3", "Blues", …, "ChineseRed", and "ChineseYellow". Use
#> `show_palettes(return_palettes = TRUE)` to see all available palettes.
get_colors("pinlan", "piao")
#> Error in get_colors("pinlan", "piao"): No matching palettes found for: "pinlan" and "piao". Available palettes
#> include: "BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn",
#> "Spectral", "Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2",
#> "Set3", "Blues", …, "ChineseRed", and "ChineseYellow". Use
#> `show_palettes(return_palettes = TRUE)` to see all available palettes.

cc$get_color(91:100)
#> 
#> ── Found in: 
#> #006D87: "ChineseSet128" and "ChineseCyan"
#> #C6E6E8: "ChineseBlue"
#> #D2F0F4: "ChineseBlue"
#> #13393E: "ChineseCyan"
#> #284852: "ChineseCyan"
#> #424C50: "ChineseCyan"
#> #3B5554: "ChineseCyan"
#> #41555D: "ChineseCyan"
#> #426666: "ChineseCyan"
#> #226B68: "ChineseCyan"
#> num  name        name_ch  rgb              hex      category  category_ch   
#> 91   haitianlan  海天蓝   (198, 230, 232)  #C6E6E8  blue      蓝            
#> 92   shuilan     水蓝     (210, 240, 244)  #D2F0F4  blue      蓝            
#> 93   luozidai    螺子黛   (19, 57, 62)     #13393E  cyan      青            
#> 94   qinggua     青緺     (40, 72, 82)     #284852  cyan      青            
#> 95   yaqing      鸦青     (66, 76, 80)     #424C50  cyan      青            
#> 96   daise       黛色     (59, 85, 84)     #3B5554  cyan      青            
#> 97   an          黯       (65, 85, 93)     #41555D  cyan      青            
#> 98   dailv       黛绿     (66, 102, 102)   #426666  cyan      青            
#> 99   daose       䌦色     (34, 107, 104)   #226B68  cyan      青            
#> 100  ruancui     软翠     (0, 109, 135)    #006D87  cyan      青            
get_colors(91:100)
#> 
#> ── Found in: 
#> #006D87: "ChineseSet128" and "ChineseCyan"
#> #C6E6E8: "ChineseBlue"
#> #D2F0F4: "ChineseBlue"
#> #13393E: "ChineseCyan"
#> #284852: "ChineseCyan"
#> #424C50: "ChineseCyan"
#> #3B5554: "ChineseCyan"
#> #41555D: "ChineseCyan"
#> #426666: "ChineseCyan"
#> #226B68: "ChineseCyan"
#> num  name        name_ch  rgb              hex      category  category_ch   
#> 91   haitianlan  海天蓝   (198, 230, 232)  #C6E6E8  blue      蓝            
#> 92   shuilan     水蓝     (210, 240, 244)  #D2F0F4  blue      蓝            
#> 93   luozidai    螺子黛   (19, 57, 62)     #13393E  cyan      青            
#> 94   qinggua     青緺     (40, 72, 82)     #284852  cyan      青            
#> 95   yaqing      鸦青     (66, 76, 80)     #424C50  cyan      青            
#> 96   daise       黛色     (59, 85, 84)     #3B5554  cyan      青            
#> 97   an          黯       (65, 85, 93)     #41555D  cyan      青            
#> 98   dailv       黛绿     (66, 102, 102)   #426666  cyan      青            
#> 99   daose       䌦色     (34, 107, 104)   #226B68  cyan      青            
#> 100  ruancui     软翠     (0, 109, 135)    #006D87  cyan      青            

# Chinese names
widget_ch <- cc$visual_colors(
  title = "Chinese Traditional Colors",
  name_type = "chinese"
)
htmltools::browsable(widget_ch)

  Chinese Traditional Colors
  


          
            钢
蓝
          
        
```

燕  
颔  
蓝

暗  
蓝

钢  
青

骐  
驎

鸽  
蓝

深  
灰  
蓝

花  
青

帝  
释  
青

佛  
头  
青

灰  
蓝

绀  
青

靛  
蓝

绀  
宇

蓝  
色

阴  
丹  
士  
林

琉  
璃  
蓝

蓝  
采  
和

苍  
蓝

鷃  
蓝

䒌  
靘

青  
黛

青  
雀  
头  
黛

碧  
城

藏  
青

吴  
须

景  
泰  
蓝

曾  
青

青  
花  
蓝

湛  
蓝

海  
涛  
蓝

飞  
燕  
草  
蓝

靛  
青

搪  
磁  
蓝

柔  
蓝

玉  
鈫  
蓝

宝  
蓝

柏  
林  
蓝

石  
青

海  
军  
蓝

安  
安  
蓝

群  
青

青  
冥

品  
蓝

尼  
罗  
蓝

牵  
牛  
花  
蓝

天  
蓝

花  
青

虹  
蓝

淡  
蓝  
灰

蝶  
翅  
蓝

苍  
苍

菘  
蓝

釉  
蓝

吐  
绶  
蓝

潮  
蓝

宝  
石  
蓝

鸢  
尾  
蓝

云  
山  
蓝

钴  
蓝

孔  
雀  
蓝

睛  
蓝

监  
德

羽  
扇  
豆  
蓝

海  
青

霁  
色

挼  
蓝

涧  
石  
蓝

东  
方  
既  
白

碧  
青

品  
月

窃  
蓝

晴  
山  
蓝

霁  
青

天  
青

星  
蓝

秋  
波  
蓝

缥  
色

晴  
山

云  
水  
蓝

清  
水  
蓝

云  
门

湖  
蓝

碧  
落

湖  
水  
蓝

鸥  
蓝

星  
郎

井  
天  
蓝

碧  
蓝

远  
天  
蓝

海  
天  
蓝

水  
蓝

螺  
子  
黛

青  
緺

鸦  
青

黛  
色

黯

黛  
绿

䌦  
色

软  
翠

青  
雘

鱼  
师  
青

太  
师  
青

蜻  
蜓  
蓝

千  
山  
翠

法  
翠

铜  
青

樫  
鸟  
蓝

晚  
波  
蓝

空  
青

扁  
青

胆  
矾  
蓝

翠  
蓝

苍  
黑

二  
绿

虾  
壳  
青

天  
水  
碧

竹  
月

缥  
碧

甸  
子  
蓝

正  
青

孔  
雀  
蓝

闪  
蓝

水  
色

蔚  
蓝

松  
石

青  
碧

白  
青

石  
绿

苍  
筤

瀑  
布  
蓝

總  
犗

西  
子

井  
天

老  
银

蟹  
青

沧  
浪

湖  
绿

青  
白

天  
缥

鸭  
卵  
青

素

月  
白

莽  
丛  
绿

云  
杉  
绿

苷  
蓝  
绿

槲  
寄  
生  
绿

深  
海  
绿

油  
绿

苍  
绿

螺  
青

白  
屈  
菜  
绿

荷  
叶  
绿

结  
绿

莓  
莓

翠  
虬

官  
绿

祖  
母  
绿

田  
螺  
绿

青  
青

松  
花  
绿

油  
绿

飞  
泉  
绿

芰  
荷

薄  
荷  
绿

翕  
赩

海  
王  
绿

翠  
微

宫  
殿  
绿

漆  
姑

亚  
丁  
绿

青  
翠

葱  
倩

孔  
雀  
绿

石  
发

瓦  
松  
绿

雀  
梅

菉  
竹

蟾  
绿

青  
梅

青  
矾  
绿

风  
入  
松

蛋  
白  
石  
绿

苍  
色

庭  
芜  
绿

碧  
山

绿  
沈

青  
葱

翠  
绿

蓝  
绿

竹  
青

碧  
色

松  
柏  
绿

竹  
绿

草  
绿

绿  
色

翠  
涛

柳  
色

美  
蝶  
绿

宝  
石  
绿

青  
楸

铜  
绿

碧  
滋

鹦  
鹉  
绿

水  
龙  
吟

梧  
枝  
绿

鲜  
绿

淡  
绿

玉  
髓  
绿

松  
霜  
绿

蛙  
绿

田  
园  
绿

麦  
苗  
绿

蔻  
梢  
绿

浪  
花  
绿

渌  
波

毛  
绿

人  
籁

兰  
苕

水  
绿

芽  
绿

醽  
醁

豆  
绿

春  
辰

草  
原  
远  
绿

苍  
葭

青  
古

葱  
绿

粉  
绿

豆  
青

橄  
榄  
黄  
绿

明  
绿

玉  
簪  
绿

碧  
绿

青  
色

橄  
榄  
石  
绿

苹  
果  
绿

芦  
苇  
绿

冰  
台

翠  
缥

葱  
黄

翡  
翠  
色

麹  
尘

嘉  
陵  
水  
绿

翠  
樽

山  
岚

柳  
绿

欧  
碧

青  
粲

嫩  
绿

艾  
绿

柳  
黄

槐  
花  
黄  
绿

葭  
菼

竹  
篁  
绿

缥

姚  
黄

绮  
钱

淡  
翠  
绿

秘  
色

卵  
色

海  
沬  
绿

少  
艾

艾  
背  
绿

葱  
青

嫩  
菊  
绿

龙  
战

紫  
瓯

栗  
壳

黄  
流

流  
黄

乌  
金

山  
鸡  
黄

枯  
绿

蛾  
黄

郁  
金  
裙

金  
埒

淡  
灰  
绿

库  
金

苍  
黄

琥  
珀

黄  
不  
老

土  
黄

鞠  
衣

芸  
黄

芥  
黄

柘  
黄

黄  
河  
琉  
璃

新  
禾  
绿

黄  
封

香  
色

草  
黄

虎  
皮  
黄

谷  
黄

栀  
子  
黄

铅  
黄

沙  
石  
黄

香  
蕉  
黄

鸡  
蛋  
黄

姜  
黄

雌  
黄

鼬  
黄

蒿  
黄

鹅  
掌  
黄

浅  
驼  
色

赤  
金

初  
熟  
杏  
黄

琥  
珀  
黄

浅  
烙  
黄

甘  
草  
黄

芒  
果  
黄

木  
瓜  
黄

鹦  
鹉  
冠  
黄

金  
盏  
黄

琉  
璃  
黄

鹅  
黄

黄  
连  
黄

柚  
黄

嫩  
鹅  
黄

雅  
梨  
黄

金  
色

乳  
鸭  
黄

硫  
华  
黄

素  
馨  
黄

禹  
余  
粮

秋  
葵  
黄

田  
赤

向  
日  
葵  
黄

大  
豆  
黄

炒  
米  
黄

缃  
叶

蝶  
黄

藤  
黄

金  
瓜  
黄

柠  
檬  
黄

淡  
密  
黄

麦  
芽  
糖  
黄

象  
牙  
黄

佛  
手  
黄

淡  
茧  
黄

葵  
扇  
黄

油  
菜  
花  
黄

栀  
子

香  
水  
玫  
瑰  
黄

黄  
鹂  
留

绢  
纨

牙  
色

麦  
秆  
黄

茉  
莉  
黄

篾  
黄

莺  
儿

酪  
黄

淡  
肉  
色

黄  
色

荔  
肉  
白

断  
肠

豆  
汁  
黄

明  
黄

松  
花

女  
贞  
黄

杏  
仁  
黄

缃  
色

檗  
黄

樱  
草  
色

黄  
白  
游

鸭  
黄

半  
见

朱  
草

韎  
韐

纁  
黄

洛  
神  
珠

棠  
梨

曙  
色

赤  
缇

赩  
炽

牙  
绯

槟  
榔  
综

光  
明  
砂

媚  
蝶

檎  
丹

黄  
栌

黄  
丹

余  
烬  
红

岱  
赭

金  
驼

龙  
睛  
鱼  
红

暮  
色

莓  
酱  
红

麂  
棕

苕  
荣

朱  
柿

燕  
颔  
红

草  
莓  
红

丹

金  
莲  
花  
橙

琼  
琚

小  
红

蟹  
壳  
红

醉  
瓜  
肉

芙  
蓉  
红

缙  
云

桂  
皮  
淡  
棕

红  
友

金  
黄

橘  
红

法  
螺  
红

菠  
萝  
红

橘  
橙

美  
人  
焦  
橙

风  
帆  
黄

赪  
尾

杏  
子

晨  
曦  
红

万  
寿  
菊  
黄

赪  
霞

瓜  
瓤  
红

橙  
色

橘  
黄

北  
瓜  
黄

椒  
房

杏  
黄

萱  
草  
色

杏  
红

软  
木  
黄

海  
螺  
橙

檀  
唇

玳  
瑁  
黄

鲑  
鱼  
红

凋  
叶  
棕

朱  
颜  
酡

雄  
黄

野  
蔷  
薇  
红

橙  
皮  
黄

枇  
杷  
黄

淡  
橘  
橙

金  
莺  
黄

榴  
萼  
黄

九  
斤  
黄

橙  
黄

海  
天  
霞

金  
叶  
黄

淡  
藏  
花  
红

骍  
刚

玫  
瑰  
粉

蜜  
黄

肉  
色

扶  
光

藕  
荷

蛋  
壳  
黄

十  
样  
锦

瓜  
瓤  
粉

润  
红

介  
壳  
淡  
粉  
红

初  
桃  
粉  
红

米  
色

落  
英  
淡  
粉

荷  
花  
白

淡  
米  
粉

粉  
白

麒  
麟  
竭

爵  
头

葡  
萄  
酒  
红

玄  
色

木  
兰

福  
色

枣  
红

顺  
圣

殷  
红

暗  
紫  
苑  
红

大  
繎

朱  
樱

丹  
秫

朱  
湛

綪  
茷

苋  
菜  
红

佛  
赤

水  
华  
朱

胭  
脂  
虫

覆  
盆  
子  
红

赤  
灵

朱  
孔  
阳

玫  
瑰  
灰

烟  
红

牡  
丹  
红

鹅  
血  
石  
红

魏  
红

枫  
叶  
红

石  
榴  
裙

丹  
雘

珊  
瑚  
赫

高  
粱  
红

紫  
矿

红  
色

朱  
殷

赫

尖  
晶  
玉  
红

红  
踯  
躅

鞓  
红

锦  
葵  
红

绀  
红

胭  
脂  
紫

鹅  
冠  
红

朱  
色

满  
江  
红

鹤  
顶  
红

赭  
色

绯

茜  
色

玉  
红

唐  
菖  
蒲  
红

绛

夕  
阳  
红

赤

酡  
红

石  
榴  
红

玫  
瑰  
红

落  
霞  
红

菠  
根  
红

唇  
脂

丽  
春  
红

品  
红

胭  
脂  
水

秋  
海  
棠  
红

莓  
红

淡  
曙  
红

朱  
槿  
色

美  
人  
祭

电  
气  
石  
红

樱  
桃  
红

嫩  
菱  
红

喜  
蛋  
红

枸  
枢  
红

月  
季  
红

榲  
桲  
红

藏  
花  
红

鱼  
鳃  
红

紫  
荆  
红

龙  
须  
红

铁  
棕

朱  
砂

火  
砖  
红

海  
棠  
红

琅  
玕  
紫

品  
红

萝  
卜  
红

松  
叶  
牡  
丹  
红

胭  
脂  
红

丹  
紫  
红

茶  
花  
红

极  
光  
红

铁  
水  
红

红  
汞  
红

银  
朱

蜻  
蜓  
红

吊  
钟  
花  
红

淡  
菽  
红

洋  
红

柿  
红

榴  
花  
红

炎

草  
茉  
莉  
红

大  
红

石  
竹  
红

珊  
瑚  
红

火  
红

淡  
蕊  
香  
红

朱  
红

夹  
竹  
桃  
红

莲  
瓣  
红

扁  
豆  
花  
红

妃  
色

兔  
眼  
红

酢  
酱  
草  
红

彤

山  
茶  
红

苹  
果  
红

陶  
瓷  
红

艳  
红

曲  
红

紫  
梅

桂  
红

渥  
赭

长  
春

黪  
紫

山  
黎  
豆  
红

初  
荷  
红

菱  
锰  
红

苏  
梅

白  
芨  
红

桃  
色

凤  
仙  
花  
红

谷  
鞘  
红

縓  
缘

淡  
绛  
红

淡  
茜  
红

嫣  
红

龙  
膏  
烛

桃  
红

香  
叶  
红

雌  
霓

霞  
光  
红

菡  
萏

报  
春  
红

榴  
子  
红

杨  
妃

春  
梅  
红

舌  
红

红  
梅  
色

莲  
红

粉  
团  
花  
红

彤  
管

淡  
罂  
粟  
红

豇  
豆  
红

芍  
药  
耕  
红

咸  
池

牡  
丹  
粉  
红

合  
欢  
红

晶  
红

颊  
红

夕  
岚

桃  
红

无  
花  
果  
红

鼠  
鼻  
红

水  
红

樱  
花

姜  
红

粉  
红

桃  
夭

粉  
米

水  
红

洋  
水  
仙  
红

银  
红

石  
蕊  
红

淡  
绯

淡  
桃  
红

藕  
色

退  
红

水  
红

盈  
盈

草  
珠  
红

深  
牵  
牛  
紫

暗  
蓝  
紫

乌  
梅  
紫

茄  
皮  
紫

李  
紫

墨  
紫

卵  
石  
紫

火  
鹅  
紫

暗  
龙  
胆  
紫

油  
紫

晶  
石  
紫

金  
鱼  
紫

酱  
紫

绀  
紫

磨  
石  
紫

荸  
荠  
紫

紫  
棠

海  
象  
紫

葡  
萄  
紫

葡  
萄  
酱  
紫

石  
竹  
紫

猪  
肝  
紫

栗  
紫

凝  
夜  
紫

龙  
葵  
紫

野  
葡  
萄  
紫

甘  
蔗  
紫

暗  
玉  
紫

龙  
睛  
鱼  
紫

鹞  
冠  
紫

牵  
牛  
紫

满  
天  
星  
紫

剑  
锋  
紫

芥  
拾  
紫

藏  
蓝

貂  
紫

齐  
紫

茄  
子

魏  
紫

葛  
巾  
紫

紫  
灰

黛  
紫

赪  
紫

三  
公  
子

菜  
头  
紫

黛  
蓝

青  
莲

苋  
菜  
紫

延  
维

桔  
梗  
紫

野  
菊  
紫

地  
血

绛  
紫

芓  
紫

芥  
花  
紫

拂  
紫  
绵

紫  
紶

乌  
色

优  
昙  
瑞

洋  
葱  
紫

玫  
瑰  
紫

紫  
色

山  
梗  
紫

蕈  
紫

黝

紫  
府

紫  
蒲

扁  
豆  
紫

槿  
紫

紫  
茎  
屏  
风

螺  
甸  
紫

藤  
萝  
紫

豆  
蔻  
紫

紫  
苑

樱  
草  
紫

茈  
藐

木  
槿

紫  
菂

青  
蛤  
壳  
紫

萝  
兰  
紫

丁  
香

淡  
蓝  
紫

紫  
薄  
汗

雪  
青

暮  
山  
紫

凤  
信  
紫

紫  
藤

淡  
牵  
牛  
紫

远  
山  
紫

昌  
荣

淡  
青  
紫

芝  
兰  
紫

丁  
香  
淡  
紫

马  
鞭  
草  
紫

淡  
藤  
萝  
紫

黑  
色

漆  
黑

獭  
见

古  
铜  
紫

墨  
色

瑾  
瑜

煤  
黑

乌  
黑

豆  
沙

苍  
蝇  
灰

青  
骊

古  
鼎  
灰

紫  
檀

牛  
角  
灰

火  
山  
棕

绀  
蝶

水  
牛  
灰

京  
元

酱  
色

璆  
琳

青  
灰

斑  
鸠  
灰

酱  
棕

栗  
棕

沙  
鱼  
灰

长  
石  
灰

暗  
驼  
棕

缁  
色

河  
豚  
灰

蒽  
油  
绿

海  
报  
灰

栗  
色

可  
可  
棕

目  
童  
子

玄  
青

柞  
叶  
棕

暮  
云  
灰

紫  
砂

古  
铜  
褐

蟹  
壳  
绿

焦  
茶  
绿

古  
铜  
绿

橄  
榄  
灰

鹤  
灰

淡  
松  
烟

淡  
栗  
棕

松  
鼠  
灰

驖  
骊

筍  
皮  
棕

枣  
褐

茶  
褐

皂  
色

蜜  
褐

霁  
蓝

中  
灰  
驼

咖  
啡

丁  
香  
棕

绿  
云

淡  
铁  
灰

瓦  
罐  
灰

赭  
石

暗  
海  
水  
绿

黄  
昏  
灰

棕  
榈  
绿

火  
岩  
棕

驼  
色

橡  
树  
棕

苍  
艾

珠  
母  
灰

石  
板  
灰

紫  
鼠

玳  
瑁

椒  
褐

鲸  
鱼  
灰

油  
葫  
芦

椰  
壳  
棕

麝  
香  
褐

烟  
墨

素  
綦

墨  
黪

橄  
榄  
绿

淡  
豆  
沙

霁  
红

黧

棕  
黑

褐  
色

朱  
石  
栗

潭  
水  
绿

緅  
絺

战  
舰  
灰

玄  
天

黝  
黑

绀

芒  
果  
棕

淡  
土  
黄

棕  
红

紫  
诰

鼠  
背  
灰

伽  
罗

燕  
羽  
灰

蟹  
壳  
灰

冥  
色

鸦  
雏

岩  
石  
棕

紫  
酱

鱼  
尾  
灰

驼  
褐

育  
阳  
染

狼  
烟  
灰

缊  
韨

蜴  
蜊  
绿

莱  
阳  
梨  
黄

檀  
褐

射  
干

淡  
咖  
啡

棕  
色

苍  
黄

黎

棠  
梨  
褐

石  
涅

黑  
朱

远  
志

蟹  
蝥  
红

中  
红  
灰

濯  
绛

綟  
绶

粽  
叶  
绿

灰  
绿

夏  
云  
灰

龟  
背  
黄

蚩  
尤  
旗

淡  
可  
可  
棕

山  
鸡  
褐

秋  
色

老  
僧  
衣

棕  
绿

吉  
金

碧  
螺  
春  
绿

茹  
藘

赭  
罗

芦  
灰

荆  
褐

鲛  
青

鹰  
背  
褐

苔  
绿

锌  
灰

绞  
衣

苏  
方

葡  
萄  
褐

嫩  
灰

雁  
灰

茶  
色

深  
灰

火  
泥  
棕

垩  
灰

雷  
雨  
垂

大  
云

荩  
篋

夜  
灰

棕  
黄

檀  
色

瓦  
灰

苔  
古

草  
灰  
绿

淡  
绿  
灰

银  
灰

沉  
香

红  
藤  
杖

迷  
楼  
灰

绛  
纱

猴  
毛  
灰

降  
真  
香

墨  
灰

明  
茶  
褐

绿  
豆  
褐

绾

石  
莲  
褐

老  
茯  
神

海  
鸥  
灰

烟  
红

淡  
赭

红  
䵂

青  
圭

蕉  
月

蒸  
栗

黄  
琮

藕  
丝  
褐

露  
褐

秋  
蓝

执  
大  
象

紫  
磨  
金

银  
褐

巨  
吕

明  
灰

大  
赤

黄  
埃

苍  
青

春  
碧

淡  
玫  
瑰  
灰

丁  
香  
褐

王  
刍

养  
生  
主

隐  
红  
灰

灰  
色

玄  
校

秋  
香

佩  
玖

鹿  
皮  
褐

镍  
灰

昏  
黄

绍  
衣

蛛  
网  
灰

黄  
螺

出  
岫

青  
鸾

尘  
灰

琬  
琰

茧  
色

沙  
饧

不  
皂

百  
灵  
鸟  
灰

冰  
山  
蓝

大  
块

紫  
花  
布

银  
鼠  
灰

珠  
子  
褐

青  
玉  
案

栾  
华

月  
灰

蓝  
灰  
色

芦  
穗  
灰

鸣  
珂

葭  
灰

淡  
银  
灰

甘  
石

月  
魄

中  
灰

枯  
黄

夏  
籥

太  
一  
余  
粮

黄  
梁

行  
香  
子

苍  
烟  
落  
照

星  
灰

石  
英

逍  
遥  
游

瓷  
秘

云  
母

草  
白

玉  
粉  
红

冻  
缥

石  
蜜

溶  
溶  
月

如  
梦  
令

月  
影  
白

鹿  
角  
棕

假  
山  
南

青  
白  
玉

霜  
地

赤  
璋

晓  
灰

缣  
湘

影  
青

仙  
米

肉  
红

大  
理  
石  
灰

花  
白

藕  
丝  
秋  
半

玛  
瑙  
灰

余  
白

香  
炉  
紫  
烟

筠  
雾

地  
籁

银  
鱼  
白

香  
皮

米  
汤  
娇

明  
月  
珰

穹  
灰

莲  
子  
白

浅  
灰

黄  
润

蓟  
粉  
红

蜜  
合

苍  
白

桑  
蕾

素  
采

弗  
肯  
红

菊  
蕾  
白

天  
球

淡  
青

韶  
粉

二  
目  
鱼

珍  
珠  
灰

云  
峰  
白

芡  
食  
白

骨  
缥

玉  
色

玉  
頩

吉  
量

缟

皦  
玉

浅  
云

莹  
白

缟  
羽

霜  
色

银  
白

铅  
白

蚌  
肉  
白

凝  
脂

山  
矾

乳  
白

鱼  
肚  
白

汉  
白  
玉

酇  
白

荼  
白

练  
色

玉  
白

粉  
色

象  
牙  
白

雪  
白

海  
参  
灰

瓷  
白

白  
色

\# pinyin as names widget \<- cc\$visual_colors( loc_range =
[c](https://rdrr.io/r/base/c.html)(1, 90), title = "Chinese Traditional
Colors", name_type = "pinyin" )
htmltools::[browsable](https://rstudio.github.io/htmltools/reference/browsable.html)(widget)

Chinese Traditional Colors

[TABLE]

\# rgb as names widget_rgb \<- cc\$visual_colors( loc_range =
[c](https://rdrr.io/r/base/c.html)(1, 90), title = "Colors with RGB
values", name_type = "rgb" )
htmltools::[browsable](https://rstudio.github.io/htmltools/reference/browsable.html)(widget_rgb)

Colors with RGB values

[TABLE]

\# hex as names widget_hex \<- cc\$visual_colors( loc_range =
[c](https://rdrr.io/r/base/c.html)(1, 90), title = "Colors with hex
codes", name_type = "hex" )
htmltools::[browsable](https://rstudio.github.io/htmltools/reference/browsable.html)(widget_hex)

Colors with hex codes

[TABLE]
