# SESSION EXPANDER — Rapport de session du 13 mai 2026

**Date** : 13 mai 2026
**Objectif** : compléter la compilation des agrégats Ada 83
**Statut** : agrégats array N-D, record imbriqué, init par défaut composite,
et agrégats anonymes en paramètre — tous validés


## 1. Travaux réalisés

### 1.1 Agrégats array N-D dans `CODE_AGGREGATE`

La branche `DN_CONSTRAINED_ARRAY` / `DN_ARRAY` de `CODE_AGGREGATE`
(expander-expressions.adb) a été refactorée pour gérer correctement les
agrégats multidimensionnels.

**Problème antérieur** : le code itérait sur les dimensions au niveau
racine et faisait `null` quand il rencontrait un sous-agrégat sans
`SM_EXP_TYPE` (cas des dimensions internes). Résultat : seule la première
dimension était émise pour un tableau N-D.

**Solution** : procédure récursive locale `EMIT_AGG_AT_DEPTH(AGG, DEPTH)`
qui descend par profondeur. Les dimensions sont précalculées une seule
fois dans un tableau `DIM_TBL` à partir de `SM_INDEX_S` du type
`SM_BASE_TYPE`, et les strides (en octets) sont calculés de la
dimension la plus interne vers la plus externe :
- `STRIDE(N) = COMP_SIZ_BYTES` (où N = NB_DIMS)
- `STRIDE(K) = STRIDE(K+1) * (LST(K+1) - FST(K+1) + 1)` pour K < N

À chaque appel récursif, l'invariant est : l'adresse de début du bloc
à remplir est sur la pile à l'entrée, et est consommée (DROP) à la sortie.

Une procédure imbriquée `EMIT_ONE_COMP(COMP)` factorise le pattern
`DUP / remplir / LI <stride> / ADD` pour les composantes positionnelles
et pour la répétition des `DN_NAMED` (CHOICE_RANGE, CHOICE_OTHERS).

**Délégation à la feuille** : quand `DEPTH = NB_DIMS` et que la
composante est un `DN_AGGREGATE` typé record, on rappelle `CODE_AGGREGATE`
qui tombe dans la branche `DN_RECORD`. Cas validé sur `array(1..N) of POINT`.

### 1.2 Agrégats record avec déclarations groupées `A, B : POINT := ...`

La branche `DN_RECORD` de `CODE_AGGREGATE` ne traitait qu'un seul
component_id par decl. Pour un type avec déclaration groupée
(`A, B : POINT;`), DIANA produit **un seul** `DN_VARIABLE_DECL` dans
`AS_DECL_S` mais **plusieurs** `DN_COMPONENT_ID` dans son
`AS_SOURCE_NAME_S`. Le `NORM_SEQ` de l'agrégat racine contient en revanche
une entrée par composant individuel.

**Solution** : double boucle imbriquée `SCAN_DECLS` / `SCAN_IDS` avec
pop de `NORM_SEQ` à chaque component_id. Garde-fou
`exit SCAN_DECLS when IS_EMPTY(NORM_SEQ)`.

### 1.3 Init par défaut composite dans `COMPILE_RECORD_VAR`

`COMPILE_RECORD_VAR` (expander-declarations.adb) faisait déjà la double
boucle correctement, mais traitait `FIELD_INIT` uniformément comme une
expression scalaire — émettant `S<size>` même pour un agrégat composite.
Pour un type record dont un champ est un autre record avec init par
défaut composite, `OPER_SIZ_CHAR` renvoyait `v` et le code produit `Sv`
était inassemblable.

**Solution** : dispatch sur `FIELD_INIT.TY = DN_AGGREGATE` :
- composite : `LIVa <lvl>, <vc>_disp, <type>.<champ>` puis
  `EXPRESSIONS.CODE_AGGREGATE(FIELD_INIT)` qui consomme l'adresse.
- scalaire : comportement antérieur (`LIVa` + `CODE_EXP` + `S<size>`).

### 1.4 Agrégats anonymes en paramètre

C'était l'obstacle qui avait forcé un contournement par variable
intermédiaire lors des sessions DIRECT_IO du 10 mai.

**Solution** : nouvelle branche dans
`CODE_PROCEDURE_CALL.INVERSE_RECURSE_ON_PARAMETERS`
(expander-instructions.adb) qui détecte `ACT_PRM.TY = DN_AGGREGATE` ou
`DN_QUALIFIED` enveloppant un agrégat, et matérialise l'agrégat dans
une variable temporaire anonyme :

