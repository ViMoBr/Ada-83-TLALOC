# SESSION EXPANDER — Rapport de session du 15 avril 2026

**Date** : 15 avril 2026
**Objectif** : implémenter ENUMERATION_IO (LRM 14.3.10) — PUT fonctionnel
**Statut** : PUT basique validé (`COULEUR_TEST` affiche `ROUGE`)


## 1. Travaux réalisés

### 1.1 Représentation des images d'énumérés — BEGIN_BLOC_DEF / END_BLOC_DEF

Le bloc IMAGES d'un type énuméré est une constante STRING Ada contenant la
concaténation de triplets `(REP:byte, LEN:byte, CHARS:LEN bytes)` pour
chaque littéral du type. Ce bloc est créé en zone postpone par les macros
fasmg `BEGIN_BLOC_DEF` / `END_BLOC_DEF` qui utilisent le mécanisme
`esc struc ... esc end struc` pour couper une macro en deux parties et
permettre l'insertion d'un nombre variable de `db`.

Pour un type `type COULEUR is (BLEU, BLANC, ROUGE)`, le LLIR généré est :

```asm
namespace COULEUR
  BEGIN_BLOC_DEF
  db 0, 4, "BLEU"
  db 1, 5, "BLANC"
  db 2, 5, "ROUGE"
  END_BLOC_DEF
  IMAGES  BYTES_BLOC       ; instancie la structure → descripteur STRING Ada
  CST LST, d, 2
  CST FST, d, 0
  CST SIZ, d, 8
  postpone  ; les postpone sont en LIFO
  align_q  ; aligne l'ensemble
  end postpone
end namespace
```

Layout mémoire en zone postpone (LIFO) :
- SIZ (offset 0), FST (offset 4), LST (offset 8)
- IMAGES.data_ptr (offset 12→16 selon alignement)
- IMAGES.info_ptr, useinfo, puis les octets des triplets


### 1.2 Patron de type via `__u_ofs` dans les génériques

Pour ENUMERATION_IO, le type formel `ENUM` est un `(<>)` discret. Le body
du modèle générique a besoin d'accéder au patron de type (SIZ, FST, LST,
IMAGES) du type actuel à l'exécution. Le mécanisme retenu est le passage
d'un unique pointeur `__u_ofs` vers le début du patron (`TYPE.SIZ`) via
le GFP (Generic Frame Pointer).

Dans le **modèle** (TEXT_IO.FINC), un seul PRM :
```asm
PRMS
    PRM ENUM__u_ofs       ; pointeur vers le patron de type
endPRMS
```

Dans l'**elab_spec** de l'instance :
```asm
VAR COULEUR__u_ofs, q
    LCA  STANDARD.COULEUR_TEST_L1.COULEUR.SIZ
    Sa   1, COULEUR__u_ofs
VAR GFP_disp, q
```

Depuis le patron, on accède aux IMAGES à l'offset 16 (`data_ptr` du
BYTES_BLOC dans le postpone).


### 1.3 Retour de STRING par fonction

Implémenté dans `CODE_RETURN` (expander-instructions.adb) : quand le type
de retour est `DN_ARRAY`, l'adresse du descripteur est stockée dans
`result__ofs` via `Sa level, -result__ofs`.

Côté appelant dans `COMPILE_ARRAY_VAR` (expander-declarations.adb) :
quand INIT_EXP est un `DN_FUNCTION_CALL`, le résultat (adresse du
descripteur) est déréférencé pour initialiser le doublet :
- `data_ptr` (offset 0) → `_disp`
- `info_ptr` (offset 8 via `La , 8`) → `__u`


### 1.4 Nouvelle instruction LIVa et ASM_OP_3

Ajout de la macro fasmg `LIVa` (Load Indirect Variable Address) à 3
paramètres : LVL, DISP, OFS. Elle utilise `INDIRECT_BASE_IN_RAX` pour
un double déréférencement :
1. Charger l'adresse de base depuis le sommet de pile (lvl=-1)
2. Déréférencer à l'offset DISP pour obtenir une adresse intermédiaire
3. Ajouter OFS pour obtenir l'adresse finale

