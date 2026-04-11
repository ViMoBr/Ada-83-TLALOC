# SESSION EXPANDER — Synthèse et point de départ

**Date** : avril 2026 (mise à jour après sessions des 9, 10 et 11 avril)
**Objectif** : compléter l'EXPANDER du compilateur TLALOC
**Objectif élargi** : implémenter le chapitre 14 du LRM Ada 83 (I/O)


## 1. État des lieux de l'EXPANDER

### Ce qui fonctionne (acquis antérieurs + sessions 9-11 avril)

- **Types scalaires** : entiers (DN_INTEGER), énumérations (DN_ENUMERATION),
  sous-types entiers et énumérations — génération complète avec namespace,
  SIZ, FST, LST.
- **Constrained arrays** : traitement multi-dimensionnel récursif via
  PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC, calcul de taille statique/dynamique,
  descripteurs avec USEINFO et offsets virtual.
- **Records statiques** : champs via STATOFS dans un `virtual at 0`,
  USEINFO pour les infos de type des champs. Initialisation par défaut
  des champs (COMPILE_RECORD_VAR). Affectation complète par BLKMOV.
- **Variables** : déclaration VAR, initialisation, accès Ld/Sd avec
  niveau lexical et déplacement.
- **Sous-programmes** : PRO/ELB/UNLINK/RTD/endPRO complet. Paramètres
  via PRMS/PRM/endPRMS. Convention : `in` scalaire par copie valeur,
  `out`/`in out` et composites par adresse (LVA). Pour les fonctions,
  `PRM result__ofs` est déclaré **en dernier** (après les paramètres Ada).
- **Appels** : CALL avec résolution différée, `if defined ... end if`
  pour n'assembler que les procédures effectivement appelées.
  INVERSE_RECURSE_ON_PARAMETERS pour l'ordre d'empilement.
- **Instructions** : if/then/else (BT/BF/BRA), boucles for/while/loop,
  case, exit, return, goto, assign, null_stm, procedure_call.
  Boucle while corrigée (BF, pas BRZ).
- **Expressions** : numeric_literal, string_literal, used_object_id,
  used_char, used_op, short_circuit, parenthesized, conversion,
  qualified, function_call, indexed, selected, attribute, membership.
  CODE_CONVERSION et CODE_QUALIFIED implémentés (no-op entier↔entier/enum).
  NOT booléen via LI 1 + OUX.
- **Paramètres composites** : distinction variable locale / paramètre
  dans CODE_INDEXED, CODE_FIRST_LAST et PROCESS_DESIGNATOR.
  Pattern paramètre array : `LVa lvl, -NAME_ofs` / `LIa , , 8` / `Ld , TYPE.FST`.
- **Types privés** : DN_PRIVATE / DN_L_PRIVATE / DN_INCOMPLETE différés.
- **Génériques** : instanciation de packages génériques (INTEGER_IO
  fonctionnel). Mécanisme GFP_disp pour les paramètres formels.
- **Packages** : namespace FASM, elab_spec, body.
- **Stubs/subunits** : include du .FINC correspondant.
- **With/use** : génération des `include 'X.FINC'`.
- **Code statements** : package MACHINE_CODE avec ASM_OPCODE.
- **Exceptions** : squelette présent mais handlers incomplets.


## 2. TEXT_IO — état actuel (LRM 14.3)

TEXT_IO.FINC est **généré par l'EXPANDER**. Le fichier compile,
assemble et fonctionne. Programme de test IO_TEST validé (11 sections).

### Architecture des GET/PUT

Principe : la version avec FILE est la version **centrale** qui fait
le travail (test `FILE.ID = -1` pour console/fichier). Les versions
sans FILE sont de simples délégations :

| Sans FILE              | Délègue à                            |
|------------------------|--------------------------------------|
| `GET(CHAR)`            | `GET(DEFAULT_INPUT, CHAR)`           |
| `GET(STRING)`          | `GET(DEFAULT_INPUT, STRING)`         |
| `GET_LINE(ITEM,LAST)`  | `GET_LINE(DEFAULT_INPUT,ITEM,LAST)` |
| `PUT(CHAR)`            | `PUT(DEFAULT_OUTPUT, CHAR)`          |
| `PUT(STRING)`          | `PUT(DEFAULT_OUTPUT, STRING)`        |
| `SKIP_LINE(SPACING)`   | `SKIP_LINE(DEFAULT_INPUT, SPACING)` |
| `SKIP_PAGE`            | `SKIP_PAGE(DEFAULT_INPUT)`           |
| `END_OF_LINE`          | `END_OF_LINE(DEFAULT_INPUT)`         |
| `END_OF_PAGE`          | `END_OF_PAGE(DEFAULT_INPUT)`         |
| `END_OF_FILE`          | `END_OF_FILE(DEFAULT_INPUT)`         |

