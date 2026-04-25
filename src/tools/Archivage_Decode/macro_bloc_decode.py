"""
macro_bloc_decode.py

Decodage d'un seul macro-bloc (8 x 8 micro-blocs = 64 micro-blocs = 512 octets)
a partir d'une image en niveaux de gris ou le macro-bloc est entoure de ses
4 croix de centrage aux coins.

Structure du macro-bloc en coordonnees grille :
  Largeur 88 points (entre les deux V2 consecutives qui bordent le macro-bloc):
    - V2 gauche : centre a gx=2 (mur noir de 5 pts, colonnes 0..4)
    - Blanc a la colonne 5
    - Micros horizontaux 1-4 : mx = 6, 16, 26, 36 (chacun 10 pts de large)
    - V1 : colonne 46 (noire) + colonne 47 (blanche) = 2 pts
    - Micros horizontaux 5-8 : mx = 48, 58, 68, 78
    - Blanc a la colonne 88
    - V2 droite : centre a gx=90

  Hauteur 82 points (entre croix extra haute gy=-2 et H2 interne gy=80):
    - H2 extra haute : gy=-2 (dans le prolongement V2)
    - Plafond du 1er micro-bloc : gy=0
    - Lignes de donnees 1-8 : gy=1..8
    - Plancher du 1er micro-bloc / plafond du 2e : gy=9/gy=10 ? Non:
      chaque micro-bloc a 10 pts de haut (gy mod 10 = 0 => plafond noir
      complet, gy mod 10 = 9 => ligne blanche suivante).
    - H2 interne : gy=80 (ligne noire complete entre sections)

  Dans chaque micro-bloc (10x10 pts) :
    - Plafond : gy=0 (relatif au micro), 9 points noirs aux colonnes 0..8
    - Colonne N (mur gauche) : gx=0, 8 points noirs aux lignes 1..8
    - Bits de donnees : gx=1..8, gy=1..8 (64 bits = 8 octets)
    - Ligne 9 (gy=9) : blanche (separateur vers le micro suivant)
    - Colonne 9 (gx=9) : blanche aussi
"""

import numpy as np


# ============================================================================
# Constantes de la structure (en points de grille, 1 pt = 0.1 mm)
# ============================================================================

# Positions en X (dans le macro-bloc, gx relatif entre V2 gauche et V2 droite)
V2_GAUCHE_X = 2    # centre V2 gauche
V2_DROITE_X = 90   # centre V2 droite
V1_NOIR_X = 46     # colonne noire de V1
V1_BLANC_X = 47    # colonne blanche de V1 (apres le noir)

# Positions en Y dans le macro-bloc (gy relatif)
CROIX_HAUTE_Y = -2     # croix extra haute
CROIX_BASSE_Y = 80     # 1re H2 interne

# Nombre de micro-blocs
MICROS_H = 8   # 4 + 4 (de part et d'autre de V1)
MICROS_V = 8   # 8 lignes

# Positions mx (colonne de depart) des 8 micros horizontaux
MICROS_MX = [6, 16, 26, 36, 48, 58, 68, 78]
# Positions my (ligne de depart) des 8 micros verticaux
MICROS_MY = [0, 10, 20, 30, 40, 50, 60, 70]

# Taille d'un micro-bloc
MICRO_W = 10   # largeur en points
MICRO_H = 10   # hauteur en points
DATA_BITS = 8  # bits de donnee par ligne
DATA_ROWS = 8  # lignes de donnees par micro-bloc


# ============================================================================
# Detection des 4 croix de centrage
# ============================================================================