MACHINE_CODE.ads étendu avec `ASM_OP_3` (OPCODE, LVL, DISP, OFS) et
les opcodes LIB..SIA pour les opérations indirectes à 3 paramètres.

Usage dans GET_ENUM_IMAGES :
```ada
ASM_OP_2'(OPCODE => La,   LVL => 1, OFS => -40);   -- @GFP_disp
ASM_OP_3'(OPCODE => LIVa, DISP => -8, OFS => 16);  -- @IMAGES via __u_ofs
ASM_OP_2'(OPCODE => Sa,   LVL => 2, OFS => -8);    -- result__ofs
```


### 1.5 Propagation automatique du GFP

Quand le body modèle d'une procédure générique appelle une autre procédure
du même générique (ex: `PUT(ITEM)` appelle `PUT(FILE,ITEM,...)`), le GFP
doit être propagé comme paramètre caché supplémentaire.

Détection dans `CODE_PROCEDURE_CALL` : si `IN_GENERIC_BODY = TRUE` et
`D(XD_REGION, PROC_ID).TY = DN_GENERIC_ID`, on empile le GFP avant
les paramètres Ada :
```ada
La  CUR_LEVEL, -GFP_ofs    -- propagation GFP
```

**Piège identifié** : `XD_REGION` des procédures du modèle générique
pointe vers un `DN_GENERIC_ID`, pas `DN_PACKAGE_ID`. Le test initial
avec `DN_PACKAGE_ID` / `SM_FIRST` échouait.


### 1.6 Corrections wrapper générique

