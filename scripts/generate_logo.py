# -*- coding: utf-8 -*-
"""Generate the Shefaa logo artwork from the app palette.

Outputs (assets/images/):
  logo.svg / logo.png        full lockup: mark + "shefaa" wordmark + tagline
  logo_mark.svg / logo_mark.png   mark only, square, launcher-icon ready

The colours below mirror lib/core/utils/app_colors.dart - change them there
first, then re-run this script so the artwork stays in sync.

Usage:
    python3 scripts/generate_logo.py          # writes the two SVGs
    # rasterise (any SVG renderer works), e.g. with a headless browser:
    #   npx playwright screenshot --viewport-size=1024,1024 logo.svg logo.png

Poppins (OFL) is fetched from Google Fonts on first run and cached in
.fonts/ so the wordmark is converted to outlines and the SVG stays
self-contained - no font needed by whoever opens it.
"""
import math, os, urllib.request
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.misc.transform import Transform

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONT_DIR = os.environ.get("SHEFAA_FONT_DIR", os.path.join(ROOT, ".fonts"))
FONT_URLS = {
    "Poppins-Regular.ttf": "https://fonts.gstatic.com/s/poppins/v24/pxiEyp8kv8JHgFVrFJA.ttf",
    "Poppins-SemiBold.ttf": "https://fonts.gstatic.com/s/poppins/v24/pxiByp8kv8JHgFVrLEj6V1s.ttf",
}


def ensure_font(name):
    path = os.path.join(FONT_DIR, name)
    if not os.path.exists(path):
        os.makedirs(FONT_DIR, exist_ok=True)
        urllib.request.urlretrieve(FONT_URLS[name], path)
    return path

# ---- App palette (lib/core/utils/app_colors.dart) -------------------------
PRIMARY    = "#67B2D8"   # AppColors.primaryColor
DARK_BLUE  = "#122A6B"   # AppColors.darkBlue
LIGHT_PRIM = "#C2E1F0"   # AppColors.lightPrimaryColor
MID_BLUE   = "#3A72AE"   # interpolation primary -> darkBlue (gradient midpoint)
WHITE      = "#FFFFFF"

# ---------------------------------------------------------------- text ----
def text_path(txt, font_file, size, tracking=0.0):
    """Return (path_d, width) for txt converted to outlines, origin at baseline 0,0."""
    font = TTFont(ensure_font(font_file))
    upem = font["head"].unitsPerEm
    cmap = font.getBestCmap()
    gs = font.getGlyphSet()
    scale = size / upem
    x = 0.0
    parts = []
    for ch in txt:
        gname = cmap.get(ord(ch))
        if gname is None:
            x += size * 0.3 + tracking
            continue
        pen = SVGPathPen(gs, ntos=lambda v: f"{v:.2f}")
        tpen = TransformPen(pen, Transform(scale, 0, 0, -scale, x, 0))
        gs[gname].draw(tpen)
        d = pen.getCommands()
        if d:
            parts.append(d)
        x += gs[gname].width * scale + tracking
    if txt:
        x -= tracking
    return " ".join(parts), x

# ------------------------------------------------------- tapered ribbon ----
def bezier(p0, p1, p2, p3, t):
    mt = 1 - t
    a, b, c, d = mt**3, 3*mt*mt*t, 3*mt*t*t, t**3
    return (a*p0[0] + b*p1[0] + c*p2[0] + d*p3[0],
            a*p0[1] + b*p1[1] + c*p2[1] + d*p3[1])

def sample_spine(segments, per_seg=90):
    """segments: [(p0,p1,p2,p3), ...] -> list of points along the chain."""
    pts = []
    for i, seg in enumerate(segments):
        rng = range(0, per_seg + 1) if i == 0 else range(1, per_seg + 1)
        for k in rng:
            pts.append(bezier(*seg, k / per_seg))
    return pts

