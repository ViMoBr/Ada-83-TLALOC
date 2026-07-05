# ORACLES — programmes-témoins et sorties attendues

Contrat du filet (piège n° 51) : l'ACVC classe A ne protège pas la sémantique ;
seuls ces programmes à sortie attendue le font. Toute campagne close ajoute ici
son témoin. Filet complet = modules du compilateur + ACVC A2..A8 + ces témoins
+ auto-compilation.

## 9. Programmes de test — résultats validés

### IO_TEST (sections 1-11, entiers et fichiers)

```
=== 1. Ecriture fichier ===          CREATE + PUT + NEW_LINE + CLOSE
=== 2. Relecture fichier ===         OPEN + GET_LINE + CLOSE
=== 3. SET_OUTPUT fichier ===        SET_OUTPUT + PUT_LINE + NEW_LINE
=== 4. Relecture io_def.dat ===      Relecture fichier écrit via défaut
=== 5. INTEGER_IO bases ===          PUT base 10/16/2/8, négatifs, WIDTH, zéro
=== 6. INTEGER_IO dans fichier ===   PUT(FILE) + relecture
=== 7. RESET fichier ===             CREATE + RESET(IN_FILE) + GET_LINE
=== 8. SKIP_LINE ===                 SKIP_LINE(1) + SKIP_LINE(1)
=== 9. NEW_PAGE ===                  NEW_PAGE + SKIP_PAGE + GET_LINE
=== 10. END_OF_FILE ===              Lecture directe 3 lignes
=== 11. END_OF_FILE boucle ===       while not END_OF_FILE loop
```

### FLOAT_TEST (session 11 avril, 22 tests + defaults)

```
=== 1-7 ===                          Constantes, arithmétique, comparaisons, conversions
=== FIN ===                          22 tests validés
```

### ENUM_TEST (sessions 15 et 25 avril, 17 sections)

```
=== 1. PUT basique ===               BLEU BLANC ROUGE
=== 2. PUT avec WIDTH ===            [      BLEU] [     ROUGE]
=== 3. PUT LOWER_CASE ===            bleu blanc rouge
=== 4. PUT via variable ===          BLANC ROUGE
=== 5. PUT sans FILE ===             BLEU
=== 6. Type JOUR ===                 LUNDI MERCREDI DIMANCHE
=== 7. JOUR WIDTH+LOWER_CASE ===     [      samedi]
=== 8. FILE_MODE ===                 IN_FILE OUT_FILE
=== 9. Boucle couleurs ===           BLEU BLANC ROUGE
=== 10. Boucle jours ===             LUNDI..DIMANCHE (WIDTH=10)
=== 11. GET fichier ===              Lu 1: ROUGE  Lu 2: BLANC  Lu 3: BLEU
=== 12. GET casse mixte ===          Rouge→ROUGE  blanc→BLANC  BLEU→BLEU
=== 13. GET JOUR ===                 LUNDI  vendredi→VENDREDI  Dimanche→DIMANCHE
=== 14. Roundtrip PUT-GET ===        BLEU BLANC ROUGE
=== 15. Roundtrip JOUR ===           LUNDI..DIMANCHE (7 jours)
=== 16. Boucle GET couleurs ===      ROUGE BLEU BLANC
=== 17. GET console ===              rouge → ROUGE
```


### DIRECT_IO_TEST (session 10 mai (1), scalaire LONG_FLOAT)

```
LONG_FLOAT SIZE = 64 bits
create+write+close ok / open in_file ok
read seq #1/#2/#3 : 3.1415 / 6.5 / -2.25
read positioned #2/#3 : 6.5 / -2.25
open inout_file ok / rewrite position 2 ok
size after rewrite = 3
final #1/#2/#3 : 3.1415 / 3.1415 / -2.25
```

### DIRECT_IO_TEST2 (sessions 10 mai (1) et 10 mai (2), tous types)

```
=== 1. COULEUR (énuméré, 8 bits) ===   5 writes, seq + positioned, ok
=== 2. POINT (record 3 INTEGER) ===    4 writes, seq + positioned, ok
=== 3. VECTEUR (array 1..4 INTEGER) == 3 writes, seq + positioned, ok
=== 4. SET_INDEX + END_OF_FILE ===     SET_INDEX(4), EOF avant/après lecture, retour début, ok
=== 5. RESET + réécriture partielle == INOUT_FILE, rewrite pos 2+4 (variable en bloc declare), ok
=== 6. IS_OPEN ===                     FALSE après CLOSE, TRUE après OPEN, ok
=== 7. Boucle END_OF_FILE ===          parcours séquentiel VECTEUR, 3 éléments, ok
=== 8. DELETE ===                      3 fichiers supprimés, ok
```