def find_cross_in_region(gray, y_center, x_center, search_half=15,
                          brightness_thresh_ratio=0.85):
    """Cherche le centre d'une croix blanche dans une petite zone.

    gray                     : image en gris
    y_center, x_center       : centre approximatif de la zone de recherche
    search_half              : demi-taille de la zone (rectangle de 2*half+1)
    brightness_thresh_ratio  : ratio (par rapport au max local) pour
                               definir les pixels consideres comme "croix"

    Retourne (cy, cx) sub-pixel, ou None si pas de structure trouvee.
    """
    h, w = gray.shape
    y_lo = max(0, y_center - search_half)
    y_hi = min(h, y_center + search_half + 1)
    x_lo = max(0, x_center - search_half)
    x_hi = min(w, x_center + search_half + 1)
    patch = gray[y_lo:y_hi, x_lo:x_hi].astype(np.float64)

    p_max = patch.max()
    if p_max < 100:
        return None

    # Pixels clairs : valeur >= brightness_thresh_ratio * p_max
    thresh = p_max * brightness_thresh_ratio
    mask = patch >= thresh

    if not mask.any():
        return None

    # Barycentre pondere par l'intensite
    ys, xs = np.where(mask)
    weights = patch[mask]
    total_w = np.sum(weights)
    cy_local = np.sum(ys * weights) / total_w
    cx_local = np.sum(xs * weights) / total_w

    return (y_lo + cy_local, x_lo + cx_local)


def find_four_crosses(gray, verbose=False, corner_size_x=12, corner_size_y=15):
    """Detecte les 4 croix de centrage aux 4 coins de l'image.

    On suppose que l'image a ete CROPPEE AUTOUR des 4 croix, qui sont
    donc collees aux 4 coins de l'image, juste a cote du bord de la V2.

    Les V2 (gauche et droite) occupent typiquement les 10-12 px proches
    des bords verticaux de l'image. Les croix sont dans CES bandes V2,
    pas au-dela (car au-dela il y a la zone de contenu des micro-blocs
    qui est principalement blanche).

    Methode : dans un rectangle etroit aux 4 coins, pic de brightness.

    corner_size_x : largeur X de la zone de recherche (doit rester dans
                    la V2, typiquement 10-15 px a 1200 dpi)
    corner_size_y : hauteur Y de la zone de recherche
    """
    h, w = gray.shape

    def find_cross_in_corner(gray, y0, x0, sx, sy):
        """Cherche la croix dans [y0:y0+sy, x0:x0+sx]."""
        h, w = gray.shape
        y_lo = max(0, y0)
        y_hi = min(h, y0 + sy)
        x_lo = max(0, x0)
        x_hi = min(w, x0 + sx)
        patch = gray[y_lo:y_hi, x_lo:x_hi].astype(np.float64)
        if patch.size == 0:
            return None
        p_max = patch.max()
        if p_max < 100:
            return None
        # Seuil : 80% du max pour isoler le pic brillant
        thresh = p_max * 0.8
        mask = patch >= thresh
        if not mask.any():
            return None
        ys, xs = np.where(mask)
        weights = patch[mask]
        cy = y_lo + np.sum(ys * weights) / np.sum(weights)
        cx = x_lo + np.sum(xs * weights) / np.sum(weights)
        return (cy, cx)

    HG = find_cross_in_corner(gray, 0, 0,
                                corner_size_x, corner_size_y)
    HD = find_cross_in_corner(gray, 0, w - corner_size_x,
                                corner_size_x, corner_size_y)
    BG = find_cross_in_corner(gray, h - corner_size_y, 0,
                                corner_size_x, corner_size_y)
    BD = find_cross_in_corner(gray, h - corner_size_y, w - corner_size_x,
                                corner_size_x, corner_size_y)

    return HG, HD, BG, BD


# ============================================================================
# Transformation bilineaire coord grille -> coord image
# ============================================================================

# Offsets empiriques a appliquer sur les coordonnees grille avant conversion.
#
# Ces valeurs ont ete determinees experimentalement sur macro-bloc-1.png :
#   - Le decalage optimal VARIE selon la position horizontale du micro-bloc
#   - Il y a une discontinuite au niveau de la V1 (separateur vertical au
#     milieu du macro-bloc)
#   - L'offset est approximativement lineaire entre mi=0 et mi=3 (demi gauche),
#     puis entre mi=4 et mi=7 (demi droite).
#
# Offsets retenus (optimises pour macro-bloc-1.png):
#   Demi gauche (mi=0..3) : offset varie lineairement de -0.10 a +0.05 (en gx)
#   Demi droite (mi=4..7) : offset varie lineairement de  0.00 a +0.35 (en gx)
#
# Offset vertical : +0.10 (constant)
#
# Ces valeurs devraient probablement etre adaptees dynamiquement par
# detection dans chaque macro-bloc. Pour l'instant on utilise les valeurs
# empiriques.
OFFSETS_GX_LEFT_HALF  = (-0.10, 0.05)   # (mi=0, mi=3)
OFFSETS_GX_RIGHT_HALF = ( 0.00, 0.35)   # (mi=4, mi=7)
DEFAULT_OFFSET_GY = 0.10


