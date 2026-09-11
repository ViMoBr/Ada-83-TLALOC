## 28-29 aout 2026 -- Cible riscv64 : codi_riscv64.finc mis au niveau (v2) et table EMITS riscv64 complete (sandbox, oracles qemu-riscv64)

(Addendum a coller a la suite de JOURNAL_SESSIONS.md.)

**Objectif.** Apres la fermeture de la boucle arm64 sur Orange Pi, completer TARGET_CODE
pour riscv64. Ordre retenu par le mainteneur : (1) mettre codi_riscv64.finc EXACTEMENT
au niveau de codi_x86_64.finc (reference) et codi_arm64.finc (premier derive stabilise) ;
(2) completer target_code-emits-riscv64_target.adb. Travail fait en sandbox, sans carte
RISC-V : capstone (desassemblage), binutils riscv64 (GNU as = second encodeur
independant) et qemu-riscv64 (execution en mode utilisateur) tiennent lieu d'oracles.

**Ecart releve (codi_riscv64 v1 vs reference).** Les 438 mots litteraux `dd` du v1 ont
d'abord ete confrontes un a un a l'assemblage GNU de leur commentaire : 0 faux (la
transcription initiale etait juste). L'ecart etait donc SEMANTIQUE, cinq points :
1. CALL/CALLI/RTD par `ra` (sd ra/jalr ra/ld ra, `ret`) : incompatible avec EXC_RAISE.
   Apres un deroulage, `ra` contient l'adresse de retour du DERNIER appel execute ; le
   RTD du frame porteur du handler retournait dans le CALL de son propre appele. arm64
   avait choisi la micro-pile explicite par sp precisement pour cela (x30 inutilise) ;
   riscv64 ne l'avait pas. -> C-R1 : adresse de retour materialisee par `auipc t0, 0 ;
   addi t0, t0, N`, rangee a [sp] (16 par appel), RTD = ld t0,0(sp) / addi sp,16 /
   jalr x0,0(t0). CALL 24 octets fixes, CALLI 28.
2. LCA/LSPA par QUAD_CONST (taille f(valeur)) sur des references AVANT : violation du
   contrat SIZE_OF = ENCODE, exactement le piege n 157 arm64. -> C-R2 : QUAD_ADDR =
   lui + addiw TOUJOURS deux instructions (image < 2 GiB, assert), plus asserts de plage
   sur BRA (+/-2 GiB) et RV_BRANCH (+/-4 KiB).
3. UNLINKR absent (lot 2 du chantier co-pile, n 165 fait x86 et arm64 le 28/08).
   -> C-R3 : mv s2, s3 avant ld s3, 0(s3) ; commentaire du contrat d'evasion sur UNLINK.
4. CVTIX/CVTXI sur produit 64 bits (mul/div) la ou x86 fait imul/idiv 128 bits et arm64
   smulh + SDIV128_64_POS : debordement silencieux pour I*DENOM >= 2**63. -> C-R4 :
   SDIV128_64_POS riscv (32 mots, miroir de l'arm64 : chemin rapide si le produit tient
   en 64 bits signes, sinon valeur absolue 128 bits avec emprunt par sltu, division
   restaurante 64 tours, restauration des signes) ; mulh + mul en tete de CVTIX/CVTXI.
5. Hygiene : `load bits qword` -> `load bits:qword` (syntaxe fasmg du codi arm64 valide) ;
   parametres textuels parentheses dans LVA/LIVA (piege n 156 : `LIVA , X__u+16`
   emettait X__u + (16 and 0xFFF) au lieu de (X__u+16) and 0xFFF).

**Verification, dans l'ordre.** (a) Oracle unitaire GNU as sur les 468 `dd` du v2 :
0 faux. (b) Emulateur Python des macros fasmg (fincemu.py : expansion, sous-macros,
if/else, local, repeat, substitution TEXTUELLE des parametres, quatre passes pour les
references avant) -- l'emulateur a du apprendre en route trois traits de fasmg :
substitution SIMULTANEE des parametres (pas sequentielle : `(ptr)+(disp)` avec un
argument nomme `disp`), `/` entier, concatenation `#`. (c) qemu-riscv64 sur des ELF
fabriques par l'emulateur : SDIV128_64_POS sur 1 233 couples (dividendes 128 bits
aleatoires et aux bornes, diviseurs > 0) contre Python, 0 ecart ; CVTIX/CVTXI sur 409
triplets contre le modele x86 (troncature vers zero, arrondi au demi loin de zero),
0 ecart ; temoin CALL -> CALL -> CALLI -> raise : EXC_RAISE restaure sp/s0/s2/s3,
dispatch dans le frame porteur, UNLINKR, RTD et retour normal a main ("EOK", sp revenu
a sa valeur initiale) ; 897 assertions semantiques sur les macros v1 inchangees
(ADD..MODI, decalages, UBFX/SBFX/BFI, comparaisons entieres et flottantes avec NaN,
CVTIF/CVTFI/CVTFIR, FEXP) et 19 sur LEXCMP (regle du prefixe, signe, tailles 1/2/4/8)
/ BLKMOV / BLKCMP / BLKAND / BLKNOT / boucle BT-BF : 0 ecart.
L'oracle d'execution a PAYE : ma premiere version de CALL comptait l'adresse de retour
une instruction trop tot (+20 au lieu de +24 ; +16 au lieu de +20 pour CALLI) -- "EE"
puis segfault. Une adresse de retour calculee de tete ne vaut rien sans execution.

