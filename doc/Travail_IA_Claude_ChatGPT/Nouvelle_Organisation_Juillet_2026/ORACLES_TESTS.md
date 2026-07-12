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

11/7/2026 FLOAT_TEST réintègre le filet — c'était le seul témoin relisant des locales de type formel dans un corps partagé, absent depuis avril ; INTEGER_IO ne peut pas jouer ce rôle (zéro occurrence, preuve par le grep).

### ENUM_TEST (pilier 3.7 → refonte auto-jugeante, 5 juillet 2026, 41 assertions)

Témoin converti au format auto-jugeant : chaque valeur produite est vérifiée
par CHECK(condition, section, numéro) ; verdict final greppable.
RESULTAT :  41 OK,   0 ECHECS
ENUM_TEST PASSE

Oracle du filet = la ligne `ENUM_TEST PASSE` (absence = régression, avec
`* ECHEC section S test N` pour localiser). La section console (17) suit le
verdict : `console OK` si l'entrée pipée est « rouge ».

Sections visuelles résiduelles (cadrage console non capturable en chaîne,
déviation RM 14.3.9 consignée — cadrage à DROITE, blancs de tête) :
=== V2. PUT avec WIDTH ===     [      BLEU] [     ROUGE]
=== V7. JOUR WIDTH+LOWER_CASE === [      samedi]
=== V10. Boucle jours WIDTH=10 ===     LUNDI     MARDI  MERCREDI  …  DIMANCHE
Couvre : PUT vers chaîne (littéraux, LOWER_CASE, via variable, FILE_MODE,
cadrage à gauche conforme), GET fichier/casse mixte/JOUR, roundtrips
couleurs et jours, boucle GET en ordre non déclaratif, GET chaîne (token,
casse, index de fin L), attributs 'FIRST/'LAST/'POS.

Mise à jour ENUM_TEST : la note « Sections visuelles résiduelles
(déviation RM 14.3.9 consignée — cadrage à DROITE, blancs de tête) » est
caduque depuis le 8 juillet : le cadrage console est désormais conforme
(blancs de QUEUE). Les sections visuelles montrent le comportement
conforme ; re-vérification visuelle faite au filet du 8 juillet.

- 9 juillet 2026  (41 assertions + vérification console interactive
  « rouge ») : GARDIEN DU CONTRAT ENUM_USE_INFO étendu (SIZ@0, FST@+4,
  LST@+8, doublet images @+16 lu par GET_ENUM_IMAGES). À repasser après
  TOUTE retouche de BLOC_DEF, de CODE_ENUMERATION_DECL ou
  d'ENUMERATION_IO. Attendu : « RESULTAT : 41 OK, 0 ECHECS /
  ENUM_TEST PASSE », plus l'écho console. Vert le 9 juillet (2) après
  refonte BLOC_DEF.

### DIRECT_IO_TEST v2 (refonte auto-jugeante, 9 juillet 2026, 65 assertions)

