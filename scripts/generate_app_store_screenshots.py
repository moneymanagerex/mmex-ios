#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import textwrap

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "Screenshots" / "2026-refresh" / "raw"
OUTPUT_DIR = ROOT / "docs" / "assets" / "app-store"
ICON_PATH = ROOT / "MMEX" / "Assets.xcassets" / "AppIcon.appiconset" / "mmex_green.png"

TEXT_COLOR = (255, 255, 255, 255)
MUTED_TEXT_COLOR = (230, 242, 236, 255)
CHIP_TEXT_COLOR = (17, 24, 39, 255)
SHADOW_COLOR = (0, 0, 0, 120)
BRAND_GREEN = (32, 201, 120, 255)
BRAND_GREEN_DARK = (13, 148, 87, 255)
CHIP_FILL = (255, 255, 255, 225)


@dataclass(frozen=True)
class ScreenshotSpec:
    source: str
    output: str
    title: str
    subtitle: str
    chips: tuple[str, ...]


SPECS = (
    ScreenshotSpec(
        source="overview.png",
        output="01-overview.png",
        title="See your money clearly",
        subtitle="Balances, trends, and recent activity in one secure overview.",
        chips=("Encrypted", "Offline first", "Net worth"),
    ),
    ScreenshotSpec(
        source="enter.png",
        output="02-entry.png",
        title="Record transactions fast",
        subtitle="Capture income, expenses, transfers, and split entries in seconds.",
        chips=("Quick entry", "Split transactions", "Transfers"),
    ),
    ScreenshotSpec(
        source="journal.png",
        output="03-journal.png",
        title="Stay on top of activity",
        subtitle="Review recent transactions with clear dates, categories, and amounts.",
        chips=("Recent activity", "Readable history", "Daily tracking"),
    ),
    ScreenshotSpec(
        source="insights.png",
        output="04-insights.png",
        title="Spot trends quickly",
        subtitle="Explore income and expense patterns with clear charts and summaries.",
        chips=("Charts", "Insights", "Trends"),
    ),
    ScreenshotSpec(
        source="manage.png",
        output="05-manage.png",
        title="Organize every detail",
        subtitle="Manage accounts, categories, payees, budgets, reports, and more.",
        chips=("Accounts", "Categories", "Budgets"),
    ),
    ScreenshotSpec(
        source="start.png",
        output="06-start.png",
        title="Own your data securely",
        subtitle="Open existing MMEX files or start fresh with local sample data.",
        chips=("MMEX compatible", "AES-256", "Files workflow"),
    ),
    ScreenshotSpec(
        source="settings.png",
        output="07-settings.png",
        title="Make the app yours",
        subtitle="Set base currency, defaults, privacy choices, and appearance.",
        chips=("Preferences", "Privacy", "Theme"),
    ),
)


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = []
    if bold:
        candidates.extend(
            [
                "/System/Library/Fonts/SFNS.ttf",
                "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
                "/System/Library/Fonts/Helvetica.ttc",
            ]
        )
    else:
        candidates.extend(
            [
                "/System/Library/Fonts/Supplemental/Arial.ttf",
                "/System/Library/Fonts/Helvetica.ttc",
            ]
        )

    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    return mask


