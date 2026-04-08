# TLALOC — Architecture du compilateur

Ce document décrit l'architecture interne du compilateur TLALOC.
Il est destiné aux développeurs travaillant sur le code du compilateur
et aux personnes souhaitant comprendre son fonctionnement en profondeur.

Pour l'introduction générale et le contexte historique, voir
[go_ahead-eng.md](markdown/go_ahead-eng.md).
Pour l'introduction technique, voir
[introduction-eng.md](markdown/introduction-eng.md).


## 1. Vue d'ensemble

TLALOC transforme un texte source Ada 83 (MIL-STD-1815A-1983) en un
exécutable ELF x86-64 via une chaîne de phases opérant sur une
représentation intermédiaire DIANA.

```
Source Ada 83 (.adb / .ads)
      │
      ▼
 ┌──────────┐     Analyse lexicale LALR(1), construction
 │PAR_PHASE │     du réseau DIANA syntaxique partiel
 │ 1924 lig.│     (LEX, GRMR_OPS, GRMR_TBL)
 └────┬─────┘
      ▼
 ┌──────────┐     Chargement des unités "withed" depuis
 │LIB_PHASE │     la bibliothèque (.DCL, .BDY, .SUB)
 │ 1230 lig.│     Intégration dans le réseau DIANA
 └────┬─────┘
      ▼
 ┌──────────┐     Vérification sémantique statique complète
 │SEM_PHASE │     28 subunits spécialisés
 │22193 lig.│     Ajout de nœuds sémantiques au réseau DIANA
 └────┬─────┘
      ▼
 ┌──────────┐     Présentation des erreurs accumulées
 │ERR_PHASE │     dans le réseau DIANA
 │  99 lig. │     (si erreurs : arrêt de la compilation)
 └────┬─────┘
      ▼
 ┌──────────┐     Génération de code LLIR (macros FASM)
 │ EXPANDER │     Machine à pile, fichier .FINC
 │ 5971 lig.│
 └────┬─────┘
      ▼
 ┌──────────┐     Sauvegarde du DIANA compilé en bibliothèque
 │WRITE_LIB │     .DCL (spec) / .BDY (body) / .SUB (subunit)
 │  264 lig.│     ATTENTION : détruit $$$.TMP
 └────┬─────┘
      ▼
    fasmg         Assemblage macro → ELF x86-64
```

Le programme principal `ada_comp` orchestre ces phases et s'arrête
selon l'option fournie (S, L, M, C, W, w, U, P, A).


## 2. Le pivot central : IDL et le réseau DIANA

### 2.1 Qu'est-ce que DIANA ?

DIANA (Descriptive Intermediate Attributed Notation for Ada) est une
représentation standardisée de programmes Ada sous forme de graphe de
nœuds typés portant des attributs. Voir la spécification de référence :
[DIANA-Ref-Manual-1986-rev4.pdf](DIANA-Ref-Manual-1986-rev4.pdf).

Le graphe DIANA est stocké dans un fichier temporaire `$$$.TMP` situé
dans le répertoire `ADA__LIB` du projet. Ce fichier utilise un système
de pages virtuelles qui permettait historiquement de travailler avec
peu de RAM en déportant les données sur disque.

### 2.2 Spécification IDL

Les règles structurelles du graphe DIANA sont exprimées par un
Interface Definition Language (IDL). Le fichier source est
`./idl/diana.idl`. Les lignes préfixées `//` définissent la
composition des classes de nœuds et les attributs. Un mécanisme
d'héritage transfère les attributs des classes aux sous-classes et
aux nœuds terminaux.

Le répertoire `./idl` contient aussi les IDL du parseur LALR
et des tables d'attributs TBL.

### 2.3 Constantes générées

L'outil `idl_tools` (sources dans `./src/idl_tools`, exécutable
dans `./bin/idl_tools`) transforme `diana.idl` en :

- **`diana_node_attr_class_names.ads`** : package Ada définissant
  l'énumération `NODE_NAME` (231 sortes de nœuds),
  l'énumération `ATTRIBUTE_NAME` (173 attributs),
  et 99 sous-types de classe.

