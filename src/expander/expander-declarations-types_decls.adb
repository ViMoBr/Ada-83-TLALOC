------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( EXPANDER.DECLARATIONS )
				-----------
package body			TYPES_DECLS
				-----------
is

    procedure CODE_ENUMERATION_DECL		( TYPE_DECL :TREE );
    procedure CODE_INTEGER_DECL		( TYPE_DECL :TREE );
    procedure CODE_FIXED_DECL			( TYPE_DECL :TREE );
    procedure CODE_FLOAT_DECL			( TYPE_DECL :TREE );

    procedure CODE_RECORD_DECL		( TYPE_DECL :TREE );
    procedure CODE_CONSTRAINED_RECORD_DECL	( TYPE_NAME : TREE; TYPE_SPEC : TREE );
    procedure CODE_UNCONSTRAINED_ARRAY_DECL	( TYPE_DECL :TREE );
    procedure CODE_CONSTRAINED_ARRAY_DECL	( TYPE_DECL :TREE );
    procedure CODE_ACCESS_DECL		( TYPE_DECL :TREE );



			--==============--
  procedure		  CODE_TYPE_DECL		( TYPE_DECL :TREE )
  is			--==============--

    TYPE_NAME	: TREE	:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_SPEC	: TREE	:= D( SM_TYPE_SPEC,	TYPE_NAME	);
  begin
				-- SCALAR	TYPES

    if	 TYPE_SPEC.TY = DN_ENUMERATION	then  CODE_ENUMERATION_DECL	     ( TYPE_DECL );
    elsif	 TYPE_SPEC.TY = DN_INTEGER		then  CODE_INTEGER_DECL	     ( TYPE_DECL );
    elsif	 TYPE_SPEC.TY = DN_FIXED		then  CODE_FIXED_DECL	     ( TYPE_DECL );
    elsif	 TYPE_SPEC.TY = DN_FLOAT		then  CODE_FLOAT_DECL	     ( TYPE_DECL );

				-- COMPOSITE TYPES

    elsif	 TYPE_SPEC.TY = DN_RECORD		then  CODE_RECORD_DECL	     ( TYPE_DECL );
    elsif  TYPE_SPEC.TY = DN_CONSTRAINED_RECORD	then  CODE_CONSTRAINED_RECORD_DECL ( TYPE_NAME, TYPE_SPEC );
    elsif	 TYPE_SPEC.TY = DN_ARRAY		then  CODE_UNCONSTRAINED_ARRAY_DECL( TYPE_DECL );
    elsif	 TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY	then  CODE_CONSTRAINED_ARRAY_DECL  ( TYPE_DECL );

				-- ACCESS TYPES

    elsif	 TYPE_SPEC.TY = DN_ACCESS		then  CODE_ACCESS_DECL	     ( TYPE_DECL );

			-- PRIVATE / LIMITED PRIVATE / INCOMPLETE TYPES

    elsif	 TYPE_SPEC.TY = DN_PRIVATE  or  TYPE_SPEC.TY = DN_L_PRIVATE  then
				------------------------
				ANTICIPATE_PRIVATE_LEVEL:
      declare
        FULL_TYPE_SPEC	: TREE	:= D( SM_TYPE_SPEC, TYPE_SPEC );

      begin
        if  not (FULL_TYPE_SPEC.TY = DN_VOID)
	and then  not ( (FULL_TYPE_SPEC.TY = DN_PRIVATE)  or  (FULL_TYPE_SPEC.TY = DN_L_PRIVATE ))
	and then  not DB( CD_COMPILED, FULL_TYPE_SPEC )  then
	DI( CD_LEVEL, FULL_TYPE_SPEC, CODI.CUR_LEVEL );
        end if;
      end			ANTICIPATE_PRIVATE_LEVEL;
			------------------------
      if	CODI.DEBUG  then
        PUT_LINE( "; EXPANDER.DECLARATIONS.CODE_TYPE_DECL : skip PRIVATE "
		& PRINT_NAME( D( LX_SYMREP, TYPE_NAME )	) & " (deferred to full type)" );
      end	if;

    elsif  TYPE_SPEC.TY = DN_INCOMPLETE  then
				---------------------------
				ANTICIPATE_INCOMPLETE_LEVEL:
      declare
        FULL_TYPE_SPEC	: TREE	:= D( XD_FULL_TYPE_SPEC, TYPE_SPEC );
      begin
        if  not (FULL_TYPE_SPEC.TY = DN_VOID)  and then  not DB( CD_COMPILED, FULL_TYPE_SPEC )  then
	DI( CD_LEVEL, FULL_TYPE_SPEC, CODI.CUR_LEVEL );
        end if;
      end			ANTICIPATE_INCOMPLETE_LEVEL;
			---------------------------
      if	CODI.DEBUG  then
        PUT_LINE(	"; EXPANDER.DECLARATIONS.CODE_TYPE_DECL : skip INCOMPLETE "
		& PRINT_NAME( D( LX_SYMREP, TYPE_NAME )	) & " (deferred to full type)" );
      end	if;

    else
      PUT_LINE( "; EXPANDER.DECLARATIONS.CODE_TYPE_DECL : TYPE_SPEC.TY ("
		& NODE_NAME'IMAGE( TYPE_SPEC.TY ) & " NON FAIT POUR ) "
		& PRINT_NAME( D( LX_SYMREP, TYPE_NAME )	)
	        );
    end if;

  end	  CODE_TYPE_DECL;
	--==============--



			---------------------
  procedure		CODE_ENUMERATION_DECL	( TYPE_DECL :TREE )
  is			---------------------

    TYPE_ID	: TREE		:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_SPEC	: TREE		:= D( SM_TYPE_SPEC,	TYPE_ID );
    TYPE_STR	:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    MAX_REP	: INTEGER		:= INTEGER'FIRST;
    MIN_REP	: INTEGER		:= INTEGER'LAST;

		-------------------
    procedure	CODE_ENUM_LITERAL_S		( ENUM_LITERAL_S :TREE )
    is
      ENUM_LITERAL_SEQ	: SEQ_TYPE	:= LIST (	ENUM_LITERAL_S );
      ENUM_LITERAL_ID	: TREE;
      LAST_LITERAL		: TREE;
    begin
      while  not IS_EMPTY( ENUM_LITERAL_SEQ )  loop
        POP( ENUM_LITERAL_SEQ, ENUM_LITERAL_ID );
        declare
	ENUM_ID_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, ENUM_LITERAL_ID ) );
	REP		: INTEGER		:= DI( SM_REP, ENUM_LITERAL_ID );
        begin
	if  MIN_REP > REP  then MIN_REP := REP;	end if;
	if  MAX_REP < REP  then MAX_REP := REP;	end if;
	if  ENUM_ID_STR /= "'""'"
	then  PUT_LINE( "db" & INTEGER'IMAGE( REP ) & ","	& INTEGER'IMAGE( ENUM_ID_STR'LENGTH ) &	", """ & ENUM_ID_STR & """" );
	else  PUT_LINE( "db" & INTEGER'IMAGE( REP ) & ","	& INTEGER'IMAGE( ENUM_ID_STR'LENGTH ) &	", ""'""""'""" );
	end if;
        end;
        LAST_LITERAL := ENUM_LITERAL_ID;
      end	loop;
      DI(	CD_LAST, ENUM_LITERAL_S, DI (	SM_REP, LAST_LITERAL ) );

  end	CODE_ENUM_LITERAL_S;
	-------------------

  begin
    DI( CD_LEVEL,	  TYPE_SPEC, INTEGER( CODI.CUR_LEVEL ) );
    DB( CD_COMPILED,  TYPE_SPEC, TRUE );

    if  CODI.DEBUG	then NEW_LINE; PUT_LINE( tab50 & "; " & TYPE_STR & " ENUMERATION TYPE INFO" ); end if;

    PUT_LINE( TYPE_STR & " = '" & TYPE_STR & "'" );
    PUT_LINE( "namespace " & TYPE_STR );
    PUT_LINE( "VAR use__info, q" );

    PUT_LINE( "BEGIN_BLOC_DEF" );
    CODE_ENUM_LITERAL_S( D( SM_LITERAL_S, TYPE_SPEC ) );
    PUT_LINE( "END_BLOC_DEF "
	    & IMAGE( DI( CD_IMPL_SIZE, TYPE_SPEC ) ) & ','
	    & INTEGER'IMAGE( MIN_REP ) & ','
	    & INTEGER'IMAGE( MAX_REP ) );

    if  CODI.DEBUG	then PUT(	ASCII.HT & "; SIZ en bits !" ); end if;
    NEW_LINE;

    PUT_LINE( tab & "LCA" & tab & "SIZ" );
    PUT_LINE( tab &	"Sa" & tab & IMAGE( CODI.CUR_LEVEL ) & ", use__info" );

    PUT_LINE( "end namespace");

  end	CODE_ENUMERATION_DECL;
	---------------------



			-----------------
  procedure		CODE_INTEGER_DECL		( TYPE_DECL :TREE )
  is			-----------------

    TYPE_ID		: TREE		:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_STR		:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    INTEGER_SPEC		: TREE		:= D( SM_TYPE_SPEC,	TYPE_ID );
    INT_RANGE		: TREE		:= D( SM_RANGE, INTEGER_SPEC );
    EXP_FST		: TREE		:= D( AS_EXP1, INT_RANGE );
    EXP_LST		: TREE		:= D( AS_EXP2, INT_RANGE );
    LVL_STR		:constant	STRING	:= IMAGE(	CODI.CUR_LEVEL );
    SIZE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( INTEGER_SPEC );
  begin
    DI( CD_LEVEL,	  INTEGER_SPEC, INTEGER( CODI.CUR_LEVEL	) );
    DI( CD_LEVEL,	  D( SM_BASE_TYPE, INTEGER_SPEC ), INTEGER( CODI.CUR_LEVEL	) );
    DB( CD_COMPILED,  INTEGER_SPEC, TRUE );

    if  CODI.DEBUG	then  NEW_LINE; PUT_LINE( tab50 & "; " & TYPE_STR & " TYPE RANGE INFO" ); end if;

    PUT_LINE( TYPE_STR & " = '" & TYPE_STR & "'" );
    PUT_LINE( "namespace " & TYPE_STR );
    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "VAR SIZ, d" );
    PUT_LINE( tab &	"LVA" & tab & LVL_STR & ", SIZ" );
    PUT_LINE( tab &	"Sa" & tab & LVL_STR & ", use__info" );

    PUT_LINE( "VAR FST, " & SIZE_CHAR );
    PUT_LINE( "VAR LST, " & SIZE_CHAR );

    PUT_LINE( tab &	"LI" & tab & IMAGE(	DI( CD_IMPL_SIZE, INTEGER_SPEC ) ) );
    PUT_LINE( tab &	"Sd" & tab & LVL_STR & ", SIZ" );

    EXPRESSIONS.CODE_EXP( EXP_FST );
    PUT_LINE( tab &	'S' & SIZE_CHAR & tab & LVL_STR & ", FST" );

    EXPRESSIONS.CODE_EXP( EXP_LST );
    PUT_LINE( tab &	'S' & SIZE_CHAR & tab & LVL_STR & ", LST" );

    PUT_LINE( "end namespace"	);

  end	CODE_INTEGER_DECL;
	-----------------


			---------------
  procedure		CODE_FIXED_DECL		( TYPE_DECL :TREE )
  is			---------------

    TYPE_ID		: TREE		:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_STR		:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    FIXED_SPEC		: TREE		:= D( SM_TYPE_SPEC,	TYPE_ID );
    SIZE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( FIXED_SPEC );
    SMALL_VAL		: TREE		:= D( CD_IMPL_SMALL, FIXED_SPEC );
    FIXED_RANGE		: TREE		:= D( SM_RANGE, FIXED_SPEC );
    EXP_FST		: TREE		:= D( AS_EXP1, FIXED_RANGE );
    EXP_LST		: TREE		:= D( AS_EXP2, FIXED_RANGE );
    LVL_STR		:constant	STRING	:= IMAGE(	CODI.CUR_LEVEL );

  begin
    DI( CD_LEVEL,	  FIXED_SPEC, INTEGER( CODI.CUR_LEVEL )	);
    DB( CD_COMPILED,  FIXED_SPEC, TRUE );

    if  CODI.DEBUG	then  NEW_LINE; PUT_LINE( tab50 & "; " & TYPE_STR & " FIXED TYPE INFO" ); end if;

    PUT_LINE( TYPE_STR & " = '" & TYPE_STR & "'" );
    PUT_LINE( "namespace " & TYPE_STR );

    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "VAR SIZ, d" );
    PUT_LINE( tab &	"LVA" & tab & LVL_STR & ", SIZ" );
    PUT_LINE( tab &	"Sa" & tab & LVL_STR & ", use__info" );

    PUT_LINE( tab &	"LI" & tab & IMAGE(	DI( CD_IMPL_SIZE, FIXED_SPEC ) ) );
    PUT_LINE( tab &	"Sd" & tab & LVL_STR & ", SIZ" );

    PUT_LINE( "VAR FST, " & SIZE_CHAR );
    PUT_LINE( "VAR LST, " & SIZE_CHAR );

    EXPRESSIONS.CODE_STATIC_FIXED_VALUE( D( SM_VALUE, EXP_FST ), FIXED_SPEC );
    PUT_LINE( tab & 'S' & SIZE_CHAR & tab & LVL_STR & ", FST" );

    EXPRESSIONS.CODE_STATIC_FIXED_VALUE( D( SM_VALUE, EXP_LST ), FIXED_SPEC );
    PUT_LINE( tab & 'S' & SIZE_CHAR & tab & LVL_STR & ", LST" );


--    EXPRESSIONS.CODE_EXP( EXP_FST );
--    PUT_LINE( tab &	'S' & SIZE_CHAR & tab & LVL_STR & ", FST" );

--    EXPRESSIONS.CODE_EXP( EXP_LST );
--    PUT_LINE( tab &	'S' & SIZE_CHAR & tab & LVL_STR & ", LST" );

    PUT_LINE( "VAR NUMER, q" );
    PUT_LINE( "VAR DENOM, q" );

    PUT_LINE( tab &	"LI" & tab & PRINT_NUM( D( XD_NUMER, SMALL_VAL ) ) );
    PUT_LINE( tab &	"Sq" & tab & LVL_STR & ", NUMER" );
    PUT_LINE( tab &	"LI" & tab & PRINT_NUM( D( XD_DENOM, SMALL_VAL ) ) );
    PUT_LINE( tab &	"Sq" & tab & LVL_STR & ", DENOM" );

    PUT_LINE( "end namespace"	);

  end	CODE_FIXED_DECL;
	---------------



			---------------
  procedure		CODE_FLOAT_DECL		( TYPE_DECL :TREE )
  is			---------------

    TYPE_ID		: TREE		:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_STR		:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    FLOAT_SPEC		: TREE		:= D( SM_TYPE_SPEC,	TYPE_ID );
    SIZE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( FLOAT_SPEC );

  begin
    DI( CD_LEVEL,	  FLOAT_SPEC, INTEGER( CODI.CUR_LEVEL )	);
    DB( CD_COMPILED,  FLOAT_SPEC, TRUE );

    if  CODI.DEBUG	then  NEW_LINE; PUT_LINE( tab50 & "; " & TYPE_STR & " FLOAT TYPE INFO" ); end if;

    PUT_LINE( TYPE_STR & " = '" & TYPE_STR & "'" );
    PUT_LINE( "namespace " & TYPE_STR );

    PUT_LINE( "VAR use__info, q" );

    PUT_LINE( "VAR SIZ, d" );
    PUT_LINE( "VAR FST, q" );
    PUT_LINE( "VAR LST, q" );

    declare
      FLOAT_RANGE	: TREE		:= D( SM_RANGE, FLOAT_SPEC );
      EXP_FST	: TREE		:= D( AS_EXP1, FLOAT_RANGE );
      EXP_LST	: TREE		:= D( AS_EXP2, FLOAT_RANGE );
      LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
    begin
      PUT_LINE( tab & "LVA" & tab & LVL_STR & ", SIZ" );
      PUT_LINE( tab & "Sa"  & tab & LVL_STR & ", use__info" );

      PUT_LINE( tab & "LI" & tab & INTEGER'IMAGE( DI( CD_IMPL_SIZE, FLOAT_SPEC ) ) );
      PUT_LINE( tab & "Sd" & tab & LVL_STR & ", SIZ" );

      EXPRESSIONS.CODE_EXP( EXP_FST );
      PUT_LINE( tab & "Sq" & tab & LVL_STR & ", FST" );

      EXPRESSIONS.CODE_EXP( EXP_LST );
      PUT_LINE( tab & "Sq" & tab & LVL_STR & ", LST" );
    end;


--    if  SIZE_CHAR = 'd'  then
--      PUT_LINE( "CST LST, " & SIZE_CHAR & ",  1.0E38" );							-- ATTENTION : CST ne sens inverse a cause de postpone
--      PUT_LINE( "CST FST, " & SIZE_CHAR & ", -1.0E38" );
--    elsif  SIZE_CHAR = 'q'  then
--      PUT_LINE( "CST LST, " & SIZE_CHAR & ",  1.0E308" );
--      PUT_LINE( "CST FST, " & SIZE_CHAR & ", -1.0E308" );
--    end if;

--    PUT_LINE( "CST SIZ, d," &	INTEGER'IMAGE( DI( CD_IMPL_SIZE, FLOAT_SPEC ) ) );
--    PUT_LINE( tab &	"LCA" & tab & "SIZ" );
--    PUT_LINE( tab &	"Sa" & tab & IMAGE( CODI.CUR_LEVEL ) & ", use__info" );

    PUT_LINE( "end namespace"	);

  end	CODE_FLOAT_DECL;
	---------------



			-----------------------------
  procedure		CODE_UNCONSTRAINED_ARRAY_DECL		( TYPE_DECL :TREE )
  is			-----------------------------

    TYPE_ID		: TREE		:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_ID_STR		:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    TYPE_SPEC		: TREE		:= D( SM_TYPE_SPEC,	TYPE_ID );
    INDEX_SUBTYPE_S		: SEQ_TYPE	:= LIST( D( SM_INDEX_S, TYPE_SPEC ) );
    DIM_NBR		: NATURAL		:= 1;
    TOTAL_DIMS		: NATURAL		:= 0;
    LVL			: LEVEL_NUM	renames CODI.CUR_LEVEL;
    LVL_STR		:constant	STRING	:= IMAGE(	LVL );

		---------------
    procedure	USEINFO_OFFSETS	( IDX_TYPE_LIST :in	out SEQ_TYPE )
    is		---------------
      IDX_TYPE		: TREE;
      DIM_NBR_STR		:constant	STRING	:= IMAGE(	DIM_NBR );
    begin
      POP( IDX_TYPE_LIST, IDX_TYPE );

      declare
        IDX_TYPE_SPEC	: TREE		:= D( SM_TYPE_SPEC,	IDX_TYPE );
        IDX_TYPE_NAME	: TREE		:= D( AS_NAME, IDX_TYPE );
        IDX_TYPE_DEFN	: TREE		:= D( SM_DEFN, IDX_TYPE_NAME );

      begin
        TOTAL_DIMS := TOTAL_DIMS + 1;

        if  not IS_EMPTY( IDX_TYPE_LIST	)  then								-- Encore des dimensions
	DIM_NBR := DIM_NBR + 1;
	USEINFO_OFFSETS( IDX_TYPE_LIST );

	PUT_LINE(	"SIZ_" & DIM_NBR_STR & " = $"	);
	PUT_LINE(	tab & "rd 1 " );
	PUT_LINE(	"FST_" & DIM_NBR_STR & " = $"	);
	PUT_LINE(	tab & "rd 1 " );
	PUT_LINE(	"LST_" & DIM_NBR_STR & " = $"	);
	PUT_LINE(	tab & "rd 1 " );

        else											-- Fini de parcourir les dimensions
	PUT_LINE(	"COMP_SIZ = $" );
	PUT_LINE(	tab & "rd 1 " );
	PUT_LINE(	"FST_" & DIM_NBR_STR & " = $"	);
	PUT_LINE(	tab & "rd 1 " );
	PUT_LINE(	"LST_" & DIM_NBR_STR & " = $"	);
	PUT_LINE(	tab & "rd 1 " );

        end if;

      end;
    end	USEINFO_OFFSETS;
	---------------

  begin
    DI( CD_LEVEL,	  TYPE_SPEC, INTEGER( CODI.CUR_LEVEL ) );
    DB( CD_COMPILED,  TYPE_SPEC, TRUE );

    if  CODI.DEBUG	then NEW_LINE; PUT_LINE( tab50 & "; " & TYPE_ID_STR & " UNCONSTRAINED ARRAY SUBTYPE INFO" ); end if;
    PUT_LINE( TYPE_ID_STR & " = '" & TYPE_ID_STR & "'" );
    PUT_LINE( "namespace " & TYPE_ID_STR );

    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "VAR SIZ, d" );
    PUT_LINE( tab &	"LVA" & tab & LVL_STR & ", SIZ" );
    PUT_LINE( tab &	"Sa" & tab & LVL_STR & ", use__info" );
    PUT_LINE( tab &	"LI" & tab & '1' );
    PUT_LINE( tab &	"NEG" );
    PUT_LINE( tab &	"Sd" & tab & LVL_STR & ", SIZ" );							-- SIZ=-1 UNCONSTRAINED

    PUT( "  virtual at 4" );										-- Commence apres SIZ
    if  CODI.DEBUG	then  PUT_LINE( tab50 & "; use info offsets pour acces sur array contraint" ); end if;
    NEW_LINE;

    USEINFO_OFFSETS( INDEX_SUBTYPE_S );

    PUT_LINE( "  end virtual"	);									-- Commence apres SIZ

    PUT_LINE( "end namespace"	);

  end	CODE_UNCONSTRAINED_ARRAY_DECL;
	-----------------------------



			--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^--
  procedure		  PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC	( TYPE_SPEC :TREE; CONSTRAINT :TREE := TREE_VOID )
  is			---------------------------------------

    DIM_NBR		: NATURAL			:= 0;
    LVL			: LEVEL_NUM		renames CODI.CUR_LEVEL;
    LVL_STR		:constant	STRING		:= IMAGE(	CODI.CUR_LEVEL );
    TOTAL_ELEMENTS		: NATURAL;

    BASE_TYPE		: TREE			:= D( SM_BASE_TYPE,	TYPE_SPEC	);
    COMP_TYPE		: TREE			:= D( SM_COMP_TYPE,	BASE_TYPE	);
  begin
    if  COMP_TYPE.TY = DN_PRIVATE  or  COMP_TYPE.TY = DN_L_PRIVATE  then
      COMP_TYPE := D( SM_TYPE_SPEC, COMP_TYPE );
    end if;

    declare
      COMP_SIZE_TREE	: TREE			:= TREE_VOID;
      IS_STATIC		: BOOLEAN			:= COMP_SIZE_TREE /= TREE_VOID;
      ARRAY_STATIC_SIZE	: NATURAL			:= 0;
		--------------
      function	COMP_SIZE_BITS	return NATURAL
      is		--------------
      begin
        if  COMP_TYPE.TY = DN_ACCESS  then
	return CODI.ADDR_SIZE * CODI.STORAGE_UNIT;
        elsif  COMP_TYPE.TY = DN_FLOAT  then
        -- Convention backend TLALOC : les flottants sont stockés en double 64 bits.
	return CODI.ADDR_SIZE * CODI.STORAGE_UNIT;

        elsif  COMP_TYPE.TY = DN_RECORD
           or  COMP_TYPE.TY = DN_CONSTRAINED_RECORD
        then
	-- Pilier 3.7 : composant record (contraint ou non).  La vue contrainte
	-- anonyme (p. ex. BUF(2)) ne porte pas de CD_IMPL_SIZE : lire celui du
	-- record de BASE, pose par CODE_RECORD_DECL (layout additif).
	declare
	  REC : TREE	:= COMP_TYPE;
	  RAW : INTEGER;
	begin
	  if  REC.TY = DN_CONSTRAINED_RECORD  then
	    REC := D( SM_BASE_TYPE, REC );
	  end if;

	  RAW := DI( CD_IMPL_SIZE, REC );

	  if  RAW = 0  then
	  -- Vue complete pas encore compilee (type prive, ACVC A7xxx) : la
	  -- taille n'est pas connaissable par l'expander A CE POINT du flux,
	  -- mais le symbole <rec>.size sera defini plus loin dans le FINC.
	  -- Retourner 0 : le site d'emission bascule sur le symbole (fasm
	  -- resout les references avant definition) et IS_STATIC tombe.
	    return 0;
	  end if;

	  return ( ( RAW + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT ) * CODI.STORAGE_UNIT;
	end;

        else
        -- CD_IMPL_SIZE est la taille minimale en BITS posee par le front-end
        -- (1 pour BOOLEAN, 3 pour un enumere a 7 valeurs...).  La convention
        -- de stockage TLALOC est l'octet (piege n 10) : arrondir.
	declare
	  RAW : INTEGER := DI( CD_IMPL_SIZE, COMP_TYPE );
	begin
	  return ( ( RAW + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT ) * CODI.STORAGE_UNIT;
	end;

        end if;

      end	COMP_SIZE_BITS;
	--------------


      -- Staticite d'une borne discrete pour le calcul de CD_IMPL_SIZE.
      -- Deliberement conservateur : on ne reconnait d'abord que les bornes
      -- que le code existant savait deja exploiter dans le chemin sans
      -- CONSTRAINT, c'est-a-dire les DN_NUMERIC_LITERAL avec SM_VALUE.
      -- Le code d'initialisation du descripteur reste dynamique et continue
      -- d'utiliser CODE_DISCRETE_RANGE_BOUND ; seule la decision de poser
      -- CD_IMPL_SIZE est modifiee.
      function IS_STATIC_INTEGER_BOUND ( EXP : TREE ) return BOOLEAN
      is
      begin
        return EXP /= TREE_VOID and then EXP.TY = DN_NUMERIC_LITERAL;
      end IS_STATIC_INTEGER_BOUND;

      procedure STATIC_RANGE_BOUNDS
        ( RNG       : in  TREE;
          IS_STATIC : out BOOLEAN;
          LO        : out INTEGER;
          HI        : out INTEGER )
      is
        EXP1 : TREE := TREE_VOID;
        EXP2 : TREE := TREE_VOID;
      begin
        IS_STATIC := FALSE;
        LO := 0;
        HI := -1;

        if RNG /= TREE_VOID and then RNG.TY = DN_RANGE then
          EXP1 := D( AS_EXP1, RNG );
          EXP2 := D( AS_EXP2, RNG );

          if IS_STATIC_INTEGER_BOUND( EXP1 )
            and then IS_STATIC_INTEGER_BOUND( EXP2 )
          then
            LO := DI( SM_VALUE, EXP1 );
            HI := DI( SM_VALUE, EXP2 );
            IS_STATIC := TRUE;
          end if;
        end if;
      end STATIC_RANGE_BOUNDS;

      procedure MULTIPLY_STATIC_DIMENSION
        ( LO : in INTEGER;
          HI : in INTEGER )
      is
        LEN : NATURAL;
      begin
        if HI < LO then
          LEN := 0;
        else
          LEN := NATURAL( HI - LO + 1 );
        end if;

        ARRAY_STATIC_SIZE := LEN * ARRAY_STATIC_SIZE;
      end MULTIPLY_STATIC_DIMENSION;


		----------------------------
    procedure	COMPILE_ARRAY_TYPE_DIMENSION		( IDX_TYPE_LIST, RANGE_LIST :in out SEQ_TYPE;
						  HAS_RANGES :BOOLEAN )
    is
      IDX_TYPE		: TREE;
      SRC_RANGE		: TREE		:= TREE_VOID;
      DIM_NBR_STR		:constant	STRING	:= IMAGE(	DIM_NBR+1	);
    begin
      POP( IDX_TYPE_LIST, IDX_TYPE );
      if  HAS_RANGES  then
        POP( RANGE_LIST, SRC_RANGE );
      end if;
      DIM_NBR := DIM_NBR + 1;

      if	IS_EMPTY(	IDX_TYPE_LIST )  then
        declare
	ELEMENT_SIZ		: NATURAL		:= COMP_SIZE_BITS;					-- TAILLE	EN BITS
	ELEMENT_SIZ_STR		:constant	STRING	:= IMAGE(	ELEMENT_SIZ );				-- IMAGE DE TAILLE EN BITS
        begin
	ARRAY_STATIC_SIZE := ELEMENT_SIZ;
	PUT_LINE(	"VAR _COMP_SIZ, d" );
	PUT_LINE(	"VAR _FST_" & DIM_NBR_STR & ", d" );
	PUT_LINE(	"VAR _LST_" & DIM_NBR_STR & ", d" );

	if  ELEMENT_SIZ = 0
	  and then ( COMP_TYPE.TY = DN_RECORD  or else  COMP_TYPE.TY = DN_CONSTRAINED_RECORD )
	then
		-- Pilier 3.7 / ACVC A7 : composant record dont la vue complete
		-- (type prive) n'est pas encore compilee.  Taille inconnue de
		-- l'EXPANDER mais pas de l'ASSEMBLEUR : emettre le symbole
		-- <rec>.size*8, defini plus loin dans le meme FINC (fasm est
		-- multi-passes).  Le tableau suit le chemin dynamique.
	  IS_STATIC := FALSE;

	  declare
	    REC	: TREE	:= COMP_TYPE;
	  begin
	    if  REC.TY = DN_CONSTRAINED_RECORD  then
	      REC := D( SM_BASE_TYPE, REC );
	    end if;

	    declare
	      REC_NAME	: TREE		:= D( XD_SOURCE_NAME, REC );
	      REC_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, REC_NAME ) );
	    begin
	      PUT( tab & "LI" & tab );
	      CODI.REGIONS_PATH( REC_NAME );
	      PUT_LINE( REC_STR & ".size*8" );							-- TAILLE SYMBOLIQUE (bits)
	    end;
	  end;

	else
	  PUT_LINE(	tab & "LI" & tab & ELEMENT_SIZ_STR );						-- TAILLE	D'UN ELEMENT DU TABLEAU
	end if;

	PUT_LINE(	tab & "Sd" & tab & LVL_STR & ", _COMP_SIZ" );						-- DWORD COMP_SIZ
	PUT_LINE(	tab & "Ld" & tab & LVL_STR & ", _COMP_SIZ" );						-- recharge pour MUL suivant
        end;

      else
        COMPILE_ARRAY_TYPE_DIMENSION( IDX_TYPE_LIST, RANGE_LIST, HAS_RANGES );

        PUT_LINE( "VAR _SIZ_" & DIM_NBR_STR & ", d" );
        PUT_LINE( "VAR _FST_" & DIM_NBR_STR & ", d" );
        PUT_LINE( "VAR _LST_" & DIM_NBR_STR & ", d" );

        PUT_LINE( tab & "MUL"	);
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", _SIZ_" & DIM_NBR_STR );					-- METTRE	LA TAILLE	TRANCHE A	CELLE LAISSEE PAR LE CALCUL SUR LA DIM PRECEDENTE
        PUT_LINE( tab & "Ld" & tab & LVL_STR & ", _SIZ_" & DIM_NBR_STR );					-- recharge pour MUL suivant
      end	if;

      if  HAS_RANGES  and then  SRC_RANGE /= TREE_VOID  then

        declare
          RNG_STATIC : BOOLEAN;
          RNG_LO     : INTEGER;
          RNG_HI     : INTEGER;
        begin
          STATIC_RANGE_BOUNDS( SRC_RANGE, RNG_STATIC, RNG_LO, RNG_HI );

          if RNG_STATIC and then IS_STATIC then
            MULTIPLY_STATIC_DIMENSION( RNG_LO, RNG_HI );
          else
            IS_STATIC := FALSE;
          end if;
        end;

        EXPRESSIONS.CODE_DISCRETE_RANGE_BOUND( SRC_RANGE, IS_LAST => FALSE );
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", _FST_" & DIM_NBR_STR );

        EXPRESSIONS.CODE_DISCRETE_RANGE_BOUND( SRC_RANGE, IS_LAST => TRUE );
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", _LST_" & DIM_NBR_STR );

      elsif	IDX_TYPE.TY = DN_INTEGER  then
        declare
	IDX_RANGE		: TREE		:= D( SM_RANGE, IDX_TYPE );
	RANGE_FIRST	: TREE		:= D( AS_EXP1, IDX_RANGE );
	RANGE_LAST	: TREE		:= D( AS_EXP2, IDX_RANGE );
        begin
	if  RANGE_FIRST.TY /= DN_NUMERIC_LITERAL
	or  RANGE_LAST.TY /= DN_NUMERIC_LITERAL
	then
	  IS_STATIC := FALSE;
	end if;

	EXPRESSIONS.CODE_EXP( RANGE_FIRST );
	PUT_LINE(	tab & "Sd" & tab & LVL_STR & ", _FST_" & DIM_NBR_STR );
	EXPRESSIONS.CODE_EXP( RANGE_LAST );
	PUT_LINE(	tab & "Sd" & tab & LVL_STR & ", _LST_" & DIM_NBR_STR );

	if  IS_STATIC  then
	  ARRAY_STATIC_SIZE	:= ( DI( SM_VALUE, RANGE_LAST	) + 1 - DI( SM_VALUE, RANGE_FIRST ) ) *	ARRAY_STATIC_SIZE;
	end if;
        end;

      else
        IS_STATIC := FALSE;
        PUT_LINE( "; PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC : index type non integer non traite "
                  & NODE_NAME'IMAGE( IDX_TYPE.TY ) );
      end	if;

      PUT_LINE( tab & "Ld" & tab & LVL_STR & ", _LST_" & DIM_NBR_STR );
      PUT_LINE( tab & "Ld" & tab & LVL_STR & ", _FST_" & DIM_NBR_STR );
      PUT_LINE( tab & "SUB" );
      PUT_LINE( tab & "INC" );
      PUT_LINE( tab & "CLAMP0" );

    end	COMPILE_ARRAY_TYPE_DIMENSION;
	----------------------------


		--------------------
    procedure	COMPUTE_INFO_OFFSETS	( IDX_TYPE_LIST :in	out SEQ_TYPE )
    is
      IDX_TYPE		: TREE;
      DIM_NBR_STR		:constant	STRING	:= IMAGE(	DIM_NBR+1	);
    begin
      POP( IDX_TYPE_LIST, IDX_TYPE );
      DIM_NBR := DIM_NBR + 1;

      if	IS_EMPTY(	IDX_TYPE_LIST )  then
	PUT_LINE(	"COMP_SIZ = $" );
	PUT_LINE(	tab & "rd 1 " );
	PUT_LINE(	"FST_" & DIM_NBR_STR & " = $"	);
	PUT_LINE(	tab & "rd 1 " );
	PUT_LINE(	"LST_" & DIM_NBR_STR & " = $"	);
	PUT_LINE(	tab & "rd 1 " );
      else
        COMPUTE_INFO_OFFSETS(	IDX_TYPE_LIST );

        PUT_LINE( "SIZ_" & DIM_NBR_STR & " = $" );
        PUT_LINE( tab & "rd 1 " );
        PUT_LINE( "FST_" & DIM_NBR_STR & " = $" );
        PUT_LINE( tab & "rd 1 " );
        PUT_LINE( "LST_" & DIM_NBR_STR & " = $" );
        PUT_LINE( tab & "rd 1 " );
      end	if;

    end	COMPUTE_INFO_OFFSETS;
	--------------------

  begin
--    if  COMP_TYPE.TY = DN_ACCESS  or else  COMP_TYPE.TY = DN_FLOAT  then
    if  COMP_TYPE.TY = DN_ACCESS  or else  COMP_TYPE.TY in CLASS_SCALAR  then
      IS_STATIC := TRUE;
    else
      COMP_SIZE_TREE := D( CD_IMPL_SIZE, COMP_TYPE );
      IS_STATIC := COMP_SIZE_TREE /= TREE_VOID;
    end if;

    DI( CD_LEVEL, TYPE_SPEC, INTEGER( LVL ) );

    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "VAR SIZ, d" );
    PUT_LINE( tab &	"LVA" & tab & LVL_STR & ", SIZ" );
    PUT_LINE( tab &	"Sa" & tab & LVL_STR & ", use__info" );

			-------------------
			DESCRIPTOR_ON_STACK:
    begin
      if  CONSTRAINT /= TREE_VOID  and then  CONSTRAINT.TY = DN_INDEX_CONSTRAINT  then
        declare
	IDX_TYPE_LIST	: SEQ_TYPE	:= LIST( D( SM_INDEX_SUBTYPE_S, TYPE_SPEC ) );
	RANGE_LIST	: SEQ_TYPE	:= LIST( D( AS_DISCRETE_RANGE_S, CONSTRAINT ) );
        begin
	COMPILE_ARRAY_TYPE_DIMENSION( IDX_TYPE_LIST, RANGE_LIST, TRUE );
        end;
      else
        declare
	IDX_TYPE_LIST	: SEQ_TYPE	:= LIST( D( SM_INDEX_SUBTYPE_S, TYPE_SPEC ) );
	DUMMY_LIST	: SEQ_TYPE	:= LIST( D( SM_INDEX_SUBTYPE_S, TYPE_SPEC ) );
        begin
	COMPILE_ARRAY_TYPE_DIMENSION( IDX_TYPE_LIST, DUMMY_LIST, FALSE );
        end;
      end if;

      PUT_LINE( tab	& "MUL" );
      PUT_LINE( tab	& "Sd" & tab & LVL_STR & ", SIZ" );

      if	IS_STATIC  then
        DI( CD_IMPL_SIZE,	TYPE_SPEC,  ARRAY_STATIC_SIZE	);
      end	if;

      PUT_LINE( "  virtual at 4" );									-- Commence apres SIZ
      declare
        IDX_TYPE_LIST	: SEQ_TYPE	:= LIST( D( SM_INDEX_SUBTYPE_S, TYPE_SPEC ) );
      begin
        DIM_NBR := 0;
        COMPUTE_INFO_OFFSETS(	IDX_TYPE_LIST );
      end;
      PUT_LINE( "  end virtual" );

      PUT_LINE( "end namespace" );

    end	DESCRIPTOR_ON_STACK;
	-------------------

    DB( CD_COMPILED, TYPE_SPEC, TRUE );
    end;

  end	  PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC;
	--===================================--



			---------------------------
  procedure		CODE_CONSTRAINED_ARRAY_DECL		( TYPE_DECL :TREE )
  is			---------------------------

    TYPE_NAME		: TREE			:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_NAME_STR		:constant	STRING		:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
    TYPE_SPEC		: TREE			:= D( SM_TYPE_SPEC,	TYPE_NAME	);

  begin
    if  CODI.DEBUG	then NEW_LINE; PUT_LINE( tab50 & "; array decl constrained array type info" ); end if;

    PUT_LINE( TYPE_NAME_STR &	" = '" & TYPE_NAME_STR & "'" );
    PUT_LINE( "namespace " & TYPE_NAME_STR );

    if  TYPE_DECL.TY = DN_CONSTRAINED_ARRAY_DEF  then
      PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( TYPE_SPEC, D( AS_CONSTRAINT, TYPE_DECL ) );
    else
      PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( TYPE_SPEC );
    end if;

  end	CODE_CONSTRAINED_ARRAY_DECL;
	---------------------------


		--------------
  function	FULL_TYPE_VIEW		( T :TREE )	return TREE
  is		--------------
    R	: TREE	:= T;
  begin
    loop
      if  R.TY = DN_PRIVATE  or else  R.TY = DN_L_PRIVATE  then
        R := D( SM_TYPE_SPEC, R );

      elsif  R.TY = DN_INCOMPLETE  then
        R := D( XD_FULL_TYPE_SPEC, R );

      else
        return  R;
      end if;
    end loop;

  end	FULL_TYPE_VIEW;
	--------------


			----------------
  procedure		CODE_RECORD_DECL		( TYPE_DECL :TREE )
  is			----------------

    TYPE_ID		: TREE			:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_SPEC		: TREE			:= D( SM_TYPE_SPEC,	TYPE_ID );
    TYPE_ID_STR		:constant	STRING		:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    LVL			: LEVEL_NUM		renames CODI.CUR_LEVEL;
    LVL_STR		:constant	STRING		:= IMAGE(	LVL );
    IS_STATIC		: BOOLEAN			:= TRUE;
    STATIC_SIZE		: NATURAL			:= 0;


    function  STATIC_TYPE_SIZE_BITS	( T :TREE )	return NATURAL;
    function  STATIC_RECORD_SIZE_BITS	( REC :TREE )	return NATURAL;

			------------------
    function		ROUND_STORAGE_BITS		( SIZE_BITS :NATURAL )	return NATURAL
    is			------------------
      RESULT	: NATURAL		:= SIZE_BITS;
    begin
      if  RESULT < CODI.STORAGE_UNIT  then
	RESULT := CODI.STORAGE_UNIT;
      end if;

      return  CODI.STORAGE_UNIT * ( ( RESULT + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT );

    end	ROUND_STORAGE_BITS;
	------------------


			-----------------------
    function		STATIC_RECORD_SIZE_BITS	( REC :TREE ) return NATURAL
    is			-----------------------
      REC_SPEC	: TREE		:= FULL_TYPE_VIEW( REC );
      SIZE	: NATURAL		:= 0;
      UNKNOWN	: BOOLEAN		:= FALSE;
		-----------------
      procedure	ADD_DISCRIMINANTS	( DS : TREE )
      is		-----------------
        DSCRMT_DECL_S	: SEQ_TYPE;
        DSCRMT_DECL		: TREE;

      begin
        if  DS = TREE_VOID  or else  DS = TREE_NIL  then
	  return;
        end if;

        DSCRMT_DECL_S := LIST( DS );

        while  not IS_EMPTY( DSCRMT_DECL_S )  loop
	POP( DSCRMT_DECL_S, DSCRMT_DECL );

	declare
	  DISCR_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, DSCRMT_DECL ) );
	  DISCR_ID	: TREE;
	begin
	  while  not IS_EMPTY( DISCR_ID_S )  loop
	    POP( DISCR_ID_S, DISCR_ID );

	    declare
	      DISCR_TYPE	: TREE	:= FULL_TYPE_VIEW( D( SM_OBJ_TYPE, DISCR_ID ) );
	      DISCR_SIZE	: NATURAL	:= STATIC_TYPE_SIZE_BITS( DISCR_TYPE );
	    begin
	      if  DISCR_SIZE = 0  then
	        UNKNOWN := TRUE;
	        return;
	      end if;

	      SIZE := SIZE + ROUND_STORAGE_BITS( DISCR_SIZE );
	    end;
	  end loop;
	end;
        end loop;

      end	ADD_DISCRIMINANTS;
	-----------------

		-------------
      procedure	ADD_COMP_LIST	( CL : TREE )
      is		-------------
        V_DECL_S	: SEQ_TYPE;
        V_DECL	: TREE;
      begin
        if  CL = TREE_VOID  or else  CL = TREE_NIL  then
	return;
        end if;

        V_DECL_S := LIST( D( AS_DECL_S, CL ) );

        while  not IS_EMPTY( V_DECL_S )  loop
	POP( V_DECL_S, V_DECL );

	if  V_DECL.TY /= DN_NULL_COMP_DECL  then
	  declare
	    COMP_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, V_DECL ) );
	    COMP_ID	: TREE;
	  begin
	    while  not IS_EMPTY( COMP_ID_S )  loop
	      POP( COMP_ID_S, COMP_ID );

	      declare
	        COMP_TYPE	: TREE	:= FULL_TYPE_VIEW( D( SM_OBJ_TYPE, COMP_ID ) );
	        COMP_SIZE	: NATURAL	:= STATIC_TYPE_SIZE_BITS( COMP_TYPE );
	      begin
	        if  COMP_SIZE = 0  then
		UNKNOWN := TRUE;
		return;
	        end if;

	        SIZE := SIZE + ROUND_STORAGE_BITS( COMP_SIZE );
	      end;
	    end loop;
	  end;
	end if;
        end loop;

	--  Pilier 3.7, layout ADDITIF : les champs de TOUTES les variantes
	--  sont poses bout a bout par CODE_RECORD_DECL ; la taille statique
	--  est donc la somme (coherence avec TRAITER_LES_CHAMPS).
        declare
	VP	: TREE	:= D( AS_VARIANT_PART, CL );
        begin
	if  VP /= TREE_VOID  and then  VP /= TREE_NIL  then
	  declare
	    VAR_S	: SEQ_TYPE	:= LIST( D( AS_VARIANT_S, VP ) );
	    VAR_E	: TREE;
	  begin
	    while  not IS_EMPTY( VAR_S )  loop
	      POP( VAR_S, VAR_E );

	      if  VAR_E.TY = DN_VARIANT  then
	        ADD_COMP_LIST( D( AS_COMP_LIST, VAR_E ) );

	        if  UNKNOWN  then
	          return;
	        end if;
	      end if;
	    end loop;
	  end;
	end if;
        end;

      end	ADD_COMP_LIST;
	-------------

    begin
      if  REC_SPEC.TY /= DN_RECORD  then
	return 0;
      end if;

      if  REPRESENTED_ITEMS.HAS_RECORD_REP( REC_SPEC )  then
	return NATURAL( REPRESENTED_ITEMS.REPRESENTED_RECORD_SIZE_BITS( REC_SPEC ) );
      end if;

      if  D( SM_SIZE, REC_SPEC ) /= TREE_VOID  then
	return NATURAL( DI( SM_SIZE, REC_SPEC ) );
      end if;

      ADD_DISCRIMINANTS( D( SM_DISCRIMINANT_S, REC_SPEC ) );
      if  UNKNOWN  then
	return 0;
      end if;

      ADD_COMP_LIST( D( SM_COMP_LIST, REC_SPEC ) );

      if  UNKNOWN  then
	return 0;
      end if;

      if  SIZE /= 0  then
	DI( CD_IMPL_SIZE, REC_SPEC, INTEGER( SIZE ) );
      end if;

      return SIZE;

    end	STATIC_RECORD_SIZE_BITS;
	-----------------------


 			-----------------------
    function		STATIC_INDEX_LENGTH		( IDX_TYPE : TREE ) return NATURAL
    is			-----------------------
      IDX_SPEC : TREE := FULL_TYPE_VIEW( IDX_TYPE );
      IDX_RANGE : TREE;
      FST       : TREE;
      LST       : TREE;
    begin
      if  IDX_SPEC = TREE_VOID  or else  IDX_SPEC = TREE_NIL  then
	return 0;
      end if;

      if  IDX_SPEC.TY = DN_INTEGER  or else  IDX_SPEC.TY = DN_ENUMERATION  then
	IDX_RANGE := D( SM_RANGE, IDX_SPEC );

	if  IDX_RANGE = TREE_VOID  or else  IDX_RANGE = TREE_NIL  then
	  return 0;
	end if;

	FST := D( AS_EXP1, IDX_RANGE );
	LST := D( AS_EXP2, IDX_RANGE );

	--  Meme perimetre que PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC : bornes
	--  litterales simples.  C'est suffisant pour les sous-types statiques
	--  comme FILE_NAME_BUFFER et pour le cas ACVC A83041D.  Les bornes
	--  dynamiques doivent continuer a rendre le record non statique.
	if  FST.TY = DN_NUMERIC_LITERAL  and then  LST.TY = DN_NUMERIC_LITERAL  then
	  declare
	    LO : INTEGER := DI( SM_VALUE, FST );
	    HI : INTEGER := DI( SM_VALUE, LST );
	  begin
	    if  HI < LO  then
	      return 0;
	    else
	      return NATURAL( HI + 1 - LO );
	    end if;
	  end;
	else
	  return 0;
	end if;
      else
	return 0;
      end if;
    end	STATIC_INDEX_LENGTH;
	-------------------


			----------------------------------
    function		STATIC_CONSTRAINED_ARRAY_SIZE_BITS	( ARR : TREE ) return NATURAL
    is			----------------------------------
      ARR_SPEC  : TREE := FULL_TYPE_VIEW( ARR );
      BASE_TYPE : TREE;
      COMP_TYPE : TREE;
      COMP_SIZE : NATURAL;
      IDX_S     : SEQ_TYPE;
      IDX_TYPE  : TREE;
      LEN       : NATURAL;
      TOTAL     : NATURAL;
    begin
      if  ARR_SPEC = TREE_VOID  or else  ARR_SPEC = TREE_NIL
      or else  ARR_SPEC.TY /= DN_CONSTRAINED_ARRAY
      then
	return 0;
      end if;

      if  D( CD_IMPL_SIZE, ARR_SPEC ) /= TREE_VOID  then
	return NATURAL( DI( CD_IMPL_SIZE, ARR_SPEC ) );
      end if;

      BASE_TYPE := D( SM_BASE_TYPE, ARR_SPEC );
      COMP_TYPE := FULL_TYPE_VIEW( D( SM_COMP_TYPE, BASE_TYPE ) );
      COMP_SIZE := STATIC_TYPE_SIZE_BITS( COMP_TYPE );

      if  COMP_SIZE = 0  then
	return 0;
      end if;

      TOTAL := COMP_SIZE;
      IDX_S := LIST( D( SM_INDEX_SUBTYPE_S, ARR_SPEC ) );

      while  not IS_EMPTY( IDX_S )  loop
	POP( IDX_S, IDX_TYPE );
	LEN := STATIC_INDEX_LENGTH( IDX_TYPE );

	if  LEN = 0  then
	  return 0;
	end if;

	TOTAL := TOTAL * LEN;
      end loop;

      DI( CD_IMPL_SIZE, ARR_SPEC, INTEGER( TOTAL ) );
      return TOTAL;

    end	STATIC_CONSTRAINED_ARRAY_SIZE_BITS;
	----------------------------------


			---------------------
    function		STATIC_TYPE_SIZE_BITS	( T : TREE )	return NATURAL
    is			---------------------
      TS : TREE := FULL_TYPE_VIEW( T );
    begin
      if  TS = TREE_VOID  or else  TS = TREE_NIL  then
        return  0;
      end if;

      if  TS.TY = DN_ACCESS  then
        return  CODI.ADDR_SIZE * CODI.STORAGE_UNIT;

      elsif  TS.TY = DN_RECORD  then
        return  STATIC_RECORD_SIZE_BITS( TS );

      elsif  TS.TY = DN_CONSTRAINED_RECORD  then
	-- Pilier 3.7 : vue contrainte (nommee ou anonyme) -> taille du record
	-- de base (layout additif : la contrainte ne change pas la taille).
        return  STATIC_RECORD_SIZE_BITS( D( SM_BASE_TYPE, TS ) );

      elsif  TS.TY = DN_CONSTRAINED_ARRAY  then

