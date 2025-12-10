#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import csv
import sys
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

BASE_CHINESE_COLORS = [
    "#1772B4",  # 群青   蓝 - elegant blue (slightly high saturation but acceptable)
    "#0AA344",  # 青葱   绿 - vibrant green (slightly high saturation but acceptable)
    "#F9BD10",  # 浅烙黄  黄 - bright yellow (high saturation/brightness, kept for cultural significance)
    "#F97D1C",  # 橘橙   橙 - bright orange (high saturation/brightness, kept for cultural significance)
    "#ED5736",  # 妃色     红 - elegant red (slightly high brightness but acceptable)
    "#D70440",  # 朱色   红 - vibrant red (high saturation, kept for cultural significance)
    "#5976BA",  # 苍苍   蓝 - elegant blue-gray (optimal elegance)
    "#8076A3",  # 藤萝紫  紫 - elegant purple (low saturation but acceptable)
]


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


def calculate_lab_distance(color1_hex, color2_hex):
    """Calculate perceptual color distance in LAB color space.

    LAB color space is perceptually uniform, so distance in LAB
    better represents visual distinguishability than RGB or HSV.

    Args:
        color1_hex: First color as hex string
        color2_hex: Second color as hex string

    Returns:
        Euclidean distance in LAB color space (higher = more distinguishable)
    """
    rgb1 = hex_to_rgb(color1_hex)
    rgb2 = hex_to_rgb(color2_hex)
    lab1 = rgb_to_lab(rgb1)
    lab2 = rgb_to_lab(rgb2)

    L1, a1, b1 = lab1
    L2, a2, b2 = lab2
    distance = math.sqrt((L2 - L1) ** 2 + (a2 - a1) ** 2 + (b2 - b1) ** 2)
    return distance


def rgb_to_hsv(rgb):
    """Convert RGB (0-255) to HSV color space.

    Returns:
        tuple: (H, S, V) where H is hue in degrees (0-360), S and V are 0-1
    """
    r, g, b = rgb[0] / 255.0, rgb[1] / 255.0, rgb[2] / 255.0

    max_val = max(r, g, b)
    min_val = min(r, g, b)
    delta = max_val - min_val

    V = max_val

    if max_val == 0:
        S = 0
    else:
        S = delta / max_val

    if delta == 0:
        H = 0
    elif max_val == r:
        H = 60 * (((g - b) / delta) % 6)
    elif max_val == g:
        H = 60 * (((b - r) / delta) + 2)
    else:
        H = 60 * (((r - g) / delta) + 4)

    if H < 0:
        H += 360

    return (H, S, V)


def limit_to_base_hue_families(all_colors, base_set8, max_hue_diff=22.5):
    base_hues = []
    for hex_color in base_set8:
        rgb = hex_to_rgb(hex_color)
        hsv = rgb_to_hsv(rgb)
        base_hues.append(hsv[0])

    def min_hue_distance(h):
        return min(min(abs(h - bh), 360.0 - abs(h - bh)) for bh in base_hues)

    filtered = []
    for hex_color in all_colors:
        rgb = hex_to_rgb(hex_color)
        hsv = rgb_to_hsv(rgb)
        hue = hsv[0]
        if min_hue_distance(hue) <= max_hue_diff:
            filtered.append(hex_color)

    return filtered


def filter_vibrant_colors(
    hex_colors, min_saturation=0.55, min_value=0.5, max_value=0.8
):
    """Filter colors to keep only vibrant colors with appropriate brightness.

    Filters out dark colors (deep blue, deep brown, deep purple, etc.) and overly bright colors.
    Keeps only colors with moderate to high saturation and medium brightness.

    Args:
        hex_colors: List of hex color strings
        min_saturation: Minimum saturation (0-1), default 0.55 to allow more elegant colors
        min_value: Minimum brightness (0-1), default 0.5 to avoid dark colors
        max_value: Maximum brightness (0-1), default 0.8 to avoid overly bright colors

    Returns:
        List of hex color strings that meet the vibrant color criteria
    """
    vibrant_colors = []

    for hex_color in hex_colors:
        rgb = hex_to_rgb(hex_color)
        hsv = rgb_to_hsv(rgb)
        saturation = hsv[1]
        value = hsv[2]

        if saturation >= min_saturation and min_value <= value <= max_value:
            vibrant_colors.append(hex_color)

    return vibrant_colors


