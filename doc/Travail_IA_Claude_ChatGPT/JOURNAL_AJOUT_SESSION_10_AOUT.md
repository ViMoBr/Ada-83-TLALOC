# AJOUT JOURNAL — session 10 aout 2026 (segfault REQ_UTIL -> piege 144 -> point fixe _standrd.adb W)

Une seule modification, en fin de fichier (journal append-only).
Attention : la ligne A SUPPRIMER contient deux accents (corrigé, récursion)
a reproduire tels quels — elle est reprise INCHANGEE en tete du bloc de
remplacement.

--------------------------------------------------------------------------------
Modification 1.1 — fichier : JOURNAL_SESSIONS.md
--------------------------------------------------------------------------------

ANCRE (inchangee) :
```
Sondes @PD et @PN retirees. Suivant en file : segfault de _standrd.adb
(corps de la bibliotheque standard), meme protocole.
```

SUPPRIMER (la ligne qui suit, derniere du fichier) :
```
Incidemment : calendar.adb corrigé : conversions de type explicites dans les fonctions de comparaison (elle partaient en récursion infinie sans les conversions DURATION).
```

REMPLACER PAR :
```
Incidemment : calendar.adb corrigé : conversions de type explicites dans les fonctions de comparaison (elle partaient en récursion infinie sans les conversions DURATION).

## Session 10 aout 2026 -- segfault _standrd.adb (corps) : GFP au niveau
## GENERIC_BASE_LEVEL+1 dans les sous-programmes IMBRIQUES d'un corps
## generique (piege 144) ; POINT FIXE ATTEINT SUR _standrd.adb OPTION W

Symptome : T2 sur _standrd.adb option M, flot d'execution envoye dans la
pile (rip = rax = 0x7fffffc0f498, adresse de pile ; backtrace : deux
frames de REQUIRE_XXX au-dessus de N_REQUIRE_SCALAR_TYPE, crash au CALLI
du sous-programme formel IS_XXX).

Chaine causale (une seule famille, piege 144). REQUIRE_XXX est une
fonction recursive IMBRIQUEE (ELB 3) dans le corps generique
REQ_TYPE_XXX (ELB 2) de SEM_PHASE.REQ_UTIL. CODE_PROCEDURE_CALL
emettait les deux acces GFP -- propagation aux appels internes et CALLI
formel -- au niveau GENERIC_BASE_LEVEL+1 (= 2) avec le symbole GFP_ofs,
que fasmg resout au PRM du PRO COURANT (namespace) : offset 16, qui au
niveau 2 est... TYPESET_ofs. Le pseudo-GFP lu etait l'adresse d'un
typeset (pile) ; [pseudo-GFP - 24] via IS_XXX__call_ofs = qword de pile
quelconque ; CALLI dedans. Verrous numeriques du diagnostic : offset 16
= TYPESET aux deux etages ; rip = rax = adresse de pile ; ecart
rbp - rsp d'environ 72 Ko explique par la fuite d'un slot resultat par
appel formel sous recursion (symptome secondaire de l'ancienne
propagation inconditionnelle, disparu a la regeneration -- la garde
not IS_GENERIC_FORMAL_SUBPROGRAM de la source courante ne l'emet plus).

Correctif : deux sites de CODE_PROCEDURE_CALL (propagation + CALLI
formel) passes de GENERIC_BASE_LEVEL+1 a CUR_LEVEL. Justification
structurelle : chaque PRO d'un corps generique porte son propre
PRM GFP_ofs (CODE_PARAM_S) et le recoit par propagation a chaque appel
-- CUR_LEVEL est correct a tous les etages, et la sortie est octet a
octet inchangee a l'imbrication 1 (les deux niveaux coincident), ce que
le diff FINC de REQ_UTIL a confirme. Bug invisible jusqu'ici : premier
generique du corpus a fonction interne recursive appelant un formel.
Jumeaux non exerces consignes au piege 144 (~21 sites, recensement
grep GENERIC_BASE_LEVEL | grep GFP_ofs : LOAD_MEM, use__info des types
formels, litteraux et conversions fixed, STORE_OR_CALLI, MACHINE_CODE)
+ RESERVE bloc declare (frame propre sans PRM GFP : CUR_LEVEL y serait
faux aussi, il faudrait le niveau du PRO englobant).

Juge final : _standrd.adb passe COMPLETEMENT en option W dans T2, et
FINC(TLALOC(TLALOC)) IDENTIQUE A L'OCTET PRES a FINC(TLALOC(gnat)) --
2220 lignes, md5 identiques, CRLF pres, cmp muet. Premier CORPS au
point fixe (les specs l'etaient depuis le 9 aout). Oracle plus fort que
le temoin FINC du correctif : le REQ_UTIL corrige TOURNE dans T2
pendant cette compilation -- la resolution de surcharge par typesets
(REQUIRE_SCALAR/UNIVERSAL_TYPE, recursion comprise, CALLI formel de
bout en bout) produit les memes decisions que la reference gnat ; une
divergence silencieuse de filtrage se serait vue au diff.

Suivant en file : les packages predefinis, meme protocole en boucle --
essai de compilation T2, correction des segfaults s'il y en a,
comparaison des FINC T1/T2 (CRLF pres). Objectif de campagne :
recompiler avec T2 tout ce que T1 compile et obtenir les MEMES FINC.
```

--------------------------------------------------------------------------------
ORACLE
--------------------------------------------------------------------------------

Documentation seule. Verifications : la ligne « Incidemment » n'apparait
qu'une fois ; `grep -c "^## Session 10 aout 2026" JOURNAL_SESSIONS.md`
rend 1 ; le journal reste append-only (aucune entree anterieure touchee).