- **`diana.tbl`** : fichier texte indiquant quels attributs possède
  chaque sorte de nœud. Converti en `diana.bin` (binaire) qui doit
  accompagner l'exécutable du compilateur.

- **Fichiers d'aide** : `diana_CLASS_.txt`, `diana_NODES_.txt`,
  `diana_NODES.txt` — listes de la hiérarchie des classes et de
  l'héritage complet des attributs. Versions ODF et PDF navigables
  dans `./doc`.

### 2.4 Le package IDL (idl.ads / idl.adb)

Le package `IDL` est le cœur du système. Il fournit :

- Le type fondamental **TREE** :

```ada
type TREE (PT : VPTR_TYPE := P) is record
  case PT is
    when P | L =>                  -- Pointeur normal ou attribut liste
      TY  : NODE_NAME;            -- Sorte du nœud
      PG  : PAGE_IDX;             -- Page virtuelle
      LN  : LINE_IDX;             -- Offset dans la page
    when S =>                      -- Pointeur source_line
      COL : SRCCOL_IDX;           -- Colonne dans le texte source
      SPG : PAGE_IDX;
      SLN : LINE_IDX;
    when HI =>                     -- En-tête de nœud ou entier court
      NOTY : NODE_NAME;           -- Sorte du nœud
      ABSS : POSITIVE_SHORT;      -- Valeur absolue entier court
      NSIZ : ATTR_NBR;            -- Nombre d'attributs (ou signe)
  end case;
end record;
```

- Les fonctions d'accès en lecture **D**, **DI**, **DB** et les
  procédures d'écriture correspondantes, qui permettent de naviguer
  dans le graphe DIANA et de lire/écrire les attributs des nœuds.

- Les déclarations des phases de compilation comme subunits séparés :
  `PAR_PHASE`, `LIB_PHASE`, `SEM_PHASE`, `ERR_PHASE`, `WRITE_LIB`,
  `PRETTY_DIANA`.

- Les subunits de gestion interne : `page_man` (gestion des pages
  virtuelles, via DIRECT_IO), `idl_tbl` (tables), `idl_man`
  (gestionnaire IDL), `print_nod` (impression des nœuds).


## 3. Description des phases

### 3.1 PAR_PHASE — Analyse lexicale et syntaxique

**Entrée** : texte source Ada 83.
**Sortie** : réseau DIANA syntaxique partiel dans `$$$.TMP`.

L'analyseur est un LALR(1) classique dont les tables sont fabriquées
par le système dans `src/lalr_tools`. La phase se compose de :

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `idl-par_phase.adb` | 813 | Procédure principale du parsing |
| `idl-par_phase-set_dflt.adb` | 104 | Valeurs par défaut |
| `lex.ads` / `lex.adb` | 63 / 672 | Analyseur lexical |
| `grmr_ops.ads` / `grmr_ops.adb` | 30 / 120 | Opérations grammaticales |
| `grmr_tbl.ads` | 42 | Tables de grammaire (via SEQUENTIAL_IO) |

Dépendances : `lex` dépend de `TEXT_IO` ; `grmr_tbl` dépend de
`SEQUENTIAL_IO` ; `par_phase` dépend de `LEX`, `GRMR_OPS`, `GRMR_TBL`.

### 3.2 LIB_PHASE — Phase bibliothèque

**Entrée** : réseau DIANA après PAR_PHASE + fichiers `.DCL`/`.BDY`/`.SUB`.
**Sortie** : réseau DIANA complété par les arbres des unités "withed".

Fichier unique : `idl-lib_phase.adb` (1 230 lignes), subunit d'IDL.
Procédure sans paramètre. Utilise `SEQUENTIAL_IO` pour lire les
fichiers de bibliothèque.

La phase lit les blocs DIANA compilés antérieurement et les intègre
(avec relocation) dans le `$$$.TMP` courant, de sorte que les
définitions importées soient disponibles pour l'analyse sémantique.