**Table EMITS riscv64 (target_code-emits-riscv64_target.adb, 1 740 lignes).** Meme
methode que C4 arm64, generalisee a la table entiere en une livraison : les 74
sequences fixes sont transcrites PAR PROGRAMME (gen_ada.py : lecture du codi v2,
expansion, resolution des branchements B-type, desassemblage capstone pour les
commentaires ; SIZE_OF = 4 x nombre de mots) ; les macros parametrees sont ecrites a la
main sur le modele arm64 (QC_LEN/E_QUAD_CONST a trois etages, E_QUAD_ADDR, E_B,
E_LQ/E_SQ, E_LOAD/E_STORE [a0+disp] a UNE plage imm12 -- pas de scale ni d'imm9 sur
RISC-V --, E_ADD, LINK_LEN/E_LINK, RTD_LEN/E_RTD, EXC_MACH_LEN/E_EXC_MACH,
E_EXC_RAISE, LEXCMP a paire de charges variable et immediats IMM12(SIZC)). Ces
helpers ont ete compiles par gnat (-gnat83) dans un programme de test qui les
confronte a l'emulateur du codi : 2 116 vecteurs (valeurs aux bornes des trois etages
de QUAD_CONST, offsets des trois voies, niveaux, alloc, prm_size, ctx, ASM_SIZE du
prologue), 0 ecart et longueurs predites = longueurs emises. Sous-unite passee au
filet syntaxique gcc -c -gnats -gnat83, ASCII pur, sequences fixes verifiees
independantes de l'adresse. TRAITS definitifs : CALL_FRAME 16, PROLOGUE_SIZE 80
(20 mots), BRA_SIZE 8, MEMSZ 1 Gio.

**Livraisons (format ancre / supprimer / remplacer, ASCII, tabulations preservees).**
- LIVRAISON_CODI_RISCV64_v2.txt : 5 commits C-R1..C-R5, 15 modifications, oracles.
- LIVRAISON_TARGET_CODE_RISCV64.txt : C-T0 (TRAITS dans target_code-emits.adb) et C-T1
  (4 modifications sur le squelette de la sous-unite) ; le fichier resultant est joint
  a titre de controle -- l'application des 4 modifications le reproduit a l'octet.
- Outillage (riscv64_outillage.tar.gz) : fincemu.py, check_dd.py, gen_ada.py,
  helpers_ada.py, gen_tst.py, harness.py et les temoins t_*.py -- pour rejouer les
  oracles (apt install qemu-user binutils-riscv64-linux-gnu ; pip install capstone).

**Ce qui reste a faire, chez le mainteneur (l'ORACLE reste le cmp fasmg).**
1. Appliquer C-R1..C-R5 ; fasmg -v 2 sur ADA_COMP.fas + codi_riscv64 v2 (passes ~18,
   n 158) ; diff des desassemblages avant/apres limite a CALL/CALLI/RTD, LCA/LSPA,
   CVTIX/CVTXI, UNLINKR.
2. Appliquer C-T0/C-T1 ; temoins TC-RV04..09/16/21 (texte des TC_TEST x86, suffixe R)
   sous cmp fasmg puis qemu-riscv64 ; ADA_COMP.riscv64fas byte-identique ; qemu-riscv64
   ADA_COMP.riscv64exe recompile les sources -> diff_finc.sh contre T2 x86.
3. Le jour d'une VisionFive 2 : point fixe croise comme sur le Pi.
Reserves consignees : (a) e_flags ELF = 0 (pas de EF_RISCV_FLOAT_ABI_DOUBLE) -- le
chargeur Linux ne le verifie pas pour un executable statique ; (b) QUAD_ADDR suppose
l'image sous 2 GiB (assert), plus strict que les 4 GiB de l'arm64 -- si un jour ORG+ASM
depasse 0x7FFFF7FF, passer a auipc+addi PC-relatif (meme taille) ; (c) le ELF riscv
n'active pas les instructions compressees (mot de 4 octets partout, comme prevu).
