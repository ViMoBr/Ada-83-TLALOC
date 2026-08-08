# LOT correctif — agrégat de tableau DE tableaux : composante non-agrégat en voie scalaire

## Chaîne causale close (pièces : AGGSTR_TEST.FINC, sondes @PD, dump)

`COLLECT_DIMENSIONS` APLATIT le tableau-de-tableaux en descendant dans le type
composant (`array (CLE) of STR3` → NB_DIMS = 2, COMP_TYPE = CHARACTER — le FINC
du témoin le montre : `_FST_2 = 1, _LST_2 = 3`, stride `_STR_1 = 3`). Le modèle
aplati d'EMIT_ONE_COMP ne sait alors traiter en profondeur intermédiaire que
des AGRÉGATS IMBRIQUÉS ; une composante NON-agrégat couvrant les dimensions
restantes — le littéral `"AND"`, parfaitement légal — tombe dans la voie
SCALAIRE : `LCA ANON_x.data_ptr` puis `SId …_PTR_1, 0` range les 4 octets bas
de l'@doublet du littéral, avec avance correcte de 3. D'où, dans le bootstrap :
BLTN_TEXT_ARRAY rempli de tranches de pointeurs (blocs STR consécutifs, pas de
40 octets — la descente de 0x28 des sondes), rognage `!` aveugle (L = 3),
symboles-poison dûment stockés et dédupliqués, deflist de `[P3,L30] "-"` vide,
HEAD. Les positions/strides étant justes, seul le CONTENU est faux — cohérent
avec l'échec des checks 2-10 du témoin, chemin scalaire de LECTURE compris
(il lit du poison bien rangé).

Le correctif est ADDITIF : une garde de profondeur dans EMIT_ONE_COMP. Si
`DEPTH < NB_DIMS` et la composante n'est pas un agrégat, copie en bloc :
longueur = `_STR_(DEPTH)` (taille du bloc des dimensions restantes, DÉJÀ posée
par COMPUTE_DYNAMIC_DIMS, garde « record symbolique » comprise via
`_STR_(NB_DIMS)`), source = @data par la règle unique n° 112
(CODE_COMPOSITE_DATA_ADDRESS — le littéral de chaîne est dans la liste). La
voie existante (profondeur terminale) est INCHANGÉE : tout FINC hors motif est
bit-identique par construction.

---

## COMMIT 1 — expander-expressions.adb (2 modifications, EMIT_ONE_COMP)

### Modification 1.1 — ouverture de la garde de profondeur

ANCRE (texte existant, inchangé, unique) :

```ada
      elsif  COMP.TY in CLASS_EXP  then
```