def compute_gx_offset(gx):
    """Calcule l'offset en gx a appliquer pour une coordonnee gx donnee.

    Interpolation lineaire par demi-macro-bloc :
      - Demi gauche (gx=6..45)  : lineaire entre OFFSETS_GX_LEFT_HALF
      - Demi droite (gx=48..87) : lineaire entre OFFSETS_GX_RIGHT_HALF
      - Entre les deux (V1)     : valeur a la frontiere
    """
    # Dans le macro-bloc, les micros sont a mx = 6, 16, 26, 36 (gauche),
    # puis V1 a gx=46..47, puis 48, 58, 68, 78 (droite).
    # Les bits sont a mx+1..mx+8 donc gx va de 7 a 45 (gauche) et 49 a 86 (droite).
    # Le plafond est a gx=mx..mx+8.

    # gx moyen de la demi gauche : 6..45, centre ~ 25.5, mx=6 -> gx 6, mx=36 -> gx 44
    # gx moyen de la demi droite : 48..87, centre ~ 67.5

    if gx < 46:
        # Demi gauche : interpolation entre (mx=6, offset=LEFT[0]) et (mx=36, offset=LEFT[1])
        t = (gx - 6) / (36 - 6)
        t = max(0, min(1, t))
        return OFFSETS_GX_LEFT_HALF[0] + t * (OFFSETS_GX_LEFT_HALF[1] - OFFSETS_GX_LEFT_HALF[0])
    else:
        # Demi droite : interpolation entre (mx=48, offset=RIGHT[0]) et (mx=78, offset=RIGHT[1])
        t = (gx - 48) / (78 - 48)
        t = max(0, min(1, t))
        return OFFSETS_GX_RIGHT_HALF[0] + t * (OFFSETS_GX_RIGHT_HALF[1] - OFFSETS_GX_RIGHT_HALF[0])


def grid_to_image(gx, gy, HG, HD, BG, BD,
                   offset_gx=None, offset_gy=DEFAULT_OFFSET_GY):
    """Convertit une coordonnee grille (gx, gy) en coordonnee image (px, py).

    Les 4 croix HG, HD, BG, BD sont supposees etre aux positions grille :
      HG = (gx=V2_GAUCHE_X, gy=CROIX_HAUTE_Y) = (2, -2)
      HD = (gx=V2_DROITE_X, gy=CROIX_HAUTE_Y) = (90, -2)
      BG = (gx=V2_GAUCHE_X, gy=CROIX_BASSE_Y) = (2, 80)
      BD = (gx=V2_DROITE_X, gy=CROIX_BASSE_Y) = (90, 80)

    offset_gx : si None, utilise compute_gx_offset(gx) qui donne un offset
                variable selon la position (plus precis). Sinon applique
                l'offset fourni.
    offset_gy : offset constant en gy (defaut DEFAULT_OFFSET_GY).

    Retourne (px, py). Fonctionne aussi avec des tableaux numpy.
    """
    gx_arr = np.asarray(gx, dtype=np.float64)
    gy_arr = np.asarray(gy, dtype=np.float64)

    # Appliquer l'offset gx : soit celui fourni, soit calcule par element
    if offset_gx is None:
        # Vectoriser compute_gx_offset
        if gx_arr.ndim == 0:
            gx_adjusted = gx_arr + compute_gx_offset(float(gx_arr))
        else:
            gx_flat = gx_arr.ravel()
            offsets = np.array([compute_gx_offset(g) for g in gx_flat])
            gx_adjusted = (gx_flat + offsets).reshape(gx_arr.shape)
    else:
        gx_adjusted = gx_arr + offset_gx

    u = (gx_adjusted - V2_GAUCHE_X) / (V2_DROITE_X - V2_GAUCHE_X)
    v = (gy_arr + offset_gy - CROIX_HAUTE_Y) / (CROIX_BASSE_Y - CROIX_HAUTE_Y)

    # Interpolation bilineaire
    w_HG = (1 - u) * (1 - v)
    w_HD = u * (1 - v)
    w_BG = (1 - u) * v
    w_BD = u * v

    py = w_HG * HG[0] + w_HD * HD[0] + w_BG * BG[0] + w_BD * BD[0]
    px = w_HG * HG[1] + w_HD * HD[1] + w_BG * BG[1] + w_BD * BD[1]

    return px, py


