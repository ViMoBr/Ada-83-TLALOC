# NOTE DE MODÈLE D'EXÉCUTION — POINTS FIXES, MUL/DIV ET ATTRIBUTS (LRM 3.5.9, 4.5.5, 14.3.8) — v1.1

**11 juillet 2026 — Q1 INTÉGRALEMENT FERMÉE par les dumps F-1 (deux
itérations de FIX_DUMP0).** Restent ouvertes : Q2 (use__info étendu),
Q3 (arrondi), Q4 (ordre T(X/Y)), Q5 (macros) — décisions mainteneur.
La sonde a payé avant la première ligne du pilier : deux fossiles
expander et TROIS dettes sem (§9). v1 conservée pour l'historique.

## 1. Algèbre de représentation (inchangée, confirmée par T34)

`repr = valeur / SMALL`, SMALL rationnel `Ns/Ds`, mantisse 64 bits signée.
Pour une valeur rationnelle `Nv/Dv` : **repr = Nv·Ds / (Dv·Ns)** — c'est
la formule UNIQUE du pilier, consommée par les littéraux, les attributs
pliés, fixed→fixed, T(X*Y) et T(X/Y). CVTIX (I.D.N → I·D/N, imul/idiv
128 bits) est déjà son exécutant runtime ; il suffit de lui donner les
bons N et D. Vérification T34 (small 3/4) : repr(6.0) = 6·4/(1·3) = 8.

| Opération | Représentation cible T (Nt/Dt) |
|---|---|
| X ± Y, comparaisons (même SMALL) | opérations entières crues (acquis) |
| X * K entier (idiome T(X*T(K)), §4) | `rX * K` — exact, aucun rescale |
| X / K entier | `rX / K` — arrondi Q3 |
| T( X * Y ) | `rX · rY · (Nx·Ny·Dt) / (Dx·Dy·Nt)` |
| T( X / Y ) | `rX · (Nx·Dy·Dt) / (Dx·Ny·Nt) / rY` — ordre Q4 |
| T( X ) fixed→fixed | `rX · (Nx·Dt) / (Dx·Nt)` ; identité si rationnels RÉDUITS égaux (cas TEQ 2/32 = 1/16) |

## 2. Q1 FERMÉE — ce que DIANA porte réellement (dumps des deux sondes)

### Q1a — DELTA et SMALL : deux champs distincts du TYPE_SPEC
- `SM_ACCURACY` = **delta déclaré**, rationnel (+1/+8, +1/+16, +1/+1),
  porté par le déclaré ET par le base — même slot que l'accuracy float.
- `CD_IMPL_SMALL` = **small implémenté** (XD_NUMER/XD_DENOM).
- Clause `for T'SMALL use` : nœud `DN_LENGTH_ENUM_REP` (attribut + AS_EXP
  à SM_VALUE plié) mais sem replie déjà la valeur dans CD_IMPL_SMALL —
  l'expander IGNORE le nœud (déjà le cas, aucun code).

### Q1b — structure des types et sous-types
- Type déclaré : DN_FIXED (IS_ANONYMOUS FALSE) → SM_BASE_TYPE anonyme
  auto-référent portant la gamme machine — bornes = USED_OBJECT_ID à
  SM_VALUE **rationnels en unités du type, NON scalés** (piège 71).
  SM_RANGE du déclaré → l'AS_RANGE du fixed_constraint, bornes pliées.
- Sous-type (`subtype S8 is T8 range -1.0..1.0`) : DN_SUBTYPE_DECL →
  SM_TYPE_SPEC = un NOUVEAU DN_FIXED ; SM_BASE_TYPE → le base anonyme du
  parent ; SM_ACCURACY et CD_IMPL_SMALL hérités TELS QUELS ; SM_RANGE →
  la contrainte pliée (AS_CONSTRAINT = DN_RANGE simple, pas de
  fixed_constraint) ; XD_SOURCE_NAME = le SUBTYPE_ID.
- **PIÈGE consigné** : `SM_IS_ANONYMOUS: TRUE` sur ce sous-type NOMMÉ.
  Le drapeau ne discrimine pas l'anonymat ; le critère fiable est
  XD_SOURCE_NAME (cohérent avec la résolution du fossile n° 80).

### Q1c — la conversion est l'unique détenteur du type cible
`C := T16(A*B)` : DN_ASSIGN → DN_CONVERSION (SM_EXP_TYPE = cible) →
DN_FUNCTION_CALL `"*"` SANS SM_EXP_TYPE (universal_fixed jamais
matérialisé — F-0 confirmé). Idem `"/"`.

