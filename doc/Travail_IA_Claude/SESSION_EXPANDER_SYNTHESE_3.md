# SESSION EXPANDER — Synthèse et point de départ

**Date** : avril 2026 (mise à jour après sessions des 9, 10 et 10 avril après-midi)
**Objectif** : compléter l'EXPANDER du compilateur TLALOC


## 1. État des lieux de l'EXPANDER

### Ce qui fonctionne (acquis antérieurs)

- **Types scalaires** : entiers (DN_INTEGER), énumérations (DN_ENUMERATION),
  sous-types entiers et énumérations — génération complète avec namespace,
  SIZ, FST, LST.
- **Constrained arrays** : traitement multi-dimensionnel récursif via
  PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC, calcul de taille statique/dynamique,
  descripteurs avec USEINFO et offsets virtual.
- **Records statiques** : champs via STATOFS dans un `virtual at 0`,
  USEINFO pour les infos de type des champs.
- **Variables** : déclaration VAR, initialisation, accès Ld/Sd avec
  niveau lexical et déplacement.
- **Sous-programmes** : PRO/ELB/UNLINK/RTD/endPRO complet. Paramètres
  via PRMS/PRM/endPRMS. Convention : `in` scalaire par copie valeur,
  `out`/`in out` et composites par adresse (LVA).
- **Appels** : CALL avec résolution différée, `if defined ... end if`
  pour n'assembler que les procédures effectivement appelées.
- **Instructions** : if/then/else (BT/BF/BRA), boucles for/while/loop,
  case, exit, return, goto, assign, null_stm, procedure_call.
- **Expressions** : numeric_literal, string_literal, used_object_id,
  used_char, used_op, short_circuit, parenthesized, conversion,
  qualified, function_call, indexed, selected, attribute, membership.
- **Génériques** : instanciation de packages génériques (INTEGER_IO
  fonctionnel). Mécanisme GFP_disp pour les paramètres formels.
- **Packages** : namespace FASM, elab_spec, body.
- **Stubs/subunits** : include du .FINC correspondant.
- **With/use** : génération des `include 'X.FINC'`.
- **Code statements** : package MACHINE_CODE avec ASM_OPCODE.
- **Exceptions** : squelette présent mais handlers incomplets.


### Acquis des sessions 9-10 avril 2026

#### Types privés et incomplets (RÉSOLU)

- **DN_PRIVATE / DN_L_PRIVATE** dans CODE_TYPE_DECL : ne génèrent
  rien. Le full type dans la partie privée de la spec est traité
  normalement quand l'expander le rencontre. Pas de résolution
  anticipée (évite les problèmes de dépendances forward comme
  FILE_MODE non encore déclaré quand FILE_TYPE est vu).
- **DN_INCOMPLETE** : même approche, différé au full type.
- **CODE_RECORD_DECL** : résolution défensive private/incomplete
  au début (si appelé dans un autre contexte).
- **`size = $`** ajouté avant `end virtual` dans les records
  statiques pour que FASM calcule la taille du bloc.
- **make_nod.adb** : `DB(DA.CD_COMPILED, NODE, FALSE)` ajouté dans
  MAKE_RECORD, MAKE_ENUMERATION, MAKE_INTEGER, MAKE_FLOAT,
  MAKE_FIXED, MAKE_ARRAY, MAKE_ACCESS, MAKE_TASK_SPEC,
  MAKE_CONSTRAINED_RECORD, MAKE_CONSTRAINED_ACCESS.

#### Initialisation des champs de record par défaut (NOUVEAU)

- **COMPILE_RECORD_VAR** dans declarations.adb : quand il n'y a
  pas d'agrégat explicite (SM_INIT_EXP = TREE_VOID), parcours des
  champs du record (SM_COMP_LIST → AS_DECL_S → AS_SOURCE_NAME_S).
  Pour chaque component_id ayant un SM_INIT_EXP /= TREE_VOID :
  ```
  LIVa  lvl, VAR_disp, STANDARD.PKG.TYPE.FIELD
  CODE_EXP(FIELD_INIT)
  S<siz>
  ```
  Ceci initialise FILE_TYPE.ID à -1 et IS_DEFAULT_IO à FALSE.

#### Affectation de record complet (NOUVEAU)

