# CORRECTIF — segfault T2 sur _standrd.adb (option M) : GFP lu au mauvais niveau dans les sous-programmes imbriques d'un corps generique

Cause : dans REQUIRE_XXX_L18 (imbrique niveau 3 dans le corps generique
REQ_TYPE_XXX_L17), CODE_PROCEDURE_CALL emet `La 2, -GFP_ofs` — niveau
GENERIC_BASE_LEVEL+1 avec l'offset LOCAL (GFP_ofs=16 du PRO courant, resolu
par le namespace fasmg). Au niveau 2, l'offset 16 est TYPESET_ofs : le GFP
lu est l'adresse d'un typeset (pile) ; [GFP-24] = qword de pile quelconque ;
CALLI dans la pile. Le niveau correct est CUR_LEVEL (chaque PRO d'un corps
generique porte son PRM GFP_ofs, propage a chaque appel). Sortie inchangee
octet a octet a l'imbrication 1 (CUR_LEVEL = GENERIC_BASE_LEVEL+1).

Application : chaque modification = ANCRE (texte existant unique, inchange,
sert uniquement a localiser) + bloc A SUPPRIMER + bloc DE REMPLACEMENT.
Indentation d'origine preservee (espaces ; aucune tabulation dans les
lignes touchees des .adb ; 4 espaces de tete dans PIEGES.md).


================================================================================
COMMIT 1 — expander : GFP a CUR_LEVEL dans CODE_PROCEDURE_CALL
================================================================================

