#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "Screenshots" / "2026-refresh" / "raw" / "iphone-17-pro-max"
ICON_PATH = ROOT / "MMEX" / "Assets.xcassets" / "AppIcon.appiconset" / "mmex_green.png"
OUTPUT_DIR = ROOT / "docs" / "assets" / "app-store" / "creative-assets"

INK = (8, 24, 19)
GREEN = (17, 91, 61)
ACCENT = (38, 207, 129)
WHITE = (250, 255, 252)
PALE = (215, 239, 226)
PILL = (20, 59, 42)


@dataclass(frozen=True)
class Creative:
    headline: str
    description: str
    features: tuple[str, str, str]


@dataclass(frozen=True)
class AssetSize:
    name: str
    placement: str
    width: int
    height: int


CREATIVES = {
    "en": {
        "header": Creative(
            headline="Your finances, in focus",
            description="Track accounts, transactions, and trends with your MMEX database.",
            features=("Local data", "Optional AES-256", "MMEX compatible"),
        ),
        "search": Creative(
            headline="See where your money goes",
            description="One clear view of accounts, transactions, and cash flow.",
            features=("Overview", "Transactions", "Insights"),
        ),
    },
    "zh-Hans": {
        "header": Creative(
            headline="收支清晰，财务尽在掌握",
            description="用 MMEX 数据库记录账户、交易与趋势；本地保存，支持 AES-256 加密。",
            features=("本地数据", "支持 AES-256", "兼容 MMEX"),
        ),
        "search": Creative(
            headline="看清每一笔钱的去向",
            description="账户、交易与现金流，一屏掌握。",
            features=("财务总览", "交易记录", "收支趋势"),
        ),
    },
}

ASSET_SIZES = (
    AssetSize("5244x2950", "header", 5244, 2950),
    AssetSize("3840x1646", "header", 3840, 1646),
    AssetSize("5244x2950", "search", 5244, 2950),
    AssetSize("3840x2560", "search", 3840, 2560),
    AssetSize("1920x1280", "search", 1920, 1280),
)

SCREENS = (
    ("journal.png", -7),
    ("insights.png", 7),
    ("overview.png", 0),
)


def load_font(size: int, bold: bool, chinese: bool) -> ImageFont.FreeTypeFont:
    candidates: list[str] = []
    if chinese:
        candidates.append(
            "/System/Library/Fonts/STHeiti Medium.ttc"
            if bold
            else "/System/Library/Fonts/Hiragino Sans GB.ttc"
        )
    candidates.extend(
        [
            "/System/Library/Fonts/SFNS.ttf" if bold else "/System/Library/Fonts/SFNS.ttf",
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
            if bold
            else "/System/Library/Fonts/Supplemental/Arial.ttf",
            "/System/Library/Fonts/Helvetica.ttc",
        ]
    )
    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


def text_width(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont) -> int:
    bounds = draw.textbbox((0, 0), text, font=font)
    return bounds[2] - bounds[0]


def wrap_text(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.ImageFont,
    max_width: int,
) -> list[str]:
    lines: list[str] = []
    current = ""
    for word in text.split():
        candidate = word if not current else f"{current} {word}"
        if text_width(draw, candidate, font) <= max_width:
            current = candidate
            continue

        if current:
            lines.append(current)
            current = ""

        for character in word:
            candidate = current + character
            if text_width(draw, candidate, font) > max_width and current:
                lines.append(current)
                current = character
            else:
                current = candidate
    if current:
        lines.append(current)
    return lines


def draw_paragraph(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.ImageFont,
    fill: tuple[int, int, int],
    x: int,
    y: int,
    max_width: int,
    spacing: int,
) -> int:
    for line in wrap_text(draw, text, font, max_width):
        draw.text((x, y), line, font=font, fill=fill)
        y = draw.textbbox((x, y), line, font=font)[3] + spacing
    return y


def gradient_background(size: tuple[int, int]) -> Image.Image:
    width, height = size
    gradient = Image.new("RGB", (1, height))
    pixels = gradient.load()
    for y in range(height):
        progress = y / max(1, height - 1)
        eased = progress**0.82
        pixels[0, y] = tuple(
            round(start + (end - start) * eased)
            for start, end in zip(INK, GREEN)
        )
    canvas = gradient.resize(size, Image.Resampling.BICUBIC)
    draw = ImageDraw.Draw(canvas)
    scale = height / 1600
    center_x = int(width * 0.84)
    center_y = int(height * 0.53)
    for inset, color, stroke in (
        (0, (25, 117, 78), max(1, int(3 * scale))),
        (int(60 * scale), (21, 100, 68), max(1, int(2 * scale))),
        (int(120 * scale), (17, 84, 58), max(1, int(2 * scale))),
    ):
        radius = int(height * 0.53) - inset
        draw.ellipse(
            (center_x - radius, center_y - radius, center_x + radius, center_y + radius),
            outline=color,
            width=stroke,
        )
    return canvas


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1),
        radius=radius,
        fill=255,
    )
    return mask


