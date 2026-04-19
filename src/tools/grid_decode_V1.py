"""
grid_decode.py - Decodeur de grille binaire a partir d'un scan.

Prend une image scannee (PNG, TIFF, PGM ou autre) d'une page de grille
produite par grid_encode.py, et reconstitue le fichier binaire original.

Strategie :
  1. Charger l'image et convertir en niveaux de gris
  2. Binariser avec seuil adaptatif local (Sauvola)
  3. Detecter les croix blanches de centrage aux croisements V2/H2
  4. Calculer la transformation affine (translation + rotation + echelle)
  5. Echantillonner les bits de donnees aux positions calculees
  6. Reconstituer les octets et ecrire le fichier de sortie

Usage :
    python3 grid_decode.py SCAN_IMAGE OUTPUT_FILE [--debug DEBUG_DIR]
"""
import sys
import os
import math
import numpy as np
from PIL import Image

# Desactiver la limite de taille d'image de Pillow
# (un scan A4 a 1200 dpi depasse la limite par defaut de 89 megapixels)
Image.MAX_IMAGE_PIXELS = None

# =============================================================================
# PARAMETRES DE LA GRILLE (identiques a grid_encode.py)
# =============================================================================

MICRO_W = 10
MICRO_H = 10
DATA_BITS = 8
DATA_ROWS = 8

MICROS_PER_HALF = 4
HALVES_PER_GROUP = 2

SEP_V1_W = 2
SEP_V2_W = 6

MICRO_ROWS_PER_SECTION = 8
SEP_H2_H = 2

GROUPS_H = 22
SECTIONS_V = 34

MICROS_PER_GROUP = MICROS_PER_HALF * HALVES_PER_GROUP
BYTES_PER_PAGE = GROUPS_H * SECTIONS_V * MICROS_PER_GROUP * MICRO_ROWS_PER_SECTION * DATA_ROWS

INDEX_MARGIN_LEFT = 25
INDEX_MARGIN_TOP = 25


# =============================================================================
# CALCUL DES POSITIONS THEORIQUES DANS LA GRILLE
# (coordonnees en points de 100um, origine = coin haut-gauche de la grille)
# =============================================================================

def compute_v2_centers_x():
    """Positions X des centres de croix (col 2 de chaque V2) dans la grille."""
    centers = []
    x = 0
    # V2 bordure gauche : cols 0-5, centre = col 2
    centers.append(x + 2)
    x += SEP_V2_W

    gw = MICROS_PER_HALF * MICRO_W + SEP_V1_W + MICROS_PER_HALF * MICRO_W
    for g in range(GROUPS_H):
        if g > 0:
            centers.append(x + 2)
            x += SEP_V2_W
        # Groupe
        x += gw

    # V2 bordure droite
    centers.append(x + 2)
    return centers


def compute_h2_centers_y():
    """Positions Y des lignes H2 (= ligne 0 de chaque sep H2) dans la grille."""
    centers = []
    y = 0
    for s in range(SECTIONS_V):
        if s > 0:
            centers.append(y)
            y += SEP_H2_H
        y += MICRO_ROWS_PER_SECTION * MICRO_H
    return centers


def compute_cross_positions():
    """Positions (x, y) de toutes les croix blanches dans la grille
    (en coordonnees de points, origine = coin haut-gauche de la grille)."""
    v2x = compute_v2_centers_x()
    h2y = compute_h2_centers_y()
    crosses = []
    for cy in h2y:
        for cx in v2x:
            crosses.append((cx, cy))
    return crosses, v2x, h2y


def compute_micro_positions():
    """Positions (x, y) du coin haut-gauche (le N de synchro) de chaque
    micro-bloc, dans l'ordre de lecture (gauche-droite, haut-bas)."""
    positions = []
    x_positions = []

    x = SEP_V2_W  # apres V2 bordure gauche
    gw = MICROS_PER_HALF * MICRO_W + SEP_V1_W + MICROS_PER_HALF * MICRO_W
    for g in range(GROUPS_H):
        if g > 0:
            x += SEP_V2_W
        for h in range(HALVES_PER_GROUP):
            if h > 0:
                x += SEP_V1_W
            for m in range(MICROS_PER_HALF):
                x_positions.append(x)
                x += MICRO_W

    y = 0
    for s in range(SECTIONS_V):
        if s > 0:
            y += SEP_H2_H
        for mr in range(MICRO_ROWS_PER_SECTION):
            my = y + mr * MICRO_H
            for mx in x_positions:
                positions.append((mx, my))
        # Avancer y apres chaque section (8 lignes de micro-blocs)
        y += MICRO_ROWS_PER_SECTION * MICRO_H

    return positions


# =============================================================================
# CHARGEMENT ET PRETRAITEMENT DE L'IMAGE
# =============================================================================

def load_and_preprocess(image_path):
    """Charge l'image, convertit en gris, renvoie un tableau numpy uint8."""
    img = Image.open(image_path)
    if img.mode != 'L':
        img = img.convert('L')
    return np.array(img, dtype=np.uint8)


def _box_mean(img, r):
    """Moyenne locale par somme cumulee (numpy pur, pas de scipy).
    img : tableau 2D float64. r : demi-largeur de la fenetre.
    Renvoie un tableau de meme taille avec la moyenne locale."""
    h, w = img.shape
    # Somme cumulee avec padding
    padded = np.zeros((h + 2*r + 1, w + 2*r + 1), dtype=np.float64)
    padded[r+1:r+1+h, r+1:r+1+w] = img
    # Somme cumulee 2D
    cs = np.cumsum(np.cumsum(padded, axis=0), axis=1)
    # Nombre de pixels dans chaque fenetre (gere les bords)
    count = np.zeros_like(img, dtype=np.float64)
    total = cs[2*r+1:, 2*r+1:] - cs[:h, 2*r+1:] - cs[2*r+1:, :w] + cs[:h, :w]
    # Compter le nombre de pixels valides par fenetre
    ones = np.zeros_like(padded)
    ones[r+1:r+1+h, r+1:r+1+w] = 1.0
    cs_ones = np.cumsum(np.cumsum(ones, axis=0), axis=1)
    count = cs_ones[2*r+1:, 2*r+1:] - cs_ones[:h, 2*r+1:] - cs_ones[2*r+1:, :w] + cs_ones[:h, :w]
    count[count == 0] = 1
    return total / count


def binarize_sauvola(gray, window_size=31, k=0.15):
    """Binarisation par seuil adaptatif de Sauvola.
    Implementation en numpy pur (pas de dependance scipy).
    Renvoie un tableau bool (True = blanc, False = noir)."""
    r = window_size // 2
    img_f = gray.astype(np.float64)

    # Moyenne et ecart-type locaux via sommes cumulees
    mean = _box_mean(img_f, r)
    sq_mean = _box_mean(img_f * img_f, r)
    std = np.sqrt(np.maximum(sq_mean - mean * mean, 0))

    # Seuil de Sauvola
    threshold = mean * (1.0 + k * (std / 128.0 - 1.0))
    return gray > threshold


def _gaussian_blur_1d(data, sigma):
    """Flou gaussien 1D par convolution (numpy pur).
    data : tableau 1D float64. sigma : ecart-type en pixels."""
    if sigma < 0.5:
        return data.copy()
    radius = int(3 * sigma + 0.5)
    x = np.arange(-radius, radius + 1, dtype=np.float64)
    kernel = np.exp(-x**2 / (2 * sigma**2))
    kernel /= np.sum(kernel)
    # Convolution avec padding par reflexion
    padded = np.pad(data, radius, mode='reflect')
    return np.convolve(padded, kernel, mode='valid')


def _gaussian_blur_2d(img, sigma):
    """Flou gaussien 2D separable (numpy pur).
    img : tableau 2D float64. sigma : ecart-type en pixels."""
    if sigma < 0.5:
        return img.copy()
    # Passe horizontale
    result = np.zeros_like(img)
    for y in range(img.shape[0]):
        result[y, :] = _gaussian_blur_1d(img[y, :], sigma)
    # Passe verticale
    for x in range(result.shape[1]):
        result[:, x] = _gaussian_blur_1d(result[:, x], sigma)
    return result


def dog_filter(gray, sigma1, sigma2):
    """Filtre difference de gaussiennes (DoG).
    Renvoie gray floute a sigma2 - gray floute a sigma1.
    Les croix blanches (structures petites dans du noir) deviennent
    des taches sombres bien contrastees."""
    img_f = gray.astype(np.float64)
    blur1 = _gaussian_blur_2d(img_f, sigma1)
    blur2 = _gaussian_blur_2d(img_f, sigma2)
    return blur1 - blur2


# =============================================================================
# DETECTION DES CROIX DE CENTRAGE
# =============================================================================

def make_cross_template(radius=8):
    """Cree un template de croix blanche sur fond noir pour la correlation.
    Le template fait (2*radius+1) x (2*radius+1) pixels.
    La croix occupe 3 pixels de large et de haut au centre."""
    size = 2 * radius + 1
    template = np.zeros((size, size), dtype=np.float64)
    # Fond : noir = 0 (les murs et lignes "2")
    # Croix : blanc = 1
    c = radius
    # Branche horizontale : 3 pixels de large, 1 pixel de haut
    template[c, c-1:c+2] = 1
    # Branche verticale : 1 pixel de large, 3 pixels de haut
    template[c-1:c+2, c] = 1
    return template


