# LIVRAISON — COMMIT 2 : segfault 0xd5a790 (élaboration d'ADA_COMP)
# Suite du commit 1 (0x46ff17). S'applique APRÈS M1.

Protocole : une modification = une ancre (texte existant unique, inchangé)
+ bloc à supprimer + bloc de remplacement, tabulations préservées, blocs
au caractère près. Contre-épreuve faite par rejeu programmatique sur la
copie M1 : ancre unique, bloc contigu, remplacement propre.


## DIAGNOSTIC — un CINQUIÈME contournement du vieux contrat, raté par
## l'audit du commit 1

Le recensement du commit 1 énumérait les appelants de CODE_SLICE. C'était
la mauvaise clé de grep : le contournement manqué ne touche jamais
CODE_SLICE — il consomme la tranche VIA CODE_EXP puis dépile deux valeurs
en aval. Leçon de méthode (à verser au piège de session) : quand on change
le contrat d'un producteur, on grep le NŒUD (DN_SLICE) dans tout
l'expander, pas le nom de la procédure ; les rustines du vieux contrat
vivent chez les CONSOMMATEURS.

Le site : CODE_ARRAY_OPERAND (expander-expressions.adb, l. 3353-3397),
branche `E.TY = DN_SLICE`, dont le commentaire avoue le vieux contrat
(« CODE_EXP(slice) laisse : @data_slice, len_slice »). Elle est partagée
par TOUS les opérateurs composites : "=", "/=", comparaisons, logiques
(via SETUP_OPERAND, l. 3581), le stub bruyant (l. 3749) et le CONCAT "&"
(l. 4209/4230).

Chaîne du crash, lisible dans votre FINC :
1. `IDL.LIB_PATH(1..L) := IDL.PROJECT_PATH(1..L) & IDL.DEFAULT_LIB_PATH`
   — opérande gauche du "&" = tranche.
2. La branche appelle CODE_EXP( E ) ; depuis M1 celui-ci laisse UN
   @doublet (le namespace ANON_72_7 de votre FINC, terminé par
   `LVA 2, ANON_72_7_disp`).
3. La branche dépile ensuite DEUX valeurs :
   `Sa ..._slice_len` consomme l'@doublet (une ADRESSE prise pour une
   longueur), puis `Sa ..._slice_data` VOLE le mot suivant sous la pile
   d'évaluation.
4. Aval : _LST_1 := dword d'une adresse de pile, longueur géante,
   BLKMOV → SIGSEGV 0xd5a790 dans l'élaboration (zone POST_CHN /
   POSITION_SEPARATEUR de votre map), frame appelant 0xd5d929. Tout
   découle du Sa excédentaire.

Pourquoi la branche se RÉDUIT au lieu de s'adapter : tous les
consommateurs (SETUP_OPERAND et les deux extractions du concat) lisent le
doublet par l'idiome unique `DUP / La ,0 / La ,8` puis calculent
LEN = LST_1 − FST_1 + 1. Le doublet du mode source de CODE_SLICE porte
des bornes RÉELLES et un bloc info canonique 1-dim aux mêmes offsets que
_STRING : LST−FST+1 donne la même longueur que la normalisation 1..len
que fabriquait la branche. La normalisation était un échafaudage du vieux
contrat ; il tombe avec lui.


## AUDIT SYSTÉMATIQUE (grep DN_SLICE, tous fichiers expander) — clôture

Cassé par M1, corrigé ici :
- expressions 3353-3397, CODE_ARRAY_OPERAND branche DN_SLICE → M2.

Refus bruyants devenus SUR-CONSERVATEURS mais sûrs (le TROU/raise part
AVANT toute émission — dettes solderables, chacune avec son témoin,
doctrine n° 122, PAS dans ce commit) :
- expressions 1648 : CODE_COMPOSITE_DATA_ADDRESS, refus tranche ;
- expressions 3016 : CODE_ATTRIBUTE, préfixe indexé/tranche (D10) ;
- declarations 1887-1896 : actuel générique composite (contrat @doublet)
  — son commentaire cite le vieux contrat, à amender au solde.