def draw_brand(
    canvas: Image.Image,
    icon: Image.Image,
    x: int,
    y: int,
    scale: float,
) -> None:
    size = int(112 * scale)
    icon_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    resized = icon.resize((size, size), Image.Resampling.LANCZOS)
    icon_layer.paste(resized, (0, 0), rounded_mask((size, size), int(size * 0.22)))
    canvas.paste(icon_layer, (x, y), icon_layer)

    draw = ImageDraw.Draw(canvas)
    font = load_font(int(31 * scale), bold=True, chinese=False)
    label = "MONEY MANAGER EX"
    text_y = y + (size - int(31 * scale)) // 2
    draw.text((x + size + int(22 * scale), text_y), label, font=font, fill=WHITE)


def make_phone(screen_name: str, height: int, angle: int) -> Image.Image:
    source = Image.open(SOURCE_DIR / screen_name).convert("RGB")
    bezel = max(5, int(height * 0.024))
    screen_height = height - bezel * 2
    screen_width = round(screen_height * source.width / source.height)
    width = screen_width + bezel * 2
    screen = source.resize((screen_width, screen_height), Image.Resampling.LANCZOS)

    island_draw = ImageDraw.Draw(screen)
    island_width = int(screen_width * 0.21)
    island_height = max(7, int(screen_height * 0.012))
    island_x = (screen_width - island_width) // 2
    island_y = int(screen_height * 0.018)
    island_draw.rounded_rectangle(
        (island_x, island_y, island_x + island_width, island_y + island_height),
        radius=island_height // 2,
        fill=(0, 0, 0),
    )

    phone = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(phone)
    draw.rounded_rectangle(
        (0, 0, width - 1, height - 1),
        radius=int(width * 0.12),
        fill=(7, 15, 11),
        outline=(105, 156, 127),
        width=max(2, int(height * 0.002)),
    )
    screen_layer = screen.convert("RGBA")
    screen_layer.putalpha(rounded_mask((screen_width, screen_height), int(width * 0.09)))
    phone.alpha_composite(screen_layer, (bezel, bezel))

    shadow_padding = max(12, int(height * 0.05))
    shadow = Image.new(
        "RGBA",
        (width + shadow_padding * 2, height + shadow_padding * 2),
        (0, 0, 0, 0),
    )
    ImageDraw.Draw(shadow).rounded_rectangle(
        (
            shadow_padding,
            shadow_padding,
            shadow_padding + width - 1,
            shadow_padding + height - 1,
        ),
        radius=int(width * 0.12),
        fill=(0, 0, 0, 150),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(max(5, int(height * 0.018))))
    shadow.alpha_composite(phone, (shadow_padding, shadow_padding))
    return shadow.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)


def draw_phones(canvas: Image.Image, placement: str, is_wide_header: bool) -> None:
    width, height = canvas.size
    if placement == "header":
        phone_height = int(height * (0.75 if is_wide_header else 0.70))
        centers = (0.57, 0.73, 0.88) if is_wide_header else (0.57, 0.72, 0.87)
        side_height = int(phone_height * 0.84)
        center_y = int(height * 0.13)
        side_y = int(height * 0.21)
    elif width / height > 1.7:
        phone_height = int(height * 0.68)
        side_height = int(phone_height * 0.87)
        centers = (0.55, 0.71, 0.86)
        center_y = int(height * 0.15)
        side_y = int(height * 0.20)
    else:
        phone_height = int(height * 0.70)
        side_height = int(phone_height * 0.88)
        centers = (0.57, 0.705, 0.84)
        center_y = int(height * 0.14)
        side_y = int(height * 0.19)

    devices = (
        make_phone(SCREENS[0][0], side_height, SCREENS[0][1]),
        make_phone(SCREENS[1][0], side_height, SCREENS[1][1]),
        make_phone(SCREENS[2][0], phone_height, SCREENS[2][1]),
    )
    placements = (
        (0, centers[0], side_y),
        (1, centers[2], side_y),
        (2, centers[1], center_y),
    )
    for index, center, top in placements:
        device = devices[index]
        x = round(width * center - device.width / 2)
        canvas.paste(device, (x, top), device)


