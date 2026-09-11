# NOTE — SUBSET FASMG DE LA CHAÎNE FINC (recensement v0)

Objet : recenser les caractéristiques de fasmg effectivement exploitées
par la chaîne TLALOC, pour délimiter ce qu'un ASSEMBLEUR NATIF LLIR
(Ada 83, auto-compilable) doit implanter afin de convertir les FINC en
binaire — ou en forme optimisable — sans fasmg. fasmg reste
l'implémentation de référence sur x86-64 (oracle différentiel).

Méthode : dépouillement de codi_x86_64.finc (2192 l., 160 macros),
codi_arm64.finc (2486 l., synchronisé), et des émissions PUT_LINE de
l'expander (les sept fichiers). État du dépôt : post point fixe du
bootstrap (12 août 2026).

Principe directeur : le langage à implanter n'est PAS fasmg — c'est le
LANGAGE FINC, dont le vocabulaire est CLOS (les macros LLIR + une
dizaine de directives). Les macros codi cessent d'être du texte
interprété : elles deviennent le CODE de l'assembleur natif (une
procédure Ada par macro). fasmg n'est requis que pour ce que les FINC
lui demandent réellement.


## 1. RECENSEMENT A — ce que les FINC contiennent (le langage d'entrée)

Constaté dans les émissions de l'expander et les têtes de .fas.

### 1.1 Lignes de macros LLIR
Une invocation par ligne : `MNEMO  arg, arg, ...`. Vocabulaire clos
(~120 macros publiques du codi ; les macros ancillaires PUSH_RAX,
FETCH_*, QUAD_CONST... ne sont JAMAIS écrites dans les FINC — usage
interne des macros entre elles).

Syntaxes d'arguments à supporter :
- entiers décimaux signés (`LI -5`, `LVa 1, -24`) ;
- littéraux flottants décimaux (`LIF 3.14`) — conversion IEEE 754
  double À LA CHARGE de l'assembleur (fasmg la faisait via `dq val`) ;
- ARGUMENTS VIDES avec virgules conservées : `LIa , , offset`,
  `Ld , FIELD` (valeurs par défaut lvl:-1, disp:0, ofs:0) ;
- noms symboliques simples et POINTÉS : `X_disp`, `_OBJ__type.FST_1`,
  `STANDARD.ce_raise_`, `PREFIX.sub.elab` ;
