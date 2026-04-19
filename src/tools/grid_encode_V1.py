"""
grid_encode.py - Encodeur de fichiers en grille binaire sur support physique.

Format A4 pagine :
  - 22 macro-colonnes (A..V) x 34 macro-lignes (01..34) par page
  - Chaque macro-bloc = 8x8 micro-blocs = 512 octets
  - 22 x 34 x 512 = 383 488 octets par page (~374 Ko)
  - V2 aux deux bords horizontaux pour les croix de centrage
  - Indices en clair : lettres (A..V) en haut et en bas,
    numeros (01..34) a gauche et a droite
  - Un PDF par page : OUTPUT_DIR/page_001.pdf, page_002.pdf, etc.

Usage :
    python3 grid_encode.py INPUT_FILE OUTPUT_DIR [SCALE]
    SCALE = 1 pour taille reelle (100um/point), 3+ pour grossissement
"""
import sys
import os
from PIL import Image, ImageDraw

# =============================================================================
# PARAMETRES
# =============================================================================

MICRO_W = 10
MICRO_H = 10
DATA_BITS = 8
DATA_ROWS = 8

MICROS_PER_HALF = 4
HALVES_PER_GROUP = 2

SEP_V1_W = 2          # mur + blanc
SEP_V2_W = 6          # mur1 + "2" + "2" + "2" + mur1 + blanc

MICRO_ROWS_PER_SECTION = 8
SEP_H2_H = 2

GROUPS_H = 22          # macro-colonnes A..V
SECTIONS_V = 34        # macro-lignes 01..34

MICROS_PER_GROUP = MICROS_PER_HALF * HALVES_PER_GROUP  # 8
BYTES_PER_PAGE = GROUPS_H * SECTIONS_V * MICROS_PER_GROUP * MICRO_ROWS_PER_SECTION * DATA_ROWS

COL_LABELS = [chr(ord('A') + i) for i in range(GROUPS_H)]
ROW_LABELS = [f"{i+1:02d}" for i in range(SECTIONS_V)]

# Marges pour indices en clair (en points de 100um)
INDEX_MARGIN_TOP = 25
INDEX_MARGIN_BOTTOM = 25
INDEX_MARGIN_LEFT = 25
INDEX_MARGIN_RIGHT = 25

# =============================================================================
# GEOMETRIE
# =============================================================================

def half_width():
    return MICROS_PER_HALF * MICRO_W

def group_width():
    return half_width() + SEP_V1_W + half_width()

def section_height():
    return MICRO_ROWS_PER_SECTION * MICRO_H

def grid_dimensions():
    gw = group_width()
    # V2_gauche + groupe_0 + (V2 + groupe) * (N-1) + V2_droite
    total_w = SEP_V2_W + gw + (GROUPS_H - 1) * (SEP_V2_W + gw) + SEP_V2_W
    total_h = SECTIONS_V * section_height() + (SECTIONS_V - 1) * SEP_H2_H
    return total_w, total_h

def page_dimensions():
    gw, gh = grid_dimensions()
    return (INDEX_MARGIN_LEFT + gw + INDEX_MARGIN_RIGHT,
            INDEX_MARGIN_TOP + gh + INDEX_MARGIN_BOTTOM)


# =============================================================================
# POLICE SIMPLE POUR LES INDICES
# Petite police bitmap 5x7 integree, pas de dependance freetype
# =============================================================================

FONT_5X7 = {
    'A': ["01110","10001","10001","11111","10001","10001","10001"],
    'B': ["11110","10001","10001","11110","10001","10001","11110"],
    'C': ["01110","10001","10000","10000","10000","10001","01110"],
    'D': ["11100","10010","10001","10001","10001","10010","11100"],
    'E': ["11111","10000","10000","11110","10000","10000","11111"],
    'F': ["11111","10000","10000","11110","10000","10000","10000"],
    'G': ["01110","10001","10000","10111","10001","10001","01110"],
    'H': ["10001","10001","10001","11111","10001","10001","10001"],
    'I': ["01110","00100","00100","00100","00100","00100","01110"],
    'J': ["00111","00010","00010","00010","00010","10010","01100"],
    'K': ["10001","10010","10100","11000","10100","10010","10001"],
    'L': ["10000","10000","10000","10000","10000","10000","11111"],
    'M': ["10001","11011","10101","10101","10001","10001","10001"],
    'N': ["10001","11001","10101","10011","10001","10001","10001"],
    'O': ["01110","10001","10001","10001","10001","10001","01110"],
    'P': ["11110","10001","10001","11110","10000","10000","10000"],
    'Q': ["01110","10001","10001","10001","10101","10010","01101"],
    'R': ["11110","10001","10001","11110","10100","10010","10001"],
    'S': ["01110","10001","10000","01110","00001","10001","01110"],
    'T': ["11111","00100","00100","00100","00100","00100","00100"],
    'U': ["10001","10001","10001","10001","10001","10001","01110"],
    'V': ["10001","10001","10001","10001","01010","01010","00100"],
    'W': ["10001","10001","10001","10101","10101","10101","01010"],
    'X': ["10001","10001","01010","00100","01010","10001","10001"],
    '0': ["01110","10001","10011","10101","11001","10001","01110"],
    '1': ["00100","01100","00100","00100","00100","00100","01110"],
    '2': ["01110","10001","00001","00010","00100","01000","11111"],
    '3': ["11111","00010","00100","00010","00001","10001","01110"],
    '4': ["00010","00110","01010","10010","11111","00010","00010"],
    '5': ["11111","10000","11110","00001","00001","10001","01110"],
    '6': ["00110","01000","10000","11110","10001","10001","01110"],
    '7': ["11111","00001","00010","00100","01000","01000","01000"],
    '8': ["01110","10001","10001","01110","10001","10001","01110"],
    '9': ["01110","10001","10001","01111","00001","00010","01100"],
    'P': ["11110","10001","10001","11110","10000","10000","10000"],
    '/': ["00001","00010","00100","00100","00100","01000","10000"],
}