- **CODE_ASSIGN** dans instructions.adb : nouveau cas DN_RECORD
  (avec résolution DN_L_PRIVATE/DN_PRIVATE). Copie par BLKMOV.
  Convention BLKMOV : pile = [@DST, LEN, @SRC] (DST empilé en
  premier, SRC en dernier = au sommet).
  ```
  LOAD_MEM(DEFN)                          -- @DST
  LI  STANDARD.TEXT_IO.FILE_TYPE.size     -- LEN (constante FASM)
  CODE_EXP(SRC_EXP)                       -- @SRC
  BLKMOV
  ```

#### Convention du doublet et accès aux champs de record (CRITIQUE)

**Convention d'adressage des composites :**
- Un record/array est représenté par un doublet dans le frame :
  `VAR name_disp, q` (pointeur vers les données)
  `VAR name__u, q`   (pointeur vers les useinfo du type)
- Le passage de paramètre composite empile l'adresse du **doublet**
  (= adresse de `_disp` dans le frame) via `LVa lvl, name_disp`.
- `_disp` **contient** l'adresse des données (`__dat`).

**Double déréférencement pour les paramètres (CRITIQUE) :**
- Pour accéder à un champ via un paramètre, il faut un niveau
  d'indirection supplémentaire par rapport à une variable locale :
  - **Variable locale** : `LIVa lvl, name_disp, FIELD` (1 déréf)
    car `_disp` dans le frame contient directement l'adresse de `__dat`.
  - **Paramètre** : `La lvl, -name_ofs` puis `LIVa -1, 0, FIELD`
    (2 déréf) car le paramètre contient l'adresse du doublet, pas
    l'adresse des données.
- **ATTENTION** : cette distinction est dans PROCESS_DESIGNATOR de
  CODE_SELECTED (expander-expressions.adb). Ne pas perdre cette
  modification lors d'éditions futures !

#### Retour de fonction (AMÉLIORÉ)

