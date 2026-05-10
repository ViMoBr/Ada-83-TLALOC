# SESSION EXPANDER — Synthèse et point de départ

**Date** : mai 2026 (mise à jour après sessions des 9, 10, 11, 12, 13, 15 et 25 avril, et 10 mai)
**Objectif** : compléter l'EXPANDER du compilateur TLALOC
**Objectif élargi** : implémenter le chapitre 14 du LRM Ada 83 (I/O)


## 1. État des lieux de l'EXPANDER

### Ce qui fonctionne (acquis antérieurs + sessions 9-15 et 25 avril)

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
  Propagation correcte des paramètres `out`/`in_out` englobants vers
  les appels internes (session 13 avril).
  **DN_ITERATION_ID** traité (session 25 avril) : les variables de boucle
  `for` sont empilées avec le nom FASM reconstruit via
  `LABEL_STR(CD_OFFSET)` + `"_disp"`.
- **Instructions** : if/then/else (BT/BF/BRA), boucles for/while/loop,
  case, exit, return, goto, assign, null_stm, procedure_call.
  Boucle while corrigée (BF, pas BRZ).
  CODE_ASSIGN et STORE_VAL gèrent DN_FLOAT.
  **CODE_ASSIGN** : branche `else` catch-all pour les types non reconnus
  (types formels génériques) — session 25 avril.
  **CODE_RETURN** : émet les UNLINK intermédiaires quand un `return` est
  dans un bloc `declare` (session 25 avril).
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
  **'POS, 'VAL** : identité (sans clause de représentation) —
  session 25 avril.
  **'PRED, 'SUCC** : DEC / INC — session 25 avril.
- **Paramètres composites** : distinction variable locale / paramètre
  dans CODE_INDEXED, CODE_FIRST_LAST et PROCESS_DESIGNATOR.
  Pattern paramètre array : `LVa lvl, -NAME_ofs` / `LIa , , 8` / `Ld , TYPE.FST`.
- **Types privés** : DN_PRIVATE / DN_L_PRIVATE / DN_INCOMPLETE différés.
- **Génériques** : instanciation de packages génériques (INTEGER_IO,
  FLOAT_IO et ENUMERATION_IO fonctionnels). Mécanisme GFP_disp pour
  les paramètres formels.
  Wrapper d'instanciation corrigé : `La` pour composites et out/in_out,
  `Lq` uniquement pour les `in` scalaires (session 13 avril).
  **Mécanisme LD/ST par CALLI** pour les paramètres `out` de types formels
  discrets : micro-procédures de taille correcte dans l'instance,
  appelées via CALLI (session 25 avril, voir section 2.1).
- **Packages** : namespace FASM, elab_spec, body.
- **Stubs/subunits** : include du .FINC correspondant.
- **With/use** : génération des `include 'X.FINC'`.
- **Code statements** : package MACHINE_CODE avec ASM_OPCODE.
  **ASM_OP_3** ajouté (session 15 avril) pour les accès indirects
  multi-niveaux (LIVa).
- **DIRECT_IO** : package générique LRM 14.2.5 compilé et validé (session
  10 mai). CREATE, OPEN, CLOSE, DELETE, RESET (2 versions), READ (2 versions),
  WRITE (2 versions), SET_INDEX, INDEX, SIZE, END_OF_FILE, IS_OPEN, MODE,
  NAME, FORM. Testé sur LONG_FLOAT (scalaire), type énuméré (byte), record
  contraint (POINT : 3 INTEGER), tableau contraint (VECTEUR : array 1..4 of
  INTEGER). Lectures/écritures séquentielles et positionnées validées.
  Mécanisme `ITEM'ADDRESS` + micro-procédure `ADR` pour l'accès aux données
  brutes des composites (voir section 2.2).
- **Exceptions** : squelette présent mais handlers incomplets.


## 2. Macros CODI_x86_64 — SSE2 flottant (session 11 avril)

### Convention flottante LLIR