### FILE_TYPE (partie privée de text_io.ads)

```ada
type FILE_TYPE is record
  ID              : INTEGER        := -1;
  NAME            : FILE_NAME_BUFFER;
  NAME_LEN        : POSITIVE;
  IS_OPENED       : BOOLEAN        := FALSE;
  MODE            : FILE_MODE;
  PAGE_LENGTH, LINE_LENGTH,
  PAGE, LINE, COL : POSITIVE_COUNT;
  IS_DEFAULT_IO   : BOOLEAN        := FALSE;
  LOOK_AHEAD      : CHARACTER      := ASCII.NUL;
  HAS_LOOK_AHEAD  : BOOLEAN        := FALSE;
  AT_END_OF_FILE  : BOOLEAN        := FALSE;
end record;
```

### Procédures testées et fonctionnelles

**File Management (LRM 14.2.1) :**
- CREATE, OPEN, CLOSE, DELETE — avec syscalls Linux
- RESET(FILE, MODE), RESET(FILE) — via SYS_FILE_SET_POS (lseek)
- MODE, FORM, IS_OPEN — fonctionnels
- NAME — code Ada écrit mais retour de slice non implémenté dans l'expander
- SET_INPUT, SET_OUTPUT, STANDARD_INPUT/OUTPUT, CURRENT_INPUT/OUTPUT

**Line/Page/Column (LRM 14.3.4) :**
- NEW_LINE (2 versions), NEW_PAGE (2 versions)
- SKIP_LINE (2 versions), SKIP_PAGE (2 versions)
- END_OF_LINE, END_OF_PAGE, END_OF_FILE — avec mécanisme lookahead
- SET_LINE_LENGTH (2), SET_PAGE_LENGTH (2)
- LINE_LENGTH (2), PAGE_LENGTH (2)
- SET_COL (2), SET_LINE (2), COL (2), LINE (2), PAGE (2)

**Character/String I/O (LRM 14.3.5–14.3.6) :**
- GET(FILE, CHAR), GET(CHAR)
- PUT(FILE, CHAR), PUT(CHAR)
- GET(FILE, STRING), GET(STRING)
- PUT(FILE, STRING), PUT(STRING)
- GET_LINE (2 versions), PUT_LINE (2 versions)

**INTEGER_IO (LRM 14.3.7) :**
- GET(FILE, ITEM, WIDTH), GET(ITEM, WIDTH) — parse décimal avec signe
- PUT(FILE, ITEM, WIDTH, BASE), PUT(ITEM, WIDTH, BASE) — complet bases 2–16
- GET(FROM:STRING), PUT(TO:STRING) — corps vides

### Syscalls MACHINE_CODE — convention

Toute fonction MACHINE_CODE avec un syscall doit avoir un `SD` pour
transférer le résultat depuis `[rbp]` vers `result__ofs` :

| Syscall           | Convention pile              | SD offset |
|-------------------|------------------------------|-----------|
| SYS_FILE_CREATE   | @NAME_descriptor             | -16       |
| SYS_FILE_OPEN     | @NAME_descriptor             | -16       |
| SYS_FILE_CLOSE    | FILE_ID                      | -16       |
| SYS_FILE_DELETE   | @NAME_descriptor             | -16       |
| SYS_FILE_SET_POS  | OFFSET, FILE_ID              | -16       |
| SYS_FILE_READ     | LENGTH, @BUFFER, FILE_ID     | -16 ou -24|
| SYS_FILE_WRITE    | LENGTH, @BUFFER, FILE_ID     | -16 ou -24|


## 3. Ce qui manque — Feuille de route chapitre 14

### Phase 1 : compléter TEXT_IO (LRM 14.3)

#### 1.1 Compléter INTEGER_IO
- GET(FROM:STRING, ITEM, LAST) — parse depuis une chaîne
- PUT(TO:STRING, ITEM, BASE) — formater dans une chaîne

#### 1.2 Implémenter FLOAT_IO (LRM 14.3.8)
- Nécessite le support des **flottants** dans l'expander :
  CODE_FLOAT_DECL, opérations FPU (FADD, FSUB, FMUL, FDIV),
  conversion INTEGER↔FLOAT dans CODE_CONVERSION.
- PUT : format `[-]d.dddE[+|-]dd` avec FORE, AFT, EXP
- GET : parse d'un littéral flottant

#### 1.3 Implémenter FIXED_IO (LRM 14.3.9)
- Nécessite le support des **points fixes** (DN_FIXED).
- Même structure que FLOAT_IO.

#### 1.4 Implémenter ENUMERATION_IO (LRM 14.3.10)
- PUT : écrire le nom de l'énuméré (nécessite table de noms runtime)
- GET : lire et identifier un nom d'énuméré
- Support UPPER_CASE / LOWER_CASE (TYPE_SET)
- **Point dur** : accès aux noms d'énumérés à l'exécution