def add_icon(canvas: Image.Image, icon: Image.Image) -> None:
    icon_size = 180
    x = canvas.width - 110 - icon_size
    y = 96

    shadow = Image.new("RGBA", (icon_size + 22, icon_size + 22), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((10, 10, icon_size + 10, icon_size + 10), radius=44, fill=SHADOW_COLOR)
    shadow = shadow.filter(ImageFilter.GaussianBlur(8))
    canvas.alpha_composite(shadow, (x - 6, y + 6))

    resized = icon.resize((icon_size, icon_size), Image.LANCZOS)
    mask = rounded_mask((icon_size, icon_size), radius=42)
    icon_layer = Image.new("RGBA", (icon_size, icon_size), (0, 0, 0, 0))
    icon_layer.paste(resized, (0, 0), mask)
    canvas.alpha_composite(icon_layer, (x, y))


def draw_gradient_overlay(canvas: Image.Image) -> None:
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    pixels = overlay.load()
    top_height = 980
    bottom_height = 320

    for y in range(top_height):
        alpha = int(220 * (1 - (y / top_height)) ** 1.85)
        for x in range(canvas.width):
            pixels[x, y] = (7, 18, 15, alpha)

    for y in range(bottom_height):
        absolute_y = canvas.height - bottom_height + y
        alpha = int(135 * ((y + 1) / bottom_height) ** 1.6)
        for x in range(canvas.width):
            pixels[x, absolute_y] = (7, 18, 15, alpha)

    canvas.alpha_composite(overlay)


def draw_brand(draw: ImageDraw.ImageDraw, brand_font: ImageFont.ImageFont) -> None:
    x = 88
    y = 104
    brand = "MONEY MANAGER EX"
    bbox = draw.textbbox((0, 0), brand, font=brand_font)
    width = bbox[2] - bbox[0]
    height = bbox[3] - bbox[1]
    padding_x = 30
    padding_y = 16
    draw.rounded_rectangle(
        (x, y, x + width + padding_x * 2, y + height + padding_y * 2),
        radius=28,
        fill=BRAND_GREEN,
    )
    draw.text((x + padding_x, y + padding_y - 2), brand, font=brand_font, fill=(11, 61, 38, 255))


def draw_wrapped_text(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.ImageFont,
    fill: tuple[int, int, int, int],
    x: int,
    y: int,
    line_spacing: int,
    max_width: int,
) -> int:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        candidate = word if not current else f"{current} {word}"
        bbox = draw.textbbox((0, 0), candidate, font=font)
        if bbox[2] - bbox[0] <= max_width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)

    cursor_y = y
    for line in lines:
        draw.text((x, cursor_y), line, font=font, fill=fill)
        bbox = draw.textbbox((x, cursor_y), line, font=font)
        cursor_y = bbox[3] + line_spacing
    return cursor_y


def draw_chips(
    draw: ImageDraw.ImageDraw,
    chips: tuple[str, ...],
    chip_font: ImageFont.ImageFont,
    start_x: int,
    baseline_y: int,
) -> None:
    x = start_x
    for chip in chips:
        bbox = draw.textbbox((0, 0), chip, font=chip_font)
        width = bbox[2] - bbox[0]
        height = bbox[3] - bbox[1]
        pad_x = 22
        pad_y = 14
        draw.rounded_rectangle(
            (x, baseline_y, x + width + pad_x * 2, baseline_y + height + pad_y * 2),
            radius=24,
            fill=CHIP_FILL,
        )
        draw.text((x + pad_x, baseline_y + pad_y - 2), chip, font=chip_font, fill=CHIP_TEXT_COLOR)
        x += width + pad_x * 2 + 18


def render(spec: ScreenshotSpec, icon: Image.Image) -> Path:
    source_path = SOURCE_DIR / spec.source
    image = Image.open(source_path).convert("RGBA")
    draw_gradient_overlay(image)
    add_icon(image, icon)

    draw = ImageDraw.Draw(image)
    brand_font = load_font(34, bold=True)
    title_font = load_font(112, bold=True)
    subtitle_font = load_font(52, bold=False)
    chip_font = load_font(34, bold=True)

    draw_brand(draw, brand_font)

    left = 88
    max_width = image.width - 176
    title_y = 364
    title_end_y = draw_wrapped_text(
        draw=draw,
        text=spec.title,
        font=title_font,
        fill=TEXT_COLOR,
        x=left,
        y=title_y,
        line_spacing=10,
        max_width=max_width,
    )
    draw_wrapped_text(
        draw=draw,
        text=spec.subtitle,
        font=subtitle_font,
        fill=MUTED_TEXT_COLOR,
        x=left,
        y=title_end_y + 34,
        line_spacing=14,
        max_width=max_width - 40,
    )

    footer_title_font = load_font(40, bold=True)
    footer_copy_font = load_font(34)
    footer_y = image.height - 248
    draw.text((88, footer_y), "Private finance, on your terms", font=footer_title_font, fill=TEXT_COLOR)
    draw.text(
        (88, footer_y + 64),
        "Local data ownership with MMEX-compatible workflows.",
        font=footer_copy_font,
        fill=MUTED_TEXT_COLOR,
    )
    draw_chips(draw, spec.chips, chip_font, 88, image.height - 410)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT_DIR / spec.output
    image.convert("RGB").save(output_path, quality=95)
    return output_path


def main() -> None:
    if not SOURCE_DIR.exists():
        raise SystemExit(f"Missing source directory: {SOURCE_DIR}")
    if not ICON_PATH.exists():
        raise SystemExit(f"Missing icon file: {ICON_PATH}")

    icon = Image.open(ICON_PATH).convert("RGBA")
    for spec in SPECS:
        output = render(spec, icon)
        print(output.relative_to(ROOT))


if __name__ == "__main__":
    main()
