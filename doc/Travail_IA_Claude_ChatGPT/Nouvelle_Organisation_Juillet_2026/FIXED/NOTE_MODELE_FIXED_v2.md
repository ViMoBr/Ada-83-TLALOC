# NOTE DE MODÈLE D'EXÉCUTION — POINTS FIXES (LRM 3.5.9, 4.5.5, 4.6) — v2

**11 juillet 2026 — v2 : dump F-0 LU. Q1, Q2, Q4, Q6 CLOSES.**

Pilier 3.5.9 : seul pilier du tableau portant la mention « partiel » depuis
le 15 mai. Objet de cette note : établir ce qui manque réellement (le constat
est plus large que « mul/div incomplètes »), fixer le modèle d'exécution,
trancher au dump F-0.

**v2 — ce qui a changé depuis v1 :** le dump `FIX_DUMP0` a REFUTÉ
l'hypothèse centrale (§9). `universal_fixed` n'est **jamais matérialisé**
par sem : le `DN_FUNCTION_CALL` d'un `FIX*FIX` ne porte **aucun**
`SM_EXP_TYPE`. Conséquence de conception : **le pilotage de `*`/`/` fixed
passe obligatoirement à `CODE_CONVERSION`** (§3.0). Le modèle de calcul
(§3.1-3.3) survit intact ; c'est la RESPONSABILITÉ qui se déplace.
Piège n° 71, troisième récidive.

---

## 1. Constat d'audit (11 juillet, lecture du code)

### 1.1 Il n'y a pas de code fixed mul/div « incomplet » : il n'y en a AUCUN

Le dispatch binaire (`CODE_DN_BLTN_OPERATOR_ID`, expressions ~3600-3668) ne
connaît que **deux mondes** : `IS_FLOAT` (calculé uniquement par
`PRM_TYPE.TY = DN_FLOAT`, l. 3616) et « tout le reste ». **Un fixed tombe
dans la branche entière.**

Conséquences, opérateur par opérateur :

| Op | Émission actuelle | Correct ? |
|---|---|---|
| `FIX + FIX`, `FIX - FIX` | `ADD` / `SUB` sur représentations | **OUI, par construction** (même SMALL ⇒ additivité) |
| `FIX < FIX`, `=`, etc. | `CGT` / `CEQ` … | **OUI** (même SMALL ⇒ ordre préservé) |
| `FIX * INT`, `INT * FIX` | `MUL` cru | **DOUTEUX — voir §9.6** : sem insère une conversion implicite qui SCALE l'entier. Probablement FAUX. F-B tranche. |
| `FIX / INT` | `DIV` cru + check zéro | **DOUTEUX — idem §9.6** |
| **`FIX * FIX`** | **`MUL` cru** | **FAUX** — résultat scalé UNE FOIS DE TROP |
| **`FIX / FIX`** | **`DIV` cru** | **FAUX** — scalé une fois de moins, et tronque (`rx/ry` vaut 0 ou 1 le plus souvent) |

C'est exactement pourquoi DURATION et CALENDAR fonctionnent : ils
n'utilisent que la moitié correcte du tableau. **L'autre moitié est
silencieuse** — aucune garde, aucun `A FAIRE` sur ce chemin, contrairement
à `**` (l. 3660) qui, lui, se signale. C'est un trou du type piège n° 53
(trou silencieux) resté ouvert deux mois.

### 1.2 Le trou est plus large : `FIXED → FIXED` n'existe pas non plus

`CODE_CONVERSION`, cible `DN_FIXED` (l. ~5427) :

- l. 5518 : `; FIXED TO FIXED WITH DIFFERENT SMALL A FAIRE` (corps générique)
- l. 5524 : `; FIXED to FIXED a faire` (chemin usuel)

Or **c'est précisément le chemin dont `T(X*Y)` a besoin** (cf. §3). Le
pilier ne peut pas être fermé par les seuls opérateurs.

### 1.3 `DN_UNIVERSAL_FIXED` : le nœud existe, sem ne l'emploie PAS

