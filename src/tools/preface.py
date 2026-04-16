"""
preface.py - Generateur de la preface technique du volume d'archive.

Produit preface.pdf contenant :
  1. Page de titre / notice d'utilisation du format
  2. Table ASCII complete (codes 32..126) + marqueurs ¬ et ¶
  3. Planche de la police a taille d'impression reelle avec codes ASCII
  4. Planche de la police agrandie x8 pour identification precise

Utilise le meme moteur de rendu que block_print.py : meme police, memes
parametres, meme aspect visuel. Tout caractere apparaissant dans le corps
de l'archive peut ainsi etre reconnu directement sur cette planche.
"""
import freetype
import sys
import os
from PIL import Image, ImageDraw

# =============================================================================
# PARAMETRES (identiques a block_print.py)
# =============================================================================

FONT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                         "Sometype_Mono.ttf")

PIXEL_SIZE   = 24
PRINT_SCALE  = 1
DPI          = 300

MARGIN_L = 0.5
MARGIN_R = 0.5
MARGIN_T = 0.5
MARGIN_B = 0.5

TIGHT_DESCENDER = 5

# =============================================================================
# Constantes calculees
# =============================================================================

PAGE_W_PX = int(8.27 * DPI)
PAGE_H_PX = int(11.69 * DPI)
ML_PX = int(MARGIN_L * DPI)
MR_PX = int(MARGIN_R * DPI)
MT_PX = int(MARGIN_T * DPI)
MB_PX = int(MARGIN_B * DPI)

# =============================================================================
# Chargement de la police
# =============================================================================

_face = freetype.Face(FONT_PATH)
_face.set_pixel_sizes(0, PIXEL_SIZE)

_asc_native = _face.size.ascender // 64
_desc_native = -_face.size.descender // 64

_max_top = 0
for _ch in '{}[]()!|"\'`':
    _face.load_char(_ch, freetype.FT_LOAD_RENDER | freetype.FT_LOAD_MONOCHROME | freetype.FT_LOAD_TARGET_MONO)
    if _face.glyph.bitmap_top > _max_top:
        _max_top = _face.glyph.bitmap_top

TIGHT_ASCENDER = _max_top + 1
LINE_HEIGHT = TIGHT_ASCENDER + TIGHT_DESCENDER

_face.load_char('M', freetype.FT_LOAD_RENDER | freetype.FT_LOAD_MONOCHROME | freetype.FT_LOAD_TARGET_MONO)
CELL_W = _face.glyph.advance.x // 64


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


_glyph_cache = {}

def _get_glyph_pixels(ch):
    if ch in _glyph_cache:
        return _glyph_cache[ch]
    idx = _face.get_char_index(ch)
    ch_render = ch if idx != 0 else '?'

    cells, left, top = _get_bitmap_cells(ch_render)
    cells = _clean_isolated(cells)

    pixels = []
    for y in range(len(cells)):
        for x in range(len(cells[y])):
            if cells[y][x]:
                dx = left + x
                dy = TIGHT_ASCENDER - top + y
                pixels.append((dx, dy))
    _glyph_cache[ch] = pixels
    return pixels


# =============================================================================
# Rendu de base
# =============================================================================

def draw_string(draw, s, origin_x, origin_y_top, scale):
    """Trace la chaine s avec la police a l'echelle scale."""
    pen_x = origin_x
    for ch in s:
        for dx, dy in _get_glyph_pixels(ch):
            px = pen_x + dx * scale
            py = origin_y_top + dy * scale
            draw.rectangle([px, py, px + scale - 1, py + scale - 1], fill=0)
        pen_x += CELL_W * scale


def new_page_image():
    img = Image.new("L", (PAGE_W_PX, PAGE_H_PX), 255)
    draw = ImageDraw.Draw(img)
    return img, draw


# =============================================================================
# PAGE 1 : Notice d'utilisation du format
# =============================================================================