### 3.3 SEM_PHASE — Analyse sémantique

**Entrée** : réseau DIANA après LIB_PHASE.
**Sortie** : réseau DIANA enrichi de nœuds sémantiques.

C'est la phase dominante du compilateur (64.6% du code, 22 193 lignes).
Le point d'entrée est `idl-sem_phase.adb` (2 667 lignes).
28 subunits spécialisés couvrent les différents aspects :

| Thème | Subunits |
|-------|----------|
| Types | `exp_type`, `derived`, `def_util` |
| Expressions | `expreso`, `aggreso`, `eval_num` |
| Noms et définitions | `newsnam`, `def_walk`, `nod_walk` |
| Visibilité | `vis_util`, `req_util` |
| Génériques | `instant`, `gen_subs` |
| Opérateurs | `univ_ops`, `uarith` |
| Statements | `stm_walk` |
| Attributs | `att_walk` |
| Représentation | `rep_clau` |
| Pragmas | `pra_walk` |
| Prédéfinis | `pre_fcns`, `fix_pre` |
| Résolution with | `fix_with` |
| Surcharge | `red_subp` |
| Fabrication de nœuds | `make_nod` (2 925 lig. — le plus gros fichier) |
| Utilitaires | `set_util`, `sem_glob`, `hom_unit`, `chk_stat` |

### 3.4 ERR_PHASE — Gestion des erreurs

Fichier unique : `idl-err_phase.adb` (99 lignes).
Présente les erreurs accumulées dans le réseau DIANA par les phases
précédentes. S'il y a des erreurs, les phases suivantes ne sont pas
exécutées.

### 3.5 EXPANDER — Génération de code

**Entrée** : réseau DIANA vérifié syntaxiquement et sémantiquement.
**Sortie** : fichier `.FINC` contenant du code LLIR (macros FASM).

L'EXPANDER est une procédure indépendante (pas un subunit d'IDL).
Il dépend de `DIANA_NODE_ATTR_CLASS_NAMES`, `IDL` et `TEXT_IO`.

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `expander.adb` | 1 415 | Procédure principale, lancement |
| `expander-utils.adb` | 420 | Utilitaires de génération |
| `expander-structures.adb` | 434 | Génération des structures |
| `expander-instructions.adb` | 945 | Génération des instructions |
| `expander-expressions.adb` | 1 054 | Génération des expressions |
| `expander-declarations.adb` | 1 703 | Génération des déclarations |

Le code LLIR est un jeu de macros pour une machine à pile :
`PRO`/`endPRO` (délimitation de procédure), `ELB` (élaboration),
`STR` (constante string), `LCA` (load constant address),
`CALL` (appel), `UNLINK` (destruction de frame), `RTD` (return), etc.

Les macros sont définies dans `codi_x86_64.finc` qui traduit la
machine à pile en instructions x86-64 réelles.

**État** : fonctionnel pour les constructions de base ; incomplet
pour certaines fonctionnalités avancées (génériques, tâches, etc.).

### 3.6 WRITE_LIB — Écriture en bibliothèque

Fichier unique : `idl-write_lib.adb` (264 lignes), subunit d'IDL.
Utilise `SEQUENTIAL_IO`.

Extrait les blocs DIANA de l'unité compilée (en excluant les blocs
importés par LIB_PHASE), les relocalise et les compacte dans un
fichier `.DCL`, `.BDY` ou `.SUB`.

**Attention** : cette opération détruit `$$$.TMP`. L'examen du réseau
DIANA (via PRETTY_DIANA) doit donc être fait avant, en s'arrêtant
avec l'option C ou M.

### 3.7 PRETTY_DIANA — Affichage du réseau

Fichier : `idl-pretty_diana.adb` (441 lignes).
Options d'affichage : U (ugly — tout, sans résumé), P (pretty — résumé
de l'unité sans inclusions), A (all — tout avec inclusions).
Crucial pour le développement de l'EXPANDER.


## 4. Graphe des dépendances entre modules

