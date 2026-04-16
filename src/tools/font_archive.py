"""
font_archive.py - Generateur des fichiers d'archive de la police.

Produit, pour la police Sometype Mono Bold a la taille utilisee par le
volume d'archive (24 pixels, cellule resserree a 14x25, pixels isoles
nettoyes), trois formats equivalents :

  sometype_24.txt  - Format texte en ASCII-art, maximalement lisible sans
                     aucun logiciel. Chaque caractere est affiche sur une
                     grille 14x25 de '#' et de '.'.

  sometype_24.hex  - Format Unifont .hex : une ligne par caractere,
                     "CODE_HEX:BITMAP_HEX" ou BITMAP_HEX est la concatenation
                     des 25 rangees, chaque rangee codee sur 2 octets.

  sometype_24.bdf  - Bitmap Distribution Format standard.

Ces fichiers decrivent exactement la police telle qu'elle apparait dans le
volume (preface et corps). Ils utilisent les memes parametres que
block_print.py : PIXEL_SIZE=24, cellule tight, nettoyage des pixels isoles.
"""
import freetype
import os
import sys

# =============================================================================
# PARAMETRES (identiques a block_print.py et preface.py)
# =============================================================================

FONT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                         "Sometype_Mono.ttf")

PIXEL_SIZE = 24
TIGHT_DESCENDER = 5

# Caracteres archives : ASCII imprimable + les deux marqueurs Latin-1
CODES_TO_ARCHIVE = list(range(32, 127)) + [172, 182]

# =============================================================================
# Chargement de la police (meme logique que block_print.py)
# =============================================================================

_face = freetype.Face(FONT_PATH)
_face.set_pixel_sizes(0, PIXEL_SIZE)

# Calculer l'ascender tight comme dans block_print.py : on mesure les
# caracteres les plus hauts effectivement utilises ({ } [ ] ( ) ! | " ' `)
_max_top = 0
for _ch in '{}[]()!|"\'`':
    _face.load_char(_ch, freetype.FT_LOAD_RENDER | freetype.FT_LOAD_MONOCHROME | freetype.FT_LOAD_TARGET_MONO)
    if _face.glyph.bitmap_top > _max_top:
        _max_top = _face.glyph.bitmap_top

TIGHT_ASCENDER = _max_top + 1
CELL_HEIGHT = TIGHT_ASCENDER + TIGHT_DESCENDER

# Largeur de cellule (police monospace)
_face.load_char('M', freetype.FT_LOAD_RENDER | freetype.FT_LOAD_MONOCHROME | freetype.FT_LOAD_TARGET_MONO)
CELL_WIDTH = _face.glyph.advance.x // 64

print(f"Cellule : {CELL_WIDTH} x {CELL_HEIGHT} pixels")
print(f"TIGHT_ASCENDER = {TIGHT_ASCENDER}, TIGHT_DESCENDER = {TIGHT_DESCENDER}")