put_line( "; STSB" );

        return  STATIC_CONSTRAINED_ARRAY_SIZE_BITS( TS );

      elsif  TS.TY = DN_ARRAY  then
        return  0;

      elsif  TS.TY in CLASS_SCALAR  or else  TS.TY in CLASS_CONSTRAINED  then
        if  D( CD_IMPL_SIZE, TS ) /= TREE_VOID  then
	return  NATURAL( DI( CD_IMPL_SIZE, TS ) );
        else
	return  0;
        end if;

      else
        return 0;
      end if;

    end	STATIC_TYPE_SIZE_BITS;
	-----------------------

  begin
				-- Resolve private/incomplete	to full type
    if  TYPE_SPEC.TY = DN_L_PRIVATE
    or  TYPE_SPEC.TY = DN_PRIVATE
    then
      TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
    elsif	 TYPE_SPEC.TY = DN_INCOMPLETE	 then
      TYPE_SPEC := D( XD_FULL_TYPE_SPEC, TYPE_SPEC );
    end if;

    if  REPRESENTED_ITEMS.HAS_RECORD_REP( TYPE_SPEC )  then
      REPRESENTED_ITEMS.CODE_REPRESENTED_RECORD_DECL( TYPE_ID, TYPE_SPEC );
      return;
    end if;

    DI( CD_LEVEL,	  TYPE_SPEC, INTEGER( CODI.CUR_LEVEL ) );
    DB( CD_COMPILED,  TYPE_SPEC, TRUE );

    if  CODI.DEBUG	then NEW_LINE; PUT_LINE( tab50 & "; " & TYPE_ID_STR & " RECORD TYPE INFO" ); end if;

    PUT_LINE( TYPE_ID_STR & " = '" & TYPE_ID_STR & "'" );
    PUT_LINE( "namespace " & TYPE_ID_STR );

    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "VAR SIZ, d" );
    PUT_LINE( tab &	"LVA" & tab & LVL_STR & ", SIZ" );
    PUT_LINE( tab &	"Sa" & tab & LVL_STR & ", use__info" );

			------------------------
			INSERE_LES_DISCRIMINANTS:
    declare
      DSCRMT_DECL_S		: SEQ_TYPE	:= LIST( D( AS_DSCRMT_DECL_S,	TYPE_DECL	) );
      DSCRMT_DECL		: TREE;
    begin
      while  not IS_EMPTY( DSCRMT_DECL_S )  loop
        POP( DSCRMT_DECL_S, DSCRMT_DECL	);
        declare
	DISCRIMINANT_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S,	DSCRMT_DECL ) );
	DISCRIMINANT_ID	: TREE;
        begin
	while  not IS_EMPTY( DISCRIMINANT_ID_S )  loop
	  POP( DISCRIMINANT_ID_S, DISCRIMINANT_ID );
	  declare
	    DISCRIMINANT_TYPE_SPEC	: TREE		:= D( SM_OBJ_TYPE, DISCRIMINANT_ID );
	    DISCRIMINANT_TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, DISCRIMINANT_TYPE_SPEC );
	    DISCRIMINANT_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, DISCRIMINANT_ID ) );
	    DISCRIMINANT_TYPE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, DISCRIMINANT_TYPE_NAME ) );
	  begin
	    PUT( "USEINFO " & LVL_STR & ", " & DISCRIMINANT_STR & ", " );
	    PUT( tab & "La " & IMAGE( DI( CD_LEVEL, DISCRIMINANT_TYPE_SPEC ) ) & ", " );
	    REGIONS_PATH( D( XD_SOURCE_NAME, DISCRIMINANT_TYPE_SPEC ) );
	    PUT_LINE( DISCRIMINANT_TYPE_STR & ".use__info" );
	  end;
	end loop;
        end;
      end	loop;
    end	INSERE_LES_DISCRIMINANTS;
	------------------------

			-----------------
			INSERE_LES_CHAMPS:
    declare
		-----------------
      procedure	INSERER_COMP_LIST		( CL : TREE )
      is		-----------------
        V_DECL_S		: SEQ_TYPE;
        V_DECL		: TREE;
      begin
        if  CL = TREE_VOID  then
	return;
        end if;

        V_DECL_S := LIST( D( AS_DECL_S, CL ) );

      -- 1. Champs ordinaires de CE comp_list
        while  not IS_EMPTY( V_DECL_S )  loop
	POP( V_DECL_S, V_DECL );

	if  V_DECL.TY /= DN_NULL_COMP_DECL  then

	  declare
	    COMP_ID_S	: SEQ_TYPE := LIST( D( AS_SOURCE_NAME_S, V_DECL ) );
	    COMP_ID	: TREE;
	    COMP_TYPE	: TREE;
	  begin
	    while  not IS_EMPTY( COMP_ID_S )  loop
	      POP( COMP_ID_S, COMP_ID );

	      COMP_TYPE := D( SM_OBJ_TYPE, COMP_ID );

	      if  COMP_TYPE.TY = DN_PRIVATE  or else  COMP_TYPE.TY = DN_L_PRIVATE  then
	        COMP_TYPE := D( SM_TYPE_SPEC, COMP_TYPE );
	      end if;
			----------------------------
			PROCESS_INSERT_ONE_COMPONENT:
	      declare
	        COMP_TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, COMP_TYPE );
	        COMP_TYPE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, COMP_TYPE_NAME ) );
	        COMP_ID_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, COMP_ID ) );

	      begin

	        if  COMP_TYPE.TY = DN_CONSTRAINED_ARRAY  then
		if  not DB( CD_COMPILED, COMP_TYPE )  then
		  PUT_LINE( COMP_ID_STR & " = '" & COMP_ID_STR & "'" );
		  PUT_LINE( " namespace " & COMP_TYPE_STR );
		  PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( COMP_TYPE );
		end if;

		PUT( "USEINFO " & LVL_STR & ", " & COMP_ID_STR & ", " );
		PUT( tab & "La " & IMAGE( DI( CD_LEVEL, COMP_TYPE ) ) & ", " );
		REGIONS_PATH( D( XD_SOURCE_NAME, D( SM_TYPE_SPEC, COMP_TYPE_NAME ) ) );
		PUT_LINE( COMP_TYPE_STR & ".use__info" );

	        else
		PUT( "USEINFO " & LVL_STR & ", " & COMP_ID_STR & ", " );
		PUT( tab & "La " & IMAGE( DI( CD_LEVEL, COMP_TYPE ) ) & ", " );
		REGIONS_PATH( COMP_TYPE_NAME );
		PUT_LINE( COMP_TYPE_STR & ".use__info" );
	        end if;



                  -- calcul IS_STATIC