# ============================================================================
# Echantillonnage d'un pixel de grille par fenetre gaussienne
# ============================================================================

def sample_grid_points_gaussian(gray, gx_arr, gy_arr, HG, HD, BG, BD,
                                  sigma=None, scale=None):
    """Echantillonne les niveaux de gris aux positions grille (gx, gy)
    fournies par INTERPOLATION BILINEAIRE sur 4 pixels (plus precis qu'une
    gaussienne pour les bits bien alignes).

    Le nom garde 'gaussian' pour compatibilite, mais l'implementation
    utilise maintenant l'interpolation bilineaire classique, qui evite
    le biais d'integration par les pixels des bits voisins.

    gx_arr, gy_arr : tableaux numpy (meme shape) de coord grille
    HG..BD         : 4 coins du macro-bloc
    scale          : echelle px/pt (optionnel, pour compatibilite)
    sigma          : ignore (pour compatibilite)

    Retourne un tableau 'darkness' dans [0, 1] (meme shape que gx_arr).
    """
    h, w = gray.shape

    # Convertir toutes les positions grille en positions image
    px_arr, py_arr = grid_to_image(gx_arr, gy_arr, HG, HD, BG, BD)

    # Interpolation bilineaire
    px_flat = px_arr.ravel()
    py_flat = py_arr.ravel()

    # Cliper aux bornes de l'image
    px_clipped = np.clip(px_flat, 0, w - 1.0001)
    py_clipped = np.clip(py_flat, 0, h - 1.0001)

    ix = np.floor(px_clipped).astype(np.int32)
    iy = np.floor(py_clipped).astype(np.int32)
    fx = px_clipped - ix
    fy = py_clipped - iy

    # Interpolation bilineaire : 4 pixels voisins ponderes
    v00 = gray[iy, ix].astype(np.float64)
    v01 = gray[iy, ix + 1].astype(np.float64)
    v10 = gray[iy + 1, ix].astype(np.float64)
    v11 = gray[iy + 1, ix + 1].astype(np.float64)

    values = (v00 * (1 - fx) * (1 - fy) +
              v01 * fx * (1 - fy) +
              v10 * (1 - fx) * fy +
              v11 * fx * fy)

    # Darkness = 1 - valeur/255
    darkness = 1.0 - values / 255.0
    return darkness.reshape(gx_arr.shape)


# ============================================================================
# Decision noir/blanc par micro-bloc (avec seuil local adaptatif)
# ============================================================================

