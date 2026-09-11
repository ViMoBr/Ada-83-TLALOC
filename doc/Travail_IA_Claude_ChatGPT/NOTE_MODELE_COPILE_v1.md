# NOTE DE MODELE D'EXECUTION -- RECUPERATION DE LA CO-PILE, v1 (lot 1 : x86_64 / expander)

**28 aout 2026, redigee AVANT tout code** (discipline de pilier). Chantier ouvert par les
pieges n 109 / 147 / 163. Perimetre arbitre en seance : liberation au niveau FRAME
seulement ; mnemonique UNLINK inchange, variante UNLINKR ajoutee. Cibles arm64 et
target_code : lot 2, apres validation de la reference x86_64 sous fasmg.

---

## 1. Ce qui tourne aujourd'hui (descriptif, lu dans codi_x86_64.finc)

Registres : R14 = sommet de co-pile (lieu d'allocation), R13 = base du frame de
co-pile courant (chaine de cellules).

```
LINK  lvl, alloc :  ... ; mov [r14], r13 ; mov r13, r14 ; lea r14, [r14+8]
                    -> une CELLULE de 8 octets par frame, qui contient le r13 anterieur
CO_VAR           :  empile r14 ; r14 += taille arrondie au qword (bump)
UNLINK lvl       :  FP_IN_RBP lvl ; POP_RAX ; RAX_IN_FP lvl ; mov r13, [r13]
                    -> r14 N'EST PAS REDESCENDU ("A FAIRE" du codi)
EXC_RAISE        :  r13, r14 := photo prise a begin: du frame porteur (EXC_MACH)
```

Consequence : allocateur a bosse par processus. 8 octets par appel + tous les CO_VAR
(concatenations, IMAGE, agregats dynamiques, tranches, lieux-resultat de tableaux
contraints, objets de bloc) ne sont rendus que par un deroulage d'exception.
Mesure (n 163) : ADA_COMP assemble par target_code = 3,39 Go RSS dont ~2,95 Go de
co-pile.

## 2. Le contrat d'evasion (pourquoi R1 a ete revoquee)

CODE_RETURN, branche `DN_ARRAY or DN_CONSTRAINED_ARRAY or DN_STRING_LITERAL`
(expander-instructions) : ecrit dans le slot de l'appelant `data_ptr_src` (copie du
POINTEUR) et BLKMOV 16 octets d'info. Les DONNEES restent dans la region de co-pile
du frame appele. Un `mov r14, r13` inconditionnel a l'UNLINK expose ces donnees au
prochain LINK/CO_VAR (constate : noms manges dans _standrd, PROGRAM_ERROR).

NB : la branche s'applique aussi aux resultats DN_CONSTRAINED_ARRAY (le CO_VAR alloue
par PREPARE_FUNCTION_RESULT_PLACE chez l'appelant est en fait laisse mort : le
data_ptr recopie est celui de l'appele). Les resultats RECORD sont, eux, BLKMOV dans
le `__dat` de l'appelant ; les scalaires/access vont dans la cellule result__ofs.

## 3. La regle (prescriptif)

Deux mnemoniques d'epilogue :

```
UNLINK  lvl  : inchange (garde la co-pile)          -- 4D 8B 6D 00           mov r13,[r13]
UNLINKR lvl  : UNLINK + r14 := r13 AVANT r13 := [r13] -- 4D 89 EE ; 4D 8B 6D 00
```

UNLINKR ramene r14 exactement a la valeur qu'il avait AVANT le LINK de ce frame (la
cellule elle-meme est rendue). Choix fait par l'EXPANDER, jamais par le codi :

| Site d'emission                                   | Mnemonique | Motif |
|---------------------------------------------------|------------|-------|
| ret_lbl d'un corps (CODE_SUBPROGRAM_BODY)         | EXIT_UNLINK_MNEMONIC( header ) | voir ci-dessous |
| wrapper d'instanciation (CODE_SUBPROG_ENTRY_DECL) | idem       | meme protocole de slot |
| fin normale d'un bloc declare (CODE_BLOCK)        | UNLINKR    | rien n'evade d'un bloc a sa fin normale |
| exit / goto a travers des blocs (CODE_EXIT, CODE_GOTO, CODE_LABELED) | UNLINKR | idem, la condition d'exit est scalaire et deja consommee |
| blocs traverses par un return (CODE_RETURN)       | UNLINK (inchange) | la valeur rendue peut vivre dans la region du bloc (`declare T : STRING ... begin return T & T; end`) ; l'epilogue du frame tranche ensuite |