def filter_vibrant_colors_strict(
    hex_colors, min_saturation=0.6, min_value=0.55, max_value=0.8
):
    vibrant_colors = []

    for hex_color in hex_colors:
        rgb = hex_to_rgb(hex_color)
        hsv = rgb_to_hsv(rgb)
        hue = hsv[0]
        saturation = hsv[1]
        value = hsv[2]

        if saturation < min_saturation or not (min_value <= value <= max_value):
            continue

        if 15 <= hue < 45:
            if saturation < 0.75:
                continue

        vibrant_colors.append(hex_color)

    return vibrant_colors


def score_colors(candidate_color, target_hue, selected_colors, min_lab_distance):
    """Score a candidate color for interpolation.
    Args:
        candidate_color: Candidate color hex string
        target_hue: Target hue position (0-360)
        selected_colors: List of already selected colors
        min_lab_distance: Minimum required LAB distance

    Returns:
        Tuple of (score, min_lab_dist_to_selected)
        score: Higher is better (negative if doesn't meet min distance requirement)
        min_lab_dist_to_selected: Minimum LAB distance to selected colors
    """
    rgb = hex_to_rgb(candidate_color)
    hsv = rgb_to_hsv(rgb)
    hue = hsv[0]
    saturation = hsv[1]
    value = hsv[2]

    dist1 = abs(target_hue - hue)
    dist2 = 360.0 - dist1
    hue_distance = min(dist1, dist2)

    min_lab_dist = float("inf")
    if selected_colors:
        for selected_color in selected_colors:
            lab_dist = calculate_lab_distance(candidate_color, selected_color)
            min_lab_dist = min(min_lab_dist, lab_dist)
    else:
        min_lab_dist = float("inf")

    if min_lab_dist < min_lab_distance:
        return (-1, min_lab_dist)

    brightness_bonus = 0
    if 0.60 <= value <= 0.80:
        brightness_bonus = 5
    else:
        brightness_bonus = -abs(value - 0.70) * 30

    saturation_bonus = 0
    if 0.55 <= saturation <= 0.85:
        saturation_bonus = 5
    else:
        saturation_bonus = -abs(saturation - 0.70) * 20

    score = (
        -hue_distance
        + (min_lab_dist - min_lab_distance) * 0.5
        + saturation_bonus
        + brightness_bonus
    )
    return (score, min_lab_dist)


def color_order(colors, min_hue_gap=30, min_lab_distance=15):
    """Optimize color order to maximize distinguishability between adjacent colors.
    Args:
        colors: List of hex color strings
        min_hue_gap: Minimum hue gap between adjacent colors (degrees, default 30)
        min_lab_distance: Minimum LAB distance between adjacent colors (default 15)

    Returns:
        List of hex colors arranged to maximize adjacent color distinguishability
    """
    if len(colors) <= 1:
        return colors

    best_start = colors[0]
    best_start_sat = 0
    for color in colors:
        rgb = hex_to_rgb(color)
        hsv = rgb_to_hsv(rgb)
        if hsv[1] > best_start_sat:
            best_start_sat = hsv[1]
            best_start = color

    ordered = [best_start]
    remaining = [c for c in colors if c != best_start]

    while remaining:
        last_color = ordered[-1]
        best_next = None
        best_score = -1

        for candidate in remaining:
            rgb_last = hex_to_rgb(last_color)
            hsv_last = rgb_to_hsv(rgb_last)
            hue_last = hsv_last[0]

            rgb_cand = hex_to_rgb(candidate)
            hsv_cand = rgb_to_hsv(rgb_cand)
            hue_cand = hsv_cand[0]

            dist1 = abs(hue_cand - hue_last)
            dist2 = 360.0 - dist1
            hue_gap = min(dist1, dist2)

            lab_dist = calculate_lab_distance(last_color, candidate)

            if hue_gap < min_hue_gap:
                score = lab_dist * 0.5
            else:
                score = lab_dist + hue_gap * 0.5

            if score > best_score:
                best_score = score
                best_next = candidate

        if best_next:
            ordered.append(best_next)
            remaining.remove(best_next)
        else:
            ordered.append(remaining[0])
            remaining.remove(remaining[0])

    return ordered