def decide_bits_microblock(darkness_bits, darkness_plafond, darkness_colN):
    """Decide noir (1) / blanc (0) pour 64 bits d'un micro-bloc en utilisant
    les reperes locaux (plafond + colonne N) comme calibration.

    darkness_bits   : array (DATA_ROWS, DATA_BITS) = (8, 8) des darkness des bits
    darkness_plafond: array (9,) des darkness des 9 points du plafond
                      (gx=0..8, gy=0)  -- tous noirs theoriquement
    darkness_colN   : array (8,) des darkness des 8 points de la colonne N
                      (gx=0, gy=1..8)  -- tous noirs theoriquement

    Strategie :
    1. Estimer le noir local (noir_ref) par la mediane des pixels plafond+N,
       qui sont THEORIQUEMENT tous noirs. On utilise la mediane pour etre
       robuste aux pixels mal echantillonnes.
    2. Pour le blanc, on ne peut pas utiliser un repere "theoriquement blanc"
       (le plafond n'a pas de pixel blanc garanti). Donc on utilise les bits
       eux-memes : ceux dont darkness < 0.4*noir_ref sont clairement blancs,
       leur mediane nous donne blanc_ref_local.
    3. Le seuil est a 50% entre blanc_ref et noir_ref, mais avec un plancher :
       si blanc_ref est tres faible (bits quasi-blancs), on privilegie quand
       meme un seuil proche de noir_ref * 0.6, pour ne pas classer des pixels
       gris moyens (darkness ~ 0.5) comme noirs a tort.

    Retourne (bits, seuil, noir_ref, blanc_ref).
    """
    # 1. noir_ref = mediane des darkness des reperes noirs
    all_black_refs = np.concatenate([darkness_plafond, darkness_colN])
    noir_ref = float(np.median(all_black_refs))

    # 2. blanc_ref : mediane des bits clairement blancs (darkness < noir_ref/2)
    bits_flat = darkness_bits.ravel()
    candidate_whites = bits_flat[bits_flat < noir_ref * 0.5]
    if len(candidate_whites) >= 4:
        blanc_ref = float(np.median(candidate_whites))
    else:
        # Micro-bloc presque tout noir : fallback
        blanc_ref = float(np.min(bits_flat))

    # 3. Seuil : combinaison du milieu (blanc, noir) et d'une fraction de noir
    # Le milieu classique
    seuil_milieu = (blanc_ref + noir_ref) / 2.0
    # Fraction basse du noir (pour forcer une decision stricte : un pixel a
    # 60% de la darkness du noir de reference est deja "plutot noir")
    seuil_fraction = noir_ref * 0.6
    # On prend le MAX des deux pour etre conservateur sur les faux noirs
    seuil = max(seuil_milieu, seuil_fraction)

    # Garde-fou : si le contraste est faible, seuil au milieu
    if noir_ref - blanc_ref < 0.2:
        seuil = 0.5

    bits = (darkness_bits > seuil).astype(np.uint8)
    return bits, seuil, noir_ref, blanc_ref


# ============================================================================
# Fonction principale : decode un macro-bloc complet
# ============================================================================