Les flottants IEEE 754 double 64 bits transitent par la **pile entière**
(qword) exactement comme les entiers. Les macros SSE2 chargent/déchargent
depuis la pile vers les registres xmm0/xmm1 pour les opérations.
Transferts pile↔xmm via `movsd` (F2 0F 10/11), toujours 64 bits.

FLOAT (32 bits nominal dans STANDARD) et LONG_FLOAT (64 bits) sont tous
deux stockés en double 64 bits — OPER_SIZ_CHAR force 'q' pour DN_FLOAT.

### Macros ajoutées (15 + CALLI)

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
| **CALLI** | Call indirect via RAX | POP_RAX + db 0xFF,0xD0 (session 25 avril) |

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


### 2.2 Mécanisme ADR par CALLI — accès aux données brutes composites (session 10 mai)

#### Problème résolu

Pour `DIRECT_IO`, `WRITE_SYSTEM_CALL` doit passer au syscall `SYS_FILE_WRITE`
l'adresse des **octets bruts** de `ITEM`. Si `ELEMENT_TYPE` est un type
composite (record, array), l'expander passe `ITEM` par doublet descripteur
`(_disp, __u)`. Utiliser `LVa 1, -OFS` dans la macro LLIR donne l'adresse
du doublet, pas des données — le fichier contiendrait des pointeurs de pile,
et la relecture dans un autre processus segfaulterait.

#### Solution : `ITEM'ADDRESS` + troisième micro-procédure `ADR`

Le body `DIRECT_IO` passe explicitement `ITEM'ADDRESS` comme troisième
paramètre `ADR : SYSTEM.ADDRESS` à `WRITE_SYSTEM_CALL`. L'instruction LLIR
`La 2, -24` charge directement cette adresse sans ambiguïté.

Parallèlement, l'expander génère une troisième micro-procédure `ADR_TYPE.elab`
dans l'elab_spec de chaque instanciation, aux côtés de `LD` et `ST` :

- **Type scalaire** : `ADR` = `RTD 0` (no-op) — l'adresse passée est déjà
  l'adresse de la valeur scalaire.
- **Type composite** (record ou array contraint) : `ADR` = `La -1, 0` +
  `RTD 0` — dépile l'adresse du doublet et charge le `data_ptr` (offset 0),
  soit l'adresse réelle des octets.

#### Convention GFP étendue (4 PRM dans le modèle)

```asm
PRMS
    PRM ELEM__u_ofs       ; offset  8 → use_info (SIZ, FST, LST...)
    PRM ELEM__ld_ofs      ; offset 16 → adresse de LD_TYPE.elab
    PRM ELEM__st_ofs      ; offset 24 → adresse de ST_TYPE.elab
    PRM ELEM__adr_ofs     ; offset 32 → adresse de ADR_TYPE.elab
endPRMS
```

VAR de l'instance en ordre inverse avant GFP_disp :
`__adr_ofs` (GFP-8), `__st_ofs` (GFP-16), `__ld_ofs` (GFP-24),
`__u_ofs` (GFP-32).

#### État actuel des micro-procédures composites

`LD` et `ST` pour les types composites sont marqués **`A REVOIR`** dans
`expander-declarations.adb` (corps provisoires `LI 0` / `DROP`). Ils ne
sont pas nécessaires pour `DIRECT_IO` qui utilise `ITEM'ADDRESS` directement,
mais le seront pour les génériques Ada 83 généraux avec paramètres `out`
de type composite.


### 2.1 Mécanisme LD/ST par CALLI (session 25 avril)

#### Problème résolu

Dans un modèle générique, le paramètre formel de type discret a
`CD_IMPL_SIZE = INTG_SIZE * 8 = 32 bits` (dword). Mais le type actuel
(ex: COULEUR avec 3 valeurs) peut n'avoir que 8 bits (byte). Le store
indirect `SId` écrit 4 octets et corrompt les variables adjacentes.

#### Architecture

Chaque instanciation d'un générique avec type formel discret (`(<>)`)
génère deux micro-procédures de taille correcte (LD et ST) dans
l'elab_spec de l'instance. Leurs adresses sont passées au modèle via
le GFP. Le modèle appelle ST via CALLI pour les affectations aux
paramètres `out` de type formel.