def _get_bitmap_cells(ch):
    _face.load_char(ch, freetype.FT_LOAD_RENDER | freetype.FT_LOAD_MONOCHROME | freetype.FT_LOAD_TARGET_MONO)
    bm = _face.glyph.bitmap
    cells = []
    for y in range(bm.rows):
        row = []
        for x in range(bm.width):
            byte_idx = y * bm.pitch + (x // 8)
            bit_idx = 7 - (x % 8)
            row.append((bm.buffer[byte_idx] >> bit_idx) & 1)
        cells.append(row)
    return cells, _face.glyph.bitmap_left, _face.glyph.bitmap_top


def _clean_isolated(cells):
    """Supprime les pixels sans voisin orthogonal (identique a block_print.py)."""
    if not cells:
        return cells
    h = len(cells)
    w = len(cells[0])
    out = [row[:] for row in cells]
    for y in range(h):
        for x in range(w):
            if cells[y][x]:
                orth = 0
                if x > 0 and cells[y][x-1]: orth += 1
                if x < w-1 and cells[y][x+1]: orth += 1
                if y > 0 and cells[y-1][x]: orth += 1
                if y < h-1 and cells[y+1][x]: orth += 1
                if orth == 0:
                    out[y][x] = 0
    return out


def build_cell(ch):
    """Construit la matrice CELL_WIDTH x CELL_HEIGHT d'un caractere,
    avec le meme traitement que block_print.py (nettoyage des isoles,
    cellule resserree)."""
    idx = _face.get_char_index(ch)
    ch_render = ch if idx != 0 else '?'

    bm_cells, left, top = _get_bitmap_cells(ch_render)
    bm_cells = _clean_isolated(bm_cells)

    # Initialiser la cellule a vide
    cell = [[0] * CELL_WIDTH for _ in range(CELL_HEIGHT)]

    # Positionner la bitmap du glyphe dans la cellule selon son bitmap_left/top
    for y in range(len(bm_cells)):
        for x in range(len(bm_cells[y])):
            if bm_cells[y][x]:
                dx = left + x
                dy = TIGHT_ASCENDER - top + y
                if 0 <= dy < CELL_HEIGHT and 0 <= dx < CELL_WIDTH:
                    cell[dy][dx] = 1

    return cell


# =============================================================================
# Format TXT (ASCII-art, maximalement lisible)
# =============================================================================

def write_txt(out_path):
    with open(out_path, 'w') as f:
        f.write(f"# Sometype Mono Bold - taille {PIXEL_SIZE} pixels\n")
        f.write(f"# Cellule resserree : {CELL_WIDTH} x {CELL_HEIGHT} pixels\n")
        f.write(f"# TIGHT_ASCENDER = {TIGHT_ASCENDER}  (position de la ligne de base depuis le haut)\n")
        f.write(f"# TIGHT_DESCENDER = {TIGHT_DESCENDER}\n")
        f.write(f"# Les pixels isoles (sans aucun voisin orthogonal) ont ete supprimes.\n")
        f.write(f"# Chaque caractere est dessine sur une grille {CELL_WIDTH}x{CELL_HEIGHT}.\n")
        f.write(f"# '#' = pixel allume, '.' = pixel eteint.\n")
        f.write(f"# Origine : coin haut-gauche de la cellule.\n")
        f.write(f"#\n")
        f.write(f"# Cette police est celle utilisee dans le volume d'archive\n")
        f.write(f"# (preface et corps, voir block_print.py et preface.py).\n")
        f.write(f"\n")

        for code in CODES_TO_ARCHIVE:
            ch = chr(code)
            cell = build_cell(ch)
            f.write(f"--- CODE {code:3d} (0x{code:02X}) = '{ch}' ---\n")
            for row in cell:
                f.write("".join("#" if p else "." for p in row) + "\n")
            f.write("\n")


# =============================================================================
# Format HEX (Unifont-like)
# =============================================================================

def write_hex(out_path):
    bytes_per_row = (CELL_WIDTH + 7) // 8

    with open(out_path, 'w') as f:
        f.write(f"# Sometype Mono Bold - taille {PIXEL_SIZE}px - format .hex style unifont\n")
        f.write(f"# Cellule resserree : {CELL_WIDTH} x {CELL_HEIGHT} pixels ({bytes_per_row} octet(s) par rangee)\n")
        f.write(f"# Pixels isoles nettoyes. Format : CODE_HEX:BITMAP_HEX\n")
        f.write(f"# BITMAP_HEX = concatenation des {CELL_HEIGHT} rangees,\n")
        f.write(f"#              chaque rangee = {bytes_per_row} octet(s) en big-endian,\n")
        f.write(f"#              bit de poids fort = pixel de gauche.\n")
        f.write(f"# Cette police decrit exactement celle utilisee dans le volume d'archive.\n")
        f.write(f"\n")

        for code in CODES_TO_ARCHIVE:
            ch = chr(code)
            cell = build_cell(ch)
            hex_rows = []
            for row in cell:
                v = 0
                for i, p in enumerate(row):
                    if p:
                        v |= 1 << (bytes_per_row * 8 - 1 - i)
                hex_rows.append(f"{v:0{bytes_per_row * 2}X}")
            f.write(f"{code:04X}:{''.join(hex_rows)}\n")


# =============================================================================
# Format BDF (Bitmap Distribution Format)
# =============================================================================

def write_bdf(out_path):
    bytes_per_row = (CELL_WIDTH + 7) // 8

    with open(out_path, 'w') as f:
        f.write(f"STARTFONT 2.1\n")
        f.write(f"COMMENT Sometype Mono Bold - cellule resserree {CELL_WIDTH}x{CELL_HEIGHT}\n")
        f.write(f"COMMENT Pixels isoles nettoyes. Police du volume d'archive.\n")
        f.write(f"FONT -SometypeMono-Bold-R-Normal--{CELL_HEIGHT}-0-0-0-C-{CELL_WIDTH*10}-ISO10646-1\n")
        f.write(f"SIZE {PIXEL_SIZE} 72 72\n")
        f.write(f"FONTBOUNDINGBOX {CELL_WIDTH} {CELL_HEIGHT} 0 {-TIGHT_DESCENDER}\n")
        f.write(f"STARTPROPERTIES 2\n")
        f.write(f"FONT_ASCENT {TIGHT_ASCENDER}\n")
        f.write(f"FONT_DESCENT {TIGHT_DESCENDER}\n")
        f.write(f"ENDPROPERTIES\n")
        f.write(f"CHARS {len(CODES_TO_ARCHIVE)}\n")
        for code in CODES_TO_ARCHIVE:
            ch = chr(code)
            cell = build_cell(ch)
            f.write(f"STARTCHAR U+{code:04X}\n")
            f.write(f"ENCODING {code}\n")
            f.write(f"SWIDTH {int(1000 * CELL_WIDTH / PIXEL_SIZE)} 0\n")
            f.write(f"DWIDTH {CELL_WIDTH} 0\n")
            f.write(f"BBX {CELL_WIDTH} {CELL_HEIGHT} 0 {-TIGHT_DESCENDER}\n")
            f.write(f"BITMAP\n")
            for row in cell:
                v = 0
                for i, p in enumerate(row):
                    if p:
                        v |= 1 << (bytes_per_row * 8 - 1 - i)
                f.write(f"{v:0{bytes_per_row * 2}X}\n")
            f.write(f"ENDCHAR\n")
        f.write(f"ENDFONT\n")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    out_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    os.makedirs(out_dir, exist_ok=True)

    txt_path = os.path.join(out_dir, f"sometype_{PIXEL_SIZE}.txt")
    hex_path = os.path.join(out_dir, f"sometype_{PIXEL_SIZE}.hex")
    bdf_path = os.path.join(out_dir, f"sometype_{PIXEL_SIZE}.bdf")

    write_txt(txt_path)
    write_hex(hex_path)
    write_bdf(bdf_path)

    print(f"Fichiers ecrits dans {out_dir} :")
    for p in [txt_path, hex_path, bdf_path]:
        sz = os.path.getsize(p)
        print(f"  {os.path.basename(p):30s} {sz:6d} octets")
    print(f"Caracteres archives : {len(CODES_TO_ARCHIVE)} (codes {CODES_TO_ARCHIVE[:3]}... + 172, 182)")