--------------------------------------------------------------------------------
Modification 1.1 — fichier : expander-instructions.adb
Propagation du GFP aux appels internes au generique (site exerce par
l'appel recursif NEW_TAIL := REQUIRE_XXX (SET_TAIL)).
--------------------------------------------------------------------------------

ANCRE (inchangee) :
```
    if  IS_IN_CURRENT_GENERIC( PROC_ID )  and then  not EXPRESSIONS.IS_GENERIC_FORMAL_SUBPROGRAM( PROC_ID )
    then
```

SUPPRIMER (la ligne qui suit immediatement l'ancre) :
```
      PUT( tab & "La " & INTEGER'IMAGE( CODI.GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
```

REMPLACER PAR :
```
      PUT( tab & "La " & INTEGER'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & "-GFP_ofs" );
```

--------------------------------------------------------------------------------
Modification 1.2 — fichier : expander-instructions.adb
Appel indirect d'un sous-programme FORMEL (site exerce par
IS_XXX (GET_TYPE (SET_HEAD)) : c'est le CALLI qui part dans la pile).
--------------------------------------------------------------------------------

ANCRE (inchangee) :
```
    if  EXPRESSIONS.IS_GENERIC_FORMAL_SUBPROGRAM( PROC_ID )  then
```

SUPPRIMER (la ligne qui suit immediatement l'ancre) :
```
      PUT_LINE( tab & "La " & IMAGE( CODI.GENERIC_BASE_LEVEL + 1 ) & "," & tab & "-GFP_ofs" );
```

REMPLACER PAR :
```
      PUT_LINE( tab & "La " & IMAGE( CODI.CUR_LEVEL ) & "," & tab & "-GFP_ofs" );
```

--------------------------------------------------------------------------------
ORACLE DU COMMIT 1
--------------------------------------------------------------------------------

1. Reconstruire l'expander (T1) ; regenerer les FINC de SEM_PHASE
   (idl-sem_phase-req_util.adb -> REQ_UTIL.FINC).

2. Temoin FINC (diff avant/apres) :
   - dans les PRO REQUIRE_XXX_L2 et REQUIRE_XXX_L18 (ELB 3), tout acces
     `-GFP_ofs` passe au niveau 3 (`La  3,` propagation recursive ;
     `La 3,` devant `La , -IS_XXX__call_ofs` + CALLI) ;
   - dans les corps REQ_DEF_XXX_L1 / REQ_TYPE_XXX_L17 (ELB 2, imbrication
     1), sortie octet a octet identique (CUR_LEVEL = GENERIC_BASE_LEVEL+1) ;
   - gardien mecanique : entre `PRO REQUIRE_XXX_` et son `endPRO`, plus
     aucune occurrence de `2,<TAB>-GFP_ofs`.

3. Reassembler T2 ; `./T2 ./ ../_standrd.adb M` termine sans segfault
   (premiere traversee reelle des filtres REQUIRE_SCALAR_TYPE /
   REQUIRE_UNIVERSAL_TYPE avec typeset non vide — EVAL_RANGE /
   EVAL_DISCRETE_RANGE de la backtrace).

4. Filet standard inchange attendu (ENUM_TEST / FLOAT_TEST / IO_TEST :
   leurs generiques n'ont pas de sous-programme imbrique dans le corps
   partage — FINC identiques, verdicts PASSE).


================================================================================
COMMIT 2 — PIEGES.md : consigner la famille et ses jumeaux non exerces
================================================================================

--------------------------------------------------------------------------------
Modification 2.1 — fichier : PIEGES.md
Insertion du piege n 144 en fin de fichier.
--------------------------------------------------------------------------------

ANCRE (inchangee) :
```
    RECSTR2_TEST restent au filet (squelette et chair de PRINT_NUM).
```

SUPPRIMER (la ligne qui suit immediatement l'ancre — derniere du fichier) :
```
    (session 9 aout)
```

REMPLACER PAR :
```
    (session 9 aout)

144. **GFP lu au niveau GENERIC_BASE_LEVEL+1 avec l'offset LOCAL : faux
    des qu'un sous-programme est IMBRIQUE dans le corps generique.**
    Chaque PRO d'un corps generique porte son propre PRM GFP_ofs
    (CODE_PARAM_S) et le symbole GFP_ofs se resout au PRM du PRO
    COURANT (namespace fasmg) : le niveau doit etre CUR_LEVEL, jamais
    GENERIC_BASE_LEVEL+1 (egaux seulement a l'imbrication 1, d'ou la
    survie du bug jusqu'au premier generique a fonction interne
    recursive). Melange niveau externe / offset interne = lecture d'un
    AUTRE PRM du frame englobant (REQ_UTIL : TYPESET, une adresse de
    pile) ; [pseudo-GFP - 24] via IS_XXX__call_ofs -> CALLI dans la
    pile (T2 sur _standrd.adb, REQUIRE_XXX recursif). Corrige aux deux
    sites exerces (CODE_PROCEDURE_CALL : propagation + CALLI formel).
    JUMEAUX NON EXERCES consignes, meme famille, recensement mecanique :
    grep -n "GENERIC_BASE_LEVEL" expander*.adb | grep "GFP_ofs"
    (~21 sites : LOAD_MEM et CODE_USED_OBJECT_ID pour les objets
    formels, use__info des types formels — 'SIZE 'SMALL 'WIDTH
    FIRST/LAST, conversions et litteraux fixed —, init de locale de
    type formel, STORE_OR_CALLI, MACHINE_CODE) — tous faux au meme
    titre si l'acces part d'un sous-programme imbrique dans le corps
    partage. RESERVE : depuis un bloc declare d'un corps generique,
    CUR_LEVEL est le niveau du BLOC (frame propre SANS PRM GFP) — il
    faudrait le niveau du PRO englobant ; non exerce, meme famille que
    le bug de niveau des thunks (journal A35801B). Gardien :
    T2 ./ _standrd.adb M + diff FINC de REQ_UTIL. (session 10 aout)
```

--------------------------------------------------------------------------------
ORACLE DU COMMIT 2
--------------------------------------------------------------------------------

Documentation seule, pas d'effet sur le code genere. Verification :
`grep -c "^144\." PIEGES.md` rend 1 ; le grep de recensement du piege
liste bien les jumeaux restants et ne liste PLUS les deux sites de
CODE_PROCEDURE_CALL.
