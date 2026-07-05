<!-- À insérer dans LLIR_REFERENCE.md, section des opérations de bloc,
     à côté de BLKMOV. Ajouts de la campagne 3.6 (4–5 juillet 2026). -->

| Op | Pile | Description |
|---|---|---|
| `CLAMP0` | n → max(0,n) | Borne à 0 tout compte d'éléments dynamique (piège n° 52). |
| `BLKCMP` | @A, LEN, @B → 0/1 | Égalité de blocs, LEN octets (ZF armé par xor pour LEN=0). Longueurs supposées égales — testées en amont. |
| `LEXCMP siz,sgn` | @G, LEN_G, @D, LEN_D → {−1,0,+1} | Ordre lexicographique LRM 4.5.2. Itère par composant de `siz` octets (1/2/4/8), normalisés 64 bits (`movsx` si `sgn`=1, `movzx` sinon) ; règle du préfixe à l'épuisement. Consommé par `LI 0` + `CLT/CLE/CGT/CGE`. Longueurs en octets, ≥ 0. |
| `BLKAND` | @DST, LEN, @SRC → | `[DST] and= [SRC]` octet à octet (BOOLEAN 0/1, LRM 4.5.1). DST contient déjà la copie de l'opérande gauche. |
| `BLKOU` | @DST, LEN, @SRC → | Idem, `or=`. |
| `BLKOUX` | @DST, LEN, @SRC → | Idem, `xor=`. |
| `BLKNOT` | @DST, LEN → | NOT composite : chaque octet `^= 1` (NOT booléen 0/1, piège n° 5 — pas 0xFF). |

Tous détruisent RAX/RCX/RSI/RDI (LEXCMP aussi RBX/RDX), comme BLKMOV.