- `diana_NODES.txt:1271` — `universal_fixed` existe.
- `diana_CLASS_.txt:214` — `TYPE_SPEC > universal_fixed`.
- **Grep sur tous les `.adb` : l'expander cite `DN_UNIVERSAL_INTEGER` et
  `DN_UNIVERSAL_REAL`, JAMAIS `DN_UNIVERSAL_FIXED`.**

**RÉSOLU AU DUMP (§9, Q1) — et l'hypothèse était fausse.** Le nœud n'est
pas « invisible de l'expander » : il est **absent de l'arbre**. Sem ne
matérialise pas l'universel, il laisse le `SM_EXP_TYPE` du
`DN_FUNCTION_CALL` **ABSENT**. Donc en l. 3393 :

    RES_TYPE : TREE := D( SM_EXP_TYPE, FUNCTION_CALL );   -- = TREE_VOID

L'opérateur, seul, est **aveugle** : il ne peut pas connaître son type
résultat. Voir §3.0 — c'est le fait structurant du pilier.

### 1.4 Dette cachée : l'hypothèse `NUMER_SMALL = 1` est partout

Trois sites portent la même mine :

- expressions l. 5172 : `-- ATTENTION HYPOTHESE NUMER_SMALL = 1`
- expressions l. 5189 : idem
- expressions l. 2581 : `; CODE_STATIC_FIXED_VALUE: SMALL.NUMER /= 1 A FAIRE`

Le compilateur suppose `SMALL = 1/2^k`. Vrai pour DURATION. **Faux dès
qu'un `for T'SMALL use 1.0/3.0` apparaît.** Note : Q5 (dump E-0) a montré
que le compilateur choisit déjà un SMALL ≠ delta (FPOS : delta `+1/+8`,
SMALL `+1/+16`) — mais toujours avec NUMER = 1. Arbitrage requis (Q4).

---

## 2. L'outil est DÉJÀ LÀ : `CVTIX` est une multiplication rationnelle exacte

Lecture de `codi_x86_64.finc` l. 946-954 :

```
CVTIX   ; empilés I, DENOM, NUMER  (I.D.N)
  POP_RBX          ; rbx = NUMER   (diviseur)
  POP_RCX          ; rcx = DENOM   (multiplicateur)
  POP_RAX          ; rax = I
  imul rcx         ; RDX:RAX = RAX * RCX      <-- produit 128 bits
  idiv rbx         ; RAX = (RDX:RAX) / RBX    <-- division 128/64
  PUSH_RAX
