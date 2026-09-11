(Addendum a coller a la suite de PIEGES.md -- numeros 166 a 168, session riscv64 des 28-29 aout 2026.)

166. ** -- L'ADRESSE DE RETOUR D'UN CALL LLIR VIT SUR LA MICRO-PILE sp, JAMAIS
DANS UN REGISTRE DE LIEN : c'est le contrat d'EXC_RAISE, pas un detail de
cible. Le codi_riscv64 v1 faisait `sd ra,0(sp) / jalr ra / ld ra` cote appelant
et `ret` (jalr x0,0(ra)) cote RTD. Correct en flux normal, FAUX des le premier
deroulage : EXC_RAISE restaure sp/s0/s2/s3/display et saute au dispatch du frame
porteur du handler, mais `ra` contient l'adresse de retour du DERNIER appel
execute (celui de l'appele abandonne) -- le RTD du frame porteur "retourne" dans
le CALL de son propre appele (temoin : "EE" puis segfault). arm64 l'avait vu
(x30 inutilise, `adr x16, .+16 ; str x16,[sp]`) ; la regle n'etait pas ecrite
comme invariant de la LLIR. Forme riscv64 : `auipc t0,0 ; addi t0,t0,+24 ;
addi sp,sp,-16 ; sd t0,0(sp) ; BRA` (CALL, 24 octets fixes) et RTD = `ld t0,
0(sp) ; addi sp,sp,16 ; jalr x0,0(t0)`. Gardien : temoin CALL -> CALL -> CALLI
-> raise -> dispatch -> UNLINKR -> RTD -> retour normal a l'appelant d'origine
(sortie "EOK", sp revenu a sa valeur initiale), a jouer sur TOUTE nouvelle cible.

167. ** -- UNE ADRESSE DE RETOUR "auipc + N" NE SE COMPTE PAS DE TETE.
Deux fois dans la meme livraison, N a ete compte une instruction trop court
(+20 pour +24 dans CALL : le BRA vaut DEUX mots ; +16 pour +20 dans CALLI :
l'`addi sp` intercale). Les encodages etaient tous justes (GNU as les avait
confirmes) -- le defaut etait dans l'ARITHMETIQUE DE POSITION, invisible au
desassemblage ligne a ligne, visible seulement a l'execution. Regle : toute
sequence qui calcule une adresse dans son propre corps (auipc/adr + offset,
branchement interne, `lbl - $ + k`) passe par un oracle d'EXECUTION avant
livraison ; pour une cible sans carte, qemu-user + un ELF fabrique par
l'emulateur des macros (fincemu.py) suffit -- il a rendu son verdict en une
seconde. Corollaire de methode : l'oracle unitaire fasmg (n 153) prouve les
OCTETS, l'oracle d'execution prouve les ADRESSES ; il faut les deux.

168. ** -- METTRE UN CODI DERIVE "AU NIVEAU" DE LA REFERENCE = AUDIT
SEMANTIQUE MACRO PAR MACRO, PAS DIFF DES MNEMONIQUES. Le codi_riscv64 v1 avait
la meme LISTE de macros que x86 (a UNLINKR pres) et 438 encodages tous justes,
et pourtant quatre ecarts de SEMANTIQUE : (1) retour par registre de lien
(n 166) ; (2) LCA/LSPA par QUAD_CONST a taille f(valeur) sur des references
avant (n 88/157, contrat SIZE_OF = ENCODE) ; (3) CVTIX/CVTXI sur produit 64 bits
la ou la reference multiplie en 128 (imul/idiv, smulh+SDIV128_64_POS) --
debordement SILENCIEUX pour I*DENOM >= 2**63 ; (4) `load bits qword` (syntaxe
fasmg non validee) et parametres textuels nus dans LVA/LIVA (n 156). Grille
d'audit pour toute nouvelle cible, a derouler dans cet ordre : contrat des
retours et d'EXC_RAISE ; tailles fixes de tout ce qui materialise une adresse
(LCA, LSPA, CALL, CALLI, prologue) ; largeur des produits intermediaires
(CVTIX, CVTXI) ; mnemoniques ajoutes a la reference DEPUIS la copie (UNLINKR) ;
syntaxe fasmg des idiomes rares (load, virtual, postpone) ; parentheses des
parametres. Chaque point se juge par execution (n 167), pas par lecture.