def draw_small_string(grid, W, H, s, ox, oy):
    """Dessine une chaine avec la police 5x7 integree."""
    pen_x = ox
    for ch in s:
        glyph = FONT_5X7.get(ch)
        if glyph:
            for dy, row in enumerate(glyph):
                for dx, bit in enumerate(row):
                    if bit == '1':
                        gx = pen_x + dx
                        gy = oy + dy
                        if 0 <= gx < W and 0 <= gy < H:
                            grid[gy][gx] = 1
        pen_x += 6  # 5 pixels + 1 espace


# =============================================================================
# ENCODAGE D'UNE PAGE
# =============================================================================

def encode_page(data, page_num, total_pages):
    gw_grid, gh_grid = grid_dimensions()
    W, H = page_dimensions()
    grid = [[0] * W for _ in range(H)]

    ox_grid = INDEX_MARGIN_LEFT
    oy_grid = INDEX_MARGIN_TOP

    def S(x, y, val=1):
        gx = ox_grid + x
        gy = oy_grid + y
        if 0 <= gx < W and 0 <= gy < H:
            grid[gy][gx] = val

    # -------------------------------------------------------------------
    # Positions X
    # -------------------------------------------------------------------
    struct_cols = []
    micro_x_positions = []
    v2_centers = []
    group_center_x = []

    x = 0
    # V2 bordure gauche
    struct_cols.append((x, 'MUR')); x += 1
    struct_cols.append((x, 'MUR')); x += 1
    v2_centers.append(x)
    struct_cols.append((x, 'MUR')); x += 1
    struct_cols.append((x, 'MUR')); x += 1
    struct_cols.append((x, 'MUR')); x += 1
    x += 1  # blanc

    for g in range(GROUPS_H):
        if g > 0:
            # V2 intermediaire
            struct_cols.append((x, 'MUR')); x += 1
            struct_cols.append((x, 'MUR')); x += 1
            v2_centers.append(x)
            struct_cols.append((x, 'MUR')); x += 1
            struct_cols.append((x, 'MUR')); x += 1
            struct_cols.append((x, 'MUR')); x += 1
            x += 1  # blanc

        group_start_x = x
        for h in range(HALVES_PER_GROUP):
            if h > 0:
                struct_cols.append((x, 'MUR')); x += 1
                x += 1  # blanc
            for m in range(MICROS_PER_HALF):
                micro_x_positions.append(x)
                x += MICRO_W
        group_center_x.append((group_start_x + x) // 2)

    # V2 bordure droite
    struct_cols.append((x, 'MUR')); x += 1
    struct_cols.append((x, 'MUR')); x += 1
    v2_centers.append(x)
    struct_cols.append((x, 'MUR')); x += 1
    struct_cols.append((x, 'MUR')); x += 1
    struct_cols.append((x, 'MUR')); x += 1
    x += 1

    # -------------------------------------------------------------------
    # Positions Y
    # -------------------------------------------------------------------
    micro_y_positions = []
    sep_h2_positions = []
    section_center_y = []

    y = 0
    for s in range(SECTIONS_V):
        if s > 0:
            sep_h2_positions.append(y)
            y += SEP_H2_H
        section_start = y
        for mr in range(MICRO_ROWS_PER_SECTION):
            micro_y_positions.append(y)
            y += MICRO_H
        section_center_y.append((section_start + y) // 2)

    # -------------------------------------------------------------------
    # 1. Colonnes structurelles (murs pleins noirs)
    # -------------------------------------------------------------------
    for (cx, ctype) in struct_cols:
        for cy in range(gh_grid):
            S(cx, cy, 1)

    # -------------------------------------------------------------------
    # 2. Lignes H2
    # -------------------------------------------------------------------
    for sy in sep_h2_positions:
        for cx in range(gw_grid):
            S(cx, sy, 1)
        # Croix blanches : branche horizontale
        for v2c in v2_centers:
            S(v2c - 1, sy, 0)
            S(v2c,     sy, 0)
            S(v2c + 1, sy, 0)

    # -------------------------------------------------------------------
    # 3. Croix blanches : branche verticale
    # -------------------------------------------------------------------
    for sy in sep_h2_positions:
        for v2c in v2_centers:
            S(v2c, sy - 1, 0)
            S(v2c, sy + 1, 0)

    # -------------------------------------------------------------------
    # 4. Micro-blocs
    # -------------------------------------------------------------------
    micro_idx = 0
    for my in micro_y_positions:
        for mx in micro_x_positions:
            # Plafond
            S(mx, my, 1)
            for b in range(DATA_BITS):
                S(mx + 1 + b, my, 1)

            # Donnees
            for row in range(DATA_ROWS):
                y_line = my + 1 + row
                byte_idx = micro_idx * DATA_ROWS + row

                S(mx, y_line, 1)

                if byte_idx < len(data):
                    byte_val = data[byte_idx]
                else:
                    byte_val = 0
                for bit in range(DATA_BITS):
                    bit_val = (byte_val >> (7 - bit)) & 1
                    S(mx + 1 + bit, y_line, bit_val)

            micro_idx += 1

    # -------------------------------------------------------------------
    # 5. Indices en clair
    # -------------------------------------------------------------------
    # Lettres en haut
    for g, label in enumerate(COL_LABELS):
        cx = ox_grid + group_center_x[g] - 2
        draw_small_string(grid, W, H, label, cx, 5)

    # Lettres en bas
    for g, label in enumerate(COL_LABELS):
        cx = ox_grid + group_center_x[g] - 2
        draw_small_string(grid, W, H, label, cx, H - 15)

    # Numeros a gauche
    for s, label in enumerate(ROW_LABELS):
        cy = oy_grid + section_center_y[s] - 3
        draw_small_string(grid, W, H, label, 3, cy)

    # Numeros a droite
    for s, label in enumerate(ROW_LABELS):
        cy = oy_grid + section_center_y[s] - 3
        draw_small_string(grid, W, H, label, W - 16, cy)

    # Numero de page
    page_str = f"P{page_num:03d}/{total_pages:03d}"
    draw_small_string(grid, W, H, page_str, W - 60, H - 15)

    return grid, W, H


# =============================================================================
# RENDU
# =============================================================================

def grid_to_image(grid, W, H, scale):
    img_w = W * scale
    img_h = H * scale
    img = Image.new("L", (img_w, img_h), 255)
    draw = ImageDraw.Draw(img)
    for y in range(H):
        for x in range(W):
            if grid[y][x]:
                px = x * scale
                py = y * scale
                draw.rectangle([px, py, px + scale - 1, py + scale - 1], fill=0)
    return img


def main():
    if len(sys.argv) < 3:
        print("Usage: grid_encode.py INPUT_FILE OUTPUT_DIR [SCALE]")
        print("  Produit OUTPUT_DIR/page_001.pdf, page_002.pdf, ...")
        sys.exit(1)

    input_path = sys.argv[1]
    output_dir = sys.argv[2]
    scale = int(sys.argv[3]) if len(sys.argv) > 3 else 1

    os.makedirs(output_dir, exist_ok=True)

    with open(input_path, 'rb') as f:
        data = f.read()

    total_pages = (len(data) + BYTES_PER_PAGE - 1) // BYTES_PER_PAGE

    gw, gh = grid_dimensions()
    pw, ph = page_dimensions()

    print(f"Fichier         : {input_path}")
    print(f"Taille          : {len(data)} octets ({len(data)/1024:.1f} Ko)")
    print(f"Grille          : {gw} x {gh} points = {gw/10:.1f} x {gh/10:.1f} mm")
    print(f"Page avec index : {pw} x {ph} points = {pw/10:.1f} x {ph/10:.1f} mm")
    print(f"Macro-colonnes  : {GROUPS_H} ({COL_LABELS[0]}..{COL_LABELS[-1]})")
    print(f"Macro-lignes    : {SECTIONS_V} ({ROW_LABELS[0]}..{ROW_LABELS[-1]})")
    print(f"Octets/page     : {BYTES_PER_PAGE} ({BYTES_PER_PAGE/1024:.0f} Ko)")
    print(f"Pages           : {total_pages}")
    print(f"Echelle         : x{scale}")
    print()

    for page_num in range(1, total_pages + 1):
        start = (page_num - 1) * BYTES_PER_PAGE
        end = min(start + BYTES_PER_PAGE, len(data))
        page_data = data[start:end]

        grid, W, H = encode_page(page_data, page_num, total_pages)
        img = grid_to_image(grid, W, H, scale)

        pdf_path = os.path.join(output_dir, f"page_{page_num:03d}.pdf")
        img.convert("RGB").save(pdf_path, "PDF", dpi=(254, 254), resolution=254)
        print(f"  Page {page_num}/{total_pages} : {len(page_data)} octets -> {pdf_path}")

    print(f"\nTermine : {total_pages} page(s) dans {output_dir}/")


if __name__ == "__main__":
    main()