def interpolate_colors_from_set8(base_set8, all_colors, target_size):
    """Interpolate colors based on ChineseSet8 hue positions.

    Strategy:
    1. Calculate hue positions of base_set8 colors
    2. Create target hue positions evenly distributed on hue circle (target_size positions)
    3. For each target position:
       - If a base_set8 color matches (within threshold), use it
       - Otherwise, find the closest color from all_colors that matches the target hue
    4. Filter selected colors to ensure vibrancy

    Args:
        base_set8: List of 8 base hex colors (ChineseSet8)
        all_colors: List of all available hex colors to choose from
        target_size: Target total number of colors (16, 32, 64, 128)

    Returns:
        List of hex colors with base_set8 colors prioritized and interpolated colors,
        sorted by hue position
    """
    if target_size <= len(base_set8):
        return base_set8[:target_size] if target_size < len(base_set8) else base_set8

    base_hue_map = {}
    base_colors_with_hue = []
    for hex_color in base_set8:
        rgb = hex_to_rgb(hex_color)
        hsv = rgb_to_hsv(rgb)
        hue = hsv[0]
        base_hue_map[hue] = hex_color
        base_colors_with_hue.append((hue, hex_color))

    hue_step = 360.0 / target_size
    target_hue_positions = [i * hue_step for i in range(target_size)]

    base_set = set(base_set8)
    available_colors = [c for c in all_colors if c not in base_set]

    vibrant_colors = filter_vibrant_colors_strict(
        available_colors, min_saturation=0.6, min_value=0.55, max_value=0.8
    )
    vibrant_colors = limit_to_base_hue_families(
        vibrant_colors,
        base_set8,
        max_hue_diff=22.5,
    )

    if len(vibrant_colors) < (target_size - len(base_set8)):
        relaxed = filter_vibrant_colors_strict(
            available_colors, min_saturation=0.55, min_value=0.5, max_value=0.85
        )
        relaxed = limit_to_base_hue_families(relaxed, base_set8, max_hue_diff=25.0)
        vibrant_colors = relaxed

    if len(vibrant_colors) < (target_size - len(base_set8)):
        relaxed2 = filter_vibrant_colors(
            available_colors, min_saturation=0.5, min_value=0.5, max_value=0.8
        )
        relaxed2 = limit_to_base_hue_families(relaxed2, base_set8, max_hue_diff=30.0)
        vibrant_colors = relaxed2

    if len(vibrant_colors) < (target_size - len(base_set8)):
        vibrant_colors = available_colors

    available_colors_by_hue = {}
    for hex_color in vibrant_colors:
        rgb = hex_to_rgb(hex_color)
        hsv = rgb_to_hsv(rgb)
        hue = hsv[0]
        if hue not in available_colors_by_hue:
            available_colors_by_hue[hue] = []
        available_colors_by_hue[hue].append((hex_color, hsv[1], hsv[2]))

    if target_size <= 16:
        min_lab_distance = 25
    elif target_size <= 32:
        min_lab_distance = 20
    elif target_size <= 64:
        min_lab_distance = 18
    else:
        min_lab_distance = 15

    selected_colors = []
    used_colors = set()

    base_assignments = {}
    base_colors_assigned = set()

    for base_hue, base_color in base_colors_with_hue:
        best_target_idx = 0
        best_target_dist = 360.0
        for idx, target_hue in enumerate(target_hue_positions):
            dist1 = abs(target_hue - base_hue)
            dist2 = 360.0 - dist1
            dist = min(dist1, dist2)
            if dist < best_target_dist:
                best_target_dist = dist
                best_target_idx = idx

        if best_target_idx not in base_assignments:
            base_assignments[best_target_idx] = base_color
            base_colors_assigned.add(base_color)

    for idx, target_hue in enumerate(target_hue_positions):
        best_color = None
        best_score = float("-inf")

        if idx in base_assignments:
            base_color = base_assignments[idx]
            if len(selected_colors) == 0:
                best_color = base_color
                selected_colors.append(best_color)
                used_colors.add(best_color)
                continue
            else:
                score, min_lab_dist = score_colors(
                    base_color, target_hue, selected_colors, min_lab_distance
                )
                if score >= 0:
                    best_color = base_color
                    selected_colors.append(best_color)
                    used_colors.add(best_color)
                    continue

        for base_hue, base_color in base_colors_with_hue:
            if base_color in used_colors:
                continue
            score, min_lab_dist = score_colors(
                base_color, target_hue, selected_colors, min_lab_distance
            )
            if score > best_score:
                best_score = score
                best_color = base_color

        if best_color is None or best_score < 0:
            for hex_color in vibrant_colors:
                if hex_color in used_colors:
                    continue
                score, min_lab_dist = score_colors(
                    hex_color, target_hue, selected_colors, min_lab_distance
                )
                if score > best_score:
                    best_score = score
                    best_color = hex_color

        if best_color is not None and best_score >= 0:
            selected_colors.append(best_color)
            used_colors.add(best_color)
        elif best_color is None or best_score < 0:
            min_lab_distance_relaxed = min_lab_distance * 0.8
            best_color_relaxed = None
            best_score_relaxed = float("-inf")

            for hex_color in vibrant_colors:
                if hex_color in used_colors:
                    continue
                score, min_lab_dist = score_colors(
                    hex_color, target_hue, selected_colors, min_lab_distance_relaxed
                )
                if score > best_score_relaxed:
                    best_score_relaxed = score
                    best_color_relaxed = hex_color

            if best_color_relaxed is not None and best_score_relaxed >= 0:
                selected_colors.append(best_color_relaxed)
                used_colors.add(best_color_relaxed)
            else:
                best_color_fallback = None
                best_distance_fallback = 360.0
                for hex_color in vibrant_colors:
                    if hex_color in used_colors:
                        continue
                    rgb = hex_to_rgb(hex_color)
                    hsv = rgb_to_hsv(rgb)
                    hue = hsv[0]
                    dist1 = abs(target_hue - hue)
                    dist2 = 360.0 - dist1
                    dist = min(dist1, dist2)
                    if dist < best_distance_fallback:
                        best_distance_fallback = dist
                        best_color_fallback = hex_color

                if best_color_fallback is not None:
                    selected_colors.append(best_color_fallback)
                    used_colors.add(best_color_fallback)

    for base_color in base_set8:
        if base_color not in used_colors:
            if len(selected_colors) < target_size:
                selected_colors.append(base_color)
                used_colors.add(base_color)
            else:
                rgb = hex_to_rgb(base_color)
                hsv = rgb_to_hsv(rgb)
                base_hue = hsv[0]

                worst_idx = 0
                worst_dist = 0
                for idx, color in enumerate(selected_colors):
                    if color in base_set8:
                        continue
                    if idx >= len(target_hue_positions):
                        continue
                    c_rgb = hex_to_rgb(color)
                    c_hsv = rgb_to_hsv(c_rgb)
                    c_hue = c_hsv[0]
                    target_hue = target_hue_positions[idx]
                    dist1 = abs(target_hue - c_hue)
                    dist2 = 360.0 - dist1
                    dist = min(dist1, dist2)
                    if dist > worst_dist:
                        worst_dist = dist
                        worst_idx = idx

                if worst_idx < len(target_hue_positions):
                    target_hue = target_hue_positions[worst_idx]
                    base_dist1 = abs(target_hue - base_hue)
                    base_dist2 = 360.0 - base_dist1
                    base_dist = min(base_dist1, base_dist2)
                    if base_dist < worst_dist:
                        selected_colors[worst_idx] = base_color
                        used_colors.add(base_color)

    if len(selected_colors) < target_size:
        for hex_color in vibrant_colors:
            if hex_color not in used_colors and len(selected_colors) < target_size:
                selected_colors.append(hex_color)
                used_colors.add(hex_color)

    if target_size <= 16:
        min_hue_gap = 50
        min_lab_dist_for_order = 25
    elif target_size <= 32:
        min_hue_gap = 40
        min_lab_dist_for_order = 20
    elif target_size <= 64:
        min_hue_gap = 35
        min_lab_dist_for_order = 18
    else:
        min_hue_gap = 30
        min_lab_dist_for_order = 15

    ordered_colors = color_order(
        selected_colors,
        min_hue_gap=min_hue_gap,
        min_lab_distance=min_lab_dist_for_order,
    )

    return ordered_colors[:target_size]


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