#### Côté instance (expander-declarations.adb)

```asm
; Micro-procédures contournées par BRA pendant l'élaboration
BRA post_LD_COULEUR
LD_COULEUR.elab:
    Lb -1, 0            ; load byte (taille du type actuel)
    RTD 0
post_LD_COULEUR:
BRA post_ST_COULEUR
ST_COULEUR.elab:
    SIb -1, 0           ; store indirect byte
    RTD 0
post_ST_COULEUR:

; VAR en ordre INVERSE des PRM du modèle (correspondance miroir)
VAR COULEUR__st_ofs, q       ; GFP_disp - 24  ↔  PRM offset 24
    LCA ST_COULEUR.elab
    Sa 1, COULEUR__st_ofs
VAR COULEUR__ld_ofs, q       ; GFP_disp - 16  ↔  PRM offset 16
    LCA LD_COULEUR.elab
    Sa 1, COULEUR__ld_ofs
VAR COULEUR__u_ofs, q        ; GFP_disp - 8   ↔  PRM offset 8
    LCA COULEUR.SIZ
    Sa 1, COULEUR__u_ofs
VAR GFP_disp, q              ; référence (offset 0, marqueur d'adresse)
```

#### Côté modèle (expander-structures.adb)

```asm
namespace ENUMERATION_IO
PRMS
    PRM ENUM__u_ofs            ; offset 8  → accédé via -8
    PRM ENUM__ld_ofs           ; offset 16 → accédé via -16
    PRM ENUM__st_ofs           ; offset 24 → accédé via -24
endPRMS
```

#### Store via CALLI (expander-instructions.adb, STORE_OR_CALLI)

```asm
    LVa 1, -ITEM_ofs          ; @param_out (adresse du paramètre)
    Ld 2, REP_disp             ; valeur à stocker
    La 1, -GFP_ofs             ; adresse de GFP_disp
    La , -ENUM__st_ofs          ; [GFP_disp - 24] = adresse de ST
    CALLI                       ; appel indirect → SIb + RTD
```

#### Convention miroir PRM/VAR

Les PRM du namespace du modèle (offsets croissants : 8, 16, 24...)
correspondent aux VAR de l'instance en **ordre inverse** avant
GFP_disp (offsets décroissants : -8, -16, -24...).

Le premier PRM (offset 8, accédé via -8) correspond à la **dernière**
VAR avant GFP_disp (GFP_disp - 8). Le GFP_disp est un simple marqueur
d'adresse dont le contenu n'est pas utilisé.


## 3. TEXT_IO — état actuel (LRM 14.3)

TEXT_IO.FINC est **généré par l'EXPANDER**. Le fichier compile,
assemble et fonctionne. Programme de test IO_TEST validé (11 sections).
Programme ENUM_TEST validé (17 sections, session 25 avril).

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

### Procédures testées et fonctionnelles

**File Management (LRM 14.2.1) :**
- CREATE, OPEN, CLOSE, DELETE — avec syscalls Linux
  Réinitialisations dans CREATE/OPEN (session 25 avril).
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
- GET(ITEM, WIDTH) — délègue à GET(DEFAULT_INPUT,...) ✓
- GET(FROM:STRING), PUT(TO:STRING) — corps vides

**ENUMERATION_IO (LRM 14.3.10) — sessions 15 et 25 avril :**
- PUT(FILE, ITEM, WIDTH, SET) — format UPPER/LOWER_CASE ✓
- PUT(ITEM, WIDTH, SET) — délègue à PUT(DEFAULT_OUTPUT,...) ✓
- GET(FILE, ITEM) — parse insensible à la casse ✓
- GET(ITEM) — délègue à GET(DEFAULT_INPUT,...) ✓ (console fonctionnel)
- GET(FROM:STRING), PUT(TO:STRING) — corps vides
- Bloc IMAGES des littéraux d'énumérés via BEGIN_BLOC_DEF/END_BLOC_DEF ✓
- Patron de type via `__u_ofs` (SIZ, FST, LST, IMAGES) ✓
- Store dans paramètre `out` via mécanisme LD/ST par CALLI ✓


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