def smoothstep(e0, e1, x):
    t = max(0.0, min(1.0, (x - e0) / (e1 - e0)))
    return t * t * (3 - 2 * t)

def ribbon(points, w_max, head=0.30, tail=0.26, head_len=0.22, tail_len=0.30):
    """Variable-width outline around a polyline; tapers at both ends."""
    # arc-length parameterisation
    acc = [0.0]
    for i in range(1, len(points)):
        acc.append(acc[-1] + math.dist(points[i], points[i-1]))
    total = acc[-1]
    left, right = [], []
    n = len(points)
    for i, p in enumerate(points):
        s = acc[i] / total
        w = w_max * (head + (1 - head) * smoothstep(0, head_len, s))
        w *= (tail + (1 - tail) * smoothstep(0, tail_len, 1 - s))
        j0, j1 = max(0, i-1), min(n-1, i+1)
        dx = points[j1][0] - points[j0][0]
        dy = points[j1][1] - points[j0][1]
        ln = math.hypot(dx, dy) or 1.0
        nx, ny = -dy/ln, dx/ln
        left.append((p[0] + nx*w/2, p[1] + ny*w/2))
        right.append((p[0] - nx*w/2, p[1] - ny*w/2))
    d = ["M %.2f %.2f" % left[0]]
    d += ["L %.2f %.2f" % q for q in left[1:]]
    d += ["L %.2f %.2f" % q for q in reversed(right)]
    d.append("Z")
    return " ".join(d)

# ------------------------------------------------------------ geometry ----
# S spine (y grows downward), lower bowl centred on the clock face
S_SPINE = [
    ((648, 262), (648, 168), (540, 122), (452, 152)),
    ((452, 152), (378, 177), (334, 262), (374, 336)),
    ((374, 336), (406, 394), (472, 422), (544, 452)),
    ((544, 452), (644, 494), (708, 566), (708, 654)),
    ((708, 654), (708, 762), (620, 840), (512, 840)),
    ((512, 840), (404, 840), (318, 762), (318, 654)),
    ((318, 654), (318, 598), (342, 556), (386, 526)),
]
CLOCK_C = (524, 652)

def clock_group():
    cx, cy = CLOCK_C
    g = [f'<circle cx="{cx}" cy="{cy}" r="163" fill="{WHITE}"/>']
    # tick marks at 12 / 3 / 6 / 9
    for ang, ln in ((90, 34), (0, 22), (270, 34), (180, 22)):
        a = math.radians(ang)
        r1, r2 = 150 - ln, 150
        x1, y1 = cx + r1*math.cos(a), cy - r1*math.sin(a)
        x2, y2 = cx + r2*math.cos(a), cy - r2*math.sin(a)
        g.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
                 f'stroke="{DARK_BLUE}" stroke-width="11" stroke-linecap="round"/>')
    # hands: 10:10-ish, matching the reference
    g.append(f'<line x1="{cx}" y1="{cy}" x2="{cx+104:.0f}" y2="{cy-74:.0f}" '
             f'stroke="{DARK_BLUE}" stroke-width="13" stroke-linecap="round"/>')
    g.append(f'<line x1="{cx}" y1="{cy}" x2="{cx-66:.0f}" y2="{cy-40:.0f}" '
             f'stroke="{DARK_BLUE}" stroke-width="13" stroke-linecap="round"/>')
    g.append(f'<circle cx="{cx}" cy="{cy}" r="9" fill="{DARK_BLUE}"/>')
    return "\n    ".join(g)