Conversion au format canonique après le fossile n° 80 (SD -32 → -40,
slot résultat des fonctions en corps générique). Trois instances
(COULEUR énuméré 8 bits, POINT record 96 bits, VECTEUR tableau 128 bits).
S1-S3 roundtrips par égalité composite complète + SIZE (après écriture et
en relecture) + IS_OPEN/MODE ; S2 INDEX = FROM+1 après READ positionné ;
S4 SET_INDEX/INDEX/END_OF_FILE ; S5 RESET + réécriture partielle INOUT
(agrégat qualifié de record en actual) ; S6 boucle `while not END_OF_FILE
loop READ` — idiome SÛR pour DIRECT_IO, positions exactes, pas de
look-ahead (contra piège n° 79) ; S7 extension par WRITE positionné
au-delà de la fin (LRM 14.2), SIZE étendu + trou relu à zéro (fichier
creux Linux) ; S8 exceptions : END_ERROR (séquentiel à EOF, positionné
hors fichier, **élément tronqué** — fichier COULEUR de 5 octets ouvert
par POINT_DIO, verrou du fossile n° 80), MODE_ERROR (READ sur OUT,
END_OF_FILE sur OUT, WRITE sur IN), STATUS_ERROR (READ/SIZE/RESET sur
fichier fermé) ; S9 DELETE ressuscité, jugé par échec de la tentative de
re-OPEN (régime actuel : échec silencieux → IS_OPEN FALSE ; handler
NAME_ERROR accepte d'avance le régime du futur lot 14.2.1).
Crée et supprime ses fichiers *_direct.dat et scratch_direct.dat.
Dernières lignes exactes :
```
RESULTAT :  65 OK,   0 ECHECS
DIRECT_IO_TEST PASSE
```
Oracle du filet = la ligne `DIRECT_IO_TEST PASSE`. Vert intégral le
9 juillet 2026.
Non asserté (dette 14.2.1, gardes absentes des packages) : CREATE/OPEN
sur fichier déjà ouvert → STATUS_ERROR ; échec d'OPEN → NAME_ERROR ;
CLOSE/DELETE sur fichier fermé → STATUS_ERROR.

### SEQ_IO_TEST v2 (refonte auto-jugeante, 9 juillet 2026, 50 assertions)

Jumeau séquentiel de DIRECT_IO_TEST v2, mêmes trois instances.
S1-S3 roundtrips par égalité composite + IS_OPEN/MODE + END_OF_FILE
après le dernier élément ; S4 boucle `while not END_OF_FILE` (idiome
sûr, positions exactes) ; S5 RESET : rembobinage simple puis RESET avec
changement de mode (IN → OUT → IN) en réécriture COMPLÈTE des 5 éléments
en ordre inverse — délibérément indépendant de la sémantique de
troncature de RESET(OUT_FILE), non arbitrée (le corps fait lseek 0 sans
troncature) ; S6 exceptions : END_ERROR (lecture après le dernier
élément, **élément tronqué** — verrou du fossile n° 80), MODE_ERROR
(READ sur OUT, END_OF_FILE sur OUT, WRITE sur IN), STATUS_ERROR
(READ/RESET/MODE sur fichier fermé) ; S7 DELETE jugé par échec de
re-OPEN (NAME_ERROR accepté d'avance, dette 14.2.1).
Crée et supprime ses fichiers *_seq.dat et scratch_seq.dat.
Dernières lignes exactes :
```
RESULTAT :  50 OK,   0 ECHECS
SEQ_IO_TEST PASSE
```
Oracle du filet = la ligne `SEQ_IO_TEST PASSE`. Vert intégral le
9 juillet 2026 (au premier passage).
Même dette 14.2.1 non assertée que DIRECT_IO_TEST v2.

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

- **Série ACVC a8** : verte le 9 juillet (2) à l'exception d'A87B59A
  (assemble, segfaut d'exécution — dette « actuels génériques
  non-sous-programmes », voir ETAT_PILIERS). A83009A/B (BLOC_DEF sous
  garde), A85013B (renamings), A83C01G (préfixe package) sont les
  verrous des pièges n° 81-82, 85-87.
  
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

### RECORD_TEST2 (pilier 3.7, lot R-B)
— sortie attendue intégrale :
E1 `0 77 1` ; E2 `FAUX VRAI` ; E3 `9` ; E4 `0 13` ; E5 `21 2` ;
E6 `55 1` ; E7 `13` ; bannières comprises.
Couvre : défauts de discriminants élaborés (M : MUT → PT = LEAF), mutation
de variante par affectation complète, 'CONSTRAINED par objet (variable
mutable → FAUX, objet contraint → VRAI), agrégat qualifié de record
(doublet anonyme), sous-type contraint d'un type à défauts (MLEAF), mutable
composant de record (BOX.N, taille max), changement de variante à travers
un formel in out, retour de mutable par fonction.

### ARRAY_TEST3 (pilier 3.6 reliquat non contraint, session 6 juillet, sections U1–U9)

Format auto-jugeant (CHECK + verdict greppable « ARRAY_TEST3 PASSE »).
Couvre les 7 trous de NOTE_MODELE_UNCONSTRAINED : U1 attributs sur marque de
sous-type non contraint (VEC5) ; U2 objets contraints d'un type non contraint
(directe, sous-type nommé, 2D) ; U3 objet non contraint initialisé par agrégat
à bornes DÉDUITES (positionnel → INTEGER'FIRST.., nommé → 1..3) ; U4 littéral
chaîne ; U5 STRING(1..N) et STRING(N..2N) dynamiques ; U6 composants non
scalaires (array of constrained array, array of record) ; U7 formels/retours
non contraints, 'LENGTH sur formel, 2D ; U8 retour STRING de longueur calculée
(résultat nommé — contournement dette D10) ; U9 conversion avec glissement
d'indices A3(VC), 7..9.
**Sortie attendue** : les 9 bannières « === Un. ... === » sans aucune ligne
« * ECHEC », puis `RESULTAT :  37 OK,   0 ECHECS` / `ARRAY_TEST3 PASSE`.
**Témoin négatif** (piège n° 67) : deux exécutions consécutives IDENTIQUES —
toute variation run-à-run signe une lecture hors bloc via `__u`.
Historique d'oracle : 7.3 corrigé le 6 juillet (`LONGUEUR(VD) = 3`, et non 4 —
piège n° 68). Vert intégral le 6 juillet 2026.

### EXC_TEST0 (pilier 11, session 7 juillet — témoin d'amorçage, dump DIANA de référence)
Sortie : VIDE. Code retour 0. Trois chemins : handler local apparié (bloc 1),
propagation LEVE → BLOCK__2 (prédéfinie non appariée puis others), frames
frères de même niveau lexical (restauration FP(2) à la bonne incarnation).
Le dump $$$_TREE de ce témoin est la référence des nœuds du pilier.

### EXC_TEST1 (pilier 11, lots E-B/E-C + addendum, 19 assertions auto-jugées)
12 sections : 1 return depuis corps protégé / 2 return depuis handler /
3 exit à travers DEUX blocs protégés (témoin du piège n° 69) / 4 récursion
+ handler levant (CNT=4 incarnations) / 5 handler dans handler /
6 propagation profonde (3 frames) / 7 renames croisés (les deux sens, via
REN0_PACK) / 8 prédéfinies levées à la main / 9 choix multiple E1|E2 /
10 raise nu dont ADVERSARIAUX 10.2-10.3 (exception traitée dans le handler
— par bloc puis par appel — puis `raise;` qui doit relever l'EXTERNE ;
juges du piège n° 75) / 11 exception en ÉLABORATION de bloc → englobant
(LRM 11.4.2) / 12 bloc protégé × 100 000 itérations (anti-fuite).
Sections 1/2/3/6 suivies d'un CONTROLE d'intégrité de la pile des
contextes. Dernières lignes exactes :
```
RESULTAT :  19 OK,   0 ECHECS
EXC_TEST1 PASSE
```
Code retour 0.

### EXC_TEST1U (pilier 11 — témoin PERMANENT de la sentinelle)
Sortie exacte : `EXCEPTION NON RATTRAPEE : PERDUE` (une ligne).
Code retour 1 — LE VÉRIFIER (`$?`), c'est la moitié auto-jugeante.

### EXC_REN0 (pilier 11 — renommage inter-unités, dump de référence SM_RENAMES_EXC)
Deux unités (REN0_PACK + EXC_REN0). Sortie : VIDE. Code retour 0.
Le dump de ce témoin a établi la forme réelle de SM_RENAMES_EXC (piège 71).

### TEXT14 (pilier 14.3, 8 juillet 2026, 42 assertions)

Témoin auto-jugeant de la conformité LRM chapitre 14 de TEXT_IO.
U1 comptabilité COL/LINE en sortie ; U2 SET_COL avant/arrière ;
U3 coupure implicite à LINE_LENGTH bornée + LAYOUT_ERROR ; U4 SET_LINE et
longueur de page ; U5 relecture sur fichier réel (GET à travers les
terminateurs, look-ahead END_OF_LINE traversé par GET(STRING), scanner
entier, GET_LINE, END_ERROR) ; U6 gardes MODE/STATUS/NAME_ERROR ;
U7 DATA_ERROR et LAYOUT_ERROR des variantes chaîne ; U8 cas résiduels
(chaîne nulle, DATA_ERROR fichier, FF devant un entier, END_OF_LINE sur
FF). Crée et supprime ses fichiers TEXT14_*.TXT.
RESULTAT :  42 OK,   0 ECHECS
TEXT14 PASSE
Oracle du filet = la ligne `TEXT14 PASSE`.

### OUTARG1 (correctif expandeur piège n° 77, 8 juillet 2026, 8 assertions)

Verrou de la classe « actual out/in out composé » : composant indexé en
out et in out (indice littéral et calculé), composant sélectionné en out
et in out, boucle sur composant indexé d'un formel non contraint (motif
exact du GET(STRING) public). Indépendant du chemin fichier.
OUTARG1 PASSE
Oracle du filet = la ligne `OUTARG1 PASSE`.