```

**`CVTIX(I, D, N) = (I × D) / N`, avec le produit intermédiaire sur
128 bits AVANT la division.** Ce n'est pas seulement une conversion
entier→fixed : c'est l'opérateur de rééchelonnement rationnel exact, à la
troncature finale près. Aucune perte de bits de poids fort, aucune perte
prématurée de poids faible.

**C'est l'unique primitive dont tout le pilier a besoin.** Corollaire
doctrinal : conforme à Q2 (pas de nouvelle macro codi), on ne touche NI à
codi NI à `_standrd.adb`.

`CVTXI(X, N, D) = (X × N) / D` **avec arrondi** (l. 964-975 : correction du
reste, arrondi au plus proche). Asymétrie à noter : `CVTIX` tronque,
`CVTXI` arrondit. À confirmer et à documenter (Q5).

---

## 3. Le modèle : LRM 4.5.5 et l'élégance d'`universal_fixed`

Ada 83 (4.5.5) définit :

| Opération | Type du résultat |
|---|---|
| `FIX * INTEGER`, `INTEGER * FIX` | le type fixed lui-même |
| `FIX / INTEGER` | le type fixed lui-même |
| **`FIX * FIX`** | **`universal_fixed`** |
| **`FIX / FIX`** | **`universal_fixed`** |

Le point clé : **`universal_fixed` ne peut être consommé que sous une
conversion explicite** (`T(X*Y)`, `T(X/Y)`). Le LRM interdit
`Z := X * Y;` directement. **Il n'y a donc AUCUN « SMALL du résultat » à
deviner : c'est la conversion cible qui le fournit.** Le modèle est fermé.

### 3.0 Qui pilote ? — `CODE_CONVERSION`, PAS l'opérateur (dump, Q1)

Le dump impose l'architecture. Le `DN_FUNCTION_CALL` de `A*B` porte :
`AS_NAME` (l'opérateur), ses opérandes (chacun AVEC son `SM_EXP_TYPE`
fixed), `SM_NORMALIZED_PARAM_S` — **et pas de `SM_EXP_TYPE`**. Le SMALL
cible n'existe QUE dans le `DN_CONVERSION` parent.

**Donc `CODE_DN_BLTN_OPERATOR_ID` ne peut pas décider seul.** C'est
`CODE_CONVERSION` (cible `DN_FIXED`) qui doit :

1. reconnaître que son `AS_EXP` est un `DN_FUNCTION_CALL` dont le
   `SM_DEFN` de l'`AS_NAME` est le `"*"` ou `"/"` prédéfini, à DEUX
   opérandes `DN_FIXED` ;
2. lire `Sx`, `Sy` (via `SM_EXP_TYPE` de chaque opérande → `CD_IMPL_SMALL`)
   et `St` (son propre `SM_EXP_TYPE`) ;
3. calculer le facteur rationnel et **émettre lui-même** la séquence
   (§3.1 / §3.2), sans jamais laisser `CODE_EXP` descendre naïvement dans
   l'opérateur — qui émettrait le `MUL` cru actuel.

Inversion de responsabilité **obligatoire**, pas optionnelle. Elle était
pressentie en v1 (Q2, « sinon : passer le facteur en paramètre — à
décider ») ; le dump tranche : c'est la seule voie.

Corollaire pour F-A : la garde ne peut pas tester `SM_EXP_TYPE` de
l'opérateur (absent). Elle teste le **type des deux opérandes**.

### 3.1 Idiome `FIX * FIX` sous conversion vers T

Soient `Sx = Nx/Dx`, `Sy = Ny/Dy`, `St = Nt/Dt` les SMALL (source x,
source y, cible).

Valeurs réelles : `x = rx·Sx`, `y = ry·Sy`. On veut la représentation
`rt` telle que `rt·St = (rx·Sx)·(ry·Sy)`, donc :

```
rt = rx · ry · (Sx·Sy/St)
   = rx · ry · (Nx·Ny·Dt) / (Dx·Dy·Nt)
```

Le facteur rationnel `Sx·Sy/St` est **entièrement calculable à
l'expansion** (produit/quotient de fractions, réduit par PGCD).
Émission :

```
    <rx>                     ; CODE_EXP(PRM_1)
    <ry>                     ; CODE_EXP(PRM_2)
    MUL                      ; rx*ry   (64 bits — voir Q3 overflow)
    LI  <Nx*Ny*Dt réduit>    ; DENOM du facteur → multiplicateur
    LI  <Dx*Dy*Nt réduit>    ; NUMER du facteur → diviseur
    CVTIX                    ; (rx*ry * D) / N, produit 128 bits
```

Cas massivement majoritaire (SMALL puissances de 2, NUMER=1) : le facteur
se réduit à `Dt/(Dx·Dy)` — souvent un simple décalage, mais on émet
`CVTIX` quand même (Q2 : LLIR explicite, l'optimiseur futur verra le
décalage).

### 3.2 Idiome `FIX / FIX` sous conversion vers T

```
rt = (rx/ry) · (Sx/(Sy·St))
   = rx · (Nx·Dy·Dt) / (Dx·Ny·Nt·ry)
```

**Précaution capitale : diviser EN DERNIER.** Émettre `rx / ry` d'abord
détruirait les poids faibles (`rx/ry` ∈ {0,1} typiquement). Donc :

```
    <rx>
    LI  <Nx*Dy*Dt réduit>    ; DENOM
    LI  <Dx*Ny*Nt réduit>    ; NUMER
    CVTIX                    ; rx rééchelonné, 128 bits internes
    <ry>
    CODE_ZERO_DIVIDE_CHECK   ; réutilise E-E (NUMERIC_ERROR)
    DIV
