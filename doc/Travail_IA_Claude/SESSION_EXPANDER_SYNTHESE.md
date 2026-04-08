# SESSION EXPANDER — Synthèse et point de départ

**Date** : avril 2026
**Objectif** : compléter l'EXPANDER du compilateur TLALOC


## 1. État des lieux de l'EXPANDER

### Ce qui fonctionne

- **Types scalaires** : entiers (DN_INTEGER), énumérations (DN_ENUMERATION),
  sous-types entiers et énumérations — génération complète avec namespace,
  SIZ, FST, LST.
- **Constrained arrays** : traitement multi-dimensionnel récursif via
  PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC, calcul de taille statique/dynamique,
  descripteurs avec USEINFO et offsets virtual.
- **Records statiques** : champs via STATOFS dans un `virtual at 0`,
  USEINFO pour les infos de type des champs. Fonctionne pour FILE_TYPE
  dans TEXT_IO.
- **Variables** : déclaration VAR, initialisation, accès Ld/Sd avec
  niveau lexical et déplacement.
- **Sous-programmes** : PRO/ELB/UNLINK/RTD/endPRO complet. Paramètres
  via PRMS/PRM/endPRMS. Convention : `in` scalaire par copie valeur,
  `out`/`in out` et composites par adresse (LVA). Accès paramètres par
  offset négatif (signe `-` ajouté dans LOAD_MEM de expander-utils.adb).
- **Appels** : CALL avec résolution différée, `if defined ... end if`
  pour n'assembler que les procédures effectivement appelées.
- **Instructions** : if/then/else (BT/BF/BRA), boucles for/while/loop
  (avec LOOP_CODE pour INC/DEC/GT/LT), case, exit, return, goto,
  assign, null_stm, procedure_call.
- **Expressions** : numeric_literal (LI), string_literal (STR),
  used_object_id, used_char, used_op (opérateurs prédéfinis),
  short_circuit, parenthesized, conversion, qualified, function_call,
  indexed, selected, attribute, membership.
- **Génériques** : instanciation de packages génériques (INTEGER_IO
  fonctionnel dans HANOI_TOWER). Mécanisme GFP_disp pour les paramètres
  formels génériques.
- **Packages** : namespace FASM pour la séparation, elab_spec, body.
  Packages génériques avec PRMS pour les paramètres formels de type.
- **Stubs/subunits** : include du .FINC correspondant.
- **With/use** : génération des `include 'X.FINC'`.
- **Code statements** : package MACHINE_CODE avec ASM_OPCODE.
- **Exceptions** : squelette présent (label excep:, ALTERNATIVE_S)
  mais handlers incomplets.


### Ce qui manque — par priorité

#### Priorité 1 : débloquer TEXT_IO et les composites

1. **Types privés** (DN_PRIVATE, DN_L_PRIVATE) : CODE_TYPE_DECL ne les
   traite pas. TEXT_IO.FILE_TYPE est un limited private dont la
   représentation complète est un record. L'EXPANDER doit résoudre le
   type complet (via SM_TYPE_SPEC du full type) et générer le record
   correspondant.

2. **Types incomplets** (DN_INCOMPLETE) : même situation pour
   FILE_TYPE_BLK. Doit être résolu vers le type complet.

3. **Records avec discriminants dynamiques** : le code de
   CODE_RECORD_DECL gère les discriminants et les champs, mais
   quand IS_STATIC = FALSE, le commentaire dit `; OFFSET NON
   STATIQUE A FAIRE`. Il faudrait calculer les offsets dynamiquement
   via USEINFO et la co-pile.

4. **Passage de records en paramètre** : fonctionne pour les cas
   statiques (FILE_TYPE est passé par adresse, champs accédés via
   LIVa + offsets STATOFS). Mais attention au cas des objets dont
   le frame pourrait être fermé — les variables de package (niveau 0)
   sont la solution naturelle.

5. **Unconstrained arrays** (DN_ARRAY) : CODE_UNCONSTRAINED_ARRAY_DECL
   existe mais est moins avancé que la version constrained. Les USEINFO
   des dimensions sont commentés. Ce type est crucial pour STRING
   (qui est `array(POSITIVE range <>) of CHARACTER`).

#### Priorité 2 : fonctionnalités avancées

6. **Types access** (DN_ACCESS) : CODE_ACCESS_DECL est vide.
   Nécessite l'allocateur (new) et la gestion du tas (R12/R11).

7. **Flottants** (DN_FLOAT, DN_FIXED) : CODE_FLOAT_DECL et
   CODE_FIXED_DECL sont vides. Macros LLIR à créer (FPU x87 ou SSE).

8. **Tâches** (DN_TASK_BODY) : vide. Complexe — pourrait être reporté.