- **CODE_RETURN** dans instructions.adb : ajout des cas DN_RECORD,
  DN_L_PRIVATE, DN_PRIVATE (retourne l'adresse du doublet via Sa)
  et DN_ENUMERATION (pour IS_OPEN, etc.).
- **CODE_VC_ID** dans expressions.adb : les stubs DN_RECORD et
  DN_ARRAY remplacés par LOAD_MEM (charge l'adresse du doublet).
- **CODE_PARAM_S** dans declarations.adb : ne plus court-circuiter
  pour les fonctions sans paramètres — il faut le PRM result__ofs.

#### Opérateurs et comparaisons (NOUVEAU)

- **CODE_DN_BLTN_OPERATOR_ID** : ajout de `MOD` et `REM`
  (en majuscules — le symrep DIANA stocke les opérateurs mot-clé
  en majuscules). Accepte aussi DN_OPERATOR_ID en plus de
  DN_BLTN_OPERATOR_ID. Correction `CIE` → `CLE`.
- **Macros LLIR ajoutées dans codi_x86_64.finc** :
  - `CLT` (setl, 0x9C), `CLE` (setle, 0x9E), `CNE` (setne, 0x95)
  - `MODI` (modulo Ada avec ajustement de signe)
  - `REMI` (reste de division tronquée, natif x86 idiv)

#### Slice de tableau (NOUVEAU)

- **CODE_SLICE** dans expressions.adb : ajout du cas
  DN_USED_OBJECT_ID. Empile l'adresse de début du slice :
  `La lvl, STR_disp` puis ajuste par `(EXP1 - FST_1) * COMP_SIZ`.
- **CODE_FIRST_LAST** : utilise le nom du **type** (via
  XD_SOURCE_NAME de SM_EXP_TYPE) au lieu du nom de la variable
  pour qualifier FST_1/LST_1 dans le namespace.

#### Variables de packages instanciés (PARTIEL)

- **LOAD_MEM** dans utils.adb : préfixage conditionnel avec
  REGIONS_PATH quand `DEFN_LVL >= CUR_LEVEL` et `XD_REGION` est
  un DN_PACKAGE_ID. Ceci permet l'accès aux variables de packages
  frères (comme NAT_IO.DEFAULT_BASE depuis string_test).
- **Piège** : la condition doit être `>=` (pas `<` ni inconditionnelle)
  sinon les accès internes au package TEXT_IO cassent.

#### Bug BOOLEAN CD_IMPL_SIZE (CONTOURNÉ)

- `_standrd.ads` déclare `for BOOLEAN'size use 1` (1 bit).
  C'est correct pour la sémantique. L'expander arrondit à l'octet
  dans TRAITER_LES_CHAMPS : si `COMP_SIZE < STORAGE_UNIT` alors
  `COMP_SIZE := STORAGE_UNIT`. Le STATOFS est donc en octets (min 1).


### Acquis de la session 10 avril après-midi 2026

#### CODE_CONVERSION et CODE_QUALIFIED (NOUVEAU)

- **CODE_CONVERSION** dans expressions.adb : était `null`, maintenant
  implémenté. Teste SM_VALUE pour le cas statique (→ `LI valeur`),
  sinon génère `CODE_EXP(AS_EXP)`. Pour entier↔entier et entier↔enum
  c'est un no-op (même représentation). Placeholder pour float/fixed.
- **CODE_QUALIFIED** : même pattern que CODE_CONVERSION.
- **Utilisé par** : `NUM(BASE)` et `INTEGER(expr)` dans INTEGER_IO.PUT.

#### CODE_INDEXED — paramètres array (NOUVEAU, CRITIQUE)

- **CODE_INDEXED** dans expressions.adb : ajout de la distinction
  paramètre/variable locale pour les tableaux, même principe que
  PROCESS_DESIGNATOR dans CODE_SELECTED.
- Nouveau BOOLEAN `IS_PARAM` pour piloter le code dans la procédure
  INDEX imbriquée.
- **Variable locale** : `La lvl, NAME_disp` pour l'adresse des données,
  `LId lvl, NAME__u, TYPE.FST` pour les useinfo.
- **Paramètre** (`CLASS_PARAM_NAME`) :
  ```
  LVa  lvl, -NAME_ofs        ; adresse du doublet
  LIa  , , 0                 ; ptr_data = doublet[0]
  ```
  Pour les useinfo (FST, COMP_SIZ) :
  ```
  LVa  lvl, -NAME_ofs        ; adresse du doublet
  LIa  , , 8                 ; ptr_useinfo = doublet[ADDR_SIZE]
  Ld   , TYPE.FST_1          ; champ depuis useinfo
  ```
- **ATTENTION** : la syntaxe `LIa` utilise `LIa , , offset` (virgules
  vides pour lvl et disp), PAS `LIa -1, offset`.

#### CODE_FIRST_LAST — paramètres array (NOUVEAU, CRITIQUE)

- **CODE_FIRST_LAST** dans expressions.adb : ajout du cas
  `SM_EXP_TYPE = DN_ARRAY and SM_DEFN in CLASS_PARAM_NAME`.
  Même pattern que CODE_INDEXED pour accéder à FST/LST via
  le doublet du paramètre :
  ```
  LVa  lvl, -NAME_ofs
  LIa  , , 8
  Ld   , TYPE.FST_1    (ou .LST_1)
  ```
- Avant cette correction, `ITEM'FIRST` et `ITEM'LAST` sur un
  paramètre STRING ne généraient **rien** (la condition existante
  ne matchait que DN_CONSTRAINED_ARRAY ou DN_ARRAY+DN_CONSTANT_ID).

#### INTEGER_IO.PUT complet (NOUVEAU)

- **PUT(FILE, ITEM, WIDTH, BASE)** : entièrement réécrit dans
  text_io.adb. Support des bases 2–16 avec format `BASE#digits#`.
  Digits 0–9 via `'0'+digit`, digits A–F via `'A'+digit-10`.
  Padding à gauche avec espaces selon WIDTH.
  Signe négatif avant le préfixe base : `-16#1A#`.
- **PUT(ITEM, WIDTH, BASE)** : délègue à `PUT(DEFAULT_OUTPUT, ...)`.
- Utilise `NUM(BASE)` (CODE_CONVERSION) et `INTEGER(expr)`
  pour les opérations mod/div sur le type générique.

#### GET depuis fichier (NOUVEAU)

- **Architecture TEXT_IO GET restructurée** : la version avec FILE
  est désormais la version centrale. Les versions sans FILE
  délèguent via DEFAULT_INPUT/DEFAULT_OUTPUT :
  - `GET(CHAR)` → `GET(DEFAULT_INPUT, CHAR)`
  - `GET(STRING)` → `GET(DEFAULT_INPUT, STRING)`
  - `GET_LINE(ITEM, LAST)` → `GET_LINE(DEFAULT_INPUT, ITEM, LAST)`
  - `PUT(CHAR)` → `PUT(DEFAULT_OUTPUT, CHAR)` (inchangé)
  - `PUT(STRING)` → `PUT(DEFAULT_OUTPUT, STRING)` (inchangé)
- **GET(FILE, CHARACTER)** : test `FILE.ID = -1` pour console
  (`SYS_GET_CHAR`) ou fichier (`SYS_FILE_READ` via READ_SYSTEM_CALL).
  Attention offset : `La 1, -16` pour le paramètre `out` CHARACTER
  (charge l'adresse destination, pas l'adresse de l'emplacement).
- **GET(FILE, STRING)** : console = boucle char-par-char via
  `GET(FILE, ITEM(I))`. Fichier = `SYS_FILE_READ` en bloc via
  READ_SYSTEM_CALL. Offset ITEM = -16 (2e paramètre).
- **GET_LINE(FILE, ITEM, LAST)** : boucle char-par-char uniforme
  (console et fichier) via `GET(FILE, CH)`. S'arrête au LF,
  ignore les CR. Plus de code MACHINE_CODE inline dans GET_LINE.
- **INTEGER_IO.GET(FILE, ITEM, WIDTH)** : parse via GET_LINE
  puis conversion digits en NUM. Gère signe +/-, espaces de tête.

#### Programme de test IO_TEST (VALIDÉ)

Résultat correct sur toutes les sections :
- Écriture fichier explicite + relecture GET_LINE
- SET_OUTPUT redirection vers fichier + relecture
- INTEGER_IO bases 10/16/2/8, négatifs, WIDTH, zéro
- INTEGER_IO écriture fichier + relecture


### Ce qui manque — par priorité révisée

#### Priorité 1 : compléter TEXT_IO

1. ~~**INTEGER_IO.PUT complet**~~ — FAIT.
2. ~~**GET depuis fichier**~~ — FAIT.
3. **Retour de slice par une fonction** : NAME(FILE) retourne
   `FILE.NAME(1..FILE.NAME_LEN)` — slice en retour de fonction.
   Nécessite que le mécanisme de retour gère les unconstrained arrays.
   CODE_RETURN pour DN_ARRAY est quasi-vide (lignes EMIT commentées).
4. **SKIP_LINE (version FILE)**, END_OF_LINE, END_OF_FILE, END_OF_PAGE
   — corps vides ou incomplets.
5. **DN_RANGE_ATTRIBUTE** : `ITEM'RANGE` dans un `for` provoque une
   erreur expander (cherche AS_EXP1 inexistant). Contournement :
   écrire `ITEM'FIRST .. ITEM'LAST`.

#### Priorité 2 : compléter l'EXPANDER

6. **Records avec discriminants dynamiques** : commentaire
   `; OFFSET NON STATIQUE A FAIRE` dans TRAITER_LES_CHAMPS.
7. **Unconstrained arrays** (DN_ARRAY) : CODE_UNCONSTRAINED_ARRAY_DECL
   moins avancé que constrained. Crucial pour STRING.
8. **Types access** (DN_ACCESS) : CODE_ACCESS_DECL est vide.
9. **Flottants** (DN_FLOAT, DN_FIXED) : vide.
10. **Tâches** (DN_TASK_BODY) : vide. Reporté.
11. **Exceptions** : handlers incomplets.
12. **Dérivation de types** (DN_DERIVED_DEF) : vide.
13. **Renames** : pas vu le contenu.
14. **FLOAT_IO, FIXED_IO, ENUMERATION_IO** : corps vides.


## 2. Architecture de l'EXPANDER (7 fichiers)

```
expander.adb                  Programme principal + CODE_ROOT
  ├── package UTILS           Constantes, types, utilitaires
  │   └── body separate       expander-utils.adb
  ├── package EXPRESSIONS     CODE_EXP, CODE_NAME, etc.
  │   └── body separate       expander-expressions.adb
  ├── package DECLARATIONS    CODE_DECL, CODE_HEADER, etc.
  │   ├── body separate       expander-declarations.adb
  │   └── package TYPES_DECLS CODE_TYPE_DECL, CODE_RECORD_DECL, etc.
  │       └── body separate   expander-declarations-types_decls.adb
  ├── package INSTRUCTIONS    CODE_STM_S, CODE_ASSIGN, etc.
  │   └── body separate       expander-instructions.adb
  └── package STRUCTURES      CODE_COMPILATION_UNIT, CODE_BLOCK_BODY
      └── body separate       expander-structures.adb
```


## 3. Conventions LLIR à retenir

- **Pile croissante** (RBP vers le haut). Paramètres sous le FP
  (offsets négatifs). Variables locales au-dessus (offsets positifs
  via VARzone virtual).
- **Display** à R15 : 32 niveaux lexicaux, `FP(lvl) = [R15 + 8*lvl]`.
- **Co-pile** (R14/R13) : pour les allocations dynamiques. Frame
  créé par LINK, libéré par UNLINK.
- **Tailles** : b=1 octet, w=2, d=4 (entiers), q=8 (adresses,
  quadwords). Le suffixe 'a' = 'q' (adresse = qword sur x86-64).
- **Strings Ada** : descripteur `[ptr_data qword | ptr_info qword]` +
  bloc info `[SIZ dword | COMP_SIZ dword | FST dword | LST dword]` +
  données.
- **Records statiques** : STATOFS dans `virtual at 0`, `size = $`
  avant `end virtual`. Accès via LIVa avec offset du champ.
- **Doublet composite** : `_disp` (ptr données) + `__u` (ptr useinfo).
  Passage paramètre = adresse du doublet. Accès champ via paramètre
  nécessite double déréférencement (La puis LIVa -1).
- **Namespaces FASM** : chaque package/type crée un namespace.
  Variables de packages frères (instances génériques) nécessitent
  chemin qualifié (REGIONS_PATH).
- **Résolution différée** : `postpone` + `if ~definite` pour les
  labels de procédures. `if defined X_` pour l'assemblage conditionnel.
- **BLKMOV** : convention pile = [@DST, LEN, @SRC] (macro POP_RSI,
  POP_RCX, POP_RDI). Copie octet par octet sans recouvrement.
- **Opérateurs mot-clé** : stockés en MAJUSCULES dans le symrep DIANA
  (`"MOD"`, `"REM"`, `"ABS"`, `"NOT"`, etc.).
- **Comparaisons signées** : CGT(>), CGE(>=), CEQ(=), CLT(<),
  CLE(<=), CNE(/=). Toutes suivent le pattern `cmp [rbp], rbx`
  puis `setcc [rbp]`.
- **Syntaxe LIa** : pour pop-et-déréf depuis la pile, utiliser
  `LIa , , offset` (virgules vides), PAS `LIa -1, offset`.


## 4. TEXT_IO — état actuel

TEXT_IO.FINC est maintenant **généré par l'EXPANDER** (plus écrit
à la main). Le fichier compile, assemble et fonctionne.

### Architecture des GET/PUT

Principe : la version avec FILE est la version **centrale** qui fait
le travail (test `FILE.ID = -1` pour console/fichier). Les versions
sans FILE sont de simples délégations :

| Sans FILE            | Délègue à                           |
|----------------------|-------------------------------------|
| `GET(CHAR)`          | `GET(DEFAULT_INPUT, CHAR)`          |
| `GET(STRING)`        | `GET(DEFAULT_INPUT, STRING)`        |
| `GET_LINE(ITEM,LAST)`| `GET_LINE(DEFAULT_INPUT,ITEM,LAST)` |
| `PUT(CHAR)`          | `PUT(DEFAULT_OUTPUT, CHAR)`         |
| `PUT(STRING)`        | `PUT(DEFAULT_OUTPUT, STRING)`       |

Ceci garantit que `SET_INPUT`/`SET_OUTPUT` affecte toutes les
versions sans FILE automatiquement.

### Procédures testées et fonctionnelles

- CREATE, OPEN, CLOSE, DELETE
- SET_OUTPUT, SET_INPUT (copie record par BLKMOV)
- SET_LINE_LENGTH (2), SET_PAGE_LENGTH (2)
- LINE_LENGTH (2), PAGE_LENGTH (2)
- SET_COL (2), SET_LINE (2), COL (2), LINE (2), PAGE (2)
- NEW_LINE (2 versions — avec/sans FILE)
- PUT(FILE, CHAR), PUT(CHAR)
- PUT(FILE, STRING), PUT(STRING)
- PUT_LINE (2 versions)
- GET(FILE, CHAR), GET(CHAR) — console SYS_GET_CHAR, fichier SYS_FILE_READ
- GET(FILE, STRING), GET(STRING) — console boucle char, fichier SYS_FILE_READ
- GET_LINE(FILE, ITEM, LAST), GET_LINE(ITEM, LAST) — boucle char-par-char
- STANDARD_INPUT, STANDARD_OUTPUT, CURRENT_INPUT, CURRENT_OUTPUT
- IS_OPEN, MODE
- INTEGER_IO.GET(FILE, ITEM), INTEGER_IO.GET(ITEM) — console et fichier
- INTEGER_IO.PUT(FILE, ITEM, WIDTH, BASE) — complet bases 2–16
- INTEGER_IO.PUT(ITEM, WIDTH, BASE)

### Procédures à compléter

- NAME(FILE) — retour de slice (STRING) — nécessite CODE_RETURN pour DN_ARRAY
- SKIP_LINE (version FILE), END_OF_LINE, END_OF_FILE, END_OF_PAGE
- INTEGER_IO.GET(FROM:STRING), INTEGER_IO.PUT(TO:STRING) — versions string
- FLOAT_IO, FIXED_IO, ENUMERATION_IO — tous les corps vides


## 5. Fichiers à uploader pour la prochaine session

Pour travailler sur TEXT_IO et l'expander :

1. `src/expander/expander-expressions.adb` — CODE_INDEXED, CODE_FIRST_LAST,
   CODE_CONVERSION, CODE_QUALIFIED, CODE_ATTRIBUTE, CODE_SLICE
2. `src/expander/expander-instructions.adb` — CODE_ASSIGN, CODE_RETURN
3. `src/expander/expander-declarations.adb` — COMPILE_RECORD_VAR, CODE_PARAM
4. `src/expander/expander-utils.adb` — LOAD_MEM, STORE
5. `src/expander/expander-declarations-types_decls.adb` — si on touche aux types
6. `text_io.adb` et `text_io.ads` — le module TEXT_IO
7. Le programme de test (io_test.adb ou string_test.adb)
8. Optionnellement `src/expander/fasmg/codi_x86_64.finc` — pour les macros LLIR


## 6. Pièges identifiés (à ne pas oublier)

1. **Double déréférencement paramètre composite** : dans
   PROCESS_DESIGNATOR (CODE_SELECTED), CODE_INDEXED et CODE_FIRST_LAST,
   le cas `CLASS_PARAM_NAME` doit utiliser `LVa lvl, -name_ofs`
   (pas `La`) pour charger l'adresse du doublet. Pour les useinfo :
   `LIa , , 8` puis `Ld , TYPE.FST` (pas `LId -1, 0, TYPE.FST`).
   NE PAS PERDRE cette distinction lors d'éditions futures.

2. **Syntaxe LIa** : `LIa , , offset` avec virgules vides.
   PAS `LIa -1, offset`. La syntaxe `-1` ne fonctionne pas.

3. **Préfixage REGIONS_PATH dans LOAD_MEM** : condition
   `DEFN_LVL >= CUR_LEVEL and XD_REGION = DN_PACKAGE_ID`.
   Si la condition est trop large, les accès internes à TEXT_IO cassent.

4. **Opérateurs en majuscules** : `"MOD"`, `"REM"`, pas `"mod"`.

5. **Fichiers uploadés** : toujours uploader les versions du
   **github** (post-commit), pas les versions locales non commitées.

6. **Ada 83 strict** : compiler avec `-gnat83`. Pas de `in out`
   sur fonctions, pas de pragmas Ada 95, etc.

7. **STATOFS arrondi** : si CD_IMPL_SIZE < STORAGE_UNIT (8 bits),
   arrondir à STORAGE_UNIT. Cas typique : BOOLEAN (1 bit → 1 octet).

8. **Fonctions sans paramètres** : CODE_PARAM_S ne doit pas
   court-circuiter si FOR_FUNCTION = TRUE (il faut PRM result__ofs).

9. **DN_RANGE_ATTRIBUTE** : `ITEM'RANGE` dans un for loop n'est pas
   géré par l'expander. Contournement : `ITEM'FIRST .. ITEM'LAST`.

10. **Offsets paramètres dans MACHINE_CODE** : pour GET(FILE, ITEM),
    FILE est à -8 (1er param), ITEM à -16 (2e param). Pour un
    paramètre `out` scalaire, utiliser `La` (pas `LA`) pour charger
    l'adresse destination. `LA` calcule l'adresse de l'emplacement,
    `La` charge le contenu (= l'adresse destination).

11. **Versions GET/PUT sans FILE** : toujours déléguer à la version
    avec FILE via DEFAULT_INPUT/DEFAULT_OUTPUT. Ne jamais mettre de
    code MACHINE_CODE inline dans les versions sans FILE (problèmes
    de symboles _disp/_ofs et sémantique de SET_INPUT/SET_OUTPUT).


## 7. Prochain chantier

Options possibles :
- **SKIP_LINE, END_OF_LINE, END_OF_FILE** — compléter les corps vides
- **NAME(FILE)** — nécessite retour de slice (CODE_RETURN DN_ARRAY)
- **Unconstrained arrays** — fondation pour STRING en général
- **Types access** — pointeurs, NEW, UNCHECKED_DEALLOCATION
