"""
block_print.py - Generateur d'archive PDF imprimable depuis une arborescence
                  de fichiers mis en bloc par BLOCK_SAVE.

Usage :
    python3 block_print.py [BLK_SRC] [PDF_SRC]

Sans arguments : utilise ./BLK_SRC/ en entree et ./PDF_SRC/ en sortie.
Avec arguments : utilise les repertoires specifies.

Parcourt recursivement BLK_SRC, et pour chaque fichier trouve, produit un
PDF correspondant dans PDF_SRC en preservant l'arborescence. Le nom du
PDF est celui du fichier bloc avec l'extension remplacee par ".pdf".

Parametres ajustables en tete de fichier :
  - PIXEL_SIZE : hauteur de la police en pixels du bitmap (24 recommande)
  - PRINT_SCALE : agrandissement a l'impression (1 = tres dense, 2 = confort)
  - DPI : resolution cible de l'imprimante (300 pour EPSON ET-2810)
  - TIGHT_DESCENDER : descender utile (5 au lieu de 8 pour densifier)
"""
import freetype
import sys
import os
from PIL import Image, ImageDraw

# =============================================================================
# PARAMETRES
# =============================================================================

FONT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                         "Sometype_Mono.ttf")

PIXEL_SIZE   = 24    # hauteur de la police en pixels
PRINT_SCALE  = 1     # 1 pixel de police = PRINT_SCALE x PRINT_SCALE dots imprimes
DPI          = 300   # resolution d'impression

# Marges en pouces
MARGIN_L = 0.5
MARGIN_R = 0.5
MARGIN_T = 0.5
MARGIN_B = 0.5

# Compression verticale : on garde le corps des lettres mais on reduit
# le descender. Mettre a None pour garder l'interligne natif de la police.
TIGHT_DESCENDER = 5  # pixels (natif: 8)

# =============================================================================
# Constantes calculees
# =============================================================================

PAGE_W_PX = int(8.27 * DPI)    # A4 largeur
PAGE_H_PX = int(11.69 * DPI)   # A4 hauteur
ML_PX = int(MARGIN_L * DPI)
MR_PX = int(MARGIN_R * DPI)
MT_PX = int(MARGIN_T * DPI)
MB_PX = int(MARGIN_B * DPI)

# =============================================================================
# Chargement et preparation de la police
# =============================================================================

_face = freetype.Face(FONT_PATH)
_face.set_pixel_sizes(0, PIXEL_SIZE)

_asc_native = _face.size.ascender // 64
_desc_native = -_face.size.descender // 64

# Mesure des limites reelles necessaires (hauteurs pour '{', '[', etc.)
_max_top = 0
for _ch in '{}[]()!|"\'`':
    _face.load_char(_ch, freetype.FT_LOAD_RENDER | freetype.FT_LOAD_MONOCHROME | freetype.FT_LOAD_TARGET_MONO)
    if _face.glyph.bitmap_top > _max_top:
        _max_top = _face.glyph.bitmap_top

TIGHT_ASCENDER = _max_top + 1   # petit jeu de securite
if TIGHT_DESCENDER is None:
    TIGHT_DESCENDER = _desc_native

LINE_HEIGHT = TIGHT_ASCENDER + TIGHT_DESCENDER

# Largeur de cellule (police monospace)
_face.load_char('M', freetype.FT_LOAD_RENDER | freetype.FT_LOAD_MONOCHROME | freetype.FT_LOAD_TARGET_MONO)
CELL_W = _face.glyph.advance.x // 64


def _get_bitmap_cells(ch):
    """Bitmap brut de ch comme liste de listes de 0/1."""
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
    """Supprime les pixels n'ayant aucun voisin orthogonal (bavures)."""
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


# Cache de glyphes : caractere -> liste de (dx, dy) dans la cellule
_glyph_cache = {}

def _get_glyph_pixels(ch):
    if ch in _glyph_cache:
        return _glyph_cache[ch]
    idx = _face.get_char_index(ch)
    if idx == 0:
        ch_render = '?'
    else:
        ch_render = ch

    cells, left, top = _get_bitmap_cells(ch_render)
    cells = _clean_isolated(cells)

    pixels = []
    for y in range(len(cells)):
        for x in range(len(cells[y])):
            if cells[y][x]:
                dx = left + x
                dy = TIGHT_ASCENDER - top + y
                if 0 <= dy < LINE_HEIGHT and 0 <= dx < CELL_W + 2:
                    pixels.append((dx, dy))
    _glyph_cache[ch] = pixels
    return pixels


# =============================================================================
# Rendu
# =============================================================================

def draw_string(draw, s, origin_x, origin_y_top, scale):
    """Trace la chaine s avec origine au coin haut-gauche de la cellule-ligne."""
    pen_x = origin_x
    for ch in s:
        for dx, dy in _get_glyph_pixels(ch):
            px = pen_x + dx * scale
            py = origin_y_top + dy * scale
            draw.rectangle([px, py, px + scale - 1, py + scale - 1], fill=0)
        pen_x += CELL_W * scale


def lines_per_page():
    avail_h = PAGE_H_PX - MT_PX - MB_PX
    return avail_h // (LINE_HEIGHT * PRINT_SCALE)


def cols_per_page():
    avail_w = PAGE_W_PX - ML_PX - MR_PX
    return avail_w // (CELL_W * PRINT_SCALE)


