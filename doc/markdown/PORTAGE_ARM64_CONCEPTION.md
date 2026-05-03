# PORTAGE ARM64 — Document de conception pour `codi_arm.finc`

## Référence de portage du backend TLALOC vers AArch64 / Linux

**Version** : avril 2026
**Cible** : Linux AArch64, ELF64, via fasmg
**Source** : portage de `src/expander/fasmg/codi_x86_64.finc` (1658 lignes)
**Méthode** : émission d'octets via `dd` 32 bits little-endian (les instructions
ARM64 font 32 bits de largeur fixe), sans recourir au syntaxe assembleur native
de fasmg — strictement comme la version x86-64 actuelle.


## 1. Principes directeurs du portage

La sémantique LLIR définie dans `LLIR_REFERENCE.md` est **conservée à
l'identique**. L'EXPANDER continue d'émettre exactement les mêmes macros
(`PUSH_RAX`, `Lq`, `Sd`, `ADD`, `BRA`, `LINK`, `CALL`, `SYS_FILE_OPEN`, ...) sans
aucune modification. Seul le contenu binaire émis par chaque macro change. Cela
implique trois conséquences :

1. **Aucune refonte de l'EXPANDER** n'est requise — il faut seulement substituer
   `codi_x86_64.finc` par `codi_arm.finc` dans le wrapper `.fas`.
2. **Les noms de macros sont conservés** (y compris ceux qui réfèrent à des
   registres x86 — `PUSH_RAX`, `POP_RBX`, `INDIRECT_BASE_IN_RAX`...) ; ces noms
   deviennent purement symboliques sur ARM, mais leur sémantique fonctionnelle
   reste identique. Inutile de renommer pour éviter de toucher au compilateur.
3. **La micro-pile descendante des adresses de retour est simulée** : `bl` met
   l'adresse de retour dans `x30` (LR) ; chaque CALL fait un push manuel de LR
   sur SP avant le branchement, et chaque RTD un pop de SP vers x30 avant `ret`.

Toutes les instructions ARM64 sont émises sous forme `dd 0xXXXXXXXX` (un mot de
32 bits little-endian). C'est rigoureusement homologue à l'usage actuel de
`db 0x48, 0x89, ...` sur x86-64.


## 2. Plan d'attribution des registres

Les registres ARM64 sont nommés `x0..x30` (64 bits) ou `w0..w30` (32 bits, vue
basse). `x31` n'existe pas en tant que tel : selon le contexte d'instruction, le
code 31 désigne soit `xzr`/`wzr` (zéro register), soit `sp` (stack pointer).

| Rôle LLIR | Registre x86-64 | Registre ARM64 | Justification |
|-----------|-----------------|----------------|---------------|
| Pile de travail (sommet) | RBP | **x29** (FP) | x29 est conventionnellement le frame pointer ARM ; choix sémantiquement adapté. |
| Micro-pile retours CALL/RET | RSP | **sp** (x31) | Registre de pile matériel ; alignement 16 octets requis pour SP par l'ABI Linux/AArch64. |
| Display des frame pointers | R15 | **x28** | Premier registre callee-saved disponible. |
| Sommet co-pile | R14 | **x27** | Callee-saved. |
| Frame pointer co-pile | R13 | **x26** | Callee-saved. |
| Haut du tas | R12 | **x25** | Callee-saved. |
| Bloc libre tas | R11 | **x24** | Callee-saved. |
| Travail principal | RAX | **x0** | Convention de retour des syscalls et appels — naturel pour le rôle de RAX. |
| Travail secondaire | RBX | **x1** | |
| Compteur (BLKMOV, shifts) | RCX | **x2** | |
| Auxiliaire (division, syscalls) | RDX | **x3** | |
| Param syscall (source) | RSI | **x4** initialement, puis remappé vers x1 pour syscall | Voir section syscalls. |
| Param syscall (destination) | RDI | **x5** initialement, puis remappé vers x0 pour syscall | Voir section syscalls. |
| Adresse de retour CALL | (sur RSP) | **x30** (LR), poussée manuellement sur SP | |

