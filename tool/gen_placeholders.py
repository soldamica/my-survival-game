#!/usr/bin/env python3
"""Generates placeholder PNGs (Diablo-like dark style) in assets/images/iso/.

Pure Python (no dependency). Replace any file with your own art,
keeping the same size and layout. Run: python3 tool/gen_placeholders.py
"""
import math
import os
import struct
import zlib

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'images', 'iso')

# 8 directions, row order: S, SW, W, NW, N, NE, E, SE (screen space, y down).
DIRS = [(0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1), (1, 0), (1, 1)]


class Img:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.px = [[(0, 0, 0, 0)] * w for _ in range(h)]

    def set(self, x, y, c):
        x, y = int(x), int(y)
        if 0 <= x < self.w and 0 <= y < self.h:
            if len(c) == 3:
                c = (*c, 255)
            self.px[y][x] = c

    def rect(self, x0, y0, w, h, c):
        for y in range(int(y0), int(y0 + h)):
            for x in range(int(x0), int(x0 + w)):
                self.set(x, y, c)

    def ellipse(self, cx, cy, rx, ry, c):
        for y in range(int(cy - ry), int(cy + ry) + 1):
            for x in range(int(cx - rx), int(cx + rx) + 1):
                if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1:
                    self.set(x, y, c)

    def diamond(self, w, h, c, edge=None):
        for y in range(h):
            for x in range(w):
                d = abs(x + 0.5 - w / 2) / (w / 2) + abs(y + 0.5 - h / 2) / (h / 2)
                if d <= 1:
                    self.set(x, y, edge if edge and d > 0.86 else c)

    def blit(self, other, ox, oy):
        for y in range(other.h):
            for x in range(other.w):
                c = other.px[y][x]
                if c[3]:
                    self.set(ox + x, oy + y, c)

    def save(self, name):
        raw = b''.join(b'\x00' + b''.join(bytes(p) for p in row) for row in self.px)

        def chunk(t, d):
            return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)

        data = (b'\x89PNG\r\n\x1a\n'
                + chunk(b'IHDR', struct.pack('>IIBBBBB', self.w, self.h, 8, 6, 0, 0, 0))
                + chunk(b'IDAT', zlib.compress(raw, 9))
                + chunk(b'IEND', b''))
        with open(os.path.join(OUT, name), 'wb') as f:
            f.write(data)
        print(f'{name:20s} {self.w}x{self.h}')


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c[:3])


def character(body, head, accent, eye):
    """384x384 sheet: 8 direction rows x 8 walk frames of 48x48. Feet at (24, 44)."""
    sheet = Img(384, 384)
    for row, (dx, dy) in enumerate(DIRS):
        n = math.hypot(dx, dy)
        dx, dy = dx / n, dy / n
        for col in range(8):
            f = Img(48, 48)
            phase = math.sin(col / 8 * 2 * math.pi)
            bob = abs(phase) * 1.5
            # legs (swing along facing direction)
            for side, sgn in ((-1, 1), (1, -1)):
                lx = 24 + side * 4 + dx * phase * 3 * sgn
                ly = 38 + dy * phase * 1.5 * sgn
                f.rect(lx - 2, ly - 2, 4, 8, shade(body, 0.55))
            # torso + cloak
            f.ellipse(24, 30 - bob, 9, 11, shade(body, 0.7))
            f.ellipse(24 - dx, 29 - bob, 7, 9, body)
            f.rect(17, 32 - bob, 14, 2, accent)  # belt
            # head
            f.ellipse(24, 16 - bob, 6, 6, shade(head, 0.75))
            f.ellipse(24 + dx, 15 - bob, 5, 5, head)
            # facing marker (eyes) unless seen from behind
            if dy >= -0.1:
                for side in (-1, 1):
                    ex = 24 + dx * 3 + side * 2 * (1 - abs(dx) * 0.6)
                    f.set(ex, 15 - bob + dy, eye)
            # arms
            f.ellipse(24 - 9 + dx * 2, 28 - bob - phase, 2, 5, shade(body, 0.6))
            f.ellipse(24 + 9 + dx * 2, 28 - bob + phase, 2, 5, shade(body, 0.6))
            sheet.blit(f, col * 48, row * 48)
    return sheet