#### 1.3 ENUMERATION_IO — compléter
- GET(FROM:STRING, ITEM, LAST) — parse depuis une chaîne
- PUT(TO:STRING, ITEM, SET) — formater dans une chaîne
- Test avec CHARACTER (256 entrées) — impact mémoire du bloc IMAGES

#### 1.4 Implémenter FIXED_IO (LRM 14.3.9)
- Nécessite le support des **points fixes** (DN_FIXED).
- Même structure que FLOAT_IO.

#### 1.5 Fonctions TEXT_IO restantes
- NAME(FILE) — retour de slice STRING (nécessite CODE_RETURN DN_ARRAY)

### Phase 2 : SEQUENTIAL_IO (LRM 14.2.3)

Package générique pour I/O séquentiel d'éléments de type quelconque.

### Phase 3 : DIRECT_IO (LRM 14.2.5)

Package générique pour I/O à accès direct par numéro d'élément.

### Phase 4 : fondations expander à compléter au fil de l'eau

| Fonctionnalité | Où | Pour quoi |
|---|---|---|
| Points fixes (DN_FIXED) | types_decls, expressions | FIXED_IO |
| Unconstrained arrays | CODE_UNCONSTRAINED_ARRAY_DECL | STRING général |
| DN_RANGE_ATTRIBUTE | expressions | for I in X'RANGE |
| Records à discriminants | TRAITER_LES_CHAMPS | Offset dynamique |
| Types access (DN_ACCESS) | CODE_ACCESS_DECL | NEW, pointeurs |
| Exceptions handlers | instructions | Catch/raise |
| Dérivation (DN_DERIVED_DEF) | types_decls | Types dérivés |
| Renames | declarations | Renommage |
| Tâches (DN_TASK_BODY) | structures | Reporté |


## 5. TODO — Améliorations identifiées

### 5.1 Généraliser LD/ST par CALLI à tous les types formels

Actuellement, le mécanisme LD/ST par CALLI n'est implémenté que pour
les types formels discrets (`DN_FORMAL_DSCRT_DEF`). Les types formels
entiers (`DN_FORMAL_INTEGER_DEF`) et flottants (`DN_FORMAL_FLOAT_DEF`)
utilisent toujours un store de taille fixe (SId 32 bits, SIq 64 bits).

Cela fonctionne tant que le type actuel a la même taille que le type
formel. Mais un `for T'SIZE use 16` sur un type entier ou un
`LONG_LONG_FLOAT` de 128 bits causerait le même problème de
débordement.

**Action** : étendre la génération LD/ST et les PRM `__ld_ofs`/`__st_ofs`
à `DN_FORMAL_INTEGER_DEF` et `DN_FORMAL_FLOAT_DEF` dans
`expander-structures.adb` et `expander-declarations.adb`, et activer
STORE_OR_CALLI dans les branches DN_INTEGER et DN_FLOAT de CODE_ASSIGN.

### 5.2 Mélange `and then` / `or` dans les expressions

Le compilateur ne gère pas correctement les expressions mixtes
`not (A and then B or C and then D)`. La sémantique devrait signaler
une erreur (Ada 83 interdit le mélange), ou l'expander devrait
parenthéser correctement. En attendant, réécrire en `if/elsif/else`.

### 5.3 CALLI pour les paramètres formels sous-programmes Ada 83

Le mécanisme CALLI pourrait servir pour les paramètres formels
sous-programmes du LRM 12.1.3 (pas seulement les LD/ST cachés).
L'infrastructure est en place.


## 6. Architecture de l'EXPANDER (7 fichiers)

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


## 7. Conventions LLIR à retenir

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
- **GFP_disp** : marqueur d'adresse uniquement — son contenu n'est pas
  utilisé, seule son adresse sert de référence pour les offsets négatifs
  vers les VAR de l'instance (session 25 avril).