EXIT_UNLINK_MNEMONIC (nouvelle fonction UTILS) :

- procedure -> UNLINKR ;
- fonction dont la vue complete du type de resultat est CLASS_SCALAR, DN_ACCESS,
  DN_RECORD ou DN_CONSTRAINED_RECORD -> UNLINKR (le resultat est COPIE chez
  l'appelant avant l'epilogue) ;
- tout le reste -> UNLINK : DN_ARRAY, DN_CONSTRAINED_ARRAY (contrat d'evasion), et par
  prudence toute sorte non prouvee (type formel generique dans un corps partage, vue
  privee non percee). Le comportement historique est toujours le repli sur.

## 4. Audit des dangers (ce qui a ete verifie dans l'expander avant d'ecrire la regle)

1. Allocateurs `new` : HEAP_ALLOC (r12), jamais CO_VAR -> hors sujet.
2. Tous les sites CO_VAR (declarations : 4 ; expressions : lieux-resultat contraints,
   agregats temporaires, concatenation, operateurs composites, tranches) allouent
   dans le frame COURANT ; aucun objet d'un frame n'est reference apres la fin de
   ce frame sauf par le contrat d'evasion (section 2).
3. Parametres out / in out composites : l'adresse est celle de l'ACTUEL (doublet de
   l'appelant, WRAP_COMPOSITE_ACTUAL_DOUBLET / SELARG dans la VARzone) ; les
   affectations dans l'appele BLKMOV dans les data de l'actuel, jamais de
   re-pointage du _disp de l'actuel. Sur.
4. Evade puis appel interpose : F (garde) rend R a l'adresse A ; tout frame P entre
   ensuite avec sa cellule LINK a une adresse > A ; UNLINKR de P ramene r14 a cette
   cellule, jamais sous A. R survit. C'est le cas _standrd de STRRET_TEST et le
   nouveau check 3 de COPILE_REL_TEST.
5. Elaboration `X : STRING := F(1)` ALIASE les data de F (DUP / LA / SA _disp) :
   X et les data de F vivent dans la region du meme frame appelant -> liberes ensemble.
6. Exceptions : la photo EXC_MACH (r13, r14 a begin:, post-elaboration) reste
   coherente : apres un handler, ret_lbl UNLINKR fait r14 := r13 = cellule du frame,
   restauree par EXC_RAISE. Les CO_VAR d'elaboration sont sous la photo, et sous la
   cellule ? NON : ils sont AU-DESSUS de la cellule et sous la photo -> rendus par
   UNLINKR a la sortie du frame, comme il se doit.
7. Recursion de fonctions a resultat tableau (IMAGE, RESOLVE...) : inchangee,
   bornee par le premier frame "relache" au-dessus.
8. Packages : pas de frame propre (pas d'ELB) ; leurs objets vivent dans le frame
   englobant (niveau 0 : jamais rendus, comme aujourd'hui).
9. Instances generiques : le wrapper relaie le slot (DN_ARRAY) ou copie le scalaire ;
   meme regle que les corps. UNCHECKED_CONVERSION vers composite : BLKMOV dans le
   data_ptr du slot recu ; record -> UNLINKR (slot = __dat appelant), tableau ->
   UNLINK par la regle (conservateur).

## 5. Ce que le lot 1 NE fait PAS (dette consignee, mesurer avant d'y aller)

- Les temporaires d'une BOUCLE dans un MEME frame (une passe de target_code qui fait
  `S := IMAGE(N) & ...` un million de fois) ne sont rendus qu'a la sortie du frame.
  Remede suivant si la mesure l'exige : (a) marque/relache au niveau instruction
  (COMARK/COREL par la pile de travail, style pile secondaire GNAT), ou (b) RETOUR
  GLISSANT : CODE_RETURN tableau recopie les data a r13+8 (BLKMOV vers le bas,
  sans recouvrement car dst < src) et pose r14 = r13+8+len -- alors TOUS les
  UNLINK deviennent UNLINKR. (b) supprime la notion de frame "garde" mais touche
  CODE_RETURN et le doublet info ; a etudier a froid avec le meme gardien STRRET_TEST.
- TAILLE_COPILE (16 Go x86, 1 Go arm) inchangee dans ce lot.

## 6. Oracles du lot 1 (ordre impose)

1. Commit C1 (codi seul) : re-assembler sous fasmg un .fas de reference -> binaire
   BYTE-IDENTIQUE (macro UNLINKR definie, pas encore emise).
2. Commit C2 (expander) : recompiler T1 ; STRRET_TEST PASSE (7/7) AVANT tout build
   de T2 (ordre des oracles, n 147) ; COPILE_TEST PASSE ; COPILE_REL_TEST (nouveau)
   PASSE ; exc_test0/1/1U, array_test1/2/3, record_test1/2, slagg, indarg, opdef,
   series ACVC : verts.
3. Diff FINC du corpus (diff_finc.sh) : les SEULES lignes qui changent sont des
   `UNLINK` devenus `UNLINKR` (verifier par `sed s/UNLINKR/UNLINK/` puis cmp).
4. Auto-compilation : ADA_COMP (T2) fonctionnel, point fixe T2 = T3 sur les FINC.
5. Mesure : `/usr/bin/time -v` sur ADA_COMP assemblant ADA_COMP -> RSS attendu de
   l'ordre de 450 Mo (contre 3,4 Go).
6. Lot 2 seulement ensuite : entree EMITS UNLINKR dans target_code (x86_64 puis
   arm64 : `x27 := x26 ; x26 := [x26]`), macro UNLINKR de codi_arm64.finc, cmp fasmg
   sur les deux cibles. Tant que target_code ignore UNLINKR, les FINC de C2 ne
   s'assemblent QUE sous fasmg.

---

## 7. RESULTATS DU LOT 1 (28 aout 2026, x86_64) -- CLOS

- Commit C1 (macro UNLINKR) puis C2 (expander, 10 modifications) appliques par le
  mainteneur ; entree EMITS UNLINKR ajoutee a target_code (x86_64) dans la foulee.
- COPILE_REL_TEST : 8 OK, 0 ECHECS, sous fasmg ET sous target_code (.x86exe).
- STRRET_TEST : 7 OK, 0 ECHECS (contrat d'evasion intact). Filet complet vert.
- Mesure : `/usr/bin/time -v ./TARGET_CODE` assemblant ADA_COMP (766 461 elements,
  200 542 symboles, 10 310 112 octets emis) : RSS max = 468 480 Ko, contre
  3 390 000 Ko avant le lot -- division par 7,2, prediction du n 163 (~450 Mo)
  tenue. 116 873 fautes de page mineures, 48 s ecoulees (User 26,75 s).
- Le residu (~470 Mo) contient les tables CARTO touchees (texte 14 Mo, pool 2,6 Mo,
  octets 10,3 Mo, elements/symboles) et ce que le lot 1 ne rend pas (temporaires
  de boucle dans un meme frame, frames gardes). Si une mesure future exige mieux :
  lire r14 en fin de run pour separer les deux parts avant de choisir entre
  marque/relache par instruction et retour glissant (par. 5).

## 8. Suite (lot 2)

- codi_arm64.finc : macro UNLINKR homologue (UNLINK + `x27 := x26` avant
  `x26 := [x26]`) ; table EMITS arm64 de target_code : une entree ; oracle cmp fasmg
  sur les memes FINC ; puis TARGET_CODE.arm64exe sur le Pi SANS swapfile ni
  overcommit (l'arene de 1 Gio doit suffire desormais).
- riscv64 debloque : une seule table EMITS a ecrire, sans bequille memoire.