```
ANONYMOUS_STR := ANONYMOUS_NAME_AT(ACT_PRM)  -- "ANON_<ligne>_<col>"
VAR ANON_X_Y_disp, q
VAR ANON_X_Y__u, q
VAR ANON_X_Y__dat, <TYPE>.SIZ                 -- réservation pile de travail
LVA <lvl>, ANON_X_Y__dat                      -- @data
Sa  <lvl>, ANON_X_Y_disp
La  <lvl_type>, <TYPE>.use__info              -- contenu (pas LVA)
Sa  <lvl>, ANON_X_Y__u
LVA <lvl>, ANON_X_Y__dat                      -- @data sur pile pour CODE_AGGREGATE
CODE_AGGREGATE(ACT_PRM)                       -- remplissage avec DROP final
LVA <lvl>, ANON_X_Y_disp                      -- @doublet pour passage paramètre
```

La macro `VAR` opérant sur la zone virtuelle `VARzone` du `endPRO`, les
déclarations émises en cours d'instructions sont automatiquement
agrégées par fasmg. Pas besoin d'insertion en zone de déclarations.

**Durée de vie** : la temporaire reste allouée pendant toute la
procédure appelante. Acceptable car les agrégats anonymes sont en
général petits (point 3D, vecteur court, descripteur). Pour les
tableaux, les données sont sur la co-pile via le mécanisme habituel,
seuls 16 octets occupent la VARzone (`_disp` + `__u`) ; le `__dat`
n'est pas alloué dans ce cas — c'est la co-pile qui fournit l'espace.
Pour les records, le `__dat` est dans la VARzone.

**`DN_QUALIFIED`** : géré dans la condition d'entrée par
`and then D(AS_EXP, ACT_PRM).TY = DN_AGGREGATE`, puis `ACT_PRM` est
remplacé par son `AS_EXP` pour la suite du traitement.

### 1.5 Suppression du contournement DIRECT_IO

DIRECT_IO_TEST2 a été remis dans sa forme idiomatique :
```ada
POINT_DIO.WRITE( FP, POINT'( X => 777, Y => 888, Z => 999 ), 2 );
```
fonctionne désormais sans déclaration de variable intermédiaire dans
un bloc `declare`. Validé sur record POINT.


## 2. Bugs corrigés

### Bug 1 : sous-agrégats array N-D sans SM_EXP_TYPE
Les sous-agrégats des dimensions internes d'un tableau multidimensionnel
n'ont pas de `SM_EXP_TYPE` rempli — seul l'agrégat racine et les
feuilles sont typés. Le code antérieur testait `SM_EXP_TYPE /= TREE_VOID`
et faisait `null` sinon. Résolu par la récursion sur la profondeur
dimensionnelle, qui n'a pas besoin du type des sous-agrégats.

### Bug 2 : COMP_DECL_S et NORM_SEQ de longueurs différentes
`POP(COMP_DECL_S)` vidait la séquence des decls avant que `NORM_SEQ`
ne soit épuisé (cas `A, B : POINT := ...`), causant un `TREE_NIL` au
pop suivant. Résolu par la double boucle.

### Bug 3 : `Sv` pour init par défaut record imbriqué
`OPER_SIZ_CHAR` sur un type record renvoie `v` (pas de store scalaire
possible). Le code émettait `Sv` qui ne s'assemblait pas. Résolu par
le dispatch `FIELD_INIT.TY = DN_AGGREGATE`.

