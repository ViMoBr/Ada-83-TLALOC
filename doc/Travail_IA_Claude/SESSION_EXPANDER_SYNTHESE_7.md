# SESSION EXPANDER — Synthèse et point de départ

**Date** : avril 2026 (mise à jour après sessions des 9, 10, 11, 12 et 13 avril)
**Objectif** : compléter l'EXPANDER du compilateur TLALOC
**Objectif élargi** : implémenter le chapitre 14 du LRM Ada 83 (I/O)


## 1. État des lieux de l'EXPANDER

### Ce qui fonctionne (acquis antérieurs + sessions 9-13 avril)

- **Types scalaires** : entiers (DN_INTEGER), énumérations (DN_ENUMERATION),
  sous-types entiers et énumérations — génération complète avec namespace,
  SIZ, FST, LST.
- **Types flottants (DN_FLOAT)** : CODE_FLOAT_DECL implémenté (namespace +
  CST SIZ). OPER_SIZ_CHAR et EXP_TYPE_CHAR forcent 'q' (qword 64 bits)
  pour tout DN_FLOAT, indépendamment de CD_IMPL_SIZE. TYPE_SIZE renvoie
  ADDR_SIZE (8 octets). Convention : tous les flottants sont représentés
  en IEEE 754 double 64 bits sur la pile entière.
- **Constrained arrays** : traitement multi-dimensionnel récursif via
  PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC, calcul de taille statique/dynamique,
  descripteurs avec USEINFO et offsets virtual.
- **Records statiques** : champs via STATOFS dans un `virtual at 0`,
  USEINFO pour les infos de type des champs. Initialisation par défaut
  des champs (COMPILE_RECORD_VAR). Affectation complète par BLKMOV.
- **Variables** : déclaration VAR, initialisation, accès Ld/Sd avec
  niveau lexical et déplacement. Variables flottantes via Lq/Sq.
- **Sous-programmes** : PRO/ELB/UNLINK/RTD/endPRO complet. Paramètres
  via PRMS/PRM/endPRMS. Convention : `in` scalaire par copie valeur,
  `out`/`in out` et composites par adresse (LVA). Pour les fonctions,
  `PRM result__ofs` est déclaré **en dernier** (après les paramètres Ada).
- **Appels** : CALL avec résolution différée, `if defined ... end if`
  pour n'assembler que les procédures effectivement appelées.
  INVERSE_RECURSE_ON_PARAMETERS pour l'ordre d'empilement.
  Propagation correcte des paramètres `out`/`in out` englobants vers
  les appels internes (session 13 avril).
- **Instructions** : if/then/else (BT/BF/BRA), boucles for/while/loop,
  case, exit, return, goto, assign, null_stm, procedure_call.
  Boucle while corrigée (BF, pas BRZ).
  CODE_ASSIGN et STORE_VAL gèrent DN_FLOAT.
- **Blocs declare** : CODE_BLOCK émet UNLINK à la sortie du bloc
  pour restaurer le display et la pile (session 13 avril).
- **Expressions** : numeric_literal, string_literal, used_object_id,
  used_char, used_op, **short_circuit** (and then / or else), parenthesized,
  conversion, qualified, function_call, indexed, selected, attribute,
  membership.
  CODE_SHORT_CIRCUIT implémenté (session 12 avril) : DUP + BF/BT + DROP
  pour évaluation conditionnelle.
  CODE_CONVERSION : CVTIF (entier→float) et CVTFI (float→entier,
  troncature) dans les deux chemins (statique et dynamique).
  CODE_DN_BLTN_OPERATOR_ID : dispatch float/entier via IS_FLOAT
  (test SM_EXP_TYPE = DN_FLOAT sur FUNCTION_CALL ou PRM_1 pour les
  comparaisons dont le résultat est BOOLEAN).
  NOT booléen via LI 1 + OUX.
- **Attributs** : 'FIRST, 'LAST, 'LENGTH fonctionnels.
  'DIGITS implémenté (lecture SM_ACCURACY du DN_FLOAT, fallback à 6
  pour les paramètres formels génériques).
- **Paramètres composites** : distinction variable locale / paramètre
  dans CODE_INDEXED, CODE_FIRST_LAST et PROCESS_DESIGNATOR.
  Pattern paramètre array : `LVa lvl, -NAME_ofs` / `LIa , , 8` / `Ld , TYPE.FST`.