def find_v2_lines(gray):
    """Trouve les 23 lignes verticales V2 par projection verticale sur
    l'image en niveaux de gris, puis affine le centrage en utilisant
    les croix blanches presentes sur chaque V2.
    
    Methode :
    1. Projeter les moyennes de gris par colonne
    2. Detecter les groupes de colonnes sombres
    3. Les 23 plus larges sont les V2
    4. Premier centrage par barycentre de la noirceur
    5. Affinement : le long de chaque V2, trouver les trous blancs (croix)
       et utiliser leur centre X pour corriger le centrage
    """
    h, w = gray.shape

    # Projection verticale : moyenne des niveaux de gris par colonne
    col_mean = np.mean(gray, axis=0)

    # Seuil adaptatif pour detecter les colonnes "noires"
    global_mean = np.mean(col_mean)
    threshold = global_mean * 0.7
    dark_cols = np.where(col_mean < threshold)[0]

    if len(dark_cols) < 20:
        print(f"  ATTENTION : seulement {len(dark_cols)} colonnes sombres")
        return []

    # Regrouper les colonnes sombres consecutives (tolerance de 2 pixels)
    groups = []
    group_start = dark_cols[0]
    for i in range(1, len(dark_cols)):
        if dark_cols[i] - dark_cols[i-1] > 3:
            groups.append((group_start, dark_cols[i-1]))
            group_start = dark_cols[i]
    groups.append((group_start, dark_cols[-1]))

    widths = [e - s + 1 for s, e in groups]

    if len(groups) < 23:
        print(f"  ATTENTION : seulement {len(groups)} groupes detectes")
        return []

    # Trier les groupes par largeur decroissante et garder les 23 plus larges
    groups_sorted = sorted(zip(widths, groups), key=lambda x: -x[0])
    v2_candidates = groups_sorted[:23]
    v2_groups = [g for w, g in v2_candidates]
    v2_groups.sort(key=lambda g: g[0])  # retrier gauche a droite
    v2_widths_sorted = [e - s + 1 for s, e in v2_groups]

    # --- Premier centrage grossier par barycentre de la noirceur ---
    v2_centers_rough = []
    for s, e in v2_groups:
        cols = np.arange(s, e + 1, dtype=np.float64)
        darkness = global_mean - col_mean[s:e+1]
        darkness = np.maximum(darkness, 0)
        total = np.sum(darkness)
        if total > 0:
            center = np.sum(cols * darkness) / total
        else:
            center = (s + e) / 2.0
        v2_centers_rough.append(center)

    # --- Affinement par detection des croix blanches via DoG ---
    # On applique un filtre difference de gaussiennes sur chaque bande V2.
    # Les croix blanches (structures ~5 pixels dans du noir) deviennent
    # des taches sombres (valeurs negatives) bien contrastees dans le DoG.
    # sigma1 adapte a l'echelle (~14 px pour 1200 dpi), sigma2 petit (~0.5)

    # Estimer l'echelle a partir de l'espacement grossier des V2
    rough_spacings = [v2_centers_rough[i+1] - v2_centers_rough[i] 
                      for i in range(len(v2_centers_rough)-1)]
    if rough_spacings:
        med_rough_spacing = sorted(rough_spacings)[len(rough_spacings)//2]
        scale_rough = med_rough_spacing / 88.0  # 88 points entre deux V2
    else:
        scale_rough = 5.0

    # Parametres du DoG adaptes a l'echelle
    sigma1 = scale_rough * 2.8   # ~13.5 pour 1200 dpi (echelle ~4.7)
    sigma2 = 0.5

    v2_centers = []
    for idx, (s, e) in enumerate(v2_groups):
        cx_rough = int(round(v2_centers_rough[idx]))
        band_half = max(5, (e - s + 1) // 2 + 4)

        # Extraire une bande verticale autour du centre grossier
        x_lo = max(0, cx_rough - band_half)
        x_hi = min(w, cx_rough + band_half + 1)
        band = gray[:, x_lo:x_hi]
        band_w = band.shape[1]

        # Appliquer le DoG sur la bande
        dog_band = dog_filter(band, sigma1, sigma2)
        # Dans le DoG, les croix (structures claires dans du sombre)
        # deviennent des zones a valeur POSITIVE (car le flou lisse le
        # signal et la difference highlight les petites structures claires).
        # En fait : DoG = blur_gros - blur_petit.
        # Une croix blanche dans du noir : blur_gros ~ gris moyen, blur_petit ~ blanc
        # Donc DoG = gris - blanc = negatif. Les croix sont NEGATIVES.
        # On cherche les minima (valeurs les plus negatives).

        # Profil vertical : valeur minimale du DoG dans chaque ligne
        # (la croix a la valeur la plus negative)
        min_profile = np.min(dog_band, axis=1)

        # Detecter les creux (valeurs tres negatives) dans le profil
        dog_threshold = np.mean(min_profile) - 1.5 * np.std(min_profile)

        cross_y_positions = []
        in_cross = False
        cross_start = 0
        for y in range(h):
            if min_profile[y] < dog_threshold:
                if not in_cross:
                    cross_start = y
                    in_cross = True
            else:
                if in_cross:
                    # Centre Y du creux
                    segment = min_profile[cross_start:y]
                    best_y = cross_start + np.argmin(segment)
                    cross_y_positions.append(best_y)
                    in_cross = False

        if len(cross_y_positions) < 3:
            v2_centers.append(v2_centers_rough[idx])
            continue

        # Pour chaque croix, mesurer le centre X exact dans le DoG
        cross_x_centers = []
        for cy in cross_y_positions:
            y_lo = max(0, cy - 3)
            y_hi = min(h, cy + 4)
            patch = dog_band[y_lo:y_hi, :]

            # Le centre X est la colonne avec la valeur DoG la plus negative
            mean_per_col = np.mean(patch, axis=0)
            # Barycentre pondere par la negativite (plus c'est negatif = plus de poids)
            col_indices = np.arange(band_w, dtype=np.float64)
            negativity = -mean_per_col  # inverser pour que les creux aient un poids positif
            negativity = np.maximum(negativity - np.percentile(negativity, 30), 0)
            total_w = np.sum(negativity)
            if total_w > 0:
                cx_local = np.sum(col_indices * negativity) / total_w
                cx_global = cx_local + x_lo
                cross_x_centers.append(cx_global)

        if len(cross_x_centers) >= 3:
            # Centre affine = mediane des centres X des croix
            refined_center = sorted(cross_x_centers)[len(cross_x_centers) // 2]
            v2_centers.append(refined_center)
        else:
            v2_centers.append(v2_centers_rough[idx])

    # Espacements entre V2 consecutifs
    spacings = [v2_centers[i+1] - v2_centers[i] for i in range(len(v2_centers)-1)]
    if spacings:
        med_spacing = sorted(spacings)[len(spacings)//2]
        scale_est = med_spacing / (SEP_V2_W + MICROS_PER_HALF * MICRO_W + SEP_V1_W + MICROS_PER_HALF * MICRO_W)
    else:
        scale_est = 0

    print(f"  Groupes verticaux  : {len(groups)} (largeurs {min(widths)}-{max(widths)} px)")
    print(f"  V2 retenues (top 23) : largeurs {min(v2_widths_sorted)}-{max(v2_widths_sorted)} px")
    if spacings:
        print(f"  Espacement median  : {med_spacing:.1f} px (echelle ~ {scale_est:.2f} px/pt)")
    print(f"  Lignes V2 detectees : {len(v2_centers)}")

    return v2_centers


def find_h2_lines(binary):
    """Trouve les lignes horizontales H2 par recherche du plus long segment
    noir continu sur chaque ligne. Les H2 traversent toute la grille en
    continu (sauf les croix blanches), contrairement aux plafonds qui sont
    interrompus tous les 10 pixels."""
    h, w = binary.shape

    # Pour chaque ligne, trouver la longueur du plus long segment noir
    max_run_len = np.zeros(h, dtype=np.int32)
    for y in range(h):
        run = 0
        best = 0
        for x in range(w):
            if not binary[y, x]:  # noir
                run += 1
                if run > best:
                    best = run
            else:
                run = 0
        max_run_len[y] = best

    # Les H2 ont un segment noir continu d'au moins la largeur d'un groupe
    # (~82 points * echelle). Les plafonds ont des segments de max ~9 pixels.
    # On cherche des lignes avec un segment > 50 points * echelle estimee.
    # Estimation grossiere de l'echelle a partir des V2 :
    if len(binary[0]) > 100:
        # Utiliser la projection pour estimer l'echelle
        col_black = np.sum(~binary, axis=0).astype(np.float64)
        mur_cols = np.where(col_black > h * 0.3)[0]
        if len(mur_cols) > 20:
            # Grouper
            grps = []
            gs = mur_cols[0]
            for i in range(1, len(mur_cols)):
                if mur_cols[i] - mur_cols[i-1] > 3:
                    grps.append((gs, mur_cols[i-1]))
                    gs = mur_cols[i]
            grps.append((gs, mur_cols[-1]))
            v2g = [(s,e) for s,e in grps if e-s >= 3]
            if len(v2g) >= 2:
                dist_px = (v2g[1][0]+v2g[1][1])/2 - (v2g[0][0]+v2g[0][1])/2
                est_scale = dist_px / 88.0
                threshold = 50 * est_scale  # segment de 50 points minimum
            else:
                threshold = 100
        else:
            threshold = 100
    else:
        threshold = 100
    h2_rows = np.where(max_run_len > threshold)[0]

    if len(h2_rows) == 0:
        print(f"  ATTENTION : aucune ligne H2 detectee")
        return []

    # Regrouper les lignes consecutives
    groups = []
    group_start = h2_rows[0]
    for i in range(1, len(h2_rows)):
        if h2_rows[i] - h2_rows[i-1] > 5:
            groups.append((group_start, h2_rows[i-1]))
            group_start = h2_rows[i]
    groups.append((group_start, h2_rows[-1]))

    h2_centers = [(s + e) / 2.0 for s, e in groups]

    print(f"  Lignes H2 detectees : {len(h2_centers)}")
    return h2_centers


def _parabolic_subpixel(y_m1, y_0, y_p1):
    """Interpolation parabolique sur 3 points centres sur un extremum.
    Renvoie le deplacement sub-pixel du sommet par rapport au point central.
    Valeur dans [-0.5, +0.5] ; 0 si le denominateur est trop petit."""
    denom = y_m1 - 2.0 * y_0 + y_p1
    if abs(denom) < 1e-9:
        return 0.0
    delta = 0.5 * (y_m1 - y_p1) / denom
    # Borner pour eviter les extrapolations aberrantes
    if delta > 0.5:
        delta = 0.5
    elif delta < -0.5:
        delta = -0.5
    return delta


def _find_h2_black_line_near(binary, v2_x, y_center, scale):
    """Fallback : trouve le centre Y d'une ligne horizontale noire autour
    de y_center, en suivant la colonne v2_x. Utile si le DoG est ambigu.
    Renvoie y sub-pixel ou None."""
    h, w = binary.shape
    search_r = max(6, int(scale * 2.5))
    y_lo = max(0, int(y_center) - search_r)
    y_hi = min(h, int(y_center) + search_r + 1)
    ix = int(round(v2_x))
    if ix < 0 or ix >= w:
        return None

    # Bande horizontale large de ~2*scale autour de la colonne v2_x
    band_half = max(2, int(scale))
    x_lo = max(0, ix - band_half)
    x_hi = min(w, ix + band_half + 1)

    # Proportion de noir par ligne dans cette bande
    # (sur la ligne H2 la croix rend le milieu blanc, mais les bords
    # restent noirs : on garde donc les colonnes non-centrales)
    line_band = binary[y_lo:y_hi, x_lo:x_hi]
    if line_band.size == 0:
        return None
    black_frac = 1.0 - np.mean(line_band, axis=1)
    # Exclure la colonne centrale (blanche au niveau de la croix)
    # deja un peu gere par le moyennage, on cherche le max
    if len(black_frac) < 3:
        return None
    best = int(np.argmax(black_frac))
    if black_frac[best] < 0.3:
        return None  # pas de ligne noire credible
    # Sub-pixel parabolique si possible
    if 0 < best < len(black_frac) - 1:
        delta = _parabolic_subpixel(black_frac[best-1], black_frac[best], black_frac[best+1])
    else:
        delta = 0.0
    return y_lo + best + delta


def find_crosses_on_v2_bands(gray, binary, v2_centers, debug_dir=None):
    """Localise precisement les 33 croix blanches le long de chaque V2.

    Strategie :
      1. Estimer l'echelle (pixels/point) depuis l'espacement des V2
      2. Pour chaque V2, extraire une bande verticale de ~22 px
         (5 points de grille = 5/10 mm = ~22 px a 1200 dpi)
      3. Calculer le DoG de la bande (les croix deviennent des
         creux tres negatifs)
      4. Profil vertical = moyenne du DoG sur la largeur de la bande
      5. Detecter les creux et selectionner 33 croix regulierement
         espacees (pas attendu ~82 points x scale)
      6. Pour chaque croix :
         - Centre Y : interpolation parabolique sur le profil
         - Centre X : barycentre pondere (- DoG) sur une fenetre
           locale, puis raffinement parabolique
      7. Si un creux DoG est trop faible, fallback : chercher la
         ligne H2 noire dans la bande binaire

    Renvoie :
      crosses : array (n_v2, n_h2_expected, 2) en (y, x) sub-pixel
                 avec np.nan pour les croix non trouvees
      scale   : echelle estimee (pixels par point de grille)
    """
    h, w = gray.shape

    # -- Echelle depuis les V2 --
    if len(v2_centers) >= 2:
        v2_dists = [v2_centers[i+1] - v2_centers[i] for i in range(len(v2_centers)-1)]
        median_dist = sorted(v2_dists)[len(v2_dists)//2]
        # Distance entre V2 consecutifs = SEP_V2_W + group_width = 6 + 82 = 88 points
        scale = median_dist / (SEP_V2_W + MICROS_PER_HALF * MICRO_W + SEP_V1_W + MICROS_PER_HALF * MICRO_W)
    else:
        scale = 5.0
    print(f"  Echelle estimee      : {scale:.3f} px/pt (1 mm = {10*scale:.1f} px)")

    # -- Geometrie attendue --
    n_h2_expected = SECTIONS_V - 1  # 33 separateurs entre 34 sections
    step_pt = MICRO_ROWS_PER_SECTION * MICRO_H + SEP_H2_H  # 82 points
    step_px = step_pt * scale
    # Position de la premiere H2 en points de grille (depuis le haut de la grille) :
    # = MICRO_ROWS_PER_SECTION * MICRO_H = 80 points
    h2y_grid_first = MICRO_ROWS_PER_SECTION * MICRO_H  # 80 points
    print(f"  Pas vertical attendu : {step_px:.1f} px entre H2 consecutifs")
    print(f"  Premiere H2 a {h2y_grid_first} pts = {h2y_grid_first*scale:.1f} px "
          f"sous le haut de la grille")

    # -- Parametres DoG --
    # Sur une bande etroite (~22 px de large), on ne peut pas appliquer un flou
    # gaussien 2D avec sigma1 ~13 dans les deux directions : la passe horizontale
    # lisserait tout en une valeur. On fait donc :
    #   - pour le PROFIL VERTICAL : flou 1D en Y uniquement sur la colonne centrale
    #     (ou une moyenne de quelques colonnes centrales) -> DoG 1D
    #   - pour le CENTRAGE X : coupe horizontale fine autour du Y trouve,
    #     DoG 2D avec sigma1 reduit dans la direction X
    sigma1_y = scale * 2.8   # direction principale
    sigma2_y = 0.5
    sigma1_x = min(scale * 1.5, 8.0)  # reduit pour tenir dans une bande de 22 px
    # Demi-largeur de la bande verticale : 5 points = ~22 px a 1200 dpi
    band_half = max(8, int(round(2.5 * scale)))

    # Resultat : tableau (23, 33, 2) avec NaN par defaut
    n_v2 = len(v2_centers)
    crosses = np.full((n_v2, n_h2_expected, 2), np.nan, dtype=np.float64)

    # Positions sub-pixel du haut et du bas de grille pour chaque V2
    # (utilisees pour etendre le maillage au-dela des 33 croix reelles)
    grid_top_per_v2 = np.full(n_v2, np.nan, dtype=np.float64)
    grid_bot_per_v2 = np.full(n_v2, np.nan, dtype=np.float64)

    # Stats pour debug
    n_primary = 0   # croix trouvees via DoG principal
    n_fallback = 0  # croix trouvees via fallback H2 noir
    n_missing = 0   # croix non trouvees

    # Pour sauvegarde debug : conserver quelques profils DoG
    debug_profiles = {}

    for vi, vx in enumerate(v2_centers):
        cx_int = int(round(vx))
        x_lo = max(0, cx_int - band_half)
        x_hi = min(w, cx_int + band_half + 1)
        band = gray[:, x_lo:x_hi]
        band_w = band.shape[1]
        local_center = cx_int - x_lo  # position du centre V2 dans la bande

        # Profil vertical : moyenner quelques colonnes centrales de la bande
        # puis DoG 1D sur ce profil (bien plus rapide et adapte qu'un DoG 2D).
        # Les croix creent des creux nets dans ce profil.
        px_lo = max(0, local_center - 2)
        px_hi = min(band_w, local_center + 3)
        col_avg = np.mean(band[:, px_lo:px_hi].astype(np.float64), axis=1)
        # DoG 1D = blur_large - blur_petit ; une croix blanche (valeur elevee
        # brievement) donne blur_large ~ valeur de fond sombre, blur_petit ~ blanc
        # donc DoG = sombre - clair = negatif. Les croix sont des creux.
        blur_y_large = _gaussian_blur_1d(col_avg, sigma1_y)
        blur_y_small = _gaussian_blur_1d(col_avg, sigma2_y)
        profile = blur_y_large - blur_y_small

        # --- Detecter le haut et le bas de la grille dans la bande ---
        # La V2 est noire en continu a l'interieur de la grille (sauf croix),
        # blanche au-dessus et en-dessous (marges avec indices en clair).
        # On cherche donc la premiere transition blanc -> noir (entree dans la
        # grille, qui est le debut du plafond du 1er micro-bloc = gy=0) et la
        # derniere transition noir -> blanc (sortie = gy=2784).
        # Centrage sub-pixel par interpolation lineaire sur la transition.
        c_min = np.min(col_avg)
        c_max = np.max(col_avg)
        c_mid = (c_min + c_max) / 2.0
        is_dark = col_avg < c_mid
        dark_idx = np.where(is_dark)[0]
        if len(dark_idx) < 10:
            y0_hint_local = None
            grid_top_sub = None
            grid_bot_sub = None
        else:
            grid_top_px = int(dark_idx[0])
            grid_bot_px = int(dark_idx[-1])
            # Sub-pixel par interpolation lineaire sur la transition
            # grid_top : on cherche y tel que col_avg(y) = c_mid en descendant
            #           (passage blanc > c_mid -> noir < c_mid)
            if grid_top_px > 0:
                v_hi = col_avg[grid_top_px - 1]
                v_lo = col_avg[grid_top_px]
                if v_hi != v_lo:
                    delta = (v_hi - c_mid) / (v_hi - v_lo)
                    grid_top_sub = grid_top_px - 1 + delta
                else:
                    grid_top_sub = float(grid_top_px)
            else:
                grid_top_sub = float(grid_top_px)
            # grid_bot : transition noir -> blanc en descendant
            if grid_bot_px < len(col_avg) - 1:
                v_lo = col_avg[grid_bot_px]
                v_hi = col_avg[grid_bot_px + 1]
                if v_hi != v_lo:
                    delta = (c_mid - v_lo) / (v_hi - v_lo)
                    grid_bot_sub = grid_bot_px + delta
                else:
                    grid_bot_sub = float(grid_bot_px)
            else:
                grid_bot_sub = float(grid_bot_px)
            # Le haut de grille correspond a gy=0 (debut du plafond 1er micro)
            # Le bas de grille correspond a gy = 34*80 + 33*2 - 1 = 2785
            # (derniere ligne noire du plancher du 34e micro, mais en fait
            # l'encodeur dessine le plafond des micros a y=2706..2714 = plafond
            # de la 1re ligne de la section 34, puis data jusqu'a y=2783.
            # La derniere transition noir->blanc dans la bande V2 arrive a
            # la fin de la derniere ligne de donnees de la section 34 = y=2783)
            # La V2 est dessinee en continu de y=0 a y=2783 (= gh_grid - 1)
            # La transition noir->blanc finale est donc entre y=2783 et y=2784.
            y0_hint_local = grid_top_sub + h2y_grid_first * scale

        # Stocker pour le maillage etendu
        if grid_top_sub is not None:
            grid_top_per_v2[vi] = grid_top_sub + x_lo * 0.0  # juste stocker
            grid_top_per_v2[vi] = grid_top_sub
        if grid_bot_sub is not None:
            grid_bot_per_v2[vi] = grid_bot_sub

        # Seuil : creux significatif si profil < mean - k*std
        # On utilise la mediane et le MAD (Median Absolute Deviation)
        # pour etre robuste aux grandes valeurs dues aux croix elles-memes
        med = np.median(profile)
        mad = np.median(np.abs(profile - med)) + 1e-9
        threshold = med - 4.0 * mad  # creux = valeurs tres negatives

        # --- Detecter les creux locaux ---
        # On cherche tous les minima locaux au-dessous du seuil,
        # separes d'au moins 0.6 * step_px
        min_sep = int(0.6 * step_px)
        # Masque des points sous seuil
        below = profile < threshold
        # Groupes contigus
        candidate_centers = []
        in_dip = False
        dip_start = 0
        for y in range(len(profile)):
            if below[y]:
                if not in_dip:
                    dip_start = y
                    in_dip = True
            else:
                if in_dip:
                    # Centre du groupe = argmin du profil dans le groupe
                    seg = profile[dip_start:y]
                    best_local = int(np.argmin(seg))
                    candidate_centers.append(dip_start + best_local)
                    in_dip = False
        if in_dip:
            seg = profile[dip_start:]
            best_local = int(np.argmin(seg))
            candidate_centers.append(dip_start + best_local)

        # Filtrer pour respecter la distance minimale
        candidate_centers.sort()
        filtered = []
        for c in candidate_centers:
            if not filtered or (c - filtered[-1]) >= min_sep:
                filtered.append(c)
            else:
                # Garder le plus profond des deux
                if profile[c] < profile[filtered[-1]]:
                    filtered[-1] = c
        candidate_centers = filtered

        # --- Selectionner 33 croix regulierement espacees ---
        # Modele lineaire : y_k = y0 + k * step, pour k = 0..32
        # y0_hint_local permet d'ancrer y0 sur une estimation fondee sur
        # la geometrie (premiere H2 a 80 pts sous le haut de la grille detecte)
        selected = _select_regular_33(candidate_centers, step_px, n_h2_expected,
                                       profile_len=len(profile),
                                       y0_hint=y0_hint_local,
                                       y0_tol=step_px * 0.4)

        if selected is None:
            # Echec complet sur cette V2, on passe au fallback complet
            if vi < 3 or vi >= n_v2 - 3:
                print(f"    V2 #{vi+1} (x={vx:.1f}) : echec selection, "
                      f"{len(candidate_centers)} creux detectes")
            # On tente quand meme une estimation : premiere croix au centre
            # du premier creux trouve, reste par step_px
            if candidate_centers:
                y0 = float(candidate_centers[0])
                selected = [y0 + k * step_px for k in range(n_h2_expected)]
            else:
                n_missing += n_h2_expected
                continue

        # --- Pour chaque croix prevue : centrage sub-pixel en Y et X ---
        for hi, y_pred in enumerate(selected):
            y_int = int(round(y_pred))
            if y_int < 3 or y_int >= len(profile) - 3:
                # Hors image
                n_missing += 1
                continue

            # Chercher le minimum local exact dans une fenetre de ±0.2*step
            search_r = max(4, int(0.2 * step_px))
            y_lo = max(1, y_int - search_r)
            y_hi = min(len(profile) - 1, y_int + search_r + 1)
            local_window = profile[y_lo:y_hi]
            local_best = int(np.argmin(local_window))
            y_min = y_lo + local_best

            # Verifier que c'est bien un creux significatif
            if profile[y_min] > med - 2.0 * mad:
                # Creux trop faible : fallback sur la ligne H2 noire
                y_fb = _find_h2_black_line_near(binary, vx, y_pred, scale)
                if y_fb is not None:
                    y_sub = y_fb
                    n_fallback += 1
                else:
                    n_missing += 1
                    continue
            else:
                # Sub-pixel Y par parabole sur 3 points
                if 0 < y_min < len(profile) - 1:
                    dy = _parabolic_subpixel(profile[y_min-1],
                                             profile[y_min],
                                             profile[y_min+1])
                else:
                    dy = 0.0
                y_sub = y_min + dy
                n_primary += 1

            # --- Centrage sub-pixel en X ---
            # On prend une petite fenetre verticale de ±3 px autour de y_sub
            # et on cherche le minimum du DoG horizontal dans cette fenetre.
            yi = int(round(y_sub))
            yw_lo = max(0, yi - 3)
            yw_hi = min(h, yi + 4)
            # Patch de la bande en niveaux de gris
            patch = band[yw_lo:yw_hi, :].astype(np.float64)
            if patch.shape[0] < 3:
                # Trop pres du bord, abandon
                continue

            # Moyenne verticale du patch : on obtient un profil horizontal
            # qui est sombre partout (murs V2) et clair sur le centre de la croix
            h_signal = np.mean(patch, axis=0)
            # DoG horizontal 1D avec sigma1 reduit (bande etroite)
            h_blur_large = _gaussian_blur_1d(h_signal, sigma1_x)
            h_blur_small = _gaussian_blur_1d(h_signal, sigma2_y)
            h_profile = h_blur_large - h_blur_small

            # Minimum du profil horizontal = centre X de la croix
            x_min = int(np.argmin(h_profile))
            if 0 < x_min < band_w - 1:
                dx = _parabolic_subpixel(h_profile[x_min-1],
                                         h_profile[x_min],
                                         h_profile[x_min+1])
            else:
                dx = 0.0
            x_sub = x_lo + x_min + dx

            # Garde-fou : x doit rester dans la bande
            if abs(x_sub - vx) > band_half:
                x_sub = vx  # fallback sur le centre V2 nominal

            crosses[vi, hi, 0] = y_sub
            crosses[vi, hi, 1] = x_sub

        # Conserver les profils des premieres/dernieres V2 pour debug
        if debug_dir and (vi < 3 or vi >= n_v2 - 2):
            debug_profiles[vi] = (profile.copy(), selected, threshold, med, mad)

    total = n_v2 * n_h2_expected
    n_found = n_primary + n_fallback
    print(f"  Croix localisees     : {n_found}/{total} "
          f"({n_primary} primaire + {n_fallback} fallback, {n_missing} manquantes)")

    # Rapport des positions haut/bas de grille mesurees
    n_top = int(np.sum(~np.isnan(grid_top_per_v2)))
    n_bot = int(np.sum(~np.isnan(grid_bot_per_v2)))
    if n_top > 0 and n_bot > 0:
        top_mean = np.nanmean(grid_top_per_v2)
        bot_mean = np.nanmean(grid_bot_per_v2)
        print(f"  Haut de grille (sub-px) : {n_top}/{n_v2} V2, moy {top_mean:.2f} px")
        print(f"  Bas de grille  (sub-px) : {n_bot}/{n_v2} V2, moy {bot_mean:.2f} px")

    # --- Sauvegarde debug ---
    if debug_dir:
        _save_cross_debug(gray, crosses, v2_centers, scale,
                          debug_profiles, debug_dir)

    return crosses, scale, grid_top_per_v2, grid_bot_per_v2


def _select_regular_33(candidates, step_px, n_expected, profile_len,
                        y0_hint=None, y0_tol=None):
    """A partir d'une liste de positions Y candidates, selectionne n_expected
    positions alignees sur un modele lineaire y_k = y0 + k*step.
    Renvoie une liste de n_expected positions (float), ou None si echec.

    Parametres :
      candidates : liste triee des positions Y des creux detectes
      step_px    : pas attendu entre positions consecutives
      n_expected : nombre de positions a trouver
      profile_len: longueur du profil (pour filtrer les y0 absurdes)
      y0_hint    : position attendue de la premiere croix (k=0). Si fournie,
                   les modeles dont y0 s'en ecarte de plus de y0_tol sont rejetes.
      y0_tol     : tolerance autour de y0_hint (defaut : 0.5 * step_px)

    Algorithme :
      - Essais RANSAC : pour chaque paire (k0, k1) de candidats avec k1-k0
        correspondant au pas attendu, calculer le modele et compter les inliers
      - Rejeter les modeles dont y0 predit est trop loin de y0_hint si fourni
      - Retenir le meilleur et raffiner par moindres carres sur les inliers
    """
    if len(candidates) < n_expected // 2:
        return None

    if y0_tol is None:
        y0_tol = 0.5 * step_px

    tolerance = step_px / 4.0
    best_inliers = 0
    best_y0 = None
    best_step = step_px

    # Helper : evaluer un modele (y0, step) en comptant les inliers
    def evaluate_model(y0_m, step_m):
        if y0_hint is not None and abs(y0_m - y0_hint) > y0_tol:
            return 0
        if abs(step_m - step_px) > 0.15 * step_px:
            return 0
        inliers = 0
        for c in candidates:
            k_float = (c - y0_m) / step_m
            k_int = round(k_float)
            if 0 <= k_int < n_expected:
                pred = y0_m + k_int * step_m
                if abs(c - pred) < tolerance:
                    inliers += 1
        return inliers

    # Strategie 1 : essais RANSAC sur des paires de candidats
    # Pour que la paire (c_i, c_j) corresponde a (k_a, k_b), il faut
    # que (c_j - c_i) ~ (k_b - k_a) * step_px.
    # On essaie (k_a, k_b) = (0, n-1) en priorite, puis d'autres k_b.
    n = len(candidates)
    # Limiter le nombre d'essais pour rester rapide
    max_k0_trials = min(6, n)
    for i in range(max_k0_trials):
        y0_cand = candidates[i]
        # Hypothese : candidates[i] correspond a k=0
        # Chercher quel candidat pourrait etre le dernier (k = n_expected-1)
        y_last_expected = y0_cand + (n_expected - 1) * step_px
        # Chercher le candidat le plus proche de y_last_expected
        for j in range(n - 1, max(-1, n - 8), -1):
            y_last_cand = candidates[j]
            if abs(y_last_cand - y_last_expected) > step_px:
                continue
            step_cand = (y_last_cand - y0_cand) / (n_expected - 1)
            inliers = evaluate_model(y0_cand, step_cand)
            if inliers > best_inliers:
                best_inliers = inliers
                best_y0 = y0_cand
                best_step = step_cand

    # Strategie 2 : si y0_hint est fourni, tester tous les candidats
    # proches de y0_hint comme y0 possible, avec step=step_px
    if y0_hint is not None:
        for c in candidates:
            if abs(c - y0_hint) <= y0_tol:
                inliers = evaluate_model(c, step_px)
                if inliers > best_inliers:
                    best_inliers = inliers
                    best_y0 = c
                    best_step = step_px

    # Strategie 3 : fallback sans contrainte, uniquement si rien n'a marche
    if best_inliers < n_expected * 0.5 and y0_hint is None:
        y0_candidates_coarse = [c for c in candidates if c < profile_len * 0.15]
        if not y0_candidates_coarse:
            y0_candidates_coarse = candidates[:3]
        for y0_try in y0_candidates_coarse:
            inliers = evaluate_model(y0_try, step_px)
            if inliers > best_inliers:
                best_inliers = inliers
                best_y0 = y0_try
                best_step = step_px

    if best_y0 is None or best_inliers < n_expected * 0.3:
        return None

    # Raffinement final : moindres carres sur les inliers
    inlier_k = []
    inlier_y = []
    for c in candidates:
        k_float = (c - best_y0) / best_step
        k_int = round(k_float)
        if 0 <= k_int < n_expected:
            pred = best_y0 + k_int * best_step
            if abs(c - pred) < tolerance:
                inlier_k.append(k_int)
                inlier_y.append(c)

    if len(inlier_k) >= 3:
        A = np.array([[k, 1] for k in inlier_k], dtype=np.float64)
        b = np.array(inlier_y, dtype=np.float64)
        params, _, _, _ = np.linalg.lstsq(A, b, rcond=None)
        final_step, final_y0 = params[0], params[1]
    else:
        final_step, final_y0 = best_step, best_y0

    # Positions predites pour k = 0..N-1
    return [final_y0 + k * final_step for k in range(n_expected)]


def _save_cross_debug(gray, crosses, v2_centers, scale,
                      debug_profiles, debug_dir):
    """Sauvegarde des images et donnees de debug pour les croix detectees."""
    from PIL import Image as _Image, ImageDraw as _ID
    import os as _os

    h, w = gray.shape

    # 1) Vue d'ensemble en pleine resolution avec toutes les croix marquees
    # L'image originale est convertie en RGB pour permettre le dessin en couleur.
    # Attention : une image 10200x14031 RGB = ~430 Mo en memoire.
    full = _Image.fromarray(gray).convert('RGB')
    draw = _ID.Draw(full)
    r = max(5, int(scale * 2))  # rayon du cercle adapte a la resolution
    line_w = max(1, int(scale / 3))
    for vi in range(crosses.shape[0]):
        for hi in range(crosses.shape[1]):
            y, x = crosses[vi, hi]
            if np.isnan(y) or np.isnan(x):
                continue
            sx, sy = int(round(x)), int(round(y))
            draw.ellipse([sx-r, sy-r, sx+r, sy+r], outline='lime', width=line_w)
            # Petite croix rouge au centre exact pour voir le sub-pixel
            draw.line([(sx - 2, sy), (sx + 2, sy)], fill='red', width=1)
            draw.line([(sx, sy - 2), (sx, sy + 2)], fill='red', width=1)
    out1 = _os.path.join(debug_dir, "debug_crosses_overview.png")
    full.save(out1)
    del full, draw  # liberer la memoire
    print(f"    {out1} (pleine resolution 1200 dpi, croix vertes + centre rouge)")

    # 2) Zooms sur les croix extremes (coins et milieux) en pleine resolution
    # Choisir 4 points : coin HG, coin HD, coin BG, coin BD
    zoom_targets = [
        ("HG", 0, 0),
        ("HD", crosses.shape[0] - 1, 0),
        ("BG", 0, crosses.shape[1] - 1),
        ("BD", crosses.shape[0] - 1, crosses.shape[1] - 1),
        ("MIL", crosses.shape[0] // 2, crosses.shape[1] // 2),
    ]
    zoom_half = max(30, int(scale * 6))
    for tag, vi, hi in zoom_targets:
        y, x = crosses[vi, hi]
        if np.isnan(y) or np.isnan(x):
            continue
        yi, xi = int(round(y)), int(round(x))
        y_lo = max(0, yi - zoom_half)
        y_hi = min(h, yi + zoom_half)
        x_lo = max(0, xi - zoom_half)
        x_hi = min(w, xi + zoom_half)
        patch = gray[y_lo:y_hi, x_lo:x_hi]
        pimg = _Image.fromarray(patch).convert('RGB')
        pdraw = _ID.Draw(pimg)
        # Marquer le centre precis
        cy_local = y - y_lo
        cx_local = x - x_lo
        # Petite croix rouge sur le centre
        pdraw.line([(cx_local - 5, cy_local), (cx_local + 5, cy_local)],
                   fill='red', width=1)
        pdraw.line([(cx_local, cy_local - 5), (cx_local, cy_local + 5)],
                   fill='red', width=1)
        out = _os.path.join(debug_dir, f"debug_cross_zoom_{tag}.png")
        pimg.save(out)
        print(f"    {out} (zoom pleine res, croix rouge sub-pixel)")

    # 3) Profils DoG des premieres/dernieres V2 en CSV
    if debug_profiles:
        csv_path = _os.path.join(debug_dir, "debug_profiles.csv")
        with open(csv_path, 'w') as f:
            f.write("# Profils DoG le long des V2 extremes\n")
            for vi, (prof, sel, thr, med, mad) in debug_profiles.items():
                f.write(f"# V2 #{vi+1} : centre x={v2_centers[vi]:.2f}, "
                        f"mediane={med:.3f}, MAD={mad:.3f}, seuil={thr:.3f}\n")
                f.write(f"# Positions predites (33) : "
                        f"{','.join(f'{s:.1f}' for s in sel)}\n")
            f.write("# y,")
            f.write(",".join(f"v{vi+1}" for vi in debug_profiles.keys()))
            f.write("\n")
            max_len = max(len(p[0]) for p in debug_profiles.values())
            profs = {vi: p[0] for vi, p in debug_profiles.items()}
            for y in range(0, max_len, 4):  # echantillonner 1/4 pour la taille
                row = [f"{y}"]
                for vi in debug_profiles.keys():
                    if y < len(profs[vi]):
                        row.append(f"{profs[vi][y]:.2f}")
                    else:
                        row.append("")
                f.write(",".join(row) + "\n")
        print(f"    {csv_path} (profils DoG echantillonnes)")


# =============================================================================
# CALAGE GEOMETRIQUE
# =============================================================================

def fit_affine_transform(crosses_array):
    """Calcule la transformation affine grille -> image a partir du tableau
    de croix detectees.

    crosses_array : np.ndarray de forme (n_v2, n_h2, 2), derniere dim = (y, x)
                    np.nan pour les croix non trouvees.

    La croix (vi, hi) a pour coordonnees grille (v2x_grid[vi], h2y_grid[hi])
    et pour coordonnees image crosses_array[vi, hi, :].
    """
    v2x_grid = compute_v2_centers_x()
    h2y_grid = compute_h2_centers_y()

    n_v2, n_h2, _ = crosses_array.shape
    if n_v2 != len(v2x_grid):
        print(f"  ATTENTION : {n_v2} V2 detectees vs {len(v2x_grid)} attendues")
    if n_h2 != len(h2y_grid):
        print(f"  ATTENTION : {n_h2} H2 detectees vs {len(h2y_grid)} attendues")

    pairs = []
    for vi in range(min(n_v2, len(v2x_grid))):
        for hi in range(min(n_h2, len(h2y_grid))):
            y, x = crosses_array[vi, hi]
            if np.isnan(y) or np.isnan(x):
                continue
            gx = v2x_grid[vi]
            gy = h2y_grid[hi]
            pairs.append(((gx, gy), (y, x)))

    print(f"  Paires appariees : {len(pairs)}")
    if len(pairs) < 3:
        raise ValueError("Pas assez de croix appariees pour calculer la transformation")

    A = np.array([[gx, gy, 1.0] for (gx, gy), _ in pairs], dtype=np.float64)
    bx = np.array([x for _, (y, x) in pairs], dtype=np.float64)
    by = np.array([y for _, (y, x) in pairs], dtype=np.float64)

    params_x, _, _, _ = np.linalg.lstsq(A, bx, rcond=None)
    params_y, _, _, _ = np.linalg.lstsq(A, by, rcond=None)
    transform = np.array([params_x, params_y])

    # Residus
    residuals = []
    for (gx, gy), (y, x) in pairs:
        pred_x = transform[0, 0] * gx + transform[0, 1] * gy + transform[0, 2]
        pred_y = transform[1, 0] * gx + transform[1, 1] * gy + transform[1, 2]
        residuals.append(math.hypot(pred_x - x, pred_y - y))

    residuals = np.array(residuals)
    mean_res = float(np.mean(residuals))
    max_res = float(np.max(residuals))
    p95_res = float(np.percentile(residuals, 95))
    print(f"  Residus : moyen {mean_res:.2f} px, p95 {p95_res:.2f} px, "
          f"max {max_res:.2f} px")

    return transform


def grid_to_image(transform, gx, gy):
    """Convertit des coordonnees grille en coordonnees image (modele affine global).
    Conserve pour diagnostic ; l'echantillonnage reel utilise grid_to_image_mesh."""
    px = transform[0, 0] * gx + transform[0, 1] * gy + transform[0, 2]
    py = transform[1, 0] * gx + transform[1, 1] * gy + transform[1, 2]
    return px, py


# =============================================================================
# CALAGE PAR MAILLAGE BILINEAIRE
# =============================================================================
#
# Un modele affine global ne capture pas les distorsions non-lineaires du
# scanner (barrel, pincushion, entrainement du papier non uniforme). On utilise
# donc les 759 croix comme un maillage d'ancrage 23 x 33 et on interpole
# bilineairement la transformation entre 4 croix voisines.
#
# Le maillage est forme par les croix aux croisements V2/H2 :
#   - 23 colonnes de V2 (indices vi = 0..22) a gx_grid = v2x_grid[vi]
#   - 33 lignes de H2  (indices hi = 0..32) a gy_grid = h2y_grid[hi]
#
# Pour un point (gx, gy) dans la grille :
#   - Cellule V2 : vi tel que v2x_grid[vi] <= gx < v2x_grid[vi+1]
#   - Cellule H2 : hi tel que h2y_grid[hi] <= gy < h2y_grid[hi+1]
#   - Coordonnees normalisees (u, v) dans la cellule : u dans [0,1]
#
# Zones aux bords :
#   - gx < v2x_grid[0] ou gx >= v2x_grid[-1] : en X, les croix de bordure
#     encadrent toute la grille en X (v2x_grid = [2, 90, ..., 1938] et
#     les donnees sont entre x=6 et x=1936 environ), donc pas besoin
#     d'extrapoler en X.
#   - gy < h2y_grid[0]  : section 1 (les 80 premiers points de grille)
#   - gy >= h2y_grid[-1]: section 34 (les 80 derniers points)
#   Pour ces zones, on extrapole en utilisant la cellule la plus proche.

def build_mesh(crosses, grid_top_per_v2=None, grid_bot_per_v2=None):
    """Construit les donnees du maillage a partir du tableau des croix.

    En cas de croix manquantes (NaN), interpole par les voisines.

    Le maillage est AUGMENTE de deux lignes virtuelles (avant la 1re H2 et
    apres la derniere) pour eviter les extrapolations imprecises dans les
    sections 1 et 34 (de part et d'autre des croix extremes).

    Strategie de positionnement des lignes virtuelles :
      - Si grid_top_per_v2 et grid_bot_per_v2 sont fournis (positions
        sub-pixel mesurees directement dans l'image), on les utilise comme
        ancres pour gy=0 (haut de grille = plafond 1er micro-bloc) et
        gy=2784 (bas de grille = fin du 34e micro-bloc). Ces mesures sont
        plus fiables que l'extrapolation car elles suivent fidelement la
        distorsion locale en haut et en bas de la page.
      - Sinon, fallback : regression lineaire sur les 33 croix de chaque V2.
    """
    v2x_grid_real = np.array(compute_v2_centers_x(), dtype=np.float64)
    h2y_grid_real = np.array(compute_h2_centers_y(), dtype=np.float64)
    n_v2, n_h2, _ = crosses.shape

    img_y = crosses[:, :, 0].copy()
    img_x = crosses[:, :, 1].copy()

    # --- Interpolation des croix manquantes (NaN) ---
    n_missing = int(np.sum(np.isnan(img_y)))
    if n_missing > 0:
        print(f"  Interpolation de {n_missing} croix manquantes...")
        for _ in range(5):
            new_y = img_y.copy()
            new_x = img_x.copy()
            changed = False
            for vi in range(n_v2):
                for hi in range(n_h2):
                    if not np.isnan(img_y[vi, hi]):
                        continue
                    neighbors_y = []
                    neighbors_x = []
                    for dvi, dhi in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                        nvi, nhi = vi + dvi, hi + dhi
                        if 0 <= nvi < n_v2 and 0 <= nhi < n_h2:
                            if not np.isnan(img_y[nvi, nhi]):
                                neighbors_y.append(img_y[nvi, nhi])
                                neighbors_x.append(img_x[nvi, nhi])
                    if len(neighbors_y) >= 2:
                        new_y[vi, hi] = np.mean(neighbors_y)
                        new_x[vi, hi] = np.mean(neighbors_x)
                        changed = True
            img_y = new_y
            img_x = new_x
            if not changed:
                break

    # --- Augmentation du maillage ---
    # Deux lignes virtuelles :
    #   gy_top = 0     (haut de grille, plafond du 1er micro-bloc)
    #   gy_bot = 2784  (bas de grille, fin du 34e micro-bloc)
    gy_top = 0.0
    gy_bot = h2y_grid_real[-1] + MICRO_ROWS_PER_SECTION * MICRO_H  # 2784

    new_h2y = np.concatenate(([gy_top], h2y_grid_real, [gy_bot]))
    new_n_h2 = n_h2 + 2

    img_y_ext = np.zeros((n_v2, new_n_h2), dtype=np.float64)
    img_x_ext = np.zeros((n_v2, new_n_h2), dtype=np.float64)

    # Colonnes centrales = croix reelles
    img_y_ext[:, 1:-1] = img_y
    img_x_ext[:, 1:-1] = img_x

    # --- Determiner les positions image des lignes virtuelles ---
    # Si des mesures directes (sub-pixel) sont disponibles, on les utilise.
    # Sinon, on fait une regression lineaire.
    use_measured_top = (grid_top_per_v2 is not None
                        and np.sum(~np.isnan(grid_top_per_v2)) >= n_v2 - 2)
    use_measured_bot = (grid_bot_per_v2 is not None
                        and np.sum(~np.isnan(grid_bot_per_v2)) >= n_v2 - 2)

    if use_measured_top:
        print("  Ligne virtuelle HAUT : utilise les positions mesurees grid_top")
    else:
        print("  Ligne virtuelle HAUT : regression lineaire (fallback)")
    if use_measured_bot:
        print("  Ligne virtuelle BAS  : utilise les positions mesurees grid_bot")
    else:
        print("  Ligne virtuelle BAS  : regression lineaire (fallback)")

    for vi in range(n_v2):
        # --- Haut de grille ---
        if use_measured_top and not np.isnan(grid_top_per_v2[vi]):
            img_y_ext[vi, 0] = grid_top_per_v2[vi]
            # Pour X : on pourrait utiliser le centre V2 detecte, mais l'X
            # de la 1re croix reelle (hi=0) est deja precis au pixel.
            # On extrapole en X par la meme pente que entre hi=0 et hi=1
            # (typiquement 0 car les V2 sont quasi verticales).
            dx = img_x_ext[vi, 2] - img_x_ext[vi, 1]  # pente X sur 1 H2
            dgy = h2y_grid_real[1] - h2y_grid_real[0]
            img_x_ext[vi, 0] = img_x_ext[vi, 1] + dx * (gy_top - h2y_grid_real[0]) / dgy
        else:
            # Regression lineaire sur les 33 croix de cette V2
            gy_vals = h2y_grid_real.astype(np.float64)
            py_vals = img_y[vi, :]
            px_vals = img_x[vi, :]
            valid = ~np.isnan(py_vals)
            if np.sum(valid) >= 2:
                g = gy_vals[valid]
                A = np.vstack([g, np.ones_like(g)]).T
                by, ay = np.linalg.lstsq(A, py_vals[valid], rcond=None)[0]
                bx, ax = np.linalg.lstsq(A, px_vals[valid], rcond=None)[0]
                img_y_ext[vi, 0] = ay + by * gy_top
                img_x_ext[vi, 0] = ax + bx * gy_top
            else:
                img_y_ext[vi, 0] = img_y_ext[vi, 1]
                img_x_ext[vi, 0] = img_x_ext[vi, 1]

        # --- Bas de grille ---
        if use_measured_bot and not np.isnan(grid_bot_per_v2[vi]):
            img_y_ext[vi, -1] = grid_bot_per_v2[vi]
            dx = img_x_ext[vi, -2] - img_x_ext[vi, -3]
            dgy = h2y_grid_real[-1] - h2y_grid_real[-2]
            img_x_ext[vi, -1] = img_x_ext[vi, -2] + dx * (gy_bot - h2y_grid_real[-1]) / dgy
        else:
            gy_vals = h2y_grid_real.astype(np.float64)
            py_vals = img_y[vi, :]
            px_vals = img_x[vi, :]
            valid = ~np.isnan(py_vals)
            if np.sum(valid) >= 2:
                g = gy_vals[valid]
                A = np.vstack([g, np.ones_like(g)]).T
                by, ay = np.linalg.lstsq(A, py_vals[valid], rcond=None)[0]
                bx, ax = np.linalg.lstsq(A, px_vals[valid], rcond=None)[0]
                img_y_ext[vi, -1] = ay + by * gy_bot
                img_x_ext[vi, -1] = ax + bx * gy_bot
            else:
                img_y_ext[vi, -1] = img_y_ext[vi, -2]
                img_x_ext[vi, -1] = img_x_ext[vi, -2]

    print(f"  Maillage etendu : {new_n_h2} lignes (dont 2 virtuelles) x {n_v2} colonnes")
    print(f"    Lignes virtuelles : gy={gy_top:.0f} (haut) et gy={gy_bot:.0f} (bas)")

    return {
        'v2x_grid': v2x_grid_real,
        'h2y_grid': new_h2y,
        'img_y': img_y_ext,
        'img_x': img_x_ext,
        'n_v2': n_v2,
        'n_h2': new_n_h2,
    }


def grid_to_image_mesh(mesh, gx, gy):
    """Interpolation bilineaire : position image d'un point grille (gx, gy).

    Utilise le maillage de croix pour suivre les distorsions non-lineaires
    du scan. Extrapole proprement au-dela des croix extremes (sections 1
    et 34, et legere marge en X).
    """
    v2x = mesh['v2x_grid']
    h2y = mesh['h2y_grid']
    img_y = mesh['img_y']
    img_x = mesh['img_x']
    n_v2 = mesh['n_v2']
    n_h2 = mesh['n_h2']

    # --- Trouver la cellule V2 (indice vi tq v2x[vi] <= gx < v2x[vi+1]) ---
    # np.searchsorted retourne l'indice ou inserer gx pour rester trie
    vi = int(np.searchsorted(v2x, gx, side='right')) - 1
    # Borner pour extrapoler depuis la cellule la plus proche
    if vi < 0:
        vi = 0
    elif vi >= n_v2 - 1:
        vi = n_v2 - 2
    u = (gx - v2x[vi]) / (v2x[vi + 1] - v2x[vi])

    # --- Trouver la cellule H2 (indice hi tq h2y[hi] <= gy < h2y[hi+1]) ---
    hi = int(np.searchsorted(h2y, gy, side='right')) - 1
    if hi < 0:
        hi = 0
    elif hi >= n_h2 - 1:
        hi = n_h2 - 2
    v = (gy - h2y[hi]) / (h2y[hi + 1] - h2y[hi])

    # --- Interpolation bilineaire ---
    # P00 = coin haut-gauche (vi,   hi)
    # P10 = coin haut-droite(vi+1, hi)
    # P01 = coin bas-gauche (vi,   hi+1)
    # P11 = coin bas-droite (vi+1, hi+1)
    w00 = (1 - u) * (1 - v)
    w10 = u * (1 - v)
    w01 = (1 - u) * v
    w11 = u * v

    px = (w00 * img_x[vi,   hi]   + w10 * img_x[vi+1, hi]   +
          w01 * img_x[vi,   hi+1] + w11 * img_x[vi+1, hi+1])
    py = (w00 * img_y[vi,   hi]   + w10 * img_y[vi+1, hi]   +
          w01 * img_y[vi,   hi+1] + w11 * img_y[vi+1, hi+1])
    return px, py


def grid_to_image_mesh_vec(mesh, gx_arr, gy_arr):
    """Version vectorisee : accepte des arrays numpy et renvoie (px, py)
    en arrays numpy. Beaucoup plus rapide pour echantillonner les millions
    de bits de la page."""
    v2x = mesh['v2x_grid']
    h2y = mesh['h2y_grid']
    img_y = mesh['img_y']
    img_x = mesh['img_x']
    n_v2 = mesh['n_v2']
    n_h2 = mesh['n_h2']

    gx_arr = np.asarray(gx_arr, dtype=np.float64)
    gy_arr = np.asarray(gy_arr, dtype=np.float64)

    vi = np.searchsorted(v2x, gx_arr, side='right') - 1
    vi = np.clip(vi, 0, n_v2 - 2)
    u = (gx_arr - v2x[vi]) / (v2x[vi + 1] - v2x[vi])

    hi = np.searchsorted(h2y, gy_arr, side='right') - 1
    hi = np.clip(hi, 0, n_h2 - 2)
    v = (gy_arr - h2y[hi]) / (h2y[hi + 1] - h2y[hi])

    w00 = (1 - u) * (1 - v)
    w10 = u * (1 - v)
    w01 = (1 - u) * v
    w11 = u * v

    px = (w00 * img_x[vi,   hi]   + w10 * img_x[vi+1, hi]   +
          w01 * img_x[vi,   hi+1] + w11 * img_x[vi+1, hi+1])
    py = (w00 * img_y[vi,   hi]   + w10 * img_y[vi+1, hi]   +
          w01 * img_y[vi,   hi+1] + w11 * img_y[vi+1, hi+1])
    return px, py


def mesh_residuals(mesh, crosses):
    """Mesure les residus du maillage : par construction, l'interpolation
    bilineaire passe exactement par les noeuds reels. Les residus servent
    de controle (doivent etre nuls aux croix reelles).

    Note : les deux lignes virtuelles ajoutees par build_mesh sont testees
    a part, mais leur residu n'est pas significatif (elles sont des
    extrapolations, pas des mesures).
    """
    # Les croix reelles sont en hi=1..n_h2-2 dans le maillage etendu.
    # crosses (donnee en entree) utilise l'indexation originale 0..n_h2_real-1
    max_err = 0.0
    n_h2_real = crosses.shape[1]
    for vi in range(mesh['n_v2']):
        for hi_real in range(n_h2_real):
            y_ref = crosses[vi, hi_real, 0]
            x_ref = crosses[vi, hi_real, 1]
            if np.isnan(y_ref):
                continue
            # La coordonnee gy de cette croix reelle
            h2y_real = compute_h2_centers_y()
            gx = mesh['v2x_grid'][vi]
            gy = h2y_real[hi_real]
            px, py = grid_to_image_mesh(mesh, gx, gy)
            err = math.hypot(px - x_ref, py - y_ref)
            if err > max_err:
                max_err = err
    return max_err


# =============================================================================
# ECHANTILLONNAGE DES BITS (avec maillage bilineaire)
# =============================================================================

def sample_bits(binary, mesh, scale, debug_dir=None):
    """Echantillonne tous les bits de donnees en utilisant le maillage
    bilineaire de croix. Vectorise pour les performances.

    binary : tableau bool numpy (True = blanc, False = noir)
    mesh   : dict produit par build_mesh()
    scale  : echelle px/pt, pour dimensionner la zone d'echantillonnage
    """
    micro_positions = compute_micro_positions()
    h, w = binary.shape

    # --- Construction vectorisee des coordonnees grille de tous les bits ---
    # Chaque micro-bloc contient DATA_ROWS * DATA_BITS = 64 bits
    # Les coordonnees grille d'un bit dans le micro-bloc (mx, my) :
    #   gx = mx + 1 + bit    pour bit in 0..7
    #   gy = my + 1 + row    pour row in 0..7
    n_micros = len(micro_positions)
    mx_arr = np.array([mp[0] for mp in micro_positions], dtype=np.float64)
    my_arr = np.array([mp[1] for mp in micro_positions], dtype=np.float64)

    # Offsets dans chaque micro-bloc
    bit_offsets = np.arange(DATA_BITS, dtype=np.float64) + 1.0  # [1..8]
    row_offsets = np.arange(DATA_ROWS, dtype=np.float64) + 1.0  # [1..8]

    # Produit externe pour avoir toutes les coords
    # gx_all et gy_all : shape finale (n_micros, DATA_ROWS, DATA_BITS)
    # On cree d'abord les tableaux aux bonnes shapes partielles, puis on
    # utilise broadcast_arrays pour les forcer a la meme shape 3D complete.
    # gx depend de (n_micros, bit) mais pas de row : shape (n_micros, 1, DATA_BITS)
    # gy depend de (n_micros, row) mais pas de bit : shape (n_micros, DATA_ROWS, 1)
    gx_partial = mx_arr[:, None, None] + bit_offsets[None, None, :]  # (n_micros, 1, 8)
    gy_partial = my_arr[:, None, None] + row_offsets[None, :, None]  # (n_micros, 8, 1)
    # Forcer la shape (n_micros, DATA_ROWS, DATA_BITS) par broadcasting explicite
    gx_all, gy_all = np.broadcast_arrays(gx_partial, gy_partial)
    # Maintenant gx_all et gy_all ont tous deux la shape (n_micros, 8, 8)

    # Applatir pour l'interpolation : ordre de parcours = micro-bloc, puis row, puis bit
    gx_flat = np.ascontiguousarray(gx_all).ravel()
    gy_flat = np.ascontiguousarray(gy_all).ravel()

    print(f"  Bits a echantillonner : {len(gx_flat)}")
    print(f"  Conversion grille -> image (bilineaire)...")
    px_flat, py_flat = grid_to_image_mesh_vec(mesh, gx_flat, gy_flat)

    # --- Echantillonnage : moyenne sur un petit voisinage ---
    # Au centre d'un point de grille, on echantillonne une fenetre de
    # (2r+1) x (2r+1) pixels et on compte la proportion de blancs.
    sample_radius = max(1, int(round(scale * 0.35)))
    ix_flat = np.round(px_flat).astype(np.int32)
    iy_flat = np.round(py_flat).astype(np.int32)

    # Masque des points dans l'image (hors bords)
    valid = ((ix_flat >= sample_radius) & (ix_flat < w - sample_radius) &
             (iy_flat >= sample_radius) & (iy_flat < h - sample_radius))
    n_valid = int(np.sum(valid))
    n_out = len(ix_flat) - n_valid
    if n_out > 0:
        print(f"  ATTENTION : {n_out} bits hors image (forces a 0)")

    # Pour chaque bit valide, calculer la proportion de blancs dans
    # la fenetre (2r+1)x(2r+1). On vectorise en additionnant les 
    # (2r+1)^2 decalages.
    print(f"  Echantillonnage (fenetre {2*sample_radius+1}x{2*sample_radius+1})...")
    white_ratio = np.zeros(len(ix_flat), dtype=np.float64)
    # Convertir binary en uint8 (1=blanc, 0=noir) pour accumulation
    bin_u8 = binary.astype(np.uint8)
    # Accumuler les echantillons
    count = np.zeros(len(ix_flat), dtype=np.int32)
    acc_white = np.zeros(len(ix_flat), dtype=np.int32)
    for dy in range(-sample_radius, sample_radius + 1):
        for dx in range(-sample_radius, sample_radius + 1):
            sx = ix_flat + dx
            sy = iy_flat + dy
            in_bounds = (sx >= 0) & (sx < w) & (sy >= 0) & (sy < h)
            # Pour les points hors bornes, on ne compte pas
            # Utiliser clip pour l'indexation et masquer ensuite
            sx_c = np.clip(sx, 0, w - 1)
            sy_c = np.clip(sy, 0, h - 1)
            vals = bin_u8[sy_c, sx_c]
            acc_white += np.where(in_bounds, vals, 0).astype(np.int32)
            count += in_bounds.astype(np.int32)

    mask = count > 0
    white_ratio[mask] = acc_white[mask] / count[mask]
    white_ratio[~mask] = 1.0  # hors image : considerer blanc (bit 0)

    # --- Decision : bit = 0 (blanc) ou 1 (noir) ---
    bits = (white_ratio <= 0.5).astype(np.uint8)  # noir => 1
    confidence = np.abs(white_ratio - 0.5) * 2.0
    low_conf = int(np.sum(confidence < 0.3))

    print(f"  Bits faible confiance : {low_conf} ({100*low_conf/len(bits):.1f}%)")

    # --- Empaqueter en octets ---
    # Structure : pour chaque micro-bloc, 8 octets (1 par ligne de donnees)
    # Chaque octet = 8 bits dans l'ordre MSB first
    bits_reshape = bits.reshape(n_micros, DATA_ROWS, DATA_BITS)
    # Conversion bits -> octets
    powers = (1 << np.arange(DATA_BITS - 1, -1, -1)).astype(np.uint8)
    bytes_arr = np.sum(bits_reshape * powers[None, None, :], axis=2).astype(np.uint8)

    data = bytes_arr.ravel().tobytes()
    print(f"  Octets reconstitues   : {len(data)}")

    # --- Debug : zoom sur quelques micro-blocs avec TOUS les points d'echantillonnage ---
    # But : voir si les bits de donnees tombent exactement sur les pixels attendus
    if debug_dir:
        _save_sampling_debug(binary, mesh, scale, micro_positions,
                             px_flat, py_flat, bits, debug_dir)

    return data


def _save_sampling_debug(binary, mesh, scale, micro_positions,
                         px_flat, py_flat, bits, debug_dir):
    """Sauvegarde des zooms pleine resolution montrant les points
    d'echantillonnage sur quelques micro-blocs representatifs.

    Rouge : bits de donnees echantillonnes
    Vert  : reperes N (mur gauche)
    Bleu  : reperes plafond
    """
    from PIL import Image as _Image, ImageDraw as _ID
    import os as _os

    h, w = binary.shape
    n_micros = len(micro_positions)

    # Choisir des micro-blocs a zoomer : coins + centre de la zone de donnees
    # (macro-bloc A01 = micro 0, macro-bloc V34 = micro (GROUPS_H-1, SECTIONS_V-1))
    # On pioche plusieurs positions : debut, centre, fin
    targets = [
        ("m0000", 0),                        # tout premier micro-bloc
        ("m0007", 7),                        # 8e micro-bloc (fin du 1er demi-groupe)
        ("m0008", 8),                        # 9e (debut du 2e demi-groupe, apres V1)
        ("m0015", 15),                       # 16e (fin du 1er groupe, avant V2)
        ("m0016", 16),                       # 17e (debut du 2e groupe, apres V2)
        ("mMIL",  n_micros // 2),            # milieu
        ("mFIN",  n_micros - 1),             # dernier
    ]

    # Pour dessiner : convertir la bande noir/blanc en RGB
    # On ne convertit que les zones de zoom pour eviter les 430 Mo
    for tag, micro_idx in targets:
        mx, my = micro_positions[micro_idx]
        # Calculer la position image du centre du micro-bloc
        gx_center = mx + 4.5
        gy_center = my + 4.5
        cx_img, cy_img = grid_to_image_mesh(mesh, gx_center, gy_center)

        # Zone de zoom : 3 micro-blocs en X, 3 en Y pour voir le contexte
        zoom_half = int(round(scale * 18))  # 18 points de grille de chaque cote
        cx_int = int(round(cx_img))
        cy_int = int(round(cy_img))
        x_lo = max(0, cx_int - zoom_half)
        x_hi = min(w, cx_int + zoom_half)
        y_lo = max(0, cy_int - zoom_half)
        y_hi = min(h, cy_int + zoom_half)

        # Extraire la region en binaire et la convertir en RGB
        region_bin = binary[y_lo:y_hi, x_lo:x_hi]
        # Remplir en 255 (blanc) ou 0 (noir)
        region_gray = (region_bin.astype(np.uint8) * 255)
        img_zoom = _Image.fromarray(region_gray).convert('RGB')
        draw = _ID.Draw(img_zoom)

        # Trouver les micro-blocs qui chevauchent cette zone (par position image)
        # On parcourt quelques indices autour de micro_idx
        search_range = range(max(0, micro_idx - 50), min(n_micros, micro_idx + 50))
        for mi in search_range:
            mmx, mmy = micro_positions[mi]
            # Tester si le centre de ce micro est dans la zone
            gxc = mmx + 4.5
            gyc = mmy + 4.5
            pxc, pyc = grid_to_image_mesh(mesh, gxc, gyc)
            if not (x_lo - 10 <= pxc <= x_hi + 10 and y_lo - 10 <= pyc <= y_hi + 10):
                continue

            # 1) Plafond : 9 points en (mmx..mmx+8, mmy) -- BLEU
            for bit_idx in range(9):
                gx = mmx + bit_idx
                gy = mmy
                px, py = grid_to_image_mesh(mesh, gx, gy)
                sx = int(round(px)) - x_lo
                sy = int(round(py)) - y_lo
                if 0 <= sx < region_gray.shape[1] and 0 <= sy < region_gray.shape[0]:
                    draw.point((sx, sy), fill='blue')
                    # Petit +
                    if 0 <= sx-1 < region_gray.shape[1]: draw.point((sx-1, sy), fill='blue')
                    if 0 <= sx+1 < region_gray.shape[1]: draw.point((sx+1, sy), fill='blue')
                    if 0 <= sy-1 < region_gray.shape[0]: draw.point((sx, sy-1), fill='blue')
                    if 0 <= sy+1 < region_gray.shape[0]: draw.point((sx, sy+1), fill='blue')

            # 2) Colonne N (bits de synchro) : 8 points en (mmx, mmy+1+r) -- VERT
            for row in range(DATA_ROWS):
                gx = mmx
                gy = mmy + 1 + row
                px, py = grid_to_image_mesh(mesh, gx, gy)
                sx = int(round(px)) - x_lo
                sy = int(round(py)) - y_lo
                if 0 <= sx < region_gray.shape[1] and 0 <= sy < region_gray.shape[0]:
                    draw.point((sx, sy), fill='lime')
                    if 0 <= sx-1 < region_gray.shape[1]: draw.point((sx-1, sy), fill='lime')
                    if 0 <= sx+1 < region_gray.shape[1]: draw.point((sx+1, sy), fill='lime')

            # 3) Bits de donnees : 64 points en (mmx+1..mmx+8, mmy+1..mmy+8) -- ROUGE
            for row in range(DATA_ROWS):
                for bit in range(DATA_BITS):
                    gx = mmx + 1 + bit
                    gy = mmy + 1 + row
                    px, py = grid_to_image_mesh(mesh, gx, gy)
                    sx = int(round(px)) - x_lo
                    sy = int(round(py)) - y_lo
                    if 0 <= sx < region_gray.shape[1] and 0 <= sy < region_gray.shape[0]:
                        draw.point((sx, sy), fill='red')

        out_path = _os.path.join(debug_dir, f"debug_sampling_{tag}.png")
        img_zoom.save(out_path)
        print(f"    {out_path} (pleine res, bleu=plafond, vert=N, rouge=bits)")


# =============================================================================
# VERIFICATION PAR LES REPERES CONNUS
# =============================================================================

def verify_sync_bits(binary, mesh, scale, max_micros=100):
    """Verifie les bits de synchro (plafonds N) pour estimer la qualite du calage.
    Utilise le maillage bilineaire.

    Un micro-bloc a la ligne 0 entierement noire (plafond) et la colonne
    gauche (bit N) de chaque ligne noire aussi. On teste les N de quelques
    micro-blocs.
    """
    micro_positions = compute_micro_positions()
    h, w = binary.shape
    sample_radius = max(1, int(round(scale * 0.35)))

    correct = 0
    total = 0
    for mx, my in micro_positions[:max_micros]:
        for row in range(DATA_ROWS):
            # Le bit N de chaque ligne de donnees est a (mx, my + 1 + row)
            gx = float(mx)
            gy = float(my + 1 + row)
            px, py = grid_to_image_mesh(mesh, gx, gy)
            ix, iy = int(round(px)), int(round(py))

            black_count = 0
            count = 0
            for dy in range(-sample_radius, sample_radius + 1):
                for dx in range(-sample_radius, sample_radius + 1):
                    sx, sy = ix + dx, iy + dy
                    if 0 <= sx < w and 0 <= sy < h:
                        if not binary[sy, sx]:
                            black_count += 1
                        count += 1
            if count > 0 and black_count > count // 2:
                correct += 1
            total += 1

    accuracy = correct / max(1, total)
    print(f"  Verification synchro : {correct}/{total} ({100*accuracy:.1f}%)")
    return accuracy


# =============================================================================
# MAIN
# =============================================================================

def main():
    if len(sys.argv) < 3:
        print("Usage: grid_decode.py SCAN_IMAGE OUTPUT_FILE [--debug DEBUG_DIR]")
        sys.exit(1)

    scan_path = sys.argv[1]
    output_path = sys.argv[2]
    debug_dir = None
    if '--debug' in sys.argv:
        idx = sys.argv.index('--debug')
        if idx + 1 < len(sys.argv):
            debug_dir = sys.argv[idx + 1]
            os.makedirs(debug_dir, exist_ok=True)

    print(f"=== grid_decode.py ===")
    print(f"Image : {scan_path}")

    # 1. Charger
    print("\n1. Chargement...")
    gray = load_and_preprocess(scan_path)
    scan_h, scan_w = gray.shape
    print(f"  Dimensions : {scan_w} x {scan_h} pixels")

    # 3. Detecter les V2 sur l'image en niveaux de gris
    print("\n3. Detection des lignes V2 (verticales)...")
    v2_centers = find_v2_lines(gray)

    # Si mode debug ou pas assez de V2, sauver les images annotees
    if debug_dir or len(v2_centers) != 23:
        if not debug_dir:
            debug_dir = "decode_dbg"
            os.makedirs(debug_dir, exist_ok=True)

        print(f"\n   Sauvegarde du debug V2 dans {debug_dir}/")
        from PIL import ImageDraw as ID

        # --- Image DoG de toute la page (reduite pour la taille) ---
        # Estimer l'echelle pour les parametres DoG
        rough_spacings = [v2_centers[i+1] - v2_centers[i]
                          for i in range(len(v2_centers)-1)]
        if rough_spacings:
            scale_rough = sorted(rough_spacings)[len(rough_spacings)//2] / 88.0
        else:
            scale_rough = scan_w / 2000.0
        sigma1 = scale_rough * 2.8
        sigma2 = 0.5

        # Calculer le DoG sur une version reduite (facteur 4) pour economiser la memoire
        dog_scale = 4
        gray_small = gray[::dog_scale, ::dog_scale]
        dog_img = dog_filter(gray_small, sigma1 / dog_scale, sigma2 / dog_scale)
        # Normaliser pour l'affichage : centrer sur 128, etaler
        dog_min = np.min(dog_img)
        dog_max = np.max(dog_img)
        if dog_max - dog_min > 0:
            dog_norm = ((dog_img - dog_min) / (dog_max - dog_min) * 255).astype(np.uint8)
        else:
            dog_norm = np.full_like(dog_img, 128, dtype=np.uint8)
        dog_pil = Image.fromarray(dog_norm, 'L')
        dog_path = os.path.join(debug_dir, "debug_dog.png")
        dog_pil.save(dog_path)
        print(f"   {dog_path} (DoG sigma1={sigma1:.1f} sigma2={sigma2:.1f}, reduit x{dog_scale})")

        # --- Image V2 lines en pleine resolution (crop central pour la taille) ---
        # On sauve juste un bandeau horizontal au milieu de l'image
        # avec les lignes rouges, pour verifier le centrage pixel par pixel
        mid_y = scan_h // 2
        band_h = min(200, scan_h // 4)
        y_lo = mid_y - band_h // 2
        y_hi = mid_y + band_h // 2
        band_gray = gray[y_lo:y_hi, :]
        img_band = Image.fromarray(band_gray).convert('RGB')
        draw_band = ID.Draw(img_band)
        for vx in v2_centers:
            ix = int(round(vx))
            draw_band.line([(ix, 0), (ix, band_h - 1)], fill='red', width=3)
        band_path = os.path.join(debug_dir, "debug_v2_band_fullres.png")
        img_band.save(band_path)
        print(f"   {band_path} (bande pleine resolution y={y_lo}-{y_hi})")

        # --- Image V2 lines reduite (vue d'ensemble) ---
        debug_scale = 4
        small_w = scan_w // debug_scale
        small_h = scan_h // debug_scale
        img_small = Image.fromarray(gray).resize((small_w, small_h))
        img_debug = img_small.convert('RGB')
        draw = ID.Draw(img_debug)
        for vx in v2_centers:
            ix = int(round(vx / debug_scale))
            draw.line([(ix, 0), (ix, small_h - 1)], fill='red', width=3)
        debug_path = os.path.join(debug_dir, "debug_v2_lines.png")
        img_debug.save(debug_path)
        print(f"   {debug_path} (vue d'ensemble reduite x{debug_scale})")

        if len(v2_centers) != 23:
            print(f"\n   ARRET : {len(v2_centers)} V2 detectees au lieu de 23.")
            print(f"   Verifiez les images de debug et ajustez les parametres.")
            sys.exit(1)

    # 4. Binariser (utilise pour le fallback H2 et pour sample_bits)
    print("\n4. Binarisation (Sauvola)...")
    binary = binarize_sauvola(gray)
    print(f"  Pixels blancs : {np.sum(binary)} / {binary.size} ({100*np.sum(binary)/binary.size:.1f}%)")

    # 5. Detection directe des croix le long des bandes V2
    #    (chaque V2 est echantillonnee verticalement, on y cherche les 33 croix)
    print("\n5. Localisation des croix sur les bandes V2...")
    crosses_array, scale_est, grid_top_v2, grid_bot_v2 = find_crosses_on_v2_bands(
        gray, binary, v2_centers, debug_dir=debug_dir)

    n_found = int(np.sum(~np.isnan(crosses_array[:, :, 0])))
    n_total = crosses_array.shape[0] * crosses_array.shape[1]
    if n_found < 20:
        print("  ERREUR : pas assez de croix detectees pour le calage")
        sys.exit(1)

    # 6. Construction du maillage bilineaire a partir des croix
    # Le maillage est etendu avec 2 lignes virtuelles (gy=0 et gy=2784)
    # ancrees sur les positions sub-pixel mesurees du haut/bas de grille,
    # pour corriger l'extrapolation dans les sections 1 et 34.
    print("\n6. Construction du maillage bilineaire...")
    mesh = build_mesh(crosses_array, grid_top_v2, grid_bot_v2)
    mesh_err = mesh_residuals(mesh, crosses_array)
    print(f"  Controle : erreur max aux noeuds reels = {mesh_err:.4f} px (doit etre ~0)")

    # 7. Diagnostic : affiner par rapport au modele affine global
    # (uniquement pour mesurer l'ampleur de la distorsion non-lineaire)
    print("\n7. Diagnostic : modele affine global (pour reference)...")
    transform_affine = fit_affine_transform(crosses_array)

    # 8. Verification des reperes N (plafonds des micro-blocs)
    print("\n8. Verification des reperes (bits de synchro)...")
    accuracy = verify_sync_bits(binary, mesh, scale_est)
    if accuracy < 0.8:
        print("  ATTENTION : calage potentiellement mauvais (< 80% de synchro correcte)")

    # 9. Echantillonnage des bits via le maillage
    print("\n9. Echantillonnage des bits (maillage bilineaire)...")
    data = sample_bits(binary, mesh, scale_est, debug_dir)

    # 10. Ecriture
    print(f"\n10. Ecriture...")
    with open(output_path, 'wb') as f:
        f.write(data)
    print(f"  Fichier ecrit : {output_path} ({len(data)} octets)")

    # 11. Debug final (overlay global)
    if debug_dir:
        print(f"\n11. Overlay final dans {debug_dir}/")
        from PIL import ImageDraw as ID
        debug_scale = 4
        small_w = scan_w // debug_scale
        small_h = scan_h // debug_scale
        img_small = Image.fromarray(gray).resize((small_w, small_h))
        img_debug = img_small.convert('RGB')
        draw = ID.Draw(img_debug)

        # Lignes V2 en rouge fin
        for vx in v2_centers:
            ix = int(round(vx / debug_scale))
            draw.line([(ix, 0), (ix, small_h - 1)], fill='red', width=1)

        # Croix detectees en vert
        for vi in range(crosses_array.shape[0]):
            for hi in range(crosses_array.shape[1]):
                y, x = crosses_array[vi, hi]
                if np.isnan(y) or np.isnan(x):
                    continue
                sx = int(x / debug_scale)
                sy = int(y / debug_scale)
                r = max(2, int(scale_est * 1.5 / debug_scale))
                draw.ellipse([sx-r, sy-r, sx+r, sy+r], outline='lime', width=1)

        debug_path = os.path.join(debug_dir, "debug_overlay.png")
        img_debug.save(debug_path)
        print(f"  {debug_path}")

    print("\nTermine.")


if __name__ == "__main__":
    main()
