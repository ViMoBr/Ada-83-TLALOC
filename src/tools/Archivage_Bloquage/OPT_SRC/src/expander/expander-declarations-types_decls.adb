------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT	MORIN, UBO
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

    elsif	 TYPE_SPEC.TY = DN_RECORD		then  CODE_RECORD_DECL	     ( TYPE_DECL );
    elsif	 TYPE_SPEC.TY = DN_ARRAY		then  CODE_UNCONSTRAINED_ARRAY_DECL( TYPE_DECL );
    elsif	 TYPE_SPEC.TY = DN_ACCESS		then  CODE_ACCESS_DECL	     ( TYPE_DECL );

    elsif	 TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY	then  CODE_CONSTRAINED_ARRAY_DECL  ( TYPE_DECL );

				-- PRIVATE / LIMITED PRIVATE TYPES
				-- Nothing to generate here; the full
				-- type declaration	in the private part
				-- will be processed normally.

    elsif	 TYPE_SPEC.TY = DN_PRIVATE
    or	 TYPE_SPEC.TY = DN_L_PRIVATE
    then
      if	CODI.DEBUG  then
	PUT_LINE(	"; CODE_TYPE_DECL : skip PRIVATE "
		& PRINT_NAME( D( LX_SYMREP, TYPE_NAME )	)
		& " (deferred to full type)" );
      end	if;

				-- INCOMPLETE TYPES
				-- Same: deferred to full type.

    elsif	 TYPE_SPEC.TY = DN_INCOMPLETE
    then
      if	CODI.DEBUG  then
	PUT_LINE(	"; CODE_TYPE_DECL : skip INCOMPLETE "
		& PRINT_NAME( D( LX_SYMREP, TYPE_NAME )	)
		& " (deferred to full type)" );
      end	if;

    else
      PUT_LINE( "; CODE_GEN.DECLARATIONS.CODE_TYPE_DECL : TYPE_SPEC.TY ("
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
    TYPE_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
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

    if  CODI.DEBUG	then NEW_LINE; PUT_LINE( tab50 & "; " &	TYPE_STR & " ENUMERATION TYPE INFO" ); end if;

    PUT_LINE( TYPE_STR & " = '" & TYPE_STR & "'" );
    PUT_LINE( "namespace " & TYPE_STR );
    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "BEGIN_BLOC_DEF" );
    CODE_ENUM_LITERAL_S( D( SM_LITERAL_S, TYPE_SPEC ) );
    PUT_LINE( "END_BLOC_DEF" );
    PUT_LINE( "IMAGES" & ASCII.HT & "BYTES_BLOC" );
    PUT_LINE( "CST " & "LST, d," & INTEGER'IMAGE(	MAX_REP )	);
    PUT_LINE( "CST " & "FST, d," & INTEGER'IMAGE(	MIN_REP )	);
    PUT	  ( "CST " & "SIZ, d," & INTEGER'IMAGE(	DI( CD_IMPL_SIZE, TYPE_SPEC )	) );
    if  CODI.DEBUG	then PUT(	ASCII.HT & "; SIZ en bits !" ); end if;
    NEW_LINE;
    PUT_LINE( "postpone" );
    PUT_LINE( "  align_q" );										-- Assurer  l'alignement de départ de tout le bloc
    PUT_LINE( "end postpone" );

    PUT_LINE( tab &	"LCA" & tab & "SIZ"	);
    PUT_LINE( tab &	"Sa" & tab & IMAGE(	CODI.CUR_LEVEL ) & ", use__info" );

    PUT_LINE( "end namespace");

  end	CODE_ENUMERATION_DECL;
	---------------------



			-----------------
  procedure		CODE_INTEGER_DECL		( TYPE_DECL :TREE )
  is			-----------------

    TYPE_ID		: TREE		:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
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

    if  CODI.DEBUG	then  NEW_LINE; PUT_LINE( tab50 & "; " & TYPE_STR	& " TYPE RANGE INFO" ); end if;

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
    TYPE_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    FIXED_SPEC		: TREE		:= D( SM_TYPE_SPEC,	TYPE_ID );
    SIZE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( FIXED_SPEC );

  begin
    DI( CD_LEVEL,	  FIXED_SPEC, INTEGER( CODI.CUR_LEVEL )	);
    DB( CD_COMPILED,  FIXED_SPEC, TRUE );

    if  CODI.DEBUG	then  NEW_LINE; PUT_LINE( tab50 & "; " & TYPE_STR	& " FIXED TYPE INFO" ); end if;

    PUT_LINE( TYPE_STR & " = '" & TYPE_STR & "'" );
    PUT_LINE( "namespace " & TYPE_STR );

    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "CST SIZ, d," &	INTEGER'IMAGE( DI( CD_IMPL_SIZE, FIXED_SPEC ) ) );
    PUT_LINE( tab &	"LCA" & tab & "SIZ"	);
    PUT_LINE( tab &	"Sa" & tab & IMAGE(	CODI.CUR_LEVEL ) & ", use__info" );

    PUT_LINE( "; load fixed limites FST LST a faire " );
    PUT_LINE( "CST FST, " & SIZE_CHAR &	", 0" );
    PUT_LINE( "CST LST, " & SIZE_CHAR &	", 0" );

    PUT_LINE( "end namespace"	);

  end	CODE_FIXED_DECL;
	---------------



			---------------
  procedure		CODE_FLOAT_DECL		( TYPE_DECL :TREE )
  is			---------------

    TYPE_ID		: TREE		:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    FLOAT_SPEC		: TREE		:= D( SM_TYPE_SPEC,	TYPE_ID );
    SIZE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( FLOAT_SPEC );

  begin
    DI( CD_LEVEL,	  FLOAT_SPEC, INTEGER( CODI.CUR_LEVEL )	);
    DB( CD_COMPILED,  FLOAT_SPEC, TRUE );

    if  CODI.DEBUG	then  NEW_LINE; PUT_LINE( tab50 & "; " & TYPE_STR	& " FLOAT TYPE INFO" ); end if;

    PUT_LINE( TYPE_STR & " = '" & TYPE_STR & "'" );
    PUT_LINE( "namespace " & TYPE_STR );

    PUT_LINE( "VAR use__info, q" );

    if  SIZE_CHAR =	'd'  then
      PUT_LINE( "CST LST, " &	SIZE_CHAR	& ",  1.0E38" );							-- ATTENTION : CST ne sens inverse a cause de postpone
      PUT_LINE( "CST FST, " &	SIZE_CHAR	& ", -1.0E38" );
    elsif	 SIZE_CHAR = 'q'  then
      PUT_LINE( "CST LST, " &	SIZE_CHAR	& ",  1.0E308" );
      PUT_LINE( "CST FST, " &	SIZE_CHAR	& ", -1.0E308" );
    end if;

    PUT_LINE( "CST SIZ, d," &	INTEGER'IMAGE( DI( CD_IMPL_SIZE, FLOAT_SPEC ) ) );
    PUT_LINE( tab &	"LCA" & tab & "SIZ"	);
    PUT_LINE( tab &	"Sa" & tab & IMAGE(	CODI.CUR_LEVEL ) & ", use__info" );

    PUT_LINE( "end namespace"	);

  end	CODE_FLOAT_DECL;
	---------------



			-----------------------------
  procedure		CODE_UNCONSTRAINED_ARRAY_DECL		( TYPE_DECL :TREE )
  is			-----------------------------

    TYPE_ID		: TREE		:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_ID_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
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

        if  not IS_EMPTY( IDX_TYPE_LIST	)  then								-- Encore	des dimensions
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

    if  CODI.DEBUG	then NEW_LINE; PUT_LINE( tab50 & "; " &	TYPE_ID_STR & " UNCONSTRAINED ARRAY SUBTYPE INFO"	); end if;
    PUT_LINE( TYPE_ID_STR & " = '" & TYPE_ID_STR & "'" );
    PUT_LINE( "namespace " & TYPE_ID_STR );

    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "VAR SIZ, d" );
    PUT_LINE( tab &	"LVA" & tab & LVL_STR & ", SIZ" );
    PUT_LINE( tab &	"Sa" & tab & LVL_STR & ", use__info" );
    PUT_LINE( tab &	"LI" & tab & '1' );
    PUT_LINE( tab &	"NEG" );
    PUT_LINE( tab &	"Sd" & tab & LVL_STR & ", SIZ" );							-- SIZ=-1	UNCONSTRAINED

    PUT( "  virtual at 4" );										-- Commence apres SIZ
    if  CODI.DEBUG	then  PUT_LINE( tab50 & "; use info offsets pour acces sur array contraint" ); end if;
    NEW_LINE;

    USEINFO_OFFSETS( INDEX_SUBTYPE_S );

    PUT_LINE( "  end virtual"	);									-- Commence apres SIZ

    PUT_LINE( "end namespace"	);

  end	CODE_UNCONSTRAINED_ARRAY_DECL;
	-----------------------------



			--===================================--
  procedure		  PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC		( TYPE_SPEC :TREE )
  is			--===================================--

    DIM_NBR		: NATURAL			:= 0;
    LVL			: LEVEL_NUM		renames CODI.CUR_LEVEL;
    LVL_STR		:constant	STRING		:= IMAGE(	CODI.CUR_LEVEL );
    TOTAL_ELEMENTS		: NATURAL;

    BASE_TYPE		: TREE			:= D( SM_BASE_TYPE,	TYPE_SPEC	);
    COMP_TYPE		: TREE			:= D( SM_COMP_TYPE,	BASE_TYPE	);
    COMP_SIZE_TREE		: TREE			:= D( CD_IMPL_SIZE,	COMP_TYPE	);
    IS_STATIC		: BOOLEAN			:= COMP_SIZE_TREE /= TREE_VOID;
    ARRAY_STATIC_SIZE	: NATURAL			:= 0;

		----------------------------
    procedure	COMPILE_ARRAY_TYPE_DIMENSION		( IDX_TYPE_LIST :in	out SEQ_TYPE )
    is
      IDX_TYPE		: TREE;
      DIM_NBR_STR		:constant	STRING	:= IMAGE(	DIM_NBR+1	);
    begin
      POP( IDX_TYPE_LIST, IDX_TYPE );
      DIM_NBR := DIM_NBR + 1;

      if	IS_EMPTY(	IDX_TYPE_LIST )  then
        declare
	ELEMENT_SIZ		: NATURAL		:= DI( CD_IMPL_SIZE, COMP_TYPE );			-- TAILLE	EN BITS
	ELEMENT_SIZ_STR		:constant	STRING	:= IMAGE(	ELEMENT_SIZ );				-- IMAGE DE TAILLE EN BITS
        begin
	ARRAY_STATIC_SIZE := ELEMENT_SIZ;
	PUT_LINE(	"VAR COMP_SIZ, d" );
	PUT_LINE(	"VAR FST_" & DIM_NBR_STR & ", d" );
	PUT_LINE(	"VAR LST_" & DIM_NBR_STR & ", d" );

	PUT_LINE(	tab & "LI" & tab & ELEMENT_SIZ_STR );							-- TAILLE	D'UN ELEMENT DU TABLEAU
	PUT_LINE(	tab & "Sd" & tab & LVL_STR & ", COMP_SIZ" );						-- DWORD COMP_SIZ
	PUT_LINE(	tab & "Ld" & tab & LVL_STR & ", COMP_SIZ" );						-- recharge pour MUL suivant
        end;

      else
        COMPILE_ARRAY_TYPE_DIMENSION( IDX_TYPE_LIST );

        PUT_LINE( "VAR SIZ_" & DIM_NBR_STR & ", d" );
        PUT_LINE( "VAR FST_" & DIM_NBR_STR & ", d" );
        PUT_LINE( "VAR LST_" & DIM_NBR_STR & ", d" );

        PUT_LINE( tab & "MUL"	);
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", SIZ_" & DIM_NBR_STR	);					-- METTRE	LA TAILLE	TRANCHE A	CELLE LAISSEE PAR LE CALCUL SUR LA DIM PRECEDENTE
        PUT_LINE( tab & "Ld" & tab & LVL_STR & ", SIZ_" & DIM_NBR_STR	);					-- recharge pour MUL suivant
      end	if;

      if	IDX_TYPE.TY = DN_INTEGER  then
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
	PUT_LINE(	tab & "Sd" & tab & LVL_STR & ", FST_" &	DIM_NBR_STR );
	EXPRESSIONS.CODE_EXP( RANGE_LAST );
	PUT_LINE(	tab & "Sd" & tab & LVL_STR & ", LST_" &	DIM_NBR_STR );

	PUT_LINE(	tab & "Ld" & tab & LVL_STR & ", LST_" &	DIM_NBR_STR );
	PUT_LINE(	tab & "INC" );
	PUT_LINE(	tab & "Ld" & tab & LVL_STR & ", FST_" &	DIM_NBR_STR );
	PUT_LINE(	tab & "SUB" );

	if  IS_STATIC  then
	  ARRAY_STATIC_SIZE	:= ( DI( SM_VALUE, RANGE_LAST	) + 1 - DI( SM_VALUE, RANGE_FIRST ) ) *	ARRAY_STATIC_SIZE;
	end if;
        end;
      end	if;

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
    DI( CD_LEVEL, TYPE_SPEC, INTEGER( LVL ) );

    PUT_LINE( "VAR use__info, q" );
    PUT_LINE( "VAR SIZ, d" );
    PUT_LINE( tab &	"LVA" & tab & LVL_STR & ", SIZ" );
    PUT_LINE( tab &	"Sa" & tab & LVL_STR & ", use__info" );

			-------------------
			DESCRIPTOR_ON_STACK:
    begin
      declare
        IDX_TYPE_LIST	: SEQ_TYPE	:= LIST( D( SM_INDEX_SUBTYPE_S, TYPE_SPEC ) );
      begin
        COMPILE_ARRAY_TYPE_DIMENSION( IDX_TYPE_LIST );
      end;
      PUT_LINE( tab	& "MUL" );
      PUT_LINE( tab	& "Sd" & tab & LVL_STR & ", SIZ" );

      if	IS_STATIC
      then  DI( CD_IMPL_SIZE,	TYPE_SPEC,  ARRAY_STATIC_SIZE	);
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

    DB( CD_COMPILED,	TYPE_SPEC, TRUE );

  end	  PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC;
	--===================================--



			---------------------------
  procedure		CODE_CONSTRAINED_ARRAY_DECL		( TYPE_DECL :TREE )
  is			---------------------------

    TYPE_NAME		: TREE			:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_NAME_STR		:constant	STRING		:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
    TYPE_SPEC		: TREE			:= D( SM_TYPE_SPEC,	TYPE_NAME	);

  begin
    if  CODI.DEBUG	then NEW_LINE; PUT_LINE( tab50 & "; array decl constrained array type info" ); end if;

    PUT_LINE( TYPE_NAME_STR &	" = '" & TYPE_NAME_STR & "'" );
    PUT_LINE( "namespace " & TYPE_NAME_STR );

    PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( TYPE_SPEC );

  end	CODE_CONSTRAINED_ARRAY_DECL;
	---------------------------



			----------------
  procedure		CODE_RECORD_DECL		( TYPE_DECL :TREE )
  is			----------------

    TYPE_ID		: TREE			:= D( AS_SOURCE_NAME, TYPE_DECL );
    TYPE_SPEC		: TREE			:= D( SM_TYPE_SPEC,	TYPE_ID );
    TYPE_ID_STR		:constant	STRING		:= PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    LVL			: LEVEL_NUM		renames CODI.CUR_LEVEL;
    LVL_STR		:constant	STRING		:= IMAGE(	LVL );
    IS_STATIC		: BOOLEAN			:= TRUE;
    STATIC_SIZE		: NATURAL			:= 0;

  begin
				-- Resolve private/incomplete	to full type
    if  TYPE_SPEC.TY = DN_L_PRIVATE
    or  TYPE_SPEC.TY = DN_PRIVATE
    then
      TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
    elsif	 TYPE_SPEC.TY = DN_INCOMPLETE	 then
      TYPE_SPEC := D( XD_FULL_TYPE_SPEC, TYPE_SPEC );
    end if;

    DI( CD_LEVEL,	  TYPE_SPEC, INTEGER( CODI.CUR_LEVEL ) );
    DB( CD_COMPILED,  TYPE_SPEC, TRUE );

    if  CODI.DEBUG	then NEW_LINE; PUT_LINE( tab50 & "; " &	TYPE_ID_STR & " RECORD TYPE INFO" ); end if;

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
	    DISCRIMINANT_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DISCRIMINANT_ID ) );
	    DISCRIMINANT_TYPE_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DISCRIMINANT_TYPE_NAME ) );
	  begin
	    PUT( "USEINFO "	& LVL_STR	& ", " & DISCRIMINANT_STR & ", " );
	    PUT( tab & "La " & IMAGE(	DI( CD_LEVEL, DISCRIMINANT_TYPE_SPEC ) ) & ", " );
	    REGIONS_PATH( D( XD_SOURCE_NAME, DISCRIMINANT_TYPE_SPEC	) );
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
      V_DECL_S		: SEQ_TYPE	:= LIST( D( AS_DECL_S, D( SM_COMP_LIST,	TYPE_SPEC	) ) );
      V_DECL		: TREE;
    begin
      while  not IS_EMPTY( V_DECL_S )  loop
        POP( V_DECL_S, V_DECL	);

        declare
	COMP_ID_S		: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S,	V_DECL ) );
	COMP_ID		: TREE;

        begin
	while  not IS_EMPTY( COMP_ID_S )  loop
	  POP( COMP_ID_S, COMP_ID );

	  declare
	    COMP_TYPE	: TREE		:= D( SM_OBJ_TYPE, COMP_ID );
	    COMP_BASE_TYPE	: TREE		:= D( SM_BASE_TYPE,	COMP_TYPE	);
	    COMP_TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, COMP_TYPE );
	    COMP_TYPE_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, COMP_TYPE_NAME ) );
	    COMP_ID_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, COMP_ID ) );

	  begin
	    if  COMP_TYPE.TY = DN_CONSTRAINED_ARRAY  then
	      if	not DB( CD_COMPILED, COMP_TYPE )  then
	        PUT_LINE( COMP_ID_STR	& " = '" & COMP_ID_STR & "'" );
	        PUT_LINE( " namespace " & COMP_TYPE_STR );
	        PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( COMP_TYPE );
	      end	if;

	      PUT( "USEINFO " & LVL_STR & ", " & COMP_ID_STR & ", "	);
	      PUT( tab & "La " & IMAGE( DI( CD_LEVEL, COMP_TYPE ) )	& ", " );
	      REGIONS_PATH(	D( XD_SOURCE_NAME, D( SM_TYPE_SPEC, COMP_TYPE_NAME ) ) );
	      PUT_LINE( COMP_TYPE_STR	& ".use__info" );

	    else
	      PUT( "USEINFO " & LVL_STR & ", " & COMP_ID_STR & ", "	);
	      PUT( tab & "La " & IMAGE( DI( CD_LEVEL, COMP_TYPE ) )	& ", " );
	      REGIONS_PATH(	COMP_TYPE_NAME );
	      PUT_LINE( PRINT_NAME( D( LX_SYMREP, COMP_TYPE_NAME ) )  & ".use__info" );
	    end if;

	    if  COMP_TYPE.TY in CLASS_SCALAR  or  COMP_TYPE.TY in CLASS_CONSTRAINED  then
	      if	D( CD_IMPL_SIZE, COMP_TYPE ) = TREE_VOID  then
	        IS_STATIC := FALSE;
	      end	if;
	    elsif	 COMP_TYPE.TY = DN_RECORD  then
	      if	not IS_EMPTY( LIST(	D( SM_DISCRIMINANT_S, COMP_TYPE ) ) )  then
	        IS_STATIC := FALSE;
	      end	if;
	    else
	      IS_STATIC := FALSE;
	    end if;
	  end;
	end loop;
        end;
      end	loop;
    end	INSERE_LES_CHAMPS;
	-----------------

    if	IS_STATIC	 then
      PUT( "virtual at 0" );
      if	CODI.DEBUG  then  PUT( tab50 & "; calcul des offsets statiques" ); end if;
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

	  PUT_LINE( tab & "LI 0" & tab & " ; offset a faire" );
	  PUT_LINE( tab & "Sd" & tab & LVL_STR & ", " & PRINT_NAME(	D( LX_SYMREP, DISCRIMINANT_ID	) ) & "__o" );

	end loop;
        end;
      end	loop;

    end		TRAITER_LES_DISCRIMINANTS;
		-------------------------

			------------------
			TRAITER_LES_CHAMPS:
    declare
      V_DECL_S		: SEQ_TYPE	:= LIST( D( AS_DECL_S, D( SM_COMP_LIST,	TYPE_SPEC	) ) );
      V_DECL		: TREE;
    begin


      while  not IS_EMPTY( V_DECL_S )  loop
        POP( V_DECL_S, V_DECL	);
        declare
	COMP_ID_S		: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S,	V_DECL ) );
	COMP_ID		: TREE;

        begin
	while  not IS_EMPTY( COMP_ID_S )  loop
	  POP( COMP_ID_S, COMP_ID );

	  declare
	    COMP_TYPE	: TREE		:= D( SM_OBJ_TYPE, COMP_ID );
	    COMP_TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, COMP_TYPE );
	    COMP_TYPE_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, COMP_TYPE_NAME ) );
	    COMP_ID_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, COMP_ID ) );
	    COMP_SIZE	: NATURAL;

	  begin
	    if  IS_STATIC  then
	      COMP_SIZE := DI( CD_IMPL_SIZE, COMP_TYPE );
	      if	COMP_SIZE	< CODI.STORAGE_UNIT	 then
	        COMP_SIZE := CODI.STORAGE_UNIT;
	      end	if;
	      PUT_LINE( "STATOFS " & COMP_ID_STR
		    & ','	& INTEGER'IMAGE( COMP_SIZE / CODI.STORAGE_UNIT ) );
	      STATIC_SIZE := STATIC_SIZE + COMP_SIZE;
	    else
	      PUT_LINE( "; OFFSET NON STATIQUE A FAIRE" );
	    end if;
	  end;
	end loop;
        end;
      end	loop;

      if	IS_STATIC	 then
        PUT_LINE( "size = $" );
        PUT_LINE( "end virtual" );
        PUT_LINE( tab & "LI" & tab & " size*" & INTEGER'IMAGE( CODI.STORAGE_UNIT ) );
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", SIZ" );
        DI( CD_IMPL_SIZE, TYPE_SPEC, STATIC_SIZE );
      end	if;

    end		TRAITER_LES_CHAMPS;
		------------------

    PUT_LINE( "end namespace"	);

  end	CODE_RECORD_DECL;
	----------------



				----------------
  procedure			CODE_ACCESS_DECL		( TYPE_DECL :TREE )
  is				----------------
  begin
    null;
  end	CODE_ACCESS_DECL;
	----------------



				--=================--
  procedure			  CODE_SUBTYPE_DECL		( SUBTYPE_DECL :TREE )
  is				--=================--

    SUBTYPE_ID		: TREE		:= D( AS_SOURCE_NAME, SUBTYPE_DECL) ;
    TYPE_SPEC		: TREE		:= D( SM_TYPE_SPEC,	SUBTYPE_ID );
    SUBTYPE_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, SUBTYPE_ID	) );
    LVL_STR		:constant	STRING	:= IMAGE(	CODI.CUR_LEVEL );
  begin
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
        BASE_TYPE		: TREE		:= D( SM_BASE_TYPE,	TYPE_SPEC	);
        BASETYPE_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP,
					   D( XD_SOURCE_NAME, BASE_TYPE ) ) );
      begin
        if  CODI.DEBUG  then NEW_LINE; PUT_LINE( tab50 & "; " & SUBTYPE_STR & " INTEGER SUBTYPE INFO" ); end if;

        PUT_LINE( SUBTYPE_STR	& " = '" & SUBTYPE_STR & "'" );
        PUT_LINE( "namespace " & SUBTYPE_STR );

        PUT_LINE( "VAR use__info, q" );
        PUT_LINE( "VAR SIZ, d" );
        PUT_LINE( tab & "LVA"	& tab & LVL_STR & ", SIZ" );
        PUT_LINE( tab & "Sa" & tab & LVL_STR & ", use__info" );
        PUT_LINE( "VAR FST, "	& SIZE_CHAR );
        PUT_LINE( "VAR LST, "	& SIZE_CHAR );
        PUT_LINE( tab & "LI" & tab & IMAGE( DI( CD_IMPL_SIZE, TYPE_SPEC ) ) );
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", SIZ" );

        EXPRESSIONS.CODE_EXP(	EXP_FST );
        PUT_LINE( tab & 'S' &	SIZE_CHAR	& tab & LVL_STR & ", FST" );

        EXPRESSIONS.CODE_EXP(	EXP_LST );
        PUT_LINE( tab & 'S' &	SIZE_CHAR	& tab & LVL_STR & ", LST" );

        PUT_LINE( "VAR PARENT__u, q" );
        PUT( tab & "La" & tab	& IMAGE( DI( CD_LEVEL, BASE_TYPE ) ) & ", " );
        REGIONS_PATH( D( XD_SOURCE_NAME, D( SM_BASE_TYPE, TYPE_SPEC )	) );
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
        BASETYPE_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP,
					   D( XD_SOURCE_NAME, D( SM_BASE_TYPE, TYPE_SPEC ) ) ) );
      begin

        if  CODI.DEBUG  then NEW_LINE; PUT_LINE( tab50 & "; " & SUBTYPE_STR & " ENUMERATION SUBTYPE INFO" ); end if;

        PUT_LINE( SUBTYPE_STR	& " = '" & SUBTYPE_STR & "'" );
        PUT_LINE( "namespace " & SUBTYPE_STR );

        PUT_LINE( "VAR use__info, q" );
        PUT_LINE( "VAR SIZ, d" );
        PUT_LINE( tab & "LVA"	& tab & LVL_STR & ", SIZ" );
        PUT_LINE( tab & "Sa" & tab & LVL_STR & ", use__info" );

        PUT_LINE( "VAR FST, "	& SIZE_CHAR );
        PUT_LINE( "VAR LST, "	& SIZE_CHAR );
        PUT_LINE( tab & "LI" & tab & IMAGE( DI( CD_IMPL_SIZE, TYPE_SPEC ) ) );
        PUT_LINE( tab & "Sd" & tab & LVL_STR & ", SIZ" );

        EXPRESSIONS.CODE_EXP(	EXP_FST );
        PUT_LINE( tab & 'S' &	SIZE_CHAR	& tab & LVL_STR & ", FST" );

        EXPRESSIONS.CODE_EXP(	EXP_LST );
        PUT_LINE( tab & 'S' &	SIZE_CHAR	& tab & LVL_STR & ", LST" );

        PUT_LINE( "VAR PARENT__u, q" );
        PUT( tab & "La" & tab	& LVL_STR	& ", " );
        REGIONS_PATH( D( XD_SOURCE_NAME, D( SM_BASE_TYPE, TYPE_SPEC )	) );
        PUT_LINE(  BASETYPE_STR & ".use__info"	);
        PUT_LINE( tab & "Sa" & tab & LVL_STR & ", PARENT__u" );

        PUT_LINE( "end namespace" );

      end		ENUMERATION_SUBTYPE;
		-------------------

   elsif	TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY
    then
      PUT_LINE( SUBTYPE_STR &	" = '" & SUBTYPE_STR & "'" );
      PUT( "namespace " & SUBTYPE_STR );
      if	CODI.DEBUG  then PUT( tab50 &	"; " & SUBTYPE_STR & " CONSTRAINED ARRAY SUBTYPE INFO" ); end if;
      NEW_LINE;

      PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( TYPE_SPEC );

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
