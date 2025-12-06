#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import csv
import sys
import os
import math
from pathlib import Path

try:
    import pandas as pd
except ImportError:
    print("Error: pandas package is required.")
    print("Install it with: pip install pandas openpyxl")
    sys.exit(1)

try:
    from pypinyin import lazy_pinyin, Style
except ImportError:
    print("Error: pypinyin package is required.")
    print("Install it with: pip install pypinyin")
    sys.exit(1)


def chinese_to_pinyin(chinese_text):
    """Convert Chinese text to pinyin without tones."""
    if not chinese_text or pd.isna(chinese_text) or chinese_text == "NA":
        raise ValueError(f"Invalid Chinese text: {chinese_text}")

    pinyin_list = lazy_pinyin(chinese_text, style=Style.NORMAL)
    pinyin = "".join(pinyin_list)

    pinyin = pinyin.lower()

    return pinyin


def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple (0-255)."""
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def rgb_to_xyz(r, g, b):
    """Convert RGB to XYZ color space (D65 illuminant)."""
    # Normalize to 0-1
    r, g, b = r / 255.0, g / 255.0, b / 255.0

    # Apply gamma correction
    def f(c):
        if c > 0.04045:
            return ((c + 0.055) / 1.055) ** 2.4
        else:
            return c / 12.92

    r, g, b = f(r), f(g), f(b)

    # Convert to XYZ using sRGB matrix
    x = (r * 0.4124564 + g * 0.3575761 + b * 0.1804375) * 100
    y = (r * 0.2126729 + g * 0.7151522 + b * 0.0721750) * 100
    z = (r * 0.0193339 + g * 0.1191920 + b * 0.9503041) * 100

    return (x, y, z)


def xyz_to_lab(x, y, z):
    """Convert XYZ to LAB color space (D65 illuminant)."""
    # D65 white point
    xn, yn, zn = 95.047, 100.000, 108.883

    def f(t):
        if t > (6 / 29) ** 3:
            return t ** (1 / 3)
        else:
            return (1 / 3) * ((29 / 6) ** 2) * t + 4 / 29

    fx = f(x / xn)
    fy = f(y / yn)
    fz = f(z / zn)

    L = 116 * fy - 16
    a = 500 * (fx - fy)
    b = 200 * (fy - fz)

    return (L, a, b)


def rgb_to_lab(rgb):
    """Convert RGB (0-255) to LAB color space."""
    r, g, b = rgb
    x, y, z = rgb_to_xyz(r, g, b)
    return xyz_to_lab(x, y, z)


def calculate_chroma(lab):
    """Calculate chroma (saturation) from LAB."""
    L, a, b = lab
    return math.sqrt(a * a + b * b)


def sort_colors_by_lab_improved(rows, category_name):
    """
    Improved color sorting using multiple LAB dimensions.
    Sorts by:
    1. Lightness (L*) - primary sort
    2. Chroma (saturation) - secondary sort for similar lightness
    3. Hue angle (atan2(b, a)) - tertiary sort for similar lightness and chroma
    This ensures visually smooth transitions while keeping bright colors together.
    """
    if len(rows) <= 1:
        return rows

    lab_data = []
    for idx, row in enumerate(rows):
        hex_color = row["hex"]
        if not hex_color:
            raise ValueError(f"Color hex code not found in row {idx}")
        rgb = hex_to_rgb(hex_color)
        lab = rgb_to_lab(rgb)
        L, a, b = lab

        chroma = calculate_chroma(lab)

        hue_angle = math.degrees(math.atan2(b, a))
        if hue_angle < 0:
            hue_angle += 360

        lab_data.append((idx, lab, chroma, hue_angle, row))

    lab_data.sort(key=lambda x: (x[1][0], -x[2], x[3]))

    return [item[4] for item in lab_data]


def main(delete_csv=False):
    """
    Main function to process Chinese colors.

    Args:
        delete_csv (bool): If True, delete CSV file after successfully saving RDA file.
                                     Default is True.
    """
    script_dir = Path(__file__).parent
    project_root = script_dir.parent

    excel_path = script_dir / "ChineseColors5.0.xlsx"
    csv_path = script_dir / "chinese_colors.csv"
    data_dir = project_root / "data"
    rda_path = data_dir / "chinese_colors.rda"

    if not excel_path.exists():
        print(f"Error: Excel file not found: {excel_path}")
        sys.exit(1)

    print(f"Reading Excel file: {excel_path}")

    all_sheets = pd.ExcelFile(excel_path)
    sheets = [s for s in all_sheets.sheet_names]

    print(f"Found sheets: {', '.join(sheets)}")

    required_columns = ["色名", "C", "M", "Y", "K", "R", "G", "B", "总"]

    all_data = []
    for sheet in sheets:
        print(f"  Reading sheet: {sheet}...")
        df = pd.read_excel(excel_path, sheet_name=sheet, header=1)

        available_cols = list(df.columns)
        missing_cols = [col for col in required_columns if col not in available_cols]
        if missing_cols:
            print(f"    Warning: Missing columns in sheet '{sheet}': {missing_cols}")
            print(f"    Available columns: {available_cols}")
            for missing_col in missing_cols:
                similar = [
                    c
                    for c in available_cols
                    if missing_col in str(c) or str(c) in missing_col
                ]
                if similar:
                    print(f"      Similar to '{missing_col}': {similar}")

        cols_to_use = [col for col in required_columns if col in df.columns]
        if len(cols_to_use) == 0:
            print(f"    Error: No required columns found in sheet '{sheet}'")
            continue

        df = df[cols_to_use]
        df["sheet_name"] = sheet
        all_data.append(df)
        print(f"    Rows: {len(df)}, Cols: {len(df.columns)}")

    if len(all_data) == 0:
        print("\nError: No data loaded from any sheet")
        sys.exit(1)

    df_all = pd.concat(all_data, ignore_index=True)
    print(f"\nTotal rows after merging: {len(df_all)}")
    print(f"Columns: {list(df_all.columns)}")

    name_col = "色名"
    r_col = "R"
    g_col = "G"
    b_col = "B"

    if name_col not in df_all.columns:
        print(f"\nError: Required column '{name_col}' not found")
        print(f"  Available columns: {list(df_all.columns)}")
        sys.exit(1)

    if (
        r_col not in df_all.columns
        or g_col not in df_all.columns
        or b_col not in df_all.columns
    ):
        print("\nError: Required RGB columns not found")
        print(f"  Available columns: {list(df_all.columns)}")
        print(f"  R column: {r_col if r_col in df_all.columns else 'NOT FOUND'}")
        print(f"  G column: {g_col if g_col in df_all.columns else 'NOT FOUND'}")
        print(f"  B column: {b_col if b_col in df_all.columns else 'NOT FOUND'}")
        sys.exit(1)

    print("\nUsing columns:")
    print(f"  Name: {name_col}")
    print(f"  R: {r_col}, G: {g_col}, B: {b_col}")

    category_map = {
        "红": "red",
        "橙": "orange",
        "黄": "yellow",
        "绿": "green",
        "青": "cyan",
        "蓝": "blue",
        "紫": "purple",
        "灰褐": "gray_brown",
    }

    print("\nProcessing colors...")
    colors_list = []

    short_names = []
    skipped_rows = []

    for idx, row in df_all.iterrows():
        name_ch_raw = row[name_col]
        if pd.isna(name_ch_raw):
            continue

        name_ch = str(name_ch_raw).strip()
        if name_ch == "nan" or name_ch == "":
            continue

        # Handle line breaks: replace newlines with spaces, then split and take first part
        name_ch = name_ch.replace("\n", " ").replace("\r", " ")

        # Handle slash: if there's a "/", take only the part before it
        if "/" in name_ch:
            name_ch = name_ch.split("/")[0].strip()

        name_ch = name_ch.strip()

        chinese_chars = [c for c in name_ch if "\u4e00" <= c <= "\u9fff"]
        if len(chinese_chars) == 0:
            continue

        if len(name_ch) > 10:
            continue

        category_chars = [
            "红",
            "橙",
            "黄",
            "绿",
            "青",
            "蓝",
            "紫",
            "灰",
            "褐",
            "黑",
            "白",
        ]
        r_val = row[r_col]
        g_val = row[g_col]
        b_val = row[b_col]

        if len(name_ch) == 1 and name_ch in category_chars:
            sheet_cat = str(row["sheet_name"]).strip()
            if name_ch == sheet_cat or name_ch in sheet_cat:
                rgb_str = "N/A"
                if not pd.isna(r_val) and not pd.isna(g_val) and not pd.isna(b_val):
                    try:
                        r = int(float(r_val))
                        g = int(float(g_val))
                        b = int(float(b_val))
                        rgb_str = f"({r}, {g}, {b})"
                    except:
                        pass
                short_names.append(
                    {"row": idx, "name": name_ch, "sheet": sheet_cat, "rgb": rgb_str}
                )
                continue

        if pd.isna(r_val) or pd.isna(g_val) or pd.isna(b_val):
            continue

        try:
            r = int(float(r_val))
            g = int(float(g_val))
            b = int(float(b_val))
        except (ValueError, TypeError):
            continue

        if not (0 <= r <= 255 and 0 <= g <= 255 and 0 <= b <= 255):
            continue

        category_ch = str(row["sheet_name"]).strip()
        if category_ch not in category_map:
            print(f"  Warning: Skipping row {idx}: Unknown category '{category_ch}'")
            continue

        category = category_map[category_ch]
        hex_color = f"#{r:02X}{g:02X}{b:02X}"
        rgb_str = f"({r}, {g}, {b})"

        try:
            name_pinyin = chinese_to_pinyin(name_ch)
            colors_list.append(
                {
                    "num": None,
                    "name": name_pinyin,
                    "name_ch": name_ch,
                    "rgb": rgb_str,
                    "hex": hex_color,
                    "category": category,
                    "category_ch": category_ch,
                }
            )
        except Exception as e:
            print(f"  Warning: Failed to convert '{name_ch}' to pinyin: {e}")

    print(f"Extracted {len(colors_list)} colors")

    if short_names:
        print(
            f"\nWarning: Found {len(short_names)} single-character color names that were skipped:"
        )
        print("  These might be truncated names")
        for item in short_names[:10]:
            print(
                f"    Row {item['row']}: '{item['name']}' in sheet '{item['sheet']}' (RGB: {item['rgb']})"
            )
        if len(short_names) > 10:
            print(f"    ... and {len(short_names) - 10} more")

    if skipped_rows:
        print(f"\nSkipped {len(skipped_rows)} rows due to missing data")

    print("\nSorting colors by category...")
    category_order = [
        "blue",
        "cyan",
        "green",
        "yellow",
        "orange",
        "red",
        "purple",
        "gray_brown",
    ]

    category_rows = {}
    for color in colors_list:
        cat = color["category"]
        if cat not in category_rows:
            category_rows[cat] = []
        category_rows[cat].append(color)

    sorted_colors = []
    for cat in category_order:
        if cat in category_rows:
            cat_rows = category_rows[cat]
            print(f"  Sorting {len(cat_rows)} colors in category '{cat}'...")
            cat_rows_sorted = sort_colors_by_lab_improved(cat_rows, cat)
            sorted_colors.extend(cat_rows_sorted)

    remaining_cats = set(category_rows.keys()) - set(category_order)
    for cat in sorted(remaining_cats):
        cat_rows = category_rows[cat]
        print(f"  Sorting {len(cat_rows)} colors in category '{cat}'...")
        cat_rows_sorted = sort_colors_by_lab_improved(cat_rows, cat)
        sorted_colors.extend(cat_rows_sorted)

    print("\nRemoving duplicate colors (same hex in same category)...")
    seen_hex_category = set()
    deduplicated_colors = []
    duplicates_removed = []

    for color in sorted_colors:
        hex_cat_key = (color["hex"], color["category"])
        if hex_cat_key not in seen_hex_category:
            seen_hex_category.add(hex_cat_key)
            deduplicated_colors.append(color)
        else:
            duplicates_removed.append(color)

    if duplicates_removed:
        print(f"  Removed {len(duplicates_removed)} duplicate colors:")
        for dup in duplicates_removed:
            print(f"    - {dup['name_ch']} ({dup['hex']}) in {dup['category']}")
    else:
        print("  No duplicates found.")

    sorted_colors = deduplicated_colors

    for idx, color in enumerate(sorted_colors, start=1):
        color["num"] = idx

    print(f"\nSaving CSV to {csv_path}...")
    fieldnames = ["num", "name", "name_ch", "rgb", "hex", "category", "category_ch"]
    with open(csv_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for color in sorted_colors:
            writer.writerow(color)

    print(f"CSV file saved: {csv_path}")
    print(f"Total colors: {len(sorted_colors)}")

    print("\nSample colors (verifying pinyin):")
    for color in sorted_colors[:10]:
        print(f"  {color['name_ch']} -> {color['name']}")

    print("\nChecking for potential pinyin issues by category...")

    colors_by_category = {}
    for color in sorted_colors:
        cat = color["category"]
        if cat not in colors_by_category:
            colors_by_category[cat] = []
        colors_by_category[cat].append(color)

    category_checks = {
        "blue": {"char": "蓝", "expected": "lan", "wrong": "la"},
        "red": {"char": "红", "expected": "hong"},
        "green": {"char": "绿", "expected": ["lv", "lu"]},
        "yellow": {"char": "黄", "expected": "huang"},
        "orange": {"char": "橙", "expected": "cheng"},
        "purple": {"char": "紫", "expected": "zi"},
        "cyan": {"char": "青", "expected": "qing"},
        "gray_brown": {"char": ["灰", "褐"], "expected": ["hui", "he"]},
    }

    issues_found = False
    total_checked = 0

    for cat in [
        "blue",
        "cyan",
        "green",
        "yellow",
        "orange",
        "red",
        "purple",
        "gray_brown",
    ]:
        if cat not in colors_by_category or cat not in category_checks:
            continue

        cat_colors = colors_by_category[cat]
        check = category_checks[cat]
        issues = []
        checked_count = 0

        for c in cat_colors:
            name_ch = c["name_ch"]
            name_pinyin = c["name"]

            if cat == "blue":
                if "蓝" in name_ch:
                    checked_count += 1
                    if "lan" not in name_pinyin and "la" in name_pinyin:
                        issues.append(c)
            elif cat == "red":
                if "红" in name_ch:
                    checked_count += 1
                    if "hong" not in name_pinyin:
                        issues.append(c)
            elif cat == "green":
                if "绿" in name_ch:
                    checked_count += 1
                    expected_list = (
                        check["expected"]
                        if isinstance(check["expected"], list)
                        else [check["expected"]]
                    )
                    if not any(exp in name_pinyin for exp in expected_list):
                        issues.append(c)
            elif cat == "yellow":
                if "黄" in name_ch:
                    checked_count += 1
                    if "huang" not in name_pinyin:
                        issues.append(c)
            elif cat == "orange":
                if "橙" in name_ch:
                    checked_count += 1
                    if "cheng" not in name_pinyin:
                        issues.append(c)
            elif cat == "purple":
                if "紫" in name_ch:
                    checked_count += 1
                    if "zi" not in name_pinyin:
                        issues.append(c)
            elif cat == "cyan":
                if "青" in name_ch:
                    checked_count += 1
                    if "qing" not in name_pinyin:
                        issues.append(c)
            elif cat == "gray_brown":
                chars = (
                    check["char"]
                    if isinstance(check["char"], list)
                    else [check["char"]]
                )
                expected_list = (
                    check["expected"]
                    if isinstance(check["expected"], list)
                    else [check["expected"]]
                )
                for char, exp in zip(chars, expected_list):
                    if char in name_ch:
                        checked_count += 1
                        if exp not in name_pinyin:
                            issues.append(c)
                            break

        total_checked += checked_count

        if issues:
            issues_found = True
            print(
                f"\n{cat.upper()} ({len(cat_colors)} colors, checked {checked_count}) - Found {len(issues)} issues:"
            )

            display_count = min(5, len(issues))
            for i in range(0, display_count, 3):
                row_issues = issues[i : i + 3]
                row_str = " | ".join(
                    [f"{c['name_ch']}->{c['name']}" for c in row_issues]
                )
                print(f"  {row_str}")
            if len(issues) > 5:
                print(f"  ... and {len(issues) - 5} more")
        else:
            print(
                f"{cat.upper()} ({len(cat_colors)} colors, checked {checked_count}) - ✓ OK"
            )

    print(f"\nTotal: Checked {total_checked} color names across all categories")
    if not issues_found:
        print("✓ No pinyin issues found in any category!")

    print(f"\nSaving RDA file to {rda_path}...")
    data_dir.mkdir(exist_ok=True)

    csv_abs_path = csv_path.resolve()
    rda_abs_path = rda_path.resolve()

    r_script = f'''chinese_colors <- read.csv("{csv_abs_path}", encoding="UTF-8", stringsAsFactors=FALSE)
usethis::use_data(chinese_colors, compress="xz", overwrite=TRUE)
cat("RDA file saved to {rda_abs_path}\\n")
'''

    temp_r_script = script_dir / "temp_save_rda.R"
    with open(temp_r_script, "w", encoding="utf-8") as f:
        f.write(r_script)

    try:
        import subprocess

        result = subprocess.run(
            ["Rscript", str(temp_r_script)], capture_output=True, text=True, check=True
        )
        print(result.stdout)
        if result.stderr:
            print("R warnings:", result.stderr)
        print("RDA file saved successfully!")

        if delete_csv and csv_path.exists():
            try:
                csv_path.unlink()
                print(f"CSV file deleted: {csv_path}")
            except Exception as e:
                print(f"Warning: Failed to delete CSV file: {e}")
    except subprocess.CalledProcessError as e:
        print(f"Warning: Failed to save RDA file: {e}")
    finally:
        if temp_r_script.exists():
            temp_r_script.unlink()

    print("\nDone!")


if __name__ == "__main__":
    main()