- `LVA` pour GFP_disp dans le wrapper utilise `CUR_LEVEL - 1` (le
  GFP_disp est dans le frame de l'instance, pas dans le frame du wrapper)
- `DN_FORMAL_DSCRT_DEF` reconnu dans `CODE_GENERIC_DECL` pour
  positionner `CD_IMPL_SIZE`


### 1.7 CODE_CODE — ASM_OP_3

Le traitement des code statements (`CODE_CODE`) a été étendu pour gérer
`ASM_OP_3` avec le champ DISP supplémentaire. Syntaxe LLIR générée :
`OPCODE LVL , DISP , OFS` (ex: `LIVa , -8 , 16`).


### 1.8 Body Ada de ENUMERATION_IO.PUT

PUT(FILE, ITEM, WIDTH, SET) implémenté en Ada 83 pur (sauf GET_ENUM_IMAGES
en MACHINE_CODE). Algorithme :
1. GET_ENUM_IMAGES retourne la STRING constante des images
2. Parcours des triplets `(REP, LEN, chars...)` via CHARACTER'POS
3. Comparaison REP = ENUM'POS(ITEM)
4. Padding espaces si WIDTH > LEN
5. Conversion majuscule → minuscule si SET = LOWER_CASE
6. Écriture caractère par caractère via PUT(FILE, CH)

PUT(ITEM, WIDTH, SET) délègue à PUT(DEFAULT_OUTPUT, ITEM, WIDTH, SET).


## 2. Bugs corrigés

### Bug 1 : Déclarations après sous-programme (Ada 83)
En Ada 83 strict, on ne peut pas déclarer de variables après un
sous-programme imbriqué. Les variables de PUT et GET qui suivaient
GET_ENUM_IMAGES ont été déplacées dans un bloc `declare`.

### Bug 2 : Paramètre GFP manquant dans les appels intra-génériques
PUT(ITEM) appelait PUT(FILE,...) sans propager le GFP → segfault.
Corrigé par la détection automatique via `XD_REGION.TY = DN_GENERIC_ID`.

### Bug 3 : Level du wrapper pour GFP_disp
Le wrapper d'instanciation utilisait `CUR_LEVEL` pour `LVA GFP_disp`
alors que GFP_disp est dans le frame englobant → `CUR_LEVEL - 1`.

### Bug 4 : `La, -8` insuffisant pour accéder aux IMAGES
L'ancien `La, -8` (simple déréférencement) ne suffisait pas pour le
double déréférencement nécessaire (GFP → __u_ofs → TYPE.SIZ → offset
vers IMAGES). Résolu par la nouvelle instruction `LIVa , DISP, OFS`.


## 3. Conventions nouvelles

- **Patron de type via `__u_ofs`** : un seul PRM dans le modèle générique
  pointe vers le début du patron de type (TYPE.SIZ). Les infos FST, LST,
  IMAGES sont à des offsets fixes depuis SIZ.
- **GFP propagation** : tout appel intra-générique détecté par
  `XD_REGION.TY = DN_GENERIC_ID` propage automatiquement le GFP.
- **ASM_OP_3** : opérations à 3 paramètres (OPCODE, DISP, OFS) pour
  les accès indirects multi-niveaux.
- **Ada 83** : après un sous-programme imbriqué, utiliser `begin declare`
  pour les variables locales.


## 4. Pièges identifiés (ajouts)

25. **XD_REGION des procédures de générique** : pointe vers `DN_GENERIC_ID`,
    pas `DN_PACKAGE_ID`. Ne pas utiliser `SM_FIRST` pour tester.
26. **Level du wrapper générique** : `CUR_LEVEL - 1` pour accéder aux
    variables de l'instance (GFP_disp, __u_ofs), pas `CUR_LEVEL`.
27. **Ada 83 strict** : pas de déclarations d'objets après un
    sous-programme imbriqué — utiliser `begin declare ... end`.
28. **LIVa pour double déréférencement** : quand il faut suivre deux
    niveaux de pointeurs (GFP → patron → champ), utiliser LIVa avec
    DISP et OFS, pas deux `La` séparés.
29. **Offset IMAGES dans le patron** : depuis TYPE.SIZ, l'offset vers
    IMAGES.data_ptr est 16 (SIZ:dd=0, FST:dd=4, LST:dd=8, puis
    alignement qword → data_ptr à 16).


## 5. Ce qui reste à faire pour ENUMERATION_IO

### 5.1 Immédiat
- GET_ENUM_IMAGES dans GET(FILE,ITEM) : mettre à jour avec `LIVa`
  (actuellement utilise encore l'ancien `La, -8`)
- Tester GET(FILE,ITEM) et GET(ITEM) — lecture d'énumérés
- Programme de test complet (`enum_test.adb`) avec les 10 sections

### 5.2 Court terme
- GET(FROM:STRING, ITEM, LAST) — parse depuis une chaîne
- PUT(TO:STRING, ITEM, SET) — formater dans une chaîne
- PUT/GET dans un fichier (FILE /= DEFAULT_OUTPUT)
- Test avec `CHARACTER` (type énuméré 256 éléments avec littéraux
  caractères `'A'`, `'B'`, etc.)

### 5.3 Questions ouvertes
- **ENUM'VAL(REP)** dans GET : vérifier que l'expander compile
  correctement cette expression pour un type formel discret
- **ENUM'IMAGE** (attribut) : pourrait utiliser le même mécanisme
  GET_ENUM_IMAGES pour un usage hors I/O
- **Taille du bloc IMAGES** : pour CHARACTER (256 entrées), le bloc
  sera volumineux — impact mémoire acceptable ?


## 6. Fichiers modifiés

| Fichier | Modifications |
|---------|--------------|
| expander-instructions.adb | CODE_RETURN DN_ARRAY, propagation GFP, CODE_CODE ASM_OP_3 |
| expander-declarations.adb | COMPILE_ARRAY_VAR DN_FUNCTION_CALL, DN_FORMAL_DSCRT_DEF, elab_spec enum __u_ofs, LVA CUR_LEVEL-1 |
| expander-structures.adb | PRM ENUM__u_ofs dans le modèle générique |
| expander-declarations-types_decls.adb | Format db REP,LEN,"NOM" dans CODE_ENUM_LITERAL_S |
| text_io.adb | Body ENUMERATION_IO (PUT complet, GET squelette) |
| machine_code.ads | ASM_OP_3, opcodes LIB..SIA |
| codi_x86_64.finc | BEGIN_BLOC_DEF, END_BLOC_DEF, LIVa |