```
              ┌──────────────────────────┐
              │ DIANA_NODE_ATTR_CLASS_NAMES │
              │    (package spec généré)    │
              └────────┬──────────┬────────┘
                       │          │
              ┌────────▼──┐  ┌───▼─────────┐
              │   IDL     │  │  EXPANDER   │
              │  (spec)   │  │ (procédure) │
              └─┬─┬─┬─┬──┘  └─────────────┘
                │ │ │ │         dépend aussi de IDL, TEXT_IO
    ┌───────────┘ │ │ └──────────────┐
    ▼             ▼ ▼                ▼
 PAR_PHASE   LIB_PHASE         SEM_PHASE
    │         SEM_PHASE         ERR_PHASE
    │         WRITE_LIB         WRITE_LIB
    │         PRETTY_DIANA
    │
    ├── LEX ──────── TEXT_IO
    ├── GRMR_OPS
    └── GRMR_TBL ── SEQUENTIAL_IO

ADA_COMP (programme principal)
    dépend de : IDL, EXPANDER, TEXT_IO, CALENDAR
```


## 5. Flux de données

```
                          Bibliothèque ADA__LIB/
                         ┌─────────────────────┐
                         │  *.DCL  *.BDY  *.SUB│
                         │  diana.bin           │
                         │  $$$.TMP (temporaire)│
                         │  *.FINC (code LLIR)  │
                         └──────────┬───────────┘
                                    │
Source .adb/.ads ──► PAR_PHASE ──►──┤ $$$.TMP (DIANA syntaxique)
                                    │
                     LIB_PHASE ◄──►─┤ lit .DCL/.BDY/.SUB
                         │          │ écrit dans $$$.TMP
                         ▼          │
                     SEM_PHASE ──►──┤ enrichit $$$.TMP
                         │          │
                     ERR_PHASE      │
                         │          │
                     EXPANDER ───►──┤ écrit .FINC
                         │          │
                     WRITE_LIB ──►──┤ écrit .DCL/.BDY/.SUB
                                    │ détruit $$$.TMP
                                    │
                         fasmg ◄────┤ lit .fas + .FINC
                           │
                           ▼
                     Exécutable ELF x86-64
```


## 6. Le système LLIR / FASM

### 6.1 Principe

Le code généré par l'EXPANDER est un texte de macros FASM décrivant
une machine à pile. Ce texte est un fichier `.FINC` (FASM INClude)
qui est inclus dans un fichier wrapper `.fas`.

### 6.2 Structure d'un fichier .fas (wrapper)

```fasm
include 'codi_x86_64.finc'           ; Définitions macros LLIR → x86-64
STANDARD = 'STANDARD'
namespace STANDARD
  virtual at 8
    VARzone::
    VARzone.DISP = $
  end virtual
  include '_STANDRD.FINC'             ; Runtime Ada standard
  LINK 0, loc_siz                     ; Prologue : frame niveau 0
  include 'MON_PROG.FINC'            ; Code généré par TLALOC
  CALL STANDARD., MON_PROG_L1        ; Appel programme principal
  SYS_EXIT                            ; Sortie système
  virtual VARzone
    loc_siz = $
  end virtual
end namespace
```

### 6.3 Structure d'un fichier .FINC (généré)

```fasm
include 'TEXT_IO.FINC'                ; Dépendances (WITH)
PRO DIS_BONJOUR_L1                    ; Début procédure
ELB 1                                 ; Élaboration body niveau 1
begin:
  STR STR_L1, ' Bonjour '            ; Constante string
  LCA STR_L1.data_ptr                ; Empile adresse du string
  CALL STANDARD.TEXT_IO., PUT_L56    ; Appel TEXT_IO.PUT
ret_lbl:
  UNLINK 1                            ; Destruction frame
  RTD                                 ; Retour
excep:                                ; Point d'entrée exceptions
endPRO                                ; Fin procédure
```

### 6.4 Jeu d'instructions LLIR (partiel, à compléter)