--	        if  COMP_TYPE.TY in CLASS_SCALAR  or else  COMP_TYPE.TY in CLASS_CONSTRAINED  then
--		if  D( CD_IMPL_SIZE, COMP_TYPE ) = TREE_VOID  then
--		  IS_STATIC := FALSE;
--		end if;

--	        elsif  COMP_TYPE.TY = DN_RECORD  then
--		if  not IS_EMPTY( LIST( D( SM_DISCRIMINANT_S, COMP_TYPE ) ) )
--		  and then  D( SM_SIZE, COMP_TYPE ) = TREE_VOID
--		then
--		  IS_STATIC := FALSE;
--		end if;
--	        elsif  COMP_TYPE.TY = DN_ACCESS  then
--		null;

--	        else
--		IS_STATIC := FALSE;
--	        end if;

	        if  STATIC_TYPE_SIZE_BITS( COMP_TYPE ) = 0  then
put_line( "; NON STATIQUE " & NODE_NAME'IMAGE( COMP_TYPE.TY ) );
		IS_STATIC := FALSE;
	        end if;


	      end		PROCESS_INSERT_ONE_COMPONENT;
			----------------------------
              end loop;
            end;
	end if;
        end loop;

      -- 2. Champs contenus dans les variantes de CE comp_list
        declare
	VP	: TREE	:= D( AS_VARIANT_PART, CL );
        begin
	if  VP /= TREE_VOID  and then  VP /= TREE_NIL  then
	  declare
	    VAR_S		: SEQ_TYPE	:= LIST( D( AS_VARIANT_S, VP ) );
	    VAR_E		: TREE;
	  begin
	    while  not IS_EMPTY( VAR_S )  loop
	      POP( VAR_S, VAR_E );

	      if  VAR_E.TY = DN_VARIANT  then
	        INSERER_COMP_LIST( D( AS_COMP_LIST, VAR_E ) );
	      end if;
	    end loop;
	  end;
	end if;
        end;

      end	INSERER_COMP_LIST;
	-----------------
    begin
      INSERER_COMP_LIST( D( SM_COMP_LIST, TYPE_SPEC ) );

    end	INSERE_LES_CHAMPS;
	-----------------

    if  IS_STATIC  then
      PUT( "virtual at 0" );
      if  CODI.DEBUG  then  PUT( tab50 & "; calcul des offsets statiques" ); end if;
      NEW_LINE;
    end	if;

			-------------------------
			TRAITER_LES_DISCRIMINANTS:
    declare
      DSCRMT_DECL_S		: SEQ_TYPE	:= LIST( D( AS_DSCRMT_DECL_S,	TYPE_DECL	) );
      DSCRMT_DECL		: TREE;
    begin
      while  not IS_EMPTY( DSCRMT_DECL_S )  loop
        POP( DSCRMT_DECL_S, DSCRMT_DECL	);
        declare
	DISCRIMINANT_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S,	DSCRMT_DECL ) );
	DISCR_TYPE_DEFN	: TREE		:= D( SM_DEFN, D( AS_NAME, DSCRMT_DECL ) );
	DISCR_TYPE_SPEC	: TREE		:= D( SM_TYPE_SPEC,	DISCR_TYPE_DEFN );
	DISCRIMINANT_ID	: TREE;
	SIZE_CHAR		: CHARACTER	:= 'x';
        begin
	if  TYPE_SPEC.TY = DN_INTEGER	 then
	  SIZE_CHAR := OPER_SIZ_CHAR(	TYPE_SPEC	);
	end if;
	while  not IS_EMPTY( DISCRIMINANT_ID_S )  loop
	  POP( DISCRIMINANT_ID_S, DISCRIMINANT_ID );

	  declare
	    DISCR_TYPE	: TREE		:= D( SM_OBJ_TYPE, DISCRIMINANT_ID );
	    DISCR_SIZE	: NATURAL;
	  begin
	    if  DISCR_TYPE.TY = DN_PRIVATE  or else  DISCR_TYPE.TY = DN_L_PRIVATE  then
	      DISCR_TYPE := D( SM_TYPE_SPEC, DISCR_TYPE );
	    end if;

	    DISCR_SIZE := DI( CD_IMPL_SIZE, DISCR_TYPE );

	    if DISCR_SIZE < CODI.STORAGE_UNIT then
	      DISCR_SIZE := CODI.STORAGE_UNIT;
	    end if;

	    PUT_LINE( "STATOFS " & PRINT_NAME( D( LX_SYMREP, DISCRIMINANT_ID ) ) & ','
			& INTEGER'IMAGE( ( DISCR_SIZE + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT ) );

	    STATIC_SIZE := STATIC_SIZE
		+ CODI.STORAGE_UNIT * ( ( DISCR_SIZE + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT );
	  end;

	end loop;
        end;
      end	loop;

    end		TRAITER_LES_DISCRIMINANTS;
		-------------------------

			------------------
			TRAITER_LES_CHAMPS:
    declare
		-----------------
      procedure	TRAITER_COMP_LIST	( CL : TREE )
      is		-----------------
        V_DECL_S		: SEQ_TYPE	:= LIST( D( AS_DECL_S, CL ) );
        V_DECL		: TREE;
      begin

        while  not IS_EMPTY( V_DECL_S )  loop
	POP( V_DECL_S, V_DECL	);

	if  V_DECL.TY /= DN_NULL_COMP_DECL  then

			----------------
			CHAMPS_REGULIERS:
	  declare
	    COMP_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S,	V_DECL ) );
	    COMP_ID	: TREE;
	    COMP_TYPE	: TREE;

	  begin
	    while  not IS_EMPTY( COMP_ID_S )  loop
	      POP( COMP_ID_S, COMP_ID );
	      COMP_TYPE := D( SM_OBJ_TYPE, COMP_ID );
	      if  COMP_TYPE.TY = DN_PRIVATE  or  COMP_TYPE.TY = DN_L_PRIVATE  then
	        COMP_TYPE := D( SM_TYPE_SPEC, COMP_TYPE );
	      end if;

	      declare
	        COMP_TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, COMP_TYPE );
	        COMP_TYPE_STR	:constant	STRING	:= '_'  & PRINT_NAME( D( LX_SYMREP, COMP_TYPE_NAME ) );
	        COMP_ID_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, COMP_ID ) );
	        COMP_SIZE		: NATURAL;

	      begin
	        if  IS_STATIC  then