**Note importante sur les syscalls Linux/AArch64** : la convention est
`x8 = numéro de syscall`, `x0..x5 = arguments`, retour dans `x0`. Cela diffère
fortement de x86-64 (où c'est `rax = numéro`, `rdi/rsi/rdx/r10/r8/r9 = arguments`).
Les macros syscall doivent positionner les arguments dans `x0..x5` dans le bon
ordre, ce qui peut nécessiter des transferts internes que la version x86-64 n'a
pas besoin de faire.

**Registre x16 (IP0) et x17 (IP1)** : registres temporaires libres, utilisés
quand on a besoin de plus de scratch (notamment pour matérialiser une adresse
absolue 64 bits via `movz`/`movk` avant un `blr`).

**Cohérence avec le code généré par l'EXPANDER** : les noms `PUSH_RAX`,
`POP_RBX`, etc. sont les noms FASM des macros. Sur ARM64, `PUSH_RAX` poussera
en réalité le contenu de `x0` sur la pile pointée par `x29` (et `x29` montera
de 8). La sémantique reste identique au regard du LLIR.


## 3. Adressage mémoire — détails critiques

### 3.1 Les deux familles d'instructions LDR/STR

ARM64 dispose de deux variantes pour les load/store à offset immédiat :

**LDR/STR (immediate, unsigned offset) — *scalé*** :
- `LDR Xt, [Xn, #imm]` : `imm` est positif, plage 0 à 32760 par pas de 8.
- `LDR Wt, [Xn, #imm]` : `imm` 0 à 16380 par pas de 4.
- `LDRH Wt, [Xn, #imm]` : 0 à 8190 par pas de 2.
- `LDRB Wt, [Xn, #imm]` : 0 à 4095 par pas de 1.
- L'encodage stocke `imm/scale` sur 12 bits → `imm12`.

**LDUR/STUR (immediate, unscaled, signed)** :
- 9 bits signés : −256 à +255 octets, **non scalé**.
- Permet les offsets négatifs et les offsets non alignés sur la taille d'accès.
- Encodage : presque identique à LDR/STR avec un autre champ.

### 3.2 Stratégie de génération

Le code TLALOC manipule très souvent des offsets **négatifs** depuis `RBP` (les
paramètres et certaines variables avec tailles dynamiques sont sous le frame
pointer). Sur x86-64, pas de souci, l'offset 8/32 bits est signé. Sur ARM64,
trois cas :

1. **Offset 0** ou positif multiple de la taille d'accès, dans la plage scalée :
   utiliser `LDR/STR` (imm12 = offset/scale).
2. **Offset entre −256 et +255**, ou non aligné : utiliser `LDUR/STUR`.
3. **Offset hors plage des deux** : matérialiser l'offset dans `x16` via
   `movz/movk`, puis utiliser la forme à registre indexé : `LDR Xt, [Xn, x16]`.

Cette logique est encapsulée dans des macros internes `EMIT_LDR_size`,
`EMIT_STR_size` qui prennent `disp` et gèrent les trois cas.

### 3.3 Différence fondamentale x86 vs ARM64 : pas d'opérations RMW mémoire

Sur x86-64 :
```
add qword ptr [rbp], rax   ; en une instruction, 4 octets
```

Sur ARM64, il faut explicitement :
```
ldr  x1, [x29]      ; charger
add  x1, x1, x0     ; opérer
str  x1, [x29]      ; ranger
```

Cela concerne toutes les macros qui modifient `[rbp]` directement : `ADD`, `SUB`,
`OUX`, `ET`, `OU`, `NON`, `INC`, `DEC`, `NEG`, `SHL`, `SAR`, ainsi que les
`setXX [rbp]` des comparaisons. Le code ARM sera plus long mais plus régulier.


## 4. Macros élémentaires — équivalences

### 4.1 Pile de travail (PUSH/POP/DROP/DUP)

Convention : `x29` est l'analogue de RBP, pointant sur la dernière valeur
empilée (dernier qword écrit). Pour empiler, on écrit à `[x29, #8]` puis on
incrémente `x29` de 8.

| Macro | Équivalent x86-64 | Équivalent ARM64 |
|-------|-------------------|------------------|
| `PUSH_RAX` | `mov [rbp+8], rax` ; `lea rbp, [rbp+8]` | `stur x0, [x29, #8]` ; `add x29, x29, #8` |
| `POP_RAX` | `mov rax, [rbp]` ; `lea rbp, [rbp-8]` | `ldr x0, [x29]` ; `sub x29, x29, #8` |
| `POP_RBX` | idem avec rbx | idem avec x1 |
| `POP_RCX` | idem avec rcx | idem avec x2 |
| `POP_RDX` | idem avec rdx | idem avec x3 |
| `POP_RSI` | idem avec rsi | idem avec x4 (transfert vers x1 si syscall) |
| `POP_RDI` | idem avec rdi | idem avec x5 (transfert vers x0 si syscall) |
| `DROP` | `lea rbp, [rbp-8]` | `sub x29, x29, #8` |
| `DUP` | `mov rax, [rbp]` ; `mov [rbp+8], rax` ; `lea rbp, [rbp+8]` | `ldr x0, [x29]` ; `stur x0, [x29, #8]` ; `add x29, x29, #8` |

Chaque macro coûte 2 instructions (8 octets) sur ARM64, comme sur x86-64
(qui faisait 8 octets aussi avec deux instructions de 4 octets MOV+LEA).

### 4.2 Frame pointer dans le display (FP_IN_RAX, FP_IN_RBP, RAX_IN_FP)

Le display est pointé par `x28` (R15 sur x86). Pour `lvl ∈ [0..31]`, l'offset
est `8*lvl` ∈ [0, 248], qui rentre dans imm12 scalé par 8 (imm12 = lvl) — donc
toujours en une seule instruction LDR/STR.

| Macro | x86-64 | ARM64 |
|-------|--------|-------|
| `FP_IN_RAX lvl` | `mov rax, [r15 + 8*lvl]` | `ldr x0, [x28, #8*lvl]` |
| `FP_IN_RBP lvl` | `mov rbp, [r15 + 8*lvl]` | `ldr x29, [x28, #8*lvl]` |
| `RAX_IN_FP lvl` | `mov [r15 + 8*lvl], rax` | `str x0, [x28, #8*lvl]` |

### 4.3 Chargements et rangements (FETCH_xxx, STORE_xxx)

Sur x86, `FETCH_BYTE disp` lit `byte ptr [rax + disp]` avec extension de signe
vers `rax`. Sur ARM64, c'est `LDRSB Xt, [Xn, #imm]` qui produit directement
l'extension de signe à 64 bits.

| Macro interne | x86-64 | ARM64 (cas disp ∈ plage scalée) |
|---------------|--------|--------------------------------|
| `FETCH_BYTE disp` | `movsx rax, byte ptr [rax + disp]` | `ldrsb x0, [x0, #disp]` |
| `FETCH_WORD disp` | `movsx rax, word ptr [rax + disp]` | `ldrsh x0, [x0, #disp]` |
| `FETCH_DWORD disp` | `movsxd rax, dword ptr [rax + disp]` | `ldrsw x0, [x0, #disp]` |
| `FETCH_QWORD disp` | `mov rax, qword ptr [rax + disp]` | `ldr x0, [x0, #disp]` |
| `STORE_BYTE disp` | `mov [rax + disp], BL` | `strb w1, [x0, #disp]` |
| `STORE_WORD disp` | `mov [rax + disp], BX` | `strh w1, [x0, #disp]` |
| `STORE_DWORD disp` | `mov [rax + disp], EBX` | `str w1, [x0, #disp]` |
| `STORE_QWORD disp` | `mov [rax + disp], RBX` | `str x1, [x0, #disp]` |

Le code FASM doit gérer les trois cas d'offset (cf. §3.2) : scalé positif via
LDR/STR ; non scalé signé court via LDUR/STUR ; hors plage via matérialisation
dans `x16`.

### 4.4 Load Immediate (LI, LIF, LCA)

| Macro | x86-64 | ARM64 |
|-------|--------|-------|
| `LI val` (32 bits signé étendu) | `mov rax, val` (5 octets imm32 + sign-extend) | jusqu'à 4 instructions `movz`/`movk` selon valeur, puis `PUSH_RAX` |
| `LIF val` (double IEEE 754) | `movabs rax, dq val` ; `PUSH_RAX` | `movz/movk` × 4 pour matérialiser le pattern de bits 64 bits dans x0, puis `PUSH_RAX` |
| `LCA ptr` (adresse 64 bits) | `movabs rax, ptr` ; `PUSH_RAX` | comme LIF, matérialisation 64 bits par 4 movz/movk dans x0, puis `PUSH_RAX` |

Détails matérialisation 64 bits arbitraires :
```
movz x0, #imm0, lsl #0
movk x0, #imm1, lsl #16
movk x0, #imm2, lsl #32
movk x0, #imm3, lsl #48
```
Optimisable : si certains chunks sont à zéro, on peut sauter les `movk`
correspondants. Pour la première version, on émet systématiquement les 4
instructions (16 octets) dans `LCA` ; pour `LI` on fait les optimisations
(`movz` seul si valeur tient sur 16 bits zéro-étendus, `movn` si tient sur
16 bits avec extension de uns, sinon `movz` + `movk` × 1..3).


## 5. Arithmétique et logique entière

### 5.1 Macros qui modifient `[rbp]` (top of stack en place)

Toutes deviennent une séquence load → opération → store. Pour économiser sur
les macros les plus fréquentes (ADD, SUB, ET, OU, OUX), on combine les deux
opérandes : la valeur dépilée est dans `x0` (POP_RAX), on lit le nouveau TOS
depuis `[x29]` dans `x1`, on calcule, on range.

| Macro | x86-64 | ARM64 |
|-------|--------|-------|
| `ADD` | POP_RAX ; `add [rbp], rax` | `POP_RAX` ; `ldr x1, [x29]` ; `add x1, x1, x0` ; `str x1, [x29]` |
| `SUB` | POP_RAX ; `sub [rbp], rax` | POP_RAX ; ldr x1, [x29] ; sub x1, x1, x0 ; str x1, [x29] |
| `MUL` | POP_RAX ; `imul [rbp]` ; DROP ; PUSH_RAX | POP_RAX ; ldr x1, [x29] ; mul x1, x1, x0 ; str x1, [x29] |
| `DIV` | POP_RBX ; POP_RAX ; `idiv rbx` ; PUSH_RAX | POP_RBX ; POP_RAX ; sdiv x0, x0, x1 ; PUSH_RAX |
| `REMI` | POP_RBX ; POP_RAX ; cqo ; idiv ; mov rax,rdx ; PUSH_RAX | POP_RBX ; POP_RAX ; sdiv x2, x0, x1 ; msub x0, x2, x1, x0 ; PUSH_RAX |
| `MODI` | comme REMI + ajustement de signe | comme REMI + branche conditionnelle pour ajustement |
| `INC` | `inc [rbp]` | ldr x0, [x29] ; add x0, x0, #1 ; str x0, [x29] |
| `DEC` | `dec [rbp]` | ldr x0, [x29] ; sub x0, x0, #1 ; str x0, [x29] |
| `NEG` | `neg [rbp]` | ldr x0, [x29] ; sub x0, xzr, x0 ; str x0, [x29] (alias `neg`) |
| `ABS` | mov rax,[rbp] ; sar rax,63 ; xor [rbp],rax ; sub [rbp],rax | ldr x0, [x29] ; cmp x0, #0 ; cneg x0, x0, mi ; str x0, [x29]  *(ARM a un `cneg` qui simplifie)* |
| `ET` | POP_RAX ; `and [rbp], rax` | POP_RAX ; ldr x1, [x29] ; and x1, x1, x0 ; str x1, [x29] |
| `OU` | POP_RAX ; `or [rbp], rax` | POP_RAX ; ldr x1, [x29] ; orr x1, x1, x0 ; str x1, [x29] |
| `OUX` | POP_RAX ; `xor [rbp], rax` | POP_RAX ; ldr x1, [x29] ; eor x1, x1, x0 ; str x1, [x29] |
| `NON` | `not [rbp]` | ldr x0, [x29] ; mvn x0, x0 ; str x0, [x29] |
| `SHL` | POP_RCX ; `shl [rbp], cl` | POP_RCX ; ldr x0, [x29] ; lslv x0, x0, x2 ; str x0, [x29] |
| `SAR` | POP_RCX ; `sar [rbp], cl` | POP_RCX ; ldr x0, [x29] ; asrv x0, x0, x2 ; str x0, [x29] |

### 5.2 Comparaisons entières (CEQ, CNE, CGT, CGE, CLT, CLE)

x86 : `pop rbx` ; `cmp [rbp], rbx` ; `setXX [rbp]`. Le résultat occupe l'octet
bas, les 7 octets supérieurs gardent l'ancienne valeur (mais ce n'est pas
gênant car le test `or al,al` qui suit n'utilise que cet octet).

ARM64 : pas de `setXX` direct sur mémoire. On utilise `cset Wd, cond` qui pose
0 ou 1 dans un registre, puis `str x0, [x29]` pour ranger un mot complet
(garantie d'avoir 0 ou 1 strict sur 64 bits, donc même plus propre).

| Macro | ARM64 |
|-------|-------|
| `CEQ` | POP_RBX (x1) ; ldr x0, [x29] ; cmp x0, x1 ; cset x0, eq ; str x0, [x29] |
| `CNE` | POP_RBX ; ldr x0, [x29] ; cmp x0, x1 ; cset x0, ne ; str x0, [x29] |
| `CGT` | POP_RBX ; ldr x0, [x29] ; cmp x0, x1 ; cset x0, gt ; str x0, [x29] |
| `CGE` | POP_RBX ; ldr x0, [x29] ; cmp x0, x1 ; cset x0, ge ; str x0, [x29] |
| `CLT` | POP_RBX ; ldr x0, [x29] ; cmp x0, x1 ; cset x0, lt ; str x0, [x29] |
| `CLE` | POP_RBX ; ldr x0, [x29] ; cmp x0, x1 ; cset x0, le ; str x0, [x29] |

Note : `cset` est l'alias de `csinc Wd, WZR, WZR, invert(cond)`. Pour `eq`, on
encode avec la condition inverse `ne`.


## 6. Arithmétique flottante

ARM64 dispose d'un jeu d'instructions SIMD/FP **scalaire** beaucoup plus propre
que SSE2. Les flottants doubles sont dans `d0..d31` (vue 64 bits des registres
v0..v31). Une instruction `fadd d0, d0, d1` est lisible et concise.

Convention LLIR maintenue : les flottants IEEE 754 double 64 bits transitent par
la pile entière (qword). On charge depuis `[x29]` vers `d0`/`d1`, on calcule, on
range.

| Macro | x86-64 SSE2 | ARM64 NEON/FP |
|-------|-------------|---------------|
| `FADD` | movsd xmm1,[rbp] ; DROP ; movsd xmm0,[rbp] ; addsd xmm0,xmm1 ; movsd [rbp],xmm0 | ldr d1, [x29] ; DROP ; ldr d0, [x29] ; fadd d0, d0, d1 ; str d0, [x29] |
| `FSUB` | idem avec subsd | idem avec fsub |
| `FMUL` | mulsd | fmul |
| `FDIV` | divsd | fdiv |
| `FNEG` | xor byte ptr [rbp+7], 0x80 | ldr d0, [x29] ; fneg d0, d0 ; str d0, [x29] |
| `FABS` | and byte ptr [rbp+7], 0x7F | ldr d0, [x29] ; fabs d0, d0 ; str d0, [x29] |
| `FEXP` | boucle mulsd | boucle fmul (logique identique) |
| `CVTIF` | cvtsi2sd xmm0, rax | scvtf d0, x0 |
| `CVTFI` | cvttsd2si rax, xmm0 (troncature) | fcvtzs x0, d0 (troncature) |

Comparaisons flottantes : ARM64 utilise `fcmp d0, d1` qui pose les flags NZCV
selon la sémantique IEEE. Les conditions `eq`, `ne`, `gt`, `ge`, `mi` (=less),
`ls` (=less or equal) sont utilisables directement avec `cset`. Pour FCEQ/FCNE
le traitement explicite des NaN n'est pas nécessaire car `fcmp` suit déjà la
sémantique IEEE 754 (NaN → unordered, condition `ne` retourne true, autres
conditions de comparaison retournent false — exactement le comportement Ada
attendu).

| Macro | ARM64 |
|-------|-------|
| `FCEQ` | ldr d1,[x29] ; DROP ; ldr d0,[x29] ; fcmp d0, d1 ; cset x0, eq ; str x0, [x29] |
| `FCNE` | idem cset x0, ne |
| `FCGT` | idem cset x0, gt |
| `FCGE` | idem cset x0, ge |
| `FCLT` | idem cset x0, mi  *(condition « less than » sur fcmp = N flag set)* |
| `FCLE` | idem cset x0, ls  *(condition « lower or same »)* |

**Encodages des deux principales formes d'accès flottant à la pile** (offset 0
depuis x29) :

```
ldr d0, [x29]         → 0xFD400000   bytes: 0x00 0x00 0x40 0xFD
ldr d1, [x29]         → 0xFD400001   bytes: 0x01 0x00 0x40 0xFD
str d0, [x29]         → 0xFD000000   bytes: 0x00 0x00 0x00 0xFD
```


## 7. Contrôle de flot

### 7.1 Branchements

| Macro | x86-64 | ARM64 |
|-------|--------|-------|
| `BRA lbl` | jmp rel32 (5 octets) | b imm26 (4 octets, ±128 Mo) |
| `BT lbl` (branch true) | POP_RAX ; or al,al ; jnz rel32 | POP_RAX ; cbnz x0, imm19 (±1 Mo) |
| `BF lbl` (branch false) | POP_RAX ; or al,al ; jz rel32 | POP_RAX ; cbz x0, imm19 (±1 Mo) |

CBZ/CBNZ sont des branchements conditionnels à plage limitée (±1 Mo, imm19 × 4).
Pour la quasi-totalité des programmes Ada compilés, c'est suffisant. En cas de
dépassement, retomber sur `cmp x0, #0` + `b.eq lbl` (étendu sur ±128 Mo via
trampoline si vraiment nécessaire — peu probable en pratique).

### 7.2 Appels et retours — cœur du portage

C'est le point critique. La sémantique LLIR exige que `CALL` empile l'adresse de
retour sur la **micro-pile descendante** (analogue de RSP) et que `RTD`
dépile cette adresse pour y retourner. Sur x86-64, c'est le comportement matériel
de `call` et `ret`. Sur ARM64, `bl` met l'adresse de retour dans `x30` (LR) et
`ret` saute à `x30` — il faut donc pousser/dépiler manuellement.

**Macro `CALL prefix, subname` — sémantique LLIR : pousse le retour sur SP, saute** :

```
sub  sp, sp, #16        ; descendre SP (alignement 16 obligatoire pour SP)
str  x30, [sp]          ; sauvegarder LR sur la micro-pile
bl   target             ; bl pose la nouvelle adresse de retour dans x30
ldr  x30, [sp]          ; restaurer LR du caller
add  sp, sp, #16        ; remonter SP
```

Total : 5 instructions = 20 octets. Plus volumineux que les 5 octets x86, mais
sémantiquement équivalent.

**Variante alternative considérée puis rejetée** : utiliser un offset de 8 sur
SP pour économiser 16 → 8 octets de descente. Refusé car SP doit rester aligné
sur 16 octets pour les exceptions matérielles (l'ABI Linux/AArch64 l'exige
strictement, sinon `SIGBUS`).

**Macro `RTD prm_size` — désalloue les paramètres et retourne** :

```
[si prm_size > 0]
sub  x29, x29, #prm_size   ; libérer prm_size octets de la pile de travail
ret  x30                   ; retour à l'adresse dans LR
```

Le `bl` original a placé l'adresse de retour dans LR, et le `CALL` macro l'a
pré-restaurée ; la séquence se compose donc proprement avec le wrapper du
caller.

**Macro `CALLI` — appel indirect via valeur en sommet de pile** :

```
POP_RAX                    ; adresse cible dans x0
sub  sp, sp, #16
str  x30, [sp]
blr  x0
ldr  x30, [sp]
add  sp, sp, #16
```

### 7.3 Cas particulier : la cible CALL est-elle dans la portée de `bl` ?

`bl` couvre ±128 Mo. Pour un compilateur Ada produisant un binaire ELF
monolithique, c'est largement suffisant (les programmes générés font quelques
centaines de Ko à quelques Mo). On reste donc sur `bl rel26`. Au cas où une
résolution dépasserait la plage, on bascule sur :

