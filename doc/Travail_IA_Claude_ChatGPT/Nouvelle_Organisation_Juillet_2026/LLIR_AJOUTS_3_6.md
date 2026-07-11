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

<!-- Ajouts session 9 juillet 2026 (2) — série a8. -->

| Op | Pile | Description |
|---|---|---|
| `LSPA prefix, subname` | → @elab | Load SubProgram Address : empile l'adresse de `prefix#subname.elab` ET arme la garde d'assemblage paresseux `prefix#subname#_` (postpone, même mécanisme que CALL). Obligatoire pour toute prise d'adresse de sous-programme (actuels génériques). Un LCA nu sur un `.elab` = piège n° 83. |

**BLOC_DEF refondu** (codi + CODE_ENUMERATION_DECL) :
`BEGIN_BLOC_DEF` (sans argument) ouvre le bloc d'images d'un énuméré —
données `db` INLINE protégées par `BRA IMAGES.skip`, noms fixes sous
`IMAGES.` (unicité par le namespace `_TYPE`) ; `END_BLOC_DEF siz,fst,lst`
pose le ENUM_USE_INFO étendu, layout contractuel : `SIZ@0 (dd) | FST@+4 |
LST@+8 | pad | IMAGES.data_ptr@+16 (dq) | IMAGES.info_ptr@+24` ;
`use__info` pointe SIZ ; TEXT_IO (GET_ENUM_IMAGES) lit le doublet à
__u+16. Supprimés : struc `BYTES_BLOC`, instanciation `IMAGES
BYTES_BLOC`, les trois `CST` et le triplet `postpone align_q` dans ce
chemin. Macros ordinaires (ni « ! », ni capture, ni postpone) : saines
sous `if defined` (pièges n° 86-87). Gardien : ENUM_TEST.

## Pilier checks (11 juillet 2026)

- ce_raise_ / ne_raise_ : trampolines uniques par exécutable (wrapper,
  région inatteignable) — posent l'identité prédéfinie et BRA
  exc_raise_. Sites : BT/BF STANDARD.ce_raise_ (ou ne_raise_).
- Idiome de check scalaire (valeur PRÉSERVÉE au sommet) :
  DUP ; <borne FST> ; CLT ; BT ce_raise_ ; DUP ; <borne LST> ; CGT ;
  BT ce_raise_ — effet de pile net nul, insérable entre évaluation et
  consommation. Bornes par la MÊME séquence que l'usage voisin
  (frame _SUBTYPE.FST/LST, descripteur .FST_n, use-info via GFP).
- Division par zéro : DUP ; LI 0 ; CEQ ; BT ne_raise_ avant DIV/MODI/
  REMI utilisateur.
- BT et BF : rel32 SYSTÉMATIQUE (comme BRA) — piège n° 82. Le retour
  du rel8 appartient à un futur optimiseur MONOTONE.
- Ordre wrapper : LINK 0, loc_siz AVANT include _STANDRD.FINC
  (piège n° 83).
- Règle générale (arbitrage Q2) : LLIR EXPLICITE maximale dans les
  FINC, pas de macro d'abréviation — matériau de l'optimiseur futur.