BLOC À SUPPRIMER (les trois lignes immédiatement sous l'ancre) :

```ada
        declare
	CT	: TREE	:= FULL_TYPE_VIEW( COMP_TYPE );
        begin
```

BLOC DE REMPLACEMENT :

```ada
        if  DEPTH < NB_DIMS  then
			--| AGGSTR_TEST (8/08, bootstrap _standrd / SHORT_INTEGER) :
			--| COLLECT_DIMENSIONS aplatit le tableau DE tableaux en
			--| descendant dans le type composant ; une composante
			--| NON-agregat couvrant les dimensions restantes (litteral de
			--| chaine "AND", objet, appel) tombait dans la voie SCALAIRE --
			--| SId rangeait l'@DOUBLET du litteral : BLTN_TEXT_ARRAY
			--| recevait des tranches de pointeurs (pas de 40 octets des
			--| blocs STR successifs), rognage '!' aveugle, symboles-poison
			--| dedupliques, deflist de "-" vide, HEAD leve.
			--| Copie en bloc : longueur = _STR_(DEPTH), taille du bloc des
			--| dimensions restantes deja posee par COMPUTE_DYNAMIC_DIMS
			--| (garde record symbolique comprise) ; source = @data par la
			--| regle unique n 112.
	PUT_LINE( tab & "La  " & LVL_STR & ", " & PTR_NAME( DEPTH ) );					-- destination
	PUT_LINE( tab & "Ld  " & LVL_STR & ", " & STR_NAME( DEPTH ) );					-- longueur : bloc des dims restantes
	CODE_COMPOSITE_DATA_ADDRESS( COMP );								-- @data source (regle n 112)
	PUT_LINE( tab & "BLKMOV" );
        else
        declare
	CT	: TREE	:= FULL_TYPE_VIEW( COMP_TYPE );
        begin
```

### Modification 1.2 — fermeture de la garde

ANCRE (texte existant, inchangé, unique) :

```ada
        TROU( "agregat tableau : composante non geree", COMP );
```

BLOC À SUPPRIMER (les quatre lignes immédiatement AU-DESSUS de l'ancre,
ligne vide comprise) :

```ada
	end if;
        end;

      else
```

BLOC DE REMPLACEMENT :

```ada
	end if;
        end;
        end if;

      else
```

### Oracles du commit 1 (dans l'ordre)

1. Reconstruire T1 (gnat). Recompiler `aggstr_test.adb` par T1, assembler,
   exécuter : `RESULTAT : 10 OK, 0 ECHECS` + `AGGSTR_TEST PASSE`. Lecture du
   FINC du témoin : pour chaque composante de TXT et POSTXT, la séquence
   devient `La  1, …_PTR_1` ; `Ld  1, …_STR_1` ; `LVA/LCA` du littéral ; `La` ;
   `BLKMOV` — plus aucun `SId` dans les blocs d'agrégat.
2. FINC des témoins existants (ENUM_TEST, REC_ARR_TEST, IO_TEST, FLOAT_TEST,
   DIRECT_IO_TEST, SECV1, TTAIL1, SUBLVL_TEST) régénérés : BIT-IDENTIQUES —
   la branche ajoutée ne s'ouvre qu'à profondeur intermédiaire sur composante
   non-agrégat, voie auparavant fausse. Tout octet de différence = collatéral.
3. Filet complet vert (mêmes témoins, exécution).
4. Chaîne complète régénérée : le diff des FINC du compilateur est confiné aux
   unités portant le motif (au moins `idl-sem_phase.FINC` — élaboration de
   BLTN_TEXT_ARRAY — vérifier au diff la liste exacte ; la citer au journal).
   Trace S de null_prog gnat/bootstrappé : toujours bit-exacte après
   normalisation CRLF.
5. Cible : reconstruire T2, `./A83.sh ./ ../_standrd.ads M`. Les sondes @PD
   encore en place doivent imprimer
   `@PD1 OP_UNARY_MINUS [-!!] L = 1 SYM = [DN_SYMBOL_REP<3.30]> "-"` (et
   consœurs), `@PD3 … DEFLIST TETE = [DN_BLTN_OPERATOR_ID…]` ; plus de HEAD à
   SHORT_INTEGER ; progression de WALK au-delà (INTEGER, LONG_INTEGER…).
   Familles suivantes possibles plus loin : hors périmètre du lot.

---

## COMMIT 2 — retrait des sondes @PD (APRÈS constat de l'oracle 5)

### Modification 2.1 — idl-sem_phase-fix_pre.adb, retrait @PD1

ANCRE (texte existant, inchangé, unique) :

```ada
			SM_OPERATOR	=> OP_CLASS'POS ( OP_NAME )
```

BLOC À SUPPRIMER (les onze lignes immédiatement sous l'ancre) :

```ada
			);
	     PUT( "@PD1 " );
	     PUT( OP_CLASS'IMAGE( OP_NAME ) );
	     PUT( " [" );
	     PUT( ITEM_NAME );
	     PUT( "] L =" );
	     PUT( INTEGER'IMAGE( ITEM_LENGTH ) );
	     PUT( " SYM = " );
	     PUT( NODE_REP( SYM ) );
	     PUT( " " );
	     PUT_LINE( PRINT_NAME( SYM ) );
```

BLOC DE REMPLACEMENT :

```ada
			);
```

### Modification 2.2 — idl-sem_phase-fix_pre.adb, retrait @PD3

ANCRE (texte existant, inchangé, unique) :

```ada
         ID_LIST := NEW_ID_LIST;
```

BLOC À SUPPRIMER (les quinze lignes immédiatement AU-DESSUS de l'ancre — le
bloc declare @PD3 inséré au diagnostic) :

```ada
         declare
	    MOINS	: TREE	:= FIND_SYM( """-""" );
         begin
	    PUT( "@PD3 " );
	    if MOINS = TREE_VOID then
	       PUT_LINE( "SYMBOLE MOINS ABSENT DE LA TABLE" );
	    elsif IS_EMPTY( LIST( MOINS ) ) then
	       PUT( NODE_REP( MOINS ) );
	       PUT_LINE( " DEFLIST VIDE" );
	    else
	       PUT( NODE_REP( MOINS ) );
	       PUT( " DEFLIST TETE = " );
	       PUT_LINE( NODE_REP( HEAD( LIST( MOINS ) ) ) );
	    end if;
         end;
```

BLOC DE REMPLACEMENT : (néant — suppression pure)

Oracle : `grep -rn "@PD" *.adb` vide ; recompilation de fix_pre ; le run M sur
`_standrd.ads` rejoue à l'identique SANS les lignes @PD.

---

## COMMIT 3 — documentation

### Modification 3.1 — PIEGES.md, ajout en fin de fichier

ANCRE : la dernière ligne du fichier (l'entrée n° 138 posée au lot subunits,
finissant par `(session 7 aout, lot subunits)`).

BLOC À SUPPRIMER : (néant — insertion sous l'ancre)

BLOC À INSÉRER :

```
139. **Agregat d'un tableau DE tableaux : COLLECT_DIMENSIONS aplatit en
    multi-dim, et une composante NON-agregat couvrant les dimensions
    restantes (litteral de chaine, objet, appel) tombait dans la voie
    scalaire d'EMIT_ONE_COMP** -- SId rangeait l'@doublet du litteral :
    contenu = tranches de pointeurs (pas constant entre elements = ecart
    des blocs STR), positions et strides JUSTES. Symptome bootstrap :
    BLTN_TEXT_ARRAY empoisonne, symboles d'operateurs doublons, deflist
    de "-" vide, HEAD leve au premier DN_FUNCTION_CALL (SHORT_INTEGER
    de _standrd). Garde de profondeur posee : DEPTH < NB_DIMS et
    non-agregat => copie en bloc, longueur _STR_(DEPTH), source regle
    n 112. Gardien : AGGSTR_TEST (checks 2-10). AUDIT RECOMMANDE :
    EMIT_ONE_COMPONENT (agregat RECORD) avec composante tableau-de-
    tableaux, et agregats MIXTES (K_A => "AND", K_B => ('O','R','!')) --
    le second membre passe par la voie agregat imbrique, non couvert
    par le temoin. (session 8 aout)
```

### Modification 3.2 — ORACLES_TESTS.md, nouvelle entrée témoin

ANCRE (titre de section existant) :

```
### Sondes @GT/@PC/@AP (hors filet, outil de diagnostic bootstrap)
```

BLOC À SUPPRIMER : (néant — insertion AVANT l'ancre)

BLOC À INSÉRER :

```
### AGGSTR_TEST (lot agregats tableau-de-tableaux, 8 aout 2026, 10 assertions)

Une unite : aggstr_test.adb. Couvre : agregat NOMME desordonne et agregat
POSITIONNEL d'un tableau constant indexe par enumere a composantes STRING(1..3)
rembourrees '!', dans un package spec au niveau 1 (motif PRENAME/
BLTN_TEXT_ARRAY) -- init d'objet depuis element indexe, double indexation
caractere, egalite composite, affectation vers STRING_3, boucle de rognage.
Attendu : « RESULTAT : 10 OK, 0 ECHECS / AGGSTR_TEST PASSE ». Historique :
rouge 9/10 avant correctif (seul ITEM'LENGTH passait -- positions justes,
contenu pointeurs). Gardien du piege n 139 ; a repasser apres toute retouche
de CODE_ARRAY_AGGREGATE, COLLECT_DIMENSIONS, EMIT_ONE_COMP ou de la regle
n 112 (CODE_COMPOSITE_DATA_ADDRESS).

```

Ordre du lot : commit 1 (oracles 1-5) → commit 2 (retrait sondes) → commit 3.