### TEXT14P (sonde, hors filet)

Sonde de bisection à marqueurs séquentiels P00..P20 sur la séquence
écriture → CLOSE → OPEN → relecture. Pas d'oracle : outil de diagnostic à
ressortir quand un chemin d'E/S neuf s'ouvre (piège n° 78).

## Témoins du pilier CHECKS (permanents au filet, checks ON)

CHK_TEST0  — gamme d'affectation (E-A) : 1..5 OK, 6 sentinelle
             CONSTRAINT_ERROR, $? = 1. Contre-épreuve OFF : 2,3,4 KO.
CHK_LEN0   — LEN_G=LEN_D (E-B) : 1..4 OK (dont tranches et tableaux
             nuls), 5 sentinelle CONSTRAINT_ERROR, $? = 1.
CHK_IDX0   — index (E-C) : 1..9 OK (quatre variantes, multi-dim,
             négatif, descripteur), 10 sentinelle, $? = 1.
CHK_TEST1  — gamme six sites (E-D) : 1..5 OK, 6a OK T = 9, 7 OK,
             8 sentinelle CONSTRAINT_ERROR, $? = 1. 6b consigne : la
             violation générique hors bornes reste à outiller.
CHK_DIV0   — division par zéro (E-E) : 1..4 OK (NUMERIC_ERROR et PAS
             CONSTRAINT_ERROR — juge de Q7), 5 sentinelle
             NUMERIC_ERROR, $? = 1.