### Q1d — la forme nue N'EXISTE PAS : rectification de F-0
`A := A * N;` est REJETÉ par sem (« DESACCORD DE TYPE ») alors que RM
4.5.5(9-10) prédéfinit `"*"(T,INTEGER)`, `"*"(INTEGER,T)`, `"/"(T,INTEGER)`
— dette sem n° 2 (§9). Le « sem insère une conversion implicite » de F-0
était une méprise : les conversions internes observées étaient ÉCRITES
dans les sources (l'utilisateur doit qualifier `T8(A * T8(N))`).
Conséquence architecturale MAJEURE : **tout le multiplicatif fixed entre
dans l'expander par DN_CONVERSION — point d'entrée unique, F-D**.
F-B est rétrogradé d'étape autonome en ÉLISION INTERNE à F-D (§4).

### Q1e — attributs : sem plie tout (dont un pliage FAUX)
- `T8'DELTA` → DN_ATTRIBUTE, SM_VALUE +1/+8, SM_EXP_TYPE = fixed du
  CONTEXTE. `T34'SMALL` → +3/+4, idem. Émission = chemin littéral fixed
  (formule §1), rien d'autre. Le `null` muet de la branche DELTA de
  CODE_ATTRIBUTE devient : émettre le SM_VALUE plié, ANOMALIE s'il
  manque (leçon 'DIGITS : un attribut émet exactement UNE valeur).
- `T8'AFT` et `T8'FORE` → SM_VALUE = **3 EN DUR TOUS LES DEUX** ; les
  valeurs vraies sont AFT=1 (10¹·0.125 ≥ 1) et FORE=4 (« 100 » + signe).
  Dette sem n° 3 (§9) — même placeholder que le `LI 3 -- a revoir`
  historique de l'expander. Décision §5.

## 3. F-2 — littéraux, statiques, sous-types, attributs

Les deux fossiles expander de la sonde, à corriger en tête de lot :

1. **Littéral fixed à Ns ≠ 1 — trou SILENCIEUX** (piège 53 caractérisé) :
   `D := 6.0` (small 3/4) émet `6·4/1 = 24` au lieu de 8. Dans
   CODE_NUMERIC_LITERAL (DN_REAL_VAL), NUMER_SMALL est lu puis IGNORÉ
   (`ATTENTION HYPOTHESE NUMER_SMALL = 1`). Correctif = formule §1 :
   pousser `Dv·Ns` (produit statique) au lieu de `Dv`. Trois sites :
   branche statique, branche générique (Ns runtime : `LI Dv / LIq
   …_FIXED_USE_INFO.NUMER / MUL` avant CVTIX), CODE_STATIC_FIXED_VALUE.
2. **CODE_STATIC_FIXED_VALUE, bail corrompant** : le `return` sur
   Ns ≠ 1 laisse l'appelant émettre son `Sq FST` → store depuis une
   pile jamais alimentée (FST/LST de _T34 = valeurs antérieures de la
   pile d'évaluation). Le correctif 1 supprime le cas ; RÈGLE générale
   à consigner : un « A FAIRE » qui rend la main à un appelant émetteur
   est PIRE qu'une ANOMALIE — compléter ou lever PROGRAM_ERROR (la
   garde F-A est le modèle).

Puis : `CODE_SUBTYPE_DECL` DN_FIXED — émettre le bloc info du sous-type
(SIZ hérité, FST/LST scalés depuis les bornes rationnelles de SM_RANGE
par la formule §1, NUMER/DENOM hérités) ; et les attributs Q1e (pliés →
chemin littéral ; AFT/FORE selon décision §5).

Témoins F-2 (auto-jugeants, valeurs) : D = 6.0 relu 6.0 sur small 3/4 ;
S8'FIRST/'LAST ; T8'DELTA = 0.125 ; T34'SMALL = 0.75 ; bornes _S8
scalées (-16/+16 en repr small 1/16).

## 4. F-D — interception par CODE_CONVERSION, avec élision intégrée

CODE_CONVERSION cible DN_FIXED, source DN_FUNCTION_CALL `"*"`/`"/"` à
opérandes fixed :

- **Élision FIX·INT (ex-F-B)** : si un opérande est DN_CONVERSION→FIXED
  dont l'AS_EXP est DN_INTEGER (l'idiome imposé `T(A * T(N))`), coder
  l'entier NU : `rA · N` est exact, même small, la conversion externe
  devient identité. Vaut pour `"*"` des deux côtés et pour `"/"` à
  diviseur entier (arrondi Q3). Zéro 128 bits, zéro perte.
- **Cas général FIX·FIX** : coder rX, rY, pousser le rationnel composé
  (§1) — statique si les trois SMALL le sont (réduction par gcd côté
  expander), sinon via les _FIXED_USE_INFO du GFP — puis XMULSC/XSCALE.
- fixed→fixed : XSCALE(rX, Nx·Dt, Dx·Nt) ; **identité si les rationnels
  RÉDUITS sont égaux** (remplace la comparaison de chaînes actuelle de
  la branche générique — cas TEQ). Remplace les six « A FAIRE ».
- La garde F-A reste : l'atteindre signifie désormais un vrai trou.

## 5. Décisions demandées (Q2–Q5 + dettes sem)

| Q | Objet | Proposition |
|---|---|---|
| Q2 | NUM'AFT/'FORE/'DELTA/'SMALL en corps partagé (FIXED_IO) | étendre `_FIXED_USE_INFO` de champs AFT et FORE précalculés à l'élaboration d'instance (DELTA/SMALL : NUMER/DENOM y sont déjà) + témoin gardien du layout (leçon piège 87) |
| Q3 | Arrondi de `*`/`/` | troncature vers zéro (idiv nu, déterministe, conforme 4.5.5) ; l'arrondi au plus proche reste aux conversions (CVTXI/CVTFIR). Sonde (5) `T8(T16(0.1875))` = l'oracle : 0.125 attendu |
| Q4 | Ordre T(X/Y) | pré-multiplication 128 bits puis idiv par rY (précision, produit en RDX:RAX) |
| Q5 | Macros codi | paire XSCALE `[r,N,D]→[r·N/D]` + XMULSC `[rX,rY,N,D]→[rX·rY·N/D]`, produit conservé en RDX:RAX ; pilotage en LLIR explicite |
| sem-1 | small défaut = delta/2 (RM 3.5.9(6) : plus grande puissance de 2 ≤ delta, soit delta lui-même quand delta = 2^-k) | assumer (côté sûr, observable via T'SMALL) ou corriger sem — à trancher AVANT de figer les témoins |
| sem-2 | rejet de `A := A*N` nu (4.5.5(9-10)) | dette de conformité front-end ; les C45x ACVC échoueront à la compilation ; instruire aussi `A * 2.0` (universal_real) |
| sem-3 | 'AFT/'FORE pliés à 3 en dur | corriger le pliage sem (consommateur naturel = SM_VALUE) ; à défaut, l'expander recalcule depuis SM_ACCURACY/SM_RANGE en ignorant le SM_VALUE — mais deux sources de vérité, déconseillé |

## 6. Ordre de construction (étapes-témoins, réordonnées)

- **F-1 — FAITE (11 juillet, deux dumps)** : Q1a-e fermées, §2 ; butin :
  2 fossiles expander + 3 dettes sem + piège SM_IS_ANONYMOUS.
- **F-2** : fossiles littéraux/statiques + CODE_SUBTYPE_DECL DN_FIXED +
  attributs pliés. Témoin FIX_TEST0 (§3). La sonde FIX_DUMP0 doit
  TRAVERSER l'expander jusqu'à la garde F-A exclue.
- **F-3** : macros codi (Q5) + F-D complet (§4, élision comprise) +
  fixed→fixed. Témoin FIX_TEST1 : toutes les lignes de FIX_DUMP0 en
  auto-jugeant — C=10.0, C=0.625, A=7.5→2.5, D=36.0 (small 3/4 !),
  E=TEQ(C) identité, T8(T16(0.1875)) selon Q3.
- **F-4** : Q2 (use__info étendu + gardien) + attributs FIXED_IO.
  Oracle : FLOAT_FIXED_IO_TEST sections 3, 7, 8, 9, 10 vertes.
- **F-5** : filet complet + TEST_CALENDAR (converti auto-jugeant) +
  auto-compilation ; ETAT_PILIERS 3.5.9 → CLOS ; tag git.

Méthode inchangée : livraisons ligne à ligne ; tout chemin incomplet
lève ANOMALIE (§3, règle 2) ; témoins à VALEURS.

## 7. Journal des rectifications v1 → v1.1

- F-B supprimé comme étape : élision interne à F-D (Q1d — la forme nue
  n'atteint jamais l'expander).
- F-2 enrichi des deux fossiles de sonde ; F-1 close.
- 'DELTA/'SMALL : plus rien à calculer (SM_VALUE plié, chemin littéral).
- 'AFT/'FORE : suspendus à sem-3.
- Trois dettes sem consignées (§5) — hors périmètre expander mais
  bloquantes pour les oracles (sem-1 conditionne toutes les valeurs de
  représentation des témoins).