def main(delete_csv=False, filter_colors=False):
    """
    Main function to process Chinese colors.

    Args:
        delete_csv (bool): If True, delete CSV file after successfully saving RDA file.
                           Default is False.
        filter_colors (bool): If True, apply color quality filtering and distance optimization.
                              If False, keep all unique colors without filtering.
                              Default is False.
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

        name_ch = name_ch.replace("\n", " ").replace("\r", " ")

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
                    except (ValueError, TypeError):
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

    if filter_colors:
        print(f"\nOptimizing colors based on LAB color space distance...")
        print(f"  Initial colors: {len(sorted_colors)}")
    else:
        print(f"\nSkipping color filtering (filter_colors=False)...")
        print(f"  Total unique colors: {len(sorted_colors)}")

    if filter_colors:
        seen_hex = set()
        unique_colors = []
        for color in sorted_colors:
            if color["hex"] not in seen_hex:
                seen_hex.add(color["hex"])
                unique_colors.append(color)

        print(f"  Unique colors: {len(unique_colors)}")

        color_lab_data = []
        for color in unique_colors:
            hex_color = color["hex"]
            rgb = hex_to_rgb(hex_color)
            lab = rgb_to_lab(rgb)
            color_lab_data.append(
                {
                    "color": color,
                    "hex": hex_color,
                    "lab": lab,
                    "L": lab[0],
                    "a": lab[1],
                    "b": lab[2],
                }
            )

        filtered_colors = []
        for item in color_lab_data:
            L, a, b = item["lab"]
            chroma = calculate_chroma(item["lab"])
            if 10 <= L <= 90 and chroma >= 5:
                filtered_colors.append(item)

        print(f"  After quality filter: {len(filtered_colors)} colors")

        def delta_e_76(lab1, lab2):
            """Calculate Delta E (CIE76) color difference."""
            L1, a1, b1 = lab1
            L2, a2, b2 = lab2
            return math.sqrt((L2 - L1) ** 2 + (a2 - a1) ** 2 + (b2 - b1) ** 2)

        min_distance = 5.0

        optimized_colors = []
        for i, item in enumerate(filtered_colors):
            if i == 0:
                optimized_colors.append(item)
                continue

            too_similar = False
            for selected in optimized_colors:
                distance = delta_e_76(item["lab"], selected["lab"])
                if distance < min_distance:
                    too_similar = True
                    break

            if not too_similar:
                optimized_colors.append(item)

        print(f"  After distance optimization: {len(optimized_colors)} colors")
        print(
            f"  Removed {len(filtered_colors) - len(optimized_colors)} similar colors"
        )

        sorted_colors = [item["color"] for item in optimized_colors]
    else:
        seen_hex = set()
        unique_colors = []
        for color in sorted_colors:
            if color["hex"] not in seen_hex:
                seen_hex.add(color["hex"])
                unique_colors.append(color)
        sorted_colors = unique_colors
        print(f"  Kept all {len(sorted_colors)} unique colors (no filtering applied)")

    for idx, color in enumerate(sorted_colors, start=1):
        color["num"] = idx

    print(f"\nFinal color count: {len(sorted_colors)}")

    print(f"\nGenerating Chinese color sets...")

    color_sets = {}
    color_sets["ChineseSet8"] = BASE_CHINESE_COLORS.copy()
    print(f"  ChineseSet8: {len(color_sets['ChineseSet8'])} colors (base colors)")

    print(f"    Base colors:")
    for hex_color in BASE_CHINESE_COLORS:
        rgb = hex_to_rgb(hex_color)
        hsv = rgb_to_hsv(rgb)
        hue_name = ""
        if 0 <= hsv[0] < 30 or hsv[0] >= 330:
            hue_name = "red"
        elif 30 <= hsv[0] < 60:
            hue_name = "orange"
        elif 60 <= hsv[0] < 90:
            hue_name = "yellow"
        elif 90 <= hsv[0] < 150:
            hue_name = "green"
        elif 150 <= hsv[0] < 210:
            hue_name = "cyan"
        elif 210 <= hsv[0] < 270:
            hue_name = "blue"
        elif 270 <= hsv[0] < 330:
            hue_name = "purple"
        print(
            f"      {hex_color}: hue={hsv[0]:.1f}° ({hue_name}), S={hsv[1]:.2f}, V={hsv[2]:.2f}"
        )

    main_color_list = [color["hex"] for color in sorted_colors]
    seen = set()
    unique_main_colors = []
    for hex_color in main_color_list:
        if hex_color not in seen:
            seen.add(hex_color)
            unique_main_colors.append(hex_color)

    print(f"  Main color list: {len(unique_main_colors)} colors")

    set_sizes = [16, 32, 64, 128]
    for size in set_sizes:
        selected_colors = interpolate_colors_from_set8(
            BASE_CHINESE_COLORS, unique_main_colors, size
        )
        color_sets[f"ChineseSet{size}"] = selected_colors
        print(
            f"  ChineseSet{size}: {len(selected_colors)} colors (interpolated from {len(BASE_CHINESE_COLORS)} base colors)"
        )

        color_hue_info = []
        for hex_color in selected_colors:
            rgb = hex_to_rgb(hex_color)
            hsv = rgb_to_hsv(rgb)
            color_hue_info.append(
                {
                    "hex": hex_color,
                    "hue": hsv[0],
                    "saturation": hsv[1],
                    "value": hsv[2],
                }
            )

        color_hue_info.sort(key=lambda x: x["hue"])
        hues = [ci["hue"] for ci in color_hue_info]

        print(
            f"    Generated ChineseSet{size}: {len(color_sets[f'ChineseSet{size}'])} colors"
        )

        if len(hues) > 1:
            min_spacing = 360.0
            max_spacing = 0.0
            spacings = []

            for i in range(len(hues)):
                next_i = (i + 1) % len(hues)
                spacing = (hues[next_i] - hues[i]) % 360
                spacings.append(spacing)
                min_spacing = min(min_spacing, spacing)
                max_spacing = max(max_spacing, spacing)

            avg_spacing = sum(spacings) / len(spacings)

            max_gap = max(spacings)

            if max_gap > 180:
                hue_range = 360.0 - max_gap
            else:
                hue_range = max(hues) - min(hues)

            print(f"    Hue distribution:")
            print(
                f"      Range: {min(hues):.1f}° - {max(hues):.1f}° (span: {hue_range:.1f}°)"
            )
            print(
                f"      Spacing: min={min_spacing:.1f}°, max={max_spacing:.1f}°, avg={avg_spacing:.1f}°"
            )
            print(f"      Target spacing: {360.0 / size:.1f}°")

            print(f"    Selected colors (ordered by hue):")
            for ci in color_hue_info:
                hue_name = ""
                if 0 <= ci["hue"] < 30 or ci["hue"] >= 330:
                    hue_name = "red"
                elif 30 <= ci["hue"] < 60:
                    hue_name = "orange"
                elif 60 <= ci["hue"] < 90:
                    hue_name = "yellow"
                elif 90 <= ci["hue"] < 150:
                    hue_name = "green"
                elif 150 <= ci["hue"] < 210:
                    hue_name = "cyan"
                elif 210 <= ci["hue"] < 270:
                    hue_name = "blue"
                elif 270 <= ci["hue"] < 330:
                    hue_name = "purple"

                print(
                    f"      {ci['hex']}: hue={ci['hue']:.1f}° ({hue_name}), S={ci['saturation']:.2f}, V={ci['value']:.2f}"
                )
        else:
            print(f"    Only 1 color selected")

    print("\nSample colors (verifying pinyin):")
    for color in sorted_colors[:10]:
        print(f"  {color['name_ch']} -> {color['name']}")

    print(
        "\nChecking for potential pinyin issues by category (final optimized colors)..."
    )

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

    print(f"\nSaving CSV to {csv_path}...")
    fieldnames = ["num", "name", "name_ch", "rgb", "hex", "category", "category_ch"]
    with open(csv_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for color in sorted_colors:
            writer.writerow(color)

    print(f"CSV file saved: {csv_path}")
    print(f"Total optimized colors: {len(sorted_colors)}")

    print(f"\nSaving RDA file to {rda_path}...")
    data_dir.mkdir(exist_ok=True)

    csv_abs_path = csv_path.resolve()
    rda_abs_path = rda_path.resolve()

    r_script = f'''chinese_colors <- read.csv("{csv_abs_path}", encoding="UTF-8", stringsAsFactors=FALSE)
chinese_color_sets <- list(
'''

    for set_name, colors_list in color_sets.items():
        colors_str = ", ".join([f'"{c}"' for c in colors_list])
        r_script += f"  {set_name} = c({colors_str}),\n"

    r_script = r_script.rstrip(",\n") + "\n)\n"
    r_script += f"""