```
movz x16, #imm0
movk x16, #imm1, lsl #16
...
blr  x16
```

Le mécanisme `postpone` de fasmg permet de calculer la distance et de choisir.
Pour la première version, on génère systématiquement la forme `bl` ; on ajoutera
le fallback uniquement si un programme test la déclenche.


## 8. LINK / UNLINK / PRO / endPRO

### 8.1 LINK lvl, alloc

Sémantique LLIR : sauvegarder l'ancien FP du niveau `lvl` sur la pile de travail,
mettre à jour l'entrée du display, allouer `alloc` octets de variables locales,
créer un frame de co-pile.

x86-64 (extrait simplifié) :
```
mov rax, [r15 + 8*lvl]    ; sauver ancien FP
mov [rbp+8], rax          ; sur la pile de travail
lea rbp, [rbp+8]
mov [r15 + 8*lvl], rbp    ; nouveau FP = position courante
lea rbp, [rbp + alloc]    ; allouer locales
mov [r14], r13            ; chaîner co-pile
mov r13, r14
lea r14, [r14 + 8]
```

ARM64 :
```
ldr  x0, [x28, #8*lvl]    ; ancien FP
stur x0, [x29, #8]        ; pousser
add  x29, x29, #8
str  x29, [x28, #8*lvl]   ; mettre à jour display
add  x29, x29, #alloc8    ; allouer locales (alloc arrondi à mult. de 8)
str  x26, [x27]           ; chaîner co-pile (x26=R13, x27=R14)
mov  x26, x27             ; (encodage : orr x26, xzr, x27)
add  x27, x27, #8
```