- **Types privés** : DN_PRIVATE / DN_L_PRIVATE / DN_INCOMPLETE différés.
- **Génériques** : instanciation de packages génériques (INTEGER_IO et
  FLOAT_IO fonctionnels). Mécanisme GFP_disp pour les paramètres formels.
  Wrapper d'instanciation corrigé : `La` pour composites et out/in_out,
  `Lq` uniquement pour les `in` scalaires (session 13 avril).
- **Packages** : namespace FASM, elab_spec, body.
- **Stubs/subunits** : include du .FINC correspondant.
- **With/use** : génération des `include 'X.FINC'`.
- **Code statements** : package MACHINE_CODE avec ASM_OPCODE.
- **Exceptions** : squelette présent mais handlers incomplets.


## 2. Macros CODI_x86_64 — SSE2 flottant (session 11 avril)

### Convention flottante LLIR

Les flottants IEEE 754 double 64 bits transitent par la **pile entière**
(qword) exactement comme les entiers. Les macros SSE2 chargent/déchargent
depuis la pile vers les registres xmm0/xmm1 pour les opérations.
Transferts pile↔xmm via `movsd` (F2 0F 10/11), toujours 64 bits.

FLOAT (32 bits nominal dans STANDARD) et LONG_FLOAT (64 bits) sont tous
deux stockés en double 64 bits — OPER_SIZ_CHAR force 'q' pour DN_FLOAT.

### Macros ajoutées (15)

| Macro | Rôle | Encodage x86-64 |
|-------|------|-----------------|
| LIF val | Load Immediate Float | movabs rax, dq val + PUSH_RAX |
| FADD | Addition | movsd + addsd xmm0,xmm1 + movsd |
| FSUB | Soustraction | movsd + subsd + movsd |
| FMUL | Multiplication | movsd + mulsd + movsd |
| FDIV | Division | movsd + divsd + movsd |
| FNEG | Négation | xor byte [rbp+7], 0x80 |
| FABS | Valeur absolue | and byte [rbp+7], 0x7F |
| FEXP | Exponentiation A**N | boucle mulsd (N entier) |
| CVTIF | Entier→double | cvtsi2sd xmm0,rax + movsd |
| CVTFI | Double→entier | movsd + cvttsd2si (troncature) |
| FCEQ | A = B | ucomisd + sete + setnp + and |
| FCNE | A /= B | ucomisd + setne + setp + or |
| FCGT | A > B | ucomisd xmm0,xmm1 + seta |
| FCGE | A >= B | ucomisd xmm0,xmm1 + setae |
| FCLT | A < B | ucomisd xmm1,xmm0 + seta |
| FCLE | A <= B | ucomisd xmm1,xmm0 + setae |

### Pièges encodage SSE2 rencontrés

- `dq double val` : fasmg ne supporte pas `double`, utiliser `dq val`
- `dq 0x8000000000000000` : fasmg tronque les constantes hex 64 bits,
  écrire les octets en `db` little-endian
- `movq xmm, [rbp]` : ambigu avec movd (32 bits) dans certains contextes,
  **toujours utiliser `movsd`** (F2 0F 10/11) pour les transferts mémoire↔xmm
- FCLT/FCLE : `ucomisd xmm1, xmm0` → ModRM = 0xC8 (pas 0xC9 qui
  donnerait ucomisd xmm1, xmm1)
- FNEG/FABS : opérer directement sur l'octet de signe [rbp+7] en
  little-endian, pas via masque 64 bits


## 3. TEXT_IO — état actuel (LRM 14.3)

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

**FLOAT_IO (LRM 14.3.8) — sessions 11-13 avril :**
- PUT(FILE, ITEM, FORE, AFT, EXP) — format `[-]d.dddE[+|-]dd` ✓
- PUT(ITEM, FORE, AFT, EXP) — délègue à PUT(DEFAULT_OUTPUT,...) ✓
- GET(FILE, ITEM, WIDTH) — parse complet, **validé depuis fichier** ✓
- GET(ITEM, WIDTH) — délègue à GET(DEFAULT_INPUT,...) ✓ (corrigé session 13)
- GET(FROM:STRING), PUT(TO:STRING) — corps vides
- DEFAULT_FORE=2, DEFAULT_AFT=NUM'DIGITS-1, DEFAULT_EXP=3 — fonctionnels ✓