```

Le rééchelonnement se fait sur 128 bits AVANT la division par `ry` — la
précision est maximale. Alternative (numérateur 128 bits complet) rejetée :
exigerait une macro codi (viole Q2).

### 3.3 `FIXED → FIXED` (conversion, §1.2)

Même mécanique, un seul facteur : `rt = rx · Sx/St = rx · (Nx·Dt)/(Dx·Nt)`
⇒ `LI Nx*Dt ; LI Dx*Nt ; CVTIX`. Élision si `Sx = St` (identité — le test
existe déjà l. 5512, à corriger : comparaison de CHAÎNES, cf. Q6).

**Une seule fonction expander `CODE_FIXED_RESCALE( NUM, DEN )` porte les
trois cas.** Pas de logique par site au-delà du calcul du rationnel.

---

## 4. Répartition doctrinale (inchangée)

- **codi_x86_64.finc** : **RIEN.** `CVTIX`/`CVTXI` suffisent (§2). Si une
  étape semble exiger une macro, le design dévie — revenir ici.
- **_standrd.adb** : **RIEN.**
- **Expander** : `CODE_FIXED_RESCALE` + branchement fixed dans
  `CODE_DN_BLTN_OPERATOR_ID` + fermeture de `FIXED_TARGET` dans
  `CODE_CONVERSION`.
- **Arithmétique rationnelle à l'expansion** : `LONG_INTEGER`, réduction
  par PGCD. Attention débordement du produit `Nx·Ny·Dt` (Q3).

---

## 5. Ordre de construction (étapes-témoins)

- **F-0 — DUMP — FAITE (11 juillet).** Témoin `FIX_DUMP0`. Q1, Q2, Q4, Q6
  closes ; Q5 reste ouverte (non décidable par lecture d'arbre). Piège 71 :
  l'hypothèse centrale (Q1) était FAUSSE. Bilan en §9.
- **F-A — Garde anti-trou-silencieux — LIVRÉE (patch F-A).** `FIX*FIX` /
  `FIX/FIX` ⇒ commentaire FINC bruyant + `raise PROGRAM_ERROR` (motif
  l. 3696). Testée sur le **type des OPÉRANDES** (le résultat n'a pas de
  type — Q1). Arrête l'hémorragie AVANT de savoir coder le cas. Devient
  filet permanent après F-D (`universal_fixed` hors conversion).
- **F-B — `FIX op INT`** : PROUVER par témoin à valeurs que la branche
  entière est correcte (elle l'est probablement ; rien ne le juge
  aujourd'hui). Oracle `FIX_TEST0`.
- **F-C — `FIXED → FIXED`** : `CODE_FIXED_RESCALE`, ferme la dette §1.2.
  Prérequis de F-D. Oracle `FIX_CONV0`.
- **F-D — `FIX*FIX`, `FIX/FIX`** sous conversion, SMALL statiques (§3.1,
  3.2), **pilotées depuis `CODE_CONVERSION`** (§3.0). Oracle `FIX_MUL0`
  (le cœur du pilier).
- **F-E — `NUMER ≠ 1`** : Q4 CLOSE (sem accepte les SMALL non dyadiques,
  §9) ⇒ **à SOLDER**, les trois `HYPOTHESE NUMER_SMALL = 1` sont de vraies
  bombes. Le modèle §3 le fait gratuitement.
- **F-F — Check de gamme fixed** : dette périmètre 2 des checks, **gratuite
  ici** — Q5/E-0 a déjà tout reconnu (bornes = rationnels en unités du
  type, constante de comparaison = borne/IMPL_SMALL). Oracle `CHK_FIX0`.
- **F-G — Filet + ACVC** (série C4A) verts, checks ON et OFF ;
  auto-compilation verte.

Méthode inchangée : livraisons en instructions ligne par ligne ; tag git.

---

## 6. Questions

### Closes au dump F-0 (11 juillet) — détail en §9

- **Q1 — `universal_fixed` : ABSENT de l'arbre. CLOSE.** Hypothèse v1
  RÉFUTÉE (piège 71). Le `DN_FUNCTION_CALL` d'un `FIX*FIX` ne porte
  **aucun** `SM_EXP_TYPE` ; sem ne matérialise pas l'universel, il laisse
  le champ vide. Le type n'existe que dans le `DN_CONVERSION` parent.
  ⇒ **pilotage par `CODE_CONVERSION`** (§3.0), et garde F-A sur les
  opérandes.
- **Q2 — Structure sous conversion : EXPLOITABLE. CLOSE.**
  `DN_CONVERSION` → `AS_EXP` = `DN_FUNCTION_CALL` →
  `AS_GENERAL_ASSOC_S/AS_LIST` = les deux opérandes, chacun avec son
  `SM_EXP_TYPE` → `CD_IMPL_SMALL`. Depuis le site de conversion on remonte
  `Sx`, `Sy` ET `St`. Le facteur rationnel est calculable intégralement à
  l'expansion. Aucun besoin de faire redescendre l'information.
- **Q4 — `NUMER ≠ 1` : sem l'ACCEPTE. CLOSE.** `for T34'SMALL use 3.0/4.0`
  traverse sem sans broncher et produit `CD_IMPL_SMALL: +3/+4`. Les trois
  `HYPOTHESE NUMER_SMALL = 1` (§1.4) sont donc de vraies bombes, pas des
  cas d'école. **Décision : SOLDER en F-E** — le calcul rationnel de §3
  traite `N/D` général sans effort supplémentaire.