### Bug 4 : `LVA` au lieu de `La` pour le `__u` de l'agrégat anonyme
Le slot `use__info` du namespace contient `@SIZ` (initialisé par
l'élaboration `LVA SIZ ; Sa use__info`). Pour copier ce contenu dans
le `__u` d'une variable, il faut `La VECTEUR.use__info` (lit le
contenu) et non `LVA VECTEUR.use__info` (empile l'adresse du slot).
Sans cette correction, l'indexation tableau à l'exécution lisait
COMP_SIZ et FST à des adresses erronées, retournant des zéros.
Les records n'étaient pas affectés car leur accès se fait par
offsets statiques sans consulter `__u`.


## 3. Conventions nouvelles

- **Stride array statique** : pour un `DN_CONSTRAINED_ARRAY`, les
  strides par dimension sont calculés à la compilation depuis `COMP_SIZ`
  et les cardinalités. Plus de `LId .use__info.COMP_SIZ` / `LI 8` / `DIV`
  à l'exécution pour les agrégats statiques.
- **`EMIT_AGG_AT_DEPTH(AGG, DEPTH)`** : invariant de pile clair :
  adresse de début empilée à l'entrée, consommée par `DROP` à la sortie.
  Le compteur `EMIS` est local à chaque appel (résolution de `others=>`
  à la profondeur courante).
- **`ANONYMOUS_NAME_AT(T)`** : nom anonyme stable basé sur la position
  source, format `ANON_<ligne>_<col>`. Garantit l'unicité pour les
  variables temporaires générées par l'expander.
- **Double underscore avant `_dat`, `_disp`, `_u`** : éviter toute
  collision avec des identificateurs Ada (qui n'autorisent pas le
  double underscore consécutif).


## 4. Pièges identifiés (ajouts)

46. **Confusion `La` / `LVA` pour le `__u` d'un agrégat anonyme** :
    le slot `<TYPE>.use__info` contient déjà `@SIZ` (rempli à
    l'élaboration). Pour copier dans le `__u` d'une variable, utiliser
    `La` (lit le contenu), pas `LVA` (empile l'adresse du slot).
    Symptôme : tableau affichant des zéros, record correct.
47. **Pas de `SM_EXP_TYPE` pour les sous-agrégats array multi-D** :
    seul l'agrégat racine et les feuilles ont `SM_EXP_TYPE` rempli.
    La récursion sur les sous-agrégats internes doit s'appuyer sur la
    profondeur dimensionnelle, pas sur le type des nœuds.
48. **Déclaration groupée dans un record** : `A, B : T;` produit un
    seul `DN_VARIABLE_DECL` avec plusieurs `DN_COMPONENT_ID` dans
    `AS_SOURCE_NAME_S`. Le traitement d'un agrégat record explicite
    doit poper `NORM_SEQ` à chaque component_id, pas à chaque decl.
49. **Macro `VAR` opère en zone virtuelle** : les `VAR` émis n'importe
    où dans le corps d'une procédure sont automatiquement agrégés en
    fin de `endPRO`. Pas besoin de pré-allouer en zone de déclarations.
50. **Sous-agrégats array multi-D : ordre des `NORM_SEQ`** : la phase
    sémantique trie les associations par indice croissant, indépendamment
    de l'ordre source. Le `EMIS` qui démarre à 0 et progresse vers
    `LST-FST+1` fonctionne directement.


## 5. Fichiers modifiés

| Fichier | Modifications |
|---------|--------------|
| expander-expressions.adb | CODE_AGGREGATE branche DN_CONSTRAINED_ARRAY / DN_ARRAY refactorée (EMIT_AGG_AT_DEPTH récursif), branche DN_RECORD double boucle SCAN_DECLS/SCAN_IDS, DN_AGGREGATE accepté dans CODE_EXP |
| expander-declarations.adb | COMPILE_RECORD_VAR init par défaut composite (dispatch FIELD_INIT.TY) |
| expander-instructions.adb | CODE_PROCEDURE_CALL.INVERSE_RECURSE_ON_PARAMETERS branche DN_AGGREGATE / DN_QUALIFIED (matérialisation via ANONYMOUS_NAME_AT) |


## 6. Programmes de test — résultats validés

### test_agregats.adb

Couverture validée (FINC vérifié manuellement, exécution sans segfault) :
- P1, P2 : records nommé et positionnel
- S1 : record de records `(A=>(1,2,3), B=>(4,5,6))`
- V1, V2, V3 : array 1D positionnel, nommé avec ranges, `others`
- H1 : record mixte POINT + VECTEUR
- M1 : MATRICE 3D `array(1..4, 1..3, 1..4) of INTEGER` avec mix
  positionnel / `others` / `m..n =>`
- TP1 : array de records (3 POINT)
- SEG2_A : init par défaut composite (record dont champs sont des records)
- SEG2_B : agrégat record de record explicite

### Agrégats en paramètre

```
INGERE_VECTEUR( VECTEUR'(8, 16, 32, 64) ) ;
INGERE_POINT( (10, 12, 14) ) ;
```

Affichage validé :
```
VEC = [          8,          16,          32,          64]
PT = (         10,          12,          14)
```

### DIRECT_IO_TEST2

`POINT_DIO.WRITE( FP, POINT'(X=>777, Y=>888, Z=>999), 2 )` — fonctionne
sans contournement.


## 7. Ce qui reste

### Cas d'agrégats encore non couverts (faible priorité)

- Agrégats avec discriminants (variant records)
- Slice assignments `V1(2..3) := (5, 6)` (agrégats anonymes
  comme cible)
- Agrégats dans des function calls retournant un type composite
- Agrégats avec expressions dynamiques (non statiquement résolubles)

### Mineures à corriger au passage

- Format `LI v` (espace après LI parfois manquant ou double dans la
  branche array — cosmétique fasmg)
- `LI 1 ; NEG` au lieu de `LI -1` pour les littéraux négatifs
  (optimisation possible dans CODE_EXP)

### Suite envisagée

- CALENDAR (LRM 9.6) — pas implémenté
- UNCHECKED_CONVERSION (LRM 13.10.2) — pas implémenté
- FIXED_IO (LRM 14.3.9) — nécessite support DN_FIXED
- Compilation par TLALOC de son propre source : par_phase a déjà été
  testé en option `w` (sans expansion). Premier vrai test
  d'auto-compilation : `idl.ads`, `idl.adb`, `diana_node_attr_class_names.ads`
  passent en `W` (avec FINC) — validité du code généré encore à
  vérifier (types à discriminants notamment).