Le seul piège est si `alloc` arrondi excède 4095 (max imm12 sans shift). Dans ce
cas, soit utiliser le shift 12 (alloc ≤ 16M par 4K), soit matérialiser dans x0
puis `add x29, x29, x0`.

### 8.2 UNLINK lvl

x86-64 :
```
mov rbp, [r15 + 8*lvl]    ; restaurer FP du niveau (jette les locales)
mov rax, [rbp]            ; lire ancien FP sauvegardé
lea rbp, [rbp - 8]
mov [r15 + 8*lvl], rax    ; restaurer display
mov r13, [r13]            ; déchaîner co-pile
```

ARM64 :
```
ldr  x29, [x28, #8*lvl]
ldr  x0, [x29]
sub  x29, x29, #8
str  x0, [x28, #8*lvl]
ldr  x26, [x26]
```

### 8.3 PRO / endPRO

Aucune instruction émise par ces macros côté x86, c'est purement déclaratif
(ouverture/fermeture de namespace FASM). **Strictement identique sur ARM64** :
les macros restent inchangées. Le seul ajustement est interne au `BRA post` de
PRO (4 octets au lieu de 5).

### 8.4 ELB lvl, PRMS, PRM, endPRMS, VAR, CO_VAR

Tout ce qui concerne les zones virtuelles (`virtual at 8`, calcul de `loc_siz`,
`prm_siz`) reste identique — c'est de la mécanique fasmg, indépendante de la
cible. Seul le `LINK lvl, loc_siz` à la fin de `ELB` génère du code différent
(cf. §8.1).