- **Q6 — Comparaison de SMALL : sem RÉDUIT déjà. CLOSE, DÉCLASSÉE.**
  `for TEQ'SMALL use 2.0/32.0` donne `CD_IMPL_SMALL: +1/+16` — réduit à la
  source. La comparaison par chaînes (l. 5512) fonctionne donc *par
  chance*. Elle reste fragile (un `PRINT_NUM` non canonique la casserait),
  mais **ce n'est plus un bug** : passage en `LONG_INTEGER` après PGCD
  recommandé, **dette non urgente**, hors chemin critique.

### Restantes

- **Q5 — Troncature vs arrondi. OUVERTE.** Non décidable par lecture
  d'arbre : demande l'exécution. Asymétrie constatée en §2 : `CVTIX`
  tronque (`idiv` brut), `CVTXI` arrondit (correction du reste,
  codi l. 964-975). LRM 4.5.7 laisse le choix entre les deux modèles
  encadrants. **À figer et à DOCUMENTER** — vérifier ce que l'ACVC C4A
  exige réellement. Sonde disponible : `A := T8( T16(0.1875) )` du témoin
  (tronque → 0.125 ; arrondit → 0.25), à observer une fois F-C livrée.
- **Q3 — Débordement. À ARBITRER (mainteneur).** Le `MUL` sur `rx*ry` est
  un `imul` 64 bits AVANT le `CVTIX` (§3.1) : deux grands fixed peuvent
  déborder **avant** le rééchelonnement. Le produit 128 bits de `CVTIX` ne
  protège que l'étage `×D`. Options : (a) accepter et **consigner**
  (cohérent : overflow est déjà HORS PÉRIMÈTRE côté checks, note checks
  §4) ; (b) macro codi `MULX` 128 bits (violerait Q2).
  **Recommandation : (a).**
- **Q7 — Périmètre `FIX ** INT`** (LRM 4.5.6) : dans ce pilier ou hors ?
  **Recommandation : hors**, consigné (`**` entier général est déjà une
  dette ouverte, l. 3660).

## 7. Témoin de dump F-0 : `FIX_DUMP0` — EXÉCUTÉ, LU (§9)

Objectif : répondre Q1, Q2, Q5, Q6 par LECTURE de l'arbre, sans code.
Résultat : Q1, Q2, Q4, Q6 closes ; Q5 demande l'exécution (F-C).
Trois SMALL distincts, dont un `NUMER ≠ 1` et un couple `1/16` vs `2/32`
(pour Q6).

