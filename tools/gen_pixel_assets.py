#!/usr/bin/env python3
"""Generate placeholder pixel-art tiles and character strips for sertão ritual GDD."""
from __future__ import annotations

import os
import struct
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_TILES = os.path.join(ROOT, "assets", "tiles", "sertao_tileset.png")
OUT_CHARS = os.path.join(ROOT, "assets", "characters", "lampiao_maria_sheet.png")

# Palette from design/ART_SCALE.md
C = {
    "shadow": (0x1A, 0x0F, 0x0A, 0xFF),
    "earth": (0x5C, 0x3D, 0x2E, 0xFF),
    "ochre": (0x8B, 0x69, 0x14, 0xFF),
    "taipa": (0xC4, 0xA5, 0x74, 0xFF),
    "spine": (0x2D, 0x4A, 0x3E, 0xFF),
    "blood": (0x8B, 0x29, 0x42, 0xFF),
    "sky": (0x87, 0xCE, 0xEB, 0xFF),
}


def write_png_rgba(path: str, width: int, height: int, rgba: bytes) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    def chunk(tag: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    raw = b""
    stride = width * 4
    for y in range(height):
        raw += b"\x00" + rgba[y * stride : (y + 1) * stride]
    compressed = zlib.compress(raw, 9)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", compressed) + chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


def fill_rect(buf: bytearray, w: int, x: int, y: int, rw: int, rh: int, col: tuple[int, int, int, int]) -> None:
    for j in range(rh):
        for i in range(rw):
            px, py = x + i, y + j
            if 0 <= px < w and 0 <= py < len(buf) // (w * 4):
                o = (py * w + px) * 4
                buf[o : o + 4] = col


def gen_tileset() -> None:
    tw, th = 32, 32
    cols = 8
    w, h = tw * cols, th
    buf = bytearray(w * h * 4)

    def tile_slot(idx: int) -> tuple[int, int]:
        return idx * tw, 0

    # 0 ground cracks
    x0, y0 = tile_slot(0)
    for j in range(th):
        for i in range(tw):
            fill_rect(buf, w, x0 + i, y0 + j, 1, 1, C["earth"])
    for i in range(0, tw, 4):
        fill_rect(buf, w, x0 + i, y0 + 8, 1, 16, C["ochre"])
    fill_rect(buf, w, x0 + 2, y0 + th - 6, tw - 4, 4, C["shadow"])

    # 1 taipa wall
    x0, y0 = tile_slot(1)
    for j in range(th):
        for i in range(tw):
            fill_rect(buf, w, x0 + i, y0 + j, 1, 1, C["taipa"])
    for j in range(0, th, 6):
        fill_rect(buf, w, x0, y0 + j, tw, 1, C["ochre"])
    fill_rect(buf, w, x0, y0, 3, th, C["shadow"])
    fill_rect(buf, w, x0 + tw - 3, y0, 3, th, C["shadow"])

    # 2 platform
    x0, y0 = tile_slot(2)
    for j in range(th // 2, th):
        for i in range(tw):
            fill_rect(buf, w, x0 + i, y0 + j, 1, 1, C["earth"])
    fill_rect(buf, w, x0, y0 + th // 2, tw, 4, C["ochre"])
    for i in range(3, tw, 8):
        fill_rect(buf, w, x0 + i, y0 + th // 2 - 2, 2, 2, C["shadow"])

    # 3 mandacaru (decorative)
    x0, y0 = tile_slot(3)
    fill_rect(buf, w, x0 + 14, y0 + 8, 4, 20, C["spine"])
    fill_rect(buf, w, x0 + 10, y0 + 4, 12, 6, C["spine"])
    for dx, dy in [(8, 6), (20, 8), (12, 2)]:
        fill_rect(buf, w, x0 + dx, y0 + dy, 3, 3, C["spine"])

    # 4 chapel ruin
    x0, y0 = tile_slot(4)
    for j in range(th):
        for i in range(tw):
            fill_rect(buf, w, x0 + i, y0 + j, 1, 1, C["taipa"])
    fill_rect(buf, w, x0 + 4, y0 + 4, tw - 8, 8, C["shadow"])
    fill_rect(buf, w, x0 + 12, y0, 8, 6, C["blood"])

    # 5 rock
    x0, y0 = tile_slot(5)
    for j in range(th):
        for i in range(tw):
            fill_rect(buf, w, x0 + i, y0 + j, 1, 1, C["shadow"])
    for j in range(4, th - 4):
        for i in range(4, tw - 4):
            fill_rect(buf, w, x0 + i, y0 + j, 1, 1, C["earth"])

    # 6 empty (transparent)
    x0, y0 = tile_slot(6)
    pass

    # 7 dry grass detail
    x0, y0 = tile_slot(7)
    for j in range(th):
        for i in range(tw):
            fill_rect(buf, w, x0 + i, y0 + j, 1, 1, C["earth"])
    for i in range(2, tw, 3):
        fill_rect(buf, w, x0 + i, y0 + th - 8, 1, 6, C["ochre"])
        fill_rect(buf, w, x0 + i + 1, y0 + th - 6, 1, 4, C["spine"])

    write_png_rgba(OUT_TILES, w, h, bytes(buf))


def draw_lampiao(buf: bytearray, w: int, ox: int, oy: int, phase: int) -> None:
    """32x36 silhouette: tall hat, bandolier, slight walk bob."""
    bob = (phase % 2) * 1
    # hat
    fill_rect(buf, w, ox + 8, oy + 2 + bob, 16, 10, C["shadow"])
    fill_rect(buf, w, ox + 10, oy + 4 + bob, 12, 6, C["earth"])
    # face
    fill_rect(buf, w, ox + 10, oy + 12 + bob, 12, 8, C["ochre"])
    # body
    fill_rect(buf, w, ox + 8, oy + 20 + bob, 16, 14, C["shadow"])
    # bandolier
    fill_rect(buf, w, ox + 9, oy + 22 + bob, 14, 2, C["ochre"])
    fill_rect(buf, w, ox + 11, oy + 18 + bob, 2, 10, C["taipa"])
    fill_rect(buf, w, ox + 19, oy + 19 + bob, 2, 10, C["taipa"])
    # legs
    fill_rect(buf, w, ox + 10, oy + 32, 4, 4, C["shadow"])
    fill_rect(buf, w, ox + 18, oy + 32, 4, 4, C["shadow"])


def draw_maria(buf: bytearray, w: int, ox: int, oy: int, phase: int) -> None:
    bob = (phase % 2) * 1
    # lenço
    fill_rect(buf, w, ox + 6, oy + 4 + bob, 20, 8, C["blood"])
    fill_rect(buf, w, ox + 8, oy + 6 + bob, 16, 4, C["shadow"])
    # face
    fill_rect(buf, w, ox + 10, oy + 12 + bob, 12, 8, C["ochre"])
    # vestido
    fill_rect(buf, w, ox + 6, oy + 20 + bob, 20, 14, C["shadow"])
    fill_rect(buf, w, ox + 8, oy + 22 + bob, 16, 10, C["blood"])
    # legs
    fill_rect(buf, w, ox + 11, oy + 32, 4, 4, C["shadow"])
    fill_rect(buf, w, ox + 17, oy + 32, 4, 4, C["shadow"])


def gen_characters() -> None:
    fw, fh = 32, 36
    frames = 8
    w, h = fw * frames, fh
    buf = bytearray(w * h * 4)
    # 0-1 Lampião idle
    draw_lampiao(buf, w, 0 * fw, 0, 0)
    draw_lampiao(buf, w, 1 * fw, 0, 1)
    # 2-3 Lampião walk
    draw_lampiao(buf, w, 2 * fw, 0, 2)
    draw_lampiao(buf, w, 3 * fw, 0, 3)
    # 4-5 Maria idle
    draw_maria(buf, w, 4 * fw, 0, 0)
    draw_maria(buf, w, 5 * fw, 0, 1)
    # 6-7 Maria walk
    draw_maria(buf, w, 6 * fw, 0, 2)
    draw_maria(buf, w, 7 * fw, 0, 3)
    write_png_rgba(OUT_CHARS, w, h, bytes(buf))


def gen_bellapps_logo_png() -> None:
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        return
    path = os.path.join(ROOT, "assets", "ui", "bellapps_logo.png")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img = Image.new("RGBA", (420, 88), (10, 18, 26, 255))
    d = ImageDraw.Draw(img)
    d.rectangle([8, 28, 56, 56], fill=(20, 180, 160, 255))
    d.rectangle([64, 28, 120, 72], fill=(13, 148, 136, 255))
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 36)
    except OSError:
        font = ImageFont.load_default()
    d.text((128, 22), "Bellapps", fill=(240, 250, 250, 255), font=font)
    img.save(path)


def main() -> None:
    gen_tileset()
    gen_characters()
    gen_bellapps_logo_png()
    print("Wrote:", OUT_TILES)
    print("Wrote:", OUT_CHARS)


if __name__ == "__main__":
    main()