- **Correspondance miroir PRM/VAR** : les PRM du namespace du modèle
  (croissants : 8, 16, 24) correspondent aux VAR de l'instance en
  ordre inverse avant GFP_disp (décroissants : -8, -16, -24).
- **CALLI pour LD/ST** : `La lvl, -GFP_ofs` puis `La , -TYPE__st_ofs`
  (simple, pas LIa indirect). Le contenu de `__st_ofs` est déjà
  l'adresse de saut, pas un pointeur.
- **Niveau dans STORE_OR_CALLI** : utiliser `DI(CD_LEVEL, DEFN)` (niveau
  du paramètre = niveau de la procédure) et non `CUR_LEVEL` (qui peut
  être plus grand dans un bloc declare).


## 8. Pièges identifiés

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
25. **XD_REGION des procédures de générique** : pointe vers `DN_GENERIC_ID`,
    pas `DN_PACKAGE_ID`. Ne pas utiliser `SM_FIRST` pour tester.
    (session 15 avril)
26. **Level du wrapper générique** : `CUR_LEVEL - 1` pour accéder aux
    variables de l'instance (GFP_disp, __u_ofs), pas `CUR_LEVEL`.
    (session 15 avril)
27. **Ada 83 strict** : pas de déclarations d'objets après un
    sous-programme imbriqué — utiliser `begin declare ... end`.
    (session 15 avril)
28. **LIVa pour double déréférencement** : quand il faut suivre deux
    niveaux de pointeurs (GFP → patron → champ), utiliser LIVa avec
    DISP et OFS, pas deux `La` séparés. (session 15 avril)
29. **Offset IMAGES dans le patron** : depuis TYPE.SIZ, l'offset vers
    IMAGES.data_ptr est 16 (SIZ:dd=0, FST:dd=4, LST:dd=8, puis
    alignement qword → data_ptr à 16). (session 15 avril)
30. **DN_ITERATION_ID dans INVERSE_RECURSE_ON_PARAMETERS** : les
    variables de boucle `for` ne sont ni DN_VARIABLE_ID ni DN_IN_ID.
    Reconstruire le nom FASM via `LABEL_STR(CD_OFFSET)` + `"_disp"`.
    Corrigé session 25 avril.
31. **Offset GFP hard-codé dans MACHINE_CODE** : chaque procédure du
    modèle a un nombre différent de PRM, donc GFP_ofs est à un offset
    différent (-40 pour PUT/4 params, -24 pour GET/2 params). Ne pas
    copier-coller les offsets entre procédures. (session 25 avril)
32. **CODE_ASSIGN et types formels génériques** : `SM_EXP_TYPE` d'un
    type formel peut être `DN_ENUMERATION` mais avec un `CD_IMPL_SIZE`
    différent du type actuel. Le `else` catch-all avec STORE_OR_CALLI
    couvre les cas non reconnus. (session 25 avril)
33. **`exit when not(A and then B or C)`** : le mélange `and then`/`or`
    dans une même expression est mal compilé par l'expander. Réécrire
    en `if/elsif/else/exit`. (session 25 avril)
34. **`return` dans un bloc `declare`** : CODE_RETURN doit émettre les
    UNLINK intermédiaires avant `BRA ret_lbl` pour chaque niveau entre
    CUR_LEVEL et le niveau de la procédure englobante.
    Corrigé session 25 avril.
35. **Réutilisation de FILE_TYPE après CLOSE/OPEN** : les champs internes
    (AT_END_OF_FILE, HAS_LOOK_AHEAD) doivent être réinitialisés dans
    CREATE et OPEN. Corrigé session 25 avril dans text_io.adb.
36. **Mismatch taille store indirect / variable** : un `SId` (dword)
    sur une variable d'un octet (petite énumération) écrase 3 octets
    adjacents. Résolu par le mécanisme LD/ST via CALLI qui utilise la
    taille correcte du type actuel. (session 25 avril)
