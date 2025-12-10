# thisplot

# thisplot 0.3.0

* **func**:
  * Color search and retrieval
    * `get_colors()`: New function to search for colors in the Chinese colors dataset and all available palettes. Supports searching by palette names, color names (pinyin or Chinese), numbers, or hex codes. Automatically reports which palette(s) contain the found colors.
    * `print.colors()`: New print method for colors objects to display color information with ANSI color support in terminal.

* **enhancement**:
  * Updated Chinese color system with improved functionality.

# thisplot 0.2.0

* **func**:
  * Chinese traditional color system
    * `ChineseColors()`: New function to create a Chinese traditional color system object with 1058 representative colors extracted from traditional Chinese color charts. Supports accessing colors by name (pinyin or Chinese), number, or hex code, creating color palettes, and generating segmented colormaps.
    * `visual_colors()`: New function to visualize colors in HTML format with a grid of color swatches, supporting optional names, RGB values, or hex codes.
    * `get_chinese_palettes()`: New function to get Chinese color palettes organized by color categories (blue, green, yellow, red, brown, purple, etc.) with automatic continuous palette generation.

* **data**:
  * `chinese_colors`: New data object containing 1058 Chinese traditional colors.

* **docs**:
  * Added comprehensive documentation for Chinese color system functions.
  * Updated package documentation to include Chinese traditional colors feature.

# thisplot 0.1.0

* initial version