Pour `CO_VAR` (allocation co-pile), équivalent ARM64 :
```
POP_RAX                          ; taille demandée
stur x27, [x29, #8]              ; empiler le sommet de co-pile
add  x29, x29, #8
add  x0, x0, #7                  ; arrondir à multiple de 8
asr  x0, x0, #3                  ; / 8
add  x27, x27, x0, lsl #3        ; co-pile += 8*x0
```


## 9. Représentation des constantes — STR, CST, BEGIN_BLOC_DEF, etc.

**Aucune modification.** Ces macros ne génèrent que des données (`db`, `dq`,
`align_q`...) dans des zones `postpone` ou `virtual`. Leur sémantique est
indépendante de la cible processeur. La représentation des strings Ada
(descripteur 16 octets + bloc info 16 octets + caractères) est conservée à
l'identique, ainsi que les conventions de format pour ENUMERATION_IO.


## 10. BLKMOV — copie de bloc

x86-64 utilise les instructions `lods`/`stos` avec préfixe `loop`. ARM64 n'a
rien de tel ; on écrit une boucle explicite :

```
POP_RSI                  ; x4 = src (puis transféré dans x4 réservé)
POP_RCX                  ; x2 = count
POP_RDI                  ; x5 = dst
                         ; (utilise x16, x17 comme scratch)
cbz  x2, .end            ; si count = 0, sauter
.loop:
ldrb w16, [x4], #1       ; charger octet et post-incrémenter src
strb w16, [x5], #1       ; ranger octet et post-incrémenter dst
sub  x2, x2, #1
cbnz x2, .loop
.end:
```