--	          if  COMP_TYPE.TY = DN_ACCESS  then
--		  COMP_SIZE := CODI.ADDR_SIZE * CODI.STORAGE_UNIT;  -- bits : 8 octets sur x86_64
--	          else
--		  COMP_SIZE := DI( CD_IMPL_SIZE, COMP_TYPE );
--	          end if;

		COMP_SIZE := STATIC_TYPE_SIZE_BITS( COMP_TYPE );
		if  COMP_SIZE = 0  then
		  PUT_LINE( "; OFFSET NON STATIQUE A FAIRE ; taille inconnue pour " & COMP_ID_STR );
		  raise  PROGRAM_ERROR;
		end if;


	          if  COMP_SIZE < CODI.STORAGE_UNIT  then
		  COMP_SIZE := CODI.STORAGE_UNIT;
	          end if;
	          PUT_LINE( "STATOFS " & COMP_ID_STR & ','
			& INTEGER'IMAGE( ( COMP_SIZE + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT ) );
	          STATIC_SIZE := STATIC_SIZE
			   + CODI.STORAGE_UNIT * ( ( COMP_SIZE + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT );

	        else
	          PUT_LINE( "; OFFSET NON STATIQUE A FAIRE" );
	        end if;
	      end;
	    end loop;
            end		CHAMPS_REGULIERS;
			----------------
	end if;
        end loop;
			----------------
			CHAMPS_VARIANTES:
        declare
	VP	: TREE := D( AS_VARIANT_PART, CL );
        begin
	if  VP /= TREE_VOID  and then  VP /= TREE_NIL  then
	  declare
	    VAR_S		: SEQ_TYPE	:= LIST( D( AS_VARIANT_S, VP ) );
	    VAR_E		: TREE;
	  begin
	    while  not IS_EMPTY( VAR_S )  loop
	      POP( VAR_S, VAR_E );

	      if  VAR_E.TY = DN_VARIANT  then
	        TRAITER_COMP_LIST( D( AS_COMP_LIST, VAR_E ) );
	      end if;
	    end loop;
	  end;
	end if;
        end		CHAMPS_VARIANTES;
			----------------

      end	TRAITER_COMP_LIST;
	-----------------

    begin
      TRAITER_COMP_LIST( D( SM_COMP_LIST, TYPE_SPEC ) );

      if	IS_STATIC	 then
        PUT_LINE( "size = $" );
        PUT_LINE( "end virtual" );
        PUT_LINE( tab & "LI" & tab & " size*" & IMAGE( CODI.STORAGE_UNIT ) );
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", SIZ" );
        DI( CD_IMPL_SIZE, TYPE_SPEC, STATIC_SIZE );
      end	if;

      if  D( SM_SIZE, TYPE_SPEC ) /= TREE_VOID  then
        DI( CD_IMPL_SIZE, TYPE_SPEC, DI( SM_SIZE, TYPE_SPEC ) );
      end if;

    end		TRAITER_LES_CHAMPS;
		------------------

    PUT_LINE( "end namespace"	);

  end	CODE_RECORD_DECL;
	----------------


  function ROOT_RECORD ( T : TREE ) return TREE is
    R : TREE := FULL_TYPE_VIEW( T );
  begin
    while R.TY = DN_CONSTRAINED_RECORD loop
      R := FULL_TYPE_VIEW( D( SM_BASE_TYPE, R ) );
    end loop;

    return R;
  end ROOT_RECORD;

		----------------------------
  procedure	CODE_CONSTRAINED_RECORD_DECL	( TYPE_NAME : TREE; TYPE_SPEC : TREE )
  is
    TYPE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
    LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );


  BASE_REC  : TREE := ROOT_RECORD( TYPE_SPEC );
  BASE_NAME : TREE := D( XD_SOURCE_NAME, BASE_REC );
  BASE_STR  : constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, BASE_NAME ) );

  procedure EMIT_BASE_PREFIX is
  begin
    REGIONS_PATH( BASE_NAME );
    PUT( BASE_STR );
  end EMIT_BASE_PREFIX;

  procedure EMIT_ALIAS ( NAME : STRING ) is
  begin
    PUT( NAME & " = " );
    EMIT_BASE_PREFIX;
    PUT_LINE( "." & NAME );
  end EMIT_ALIAS;

  procedure EMIT_COMP_LIST_ALIASES ( CL : TREE ) is
    V_DECL_S : SEQ_TYPE;
    V_DECL   : TREE;
  begin
    if CL = TREE_VOID or else CL = TREE_NIL then
      return;
    end if;

    V_DECL_S := LIST( D( AS_DECL_S, CL ) );

    while not IS_EMPTY( V_DECL_S ) loop
      POP( V_DECL_S, V_DECL );

      if V_DECL.TY /= DN_NULL_COMP_DECL then
        declare
          COMP_ID_S : SEQ_TYPE := LIST( D( AS_SOURCE_NAME_S, V_DECL ) );
          COMP_ID   : TREE;
        begin
          while not IS_EMPTY( COMP_ID_S ) loop
            POP( COMP_ID_S, COMP_ID );
            EMIT_ALIAS( PRINT_NAME( D( LX_SYMREP, COMP_ID ) ) );
          end loop;
        end;
      end if;
    end loop;

    declare
      VP : TREE := D( AS_VARIANT_PART, CL );
    begin
      if VP /= TREE_VOID and then VP /= TREE_NIL then
        declare
          VAR_S : SEQ_TYPE := LIST( D( AS_VARIANT_S, VP ) );
          VAR_E : TREE;
        begin
          while not IS_EMPTY( VAR_S ) loop
            POP( VAR_S, VAR_E );

            if VAR_E.TY = DN_VARIANT then
              EMIT_COMP_LIST_ALIASES( D( AS_COMP_LIST, VAR_E ) );
            end if;
          end loop;
        end;
      end if;
    end;
  end EMIT_COMP_LIST_ALIASES;

