"""
Diagnostic : identifier les croix aux residus les plus importants
par rapport au modele affine global.

Usage: python3 diag_crosses.py <scan_image.png>
"""
import sys
import os
import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from grid_decode import (load_and_preprocess, binarize_sauvola,
                          find_v2_lines, find_crosses_on_v2_bands,
                          compute_h2_centers_y, compute_v2_centers_x,
                          fit_affine_transform, grid_to_image)

if len(sys.argv) < 2:
    print("Usage: python3 diag_crosses.py <scan_image.png>")
    sys.exit(1)

img_path = sys.argv[1]
print(f"Analyse de {img_path}...")

gray = load_and_preprocess(img_path)
binary = binarize_sauvola(gray)
v2 = find_v2_lines(gray)
crosses, scale = find_crosses_on_v2_bands(gray, binary, v2)

# Fit affine
transform = fit_affine_transform(crosses)

# Residu de chaque croix
v2x = compute_v2_centers_x()
h2y = compute_h2_centers_y()

residuals = []
for vi in range(crosses.shape[0]):
    for hi in range(crosses.shape[1]):
        y_det = crosses[vi, hi, 0]
        x_det = crosses[vi, hi, 1]
        if np.isnan(y_det):
            continue
        gx = v2x[vi]
        gy = h2y[hi]
        px_pred, py_pred = grid_to_image(transform, gx, gy)
        err = np.hypot(px_pred - x_det, py_pred - y_det)
        residuals.append((vi, hi, err, x_det, y_det, px_pred, py_pred))

# Tri par erreur decroissante
residuals.sort(key=lambda r: -r[2])

print()
print("20 croix avec les plus gros residus (modele affine):")
print(f"{'vi':>3} {'hi':>3} {'err(px)':>8} {'x_det':>10} {'y_det':>10} {'x_pred':>10} {'y_pred':>10}")
for (vi, hi, err, xd, yd, xp, yp) in residuals[:20]:
    print(f"{vi:3d} {hi:3d} {err:8.2f} {xd:10.2f} {yd:10.2f} {xp:10.2f} {yp:10.2f}")

print()
print("Distribution des residus :")
errs = np.array([r[2] for r in residuals])
print(f"  Nombre     : {len(errs)}")
print(f"  Moyenne    : {np.mean(errs):.2f} px")
print(f"  Mediane    : {np.median(errs):.2f} px")
print(f"  Max        : {np.max(errs):.2f} px")
print(f"  p50/p90/p99: {np.percentile(errs, 50):.2f} / {np.percentile(errs, 90):.2f} / {np.percentile(errs, 99):.2f}")

# Grouper les residus par hi (ligne H2)
print()
print("Residus moyens par ligne H2 (hi=0 et hi=34 sont les extras):")
for hi in range(crosses.shape[1]):
    errs_hi = [r[2] for r in residuals if r[1] == hi]
    if errs_hi:
        print(f"  hi={hi:2d}: mean={np.mean(errs_hi):6.2f}, max={np.max(errs_hi):6.2f}, n={len(errs_hi)}")

# Grouper par vi (V2)
print()
print("Residus moyens par V2 (vi=0 V2 gauche, vi=22 V2 droite):")
for vi in range(crosses.shape[0]):
    errs_vi = [r[2] for r in residuals if r[0] == vi]
    if errs_vi:
        print(f"  vi={vi:2d}: mean={np.mean(errs_vi):6.2f}, max={np.max(errs_vi):6.2f}")