| Macro | Signification | Effet |
|-------|---------------|-------|
| `PRO` / `endPRO` | Procedure / End | Délimite une procédure |
| `ELB n` | Elaborate Body | Prologue de body, niveau n |
| `STR label, "..."` | String | Déclare une constante string |
| `LCA addr` | Load Constant Address | Empile une adresse constante |
| `CALL ns.name` | Call | Appel de sous-programme |
| `UNLINK n` | Unlink | Destruction du frame niveau n |
| `RTD` | Return | Retour de sous-programme |
| `LINK n, size` | Link | Création du frame niveau n |
| `SYS_EXIT` | System Exit | Terminaison du programme |

Ce jeu sera documenté de manière exhaustive dans un document dédié
(`LLIR_REFERENCE.md`) au fur et à mesure du développement de l'EXPANDER.


## 7. Filiation historique

TLALOC s'inscrit dans une lignée de travaux sur la compilation Ada 83 :

- **Projet NYU Ada** (Courant Institute) : spécification SETL
  interprétable du langage, antérieure à 1990.

- **Ada/Ed-C** : traduction en C de la spécification SETL, fruit d'une
  collaboration ENST / NYUADA (1986). Code interprété par machine
  virtuelle. Sources encore accessibles et recompilables.

- **Thèses de Pologne** (Gliwice, 1990) : projet ada/IIPS sous la
  direction de P. Szmal. Traducteur DIANA → A-code (M. Ciernak),
  linker Ada (M. Chlopek), runtime (D. Glowaki), traduction A-code →
  assembleur 386 (A. Wierzinska).

- **Front-end Peregrine Systems** (~1988) : prototype de traducteur
  Ada 83 → DIANA par Bill Easton. Système en phases distinctes avec
  gestion par pages virtuelles. C'est ce prototype qui a servi de base
  à TLALOC, largement modifié pour exploiter les possibilités de GNAT.


## 8. Métriques

| Composant | Lignes | % du total |
|-----------|--------|------------|
| SEM_PHASE (28 subunits) | 22 193 | 64.6% |
| EXPANDER (6 fichiers) | 5 971 | 17.4% |
| IDL (spec + body + 4 subunits) | 2 123 | 6.2% |
| PAR_PHASE (+ LEX, GRMR) | 1 924 | 5.6% |
| LIB_PHASE | 1 230 | 3.6% |
| PRETTY_DIANA | 441 | 1.3% |
| WRITE_LIB | 264 | 0.8% |
| ADA_COMP | 179 | 0.5% |
| ERR_PHASE | 99 | 0.3% |
| **Total** | **34 344** | **100%** |

Ratio frontend/backend : 4.8:1 (typique d'un compilateur académique).
Plus gros fichier : `make_nod.adb` (2 925 lignes).


## 9. Conventions et organisation du code Ada 83

Le code respecte strictement Ada 83 : pas de child packages (Ada 95+).
La modularité est obtenue par le mécanisme de subunits :

```ada
-- Déclaration dans idl.ads :
procedure SEM_PHASE (...);

-- Dans idl.adb :
procedure SEM_PHASE (...) is separate;

-- Fichier séparé idl-sem_phase.adb :
separate (IDL)
procedure SEM_PHASE (...) is
  ...
end SEM_PHASE;
```

La notation `_[` dans les diagrammes de structure indique un subunit
de package (accès aux déclarations du parent), tandis que `_(` indique
un subunit de procédure.


## 10. Pour aller plus loin

- **Spécification DIANA** : `doc/DIANA-Ref-Manual-1986-rev4.pdf`
- **Nœuds DIANA navigables** : `doc/DIANA_NODES.pdf`
- **Classes DIANA** : `doc/DIANA_CLASS_.odt`
- **Spécification IDL source** : `idl/diana.idl`
- **Documentation LLIR** : `doc/LLIR_REFERENCE.md` (à créer)
- **Thèses de Pologne** : `doc/Thèses_Pologne/`
- **Wiki Ada 83** : https://ada83.org/wiki/