### 3.1 Bugs corrigés session 13 avril

#### Bug 1 (corrigé) : FIO.PUT(FILE,...) corrompt le record FILE_TYPE

**Causes** (deux bugs combinés) :

**(a) Wrapper générique `Lq` au lieu de `La` pour composites** :
dans `INVERSE_RECURSE_NAMES` (expander-declarations.adb), le wrapper
d'instanciation utilisait `Lq` (charge la valeur) pour **tous** les
paramètres. Pour un `in` composite (FILE_TYPE record), il fallait `La`
(propager l'adresse). Pour `out`/`in out`, il fallait aussi `La`.

**Correctif** : distinguer `(DN_IN_ID and CLASS_SCALAR)` → `Lq` (valeur),
sinon → `La` (adresse).

**(b) UNLINK manquant dans CODE_BLOCK** : un bloc `declare...begin...end`
émettait `ELB N` (= `LINK N`) pour allouer les variables locales et
mettre à jour le display, mais n'émettait jamais le `UNLINK N`
correspondant à la sortie du bloc. Le display restait corrompu.
FLOAT_IO.PUT contient un bloc `declare EXP_STR...` (BLOCK__20) qui
faisait `LINK 2` sans `UNLINK 2`. Au retour, le display[2] pointait
vers le frame de BLOCK__20 au lieu du frame du wrapper → le `UNLINK 2`
du wrapper opérait sur le mauvais frame → corruption de la pile.

**Correctif** : ajout de `UNLINK N` dans `CODE_BLOCK` avant `DEC_LEVEL`
et `endPRO`.

#### Bug 2 (corrigé) : FIO.GET(ITEM) sans FILE segfault

**Cause** : même bug (a) que Bug 1 — le wrapper passait `Lq` au lieu
de `La` pour le paramètre `out ITEM`. Le body recevait une valeur
(non initialisée) au lieu d'une adresse → écriture à l'adresse 0.

**Correctif** : même correctif que Bug 1(a).

#### Bug 3 (corrigé) : GET_LINE console ne lit rien

**Cause** : GET_LINE appelait `GET(FILE, CH)` caractère par caractère.
Pour la console, GET utilise SYS_GET_CHAR qui désactive ICANON et ECHO
pour chaque caractère → pas d'écho, aller-retours termios problématiques.

**Correctif** : ajout d'un `if FILE.ID = -1` dans GET_LINE qui utilise
directement SYS_GET_STR (sys_read en mode canonique avec écho) pour la
console. La boucle par GET(FILE, CH) est conservée pour les fichiers.

```ada
if  FILE.ID = -1  then
  ASM_OP_2'( OPCODE => La, LVL => 1, OFS => -24 );   -- push @LAST
  ASM_OP_2'( OPCODE => La, LVL => 1, OFS => -16 );   -- push @ITEM
  ASM_OP_0'( OPCODE => SYS_GET_STR );
else
  -- boucle GET(FILE, CH) pour fichiers
end if;
```

#### Bug 4 (corrigé) : propagation param out/in_out dans INVERSE_RECURSE_ON_PARAMETERS

**Cause** : dans `CODE_PROCEDURE_CALL`, quand le paramètre actuel est
un paramètre `out` ou `in out` de la procédure englobante (DN_OUT_ID
ou DN_IN_OUT_ID), il n'y avait pas de branche pour le traiter. Le code
tombait dans le `else` → message d'erreur au lieu de code.

**Correctif** : ajout de la branche `DN_OUT_ID / DN_IN_OUT_ID` avec
deux sous-cas selon le paramètre formel cible :
- `out/inout → out/inout` : `La lvl, -NAME_ofs` (propager l'adresse)
- `out/inout → in` : `LI_siz lvl, -NAME_ofs` (déréférencer via load indirect)


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


## 4. Ce qui manque — Feuille de route chapitre 14

### Phase 1 : compléter TEXT_IO (LRM 14.3)

#### 1.1 Compléter INTEGER_IO
- GET(FROM:STRING, ITEM, LAST) — parse depuis une chaîne
- PUT(TO:STRING, ITEM, BASE) — formater dans une chaîne

#### 1.2 FLOAT_IO — compléter
- GET(FROM:STRING, ITEM, LAST) — parse depuis une chaîne
- PUT(TO:STRING, ITEM, AFT, EXP) — formater dans une chaîne
- Arrondi Ada 83 : CVTFI fait troncature, Ada 83 veut arrondi au plus
  proche pour INTEGER(float). Ajouter macro CVTFIR si nécessaire.
- 'DIGITS : résoudre proprement via chaîne générique (actuellement
  fallback à 6 pour les paramètres formels)

#### 1.3 Implémenter FIXED_IO (LRM 14.3.9)
- Nécessite le support des **points fixes** (DN_FIXED).
- Même structure que FLOAT_IO.

#### 1.4 Implémenter ENUMERATION_IO (LRM 14.3.10)
- PUT : écrire le nom de l'énuméré (nécessite table de noms runtime)
- GET : lire et identifier un nom d'énuméré
- Support UPPER_CASE / LOWER_CASE (TYPE_SET)
- **Point dur** : accès aux noms d'énumérés à l'exécution.
  Les CST des littéraux sont déjà générés dans CODE_ENUM_LITERAL_S.
  La question du passage des noms d'énumérés sous forme d'un bloc
  STRING Ada (plutôt que chaînes Pascal via CST) est à l'étude.
  Pourrait nécessiter le retour d'array non contraint comme pour NAME.

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
| Retour de slice (DN_ARRAY) | CODE_RETURN | NAME(FILE), ENUMERATION_IO |
| Points fixes (DN_FIXED) | types_decls, expressions | FIXED_IO |
| Unconstrained arrays | CODE_UNCONSTRAINED_ARRAY_DECL | STRING général |
| DN_RANGE_ATTRIBUTE | expressions | for I in X'RANGE |
| Records à discriminants | TRAITER_LES_CHAMPS | Offset dynamique |
| Types access (DN_ACCESS) | CODE_ACCESS_DECL | NEW, pointeurs |
| Exceptions handlers | instructions | Catch/raise |
| Dérivation (DN_DERIVED_DEF) | types_decls | Types dérivés |
| Renames | declarations | Renommage |
| Tâches (DN_TASK_BODY) | structures | Reporté |


## 5. Architecture de l'EXPANDER (7 fichiers)

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


## 6. Conventions LLIR à retenir

- **Pile croissante** (RBP vers le haut). Paramètres sous le FP
  (offsets négatifs). Variables locales au-dessus (offsets positifs).
- **Display** à R15 : 32 niveaux lexicaux.
- **Co-pile** (R14/R13) : allocations dynamiques.
- **Tailles** : b=1, w=2, d=4, q=8. Suffixe 'a' = 'q'.
- **Flottants** : toujours qword (q) sur la pile, IEEE 754 double 64 bits.
  FLOAT (CD_IMPL_SIZE=32) et LONG_FLOAT (64) tous deux en double.
- **Short-circuit** : `A and then B` → DUP, BF skip, DROP, eval B, skip:
  `A or else B` → DUP, BT skip, DROP, eval B, skip:
- **Doublet composite** : `_disp` + `__u`. Passage = adresse du doublet.
- **PRM result__ofs en dernier** dans les fonctions.
- **SD après syscall** : transférer `[rbp]` vers result__ofs.
- **NOT booléen** : `LI 1` + `OUX`. Pas `NON` (bitwise).
- **Syntaxe virgules vides** : `LIa , , offset` / `Ld , FIELD`.
- **Opérateurs mot-clé** : MAJUSCULES dans le symrep DIANA.
- **While** : `BF` (pas BRZ).
- **Fins de ligne Linux** : LF seul. CR ignoré. FF = saut de page.
- **Transferts flottants pile↔xmm** : toujours `movsd` (F2 0F 10/11),
  jamais `movq` (ambigu avec movd 32 bits dans certains contextes fasmg).
- **Blocs declare** : toujours `UNLINK N` avant de quitter le bloc.
- **Wrapper générique** : `La` pour composites et out/in_out, `Lq`
  uniquement pour les `in` scalaires.
- **postpone LIFO** : les `CST` en zone `postpone` sont placés en
  mémoire dans l'ordre inverse de leur émission.


## 7. Pièges identifiés

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
14. **fasmg `dq` hex 64 bits** : tronqué, écrire les octets en `db` LE.
15. **fasmg `movq xmm,[mem]`** : peut être interprété comme movd 32 bits,
    utiliser `movsd` (F2 0F 10/11) pour pile↔xmm.
16. **FCLT/FCLE encodage** : ucomisd xmm1,xmm0 = ModRM 0xC8 pas 0xC9.
17. **CODE_CONVERSION statique** : un LI suivi de CVTIF si cible DN_FLOAT.
18. **OPER_SIZ_CHAR DN_FLOAT** : forcer 'q' (CD_IMPL_SIZE=32 dans STANDARD
    mais on stocke toujours en double 64 bits).
19. **CODE_SHORT_CIRCUIT** : était un stub `null`, causait des BF/BT sans
    condition évaluée. Corrigé session 12 avril.
20. **Wrapper générique paramètres** : `Lq` pour tous → `La` pour
    composites et out/in_out. Corrigé session 13 avril.
21. **CODE_BLOCK sans UNLINK** : un bloc `declare` faisait LINK N sans
    UNLINK N correspondant → corruption du display au retour.
    Corrigé session 13 avril.
22. **Propagation out/in_out** : `INVERSE_RECURSE_ON_PARAMETERS` ne
    traitait pas DN_OUT_ID / DN_IN_OUT_ID → message d'erreur au lieu
    de code. Corrigé session 13 avril.
23. **GET_LINE console** : SYS_GET_CHAR en boucle → pas d'écho.
    Remplacé par SYS_GET_STR pour la console. Corrigé session 13 avril.
24. **postpone LIFO** : les CST émises en premier se retrouvent en
    dernier en mémoire. Ordre d'émission inverse requis pour obtenir
    un layout mémoire séquentiel.


## 8. Fichiers à uploader pour la prochaine session

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
=== 1. Constantes ===
 3.14158E+000                        LIF positif
-3.14158E+000                        LIF négatif (FNEG)
 0.00000E+000                        zéro
 1.00000E+000                        un
=== 2. Arithmetique ===
 5.50E+000                           FADD (2.5 + 3.0)
-5.00E-001                           FSUB (2.5 - 3.0)
 7.50E+000                           FMUL (2.5 * 3.0)
 8.3333E-001                         FDIV (2.5 / 3.0)
=== 3. Negation et abs ===
-7.50E+000                           FNEG
 7.50E+000                           double FNEG
 7.50E+000                           FABS
=== 4. Comparaisons ===
1.0 < 2.0 : OK                      FCLT
2.0 > 1.0 : OK                      FCGT
1.0 <= 1.0 : OK                     FCLE
1.0 >= 1.0 : OK                     FCGE
1.0 /= 2.0 : OK                     FCNE
2.0 = 2.0 : OK                      FCEQ
=== 5. Negatifs ===
-1.0 > -2.0 : OK                    FCGT négatifs
-2.0 < -1.0 : OK                    FCLT négatifs
=== 6. Conversion ===
 4.2E+001                            CVTIF (INTEGER→FLOAT)
=== 7. Grands/petits ===
 1.234567E+005                       grand nombre
 1.230000E-004                       petit nombre
=== FIN ===
```

### Test defaults (PUT sans paramètres, session 12 avril)

```
X=  3.14158E+000                     DEFAULT_FORE=2, DEFAULT_AFT=5, DEFAULT_EXP=3
Y= -3.14158E+000                     négatif avec defaults ('DIGITS fonctionne)
```

### GET_TEST (session 13 avril — FLOAT_IO fichier + console)

```
Entrez un flottant : 3.89
Lu : [3.89]
=== Test 1 : FIO.PUT 3.14159 dans fichier ===
Ecriture OK
=== Test 2 : FIO.GET depuis fichier ===
Relu depuis fichier :  3.141580E+000
=== Test 3 : verification GET_LINE ===
Contenu brut : [ 3.14158E+000]
=== Test 4 : FIO.PUT stdout ===
 2.71828E+000
```

Valide : FIO.PUT(FILE,...) + NEW_LINE(FILE) + CLOSE sans corruption,
FIO.GET(FILE, X) relecture, FIO.PUT stdout, GET_LINE console avec écho.