NOTICE_LINES = [
    "-- FICHIER: preface.notice  PAGE: 1/N  DEBUT",
    "",
    "",
    "                            VOLUME D'ARCHIVAGE - NOTICE TECHNIQUE",
    "",
    "",
    "Ce volume contient le code source d'un compilateur Ada, imprime dans un format",
    "destine a la conservation a long terme sans support electronique, et prevu pour",
    "permettre a un lecteur futur de retrouver integralement le contenu du source",
    "original, soit a la lecture humaine directe, soit par ressaisie manuelle, soit",
    "par reconnaissance optique de caracteres (OCR).",
    "",
    "",
    "1. STRUCTURE GENERALE",
    "",
    "Chaque fichier source Ada est imprime sur une ou plusieurs pages. Chaque page",
    "porte en haut et en bas une ligne de balise au format commentaire Ada :",
    "",
    "    -- FICHIER: <chemin/nom>  PAGE: n/N  DEBUT",
    "    -- FICHIER: <chemin/nom>  PAGE: n/N  FIN",
    "",
    "ou <chemin/nom> est le chemin relatif du fichier dans l'arborescence source,",
    "n est le numero de la page courante et N le nombre total de pages du fichier.",
    "Ces lignes sont separees du corps du texte par une ligne blanche, facilitant",
    "la detection automatique des limites du bloc.",
    "",
    "",
    "2. FORMAT DU CORPS DE PAGE",
    "",
    "Le texte source est concatene : les retours a la ligne du source d'origine ne",
    "produisent pas de retour a la ligne dans l'impression. Le texte est ensuite",
    "coupe en blocs de 150 caracteres utiles, chacun imprime sur une ligne. Les",
    "tabulations et retours a la ligne du source sont visualises par deux",
    "caracteres speciaux :",
    "",
    "    ¬   (code 172, NOT SIGN)       : une tabulation (HT, code ASCII 9)",
    "    ¶   (code 182, PILCROW SIGN)   : une fin de ligne source (LF, code 10)",
    "",
    "Chaque ligne de bloc est precedee d'un prefixe de 5 caracteres qui contient",
    "tous les 10 blocs le numero du bloc au format NNNN suivi d'un espace, et",
    "sinon 5 espaces. Une ligne blanche est inseree tous les 50 blocs pour faciliter",
    "le reperage visuel.",
    "",
    "",
    "3. RECONSTITUTION DU SOURCE ORIGINAL",
    "",
    "A partir de la ressaisie du corps de page, pour retrouver le source Ada :",
    "",
    "    a) Retirer pour chaque ligne le prefixe de 5 caracteres.",
    "    b) Ignorer les lignes completement blanches (separateurs de section).",
    "    c) Concatener toutes les lignes restantes en une seule chaine.",
    "    d) Remplacer chaque ¬ par une tabulation (HT).",
    "    e) Remplacer chaque ¶ par un saut de ligne (LF). Chaque ¶ marque la",
    "       fin d'une ligne du source original.",
    "",
    "Les indentations et alignements d'origine sont preserves par les tabulations",
    "reglees a 10 caracteres : un editeur de texte utilisant des tabulations de",
    "10 colonnes restituera l'aspect visuel exact du source original.",
    "",
    "",
    "4. JEU DE CARACTERES",
    "",
    "Seuls les caracteres ASCII imprimables (codes 32 a 126) apparaissent dans le",
    "corps du texte, outre les deux marqueurs ¬ et ¶ qui sont en Latin-1. La police",
    "utilisee est Sometype Mono Bold, specifiquement choisie pour la distinction",
    "nette des caracteres potentiellement confondables (zero barre, 1 avec pied,",
    "l minuscule avec crosse, etc.). La planche de reference des glyphes et la",
    "table ASCII figurent dans les pages suivantes de cette preface.",
    "",
    "-- FICHIER: preface.notice  PAGE: 1/N  FIN",
]


def render_notice(page_num=1, total=4):
    """Page de notice : texte simple, rendu avec la meme police que le corps."""
    img, draw = new_page_image()

    # Remplacer "1/N" par "page_num/total" dans le tableau NOTICE_LINES
    lines = []
    for line in NOTICE_LINES:
        lines.append(line.replace("1/N", f"{page_num}/{total}"))

    y = MT_PX
    for line in lines:
        if y + LINE_HEIGHT * PRINT_SCALE > PAGE_H_PX - MB_PX:
            break
        draw_string(draw, line, ML_PX, y, PRINT_SCALE)
        y += LINE_HEIGHT * PRINT_SCALE
    return img


# =============================================================================
# PAGE 2 : Planche de la police a taille reelle, avec codes
# =============================================================================