for (set_name in names(chinese_color_sets)) {{
  attr(chinese_color_sets[[set_name]], "type") <- "discrete"
}}
attr(chinese_colors, "color_sets") <- chinese_color_sets
class(chinese_colors) <- c("chinese_colors", class(chinese_colors))
`$.chinese_colors` <- function(x, name) {{
  if (name %in% names(x)) {{
    return(x[[name]])
  }}
  color_sets <- attr(x, "color_sets", exact = TRUE)
  if (!is.null(color_sets) && name %in% names(color_sets)) {{
    return(color_sets[[name]])
  }}
  return(NULL)
}}

usethis::use_data(chinese_colors, compress="xz", overwrite=TRUE)
cat("RDA file saved to {rda_abs_path}\\n")
"""

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
            print("R messages:")
            print(result.stderr)
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
    parser = argparse.ArgumentParser(
        description="Process Chinese traditional colors from Excel file and generate optimized color data.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Default: filter colors enabled
  python3 colors/ChineseColors.py
  
  # Disable color filtering (keep all colors)
  python3 colors/ChineseColors.py --no-filter-colors
  
  # Enable color filtering explicitly
  python3 colors/ChineseColors.py --filter-colors
  
  # Delete CSV after processing
  python3 colors/ChineseColors.py --delete-csv
  
  # Combine options
  python3 colors/ChineseColors.py --no-filter-colors --delete-csv
        """,
    )
    parser.add_argument(
        "--delete-csv",
        action="store_true",
        default=False,
        help="Delete CSV file after successfully saving RDA file (default: False)",
    )
    parser.add_argument(
        "--filter-colors",
        action="store_true",
        default=None,
        help="Enable color quality filtering and distance optimization (default: False)",
    )
    parser.add_argument(
        "--no-filter-colors",
        dest="filter_colors",
        action="store_false",
        help="Disable color filtering (keep all unique colors without filtering)",
    )

    args = parser.parse_args()

    filter_colors = args.filter_colors if args.filter_colors is not None else False

    main(delete_csv=args.delete_csv, filter_colors=filter_colors)
