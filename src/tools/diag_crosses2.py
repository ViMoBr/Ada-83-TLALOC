"""
Diagnostic : voir les positions des premieres croix (hi=0..4) de chaque V2.
On attend un pas regulier de ~385 px entre croix consecutives.
"""
import sys, os
import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from grid_decode import (load_and_preprocess, binarize_sauvola,
                          find_v2_lines, find_crosses_on_v2_bands)

if len(sys.argv) < 2:
    print("Usage: python3 diag_crosses2.py <scan_image.png>")
    sys.exit(1)

gray = load_and_preprocess(sys.argv[1])
binary = binarize_sauvola(gray)
v2 = find_v2_lines(gray)
crosses, scale = find_crosses_on_v2_bands(gray, binary, v2)

print()
print("Positions Y des premieres croix (hi=0..4) par V2 :")
print("Pas attendu entre croix consecutives = 385.6 px (1200 dpi)")
print()
print(f"{'vi':>3} | {'hi=0':>8} | {'hi=1':>8} | {'hi=2':>8} | {'hi=3':>8} | {'hi=4':>8} | pas_01 | pas_12 | pas_23 | pas_34")
for vi in range(23):
    ys = [crosses[vi, hi, 0] for hi in range(5)]
    pas = [ys[i+1] - ys[i] for i in range(4)]
    print(f"{vi:3d} | {ys[0]:8.1f} | {ys[1]:8.1f} | {ys[2]:8.1f} | {ys[3]:8.1f} | {ys[4]:8.1f} | "
          f"{pas[0]:6.1f} | {pas[1]:6.1f} | {pas[2]:6.1f} | {pas[3]:6.1f}")

print()
print("Positions Y des dernieres croix (hi=30..34) par V2 :")
print()
print(f"{'vi':>3} | {'hi=30':>8} | {'hi=31':>8} | {'hi=32':>8} | {'hi=33':>8} | {'hi=34':>8} | pas_30_31 | pas_31_32 | pas_32_33 | pas_33_34")
for vi in range(23):
    ys = [crosses[vi, hi, 0] for hi in range(30, 35)]
    pas = [ys[i+1] - ys[i] for i in range(4)]
    print(f"{vi:3d} | {ys[0]:8.1f} | {ys[1]:8.1f} | {ys[2]:8.1f} | {ys[3]:8.1f} | {ys[4]:8.1f} | "
          f"{pas[0]:9.1f} | {pas[1]:9.1f} | {pas[2]:9.1f} | {pas[3]:9.1f}")
