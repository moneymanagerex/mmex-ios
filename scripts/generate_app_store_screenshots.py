#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "Screenshots" / "2026-refresh" / "raw"
LARGE_SOURCE_DIR = SOURCE_DIR / "iphone-17-pro-max"
OUTPUT_DIR = ROOT / "docs" / "assets" / "app-store"
ICON_PATH = ROOT / "MMEX" / "Assets.xcassets" / "AppIcon.appiconset" / "mmex_green.png"

TEXT_COLOR = (255, 255, 255, 255)
MUTED_TEXT_COLOR = (230, 242, 236, 255)
SHADOW_COLOR = (0, 0, 0, 120)
BRAND_GREEN = (32, 201, 120, 255)


@dataclass(frozen=True)
class ScreenshotSpec:
    source: str
    output: str
    eyebrow: str
    title: str
    subtitle: str


SPECS = (
    ScreenshotSpec(
        source="overview.png",
        output="01-overview.png",
        eyebrow="A CLEARER FINANCIAL PICTURE",
        title="Your money, all in view",
        subtitle="Balances, net worth, and cash flow at a glance.",
    ),
    ScreenshotSpec(
        source="journal.png",
        output="02-journal.png",
        eyebrow="EVERY DETAIL, EASY TO FIND",
        title="Find every transaction",
        subtitle="Review recent activity by date, category, payee, and amount.",
    ),
    ScreenshotSpec(
        source="insights.png",
        output="03-insights.png",
        eyebrow="TURN ACTIVITY INTO INSIGHT",
        title="Spot trends quickly",
        subtitle="See income and spending trends in clear charts.",
    ),
    ScreenshotSpec(
        source="enter.png",
        output="04-entry.png",
        eyebrow="MADE FOR EVERYDAY MONEY",
        title="Log spending in seconds",
        subtitle="Record income, expenses, transfers, and split transactions with ease.",
    ),
    ScreenshotSpec(
        source="manage.png",
        output="05-manage.png",
        eyebrow="YOUR FINANCES, ORGANIZED",
        title="Organize every detail",
        subtitle="Manage accounts, categories, payees, budgets, reports, and more.",
    ),
    ScreenshotSpec(
        source="start.png",
        output="06-start.png",
        eyebrow="BUILT AROUND YOUR DATA",
        title="Own your data securely",
        subtitle="Open existing MMEX files or start fresh with local sample data.",
    ),
    ScreenshotSpec(
        source="settings.png",
        output="07-settings.png",
        eyebrow="MAKE IT WORK YOUR WAY",
        title="Make the app yours",
        subtitle="Set base currency, defaults, privacy choices, and appearance.",
    ),
)

MAINLAND_SEARCH_SPECS = (
    ScreenshotSpec(
        source="overview.png",
        output="cn-01-overview.png",
        eyebrow="一目了然的财务全景",
        title="掌握每一笔收支",
        subtitle="账户余额、净资产与现金流，一目了然。",
    ),
    ScreenshotSpec(
        source="journal.png",
        output="cn-02-journal.png",
        eyebrow="每笔记录，随时可查",
        title="轻松查找每笔交易",
        subtitle="按日期、类别和金额，快速查看近期交易。",
    ),
    ScreenshotSpec(
        source="insights.png",
        output="cn-03-insights.png",
        eyebrow="让收支趋势一目了然",
        title="看清财务变化",
        subtitle="直观查看收入与支出的变化趋势。",
    ),
    ScreenshotSpec(
        source="enter.png",
        output="cn-04-entry.png",
        eyebrow="日常记账，轻松上手",
        title="几秒记下一笔",
        subtitle="轻松记录收入、支出、转账和拆分交易。",
    ),
)


def load_font(
    size: int,
    bold: bool = False,
    chinese: bool = False,
) -> ImageFont.FreeTypeFont:
    candidates = []
    if bold:
        if chinese:
            candidates.append("/System/Library/Fonts/STHeiti Medium.ttc")
        candidates.extend(
            [
                "/System/Library/Fonts/SFNS.ttf",
                "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
                "/System/Library/Fonts/Helvetica.ttc",
            ]
        )
    else:
        if chinese:
            candidates.extend(
                [
                    "/System/Library/Fonts/Hiragino Sans GB.ttc",
                    "/System/Library/Fonts/STHeiti Light.ttc",
                ]
            )
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
    scale = canvas.width / 1320
    icon_size = int(148 * scale)
    x = canvas.width - int(76 * scale) - icon_size
    y = int(92 * scale)

    shadow = Image.new("RGBA", (icon_size + 22, icon_size + 22), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        (10, 10, icon_size + 10, icon_size + 10),
        radius=int(36 * scale),
        fill=SHADOW_COLOR,
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(8))
    canvas.alpha_composite(shadow, (x - int(6 * scale), y + int(6 * scale)))

    resized = icon.resize((icon_size, icon_size), Image.LANCZOS)
    mask = rounded_mask((icon_size, icon_size), radius=int(34 * scale))
    icon_layer = Image.new("RGBA", (icon_size, icon_size), (0, 0, 0, 0))
    icon_layer.paste(resized, (0, 0), mask)
    canvas.alpha_composite(icon_layer, (x, y))