#### 1.5 Fonctions TEXT_IO restantes
- NAME(FILE) — retour de slice STRING (nécessite CODE_RETURN DN_ARRAY)
- SET_COL, SET_LINE — compléter selon LRM 14.3.4(28-40)

### Phase 2 : SEQUENTIAL_IO (LRM 14.2.3)

Package générique pour I/O séquentiel d'éléments de type quelconque.
Dépendances : instanciation générique avec type privé (fonctionne),
taille ELEMENT_TYPE à runtime, SYS_FILE_READ/WRITE avec taille variable.
Déjà utilisé : `GRMR_TBL_IO` dans les outils LALR.

### Phase 3 : DIRECT_IO (LRM 14.2.5)

Package générique pour I/O à accès direct par numéro d'élément.
Dépendances : mêmes que SEQUENTIAL_IO + SYS_FILE_SET_POS pour
le positionnement par index. Calcul offset : `(INDEX-1) * ELEMENT_SIZE`.

### Phase 4 : fondations expander à compléter au fil de l'eau

| Fonctionnalité | Où | Pour quoi |
|---|---|---|
| Retour de slice (DN_ARRAY) | CODE_RETURN | NAME(FILE) |
| Flottants (DN_FLOAT) | types_decls, expressions | FLOAT_IO |
| Points fixes (DN_FIXED) | types_decls, expressions | FIXED_IO |
| Unconstrained arrays | CODE_UNCONSTRAINED_ARRAY_DECL | STRING général |
| DN_RANGE_ATTRIBUTE | expressions | for I in X'RANGE |
| Records à discriminants | TRAITER_LES_CHAMPS | Offset dynamique |
| Types access (DN_ACCESS) | CODE_ACCESS_DECL | NEW, pointeurs |
| Exceptions handlers | instructions | Catch/raise |
| Dérivation (DN_DERIVED_DEF) | types_decls | Types dérivés |
| Renames | declarations | Renommage |
| Tâches (DN_TASK_BODY) | structures | Reporté |


## 4. Architecture de l'EXPANDER (7 fichiers)

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


## 5. Conventions LLIR à retenir

- **Pile croissante** (RBP vers le haut). Paramètres sous le FP
  (offsets négatifs). Variables locales au-dessus (offsets positifs).
- **Display** à R15 : 32 niveaux lexicaux.
- **Co-pile** (R14/R13) : allocations dynamiques.
- **Tailles** : b=1, w=2, d=4, q=8. Suffixe 'a' = 'q'.
- **Doublet composite** : `_disp` + `__u`. Passage = adresse du doublet.
- **PRM result__ofs en dernier** dans les fonctions.
- **SD après syscall** : transférer `[rbp]` vers result__ofs.
- **NOT booléen** : `LI 1` + `OUX`. Pas `NON` (bitwise).
- **Syntaxe virgules vides** : `LIa , , offset` / `Ld , FIELD`.
- **Opérateurs mot-clé** : MAJUSCULES dans le symrep DIANA.
- **While** : `BF` (pas BRZ).
- **Fins de ligne Linux** : LF seul. CR ignoré. FF = saut de page.


## 6. Pièges identifiés

1. Double déréférencement paramètre : `LVa` (pas `La`) pour le doublet.
2. Syntaxe virgules vides : `LIa , , ofs` pas `LIa -1, ofs`.
3. PRM result__ofs toujours en dernier dans PRMS.
4. SD après chaque SYS_FILE_* dans les fonctions MACHINE_CODE.
5. NOT booléen = `LI 1` + `OUX`, pas `NON`.
6. While = `BF`, pas `BRZ`.
7. REGIONS_PATH : condition `>= CUR_LEVEL`.
8. Opérateurs en MAJUSCULES.
9. Ada 83 strict (`-gnat83`).
10. STATOFS arrondi : BOOLEAN 1 bit → 1 octet.
11. DN_RANGE_ATTRIBUTE non géré : contournement FIRST..LAST.
12. Versions sans FILE : déléguer, pas de MACHINE_CODE inline.
13. Fichiers uploadés : toujours post-commit github.


## 7. Fichiers à uploader pour la prochaine session

1. `src/expander/expander-expressions.adb`
2. `src/expander/expander-instructions.adb`
3. `src/expander/expander-declarations.adb`
4. `src/expander/expander-utils.adb`
5. `src/expander/expander-declarations-types_decls.adb`
6. `text_io.adb` et `text_io.ads`
7. `sequential_io.ads` — spec existante
8. `direct_io.ads` — spec existante
9. `io_test.adb` — programme de test
10. `src/expander/fasmg/codi_x86_64.finc`


## 8. Programme de test IO_TEST — résultats validés

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