def render_glyph_chart_real_size(page_num=2, total=4):
    """Planche des caracteres a taille d'impression reelle (PRINT_SCALE=1).
    Chaque caractere est accompagne de son code ASCII decimal."""
    img, draw = new_page_image()
    y = MT_PX

    header = f"-- FICHIER: preface.police_taille_reelle  PAGE: {page_num}/{total}  DEBUT"
    draw_string(draw, header, ML_PX, y, PRINT_SCALE)
    y += 2 * LINE_HEIGHT * PRINT_SCALE

    title = "PLANCHE DES CARACTERES A TAILLE D'IMPRESSION REELLE"
    draw_string(draw, title, ML_PX, y, PRINT_SCALE)
    y += 2 * LINE_HEIGHT * PRINT_SCALE

    note = "Chaque cellule : code ASCII decimal, suivi du caractere. Taille nominale : 2 mm de hauteur."
    draw_string(draw, note, ML_PX, y, PRINT_SCALE)
    y += 2 * LINE_HEIGHT * PRINT_SCALE

    # Caracteres : 32..126 + 172 + 182 = 97 caracteres
    chars = [chr(c) for c in range(32, 127)] + [chr(172), chr(182)]

    # Mise en grille : 6 colonnes de "NNN C" (5 caracteres + espace separateur)
    cols = 6
    cell_txt_len = 7  # "NNN C  " = 3 chiffres + espace + caractere + 2 espaces
    for i, ch in enumerate(chars):
        col = i % cols
        row = i // cols
        code = ord(ch)
        s = f"{code:3d} {ch}"
        cell_x = ML_PX + col * (CELL_W * PRINT_SCALE * (cell_txt_len + 2))
        cell_y = y + row * LINE_HEIGHT * PRINT_SCALE
        if cell_y + LINE_HEIGHT * PRINT_SCALE > PAGE_H_PX - MB_PX - 2 * LINE_HEIGHT * PRINT_SCALE:
            break
        draw_string(draw, s, cell_x, cell_y, PRINT_SCALE)

    footer = f"-- FICHIER: preface.police_taille_reelle  PAGE: {page_num}/{total}  FIN"
    footer_y = PAGE_H_PX - MB_PX - LINE_HEIGHT * PRINT_SCALE
    draw_string(draw, footer, ML_PX, footer_y, PRINT_SCALE)

    return img


# =============================================================================
# PAGE 3 : Planche de la police agrandie, pour identification
# =============================================================================

def render_glyph_chart_magnified(page_num=3, total=4):
    """Planche des caracteres agrandis x6, avec code ASCII au-dessus.
    Permet l'identification precise de chaque glyphe, et la reconstruction
    du bitmap pixel par pixel le cas echeant."""
    img, draw = new_page_image()
    y = MT_PX

    header = f"-- FICHIER: preface.police_agrandie  PAGE: {page_num}/{total}  DEBUT"
    draw_string(draw, header, ML_PX, y, PRINT_SCALE)
    y += 2 * LINE_HEIGHT * PRINT_SCALE

    title = "PLANCHE DES CARACTERES AGRANDIS x6 - IDENTIFICATION VISUELLE"
    draw_string(draw, title, ML_PX, y, PRINT_SCALE)
    y += 2 * LINE_HEIGHT * PRINT_SCALE

    # Caracteres 32..126 + marqueurs
    chars = [chr(c) for c in range(32, 127)] + [chr(172), chr(182)]

    magnify = 6
    # Pour chaque caractere : code en petit au-dessus, caractere agrandi en dessous
    # Cellule totale : largeur = CELL_W * magnify + petit espace
    #                 hauteur = LINE_HEIGHT * magnify + LINE_HEIGHT (pour le code)
    cell_w_tot = CELL_W * magnify * PRINT_SCALE + 4 * PRINT_SCALE
    cell_h_tot = LINE_HEIGHT * magnify * PRINT_SCALE + LINE_HEIGHT * PRINT_SCALE + 4 * PRINT_SCALE

    cols = (PAGE_W_PX - ML_PX - MR_PX) // cell_w_tot
    avail_h = PAGE_H_PX - MB_PX - y - 2 * LINE_HEIGHT * PRINT_SCALE   # reserver pour footer
    rows = avail_h // cell_h_tot

    for i, ch in enumerate(chars):
        col = i % cols
        row = i // cols
        if row >= rows:
            break
        cell_x = ML_PX + col * cell_w_tot
        cell_y = y + row * cell_h_tot

        # Code ASCII en petit au-dessus (echelle 1, aligne a gauche de la cellule)
        code_str = f"{ord(ch):3d}"
        draw_string(draw, code_str, cell_x, cell_y, PRINT_SCALE)

        # Caractere agrandi x6 en dessous
        glyph_y = cell_y + LINE_HEIGHT * PRINT_SCALE + 2 * PRINT_SCALE
        draw_string(draw, ch, cell_x, glyph_y, magnify * PRINT_SCALE)

    footer = f"-- FICHIER: preface.police_agrandie  PAGE: {page_num}/{total}  FIN"
    footer_y = PAGE_H_PX - MB_PX - LINE_HEIGHT * PRINT_SCALE
    draw_string(draw, footer, ML_PX, footer_y, PRINT_SCALE)

    return img, len(chars) - (cols * rows) if cols * rows < len(chars) else 0