def main():
    os.makedirs(OUT, exist_ok=True)

    # Floor tiles 32x16 (dark stone, 4 variants)
    for i, base in enumerate([(58, 52, 46), (54, 49, 44), (62, 55, 47), (50, 46, 42)]):
        t = Img(32, 16)
        t.diamond(32, 16, base, edge=shade(base, 0.7))
        if i % 2:
            t.set(12, 7, shade(base, 0.6)); t.set(13, 8, shade(base, 0.6)); t.set(14, 8, shade(base, 0.6))
        if i == 3:
            t.ellipse(20, 8, 2, 1, shade(base, 1.25))
        t.save(f'floor_{i}.png')

    character(body=(110, 30, 26), head=(205, 160, 120), accent=(170, 140, 60),
              eye=(30, 20, 20)).save('hero.png')
    character(body=(70, 82, 56), head=(120, 140, 100), accent=(60, 40, 30),
              eye=(230, 40, 30)).save('zombie.png')

    s = Img(24, 12); s.ellipse(12, 6, 11, 5, (0, 0, 0, 110)); s.save('shadow.png')

    a = Img(16, 4)
    a.rect(3, 1, 10, 2, (140, 100, 60)); a.rect(13, 0, 3, 4, (200, 200, 210))
    a.rect(0, 0, 3, 1, (180, 40, 30)); a.rect(0, 3, 3, 1, (180, 40, 30))
    a.save('arrow.png')

    q = Img(16, 16)  # quiver pickup
    q.rect(5, 3, 6, 12, (90, 55, 30)); q.rect(5, 6, 6, 1, (170, 140, 60))
    for x in (6, 8, 10):
        q.rect(x, 0, 1, 4, (140, 100, 60)); q.set(x, 0, (200, 200, 210))
    q.save('arrow_pickup.png')

    w = Img(16, 16)  # sword pickup
    for i in range(10):
        w.set(4 + i, 11 - i, (200, 200, 210)); w.set(5 + i, 11 - i, (150, 150, 160))
    w.rect(2, 11, 5, 2, (170, 140, 60)); w.rect(3, 13, 2, 2, (90, 55, 30))
    w.save('sword_pickup.png')

    # HUD bottom panel 640x72 (stone with bevel, orb sockets)
    p = Img(640, 72)
    p.rect(0, 0, 640, 72, (38, 34, 30))
    p.rect(0, 0, 640, 2, (90, 80, 66)); p.rect(0, 2, 640, 1, (20, 18, 16))
    for x in range(0, 640, 40):
        p.rect(x, 3, 1, 69, (28, 25, 22))
    for cx in (36, 604):
        p.ellipse(cx, 38, 34, 34, (18, 16, 14))
    p.rect(250, 24, 140, 40, (24, 22, 20)); p.rect(251, 25, 138, 1, (70, 62, 52))
    p.save('hud_panel.png')

    o = Img(64, 64)
    for y in range(64):
        for x in range(64):
            d = math.hypot(x + 0.5 - 32, y + 0.5 - 32)
            if 27 <= d <= 31:
                o.set(x, y, shade((150, 125, 70), 1.1 - (d - 27) * 0.12))
    o.ellipse(22, 20, 4, 3, (255, 255, 255, 70))
    o.save('orb_frame.png')
    for name, col in (('orb_red.png', (170, 20, 20)), ('orb_blue.png', (30, 50, 170))):
        f = Img(64, 64)
        for y in range(64):
            for x in range(64):
                d = math.hypot(x + 0.5 - 32, y + 0.5 - 32)
                if d < 27.5:
                    f.set(x, y, shade(col, 1.25 - d / 40 - (y / 64) * 0.3))
        f.save(name)

    for name, icon in (('skill_bow.png', 'bow'), ('skill_sword.png', 'sword')):
        b = Img(28, 28)
        b.rect(0, 0, 28, 28, (120, 100, 60)); b.rect(1, 1, 26, 26, (30, 26, 22))
        if icon == 'bow':
            for i in range(18):
                b.set(8 + int(4 * math.sin(i / 17 * math.pi)), 5 + i, (150, 105, 60))
            b.rect(8, 5, 1, 18, (220, 220, 200))
        else:
            for i in range(14):
                b.set(7 + i, 20 - i, (200, 200, 210))
            b.rect(5, 19, 6, 2, (170, 140, 60))
        b.save(name)


if __name__ == '__main__':
    main()