def decode_macro_block(gray, four_crosses=None, debug_dir=None, verbose=False):
    """Decode un macro-bloc (8x8 micro-blocs = 512 octets).

    gray         : image en niveaux de gris (array 2D uint8), contenant le
                   macro-bloc. L'image a ete croppee autour des 4 croix de
                   centrage, qui se trouvent donc AUX 4 COINS de l'image.
    four_crosses : (HG, HD, BG, BD) optionnel. Si None, utilise les 4 coins
                   de l'image comme les 4 centres de croix (convention par
                   defaut, correspondant a une crop exacte autour des croix).
                   Sinon, les coordonnees sub-pixel fournies sont utilisees.
    debug_dir    : dossier pour sauvegarder les images de debug
    verbose      : afficher des informations de progression

    Retourne : bytes de longueur 512 (= 8 micros x 8 lignes x 8 octets)
    """
    h, w = gray.shape

    if four_crosses is None:
        # Les 4 coins de l'image = les 4 centres de croix (convention par
        # defaut apres crop autour des croix)
        HG = (0.0, 0.0)
        HD = (0.0, float(w - 1))
        BG = (float(h - 1), 0.0)
        BD = (float(h - 1), float(w - 1))
    else:
        HG, HD, BG, BD = four_crosses
        for name, c in zip(['HG', 'HD', 'BG', 'BD'], [HG, HD, BG, BD]):
            if c is None:
                raise ValueError(f"Croix {name} non detectee")

    # Calculer l'echelle
    d_h = ((HD[1] - HG[1]) + (BD[1] - BG[1])) / 2
    d_v = ((BG[0] - HG[0]) + (BD[0] - HD[0])) / 2
    scale_h = d_h / 88
    scale_v = d_v / 82
    scale = (scale_h + scale_v) / 2

    if verbose:
        print(f"Croix HG : ({HG[0]:.2f}, {HG[1]:.2f})")
        print(f"Croix HD : ({HD[0]:.2f}, {HD[1]:.2f})")
        print(f"Croix BG : ({BG[0]:.2f}, {BG[1]:.2f})")
        print(f"Croix BD : ({BD[0]:.2f}, {BD[1]:.2f})")
        print(f"Echelle  : {scale_h:.3f} (horiz) / {scale_v:.3f} (vert) = {scale:.3f} px/pt")

    # --- Preparer toutes les positions grille a echantillonner ---
    # Pour les 64 micro-blocs, on a besoin de :
    #   - 9 points de plafond (gx = mx..mx+8, gy = my)
    #   - 8 points de colonne N (gx = mx, gy = my+1..my+8)
    #   - 64 points de bits (gx = mx+1..mx+8, gy = my+1..my+8)

    # On prepare tout dans un seul grand tableau pour une seule passe
    # d'echantillonnage vectorisee.

    all_bytes = bytearray(512)  # 64 micros x 8 octets

    debug_info = []

    for mj in range(MICROS_V):      # ligne de micros (my)
        my = MICROS_MY[mj]
        for mi in range(MICROS_H):  # colonne de micros (mx)
            mx = MICROS_MX[mi]

            # Indices des points de grille a echantillonner pour ce micro-bloc
            # Plafond : 9 pts (gx = mx..mx+8, gy = my)
            gx_plafond = np.arange(9) + mx
            gy_plafond = np.full(9, my)

            # Colonne N : 8 pts (gx = mx, gy = my+1..my+8)
            gx_colN = np.full(8, mx)
            gy_colN = np.arange(1, 9) + my

            # Bits : 64 pts (gx = mx+1..mx+8, gy = my+1..my+8)
            bit_cols = np.arange(1, 9)
            bit_rows = np.arange(1, 9)
            gx_bits = (mx + bit_cols)[None, :].repeat(8, axis=0)  # (8, 8)
            gy_bits = (my + bit_rows)[:, None].repeat(8, axis=1)  # (8, 8)

            # Echantillonner
            d_plafond = sample_grid_points_gaussian(
                gray, gx_plafond, gy_plafond, HG, HD, BG, BD, scale=scale)
            d_colN = sample_grid_points_gaussian(
                gray, gx_colN, gy_colN, HG, HD, BG, BD, scale=scale)
            d_bits = sample_grid_points_gaussian(
                gray, gx_bits, gy_bits, HG, HD, BG, BD, scale=scale)

            # Decider les bits
            bits, seuil, noir_ref, blanc_ref = decide_bits_microblock(
                d_bits, d_plafond, d_colN)

            # Composer les 8 octets (1 par ligne, MSB first)
            micro_idx = mj * MICROS_H + mi
            for row in range(DATA_ROWS):
                byte_val = 0
                for col in range(DATA_BITS):
                    byte_val = (byte_val << 1) | int(bits[row, col])
                all_bytes[micro_idx * 8 + row] = byte_val

            if debug_dir or verbose:
                debug_info.append({
                    'mi': mi, 'mj': mj, 'mx': mx, 'my': my,
                    'd_plafond': d_plafond, 'd_colN': d_colN,
                    'd_bits': d_bits, 'bits': bits,
                    'seuil': seuil, 'noir_ref': noir_ref, 'blanc_ref': blanc_ref,
                })

    if verbose:
        # Afficher un resume des seuils par micro-bloc
        print()
        print("Seuils par micro-bloc (noir_ref / blanc_ref / seuil):")
        for info in debug_info[:8]:  # juste la 1re ligne
            print(f"  micro ({info['mi']},{info['mj']}) mx={info['mx']} my={info['my']}: "
                  f"noir={info['noir_ref']:.3f}, blanc={info['blanc_ref']:.3f}, "
                  f"seuil={info['seuil']:.3f}")

    if debug_dir:
        _save_macro_debug(gray, bytes(all_bytes), HG, HD, BG, BD, debug_info, debug_dir)

    return bytes(all_bytes)