Total : 5 instructions de boucle (20 octets), une fois le préambule fait.
Note : ARM64 a aussi des formes `ldr [x4], #1` avec post-incrément, ce qui rend
la boucle élégante et compacte.


## 11. Syscalls Linux/AArch64 — convention et différences

### 11.1 Convention d'appel

| Aspect | x86-64 | AArch64 |
|--------|--------|---------|
| Numéro de syscall | rax | x8 |
| Argument 1 | rdi | x0 |
| Argument 2 | rsi | x1 |
| Argument 3 | rdx | x2 |
| Argument 4 | r10 | x3 |
| Argument 5 | r8 | x4 |
| Argument 6 | r9 | x5 |
| Instruction | syscall (0F 05) | svc #0 (D4 00 00 01) |
| Retour | rax | x0 |

### 11.2 Numéros de syscalls AArch64 Linux

Les numéros AArch64 sont **différents** de x86-64. Tableau pour ce qui est
utilisé par TLALOC :

| Fonction | x86-64 | AArch64 | Notes |
|----------|--------|---------|-------|
| `read` | 0 | 63 | identique sémantique |
| `write` | 1 | 64 | |
| `close` | 3 | 57 | |
| `open` | 2 | — | **n'existe pas** sur AArch64 |
| `openat` | 257 | 56 | utilisé à la place de `open` |
| `lseek` | 8 | 62 | |
| `unlink` | 87 | — | **n'existe pas** sur AArch64 |
| `unlinkat` | 263 | 35 | utilisé à la place de `unlink` |
| `ioctl` | 16 | 29 | |
| `exit` | 60 | 93 | |

### 11.3 `openat` et `unlinkat` — particularités