def stethoscope_group():
    sw = 14
    st = (f'fill="none" stroke="url(#steth)" stroke-width="{sw}" '
          f'stroke-linecap="round" stroke-linejoin="round"')
    parts = [
        # binaural headset: one continuous U from ear tip to ear tip
        f'<path d="M 528 232 C 528 292 548 328 590 344 C 630 328 650 290 650 234" {st}/>',
        # yoke down to the chest piece
        f'<path d="M 590 344 L 590 372" {st}/>',
        # ear tips
        f'<circle cx="528" cy="226" r="12" fill="{PRIMARY}"/>',
        f'<circle cx="650" cy="228" r="12" fill="{PRIMARY}"/>',
        # chest piece
        f'<circle cx="590" cy="404" r="32" fill="{WHITE}" stroke="url(#steth)" stroke-width="14"/>',
        f'<circle cx="590" cy="404" r="12" fill="{PRIMARY}"/>',
        # loose tube sweeping right, ending in a bud
        f'<path d="M 662 246 C 706 312 730 376 720 432" {st}/>',
        f'<circle cx="719" cy="448" r="16" fill="{PRIMARY}"/>',
    ]
    return "\n    ".join(parts)

def defs():
    return f'''<defs>
    <linearGradient id="sGrad" x1="0.18" y1="0" x2="0.8" y2="1">
      <stop offset="0" stop-color="{PRIMARY}"/>
      <stop offset="0.45" stop-color="{MID_BLUE}"/>
      <stop offset="1" stop-color="{DARK_BLUE}"/>
    </linearGradient>
    <linearGradient id="steth" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="{PRIMARY}"/>
      <stop offset="1" stop-color="{MID_BLUE}"/>
    </linearGradient>
    <filter id="soft" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="10" stdDeviation="18" flood-color="{DARK_BLUE}" flood-opacity="0.10"/>
    </filter>
  </defs>'''

def mark_svg_body(dy=0):
    spine = ribbon(sample_spine(S_SPINE), w_max=74)
    return f'''<g transform="translate(0 {dy})">
    {clock_group()}
    <path d="{spine}" fill="url(#sGrad)"/>
    {stethoscope_group()}
  </g>'''

# ------------------------------------------------------------- lockup ----
def build_lockup():
    word_d, word_w = text_path("shefaa", "Poppins-Regular.ttf", 176)
    tag_d, tag_w = text_path("BOOK YOUR CLINIC TIME", "Poppins-Regular.ttf", 40, tracking=7.5)
    wx = (1024 - word_w) / 2
    tx = (1024 - tag_w) / 2
    tag_y = 954
    dash = 62
    gap = 30
    body = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  {defs()}
  <rect x="26" y="26" width="972" height="972" rx="196" fill="{WHITE}" filter="url(#soft)"/>
  <g transform="translate(512 372) scale(0.80) translate(-518 -481)">
    {mark_svg_body()}
  </g>
  <path d="{word_d}" fill="{DARK_BLUE}" transform="translate({wx:.1f} 872)"/>
  <path d="{tag_d}" fill="{PRIMARY}" transform="translate({tx:.1f} {tag_y})"/>
  <line x1="{tx-gap-dash:.1f}" y1="{tag_y-13}" x2="{tx-gap:.1f}" y2="{tag_y-13}" stroke="{PRIMARY}" stroke-width="5" stroke-linecap="round"/>
  <line x1="{tx+tag_w+gap:.1f}" y1="{tag_y-13}" x2="{tx+tag_w+gap+dash:.1f}" y2="{tag_y-13}" stroke="{PRIMARY}" stroke-width="5" stroke-linecap="round"/>
</svg>
'''
    return body

def build_mark():
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  {defs()}
  <rect x="0" y="0" width="1024" height="1024" rx="0" fill="{WHITE}"/>
  <g transform="translate(512 512) scale(1.02) translate(-526 -481)">
    {mark_svg_body()}
  </g>
</svg>
'''

if __name__ == "__main__":
    out = os.path.join(ROOT, "assets", "images")
    os.makedirs(out, exist_ok=True)
    open(os.path.join(out, "logo.svg"), "w").write(build_lockup())
    open(os.path.join(out, "logo_mark.svg"), "w").write(build_mark())
    print("wrote logo.svg and logo_mark.svg to", out)