def render_page(body_lines, header, footer):
    img = Image.new("L", (PAGE_W_PX, PAGE_H_PX), 255)
    draw = ImageDraw.Draw(img)
    y = MT_PX
    # En-tete, puis une ligne vide pour encadrer le bloc de texte.
    draw_string(draw, header, ML_PX, y, PRINT_SCALE)
    y += 2 * LINE_HEIGHT * PRINT_SCALE
    # Corps
    for line in body_lines:
        draw_string(draw, line, ML_PX, y, PRINT_SCALE)
        y += LINE_HEIGHT * PRINT_SCALE
    # Pied de page positionne en bas, precede d'une ligne vide.
    footer_y = PAGE_H_PX - MB_PX - LINE_HEIGHT * PRINT_SCALE
    draw_string(draw, footer, ML_PX, footer_y, PRINT_SCALE)
    return img


def process_file(blocked_path, source_name, out_pdf_path):
    """Rend un fichier bloc en PDF d'archivage."""
    with open(blocked_path, 'r', encoding='latin-1') as f:
        all_lines = [line.rstrip('\n') for line in f]

    lpp = lines_per_page()
    body_per_page = lpp - 4   # reserver en-tete + ligne vide + ligne vide + pied
    if body_per_page <= 0:
        raise ValueError("Page trop petite pour contenir du texte.")
    total_pages = (len(all_lines) + body_per_page - 1) // body_per_page

    pil_pages = []
    for page_num in range(1, total_pages + 1):
        start = (page_num - 1) * body_per_page
        end = start + body_per_page
        chunk = all_lines[start:end]
        header = f"-- FICHIER: {source_name}  PAGE: {page_num}/{total_pages}  DEBUT"
        footer = f"-- FICHIER: {source_name}  PAGE: {page_num}/{total_pages}  FIN"
        pil_pages.append(render_page(chunk, header, footer))

    if pil_pages:
        out_dir = os.path.dirname(out_pdf_path)
        if out_dir:
            os.makedirs(out_dir, exist_ok=True)
        rgb_pages = [p.convert("RGB") for p in pil_pages]
        rgb_pages[0].save(out_pdf_path, "PDF",
                          dpi=(DPI, DPI), resolution=DPI,
                          save_all=True, append_images=rgb_pages[1:])
    return total_pages, len(all_lines)


def blocked_to_source_name(blocked_name):
    """Inverse de BLOCKED_NAME : restitue le nom du fichier source original.
    Exemple : 'block_save.Badb' -> 'block_save.adb'.
    Le format produit par block_save.adb est : nom + '.B' + 2 caracteres
    d'extension restants."""
    dot = blocked_name.rfind('.')
    if dot >= 0 and dot < len(blocked_name) - 1 and blocked_name[dot+1] == 'B':
        # Enleve le 'B' juste apres le dernier point
        return blocked_name[:dot+1] + blocked_name[dot+2:]
    return blocked_name


def process_tree(blk_src_dir, pdf_src_dir):
    """Parcourt recursivement blk_src_dir et produit les PDF dans pdf_src_dir."""
    if not os.path.isdir(blk_src_dir):
        print(f"Repertoire introuvable : {blk_src_dir}")
        sys.exit(1)

    blocked_files = []
    for root, dirs, files in os.walk(blk_src_dir):
        for fname in files:
            full_path = os.path.join(root, fname)
            rel_path = os.path.relpath(full_path, blk_src_dir)
            blocked_files.append((full_path, rel_path))
    blocked_files.sort(key=lambda t: t[1])

    if not blocked_files:
        print(f"Aucun fichier trouve dans {blk_src_dir}")
        sys.exit(1)

    print(f"Parametres : cellule {CELL_W}x{LINE_HEIGHT} px, "
          f"{cols_per_page()} colonnes, {lines_per_page()} lignes/page")
    print(f"Entree : {blk_src_dir}")
    print(f"Sortie : {pdf_src_dir}")
    print()
    print(f"{'FICHIER':<55s} {'PAGES':>7s} {'LIGNES':>8s}")
    print("-" * 72)

    total_pages = 0
    total_lines = 0
    for blocked_full, rel_path in blocked_files:
        rel_dir = os.path.dirname(rel_path)
        blocked_fname = os.path.basename(rel_path)
        source_fname = blocked_to_source_name(blocked_fname)

        if rel_dir:
            source_display = os.path.join(rel_dir, source_fname).replace(os.sep, '/')
        else:
            source_display = source_fname

        pdf_fname = os.path.splitext(blocked_fname)[0] + ".pdf"
        pdf_path = os.path.join(pdf_src_dir, rel_dir, pdf_fname)

        pages, lines = process_file(blocked_full, source_display, pdf_path)
        total_pages += pages
        total_lines += lines

        disp = source_display
        if len(disp) > 54:
            disp = "..." + disp[-51:]
        print(f"{disp:<55s} {pages:>7d} {lines:>8d}")

    print("-" * 72)
    print(f"{'TOTAL':<55s} {total_pages:>7d} {total_lines:>8d}")


if __name__ == "__main__":
    blk_src = sys.argv[1] if len(sys.argv) > 1 else "./BLK_SRC"
    pdf_src = sys.argv[2] if len(sys.argv) > 2 else "./PDF_SRC"
    process_tree(blk_src, pdf_src)