def _save_macro_debug(gray, decoded_bytes, HG, HD, BG, BD, debug_info, debug_dir):
    """Sauvegarde d'images de debug pour diagnostiquer le decodage."""
    from PIL import Image, ImageDraw
    import os

    os.makedirs(debug_dir, exist_ok=True)

    # 1) Image entiere du macro-bloc avec tous les points d'echantillonnage
    img = Image.fromarray(gray).convert('RGB')
    draw = ImageDraw.Draw(img)

    # Marquer les 4 croix
    for name, c, color in [('HG', HG, 'red'), ('HD', HD, 'red'),
                             ('BG', BG, 'red'), ('BD', BD, 'red')]:
        cy, cx = c
        cy_i, cx_i = int(round(cy)), int(round(cx))
        draw.ellipse([cx_i-5, cy_i-5, cx_i+5, cy_i+5], outline=color, width=2)

    # Marquer les points d'echantillonnage : plafond=bleu, N=vert, bits=selon valeur
    for info in debug_info:
        mx, my = info['mx'], info['my']
        # Plafond : 9 pts
        for bit_idx in range(9):
            gx = mx + bit_idx
            gy = my
            px, py = grid_to_image(gx, gy, HG, HD, BG, BD)
            sx, sy = int(round(px)), int(round(py))
            if 0 <= sx < gray.shape[1] and 0 <= sy < gray.shape[0]:
                draw.ellipse([sx-1, sy-1, sx+1, sy+1], fill='blue')
        # Colonne N : 8 pts
        for row in range(8):
            gx = mx
            gy = my + 1 + row
            px, py = grid_to_image(gx, gy, HG, HD, BG, BD)
            sx, sy = int(round(px)), int(round(py))
            if 0 <= sx < gray.shape[1] and 0 <= sy < gray.shape[0]:
                draw.ellipse([sx-1, sy-1, sx+1, sy+1], fill='lime')
        # Bits : 64 pts, couleur selon decision (noir=rouge, blanc=magenta)
        for row in range(8):
            for col in range(8):
                gx = mx + 1 + col
                gy = my + 1 + row
                px, py = grid_to_image(gx, gy, HG, HD, BG, BD)
                sx, sy = int(round(px)), int(round(py))
                if 0 <= sx < gray.shape[1] and 0 <= sy < gray.shape[0]:
                    color = 'red' if info['bits'][row, col] else 'magenta'
                    draw.ellipse([sx-1, sy-1, sx+1, sy+1], fill=color)

    img.save(os.path.join(debug_dir, 'macro_bloc_sampling.png'))
    print(f"    {debug_dir}/macro_bloc_sampling.png")

    # 2) Ecrire un rapport texte
    with open(os.path.join(debug_dir, 'macro_bloc_report.txt'), 'w') as f:
        f.write("=== Decodage macro-bloc ===\n")
        f.write(f"Croix HG: {HG}\n")
        f.write(f"Croix HD: {HD}\n")
        f.write(f"Croix BG: {BG}\n")
        f.write(f"Croix BD: {BD}\n\n")
        f.write(f"512 octets decodes:\n")
        # Afficher les octets par lignes de 16
        for i in range(0, 512, 16):
            chunk = decoded_bytes[i:i+16]
            hex_str = ' '.join(f'{b:02X}' for b in chunk)
            ascii_str = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
            f.write(f'{i:04X}: {hex_str}  |{ascii_str}|\n')
    print(f"    {debug_dir}/macro_bloc_report.txt")


# ============================================================================
# Main / test
# ============================================================================

