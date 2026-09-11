#!/usr/bin/env python3
"""Profil plat par sous-programme TLALOC.
Usage : perf script -i t1.data -F ip | python3 perfmap.py arm64map.txt
Le map est celui de fasmg (lignes 'NOM_Lnn 0x...' ; les lignes 'var elab' et
'disp' sont ignorees) ; les 'including sub unit X.FINC' donnent l'unite."""
import sys, re

funcs = []          # (adresse, nom, unite)
unit = '?'
for line in open(sys.argv[1], encoding='latin-1'):
    m = re.match(r'including sub unit\s+(\S+)', line.strip())
    if m:
        unit = m.group(1); continue
    m = re.match(r'^(\S+)\s+0x([0-9A-Fa-f]+)\s*$', line.strip())
    if m and not line.startswith(' ') and not line.startswith('var '):
        funcs.append((int(m.group(2), 16), m.group(1), unit))
funcs.sort()
addrs = [f[0] for f in funcs]

import bisect
hist = {}
total = 0
for line in sys.stdin:
    t = line.split()
    if not t: continue
    try: ip = int(t[-1], 16)
    except ValueError: continue
    i = bisect.bisect_right(addrs, ip) - 1
    key = funcs[i][1] + '  [' + funcs[i][2] + ']' if i >= 0 else '?'
    hist[key] = hist.get(key, 0) + 1
    total += 1

print('%d echantillons' % total)
cum = 0
for k, n in sorted(hist.items(), key=lambda x: -x[1])[:40]:
    cum += n
    print('%6.2f %%  %6.2f %%  %-40s' % (100.0 * n / total, 100.0 * cum / total, k))
