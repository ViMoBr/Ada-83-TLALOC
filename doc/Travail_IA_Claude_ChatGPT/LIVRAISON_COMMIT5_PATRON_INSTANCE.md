# LIVRAISON — COMMIT 5 : un patron n'est pas une instance
# (SELARG : le __u remis à GET_LINE pointait le patron _STRING)

Protocole ancré habituel ; expander-instructions.adb est vierge de tout
commit précédent — l'ancre s'applique telle quelle. Rejeu fait.

## DIAGNOSTIC (clos — c'est le vôtre, formalisé)

`GET_LINE( IFILE, SLINE.BDY, SLINE.LEN )` : le SELARG de l'actual
composite sélectionné posait `__u := La 0, STANDARD._STRING.use__info`
— le bloc du TYPE DE BASE non contraint, un PATRON qui existe pour
définir des OFFSETS, jamais des VALEURS. GET_LINE lit légitimement les
bornes d'ITEM à travers ce doublet : bornes de hasard → arrêt à 17 →
NULL_PR → « OG » resté dans le fichier → pseudo-ligne 2 → toute la
chaîne observée. GETREC passait : sa variable LOCALE avait son vrai
bloc — le défaut exige le composant de record dont SM_EXP_TYPE remonte
au base. Les bornes réelles du composant SONT statiquement accessibles
(la preuve : STATOFS BDY, 255, 1 émis par le record-elab via
STATIC_TYPE_SIZE_BITS sur SM_OBJ_TYPE) : c'est la SÉLECTION d'attribut
qui divergeait — SM_EXP_TYPE (base) au SELARG contre SM_OBJ_TYPE
(contraint) au STATOFS.

RÈGLE NOUVELLE AU PILIER (à consigner) : **tout use__info remis au
runtime pointe un bloc d'INSTANCE (objet, composant élaboré, bloc
anonyme) — jamais le patron d'un type de base.**

## LA MODIFICATION (une seule, expander-instructions.adb ~l. 782)

Dispatch retaillé :
- DN_CONSTRAINED_ARRAY / DN_RECORD (types NOMMÉS) : émission
  historique conservée à l'identique — leurs blocs _<type> sont de
  vrais blocs d'instance élaborés ;
- DN_ARRAY (résolution au BASE — le cas fautif) : fabrication du bloc
  d'instance du COMPOSANT (namespace SELARG_x_info + immédiats
  COMP/FST/LST/SIZ) depuis les bornes statiques de SM_OBJ_TYPE du
  désignateur ; extraction volontairement minimale (littéral /
  SM_VALUE posé via SM_DEFN — sous-ensemble assumé de
  STATIC_BOUND_VALUE, dette de fusion consignée) ; TROU bruyant pour :
  sous-type non contraint, multi-dim, bornes non statiques,
  CD_IMPL_SIZE absent.

ANCRE (unique, inchangée) :
```
	    CODI.TROU( "SELARG actuel selecte de vue record contrainte", ACT_TYPE );

```