Corrects et INTACTS (mode explicite, appel DIRECT de CODE_SLICE) :
- TRUE explicite (consommateurs légitimes de @data+LEN) : instructions
  2027 et 2141 (affectation source tranche), 2133 (destination tranche,
  défaut TRUE) ; expressions 1618 (+DROP, adresse d'objet) ;
- FALSE explicite (déjà au doublet) : instructions 967 (actual nu),
  1162 (return) ; declarations 1141 (init), 1515 (alias) ;
- expressions 1824 : PREFIX_NAME_STR, purement nominal, sans émission.

Après M2 il ne reste AUCUN consommateur du contrat @data+LEN via
CODE_EXP : la forme deux-valeurs n'existe plus que par appel direct
CODE_SLICE( TRUE ), là où un BLKMOV la consomme immédiatement.


====================================================================
## COMMIT 2 — CODE_ARRAY_OPERAND : la branche tranche suit la règle
====================================================================

--------------------------------------------------------------------
### M2 — expander-expressions.adb (CODE_ARRAY_OPERAND, ~l. 3353)
--------------------------------------------------------------------

ANCRE (unique dans le fichier, inchangée) :
```
	    elsif E.TY = DN_SLICE then
```

BLOC À SUPPRIMER (immédiatement sous l'ancre, 44 lignes) :
```
	    -- CODE_EXP(slice) laisse : @data_slice, len_slice.
	      PUT_LINE( "VAR" & tab & ANON & "_slice_data, q" );
	      PUT_LINE( "VAR" & tab & ANON & "_slice_len,  q" );

	      PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
	      PUT_LINE( "VAR" & tab & ANON & "__u,   q" );

	      PUT_LINE( "namespace " & ANON & "_info" );
	      PUT_LINE( "  VAR SIZ,      d" );
	      PUT_LINE( "  VAR _COMP_SIZ, d" );
	      PUT_LINE( "  VAR _FST_1,    d" );
	      PUT_LINE( "  VAR _LST_1,    d" );
	      PUT_LINE( "end namespace" );

	      CODE_EXP( E );

    -- Sauver len puis data.
	      PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "_slice_len" );
	      PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "_slice_data" );

    -- Construire le doublet temporaire.
	      PUT_LINE( tab & "La  " & LVL & ", " & ANON & "_slice_data" );
	      PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "_disp" );

	      PUT_LINE( tab & "LVA " & LVL & ", " & ANON & "_info.SIZ" );
	      PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "__u" );

    -- Info normalisÃ©e : bounds 1 .. len.
	      PUT_LINE( tab & "LI" & tab & "1" );
	      PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info._FST_1" );

	      PUT_LINE( tab & "La  " & LVL & ", " & ANON & "_slice_len" );
	      PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info._LST_1" );

	      PUT_LINE( tab & "LI" & tab & "8" );
	      PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info._COMP_SIZ" );

	      PUT_LINE( tab & "La  " & LVL & ", " & ANON & "_slice_len" );
	      PUT_LINE( tab & "LI" & tab & "8" );
	      PUT_LINE( tab & "MUL" );
	      PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info.SIZ" );

    -- RÃ©sultat attendu par la concat : @doublet.
	      PUT_LINE( tab & "LVA " & LVL & ", " & ANON & "_disp" );
```

BLOC DE REMPLACEMENT :
```
			--| Segfault 0xd5a790 (elaboration d'ADA_COMP, concat
			--| PROJECT_PATH(1..L) & DEFAULT_LIB_PATH, 03/08) : cette branche
			--| etait le CINQUIEME contournement du defaut de CODE_NAME_EXP --
			--| elle depilait DEUX valeurs (@data, LEN) apres CODE_EXP.  Depuis
			--| le correctif 0x46ff17 (regle n 112 : CODE_EXP est un producteur
			--| de VALEUR, tranche = @doublet en mode source), CODE_EXP laisse
			--| UN @doublet a bornes REELLES et info canonique 1-dim : les
			--| consommateurs (SETUP_OPERAND, concat) n'utilisent les bornes que
			--| par LST-FST+1 -- la normalisation 1..len etait superflue.  Le
			--| double Sa volait un mot sous la pile ; la branche se reduit au
			--| producteur de la regle, comme la branche generale.
	      CODE_EXP( E );							-- @doublet (mode source, bornes reelles)
```

--------------------------------------------------------------------
### M3a — slconv1.adb : déclaration du réceptacle S7
--------------------------------------------------------------------

ANCRE :
```
  R	: CHN4;
```

BLOC À SUPPRIMER (ligne vide + begin) :
```

begin
```

BLOC DE REMPLACEMENT :
```
  R5	: STRING( 1..5 );

begin
```

--------------------------------------------------------------------
### M3b — slconv1.adb : assertions S4-S7 (opérateurs composites)
--------------------------------------------------------------------

ANCRE :
```
  CHECK( "S3 UC en operande d'egalite", TO_CHN4( MID4( BIG( 1..4 ) ) ) = "ABCD" );
```

BLOC À SUPPRIMER (ligne vide + première ligne du RESULTAT) :
```

  PUT_LINE( "RESULTAT :" & NATURAL'IMAGE( OK_COUNT ) & " OK,"
```

BLOC DE REMPLACEMENT :
```

  CHECK( "S4 egalite tranche = litteral", BIG( 5..8 ) = "EFGH" );

  CHECK( "S5 concat tranche & litteral", BIG( 1..3 ) & "XY" = "ABCXY" );

  CHECK( "S6 concat deux tranches", BIG( 1..2 ) & BIG( 11..12 ) = "ABKL" );

  R5( 1..5 ) := BIG( 1..3 ) & "XY";				-- motif exact du crash : tranche := tranche & chaine (LIB_PATH)
  CHECK( "S7 tranche := tranche & litteral", R5 = "ABCXY" );

  PUT_LINE( "RESULTAT :" & NATURAL'IMAGE( OK_COUNT ) & " OK,"
```

--------------------------------------------------------------------
### ORACLES DU COMMIT 2
--------------------------------------------------------------------

1. **Filet syntaxique** : `gnat -gnats -gnat83` sur
   expander-expressions.adb (M1+M2) et slconv1.adb — zéro erreur.

2. **Oracle témoin** : SLCONV1, désormais 7 assertions — la ligne
   « SLCONV1 PASSE ». S5-S7 reproduisent le crash 0xd5a790 avant M2
   (le témoin est discriminant) ; S4 juge SETUP_OPERAND ; S1-S3
   gardent la non-régression du commit 1.

3. **Diff FINC** (ré-expansion d'ada_comp.adb) : au "&" de
   l'élaboration, disparition des VAR `_slice_data` / `_slice_len` et
   des deux `Sa` associés ; l'opérande gauche devient le namespace
   doublet de CODE_SLICE (mode source) suivi DIRECTEMENT de
   `DUP / La ,0 / La ,8`. Une valeur produite, une consommée. Aucun
   autre site du diff ne doit bouger.

4. **Oracle bootstrap** : gdb run — l'élaboration d'ADA_COMP franchit
   la zone POST_CHN / POSITION_SEPARATEUR (plus de 0xd5a790), et l'on
   retrouve l'objectif du commit 1 : sur null_prog, ERR_PHASE imprime
   son message d'erreur COMPLET sans segfault (ni 0x46ff17 ni
   0xd5a790). Ce message reste la première pièce de la chasse parser.


====================================================================
## HORS COMMIT — à consigner
====================================================================

- **Piège de session (amendement du versement prévu au commit 1)** :
  changer le contrat d'un producteur exige le grep du NŒUD consommé
  (DN_SLICE) sur tout l'expander — les rustines du vieux contrat
  vivent chez les consommateurs, pas aux sites d'appel du producteur.
  L'audit du commit 1 (appelants de CODE_SLICE) a manqué la branche
  de CODE_ARRAY_OPERAND pour cette raison exacte.
- **Dettes solderables** (chacune : son témoin, son commit) :
  expressions 1648 (CCDA tranche → accepter l'@doublet, La ,0),
  expressions 3016 (attribut à préfixe tranche), declarations
  1887-1896 (actuel générique tranche — amender le commentaire qui
  cite le vieux contrat).