9. **Exceptions** : le squelette est en place mais les handlers ne
   sont pas implémentés (CHOICE_EXP, CHOICE_OTHERS dans
   CODE_EXCEPTIONS_ALTERNATIVE_S sont des todo).

10. **Dérivation de types** (DN_DERIVED_DEF) : CODE_DERIVED_SUBPROG
    est vide.

11. **Renames** (CODE_SIMPLE_RENAME_DECL) : déclaré mais pas vu le
    contenu.

12. **Corps des génériques FLOAT_IO, FIXED_IO, ENUMERATION_IO** :
    tous les corps de procédures sont vides (squelettes uniquement).


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

### Fonctions utilitaires clés (dans UTILS)

- `OPER_SIZ_CHAR(DEFN)` : retourne 'b'/'w'/'d'/'q' selon la taille
  du type. Détermine le suffixe des instructions Load/Store.
- `EXP_TYPE_CHAR(EXP)` : idem depuis une expression.
- `CODE_DATA_TYPE_OF(EXP_OR_TYPE_SPEC)` : retourne le caractère de
  taille pour un type ou une expression.
- `LOAD_MEM(DEFN)` : génère le chargement d'une variable/paramètre.
  Ajoute le signe `-` pour les paramètres (offset négatif).
- `STORE(DEST_DEFN)` : génère le rangement.
- `REGIONS_PATH(ID)` : génère le chemin de namespaces
  `STANDARD.TEXT_IO.` etc.
- `NEW_LABEL` : générateur de labels uniques (L1, L2, ...).
- `INC_LEVEL` / `DEC_LEVEL` : gestion du niveau lexical courant.


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
- **Records statiques** : STATOFS dans `virtual at 0`, accès via
  LIVa avec offset du champ.
- **Namespaces FASM** : chaque package/type crée un namespace.
  Résolution : `STANDARD.TEXT_IO.FILE_TYPE.ID`.
- **Résolution différée** : `postpone` + `if ~definite` pour les
  labels de procédures. `if defined X_` pour l'assemblage conditionnel.


## 4. Le problème TEXT_IO en détail

TEXT_IO est le package le plus complexe de la bibliothèque standard.
Le .FINC actuel (~2195 lignes) contient :

- **Types** : FILE_MODE (enum), COUNT (integer range), FILE_NAME_BUFFER
  (constrained array 1..256 of CHARACTER), FILE_TYPE (record avec
  10 champs), FILE_TYPE_BLK (duplicata).
- **Variables de package** (niveau 0) : STDOUT_PAGE_LENGTH,
  STDOUT_LINE_LENGTH, STDOUT_PAGE, STDOUT_LINE, STDOUT_COL,
  DEFAULT_INPUT (record), DEFAULT_OUTPUT (record).
- **Procédures implémentées** : CREATE, OPEN (avec appel syscall),
  manipulation des champs FILE_TYPE via LIVa + STATOFS, copie de
  noms via BLKMOV.
- **Procédures avec corps** : PUT (string), PUT (char), NEW_LINE,
  PUT_LINE, GET, GET_LINE, et les variantes avec/sans FILE paramètre.
  INTEGER_IO (PUT/GET) est fonctionnel.
- **Procédures vides** (squelette seul) : tous les GET/PUT de
  FLOAT_IO, FIXED_IO, ENUMERATION_IO.

Le problème FILE_TYPE/SET_INPUT/SET_OUTPUT : les DEFAULT_INPUT et
DEFAULT_OUTPUT sont déclarés comme variables de package (niveau 0).
Elles persistent tant que le namespace STANDARD.TEXT_IO existe (c'est-
à-dire toute la durée d'exécution). SET_INPUT/SET_OUTPUT doivent juste
copier un pointeur vers ces variables. C'est faisable avec l'existant.

Le vrai point de blocage est plutôt que le TEXT_IO.FINC actuel a été
en grande partie écrit à la main et doit être régénéré par l'EXPANDER.
Pour cela, il faut que l'EXPANDER gère DN_L_PRIVATE → résolution vers
le record complet.


## 5. Fichiers à uploader pour la prochaine session

Pour travailler sur l'EXPANDER :

1. `src/expander/expander-declarations.adb` (le plus gros, ~1700 lignes)
2. `src/expander/expander-expressions.adb` (~1050 lignes)
3. `src/expander/expander-utils.adb` (~420 lignes) — pour LOAD_MEM, STORE
4. Optionnellement `src/expander/expander-instructions.adb` si on
   touche aux instructions

Le cas test concret pour valider : un programme Ada 83 simple qui
déclare un record, l'initialise, accède à ses champs, et le passe
en paramètre à une procédure.