def main():
    import sys
    from PIL import Image
    import os

    if len(sys.argv) < 2:
        print("Usage: python3 macro_bloc_decode.py <macro_bloc.png> [expected.bin]")
        sys.exit(1)

    img_path = sys.argv[1]
    expected_path = sys.argv[2] if len(sys.argv) > 2 else None

    print(f"Decodage de {img_path}...")
    img = Image.open(img_path)
    if img.mode != 'L':
        img = img.convert('L')
    gray = np.array(img)
    print(f"Image : {gray.shape[1]} x {gray.shape[0]} px")

    debug_dir = '/tmp/macro_bloc_dbg'
    decoded = decode_macro_block(gray, debug_dir=debug_dir, verbose=True)
    print(f"\n{len(decoded)} octets decodes")
    print(f"Premiers 64 octets decodes:")
    for i in range(0, 64, 16):
        chunk = decoded[i:i+16]
        hex_str = ' '.join(f'{b:02X}' for b in chunk)
        ascii_str = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
        print(f'  {i:04X}: {hex_str}  |{ascii_str}|')

    if expected_path:
        with open(expected_path, 'rb') as f:
            expected = f.read()

        # Comprendre l'ordre reel d'encodage :
        # L'encodeur parcourt la PAGE ENTIERE en ordre "ligne par ligne"
        # (tous les micros de mj=0 de TOUS les macro-blocs avant de passer
        # aux micros de mj=1). Donc :
        #   - Octets 0..63 du fichier source -> macro-bloc A01, mj=0 (mi=0..7)
        #   - Octets 64..127 -> macro-bloc A02, mj=0 (mi=0..7)
        #   - Octets 1408..1471 -> macro-bloc A01, mj=1 (mi=0..7)
        #     (1408 = 176 micros * 8 octets)
        #   - etc.
        # Pour le macro-bloc A01 (1er en haut a gauche), les octets attendus
        # sont :
        #   mj=0 : octets 0..63 du fichier
        #   mj=1 : octets 1408..1471
        #   ...
        # Si le fichier fait moins de 1408 octets, on n'a que mj=0 a comparer.

        # 22 macro-blocs horizontaux, 8 micros par macro-bloc = 176 micros
        # par ligne de macro-blocs. 8 octets par micro = 1408 octets par
        # rang mj.
        BYTES_PER_MJ_ROW = 22 * 8 * 8  # 1408

        print(f"\nTaille du fichier attendu : {len(expected)} octets")

        # Construire les octets du macro-bloc A01 depuis le fichier source
        a01_expected = bytearray(512)
        for mj in range(MICROS_V):
            for mi in range(MICROS_H):
                micro_idx_page = mj * 176 + mi  # position dans la page
                for row in range(DATA_ROWS):
                    byte_idx_source = micro_idx_page * DATA_ROWS + row
                    if byte_idx_source < len(expected):
                        micro_idx_in_macro = mj * MICROS_H + mi
                        a01_expected[micro_idx_in_macro * 8 + row] = \
                            expected[byte_idx_source]
                    # Sinon reste a 0 (valeur par defaut)

        # Determiner jusqu'ou on peut comparer
        # On ne peut valider que les bytes pour lesquels on a des donnees
        # dans le fichier source (< len(expected)).
        verifiables_idx = []
        for mj in range(MICROS_V):
            for mi in range(MICROS_H):
                micro_idx_page = mj * 176 + mi
                for row in range(DATA_ROWS):
                    byte_idx_source = micro_idx_page * DATA_ROWS + row
                    if byte_idx_source < len(expected):
                        micro_idx_in_macro = mj * MICROS_H + mi
                        verifiables_idx.append(micro_idx_in_macro * 8 + row)

        n_verif = len(verifiables_idx)
        n_match = sum(1 for i in verifiables_idx if decoded[i] == a01_expected[i])
        n_bits_correct = 0
        for i in verifiables_idx:
            xor = decoded[i] ^ a01_expected[i]
            n_bits_correct += 8 - bin(xor).count('1')

        print(f"\nComparaison sur les {n_verif} octets verifiables :")
        print(f"  {n_match}/{n_verif} ({100*n_match/n_verif:.1f}%) octets corrects")
        print(f"  {n_bits_correct}/{8*n_verif} ({100*n_bits_correct/(8*n_verif):.1f}%) bits corrects")

        # Detail des octets verifiables
        print(f"\nDetail des octets verifiables :")
        print(f"  pos  decode(hex) attendu(hex)  decode(ASCII) attendu(ASCII)  match?")
        for i in verifiables_idx[:72]:
            d = decoded[i]
            e = a01_expected[i]
            ok = '✓' if d == e else '✗'
            dc = chr(d) if 32 <= d < 127 else '.'
            ec = chr(e) if 32 <= e < 127 else '.'
            mj_idx = (i // 8) // MICROS_H
            mi_idx = (i // 8) % MICROS_H
            row_idx = i % 8
            print(f"  {i:3d}  {d:02X}          {e:02X}           "
                  f"{dc}             {ec}              {ok}  "
                  f"(micro mi={mi_idx}, mj={mj_idx}, row={row_idx})")


if __name__ == '__main__':
    main()