# =============================================================================
# PAGE 4 : Table ASCII complete
# =============================================================================

def render_ascii_table(page_num=4, total=4):
    """Table ASCII complete (codes 0..127) avec nom des caracteres de controle
    et indication des deux marqueurs ¬ et ¶."""
    img, draw = new_page_image()
    y = MT_PX

    header = f"-- FICHIER: preface.table_ascii  PAGE: {page_num}/{total}  DEBUT"
    draw_string(draw, header, ML_PX, y, PRINT_SCALE)
    y += 2 * LINE_HEIGHT * PRINT_SCALE

    title = "TABLE ASCII (codes 0..127) ET MARQUEURS LATIN-1"
    draw_string(draw, title, ML_PX, y, PRINT_SCALE)
    y += 2 * LINE_HEIGHT * PRINT_SCALE

    ctl_names = [
        "NUL", "SOH", "STX", "ETX", "EOT", "ENQ", "ACK", "BEL",
        "BS ", "HT ", "LF ", "VT ", "FF ", "CR ", "SO ", "SI ",
        "DLE", "DC1", "DC2", "DC3", "DC4", "NAK", "SYN", "ETB",
        "CAN", "EM ", "SUB", "ESC", "FS ", "GS ", "RS ", "US ",
    ]

    # Format : DEC HEX GLYPHE NOM      DEC HEX GLYPHE NOM      ...
    # 4 colonnes, 32 lignes (pour 128 codes)
    col_width_chars = 16
    cols = 4
    rows = 32

    for i in range(128):
        col = i // rows
        row = i % rows
        cell_x = ML_PX + col * col_width_chars * CELL_W * PRINT_SCALE
        cell_y = y + row * LINE_HEIGHT * PRINT_SCALE

        if i < 32:
            # Caractere de controle
            s = f"{i:3d} {i:02X} .  {ctl_names[i]}"
        elif i == 127:
            s = f"{i:3d} {i:02X} .  DEL"
        else:
            # Caractere imprimable
            s = f"{i:3d} {i:02X} {chr(i)}"
        draw_string(draw, s, cell_x, cell_y, PRINT_SCALE)

    # Ajouter les deux marqueurs Latin-1 en dessous
    marker_y = y + (rows + 1) * LINE_HEIGHT * PRINT_SCALE
    draw_string(draw, "MARQUEURS LATIN-1 UTILISES DANS LE CORPS :", ML_PX, marker_y, PRINT_SCALE)
    marker_y += LINE_HEIGHT * PRINT_SCALE
    draw_string(draw, f"172 AC {chr(172)}  NOT SIGN     = TABULATION (HT, code 9 ASCII)",
                ML_PX, marker_y, PRINT_SCALE)
    marker_y += LINE_HEIGHT * PRINT_SCALE
    draw_string(draw, f"182 B6 {chr(182)}  PILCROW SIGN = FIN DE LIGNE SOURCE (LF, code 10 ASCII)",
                ML_PX, marker_y, PRINT_SCALE)

    footer = f"-- FICHIER: preface.table_ascii  PAGE: {page_num}/{total}  FIN"
    footer_y = PAGE_H_PX - MB_PX - LINE_HEIGHT * PRINT_SCALE
    draw_string(draw, footer, ML_PX, footer_y, PRINT_SCALE)

    return img


# =============================================================================
# ASSEMBLAGE
# =============================================================================

def build_preface(out_path):
    # Premiere passe : compter le nombre total de pages
    # (on sait que c'est 4 dans la version actuelle, mais faisons proprement)

    # Parametres : 1 page notice, 1 page taille reelle, 1 page agrandie,
    #              1 page table ASCII
    TOTAL = 4

    pages = []

    # Page 1 : notice
    pages.append(render_notice(page_num=1, total=TOTAL))

    # Page 2 : planche a taille reelle
    pages.append(render_glyph_chart_real_size(page_num=2, total=TOTAL))

    # Page 3 : planche agrandie
    p, remaining = render_glyph_chart_magnified(page_num=3, total=TOTAL)
    pages.append(p)
    if remaining > 0:
        print(f"Attention : {remaining} caracteres n'ont pas tenu sur la planche agrandie.")

    # Page 4 : table ASCII
    pages.append(render_ascii_table(page_num=4, total=TOTAL))

    total = len(pages)
    print(f"Nombre total de pages de preface : {total}")

    rgb = [p.convert("RGB") for p in pages]
    rgb[0].save(out_path, "PDF", dpi=(DPI, DPI), resolution=DPI,
                save_all=True, append_images=rgb[1:])
    print(f"Preface ecrite : {out_path}")


if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else "preface.pdf"
    build_preface(out)