def draw_gradient_overlay(canvas: Image.Image) -> None:
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    pixels = overlay.load()
    gradient_start = int(canvas.height * 0.05)
    solid_end = int(canvas.height * 0.17)
    gradient_end = int(canvas.height * 0.30)

    for y in range(gradient_start, gradient_end):
        if y <= solid_end:
            alpha = 255
        else:
            progress = (y - solid_end) / (gradient_end - solid_end)
            alpha = int(255 * (1 - progress) ** 1.4)
        for x in range(canvas.width):
            pixels[x, y] = (7, 18, 15, alpha)

    canvas.alpha_composite(overlay)


def draw_brand(
    draw: ImageDraw.ImageDraw,
    brand_font: ImageFont.ImageFont,
    scale: float,
) -> None:
    x = int(64 * scale)
    y = int(96 * scale)
    brand = "MONEY MANAGER EX"
    bbox = draw.textbbox((0, 0), brand, font=brand_font)
    width = bbox[2] - bbox[0]
    height = bbox[3] - bbox[1]
    padding_x = int(22 * scale)
    padding_y = int(12 * scale)
    draw.rounded_rectangle(
        (x, y, x + width + padding_x * 2, y + height + padding_y * 2),
        radius=int(22 * scale),
        fill=BRAND_GREEN,
    )
    draw.text(
        (x + padding_x, y + padding_y - int(2 * scale)),
        brand,
        font=brand_font,
        fill=(11, 61, 38, 255),
    )


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
    lines: list[str] = []
    current = ""
    for word in text.split():
        candidate = word if not current else f"{current} {word}"
        bbox = draw.textbbox((0, 0), candidate, font=font)
        if bbox[2] - bbox[0] <= max_width:
            current = candidate
            continue

        if current:
            lines.append(current)
            current = ""

        for character in word:
            candidate = current + character
            bbox = draw.textbbox((0, 0), candidate, font=font)
            if bbox[2] - bbox[0] > max_width and current:
                lines.append(current)
                current = character
            else:
                current = candidate
    if current:
        lines.append(current)

    cursor_y = y
    for line in lines:
        draw.text((x, cursor_y), line, font=font, fill=fill)
        bbox = draw.textbbox((x, cursor_y), line, font=font)
        cursor_y = bbox[3] + line_spacing
    return cursor_y


def render(
    spec: ScreenshotSpec,
    icon: Image.Image,
    source_dir: Path,
    output_dir: Path,
) -> Path:
    source_path = source_dir / spec.source
    image = Image.open(source_path).convert("RGBA")
    draw_gradient_overlay(image)
    add_icon(image, icon)

    draw = ImageDraw.Draw(image)
    scale = image.width / 1320
    chinese = any("\u4e00" <= character <= "\u9fff" for character in spec.title)
    brand_font = load_font(int(30 * scale), bold=True)
    eyebrow_font = load_font(int(26 * scale), bold=True, chinese=chinese)
    title_font = load_font(int(80 * scale), bold=True, chinese=chinese)
    subtitle_font = load_font(int(38 * scale), chinese=chinese)

    draw_brand(draw, brand_font, scale)

    left = int(64 * scale)
    max_width = image.width - int(128 * scale)
    eyebrow_y = int(196 * scale)
    draw.rounded_rectangle(
        (left, eyebrow_y + int(13 * scale), left + int(54 * scale), eyebrow_y + int(20 * scale)),
        radius=int(4 * scale),
        fill=BRAND_GREEN,
    )
    draw.text(
        (left + int(72 * scale), eyebrow_y),
        spec.eyebrow,
        font=eyebrow_font,
        fill=MUTED_TEXT_COLOR,
    )
    title_y = int(248 * scale)
    title_end_y = draw_wrapped_text(
        draw=draw,
        text=spec.title,
        font=title_font,
        fill=TEXT_COLOR,
        x=left,
        y=title_y,
        line_spacing=int(8 * scale),
        max_width=max_width,
    )
    draw_wrapped_text(
        draw=draw,
        text=spec.subtitle,
        font=subtitle_font,
        fill=MUTED_TEXT_COLOR,
        x=left,
        y=title_end_y + int(20 * scale),
        line_spacing=int(8 * scale),
        max_width=max_width - int(40 * scale),
    )

    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / spec.output
    image.convert("RGB").save(output_path, quality=95)
    return output_path


def main() -> None:
    if not SOURCE_DIR.exists():
        raise SystemExit(f"Missing source directory: {SOURCE_DIR}")
    if not LARGE_SOURCE_DIR.exists():
        raise SystemExit(f"Missing large-display source directory: {LARGE_SOURCE_DIR}")
    if not ICON_PATH.exists():
        raise SystemExit(f"Missing icon file: {ICON_PATH}")

    icon = Image.open(ICON_PATH).convert("RGBA")
    for source_dir, output_dir in (
        (SOURCE_DIR, OUTPUT_DIR),
        (LARGE_SOURCE_DIR, OUTPUT_DIR / "6.9-inch"),
    ):
        for spec in (*SPECS, *MAINLAND_SEARCH_SPECS):
            output = render(spec, icon, source_dir, output_dir)
            print(output.relative_to(ROOT))


if __name__ == "__main__":
    main()