BLOC À SUPPRIMER (l'elsif array/record complet) :
```
	  elsif  ACT_TYPE.TY = DN_ARRAY  or else  ACT_TYPE.TY = DN_CONSTRAINED_ARRAY  or  else ACT_TYPE.TY = DN_RECORD
	  then
	    declare
	      ANON	:constant STRING	:= "SELARG_" & NEW_LABEL;
	      LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
	      TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, ACT_TYPE );
	      TYPE_NAME_STR :constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	    begin
	      PUT_LINE( tab & "VAR " & ANON & "_disp, q" );
	      PUT_LINE( tab & "VAR " & ANON & "__u, q" );

		      if  ACT_PRM.TY = DN_SELECTED  then
		        EXPRESSIONS.CODE_SELECTED( ACT_PRM, IS_SOURCE => FALSE );
		      else
		        EXPRESSIONS.CODE_OBJECT_ADDRESS( ACT_PRM );
		      end if;
	      PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & ANON & "_disp" );

	      PUT( tab & "La " & IMAGE( DI( CD_LEVEL, ACT_TYPE ) ) & ", " );
	      CODI.REGIONS_PATH( TYPE_NAME );
	      PUT_LINE( TYPE_NAME_STR & ".use__info" );
	      PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & ANON & "__u" );

	      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );
	    end;
```

BLOC DE REMPLACEMENT :
```
	  elsif  ACT_TYPE.TY = DN_CONSTRAINED_ARRAY  or  else ACT_TYPE.TY = DN_RECORD
	  then
			--| Type NOMME : son bloc _<type> est un vrai bloc d'INSTANCE,
			--| elabore avec ses valeurs -- emission historique conservee.
	    declare
	      ANON	:constant STRING	:= "SELARG_" & NEW_LABEL;
	      LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
	      TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, ACT_TYPE );
	      TYPE_NAME_STR :constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	    begin
	      PUT_LINE( tab & "VAR " & ANON & "_disp, q" );
	      PUT_LINE( tab & "VAR " & ANON & "__u, q" );

		      if  ACT_PRM.TY = DN_SELECTED  then
		        EXPRESSIONS.CODE_SELECTED( ACT_PRM, IS_SOURCE => FALSE );
		      else
		        EXPRESSIONS.CODE_OBJECT_ADDRESS( ACT_PRM );
		      end if;
	      PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & ANON & "_disp" );

	      PUT( tab & "La " & IMAGE( DI( CD_LEVEL, ACT_TYPE ) ) & ", " );
	      CODI.REGIONS_PATH( TYPE_NAME );
	      PUT_LINE( TYPE_NAME_STR & ".use__info" );
	      PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & ANON & "__u" );

	      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );
	    end;

	  elsif  ACT_TYPE.TY = DN_ARRAY  then
			--| Pilier (04/08, GET_LINE(SLINE.BDY,..) -> LEN=17 -> NULL_PR) :
			--| SM_EXP_TYPE remonte au TYPE DE BASE non contraint, et son bloc
			--| _<base> (ex. STANDARD._STRING) est un PATRON -- il definit des
			--| OFFSETS, jamais des VALEURS consultables.  Le donner comme __u
			--| au callee (GET_LINE lit les bornes d'ITEM a travers) livre des
			--| bornes de hasard.  REGLE : tout use__info remis au runtime
			--| pointe un bloc d'INSTANCE.  Ici : fabriquer le bloc du
			--| COMPOSANT depuis les bornes STATIQUES de son sous-type
			--| (SM_OBJ_TYPE du designateur) ; hors statique 1-dim -> TROU.
			--| Extraction volontairement MINIMALE (litteral / SM_VALUE pose,
			--| via SM_DEFN pour les noms) : sous-ensemble assume de
			--| STATIC_BOUND_VALUE (types_decls, piege n 95a) -- dette de
			--| fusion consignee, tout cas hors sous-ensemble aboie.
	    declare
	      ANON	:constant STRING	:= "SELARG_" & NEW_LABEL;
	      LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
	      COMP_ST	: TREE	:= TREE_VOID;
	      IDX_S	: SEQ_TYPE;
	      IDX_TYPE	: TREE;
	      IDX_RANGE	: TREE	:= TREE_VOID;
	      ELEM_TYPE	: TREE;
	      LO, HI	: INTEGER	:= 0;
	      LO_OK, HI_OK	: BOOLEAN	:= FALSE;
	      NDIM	: NATURAL	:= 0;
	      COMP_BITS	: INTEGER	:= 0;

	      procedure	BORNE_STATIQUE	( B :TREE; V :out INTEGER; OK :out BOOLEAN )
	      is
	        N	: TREE	:= B;
	        SV	: TREE;
	      begin
	        if  N.TY = DN_USED_NAME_ID  or else  N.TY = DN_USED_OBJECT_ID  then			--| noms : sm_value via sm_defn
	          N := D( SM_DEFN, N );
	        end if;
	        SV := D( SM_VALUE, N );
	        if  SV.TY = DN_NUM_VAL  or else  SV.NOTY = DN_NUM_VAL  then
	          V := DI( SM_VALUE, N );  OK := TRUE;
	        else
	          V := 0;  OK := FALSE;
	        end if;
	      end BORNE_STATIQUE;

	    begin
	      if  ACT_PRM.TY = DN_SELECTED  then
	        COMP_ST := D( SM_OBJ_TYPE, D( SM_DEFN, D( AS_DESIGNATOR, ACT_PRM ) ) );
	        COMP_ST := CODI.FULL_TYPE_VIEW( COMP_ST );
	      end if;

	      if  COMP_ST = TREE_VOID  or else  COMP_ST.TY /= DN_CONSTRAINED_ARRAY  then
	        CODI.TROU( "SELARG tableau de base sans sous-type composant contraint", ACT_TYPE );
	      end if;

	      IDX_S := LIST( D( SM_INDEX_SUBTYPE_S, COMP_ST ) );
	      while  not IS_EMPTY( IDX_S )  loop
	        POP( IDX_S, IDX_TYPE );
	        NDIM := NDIM + 1;
	        IDX_RANGE := D( SM_RANGE, CODI.FULL_TYPE_VIEW( IDX_TYPE ) );
	      end loop;
	      if  NDIM /= 1  or else  IDX_RANGE = TREE_VOID  or else  IDX_RANGE.TY /= DN_RANGE  then
	        CODI.TROU( "SELARG composant tableau multi-dim ou sans SM_RANGE (D6)", COMP_ST );
	      end if;

	      BORNE_STATIQUE( D( AS_EXP1, IDX_RANGE ), LO, LO_OK );
	      BORNE_STATIQUE( D( AS_EXP2, IDX_RANGE ), HI, HI_OK );
	      if  not ( LO_OK and HI_OK )  or else  HI < LO  then
	        CODI.TROU( "SELARG composant tableau a bornes non statiques", COMP_ST );
	      end if;

	      ELEM_TYPE := D( SM_COMP_TYPE, D( SM_BASE_TYPE, COMP_ST ) );
	      if  ELEM_TYPE.TY = DN_PRIVATE  or else  ELEM_TYPE.TY = DN_L_PRIVATE  then
	        ELEM_TYPE := D( SM_TYPE_SPEC, ELEM_TYPE );
	      end if;
	      COMP_BITS := DI( CD_IMPL_SIZE, CODI.FULL_TYPE_VIEW( ELEM_TYPE ) );				--| convention octet (piege n 10) : arrondir
	      COMP_BITS := ( ( COMP_BITS + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT ) * CODI.STORAGE_UNIT;
	      if  COMP_BITS = 0  then
	        CODI.TROU( "SELARG composant elementaire sans CD_IMPL_SIZE", ELEM_TYPE );
	      end if;

	      PUT_LINE( tab & "VAR " & ANON & "_disp, q" );
	      PUT_LINE( tab & "VAR " & ANON & "__u, q" );
	      PUT_LINE( "namespace " & ANON & "_info" );						--| bloc d'INSTANCE du composant
	      PUT_LINE( "  VAR SIZ,      d" );
	      PUT_LINE( "  VAR _COMP_SIZ, d" );
	      PUT_LINE( "  VAR _FST_1,    d" );
	      PUT_LINE( "  VAR _LST_1,    d" );
	      PUT_LINE( "end namespace" );

	      if  ACT_PRM.TY = DN_SELECTED  then
	        EXPRESSIONS.CODE_SELECTED( ACT_PRM, IS_SOURCE => FALSE );
	      else
	        EXPRESSIONS.CODE_OBJECT_ADDRESS( ACT_PRM );
	      end if;
	      PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & ANON & "_disp" );

	      PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BITS ) );
	      PUT_LINE( tab & "Sd" & tab & LVL_STR & ", " & ANON & "_info._COMP_SIZ" );
	      PUT_LINE( tab & "LI" & tab & IMAGE( LO ) );
	      PUT_LINE( tab & "Sd" & tab & LVL_STR & ", " & ANON & "_info._FST_1" );
	      PUT_LINE( tab & "LI" & tab & IMAGE( HI ) );
	      PUT_LINE( tab & "Sd" & tab & LVL_STR & ", " & ANON & "_info._LST_1" );
	      PUT_LINE( tab & "LI" & tab & IMAGE( ( HI - LO + 1 ) * COMP_BITS ) );
	      PUT_LINE( tab & "Sd" & tab & LVL_STR & ", " & ANON & "_info.SIZ" );
	      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_info.SIZ" );
	      PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & ANON & "__u" );

	      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );
	    end;
```

## ORACLES DU COMMIT 5

1. **Filet syntaxique** : `gnat -gnats -gnat83` — zéro erreur.
   (Deux points à surveiller au filet : les attributs SV.NOTY /
   DN_NUM_VAL de BORNE_STATIQUE — si le nom exact du champ NOTY
   diffère chez vous, me renvoyer l'erreur gnat, l'extraction est
   calquée sur LIRE_SM_VALUE de types_decls.)

2. **Identité d'émission** (leçon du commit 4) : ré-expansion du
   CORPUS COMPLET + du bootstrap ; le diff ne doit toucher QUE les
   sites SELARG d'actuals tableaux-de-base (GET_LINE de par_phase,
   d'ERR_PHASE, GETREC…) — chacun y gagne le namespace SELARG_x_info
   + les immédiats, et perd le `La 0, _STRING.use__info`. Tout autre
   mouvement = stop.

3. **Témoins** : GETREC re-passe (dual) ; le filet entier re-passe.

4. **L'oracle royal** : bootstrap re-généré,
   `./A83.sh ./ ./null_prog.adb S` avec LEX_DEBUG :
   `Source Line={procedure NULL_PROG}`, %U%L%L%P%R%O%G complet,
   token `identifier\NULL_PROG`, TXTREP L54 — et, la trace gnat
   faisant foi, le parse de null_prog au bout. Si l'erreur IS
   subsiste sur des tokens désormais sains : les lignes « @ » de
   M-TRACE sur données propres.

5. **Au même run, re-mesurer les deux mystères adjacents** : les
   4 NULs du `PUT( "ada83 compiling " & … )` (si le +4 venait d'une
   consultation de patron par un autre chemin, il peut tomber avec ;
   s'il reste, dossier séparé avec le site d'appel de PAR_PHASE) ; et
   la poubelle des défauts de MAKE (F3) — si elle persiste, son
   chantier s'ouvre avec le source de MAKE.

## HORS COMMIT — dettes et consignes

- Pilier amendé : « patron = offsets, jamais valeurs » + le
  recensement des AUTRES consultations de patron encore en place, à
  solder chacune avec témoin le jour venu : USEINFO du record-elab
  (REGIONS_PATH vers le base au lieu du bloc local —
  types_decls, PROCESS_INSERT_ONE_COMPONENT), CODE_INDEXED
  USE_TYPE_INFO_DIRECT (repli base), INDARG (dette commune n 112).
- Dette de fusion : BORNE_STATIQUE ⊂ STATIC_BOUND_VALUE — hisser
  l'original en helper partagé quand un site de plus en aura besoin.