begin
  if BASE_REC.TY /= DN_RECORD then
    PUT_LINE( "; CODE_CONSTRAINED_RECORD_DECL : base non record "
            & NODE_NAME'IMAGE( BASE_REC.TY ) );
    raise PROGRAM_ERROR;
  end if;

  DI( CD_LEVEL, TYPE_SPEC, INTEGER( CODI.CUR_LEVEL ) );
  DB( CD_COMPILED, TYPE_SPEC, TRUE );

  if D( CD_IMPL_SIZE, BASE_REC ) /= TREE_VOID then
    DI( CD_IMPL_SIZE, TYPE_SPEC, DI( CD_IMPL_SIZE, BASE_REC ) );
  end if;

--  if D( CD_ALIGNMENT, BASE_REC ) /= TREE_VOID then		-- A VOIR
--    DI( CD_ALIGNMENT, TYPE_SPEC, DI( CD_ALIGNMENT, BASE_REC ) );
--  end if;

  if CODI.DEBUG then
    NEW_LINE;
    PUT_LINE( tab50 & "; " & TYPE_STR & " CONSTRAINED RECORD VIEW" );
  end if;

  PUT_LINE( TYPE_STR & " = '" & TYPE_STR & "'" );
  PUT_LINE( "namespace " & TYPE_STR );

  PUT( "use__info = " );
  EMIT_BASE_PREFIX;
  PUT_LINE( ".use__info" );

  PUT( "SIZ = " );
  EMIT_BASE_PREFIX;
  PUT_LINE( ".SIZ" );

  PUT( "size = " );
  EMIT_BASE_PREFIX;
  PUT_LINE( ".size" );

  -- Discriminants du record racine.
  declare
    DSCRMT_DECL_S : SEQ_TYPE := LIST( D( SM_DISCRIMINANT_S, BASE_REC ) );
    DSCRMT_DECL   : TREE;
  begin
    while not IS_EMPTY( DSCRMT_DECL_S ) loop
      POP( DSCRMT_DECL_S, DSCRMT_DECL );

      declare
        DISCR_ID_S : SEQ_TYPE := LIST( D( AS_SOURCE_NAME_S, DSCRMT_DECL ) );
        DISCR_ID   : TREE;
      begin
        while not IS_EMPTY( DISCR_ID_S ) loop
          POP( DISCR_ID_S, DISCR_ID );
          EMIT_ALIAS( PRINT_NAME( D( LX_SYMREP, DISCR_ID ) ) );
        end loop;
      end;
    end loop;
  end;

  -- Composants ordinaires et variants du record racine.
  EMIT_COMP_LIST_ALIASES( D( SM_COMP_LIST, BASE_REC ) );

  PUT_LINE( "end namespace" );

  end	CODE_CONSTRAINED_RECORD_DECL;
	----------------------------


				----------------
  procedure			CODE_ACCESS_DECL		( TYPE_DECL :TREE )
  is				----------------
    TYPE_ID		: TREE		:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_SPEC		: TREE		:= D( SM_TYPE_SPEC, TYPE_ID );
    TYPE_STR		: constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    RAW_DESIG_TYPE		: TREE		:= D( SM_DESIG_TYPE, TYPE_SPEC );
    DESIG_TYPE		: TREE		:= RAW_DESIG_TYPE;
    DESIG_IS_FORWARD	: BOOLEAN		:= FALSE;
    LVL_STR		:constant STRING	:= IMAGE( CODI.CUR_LEVEL );

  begin
    DI( CD_LEVEL,      TYPE_SPEC, INTEGER( CODI.CUR_LEVEL ) );
    DB( CD_COMPILED,   TYPE_SPEC, TRUE );

--  Le type access lui-même est complet immédiatement :
  --  sa représentation est toujours un pointeur machine.
  --  En revanche, le type désigné peut encore être une vue privée
  --  ou un incomplete.

    while  DESIG_TYPE.TY = DN_PRIVATE  or else  DESIG_TYPE.TY = DN_L_PRIVATE  loop
      if  D( SM_TYPE_SPEC, DESIG_TYPE ) = TREE_VOID  then
        exit;
      end if;

      DESIG_TYPE := D( SM_TYPE_SPEC, DESIG_TYPE );
    end loop;

    --  Si le type désigné est incomplet, l'access type est légalement
    --  déclaré avant le full type. On utilise alors le full type comme
    --  source du use_info, mais sans le marquer compilé.
    if  DESIG_TYPE.TY = DN_INCOMPLETE  then
			--------------------
			ACCESS_TO_INCOMPLETE:
      declare
        FULL_DESIG_TYPE : TREE := D( XD_FULL_TYPE_SPEC, DESIG_TYPE );
      begin
        if  FULL_DESIG_TYPE /= TREE_VOID  then
          DESIG_TYPE := FULL_DESIG_TYPE;

          --  Le full type sera codé plus tard dans la même partie déclarative.
          --  On initialise seulement son niveau pour permettre la référence
          --  forward à CELL.use__info.
          DI( CD_LEVEL, DESIG_TYPE, INTEGER( CODI.CUR_LEVEL ) );
        end if;
      end		ACCESS_TO_INCOMPLETE;
		--------------------
    end if;

    if  DESIG_TYPE /= TREE_VOID
	and then DESIG_TYPE.TY /= DN_PRIVATE
	and then DESIG_TYPE.TY /= DN_L_PRIVATE
	and then DESIG_TYPE.TY /= DN_INCOMPLETE
    then
put_line( "; CODE_ACCESS_DECL cd_level void ? " & boolean'image( D( CD_LEVEL, DESIG_TYPE )= TREE_VOID ) );
      if  D( CD_LEVEL, DESIG_TYPE ).PT = P  and then  D( CD_LEVEL, DESIG_TYPE ).TY = DN_VIRGIN  then
      --  Cas : access vers un full type connu sémantiquement,
      --  mais déclaré/codé plus loin dans la même région.

put_line( "; CODE_ACCESS_DECL cd_level rempli" );

        DI( CD_LEVEL, DESIG_TYPE, INTEGER( CODI.CUR_LEVEL ) );
        DESIG_IS_FORWARD := TRUE;
      end if;
    end if;

    if  CODI.DEBUG  then
      NEW_LINE;
      PUT_LINE( tab50 & "; " & TYPE_STR & " ACCESS TYPE INFO" );
    end if;

    PUT_LINE( TYPE_STR & " = '" & TYPE_STR & "'" );
    PUT_LINE( "namespace " & TYPE_STR );

    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "VAR SIZ, d" );
    PUT_LINE( tab & "LVA" & tab & LVL_STR & ", SIZ" );
    PUT_LINE( tab & "Sa"  & tab & LVL_STR & ", use__info" );
    PUT_LINE( tab & "LI"  & tab & IMAGE( CODI.ADDR_SIZE * CODI.STORAGE_UNIT ) );
    PUT_LINE( tab & "Sd"  & tab & LVL_STR & ", SIZ" );

    PUT_LINE( "VAR DESIG__u, q" );

    if  DESIG_TYPE.TY = DN_PRIVATE  or else  DESIG_TYPE.TY = DN_L_PRIVATE
	or else  DESIG_TYPE.TY = DN_INCOMPLETE  or else  DESIG_TYPE = TREE_VOID
    then
    --  Patron désigné encore indisponible.
    --  Suffisant pour les déclarations pures de A33003A.
      PUT_LINE( tab & "LI" & tab & "0" );

    else
      declare
        DESIG_NAME	: TREE		:= D( XD_SOURCE_NAME, DESIG_TYPE );
        DESIG_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, DESIG_NAME ) );
        DESIG_LVL	:constant INTEGER	:= DI( CD_LEVEL, DESIG_TYPE );

      begin
        if  DESIG_IS_FORWARD  then
         --  Important : ne pas faire La ..., use__info ici.
         --  Le code de TA est exécuté avant l'initialisation de TD.use__info.
         --  On stocke donc directement le pointeur vers le bloc use_info.
	if  DESIG_TYPE.TY = DN_ENUMERATION  then
	  PUT( tab & "LCA" & tab );
	  REGIONS_PATH( DESIG_NAME );
	  PUT_LINE( DESIG_STR & ".SIZ" );
	else
	  PUT( tab & "LVA" & tab & IMAGE( DESIG_LVL ) & ", " );
	  REGIONS_PATH( DESIG_NAME );
	  PUT_LINE( DESIG_STR & ".SIZ" );
	end if;

        else
	PUT( tab & "La " & IMAGE( DI( CD_LEVEL, DESIG_TYPE ) ) & ", " );
	REGIONS_PATH( DESIG_NAME );
	PUT_LINE( DESIG_STR & ".use__info" );
        end if;
      end;
    end if;

    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", DESIG__u" );
    PUT_LINE( "end namespace" );

  end	CODE_ACCESS_DECL;
	----------------



				--^^^^^^^^^^^^^^^^^--
  procedure			  CODE_SUBTYPE_DECL		( SUBTYPE_DECL :TREE )
  is				---------------------

    SUBTYPE_ID		: TREE		:= D( AS_SOURCE_NAME, SUBTYPE_DECL) ;
    TYPE_SPEC		: TREE		:= D( SM_TYPE_SPEC,	SUBTYPE_ID );
    SUBTYPE_STR		:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, SUBTYPE_ID	) );
    LVL_STR		:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
  begin
    if  TYPE_SPEC.TY = DN_PRIVATE  or else  TYPE_SPEC.TY = DN_L_PRIVATE  then
      if  CODI.DEBUG  then
        PUT_LINE( "; CODE_SUBTYPE_DECL : skip PRIVATE subtype " & SUBTYPE_STR & " (deferred to full type)" );
      end if;
      return;

    elsif  TYPE_SPEC.TY = DN_INCOMPLETE  then
      if  CODI.DEBUG  then
        PUT_LINE( "; CODE_SUBTYPE_DECL : skip INCOMPLETE subtype " & SUBTYPE_STR & " (deferred to full type)" );
      end if;
      return;
    end if;

    DI( CD_LEVEL,	  TYPE_SPEC, INTEGER( CODI.CUR_LEVEL ) );
    DB( CD_COMPILED,  TYPE_SPEC, TRUE );

    if  TYPE_SPEC.TY = DN_INTEGER  then
				---------------
				INTEGER_SUBTYPE:
      declare
        SIZE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( TYPE_SPEC );
        INT_RANGE		: TREE		:= D( SM_RANGE, TYPE_SPEC );
        EXP_FST		: TREE		:= D( AS_EXP1, INT_RANGE );
        EXP_LST		: TREE		:= D( AS_EXP2, INT_RANGE );
        LVL_STR		:constant	STRING	:= IMAGE(	CODI.CUR_LEVEL );
        BASE_TYPE		: TREE		:= D( SM_BASE_TYPE, TYPE_SPEC );
        BASETYPE_STR	:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP,
					   D( XD_SOURCE_NAME, BASE_TYPE ) ) );
      begin
        if  CODI.DEBUG  then NEW_LINE; PUT_LINE( tab50 & "; " & SUBTYPE_STR & " INTEGER SUBTYPE INFO" ); end if;

        PUT_LINE( SUBTYPE_STR & " = '" & SUBTYPE_STR & "'" );
        PUT_LINE( "namespace " & SUBTYPE_STR );

        PUT_LINE( "VAR use__info, q" );
        PUT_LINE( "VAR SIZ, d" );
        PUT_LINE( tab & "LVA" & tab & LVL_STR & ", SIZ" );
        PUT_LINE( tab & "Sa" & tab & LVL_STR & ", use__info" );
        PUT_LINE( "VAR FST, " & SIZE_CHAR );
        PUT_LINE( "VAR LST, " & SIZE_CHAR );
        PUT_LINE( tab & "LI" & tab & IMAGE( DI( CD_IMPL_SIZE, TYPE_SPEC ) ) );
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", SIZ" );

        EXPRESSIONS.CODE_EXP( EXP_FST );
        PUT_LINE( tab & 'S' & SIZE_CHAR & tab & LVL_STR & ", FST" );

        EXPRESSIONS.CODE_EXP( EXP_LST );
        PUT_LINE( tab & 'S' & SIZE_CHAR & tab & LVL_STR & ", LST" );

        PUT_LINE( "VAR PARENT__u, q" );
        PUT( tab & "La" & tab & IMAGE( DI( CD_LEVEL, BASE_TYPE ) ) & ", " );
        REGIONS_PATH( D( XD_SOURCE_NAME, D( SM_BASE_TYPE, TYPE_SPEC ) ) );
        PUT_LINE(  BASETYPE_STR & ".use__info"	);
        PUT_LINE( tab & "Sa" & tab & LVL_STR & ", PARENT__u" );

        PUT_LINE( "end namespace" );

      end		INTEGER_SUBTYPE;
		---------------

    elsif	 TYPE_SPEC.TY = DN_ENUMERATION  then
				-------------------
				ENUMERATION_SUBTYPE:
      declare
        SIZE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( TYPE_SPEC );
        ENUM_RANGE		: TREE		:= D( SM_RANGE, TYPE_SPEC );
        EXP_FST		: TREE		:= D( AS_EXP1, ENUM_RANGE );
        EXP_LST		: TREE		:= D( AS_EXP2, ENUM_RANGE );
        LVL_STR		:constant	STRING	:= IMAGE(	CODI.CUR_LEVEL );
        BASE_TYPE		: TREE		:= D( SM_BASE_TYPE, TYPE_SPEC );
        BASETYPE_STR	:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP,
					   D( XD_SOURCE_NAME, BASE_TYPE ) ) );
      begin

        if  CODI.DEBUG  then NEW_LINE; PUT_LINE( tab50 & "; " & SUBTYPE_STR & " ENUMERATION SUBTYPE INFO" ); end if;

        PUT_LINE( SUBTYPE_STR & " = '" & SUBTYPE_STR & "'" );
        PUT_LINE( "namespace " & SUBTYPE_STR );

        PUT_LINE( "VAR use__info, q" );
        PUT_LINE( "VAR SIZ, d" );
        PUT_LINE( tab & "LVA" & tab & LVL_STR & ", SIZ" );
        PUT_LINE( tab & "Sa" & tab & LVL_STR & ", use__info" );

        PUT_LINE( "VAR FST, " & SIZE_CHAR );
        PUT_LINE( "VAR LST, " & SIZE_CHAR );
        PUT_LINE( tab & "LI" & tab & IMAGE( DI( CD_IMPL_SIZE, TYPE_SPEC ) ) );
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", SIZ" );

        EXPRESSIONS.CODE_EXP( EXP_FST );
        PUT_LINE( tab & 'S' & SIZE_CHAR & tab & LVL_STR & ", FST" );

        EXPRESSIONS.CODE_EXP( EXP_LST );
        PUT_LINE( tab & 'S' & SIZE_CHAR & tab & LVL_STR & ", LST" );

        PUT_LINE( "VAR PARENT__u, q" );
        PUT( tab & "La " & IMAGE( DI( CD_LEVEL, BASE_TYPE ) ) & tab & ", " );
        REGIONS_PATH( D( XD_SOURCE_NAME, BASE_TYPE ) );
        PUT_LINE(  BASETYPE_STR & ".use__info"	);
        PUT_LINE( tab & "Sa" & tab & LVL_STR & ", PARENT__u" );

        PUT_LINE( "end namespace" );

      end		ENUMERATION_SUBTYPE;
		-------------------

    elsif  TYPE_SPEC.TY = DN_FLOAT  then
			------------
			GARDE_FORMEL:
  declare
    FLOAT_RANGE : TREE := D( SM_RANGE, TYPE_SPEC );
    BASE_TYPE   : TREE := D( SM_BASE_TYPE, TYPE_SPEC );
  begin
    if FLOAT_RANGE = TREE_VOID then
      -- Cas typique : SUBTYPE SF IS F; où F est un type formel flottant.
      -- Ne surtout pas chercher AS_EXP1/AS_EXP2.
      if CODI.DEBUG then
        PUT_LINE( "; CODE_SUBTYPE_DECL : FLOAT subtype without range "
                & SUBTYPE_STR & " treated as alias" );
      end if;

      -- Minimalement : le type est connu/compilé, mais aucun patron FST/LST
      -- propre n'est généré.
      DB( CD_COMPILED, TYPE_SPEC, TRUE );

      -- Option utile si CD_IMPL_SIZE n'est pas posé par la sémantique :