`openat` prend un argument supplémentaire en première position : un descripteur
de répertoire de référence. Pour reproduire la sémantique de `open` (chemins
relatifs au répertoire courant), on passe `AT_FDCWD = -100` (soit
`0xFFFFFFFFFFFFFF9C` sur 64 bits) en premier argument.

```
openat(AT_FDCWD, path, flags, mode)
```

Idem `unlinkat(AT_FDCWD, path, 0)` pour reproduire `unlink(path)`.

### 11.4 Mode terminal pour SYS_GET_CHAR

`ioctl(0, TCGETS, &termios)` puis modification du `c_lflag` (bit ICANON et bit
ECHO) puis `ioctl(0, TCSETS, &termios)` : la séquence est identique à x86-64, en
adaptant le numéro de syscall ioctl (29 au lieu de 16) et la convention
d'arguments. Les codes TCGETS = 0x5401 et TCSETS = 0x5402 sont **identiques** sur
les deux architectures Linux (ce sont des constantes du noyau, pas spécifiques
ABI).

### 11.5 Allocation pile pour le termios

Sur x86-64, `sub rsp, 64` ; `mov rdx, rsp`. Sur AArch64, la pile pointée par SP
doit rester alignée 16 octets (déjà mentionné en §7.2). 64 est multiple de 16
donc `sub sp, sp, #64` puis `mov x2, sp` fonctionne directement.

### 11.6 Encodage type des syscalls

Exemple pour `SYS_PUT_CHAR` (écrit 1 octet sur stdout = écriture du caractère
en sommet de pile à `[x29]`) :

```
mov  x1, x29           ; x1 = adresse du caractère
mov  x0, #1            ; x0 = stdout
mov  x2, #1            ; x2 = longueur 1
mov  x8, #64           ; x8 = sys_write
svc  #0
DROP                   ; consommer le caractère
```


## 12. En-tête ELF64 AArch64

Quasi-identique à la version x86-64 — seule différence pratique :

| Champ | Valeur x86-64 | Valeur AArch64 |
|-------|---------------|----------------|
| `e_machine` | 62 (EM_X86_64) | **183** (EM_AARCH64) |
| `e_entry` | 0x00400078 | **0x00400078** (peut rester) |
| `org` | 0x400000 | **0x400000** (idem) |
| Reste de l'en-tête | identique | identique |

`ELFCLASS64`, `ELFDATA2LSB`, `EV_CURRENT`, `ET_EXEC`, `SYSTEM_V` gardent leur
valeur. Le mécanisme de calcul de `ASM_SIZE` via `postpone` reste inchangé.

La taille de l'en-tête ELF (`e_ehsize=64`, `e_phentsize=56`, `e_phnum=1`) est
identique : ELF64 a une structure d'en-tête fixe quelle que soit l'architecture
cible.


## 13. Bootstrap au point d'entrée

Le code émis au point d'entrée du programme (avant l'inclusion du code utilisateur)
met en place : la micro-pile, le display, le frame pointer initial, la co-pile.
Sur x86-64 c'est ~7 instructions. Sur ARM64, équivalent :

```
;   x25 = post-haut du tas (équivalent r12)
mov   x25, sp                    ; sauvegarder le SP fourni par le noyau
;   sp = micro-pile descendante - 1Mo plus bas
mov   x16, #0x100000             ; 1 Mo
sub   sp, sp, x16
;   x28 = display (32 frame pointers) en bas de la zone réservée
mov   x28, sp
;   x29 = pile de travail = juste au-dessus du display
add   x29, x28, #8*32            ; 256 octets au-dessus de x28
;   FP du niveau 0 = x29
str   x29, [x28]
;   co-pile : x27 = bas de co-pile, juste après le code+constantes alignées qword
movz  x27, #(0x400078 + 8*((ASM_SIZE+7)/8)) bits 0..15
movk  x27, ... bits 16..31
movk  x27, ... bits 32..47
movk  x27, ... bits 48..63
;   premier "frame" de co-pile
str   x27, [x27]
mov   x26, x27                   ; orr x26, xzr, x27
add   x27, x27, #8
```

L'adresse `0x400078 + 8*((ASM_SIZE+7)/8)` n'étant connue qu'à la fin de
l'assemblage, le mécanisme `postpone` actuel se transpose directement : ces 4
movz/movk seront patchés avec les valeurs finales. Le code FASM peut s'écrire :

```fasmg
local co_pile_start
co_pile_start = 0x400078 + 8*((ASM_SIZE+7)/8)
dd 0xD2800000 + (((co_pile_start) and 0xFFFF) shl 5) + 27       ; movz x27, #imm16
dd 0xF2A00000 + ((((co_pile_start) shr 16) and 0xFFFF) shl 5) + 27   ; movk x27, #imm, lsl 16
dd 0xF2C00000 + ((((co_pile_start) shr 32) and 0xFFFF) shl 5) + 27   ; movk x27, #imm, lsl 32
dd 0xF2E00000 + ((((co_pile_start) shr 48) and 0xFFFF) shl 5) + 27   ; movk x27, #imm, lsl 48
```

(Encodage exact à confirmer macro par macro lors de la rédaction.)


## 14. Tableau récapitulatif des macros — couverture

