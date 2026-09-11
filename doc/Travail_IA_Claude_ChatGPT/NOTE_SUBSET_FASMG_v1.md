# NOTE — SUBSET FASMG DE LA CHAÎNE FINC (recensement v1)

v1 (17 août 2026) : intègre les arbitrages Q1–Q4, la troisième cible
RISC-V (codi_riscv64.finc, synchronisé, NON TESTÉ sur VisionFive 2),
le relevé empirique des postpone (DIS_BONJOUR), et la « forme
canonique d'adresse » qui garantit deux passes suffisantes.
Remplace la v0. L'outil recensé ici est baptisé TARGET_CODE.

Objet : délimiter ce que TARGET_CODE (Ada 83, auto-compilable) doit
implanter pour convertir les FINC en ELF exécutable — ou en forme
optimisable — sans fasmg. fasmg reste l'implémentation de référence
et l'oracle différentiel sur les trois cibles (x86 en natif ;
AArch64 et RISC-V par cross-assemblage sur laptop).

Méthode : dépouillement de codi_x86_64.finc (2192 l., 160 macros),
codi_arm64.finc (2486 l.), codi_riscv64.finc (2548 l., 165 macros),
et des émissions PUT_LINE des sept fichiers de l'expander.

Principe directeur : le langage à implanter n'est PAS fasmg — c'est
le LANGAGE FINC, à vocabulaire CLOS. Les macros codi cessent d'être
du texte interprété : elles deviennent le CODE de TARGET_CODE (une
procédure Ada par macro, une table d'encodage par cible).


## 1. RECENSEMENT A — ce que les FINC contiennent (langage d'entrée)

### 1.1 Lignes de macros LLIR
Une invocation par ligne : `MNEMO  arg, arg, ...`. ~120 macros
publiques (les ancillaires PUSH_RAX, FETCH_*, QUAD_CONST, RV_BRANCH…
ne sont JAMAIS écrites dans les FINC — usage interne).

Syntaxes d'arguments :
- entiers décimaux signés (`LI -5`, `LVa 1, -24`) ;
- littéraux flottants décimaux (`LIF 3.14`) — conversion IEEE 754
  double À LA CHARGE de TARGET_CODE ;
- ARGUMENTS VIDES à virgules conservées : `LIa , , ofs`, `Ld , FIELD`
  (défauts lvl:-1, disp:0, ofs:0) ;
- noms simples et POINTÉS : `X_disp`, `_OBJ__type.FST_1`,
  `STANDARD.ce_raise_`, `PREFIX.sub.elab` ;
- expressions d'opérandes : `ptr+disp` (LCA) ;
- paires `prefix, subname` (CALL/LSPA — concaténation simple) ;
- chaînes quotées pour STR/db, codes numériques mélangés
  (`db 'txt', 10`).

### 1.2 Directives structurelles émises telles quelles
| Construction | Émetteur | Rôle |
|---|---|---|
| `namespace N` / `end namespace` | tête .fas, PRO/STR/endPRO | portée hiérarchique |
| `include 'chemin'` | tête .fas, with, ferm. transitive, corps | inclusion |
| `if ~ definite S` / `if defined S` / `end if` | gardes n° 97, lazy | inclusion conditionnelle |
| `NAME = 'NAME'` | tête de FINC d'unité | symbole de garde (valeur indifférente) |
| `virtual at 0/8` / `end virtual` | types_decls 1646/1798, structures 336/338 | zones de layout |
| `STATOFS nom, siz, algn` | types_decls 1686, 1751 | offsets de composants |
| `label:` | ret_lbl:, L<n>, elab:/post: | cibles de branchement |
| `display '...', 10` / `hexa_show '...', $` | traces, carto | MAP — voir §5-Q1 |
| `;` commentaire, `; EXL Lnn` | partout | ignorer (EXL = crochet exceptions) |

Fins de ligne : LF seul (CR ignoré, FF saut de page). Tabulations
libres.

### 1.3 Subset NÉGATIF (constaté absent — à NE PAS implanter)
`struc`/`esc` (BEGIN_BLOC_DEF_OLD n'est plus émis) ; définition de
macros dans les FINC ; `match`, `irp`, `iterate`, `calminstruction`,
sections, formats objets ; `repeat` hors align_* ; arithmétique
au-delà de `+ - * / mod` et comparaisons de `if` — un évaluateur
entier 64 bits à six opérateurs suffit.


## 2. RECENSEMENT B — services fasmg internalisés dans TARGET_CODE

### 2.1 Namespaces hiérarchiques et résolution
Arbre de portées (`namespace`, un par sous-programme via PRO).
Résolution d'un nom non pointé : portée courante puis REMONTÉE DES
PARENTS UNIQUEMENT — jamais les frères (piège n° 105 ; d'où
REGIONS_PATH côté expander). Noms pointés : navigation absolue depuis
une racine trouvée par remontée. À reproduire À L'IDENTIQUE.

### 2.2 Zones virtuelles de layout (PRMzone, VARzone, virtual at 0)
- PRMS ouvre PRMzone à 8 ; PRM pose `name_ofs = $`, réserve un
  qword ; endPRMS : `prm_siz = $-8`.
- ELB ouvre VARzone à 8 ; VAR aligne (b/w/d/q selon le caractère,
  align_q si taille littérale), pose `name_disp`, réserve ; USEINFO
  réserve le `__u` ; endPRO clôt : `loc_siz = $` aligné q — RÉFÉRENCÉ
  par le LINK de ELB AVANT définition (⇒ passe 1, §4).
- virtual at 0 + STATOFS : layout des records (align par composant,
  repli ancienne règle par taille si algn=0). MIROIR DE LAYOUT (piège
  n° 110) : TARGET_CODE devient la TROISIÈME implémentation du calcul
  — test-miroir obligatoire contre ALIGN_STATIC_BITS et contre fasmg.

### 2.3 Différés (postpone) — sémantique RELEVÉE, pas supposée
Exécution en ordre LIFO : le premier postpone enregistré (ASM_SIZE,
tête de codi — « sera fait en toute fin car c'est le premier ») rejoue
en DERNIER ; le dernier enregistré rejoue en PREMIER. Relevé
empirique DIS_BONJOUR (hexdump T) : les constantes STR/CST sont
émises JUSTE APRÈS le code, dernier postpone en tête — descripteur
(data_ptr, info_ptr) puis info (SIZ=72, COMP=8, FST=1, LST=9) puis
les octets ' Bonjour ', padding d'alignement, constante suivante.
Règle TARGET_CODE : liste de différés émise après le code en ordre
inverse d'enregistrement ; ASM_SIZE calculé en tout dernier.

Lazy des sous-programmes : LSPA/CALL posent en différé
`SYM_ = SYM.elab` si `~definite` ; corps gardés par `if defined SYM_`.
Sémantique réelle : GRAPHE D'ATTEIGNABILITÉ. TARGET_CODE : marquage
des symboles requis en passe 1, gardes évaluées sur cette table.

### 2.4 Références avant, évaluation, refus
Labels avant définition (BRA post, branches avant), loc_siz, ASM_SIZE
(consommé par l'en-tête ELF émis avant le code), str_bit_size.
`err` (LEXCMP) et `assert` (RTD, FP_IN_RAX lvl≤31) : refus bruyants
à conserver tels quels (doctrine R6).

### 2.5 Sélection d'encodage et FORME CANONIQUE D'ADRESSE
Sélections par valeur : x86 disp0/disp8/disp32 ; ARM imm12 vs
movz/movk ; RISC-V imm12 vs lui/addi vs QUAD_CONST long (1 à 8
instructions). Deux catégories d'opérandes :
- OFFSETS DE FRAME (disp, ofs, prm_siz, loc_siz, STATOFS) : tous
  résolus par le layout en passe 1 ⇒ la sélection courte/longue en
  passe 2 opère sur valeurs connues. Aucun problème.
- ADRESSES DE CODE/DONNÉES (labels, .elab, ptr) : seules références
  avant restantes. Contrôle de flot : DÉJÀ à taille fixe sur les
  trois cibles (x86 : rel32 systématique — piège n° 82 ; RISC-V :
  AUIPC+JALR 8 octets, portée ±2 Gio, pour BRA/BT/BF/CALL ; ARM :
  B ±128 Mio / CBZ ±1 Mio à taille fixe). Reste QUAD_CONST sur
  symbole (LSPA, LCA, et l'adresse `retour` de CALL ARM —
  auto-référentielle : sa valeur dépend de la taille du QUAD_CONST
  qui la matérialise).
RÈGLE : toute constante de classe ADRESSE s'émet en FORME CANONIQUE
à taille fixe — ARM : movz+movk (2 instr) ; RISC-V : lui+addi
(2 instr) ; x86 : movabs (10 octets, déjà le cas). Valide tant que
les adresses tiennent en 32 bits positifs (org 0x400000 + ASM_SIZE ;
poser un assert). Cette forme COÏNCIDE avec le point de convergence
fasmg (les chunks hauts élidés sont nuls) ⇒ le byte-diff reste
atteignable ET l'auto-référence de CALL se résout en passe 1.

INVARIANT DE TAILLE DÉTERMINISTE : sous cette règle, la taille de
chaque invocation est calculable en passe 1 sans connaître les
adresses avant ⇒ passe 1 assigne TOUTES les adresses exactement,
passe 2 émet. DEUX PASSES FIXES suffisent par construction ; aucune
convergence, aucune oscillation possible. (L'élision push/pop a été
RETIRÉE des codi — il ne reste que des affectations inertes
`optim_RAX_ON_TOP = 0` dans codi_arm64 ; plus rien ne dépend des
adresses. Le retour d'optimisations de ce type appartient à
l'optimiseur FINC→FINC, jamais à TARGET_CODE.)

### 2.6 Amorçage et image binaire (par cible)
ELF64 + Phdr unique PT_LOAD RWX, org 0x400000, entrée 0x400078 ;
p_memsz = ASM_SIZE + réserve co-pile. e_machine : 62 (x86) /
183 (AArch64) / 243 (RISC-V). Prologue : mmap tas 64 Mio, pile
montante 4 Mio sous SP, display 32 niveaux, co-pile après le code.
OCTETS DE REMPLISSAGE des align_* — PERTINENT POUR LE BYTE-DIFF :
0x90 sur x86, 0x00 sur ARM et RISC-V.


## 3. VOCABULAIRE LLIR (tables d'encodage par cible)

Familles : pile (DUP, DROP, OVER) ; charges (LI, LIF, LCA, LSPA,
LVa, LIVa, L*/UL*/LI*/ULI*) ; rangements (S*, SI*) ; arith./logique
(ADD…SAR, ET, OU, OUX) ; CHAMPS DE BITS (UBFX, SBFX, BFI —
synchronisés sur les trois codi) ; flottant (F*, CVT*) ;
comparaisons (C*, FC*) ; flot (BRA, BT, BF, CALL, CALLI, RTD) ;
frames (LINK, UNLINK, PRO, PRMS, PRM, endPRMS, ELB, endPRO) ;
données (STR, CST, BEGIN/END_BLOC_DEF, USEINFO, STATOFS, VAR,
CO_VAR, HEAP_ALLOC) ; blocs (BLKMOV, BLKCMP, BLKAND/OU/OUX/NOT,
LEXCMP) ; exceptions (EXC_MACH, EXC_RAISE) ; SYS_* (13 —
open/unlink x86 contre openat/unlinkat ARM et RISC-V).

État de validation des cibles : x86 = référence (point fixe) ;
AArch64 = point fixe reproduit sur Orange Pi 3b + filet PARTIEL
(enum_test, calendar, direct/sequential_io verts ; solde — flottant,
exceptions, fichiers exhaustifs — à rejouer) ; RISC-V = synchronisé,
AUCUN test sur cible (VisionFive 2 en attente) — MÉFIANCE, ne pas
s'en servir comme référence de byte-diff avant son propre point fixe.


## 4. ARCHITECTURE DE TARGET_CODE (arbitré)

1. Procédure autonome au même titre que l'expander : entrée = nom du
   .fas initial + FINC corrects ; sortie = ELF ; tout s'enchaîne sans
   le frontend. Écrite en Ada 83, compilée par TLALOC (elle rejoint
   les unités du point fixe).
2. DEUX PASSES FIXES (invariant §2.5). Monotonie totale. Refus
   bruyants.
3. Une table d'encodage par cible ; les trois codi SONT les specs
   (les `db`/`dd` commentés). Sélection de cible par option.
4. Chemins d'include : mêmes règles que fasmg (l'occasion de
   paramétrer LIB_PATH proprement — expander.adb:589).
5. Sortie whole-program monolithique. Pas de format objet, pas
   d'éditeur de liens.
6. MAP : les `display`/`hexa_show` sont reproduits SOUS OPTION —
   pendant du flag GENERATE_BINARY_MAP de l'expander ; une future
   interface de commande « à la DCL » unifiera ces commutateurs.
7. L'optimiseur FINC→FINC (niveau 1) est un outil SÉPARÉ partageant
   parseur et tables ; TARGET_CODE n'optimise qu'au niveau 0
   (sélection d'encodage sur valeurs connues).


## 5. ORACLES

Dans l'ordre : (a) BYTE-DIFF du binaire TARGET_CODE contre fasmg —
x86 d'abord (référence absolue), puis AArch64 (binaires de référence
cross-assemblés sur laptop) ; RISC-V seulement après son propre
baptême fasmg sur VisionFive. Conditions réunies : élision retirée,
postpone relevé (§2.3), formes canoniques coïncidentes (§2.5),
padding recensé (§2.6). Au premier écart : comparer par sections
avant de conclure. (b) Filet des témoins auto-jugeants sur chaque
cible. (c) Point fixe : T2 assemblé par TARGET_CODE recompile les
63 unités à l'identique — TARGET_CODE entre alors sous l'oracle
suprême comme les autres.

Questions restantes :
- Q5 : ordre exact des postpone quand STR/CST et LSPA/CALL
  s'entremêlent (les différés lazy ne produisent pas d'octets, mais
  leur rang LIFO peut décaler les constantes) — un relevé hexdump sur
  une unité à sous-programmes suffira à trancher.
- Q6 : l'assert « adresses < 2^32 » de la forme canonique — plafond à
  documenter (p_memsz réserve 16 Gio au-dessus du code sur x86 : la
  co-pile peut dépasser 2^32, mais aucune CONSTANTE d'adresse
  assemblée ne pointe dedans — à vérifier une fois, EXC_MACH/EXC_RAISE
  compris).
