# Changelog

## thisplot 0.2.0

- **func**:
  - Chinese traditional color system
    - [`ChineseColors()`](https://mengxu98.github.io/thisplot/reference/ChineseColors.md):
      New function to create a Chinese traditional color system object
      with 1058 representative colors extracted from traditional Chinese
      color charts. Supports accessing colors by name (pinyin or
      Chinese), number, or hex code, creating color palettes, and
      generating segmented colormaps.
    - [`visual_colors()`](https://mengxu98.github.io/thisplot/reference/visual_colors.md):
      New function to visualize colors in HTML format with a grid of
      color swatches, supporting optional names, RGB values, or hex
      codes.
    - [`get_chinese_palettes()`](https://mengxu98.github.io/thisplot/reference/get_chinese_palettes.md):
      New function to get Chinese color palettes organized by color
      categories (blue, green, yellow, red, brown, purple, etc.) with
      automatic continuous palette generation.
    - [`print.ChineseColors()`](https://mengxu98.github.io/thisplot/reference/print.ChineseColors.md)
      and
      [`print.ChineseColorInfo()`](https://mengxu98.github.io/thisplot/reference/print.ChineseColorInfo.md):
      New print methods for ChineseColors objects to display color
      information.
- **data**:
  - `chinese_colors`: New data object containing 1058 Chinese
    traditional colors.
- **docs**:
  - Added comprehensive documentation for Chinese color system
    functions.
  - Updated package documentation to include Chinese traditional colors
    feature.

## thisplot 0.1.0

- initial version