def draw_pills(
    draw: ImageDraw.ImageDraw,
    features: tuple[str, str, str],
    font: ImageFont.ImageFont,
    x: int,
    y: int,
    gap: int,
    scale: float,
) -> None:
    for feature in features:
        bounds = draw.textbbox((0, 0), feature, font=font)
        text_width = bounds[2] - bounds[0]
        text_height = bounds[3] - bounds[1]
        pad_x = int(20 * scale)
        pad_y = int(12 * scale)
        width = text_width + pad_x * 2
        height = text_height + pad_y * 2
        draw.rounded_rectangle(
            (x, y, x + width, y + height),
            radius=height // 2,
            fill=PILL,
            outline=(53, 134, 91),
            width=max(1, int(2 * scale)),
        )
        draw.text(
            (x + pad_x, y + pad_y - int(2 * scale)),
            feature,
            font=font,
            fill=PALE,
        )
        x += width + gap


def compose_asset(
    size: AssetSize,
    creative: Creative,
    icon: Image.Image,
    locale: str,
) -> Image.Image:
    canvas = gradient_background((size.width, size.height))
    draw = ImageDraw.Draw(canvas)
    scale = size.height / 1600
    chinese = locale == "zh-Hans"
    is_wide_header = size.placement == "header" and size.width / size.height > 2

    draw_brand(
        canvas,
        icon,
        int(size.width * 0.075),
        int(size.height * 0.095),
        scale,
    )

    if size.placement == "header":
        left = int(size.width * 0.075)
        max_width = int(size.width * (0.38 if is_wide_header else 0.36))
        title_y = int(size.height * 0.34)
        title_font = load_font(int(size.height * 0.078), bold=True, chinese=chinese)
        body_font = load_font(int(size.height * 0.034), bold=False, chinese=chinese)
        feature_font = load_font(int(size.height * 0.026), bold=True, chinese=chinese)
        text_end = draw_paragraph(
            draw,
            creative.headline,
            title_font,
            WHITE,
            left,
            title_y,
            max_width,
            int(size.height * 0.012),
        )
        text_end = draw_paragraph(
            draw,
            creative.description,
            body_font,
            PALE,
            left,
            text_end + int(size.height * 0.035),
            max_width,
            int(size.height * 0.012),
        )
        draw_pills(
            draw,
            creative.features,
            feature_font,
            left,
            max(text_end + int(size.height * 0.06), int(size.height * 0.77)),
            int(12 * scale),
            scale,
        )
    else:
        left = int(size.width * 0.065)
        max_width = int(size.width * (0.35 if size.width / size.height > 1.7 else 0.34))
        title_y = int(size.height * 0.25)
        title_font = load_font(int(size.height * 0.074), bold=True, chinese=chinese)
        body_font = load_font(int(size.height * 0.034), bold=False, chinese=chinese)
        feature_font = load_font(int(size.height * 0.026), bold=True, chinese=chinese)
        text_end = draw_paragraph(
            draw,
            creative.headline,
            title_font,
            WHITE,
            left,
            title_y,
            max_width,
            int(size.height * 0.012),
        )
        text_end = draw_paragraph(
            draw,
            creative.description,
            body_font,
            PALE,
            left,
            text_end + int(size.height * 0.035),
            max_width,
            int(size.height * 0.012),
        )
        draw_pills(
            draw,
            creative.features,
            feature_font,
            left,
            max(text_end + int(size.height * 0.07), int(size.height * 0.60)),
            int(10 * scale),
            scale,
        )

    draw_phones(canvas, size.placement, is_wide_header)
    return canvas


def main() -> None:
    if not SOURCE_DIR.exists():
        raise SystemExit(f"Missing iPhone 17 Pro Max captures: {SOURCE_DIR}")
    if not ICON_PATH.exists():
        raise SystemExit(f"Missing app icon: {ICON_PATH}")
    missing_screens = [name for name, _ in SCREENS if not (SOURCE_DIR / name).exists()]
    if missing_screens:
        raise SystemExit(f"Missing source screenshots: {', '.join(missing_screens)}")

    icon = Image.open(ICON_PATH).convert("RGBA")
    for locale, creatives in CREATIVES.items():
        for size in ASSET_SIZES:
            asset = compose_asset(size, creatives[size.placement], icon, locale)
            output_dir = OUTPUT_DIR / locale
            output_dir.mkdir(parents=True, exist_ok=True)
            output = output_dir / f"{size.placement}-{size.name}.png"
            asset.save(output, format="PNG", optimize=True)
            print(f"{output.relative_to(ROOT)}: {asset.width}x{asset.height}")


if __name__ == "__main__":
    main()