```ada
with TEXT_IO; use TEXT_IO;
procedure FIX_DUMP0 is

  -- SMALL puissance de 2, NUMER = 1 (cas nominal, celui de DURATION)
  type T8  is delta 0.125   range -100.0 .. 100.0;     -- small attendu 1/8 ou 1/16
  type T16 is delta 0.0625  range -100.0 .. 100.0;     -- small attendu 1/16

  -- SMALL explicite NUMER /= 1  (Q4)  : 3/4 n'est PAS 1/2^k
  type T34 is delta 1.0     range -1000.0 .. 1000.0;
  for T34'SMALL use 3.0/4.0;

  -- SMALL explicite equivalent par reduction : 2/32 == 1/16  (Q6)
  type TEQ is delta 0.0625  range -100.0 .. 100.0;
  for TEQ'SMALL use 2.0/32.0;

  A : T8  := 2.5;
  B : T8  := 4.0;
  C : T16 := 0.0;
  D : T34 := 6.0;
  E : TEQ := 0.0;
  N : INTEGER := 3;

begin
  -- (1) Q1/Q2 : SM_EXP_TYPE de A*B ?  universal_fixed ?  arbre sous conversion ?
  C := T16( A * B );                 -- 2.5 * 4.0 = 10.0   attendu C = 10.0
  C := T16( A / B );                 -- 2.5 / 4.0 = 0.625  attendu C = 0.625

  -- (2) F-B : FIX op INT  (deja correct ?  a juger)
  A := A * N;                        -- 2.5 * 3 = 7.5
  A := A / N;                        -- retour a 2.5

  -- (3) Q4 : NUMER /= 1 traverse-t-il ?
  D := T34( D * D );                 -- 36.0

  -- (4) Q6 : SMALL egaux apres reduction (1/16 vs 2/32) -> conversion identite ?
  E := TEQ( C );                     -- doit etre une IDENTITE, pas un rescale

  -- (5) Q5 : troncature ou arrondi ?  0.1875 n'est pas representable en 1/8
  A := T8( T16(0.1875) );            -- 1.5/8 : tronque -> 0.125 ; arrondi -> 0.25

end FIX_DUMP0;
```

*(Les cinq points de lecture prévus ici en v1 sont répondus en §9.)*

---

## 8. Ce que ce pilier NE construit PAS

Aucune macro codi (§2, Q2), aucune modification de `_standrd.adb`, aucune
mécanique d'exception nouvelle (`CODE_ZERO_DIVIDE_CHECK` de E-E est
réutilisé tel quel). Overflow sur `rx*ry` : consigné, HORS PÉRIMÈTRE (Q3).
`FIX ** INT` : hors périmètre (Q7). Bornes fixed DYNAMIQUES : hors
périmètre (déjà consigné en Q5/E-0, « rare, suit le périmètre 2 »).

Si une étape semble exiger l'un de ces éléments, c'est que le design dévie —
revenir à cette note.


---

## 9. Bilan du dump F-0 (11 juillet) — quatre questions closes, une hypothèse réfutée

Lecture de `____TREE.TXT` (655 lignes, `fix_dump0.adb`).

### 9.1 Q1 — `universal_fixed` est ABSENT. L'hypothèse v1 était FAUSSE.

**Aucune occurrence de `universal` dans tout l'arbre.** Le
`DN_FUNCTION_CALL` de `A*B` (l. 450 du dump) porte :

```
AS_EXP: [DN_CONVERSION,P234,L114]            <-- SM_EXP_TYPE: [DN_FIXED,P212,L52]  (T16)
| AS_EXP: [DN_FUNCTION_CALL,P11,L43]         <-- PAS de SM_EXP_TYPE !
|   AS_NAME: [DN_USED_OP,P11,L36]  "*"
|     SM_DEFN: [DN_BLTN_OPERATOR_ID,P77,L99]
|   AS_GENERAL_ASSOC_S:
|     { [DN_USED_OBJECT_ID] A  SM_EXP_TYPE: [DN_FIXED,P204,L67]   (T8)
|       [DN_USED_OBJECT_ID] B  SM_EXP_TYPE: [DN_FIXED,P204,L67] } (T8)
|   LX_PREFIX / SM_NORMALIZED_PARAM_S
| AS_NAME: T16
```

Sem **ne matérialise pas** l'universel : il laisse simplement le champ
absent. Le nœud `DN_UNIVERSAL_FIXED` existe dans DIANA mais n'est jamais
construit. ⇒ `RES_TYPE = TREE_VOID` en l. 3393, `IS_FLOAT` = FALSE, `MUL`
cru. **Conséquence : §3.0 (pilotage par la conversion) + garde F-A sur les
opérandes.**

**Piège n° 71, troisième récidive** (après E-0 : 3/3 hypothèses fausses).
La leçon tient : ne jamais présupposer la forme de l'arbre, même quand le
nœud existe dans la grammaire DIANA.

### 9.2 Q2 — Tout est remontable depuis la conversion