--      if BASE_TYPE /= TREE_VOID and then BASE_TYPE.TY = DN_FLOAT then
--        if HAS_ATTR( CD_IMPL_SIZE, BASE_TYPE ) then   -- pseudo, selon tes utilitaires
--          DI( CD_IMPL_SIZE, TYPE_SPEC, DI( CD_IMPL_SIZE, BASE_TYPE ) );
--        end if;
--      end if;

      return;
    end if;

  end	GARDE_FORMEL;
	------------

				-------------
				FLOAT_SUBTYPE:
      declare
        FLOAT_RANGE		: TREE		:= D( SM_RANGE, TYPE_SPEC );
        EXP_FST		: TREE		:= D( AS_EXP1, FLOAT_RANGE );
        EXP_LST		: TREE		:= D( AS_EXP2, FLOAT_RANGE );
        BASE_TYPE		: TREE		:= D( SM_BASE_TYPE, TYPE_SPEC );
        BASETYPE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, BASE_TYPE ) ) );
      begin
        if  CODI.DEBUG  then
	NEW_LINE;
	PUT_LINE( tab50 & "; " & SUBTYPE_STR & " FLOAT SUBTYPE INFO" );
        end if;

        PUT_LINE( SUBTYPE_STR & " = '" & SUBTYPE_STR & "'" );
        PUT_LINE( "namespace " & SUBTYPE_STR );

        PUT_LINE( "VAR use__info, q" );
        PUT_LINE( "VAR SIZ, d" );
        PUT_LINE( "VAR FST, q" );
        PUT_LINE( "VAR LST, q" );

        PUT_LINE( tab & "LVA" & tab & LVL_STR & ", SIZ" );
        PUT_LINE( tab & "Sa"  & tab & LVL_STR & ", use__info" );

        PUT_LINE( tab & "LI" & tab & IMAGE( DI( CD_IMPL_SIZE, TYPE_SPEC ) ) );
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", SIZ" );

        EXPRESSIONS.CODE_EXP( EXP_FST );
        PUT_LINE( tab & "Sq" & tab & LVL_STR & ", FST" );

        EXPRESSIONS.CODE_EXP( EXP_LST );
        PUT_LINE( tab & "Sq" & tab & LVL_STR & ", LST" );

        PUT_LINE( "VAR PARENT__u, q" );
        PUT( tab & "La " & IMAGE( DI( CD_LEVEL, BASE_TYPE ) ) & tab & ", " );
        REGIONS_PATH( D( XD_SOURCE_NAME, BASE_TYPE ) );
        PUT_LINE( BASETYPE_STR & ".use__info" );
        PUT_LINE( tab & "Sa" & tab & LVL_STR & ", PARENT__u" );

        PUT_LINE( "end namespace" );

      end		FLOAT_SUBTYPE;
		-------------

    elsif  TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY
    then
      PUT_LINE( SUBTYPE_STR &	" = '" & SUBTYPE_STR & "'" );
      PUT( "namespace " & SUBTYPE_STR );
      if	CODI.DEBUG  then PUT( tab50 &	"; " & SUBTYPE_STR & " CONSTRAINED ARRAY SUBTYPE INFO" ); end if;
      NEW_LINE;

      PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( TYPE_SPEC, D( AS_CONSTRAINT, D( AS_SUBTYPE_INDICATION, SUBTYPE_DECL ) ) );

    elsif  TYPE_SPEC.TY = DN_CONSTRAINED_RECORD  then
      CODE_CONSTRAINED_RECORD_DECL( SUBTYPE_ID, TYPE_SPEC );

    else
      PUT_LINE( ";  CODE_SUBTYPE_DECL : TYPE_SPEC.TY PAS FAIT " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
    end if;

  end	  CODE_SUBTYPE_DECL;
	--=================--


	-----------
end	TYPES_DECLS;
	-----------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