Fichier `point_direct.dat` après 4 writes (hexdump vérifié) :
```
0001 0000  0002 0000  0003 0000   → X=1,  Y=2,  Z=3   (P1)
0010 0000  0020 0000  0040 0000   → X=16, Y=32, Z=64  (P2)
fffb ffff  0000 0000  0063 0000   → X=-5, Y=0,  Z=99  (P3)
002a 0000  ffff ffff  0007 0000   → X=42, Y=-1, Z=7   (P4)
```

Note : agrégats nommés en position de paramètre (`(X=>777,Y=>888,Z=>999)`)
non encore compilables — contournement par variable intermédiaire déclarée
dans un bloc `declare`.

### SEQ_IO_TEST (session 10 mai (3), tous types)

```
=== 1. COULEUR (énuméré, 8 bits) ===   5 writes, 3 reads seq, ok
=== 2. POINT (record 3 INTEGER) ===    3 writes, 3 reads seq, ok
=== 3. VECTEUR (array 1..4 INTEGER) == 3 writes, 3 reads seq, ok
=== 4. END_OF_FILE + boucle ===        EOF=FALSE au début, boucle 3 éléments, EOF=TRUE après, ok
=== 5. RESET ===                       relecture depuis le début après RESET, ok
=== 6. IS_OPEN ===                     FALSE après CLOSE, TRUE après OPEN, ok
=== 7. MODE ===                        IN_FILE et OUT_FILE corrects (CREATE pour OUT_FILE), ok
=== 8. DELETE ===                      4 fichiers supprimés, ok
```


### ARRAY_TEST1 v2 (pilier 3.6, sessions 4–5 juillet, 9 sections)

Contraint 1D (indexation, FIRST/LAST/LENGTH), agrégats (positionnel, range,
others), matrice 2D et attributs dimensionnés, index par énuméré, STRING
(littéral, caténation), tranches (lecture, affectation, paramètre), paramètres
et fonction non contraints, 'RANGE à préfixe objet, 'IMAGE.
**Sortie attendue** (repères) : §1 `1 9 25 1 5 5` ; §3 `14 24 35 3 2 1 4 3 5` ;
§5 `GHIJKL / ABCDEFGHIJKL / GHIJKLABCDEF` ; §6 `DEFGHI GHIDEF XYZJKL DEFGHI 2 5 4 [BCDE]` ;
§7 `... [DEFGHI] 1 7 7 [BONJOUR] 150 18` ; §8 `150` ; §9 `42`.
Vert intégral le 5 juillet 2026.

### ARRAY_TEST2 v2 (pilier 3.6, sessions 4–5 juillet, sections D1–D9)

Opérateurs et formes composites : D7 nuls/CLAMP0, D1 égalité, D2 lexicographique
(7 cas dont témoin signé `(-5,2,3) < (1,2,3)` — protège movsx vs movzx),
D3 logiques booléens (and/or/xor/not composites), D4 caténation toutes formes,
D5 conversion, D8 retour de tranche, D9 agrégats qualifiés + VEC3'RANGE.
**Sortie attendue** : D7 `0 0 3 2 0 [] ABCDEFGHIJKL ABCDEFGHIJKL ABCDEF` ;
D1 `VRAI FAUX VRAI FAUX VRAI FAUX` ; D2 `VRAI ×7` ;
D3 `VRAI FAUX VRAI FAUX VRAI FAUX FAUX VRAI` ; D4 `XAB ABY XY XABYAB` ;
D5 `100 300 11 13 100` ; D8 `ONT BCDE` ; D9 `3 4 9 0 9 5 8 1 3`.
Vert intégral le 5 juillet 2026.

### État ACVC (5 juillet 2026)

Modules du compilateur : compilent et s'exécutent. Séries **A2 à A7 : vertes
en totalité**. Série **A8 : 17 tests verts**, échecs restants consignés
(renommage, use, portée, visibilité — hypothèse causes-mères communes,
cf. point de méthode du 4 juillet). Auto-compilation : verte après lot D2
(les comparaisons STRING du compilateur passaient auparavant par le stub).

### RECORD_TEST1 (pilier 3.7, lot R-A) 
— sortie attendue intégrale :
R1 `5 30 9` ; R2 `3 7` ; R3 `42 43 0 2` ; R4 `200 VRAI FAUX` ;
R5 `17 3 6 2` ; R6 `6 40 41 5` ; R7 `2 15` ; bannières comprises.
Couvre : élaboration des discriminants (contrainte normalisée), agrégats
positionnels/nommés avec discriminants et variantes (marcheur canonique
SM_NORMALIZED_COMP_S), affectation complète et égalité BLKCMP (sans
variantes), composant record de record (W.P) et de tableau (ARR de BUF(2)),
paramètres in/in out et retour de fonction record contraint, discriminant
en borne de boucle.