Toutes les macros publiques de `codi_x86_64.finc` ont leur équivalent
fonctionnel ARM64 défini ci-dessus. Récapitulatif de la liste exhaustive (par
ordre dans le fichier source actuel) :

**Pile** : PUSH_RAX, PUSH_RDX, POP_RAX, POP_RBX, POP_RCX, POP_RDX, POP_RSI,
POP_RDI, DROP, DUP — **§4.1**.

**Alignement** : align_b, align_w, align_d, align_q — **inchangées** (manipulent
la position courante via `db 0x90` ou padding ; remplacer le 0x90 par un nop
ARM `0xD503201F`).

**Frame pointers** : FP_IN_RAX, RAX_IN_FP, FP_IN_RBP, BASE_IN_RAX,
INDIRECT_BASE_IN_RAX — **§4.2**.

**Fetch/Store internes** : FETCH_BYTE, FETCH_WORD, FETCH_DWORD, FETCH_QWORD,
STORE_BYTE, STORE_WORD, STORE_DWORD, STORE_QWORD — **§4.3**.

**Load constantes** : LI, LIF, LCA — **§4.4**.

**Load adresses variables** : LVa, LIVa — combinaison §4.2 + lea-équivalent (lea
sur ARM64 = `add Xd, Xn, #imm`).

**Load données** : Lb, Lw, Ld, Lq, La, LIb, LIw, LId, LIq, LIa — combinaisons
des macros internes.

**Store données** : Sb, Sw, Sd, Sq, Sa, SIb, SIw, SId, SIq, SIa — idem.

**Logique** : ET, OU, NON, OUX, SHL — **§5.1**.

**Arithmétique entière** : DEC, INC, NEG, ABS, ADD, SUB, MUL, DIV, REMI, MODI,
SAR — **§5.1**.

**Arithmétique flottante** : FADD, FSUB, FMUL, FDIV, FNEG, FABS, FEXP — **§6**.

**Conversions** : CVTIF, CVTFI — **§6**.

**Comparaisons entières** : CEQ, CNE, CGT, CGE, CLT, CLE — **§5.2**.

**Comparaisons flottantes** : FCEQ, FCNE, FCGT, FCGE, FCLT, FCLE — **§6**.

**Contrôle de flot** : BRA, BT, BF, CALL, CALLI, RTD — **§7**.

**Frames** : LINK, UNLINK, PRO, PRMS, PRM, endPRMS, ELB, endPRO — **§8**.

**Constantes structurelles** : BEGIN_BLOC_DEF, END_BLOC_DEF, STR, CST,
USEINFO, STATOFS, VAR, CO_VAR — **§9** (la plupart inchangées).

**BLKMOV** — **§10**.

**Syscalls** : SYS_PUT_CHAR, SYS_PUT_STR, SYS_GET_CHAR, SYS_GET_STR,
COPY_STRING_APPEND_NUL, SYS_FILE_CREATE, SYS_FILE_OPEN, SYS_FILE_SET_POS,
SYS_FILE_GET_POS, SYS_FILE_GET_SIZE, SYS_FILE_WRITE, SYS_FILE_READ,
SYS_FILE_CLOSE, SYS_FILE_DELETE, SYS_EXIT — **§11**.

**Bootstrap et ELF header** — **§12, §13**.


## 15. Stratégie de validation

Une fois `codi_arm.finc` rédigé, vérifications recommandées :

1. **Assemblage** : produire un binaire ELF avec un programme test minimal
   (équivalent `dis_bonjour.adb`) et vérifier l'en-tête avec `readelf -h`.
2. **Désassemblage** : `objdump -d` pour vérifier que les séquences émises
   correspondent bien aux instructions ARM64 attendues.
3. **Exécution** : sur Raspberry Pi 4/5 ou émulateur QEMU-aarch64 sous Linux x86.
4. **Tests progressifs** : reproduire la suite de test existante (IO_TEST,
   FLOAT_TEST, ENUM_TEST) en commençant par les programmes les plus simples.

Le code TLALOC fonctionne par génération de macros, donc une fois `codi_arm.finc`
correct, **tous les programmes Ada déjà compilables sur x86-64 doivent compiler
sans modification**. Les bugs résiduels seront uniquement dans `codi_arm.finc`,
pas dans l'EXPANDER.


## 16. Points ouverts à trancher pendant l'implémentation

- **Optimisation des séquences load/op/store** : on peut parfois économiser un
  load en gardant la valeur en `x0` après une opération. La version x86 le
  faisait via `optim_RAX_ON_TOP`. On verra si on garde cette mécanique.
- **Choix du nop** : `nop` ARM64 est `0xD503201F` (4 octets). Pour les
  alignements, on peut soit padder avec des nops (4 octets), soit avec des
  `0x00` (qui sont des instructions invalides — acceptable dans des zones de
  données mais pas dans du code). Privilégier les nops dans les zones de code.
- **Format final du fichier** : conserver le style visuel et les commentaires
  ASCII-art du fichier x86-64 d'origine pour cohérence du dépôt.
- **Tests sur la plage de bl** : rester en `bl rel26` tant que les programmes
  TLALOC restent sous 128 Mo. Ajouter le fallback `blr x16` uniquement si un
  programme test le déclenche.


---

**Date de référence** : avril 2026 — à mettre à jour à chaque session de
travail sur le portage ARM64.