Confirmé ci-dessus : `Sx` et `Sy` par `SM_EXP_TYPE` des opérandes,
`St` par le `SM_EXP_TYPE` de la conversion. `CODE_CONVERSION` a les trois.

### 9.3 Q4 — sem accepte les SMALL non dyadiques

`for T34'SMALL use 3.0/4.0` :

```
[DN_LENGTH_ENUM_REP]  T34'SMALL     SM_VALUE: +3/+4
  → CD_IMPL_SMALL: +3/+4            SM_ACCURACY: +1/+1
```

Le SMALL `3/4` **traverse sem sans broncher**. Les trois
`HYPOTHESE NUMER_SMALL = 1` du code sont donc de vraies bombes.
⇒ **F-E : solder.**

### 9.4 Q6 — sem réduit les SMALL à la source

`for TEQ'SMALL use 2.0/32.0` → `CD_IMPL_SMALL: +1/+16` (**déjà réduit**).
La comparaison par chaînes de la l. 5512 fonctionne par chance. Dette
déclassée (non urgente).

### 9.5 Trouvaille non prévue — le SMALL est la puissance de 2 SOUS le delta

Fait à retenir (généralise Q5/E-0, où l'on avait noté « SMALL ≠ delta » sur
FPOS sans en tirer la règle) :

| Type | `delta` (SM_ACCURACY) | `CD_IMPL_SMALL` |
|---|---|---|
| `T8`  — `delta 0.125`  | `+1/+8`  | **`+1/+16`** |
| `T16` — `delta 0.0625` | `+1/+16` | **`+1/+32`** |
| `TEQ` — `'SMALL use 2.0/32.0` | `+1/+16` | `+1/+16` (imposé) |
| `T34` — `'SMALL use 3.0/4.0`  | `+1/+1`  | `+3/+4` (imposé) |

**Règle : à défaut de clause `'SMALL`, le compilateur prend la puissance de
2 immédiatement INFÉRIEURE au delta** (un bit de garde). Ne JAMAIS déduire
le SMALL du delta dans le code : toujours lire `CD_IMPL_SMALL`.

**Effet de bord sur le témoin :** `TEQ` (SMALL `1/16`) et `T16` (SMALL
`1/32`) ne sont donc PAS de même représentation — l'instruction
`E := TEQ( C );` du témoin, prévue en v1 comme une *identité*, est en
réalité un **vrai rescale d'un facteur 2**. Le témoin reste utile (il
exerce le chemin F-C), mais **son oracle change** : ce n'est pas un
no-op. À corriger dans ORACLES_TESTS lors de F-C.

### 9.6 `FIX * INTEGER` — forme de l'arbre (utile pour F-B)

`A := A * N;` (l. 506) : l'entier `N` apparaît **sous un `DN_CONVERSION`
implicite vers T8** inséré par sem —

```
AS_EXP: [DN_CONVERSION]                      SM_EXP_TYPE: T8
| AS_EXP: [DN_FUNCTION_CALL]  "*"
|   { A                        SM_EXP_TYPE: T8
|     [DN_CONVERSION]          SM_EXP_TYPE: T8      <-- conversion de N !
|     | AS_EXP: N              SM_EXP_TYPE: DN_INTEGER
|     | AS_NAME: T8 }
```

**Attention (à vérifier en F-B) :** si cette conversion implicite
`INTEGER → T8` est réellement exécutée, elle émet un `CVTIX` — c'est-à-dire
qu'elle SCALE `N` (3 → 48 avec SMALL 1/16). Alors `A * N` deviendrait
`rA * 48` au lieu de `rA * 3` : **FAUX d'un facteur SMALL**. Le
`FIX * INTEGER` ne serait donc PAS correct comme supposé en §1.1 !

Cette lecture **invalide peut-être l'optimisme de §1.1 sur `FIX*INT`**.
C'est exactement pourquoi F-B existe (« PROUVER par témoin à valeurs »).
**F-B devient prioritaire et n'est plus une formalité.** Note : les deux
opérandes étant alors `DN_FIXED` (après conversion implicite), la garde
F-A **tombera peut-être sur `A * N`** — ce qui, si cela se produit, est le
révélateur du bug, pas un défaut de la garde.

