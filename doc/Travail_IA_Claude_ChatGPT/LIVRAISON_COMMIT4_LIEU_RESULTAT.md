# LIVRAISON — COMMIT 4 : la règle unique du LIEU-RÉSULTAT
# (segfault RETPKG1 + troncature NULL_PR du bootstrappé : même racine)

Protocole ancré habituel, blocs au caractère près, rejeu fait sur la
copie portant M1+M2+M3.


## DIAGNOSTIC (clos — FINC + registres + source, chaque maillon)

Le site P1 de RETPKG1.FINC montre l'appel `RETPKG.TS` précédé d'un seul
`LI 0  ; lieu resultat sur pile`. Dans TS, `SIq 1, -result__ofs, 0`
écrit le data_ptr À TRAVERS ce slot : [FP(1)−8] = 0 → `mov rbx,(0)` →
SIGSEGV (rax=0 au fault ; le doublet de TS, lui, était correctement
construit dans sa frame : {data, @info{72,8,1,9}} visibles dans la
photo de pile).

Racine : CODE_SELECTED, branche « désignateur = DN_FUNCTION_ID »
(appel PRÉFIXÉ d'une fonction de paquetage) empile
**LI 0 inconditionnellement** — le protocole SCALAIRE — quel que soit
le type du résultat. CODE_FUNCTION_CALL (branche DN_USED_NAME_ID,
appel simple) fait, lui, le dispatch complet : RECORD → doublet+data ;
DN_ARRAY (non contraint) → doublet anonyme C7 ; tableau contraint →
doublet du type ; sinon scalaire → LI 0.

CONVERGENCE avec la chasse parser : `LEX.TOKEN_STRING` appelé PRÉFIXÉ
depuis PAR_PHASE est exactement cette forme (fonction de paquetage,
résultat STRING). Chez le bootstrappé, le slot-résultat ne contient pas
0 mais un résidu de pile : le SIq écrit à travers une adresse poubelle
SANS crasher, le doublet appelant n'est jamais rempli, les longueurs
lues sont des résidus → **NULL_PR** (troncature silencieuse) et la
TXTREP stockée courte. Le crash net du témoin et la corruption
silencieuse du compilateur sont le même défaut sous deux résidus.

QUATRIÈME occurrence du motif « préparation dupliquée ici, absente
là » (après n° 112, C1-ter, et le littéral du commit 3). Correctif à
la règle : le dispatch est HISSÉ en une procédure partagée
`PREPARE_FUNCTION_RESULT_PLACE( FUNC_DEF, CALL_NODE )` — texte
transplanté TEL QUEL de CODE_FUNCTION_CALL — utilisée par les DEUX
sites ; `PREPARE_ARRAY_RETURN` (locale) est hissée de même en
`PREPARE_ARRAY_RESULT_PLACE( CALL_NODE )` (elle sert aussi à la
branche attribut 'IMAGE). Les appels scalaires préfixés (STORED_LEN)
sont INCHANGÉS : le else du dispatch émet le même LI 0.


====================================================================
## COMMIT 4 — cinq modifications, expander-expressions.adb
====================================================================

--------------------------------------------------------------------
### M-1  — insertion des deux procédures partagées (après CODE_SLICE)
--------------------------------------------------------------------

ANCRE (unique, inchangée) :
```
  end	CODE_SLICE;
```

BLOC À SUPPRIMER :
```
	----------
```

BLOC DE REMPLACEMENT :
```
	----------


			--------------------------
  procedure		PREPARE_ARRAY_RESULT_PLACE	( CALL_NODE :TREE )
  is			--------------------------
			--| Ex-PREPARE_ARRAY_RETURN, locale de CODE_FUNCTION_CALL, HISSEE
			--| au body (segfault RETPKG1 / troncature NULL_PR, 04/08) : la
			--| preparation du lieu-resultat doit etre la MEME pour un appel
			--| PREFIXE (fonction de paquetage, CODE_SELECTED) et un appel
			--| simple (CODE_FUNCTION_CALL).  Texte transplante tel quel,
			--| FUNCTION_CALL parametre en CALL_NODE.
    ANON	:constant STRING	:= ANONYMOUS_NAME_AT( CALL_NODE );
    LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
  begin
      PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
      PUT_LINE( "VAR" & tab & ANON & "__u,   q" );
      PUT_LINE( "namespace " & ANON & "_info" );
      PUT_LINE( "  VAR SIZ, d" );
      PUT_LINE( "  VAR _COMP_SIZ, d" );
      PUT_LINE( "  VAR _FST_1, d" );
      PUT_LINE( "  VAR _LST_1, d" );
      PUT_LINE( "end namespace" );

      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_info.SIZ" );
      PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON & "__u" );
    -- Empiler l'adresse du doublet comme result__ofs (dernier PRM)
      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );

  end	PREPARE_ARRAY_RESULT_PLACE;
	--------------------------


			-----------------------------
  procedure		PREPARE_FUNCTION_RESULT_PLACE	( FUNC_DEF, CALL_NODE :TREE )
  is			-----------------------------
			--| Regle unique du lieu-resultat (segfault RETPKG1 + troncature
			--| NULL_PR du bootstrappe, 04/08) : la branche DN_FUNCTION_ID de
			--| CODE_SELECTED empilait LI 0 INCONDITIONNELLEMENT -- protocole
			--| scalaire -- quel que soit le resultat ; pour un COMPOSITE, le
			--| SIq du callee ecrivait A TRAVERS ce zero (crash net) ou a
			--| travers un residu de pile (corruption SILENCIEUSE :
			--| LEX.TOKEN_STRING prefixe depuis PAR_PHASE -> NULL_PR).
			--| Quatrieme occurrence du motif "preparation dupliquee ici,
			--| absente la" : le dispatch de CODE_FUNCTION_CALL
			--| (DN_USED_NAME_ID) est transplante tel quel et PARTAGE par les
			--| deux sites.  CONTEXT=TREE_VOID + resultat composite : ne peut
			--| plus passer silencieusement (ANONYMOUS_NAME_AT aboiera).
    FUNC_SPEC	: TREE	:= D( SM_SPEC, FUNC_DEF );
    RET_NAME	: TREE	:= D( AS_NAME, FUNC_SPEC );	 -- nom du type de retour (DN_FUNCTION_SPEC)
    RET_TS	: TREE	:= TREE_VOID;
  begin
        -- Resoudre le type de retour jusqu'au TYPE_SPEC effectif
        if  RET_NAME /= TREE_VOID  then
	RET_TS := D( SM_TYPE_SPEC, D( SM_DEFN, RET_NAME ) );
	while  RET_TS.TY = DN_L_PRIVATE  or  RET_TS.TY = DN_PRIVATE  loop
	  RET_TS := D( SM_TYPE_SPEC, RET_TS );
	end loop;

	if  RET_TS.TY = DN_CONSTRAINED_RECORD  then						-- pilier 3.7 : vue contrainte -> base
	  RET_TS := D( SM_BASE_TYPE, RET_TS );						-- (meme taille : layout additif ;
	end if;										--  symboles .size/.use__info de la base)
        end if;

        if  RET_TS /= TREE_VOID  and then  RET_TS.TY = DN_RECORD  then
	-- Allouer un doublet anonyme avec son espace donnees, empiler son adresse comme result__ofs
	declare
	  ANON_STR  : constant STRING := ANONYMOUS_NAME_AT( CALL_NODE );
	  TYPE_NAME : TREE		:= D( XD_SOURCE_NAME, RET_TS );
	  TN_STR	  : constant STRING := TYPE_INFO_STR( RET_TS );
	  LVL_STR	  : constant STRING := IMAGE( CODI.CUR_LEVEL );
	begin
	  PUT_LINE( "VAR" & tab & ANON_STR & "_disp, q" );
	  PUT_LINE( "VAR" & tab & ANON_STR & "__u,    q" );
	  PUT( "VAR" & tab & ANON_STR & "__dat, " );
	  CODI.REGIONS_PATH( TYPE_NAME );
	  PUT_LINE( TN_STR & ".size" );

	  -- Initialiser data_ptr -> adresse des donnees brutes
	  PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON_STR & "__dat" );
	  PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON_STR & "_disp" );

	  -- Initialiser use_info_ptr
	  PUT( tab & "La  " & IMAGE( DI( CD_LEVEL, RET_TS ) ) & ", " );
	  CODI.REGIONS_PATH( TYPE_NAME );
	  PUT_LINE( TN_STR & ".use__info" );
	  PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON_STR & "__u" );

	  -- Empiler l'adresse du doublet comme result__ofs pour la fonction
	  PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON_STR & "_disp" );
	  if  CODI.DEBUG  then PUT( tab50 & "; doublet resultat record anonyme" ); end if;
	  NEW_LINE;
	end;

        elsif  RET_TS /= TREE_VOID  and then  RET_TS.TY = DN_ARRAY  then
	PREPARE_ARRAY_RESULT_PLACE( CALL_NODE );

        elsif  RET_TS /= TREE_VOID  and then  RET_TS.TY = DN_CONSTRAINED_ARRAY  then
	  declare
	    ANON_STR	: constant STRING	:= ANONYMOUS_NAME_AT( CALL_NODE );
	    TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, RET_TS );
	    TN_STR	: constant STRING	:= TYPE_INFO_STR( RET_TS );
	    TYPE_LVL	: constant STRING	:= IMAGE( DI( CD_LEVEL, RET_TS ) );
	    LVL_STR	: constant STRING	:= IMAGE( CODI.CUR_LEVEL );
	  begin
	    PUT_LINE( "VAR" & tab & ANON_STR & "_disp, q" );
	    PUT_LINE( "VAR" & tab & ANON_STR & "__u,   q" );

	    -- info du doublet := info du TYPE (bornes deja elaborees)
	    PUT( tab & "La  " & TYPE_LVL & ", " );
	    CODI.REGIONS_PATH( TYPE_NAME );
	    PUT_LINE( TN_STR & ".use__info" );
	    PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON_STR & "__u" );

	    -- data := CO_VAR( SIZ/8 ) -- taille runtime du type
	    PUT( tab & "Ld  " & TYPE_LVL & ", " );
	    CODI.REGIONS_PATH( TYPE_NAME );
	    PUT_LINE( TN_STR & ".SIZ" );
	    PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
	    PUT_LINE( tab & "DIV" );
	    PUT_LINE( tab & "CO_VAR" );
	    PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON_STR & "_disp" );

	    -- empiler l'adresse du doublet comme result__ofs
	    PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON_STR & "_disp" );
	  end;



        else
	-- Cas scalaire, array, etc. : placeholder qword nul
	PUT( tab & "LI" & tab & "0" );
	if  CODI.DEBUG  then PUT( tab50 & "; lieu resultat sur pile" ); end if;
	NEW_LINE;
        end if;
  end	PREPARE_FUNCTION_RESULT_PLACE;
	-----------------------------

```
--------------------------------------------------------------------
### M-2  — CODE_SELECTED, branche DN_FUNCTION_ID (le LI 0 inconditionnel)
--------------------------------------------------------------------

ANCRE (unique, inchangée) :
```
        elsif  DESIGNATOR_DEFN.TY = DN_FUNCTION_ID
	then
```

BLOC À SUPPRIMER :
```
	PUT( tab & "LI" & tab & "0" );
	if CODI.DEBUG  then  PUT( tab50 & "; lieu resultat sur pile" ); end if;
	NEW_LINE;
```

BLOC DE REMPLACEMENT :
```
	PREPARE_FUNCTION_RESULT_PLACE( DESIGNATOR_DEFN, CONTEXT );					--| lieu-resultat selon le TYPE du resultat (ex-LI 0 inconditionnel)
```
--------------------------------------------------------------------
### M-3  — CODE_FUNCTION_CALL, branche attribut (le cas de 'IMAGE)
--------------------------------------------------------------------

ANCRE (unique, inchangée) :
```
      if  D( SM_EXP_TYPE, FUNCTION_CALL ).TY = DN_ARRAY  then						-- Le cas de 'IMAGE
```

BLOC À SUPPRIMER :
```
        PREPARE_ARRAY_RETURN;
```

BLOC DE REMPLACEMENT :
```
        PREPARE_ARRAY_RESULT_PLACE( FUNCTION_CALL );
```
--------------------------------------------------------------------
### M-4a — suppression de la locale PREPARE_ARRAY_RETURN
--------------------------------------------------------------------

ANCRE (unique, inchangée) :
```
    end	CODE_DN_BLTN_OPERATOR_ID;
	------------------------
```

BLOC À SUPPRIMER :
```


		--------------------
    procedure	PREPARE_ARRAY_RETURN
    is		--------------------
      ANON	:constant STRING	:= ANONYMOUS_NAME_AT( FUNCTION_CALL );
      LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
    begin
      PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
      PUT_LINE( "VAR" & tab & ANON & "__u,   q" );
      PUT_LINE( "namespace " & ANON & "_info" );
      PUT_LINE( "  VAR SIZ, d" );
      PUT_LINE( "  VAR _COMP_SIZ, d" );
      PUT_LINE( "  VAR _FST_1, d" );
      PUT_LINE( "  VAR _LST_1, d" );
      PUT_LINE( "end namespace" );

      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_info.SIZ" );
      PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON & "__u" );
    -- Empiler l'adresse du doublet comme result__ofs (dernier PRM)
      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );

    end	PREPARE_ARRAY_RETURN;
	--------------------

```

BLOC DE REMPLACEMENT :
```


```
--------------------------------------------------------------------
### M-4b — CODE_FUNCTION_CALL, branche DN_USED_NAME_ID → appel partagé
--------------------------------------------------------------------

ANCRE (unique, inchangée) :
```
      return;											-- On a fini pour ce cas

    elsif  NAME.TY = DN_USED_NAME_ID  then
```

BLOC À SUPPRIMER :
```
      declare
        FUNC_DEF	: TREE	:= D( SM_DEFN, NAME );
        FUNC_SPEC	: TREE	:= D( SM_SPEC, FUNC_DEF );
        RET_NAME	: TREE	:= D( AS_NAME, FUNC_SPEC );	 -- nom du type de retour (DN_FUNCTION_SPEC)
        RET_TS	: TREE	:= TREE_VOID;
      begin
        -- Resoudre le type de retour jusqu'au TYPE_SPEC effectif
        if  RET_NAME /= TREE_VOID  then
	RET_TS := D( SM_TYPE_SPEC, D( SM_DEFN, RET_NAME ) );
	while  RET_TS.TY = DN_L_PRIVATE  or  RET_TS.TY = DN_PRIVATE  loop
	  RET_TS := D( SM_TYPE_SPEC, RET_TS );
	end loop;

	if  RET_TS.TY = DN_CONSTRAINED_RECORD  then						-- pilier 3.7 : vue contrainte -> base
	  RET_TS := D( SM_BASE_TYPE, RET_TS );						-- (meme taille : layout additif ;
	end if;										--  symboles .size/.use__info de la base)
        end if;

        if  RET_TS /= TREE_VOID  and then  RET_TS.TY = DN_RECORD  then
	-- Allouer un doublet anonyme avec son espace donnees, empiler son adresse comme result__ofs
	declare
	  ANON_STR  : constant STRING := ANONYMOUS_NAME_AT( FUNCTION_CALL );
	  TYPE_NAME : TREE		:= D( XD_SOURCE_NAME, RET_TS );
	  TN_STR	  : constant STRING := TYPE_INFO_STR( RET_TS );
	  LVL_STR	  : constant STRING := IMAGE( CODI.CUR_LEVEL );
	begin
	  PUT_LINE( "VAR" & tab & ANON_STR & "_disp, q" );
	  PUT_LINE( "VAR" & tab & ANON_STR & "__u,    q" );
	  PUT( "VAR" & tab & ANON_STR & "__dat, " );
	  CODI.REGIONS_PATH( TYPE_NAME );
	  PUT_LINE( TN_STR & ".size" );

	  -- Initialiser data_ptr -> adresse des donnees brutes
	  PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON_STR & "__dat" );
	  PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON_STR & "_disp" );

	  -- Initialiser use_info_ptr
	  PUT( tab & "La  " & IMAGE( DI( CD_LEVEL, RET_TS ) ) & ", " );
	  CODI.REGIONS_PATH( TYPE_NAME );
	  PUT_LINE( TN_STR & ".use__info" );
	  PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON_STR & "__u" );

	  -- Empiler l'adresse du doublet comme result__ofs pour la fonction
	  PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON_STR & "_disp" );
	  if  CODI.DEBUG  then PUT( tab50 & "; doublet resultat record anonyme" ); end if;
	  NEW_LINE;
	end;

        elsif  RET_TS /= TREE_VOID  and then  RET_TS.TY = DN_ARRAY  then
	PREPARE_ARRAY_RETURN;

        elsif  RET_TS /= TREE_VOID  and then  RET_TS.TY = DN_CONSTRAINED_ARRAY  then
	  declare
	    ANON_STR	: constant STRING	:= ANONYMOUS_NAME_AT( FUNCTION_CALL );
	    TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, RET_TS );
	    TN_STR	: constant STRING	:= TYPE_INFO_STR( RET_TS );
	    TYPE_LVL	: constant STRING	:= IMAGE( DI( CD_LEVEL, RET_TS ) );
	    LVL_STR	: constant STRING	:= IMAGE( CODI.CUR_LEVEL );
	  begin
	    PUT_LINE( "VAR" & tab & ANON_STR & "_disp, q" );
	    PUT_LINE( "VAR" & tab & ANON_STR & "__u,   q" );

	    -- info du doublet := info du TYPE (bornes deja elaborees)
	    PUT( tab & "La  " & TYPE_LVL & ", " );
	    CODI.REGIONS_PATH( TYPE_NAME );
	    PUT_LINE( TN_STR & ".use__info" );
	    PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON_STR & "__u" );

	    -- data := CO_VAR( SIZ/8 ) -- taille runtime du type
	    PUT( tab & "Ld  " & TYPE_LVL & ", " );
	    CODI.REGIONS_PATH( TYPE_NAME );
	    PUT_LINE( TN_STR & ".SIZ" );
	    PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
	    PUT_LINE( tab & "DIV" );
	    PUT_LINE( tab & "CO_VAR" );
	    PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON_STR & "_disp" );

	    -- empiler l'adresse du doublet comme result__ofs
	    PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON_STR & "_disp" );
	  end;



        else
	-- Cas scalaire, array, etc. : placeholder qword nul
	PUT( tab & "LI" & tab & "0" );
	if  CODI.DEBUG  then PUT( tab50 & "; lieu resultat sur pile" ); end if;
	NEW_LINE;
        end if;
      end;
```

BLOC DE REMPLACEMENT :
```
      PREPARE_FUNCTION_RESULT_PLACE( D( SM_DEFN, NAME ), FUNCTION_CALL );
```

--------------------------------------------------------------------
### M-5 — hygiène des greps : quatre commentaires citaient l'ancien nom
--------------------------------------------------------------------

M-5a — remplacer :
```
      -- Modele : CODE_EXP(appel) laisse @doublet anonyme (PREPARE_ARRAY_RETURN) ;
```
par :
```
      -- Modele : CODE_EXP(appel) laisse @doublet anonyme (PREPARE_ARRAY_RESULT_PLACE) ;
```

M-5b — remplacer :
```
        ANON      :constant STRING := ANONYMOUS_NAME_AT( NAME );   -- MEME nom que PREPARE_ARRAY_RETURN
```
par :
```
        ANON      :constant STRING := ANONYMOUS_NAME_AT( NAME );   -- MEME nom que PREPARE_ARRAY_RESULT_PLACE
```

M-5c — remplacer :
```
	-- PREPARE_ARRAY_RETURN ; bornes runtime dans <anon>_info, 1-dim
```
par :
```
	-- PREPARE_ARRAY_RESULT_PLACE ; bornes runtime dans <anon>_info, 1-dim
```

M-5d — remplacer :
```
      ANON	:constant STRING	:= ANONYMOUS_NAME_AT( PREFIX_NAME );	-- MEME nom que PREPARE_ARRAY_RETURN
```
par :
```
      ANON	:constant STRING	:= ANONYMOUS_NAME_AT( PREFIX_NAME );	-- MEME nom que PREPARE_ARRAY_RESULT_PLACE
```


--------------------------------------------------------------------
### ORACLES DU COMMIT 4
--------------------------------------------------------------------

1. **Filet syntaxique** : `gnat -gnats -gnat83` — zéro erreur.

2. **Oracle témoin** : RETPKG1 — « RESULTAT : 5 OK, 0 ECHECS » +
   « RETPKG1 PASSE » des deux côtés (P1 affiche [NULL_PROG] entier ;
   P4/P5 jugent le relais résultat→actuel ; P6 la longueur 2).
   RETSLICE et RETMICRO1 restent verts (non-régression du chemin
   local).

3. **Diff FINC** (retpkg1) : au site P1, le `LI 0` est remplacé par le
   doublet anonyme C7 (VAR _disp/__u + namespace _info + LVA/Sa/LVA)
   — identique au site de RETMICRO1 ; les appels STORED_LEN /
   STORED_EQ gardent leur LI 0 (scalaires). Aucun autre site du diff
   ne bouge.

4. **L'oracle royal — le bootstrappé** : re-génération complète
   (commits 1-4), puis `./A83.sh ./ ./null_prog.adb S` avec M-DBG :
   la trace doit montrer `identifier\NULL_PROG` ENTIER et la TXTREP
   L54. Ensuite, de deux choses l'une : l'erreur IS disparaît avec la
   corruption (les résidus de pile pollués par les SIq à travers
   pouvaient déborder ailleurs) — PAR_PHASE clos ; ou elle persiste
   sur un walk de table propre — et les lignes « @ » de M-TRACE, sur
   un compilateur enfin sain, désignent l'opération exacte.


====================================================================
## HORS COMMIT — à consigner
====================================================================

- Piège de session (le motif, désormais nommé, en est à sa QUATRIÈME
  occurrence) : toute PRÉPARATION DE PROTOCOLE (lieu-résultat, actuel,
  producteur de valeur) qui existe en plusieurs exemplaires finit avec
  un exemplaire faux ; le grep de clôture est celui du POINT DE
  PROTOCOLE (ici « lieu resultat sur pile »), pas du nœud seulement.
  Les LI 0 restants et légitimes : INTEGER_VALUE (2872), WIDTH formel
  (2917), INTEGER_POW (4413) — tous scalaires par construction ;
  le else scalaire du dispatch partagé.
- Chantier F3 toujours ouvert (défauts de MAKE, poubelle
  [DN_ARGUMENT_ID,P9873,L100]) — source de MAKE + FINC à joindre
  après l'oracle royal ; NB : si cette poubelle était ELLE AUSSI une
  retombée des SIq-à-travers (écritures dans les pages DIANA via un
  résidu), l'oracle royal peut la faire disparaître — à vérifier au
  même run.
