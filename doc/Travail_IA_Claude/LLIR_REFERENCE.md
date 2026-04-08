# LLIR — Low Level Intermediate Representation

## Référence du jeu d'instructions de la machine à pile TLALOC

**Version** : avril 2026
**Fichier source** : `src/expander/fasmg/codi_x86_64.finc`
**Cible** : Linux x86-64, ELF, via fasmg


## 1. Principes généraux

La LLIR est un jeu de macros FASM décrivant une **machine à pile** dont
les instructions opèrent sur une pile de travail croissant vers les
adresses hautes. Ce choix inhabituel (les piles processeur croissent
vers le bas) est délibéré : le sens descendant est ingérable pour
certaines variables locales structurées d'Ada 83.

Le code LLIR est écrit par l'EXPANDER dans un fichier `.FINC`, puis
inclus dans un wrapper `.fas` qui fournit l'en-tête ELF, le prologue
système et le runtime. L'assemblage par `fasmg` produit directement un
exécutable ELF x86-64 monolithique (pas d'étape de linkage).


## 2. Organisation mémoire

### 2.1 Registres dédiés

| Registre | Rôle |
|----------|------|
| **RBP** | Pointeur de sommet de la pile de travail (croissante vers le haut). Pointe sur la dernière valeur empilée (qword). |
| **RSP** | Micro-pile descendante pour les adresses de retour CALL/RET uniquement. Ne sert pas aux données. |
| **R15** | Base du display des frame pointers (32 niveaux max, soit 256 octets). |
| **R14** | Sommet de la co-pile (lieu d'allocation dynamique). |
| **R13** | Frame pointer de co-pile (début de chaîne pour désallocation). |
| **R12** | Haut du tas (zone allouée en début d'exécution, expansion vers le bas). |
| **R11** | Pointeur de bloc libre du tas. |
| **RAX** | Registre de travail principal (chargement, calcul). |
| **RBX** | Registre de travail secondaire (store, opérande droit). |
| **RCX** | Compteur (boucles BLKMOV, décalages). |
| **RDX** | Opérande auxiliaire (division, syscalls). |
| **RSI, RDI** | Paramètres syscalls Linux. |

### 2.2 Les trois piles

**Pile de travail** (RBP) : croît vers les adresses hautes. Contient
les valeurs temporaires, les variables locales (taille connue à la
compilation) et les frame pointers sauvegardés. Les opérations
PUSH_RAX/POP_RAX écrivent/lisent à `[rbp±8]` puis ajustent RBP.

**Micro-pile** (RSP) : pile processeur classique (décroissante). Sert
exclusivement aux adresses de retour des CALL/RET x86. Aussi utilisée
ponctuellement pour des allocations temporaires (termios dans GET_CHAR).

**Co-pile** (R14/R13) : pile d'allocation dynamique pour les variables
dont la taille n'est connue qu'à l'exécution (tableaux à bornes
dynamiques). Organisée en frames chaînés : chaque LINK crée un nouveau
frame de co-pile, chaque UNLINK libère toutes les allocations du niveau.
Cela évite de mélanger allocations statiques et dynamiques sur la pile
de travail, et rend la désallocation triviale (pas de gestion de tas).

### 2.3 Le display

Zone de 32 emplacements qword pointée par R15, contenant les frame
pointers de chaque niveau lexical (0 à 31). Permet l'accès aux
variables des portées englobantes en Ada 83 (niveaux lexicaux).

`FP(lvl)` = `[R15 + 8*lvl]` = frame pointer du niveau lexical `lvl`.

### 2.4 Layout mémoire global

```
Adresses basses                              Adresses hautes
─────────────────────────────────────────────────────────────
│ ELF header │ Code + Constantes │ Co-pile │    ...     │
│  0x400000  │     0x400078      │ R14 →   │            │
─────────────────────────────────────────────────────────────

                                    │ 1Mo réservé en mémoire │
                                    └────────────────────────┘

RSP (micro-pile, décroissante)
  │
  ├── Display (32 × 8 = 256 octets)  ← R15
  │
  └── Pile de travail (croissante)    ← RBP
```


## 3. Structure d'un programme LLIR

### 3.1 Wrapper (.fas)

```fasm
include 'codi_x86_64.finc'       ; Macros LLIR et en-tête ELF
STANDARD = 'STANDARD'
namespace STANDARD
  virtual at 8                    ; Espace variables globales
    VARzone::
  end virtual
  include '_STANDRD.FINC'         ; Runtime Ada 83 (STANDARD, TEXT_IO...)
  LINK 0, loc_siz                 ; Frame niveau 0 (programme principal)
  include 'MON_PROG.FINC'        ; Code généré par l'EXPANDER
  CALL STANDARD., MON_PROG_L1    ; Appel du programme principal
  SYS_EXIT                        ; Retour au système
  virtual VARzone
    loc_siz = $                   ; Calcul rétropropagé de la taille
  end virtual
end namespace
```

### 3.2 Unité compilée (.FINC)

```fasm
include 'TEXT_IO.FINC'            ; Dépendances (clauses WITH)

PRO DIS_BONJOUR_L1               ; Début de procédure
ELB 1                            ; Élaboration body, niveau 1
                                  ; (déclarations locales ici)
begin:                            ; Instructions exécutables
  STR STR_L1, ' Bonjour '        ; Constante string
  LCA STR_L1.data_ptr            ; Empile l'adresse du string
  CALL STANDARD.TEXT_IO., PUT_L56 ; Appel TEXT_IO.PUT
ret_lbl:                          ; Point de sortie normal
  UNLINK 1                        ; Détruit le frame
  RTD                             ; Retour
excep:                            ; Point d'entrée des exceptions
endPRO                            ; Fin de procédure
```

### 3.3 Structure systématique d'une procédure

Chaque procédure/fonction suit ce squelette :

```
PRO  nom_L<n>           ; Ouvre un namespace FASM
  [PRMS / PRM / endPRMS] ; Déclaration des paramètres (si présents)
  ELB  <lvl>             ; Prologue : LINK + allocation locales
    [VAR / STR / CST]    ; Déclarations locales
  begin:                 ; Code exécutable
    ...
  ret_lbl:               ; Sortie normale
    UNLINK <lvl>         ; Restauration du frame
    RTD [prm_size]       ; Retour (avec désallocation paramètres)
  excep:                 ; Gestionnaire d'exceptions (futur)
endPRO                   ; Ferme le namespace, calcule loc_siz
```


## 4. Catalogue des instructions LLIR

### 4.1 Constantes et chargements immédiats

| Instruction | Paramètres | Effet pile | Description |
|-------------|------------|------------|-------------|
| `LI val` | val (32 bits signé) | → val | Empile un entier immédiat |
| `LIF val` | val (flottant) | → val | Empile un flottant (fld1 si val=1.0) |
| `LCA ptr` | ptr (64 bits) | → ptr | Empile une adresse constante (64 bits) |

### 4.2 Chargement de variables (Load)

Convention : `lvl` = niveau lexical (-1 = adresse empilée), `disp` = déplacement depuis le frame pointer.

**Accès direct** (via frame pointer) :

| Instruction | Taille | Effet |
|-------------|--------|-------|
| `Lb lvl, disp` | 8 bits | Empile `byte[FP(lvl) + disp]` (sign-extended) |
| `Lw lvl, disp` | 16 bits | Empile `word[FP(lvl) + disp]` (sign-extended) |
| `Ld lvl, disp` | 32 bits | Empile `dword[FP(lvl) + disp]` (sign-extended) |
| `Lq lvl, disp` | 64 bits | Empile `qword[FP(lvl) + disp]` |
| `La lvl, disp` | 64 bits | Synonyme de Lq (adresse) |
| `LVa lvl, disp` | — | Empile l'adresse `FP(lvl) + disp` (sans lire la donnée) |

**Accès indirect** (via pointeur stocké dans le frame) :

| Instruction | Taille | Effet |
|-------------|--------|-------|
| `LIb lvl, disp, ofs` | 8 bits | Empile `byte[ [FP(lvl)+disp] + ofs ]` |
| `LIw lvl, disp, ofs` | 16 bits | Empile `word[ [FP(lvl)+disp] + ofs ]` |
| `LId lvl, disp, ofs` | 32 bits | Empile `dword[ [FP(lvl)+disp] + ofs ]` |
| `LIq lvl, disp, ofs` | 64 bits | Empile `qword[ [FP(lvl)+disp] + ofs ]` |
| `LIa lvl, disp, ofs` | 64 bits | Synonyme de LIq |
| `LIVa lvl, disp, ofs` | — | Empile l'adresse `[FP(lvl)+disp] + ofs` |

Le cas `lvl = -1` signifie que l'adresse de base est prise sur la pile
(dépilée) au lieu du display. Cela permet l'adressage via un pointeur
calculé dynamiquement.

### 4.3 Rangement de variables (Store)

**Accès direct :**

| Instruction | Taille | Effet |
|-------------|--------|-------|
| `Sb lvl, disp` | 8 bits | `byte[FP(lvl)+disp] ← dépile` |
| `Sw lvl, disp` | 16 bits | `word[FP(lvl)+disp] ← dépile` |
| `Sd lvl, disp` | 32 bits | `dword[FP(lvl)+disp] ← dépile` |
| `Sq lvl, disp` | 64 bits | `qword[FP(lvl)+disp] ← dépile` |
| `Sa lvl, disp` | 64 bits | Synonyme de Sq |

**Accès indirect :**

| Instruction | Taille | Effet |
|-------------|--------|-------|
| `SIb lvl, disp, ofs` | 8 bits | `byte[ [FP(lvl)+disp] + ofs ] ← dépile` |
| `SIw lvl, disp, ofs` | 16 bits | `word[ [FP(lvl)+disp] + ofs ] ← dépile` |
| `SId lvl, disp, ofs` | 32 bits | `dword[ [FP(lvl)+disp] + ofs ] ← dépile` |
| `SIq lvl, disp, ofs` | 64 bits | `qword[ [FP(lvl)+disp] + ofs ] ← dépile` |
| `SIa lvl, disp, ofs` | 64 bits | Synonyme de SIq |

### 4.4 Opérations arithmétiques entières

| Instruction | Effet pile | Description |
|-------------|------------|-------------|
| `ADD` | a, b → a+b | Addition |
| `SUB` | a, b → a-b | Soustraction |
| `MUL` | a, b → a*b | Multiplication signée (imul) |
| `DIV` | a, b → a/b | Division entière signée (idiv) |
| `REM` | a, b → a rem b | Reste de division signée |
| `NEG` | a → -a | Négation |
| `ABS` | a → |a| | Valeur absolue (sans branchement) |
| `INC` | a → a+1 | Incrément |
| `DEC` | a → a-1 | Décrément |

### 4.5 Opérations logiques

| Instruction | Effet pile | Description |
|-------------|------------|-------------|
| `ET` | a, b → a AND b | ET logique/bit à bit |
| `OU` | a, b → a OR b | OU logique/bit à bit |
| `NON` | a → NOT a | Complément |
| `OUX` | a, b → a XOR b | OU exclusif |
| `SHL` | a, n → a << n | Décalage gauche |
| `SAR` | a, n → a >> n | Décalage arithmétique droit |

### 4.6 Comparaisons

| Instruction | Effet pile | Description |
|-------------|------------|-------------|
| `CGT` | a, b → (a > b) | A empilé en premier, puis B. Résultat booléen (0/1). |
| `CGE` | a, b → (a ≥ b) | Idem. |
| `CEQ` | a, b → (a = b) | Idem. |

Pour obtenir `<` ou `≤`, inverser l'ordre d'empilement de A et B.

### 4.7 Contrôle de flot

| Instruction | Paramètres | Description |
|-------------|------------|-------------|
| `BRA lbl` | label | Branchement inconditionnel (jmp rel32) |
| `BT lbl` | label | Branchement si vrai (dépile, saute si ≠ 0) |
| `BF lbl` | label | Branchement si faux (dépile, saute si = 0) |
| `CALL ns., name` | namespace, nom | Appel de sous-programme. Empile l'adresse de retour sur la micro-pile RSP. |
| `RTD [prm_size]` | taille paramètres | Retour. Désalloue `prm_size` octets de la pile de travail avant le ret. |

### 4.8 Gestion de pile et frames

| Instruction | Paramètres | Description |
|-------------|------------|-------------|
| `LINK lvl, alloc` | niveau, taille | Sauvegarde FP(lvl), met à jour le display, alloue `alloc` octets de variables locales. Crée aussi un frame de co-pile. |
| `UNLINK lvl` | niveau | Restaure le frame pointer FP(lvl), libère les variables locales et le frame de co-pile correspondant. |
| `PRO name` | label | Début de procédure : ouvre un namespace FASM, BRA autour de l'élaboration. |
| `endPRO` | — | Fin de procédure : calcule `loc_siz` (taille des locales rétropropagée au LINK), ferme le namespace. |
| `ELB lvl` | niveau | Point d'entrée de l'élaboration : ouvre la zone VARzone, appelle LINK. |

### 4.9 Déclarations

| Instruction | Paramètres | Description |
|-------------|------------|-------------|
| `VAR name, sizChar [, count]` | nom, taille, nombre | Déclare une variable locale dans la VARzone virtuelle. Tailles : b (byte), w (word), d (dword), q (qword) ou un nombre d'octets. |
| `STR name, "bytes"` | nom, contenu | Déclare une constante string Ada : descripteur `[ptr_data, ptr_info]` + zone info `[tot_siz, comp_siz, first, last]` + octets. |
| `CST name, sizChar, val` | nom, taille, valeur | Déclare une constante. `sizChar` détermine l'alignement et la réservation. |
| `STATOFS name, siz` | nom, taille | Déclare un offset statique (pour les champs de record) dans une `virtual at 0`. |
| `USEINFO lvl, name, load_instr` | niveau, nom, instruction | Déclare et initialise un pointeur vers une info de type (USE_INFO). |
| `CO_VAR` | — | Alloue sur la co-pile : dépile la taille, empile l'adresse du bloc alloué. |

### 4.10 Paramètres

| Instruction | Description |
|-------------|-------------|
| `PRMS` | Ouvre la zone de déclaration des paramètres (virtual at 8 au-dessus du FP). |
| `PRM name` | Déclare un paramètre (qword, alloué séquentiellement). |
| `endPRMS` | Ferme la zone, calcule `prm_siz`. |

### 4.11 Manipulation de pile

| Instruction | Effet | Description |
|-------------|-------|-------------|
| `DROP` | a → | Jette le sommet de pile |
| `DUP` | a → a, a | Duplique le sommet de pile |
| `BLKMOV` | dst, count, src → | Copie `count` octets de `src` vers `dst` |

### 4.12 Appels système Linux

| Instruction | Effet | Description |
|-------------|-------|-------------|
| `SYS_EXIT` | — | Terminaison (syscall 60, code 0) |
| `SYS_PUT_CHAR` | char → | Écrit un caractère sur stdout |
| `SYS_PUT_STR` | @desc → | Écrit un string Ada sur stdout |
| `SYS_GET_CHAR` | @dest → | Lit un caractère sur stdin (mode non-canonique) |
| `SYS_GET_STR` | @desc → | Lit une ligne sur stdin |
| `SYS_FILE_CREATE` | @name → fd | Crée un fichier (O_CREAT+O_RDWR) |
| `SYS_FILE_OPEN` | @name → fd | Ouvre un fichier (RDWR) |
| `SYS_FILE_CLOSE` | fd → status | Ferme un fichier |
| `SYS_FILE_DELETE` | @name → status | Supprime un fichier (unlink) |
| `SYS_FILE_WRITE` | fd, @buf, len → status | Écrit dans un fichier |
| `SYS_FILE_READ` | fd, @buf, len → status | Lit depuis un fichier |
| `SYS_FILE_SET_POS` | fd, pos → status | Positionne dans un fichier (lseek) |


## 5. Représentation des strings Ada

Un string Ada 83 est représenté par un descripteur de deux qwords suivi
d'un bloc d'information et des caractères :

```
@data_ptr:  qword → adresse des caractères
@info_ptr:  qword → adresse du bloc info

Bloc info (4 × dword) :
  SIZ      : taille totale en octets
  COMP_SIZ : taille d'un composant (1 pour CHARACTER)
  FST_1    : borne inférieure (FIRST)
  LST_1    : borne supérieure (LAST)

Caractères : suite d'octets à l'adresse pointée par data_ptr
```

Pour une constante (macro `STR`), les caractères suivent immédiatement
le descripteur. Pour une variable, les octets sont alloués sur la
co-pile.


## 6. Mécanisme CALL/RTD

L'appel `CALL ns., name` utilise un mécanisme de résolution différée
via `postpone` : si le label `ns.name_` n'est pas déjà défini, il est
automatiquement résolu vers `ns.name.elab` (point d'entrée de
l'élaboration). Cela permet l'inclusion des `.FINC` dans n'importe
quel ordre.

Le `RTD prm_size` désalloue `prm_size` octets de la pile de travail
(les paramètres empilés par l'appelant) avant d'exécuter le `ret` x86
sur la micro-pile RSP.


## 7. Mécanisme du package MACHINE_CODE

Le package `MACHINE_CODE` permet l'insertion d'instructions LLIR
directement depuis le source Ada 83 via les `code statements`
(chapitre 13.8 du LRM). Chaque opcode est représenté comme un
littéral d'une énumération `ASM_OPCODE`, avec des types record
`ASM_OP_0` (0 opérande), `ASM_OP_1` (1 opérande), `ASM_OP_2`
(2 opérandes) pour les variantes.


## 8. Notes sur les performances et choix de conception

**Pile croissante** : imposée par la gestion de variables structurées
Ada (tableaux, records) dont les offsets sont plus naturels vers le
haut.

**Pas d'optimisation peephole** : des commentaires dans `codi_x86_64.finc`
(lignes 200-201) mentionnent des variables pour du peephole
PUSH-POP, mais le mécanisme est désactivé. C'est un axe d'amélioration
future.

**Tailles d'opération** : les mouvements de pile sont en 64 bits
(qword), mais l'arithmétique se fait souvent en 32 bits pour simplifier.
Les chargements de données de taille inférieure (byte, word, dword)
effectuent une extension de signe vers 64 bits (movsx).

**Co-pile vs tas** : la co-pile est préférée au tas pour les
allocations dynamiques de taille connue à l'entrée d'un bloc, car
la désallocation est automatique et triviale (restauration du frame
pointer R13). Le tas (R12/R11) est réservé aux allocations
`new` (access types).