- expressions d'opérandes : `ptr+disp` (LCA), soustractions de labels ;
- paires `prefix, subname` pour CALL/LSPA (concaténation `#` interne :
  l'assembleur natif concatène simplement) ;
- chaînes quotées pour STR/db : `STR nom, 'octets'` (+ codes numériques
  mélangés : `db 'txt', 10`).

### 1.2 Directives structurelles émises telles quelles
| Construction | Émetteur | Rôle |
|---|---|---|
| `namespace N` / `end namespace` | tête .fas (STANDARD), macros PRO/STR/endPRO | portée hiérarchique |
| `include 'chemin'` | tête .fas, CODE_WITH_CONTEXT, fermeture transitive, corps de sous-prog. | inclusion textuelle |
| `if ~ definite SYM` / `if defined SYM` / `end if` | gardes de with (n° 97), assemblage lazy des corps | inclusion conditionnelle |
| `NAME = 'NAME'` | tête de FINC d'unité | définit le symbole de garde (valeur indifférente : `defined` doit devenir vrai) |
| `virtual at 0` / `virtual at 8` / `end virtual` | types_decls (records représentés, 1646/1798), structures (336/338) | zones de layout sans émission |
| `STATOFS nom, siz, algn` | types_decls (1686, 1751) | offsets de composants |
| `label:` | ret_lbl:, labels L\<n\> de NEW_LABEL, elab:/post: via macros | cibles de branchement |
| `display '...', 10` | traces d'inclusion | DIAGNOSTIC — reproduire ou ignorer (décision §5) |
| `hexa_show '...', $` | carto de débogage (garde DEBUG) | idem |
| `;` commentaire, `; EXL Lnn` | partout | ignorer (EXL = crochet futur exceptions) |

Fins de ligne : LF seul (CR ignoré, FF saut de page — mêmes règles que
le frontend). Tabulations libres entre mnémonique et arguments.

### 1.3 Subset NÉGATIF (constaté absent des FINC — à NE PAS implanter)
- `struc` / `esc` / macros coupées : BEGIN_BLOC_DEF_OLD n'est PLUS
  émis (remplacé par BEGIN_BLOC_DEF sans struc ni postpone — son
  cartouche l'atteste : « Ni struc coupée, ni postpone, ni "!" ») ;
- définition de macros DANS les FINC : aucune ; `match`, `irp/irpv`,
  `iterate`, `calminstruction`, sections, formats objets, symboles
  interactifs : rien de tout cela ;
- `repeat` : interne aux align_* seulement ;
- arithmétique symbolique générale : seuls `+`, `-`, `*`, `/`, `mod`,
  comparaisons dans les `if` des macros — un évaluateur d'expressions
  entières 64 bits à 6 opérateurs suffit.


## 2. RECENSEMENT B — services fasmg exploités PAR les macros codi
(à internaliser dans l'assembleur ; disparaissent comme « langage »)

### 2.1 Namespaces hiérarchiques et résolution
Arbre de portées ouvert/fermé par `namespace`/`end namespace` (PRO en
ouvre un par sous-programme). Résolution d'un nom non pointé : portée
courante puis REMONTÉE DES PARENTS UNIQUEMENT — jamais les frères
(piège n° 105 : l'expander émet REGIONS_PATH précisément parce que la
remontée ne trouve pas un frère). Noms pointés : navigation absolue
depuis une racine trouvée par remontée. À REPRODUIRE À L'IDENTIQUE :
tout écart casserait des FINC valides sous fasmg.

### 2.2 Zones virtuelles de layout (PRMzone, VARzone, virtual at 0)
- `PRMS` ouvre PRMzone à 8 ; chaque `PRM name_ofs` pose name_ofs=$ et
  réserve un qword ; `endPRMS` calcule `prm_siz = $-8`.
- `ELB` ouvre VARzone à 8 ; `VAR name_disp, c, n` aligne (align_b/w/d/q
  selon c, align_q si taille littérale), pose name_disp, réserve ;
  `USEINFO` réserve le qword `__u` dans VARzone puis émet du code ;
  `endPRO` clôt : `loc_siz = $` (aligné q).
- `virtual at 0` + STATOFS : layout des records (align par composant,
  repli ancienne règle par taille si algn=0). MIROIR DE LAYOUT (piège
  n° 110) : l'assembleur natif devient la TROISIÈME implémentation de
  ce calcul — même helper conceptuel, mêmes règles, test-miroir
  obligatoire contre ALIGN_STATIC_BITS côté Ada et contre fasmg.

Point dur : `loc_siz` est RÉFÉRENCÉ par le LINK de ELB AVANT d'être
défini par endPRO ⇒ exigence de résolution avant (cf. §4, deux passes).

### 2.3 Différés et assemblage lazy
- `postpone` de STR et CST : les constantes sont rejetées en fin de
  module ⇒ l'assembleur natif accumule une LISTE DE CONSTANTES émise à
  la clôture (fin d'assemblage — noter : fasmg exécute les postpone en
  fin de SOURCE ENTIER ; vérifier sur T2 où les octets atterrissent,
  et reproduire cet emplacement pour l'oracle byte-diff).
- Lazy des sous-programmes : LSPA/CALL posent en différé
  `SYM_ = SYM.elab` si `~definite SYM_` ; les corps sont gardés par
  `if defined SYM_...`. Sémantique réelle : GRAPHE D'ATTEIGNABILITÉ —
  un corps n'est assemblé que si référencé. Dans l'assembleur natif :
  marquage des symboles requis (passe 1) puis évaluation des gardes
  `if defined` sur cette table. Le tree-shaking devient explicite au
  lieu d'émerger du multi-passes.

### 2.4 Références avant et évaluation
Labels avant définition (BRA post, branches avant), `loc_siz`,
`ASM_SIZE` (taille totale, consommée par l'en-tête ELF émis AVANT le
code), `str_bit_size` calculé après les octets mais consommé avant.
Évaluation d'expressions au moment de l'émission : `ptr+disp`,
`str_bit_size/8`, `8*(data_end-data)`, `lbl-$+4` (ARM). `err` (LEXCMP,
tailles non supportées) et `assert` (RTD, prm_size≥0) : messages
d'erreur à conserver comme refus bruyants.

### 2.5 Sélection d'encodage dépendante des valeurs (niveau 0)
x86 : disp==0 / disp8 / disp32 (FETCH/STORE/L*/S*), imm court/long.
ARM : immédiats 12 bits vs movz/movk, QUAD_CONST à chunks nuls élidés.
Ces choix restent DANS l'assembleur natif (seul étage connaissant la
cible). ATTENTION FORWARD : quand l'opérande est une ADRESSE non encore
connue (QUAD_CONST sur label avant), la taille de la séquence dépend de
la valeur ⇒ règle MONOTONE : forme MAXIMALE systématique pour toute
référence avant (4 movz/movk), optimisation réservée aux valeurs
connues en passe 1. C'est le prix de l'abandon du multi-passes à
convergence.

### 2.6 Multi-passes et optimisation push/pop — NON REPRIS
Le multi-passes fasmg (piège n° 106) n'existe que pour la convergence
des références avant et l'élision push/pop dépendante des adresses.
Doctrine assembleur natif : DEUX PASSES FIXES (1 : parse, portées,
layout, atteignabilité, adresses avec formes maximales pour les
forward ; 2 : émission). L'élision push/pop REMONTE au niveau FINC→FINC
(optimiseur, fenêtre de macros adjacentes) ou dans le sélecteur
d'encodage sur fenêtre locale SANS dépendance aux adresses. Aucune
oscillation possible par construction.

### 2.7 Amorçage et image binaire
En-tête ELF64 + Phdr unique PT_LOAD RWX, org 0x400000, entrée
0x400078, p_memsz = ASM_SIZE + réserve co-pile (16 Gio x86 / 1 Gio
ARM — budget co-pile, piège n° 109) ; prologue machine : mmap du tas
(64 Mio), pile montante calée 4 Mio sous SP, display 32 niveaux,
co-pile après le code. Tout ceci est du CODE de l'assembleur natif
(table par cible), plus du texte. EM_X86_64=62 / EM_AARCH64=183.


## 3. VOCABULAIRE LLIR À TABLE D'ENCODAGE (par cible)

Familles (noms = ceux du codi, sémantique inchangée) :
- pile : DUP, DROP, (OVER) ;
- charges : LI, LIF, LCA, LSPA, LVa, LIVa, L{b,w,d,q,a},
  UL{b,w,d}, LI{b,w,d,q,a}, ULI{b,w,d} ;
- rangements : S{b,w,d,q,a}, SI{b,w,d,q,a} ;
- arith./logique : ADD, SUB, MUL, DIV, REMI, MODI, SAR, ET, OU, OUX... ;
- flottant : FADD, FSUB, FMUL, FDIV, FNEG, FABS, FEXP, CVTIF, CVTFI,
  CVTFIR, CVTIX, CVTXI, FC{EQ,NE,GT,GE,LT,LE} ;
- comparaisons : C{EQ,NE,GT,GE,LT,LE} ;
- flot : BRA, BT, BF (rel32 systématique côté émission x86 — piège
  n° 82), CALL, CALLI, RTD ;
- frames : LINK, UNLINK, PRO, PRMS, PRM, endPRMS, ELB, endPRO ;
- données : STR, CST, BEGIN_BLOC_DEF, END_BLOC_DEF, USEINFO, STATOFS,
  VAR, CO_VAR, HEAP_ALLOC ;
- blocs : BLKMOV, BLKCMP, BLKAND, BLKOU, BLKOUX, BLKNOT, LEXCMP ;
- exceptions : EXC_MACH, EXC_RAISE ;
- syscalls : SYS_* (13 macros ; numéros et conventions par cible —
  openat/unlinkat côté ARM).

Couverture de validation : le point fixe exerce largement l'entier et
les composites ; flottant, CALENDAR, fichiers, exceptions exigent le
FILET COMPLET des témoins (état actuel sur Orange Pi : partiel —
enum_test, calendar, direct/sequential_io verts ; solde à rejouer).


## 4. ARCHITECTURE CIBLE DE L'ASSEMBLEUR NATIF (conséquences)

1. Écrit en Ada 83, compilé par TLALOC (dogfooding ; il rejoint les 63
   unités et le point fixe).
2. Deux passes fixes (§2.6) ; monotonie totale ; refus bruyants (R6).
3. Une table d'encodage par cible ; codi_arm64.finc EST la spec ARM
   (les `dd 0x...` commentés) ; codi_x86_64.finc la spec x86.
4. Entrée : le .fas de tête + includes (mêmes chemins que fasmg —
   la remarque « il faudra modifier le chemin » de expander.adb:589
   devient l'occasion de paramétrer LIB_PATH proprement).
5. Sortie : ELF monolithique whole-program, identique modèle fasmg.
   Pas de format objet, pas d'éditeur de liens.
6. La sortie « forme optimisable » (FINC→FINC, niveau 1) est un
   programme SÉPARÉ partageant le parseur et les tables — l'assembleur
   n'optimise pas au-delà du niveau 0.

## 5. ORACLES ET QUESTIONS OUVERTES

Oracles, dans l'ordre : (a) byte-diff du binaire natif contre fasmg,
sur x86 ET sur AArch64 (les binaires ARM de référence s'assemblent en
cross sur laptop) — sous réserve push/pop et emplacement des postpone
(§2.3) : au premier écart, comparer par sections avant de conclure ;
(b) filet des témoins auto-jugeants exécuté sur les deux cibles ;
(c) point fixe : T2 assemblé par l'assembleur natif recompile les 63
unités à l'identique.

Ouvert :
- Q1 : `display`/`hexa_show` — reproduire (trace utile) ou ignorer ?
  Proposition : reproduire, coût nul.
- Q2 : emplacement exact des constantes postpone (STR/CST) dans T2 —
  à relever AVANT d'écrire l'émetteur, pour viser byte-identique.
- Q3 : l'élision push/pop actuelle de fasmg — la débrayer côté codi
  pour la période de comparaison byte-diff, ou l'implanter à
  l'identique ? Proposition : débrayage temporaire (un commutateur),
  l'optimisation renaissant au niveau FINC→FINC.
- Q4 : nom de baptême de l'outil (il rejoindra l'INDEX du dépôt).