37. **Micro-procédures LD/ST dans l'elab_spec** : le code des
    micro-procédures doit être contourné par `BRA post_LD/ST` pendant
    l'élaboration, sinon il corrompt la pile. (session 25 avril)
38. **La vs LIa pour charger l'adresse de ST** : `La , -ENUM__st_ofs`
    (simple) et non `LIa , -ENUM__st_ofs, 0` (indirect). Le contenu
    de __st_ofs est déjà l'adresse de saut. (session 25 avril)
39. **Correspondance miroir PRM/VAR** : les VAR de l'instance doivent
    être dans l'ordre **inverse** des PRM du modèle. Le premier PRM
    (offset 8) correspond à la dernière VAR avant GFP_disp (offset -8).
    (session 25 avril)

40. **`LVa` sur `in` composite dans syscall** : donne l'adresse du doublet
    descripteur, pas des données brutes. Pour les I/O fichier, utiliser
    `ITEM'ADDRESS` comme paramètre explicite `SYSTEM.ADDRESS` et `La 2, -OFS`
    dans la macro LLIR. (session 10 mai)
41. **Hexdump cohérent ≠ fichier correct** : READ/WRITE symétriques sur le
    même doublet donnent des résultats corrects en intra-processus mais
    écrivent des pointeurs de pile dans le fichier. Un second processus
    segfaulterait. Toujours vérifier avec hexdump que le fichier contient
    les valeurs attendues, pas des adresses `0x7ffc...`. (session 10 mai)
42. **Agrégats nommés en position de paramètre** : non encore implémentés
    dans l'expander. Un agrégat `(X=>1,Y=>2)` comme initialiseur de variable
    fonctionne (COMPILE_RECORD_VAR), mais pas comme argument d'appel. 
    Contournement : variable intermédiaire déclarée avec l'agrégat. (session 10 mai)


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


### DIRECT_IO_TEST (session 10 mai, scalaire LONG_FLOAT)

```
LONG_FLOAT SIZE = 64 bits
create+write+close ok / open in_file ok
read seq #1/#2/#3 : 3.1415 / 6.5 / -2.25
read positioned #2/#3 : 6.5 / -2.25
open inout_file ok / rewrite position 2 ok
size after rewrite = 3
final #1/#2/#3 : 3.1415 / 3.1415 / -2.25
```

### DIRECT_IO_TEST2 (session 10 mai, types non scalaires)

```
=== 1. COULEUR (énuméré, 8 bits) ===   5 writes, seq + positioned, ok
=== 2. POINT (record 3 INTEGER) ===    4 writes, seq + positioned en ordre qqcq, ok
=== 3. VECTEUR (array 1..4 INTEGER) == 3 writes, seq + positioned, ok
=== 4. SET_INDEX + END_OF_FILE ===     SET_INDEX(4), EOF avant/après lecture, retour début, ok
=== 5. RESET + réécriture partielle == INOUT_FILE, rewrite pos 2+4, RESET IN_FILE, verify, ok
=== 6. IS_OPEN ===                     FALSE après CLOSE, TRUE après OPEN, ok
=== 7. Boucle END_OF_FILE ===          parcours séquentiel VECTEUR, 3 éléments, ok
=== 8. DELETE ===                      3 fichiers supprimés, IS_OPEN FALSE après DELETE, ok
```
Note : agrégats nommés en position de paramètre (`(X=>777,Y=>888,Z=>999)`)
non encore compilables — contournement par variables intermédiaires déclarées.

## 10. Fichiers à uploader pour la prochaine session

1. `src/expander/expander.adb`
2. `src/expander/expander-expressions.adb`
3. `src/expander/expander-instructions.adb`
4. `src/expander/expander-declarations.adb`
5. `src/expander/expander-utils.adb`
6. `src/expander/expander-declarations-types_decls.adb`
7. `src/expander/expander-structures.adb`
8. `text_io.adb` et `text_io.ads`
9. `direct_io.adb` et `direct_io.ads`
10. `machine_code.ads`
11. `src/expander/fasmg/codi_x86_64.finc`
12. Programme de test en cours