CHK_ANON0  — piège n° 80 : 1..4 OK, 5 OK-dette (violation anonyme
             SILENCIEUSE — si cette section change, dette soldée ou
             régression : mettre à jour témoin et note).
CHK_CSTPRM0/1/2 — fossile n° 81 (scalaires/composites/privés en
             actuel) : toutes lignes OK, $? = 0.
CHK_PREDEF0 — bornes prédéfinies via use-info + BOOLEAN'IMAGE
             (pièges n° 80-rectif et n° 83) :
             INTEGER -2147483648/2147483647, CHARACTER 0/127,
             BOOLEAN 0/1, IMAGE TRUE FALSE, $? = 0.

Sondes RETIRÉES du filet (diagnostic une-fois, archivées) :
CHK_ANON1/2/2B/3, CHK_DUMP0.

### FIX_TEST1 (12 juillet, pilier fixed — 15 assertions)

```
=== S1. Multiplicatif T(X*Y), T(X/Y), elision FIX.INT ===
=== S2. fixed -> fixed (rescale, identite, troncature) ===
=== S3. Attributs plies, sous-type ===
 T8'AFT (sem-3, attendu 3) =          3        <- AFFICHE non asserte (dette sem-3)
 T8'FORE (sem-3, attendu 3) =          3       <- idem
=== S4. Division fixed par zero -> NUMERIC_ERROR (Q7) ===
RESULTAT :          15 OK,           0 ECHECS
FIX_TEST1 PASSE
```
Oracle : la ligne « FIX_TEST1 PASSE ». Gardiens de troncature vers
zéro : tests 3 (1.59375), 10 (3.75), 11 (-2.25 — un plancher donnerait
-3.0). DÉPEND du régime sem-1 (small = delta/2) : si sem change,
toutes les représentations attendues changent.

### FLOAT_FIXED_IO_TEST (12 juillet — 11 sections, FLOAT_IO + FIXED_IO)

```
=== 1. FLOAT_IO PUT LONG_FLOAT — formats ===   pi 3.141593E+00, grand 1.2346E+15,
                                               petit -4.5679E-08, zero, un, negatif,
                                               FORE pad "   2.50E+00"
=== 2. FLOAT_IO PUT FLOAT ===                  e 2.7183E+00, -1.000E-03
=== 3. FIXED_IO PUT DURATION ===               1.500 / 0.020 / -3.14 / 0.000 / "  12.50"
=== 4-6. FLOAT_IO GET (fichier, WIDTH, console) ===
=== 7-10. FIXED_IO GET (fichier, exposants 2.5E-1 -> 0.2500, WIDTH, console) ===
=== 11. GET roundtrip — deux valeurs sur une ligne ===
=== FIN ===
```
Oracle : sortie complète ci-dessus. Sections 6 et 10 interactives
(entrées : -1.5E+2 et 1.5). Gardien du contrat GFP/adaptateurs
(n° 92) et du calcul FIXED_AFT/FORE d'instanciation (F-4a).

### FLOAT_TEST — RÉINTÉGRÉ AU FILET (12 juillet)

Témoin d'avril, seul à relire des locales de type formel en corps
partagé — son absence du filet a laissé vivre le n° 92 de fin avril à
juillet. Ne plus jamais retirer un témoin sans vérifier qui d'autre
couvre ses chemins.

### TEST_CALENDAR (12 juillet — témoin d'exception 1900/2100 ajouté)

Sections TIME_OF/SPLIT, sélecteurs, rollover minuit, opérateurs
(DELTA_T = 2.500000E-01), journée ordinaire, passage année, HORS GAMME
(1900 -> CONSTRAINT_ERROR OK, 2100 -> CONSTRAINT_ERROR OK), non
bissextile, passage arrière, CLOCK (visuel), cohérence. Conversion au
format CHECK/RESULTAT : à faire à l'occasion (dette de confort, pas de
couverture).