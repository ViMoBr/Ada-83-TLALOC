------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT	MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( EXPANDER	)
				------------
	package body		DECLARATIONS
				------------
is


  package	CODI	renames EXPANDER.UTILS;
  use CODI;

  -------			-----------
  package			TYPES_DECLS
  -------			-----------
  is

    procedure CODE_TYPE_DECL			( TYPE_DECL :TREE );
    procedure CODE_SUBTYPE_DECL		( SUBTYPE_DECL :TREE );
    procedure PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC	( TYPE_SPEC :TREE; CONSTRAINT :TREE := TREE_VOID );

  ---	-----------
  end	TYPES_DECLS;
  ---	-----------
  package	body TYPES_DECLS is	separate;

  procedure CODE_REP	( REP :TREE );
  procedure CODE_USE_PRAGMA	( USE_PRAGMA :TREE );


			--=========--
  procedure		  CODE_DECL		( DECL :TREE )
  is			--=========--
  begin
    if	 DECL.TY = DN_NULL_COMP_DECL	then  CODE_NULL_COMP_DECL( DECL );
    elsif	 DECL.TY in CLASS_ID_DECL	then  CODE_ID_DECL	     ( DECL );
    elsif	 DECL.TY in CLASS_ID_S_DECL	then  CODE_ID_S_DECL     ( DECL );
    elsif	 DECL.TY in CLASS_REP	then  CODE_REP	     ( DECL );
    elsif	 DECL.TY in CLASS_USE_PRAGMA	then  CODE_USE_PRAGMA    ( DECL );
    end if;

  end	  CODE_DECL;
	--=========--



			--===========--
  procedure		  CODE_DECL_S		( DECL_S :TREE )
  is			--===========--

    DECL_SEQ	: SEQ_TYPE	:= LIST( DECL_S );
    DECL		: TREE;
  begin
    while	 not IS_EMPTY( DECL_SEQ )  loop
      POP( DECL_SEQ, DECL );
      CODE_DECL( DECL );
    end loop;

  end	  CODE_DECL_S;
	--===========--



			-------------------
  procedure		CODE_NULL_COMP_DECL		( NULL_COMP_DECL :TREE )
  is
  begin
    null;
  end	CODE_NULL_COMP_DECL;
	-------------------



			------------
  procedure		CODE_ID_DECL		( ID_DECL	:TREE )
  is			------------
  begin
    if	 ID_DECL.TY = DN_TYPE_DECL		then  TYPES_DECLS.CODE_TYPE_DECL   ( ID_DECL );
    elsif	 ID_DECL.TY = DN_SUBTYPE_DECL		then  TYPES_DECLS.CODE_SUBTYPE_DECL( ID_DECL );
    elsif	 ID_DECL.TY = DN_TASK_DECL		then  CODE_TASK_DECL         ( ID_DECL );
    elsif	 ID_DECL.TY in CLASS_UNIT_DECL	then  CODE_UNIT_DECL         ( ID_DECL );
    elsif	 ID_DECL.TY in CLASS_SIMPLE_RENAME_DECL	then  CODE_SIMPLE_RENAME_DECL( ID_DECL );

    end if;

  end	CODE_ID_DECL;
	------------



			--------------
  procedure		CODE_ID_S_DECL		( ID_S_DECL :TREE )
  is			--------------
  begin
    if	 ID_S_DECL.TY in CLASS_EXP_DECL		then  CODE_EXP_DECL		   ( ID_S_DECL );
    elsif	 ID_S_DECL.TY = DN_EXCEPTION_DECL		then  CODE_EXCEPTION_DECL	   ( ID_S_DECL );
    elsif	 ID_S_DECL.TY = DN_DEFERRED_CONSTANT_DECL	then  CODE_DEFERRED_CONSTANT_DECL( ID_S_DECL );
    end if;

  end	CODE_ID_S_DECL;
	--------------



			--=======--
  procedure		CODE_HEADER		( HEADER :TREE )
  is			--=======--
  begin

    if  HEADER.TY in CLASS_SUBP_ENTRY_HEADER
    then
      CODE_PARAM_S(	D( AS_PARAM_S, HEADER ), (HEADER.TY = DN_FUNCTION_SPEC) );
      CODE_SUBP_ENTRY_HEADER(	HEADER );

    elsif	 HEADER.TY = DN_PACKAGE_SPEC
    then	CODE_PACKAGE_SPEC( HEADER );

    end if;

  end	  CODE_HEADER;
	--===========--


			------------
  procedure		CODE_PARAM_S	( PARAM_S	:TREE; FOR_FUNCTION	:BOOLEAN := FALSE )
  is			------------
  begin
    declare
      PARAM_SEQ		: SEQ_TYPE	:= LIST( PARAM_S );
      PARAM		: TREE;
    begin
      CODI.NO_SUBP_PARAMS := IS_EMPTY( PARAM_SEQ );
      if	CODI.NO_SUBP_PARAMS	 and  not FOR_FUNCTION  and  not CODI.IN_GENERIC_BODY  then
        return;
      end	if;

      if	CODI.OUTPUT_CODE  then
        PUT( "PRMS"	);
        if  CODI.DEBUG  then	PUT( tab50 & ";    debut parametrage" ); end if;
        NEW_LINE;
      end	if;

      while  not IS_EMPTY( PARAM_SEQ )	loop
        POP( PARAM_SEQ, PARAM	);
        CODE_PARAM(	PARAM );
      end	loop;

      if	CODI.OUTPUT_CODE  then
        if  CODI.IN_GENERIC_BODY  then
	PUT_LINE(	tab & "PRM GFP_ofs"	);
        end if;
        if  FOR_FUNCTION  then
	PUT( tab & "PRM result__ofs" );
	if  CODI.DEBUG  then  PUT( tab50 & "; resultat de fonction"	); end if;
	NEW_LINE;
        end if;
        PUT( "endPRMS" );
        if CODI.DEBUG then PUT( tab50 &	";    fin parametrage" ); end	if;
        NEW_LINE;
      end	if;
    end;

  end	CODE_PARAM_S;
	------------


			----------
  procedure		CODE_PARAM	( PARAM :TREE )
  is			----------

    ID_LIST	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S,	PARAM ) );
    ID		: TREE;

  begin
    while	 not IS_EMPTY( ID_LIST )  loop
      POP( ID_LIST,	ID );

      DI(	CD_LEVEL,	ID, INTEGER( CODI.CUR_LEVEL )	);

      if	CODI.OUTPUT_CODE  then
        if  D( SM_OBJ_TYPE, ID ).TY in CLASS_SCALAR and PARAM.TY = DN_IN  then
	PUT( tab & "PRM " &	PRINT_NAME( D( LX_SYMREP, ID ) ) & "_ofs" );
        else
	PUT( tab & "PRM " &	PRINT_NAME( D( LX_SYMREP, ID ) ) & "_ofs" );
        end if;
      end	if;

      if	PARAM.TY = DN_IN
      then  CODE_IN	( PARAM );

      elsif  PARAM.TY = DN_OUT
      then  CODE_OUT ( PARAM );

      elsif  PARAM.TY = DN_IN_OUT
      then  CODE_IN_OUT ( PARAM );

      end	if;
      if	CODI.OUTPUT_CODE  then NEW_LINE; end if;
    end loop;

  end	CODE_PARAM;
	----------


  --|-------------------------------------------------------------------------------------------
  procedure CODE_IN	( ADA_IN :TREE ) is
  begin
    if  CODI.OUTPUT_CODE  then
      if	CODI.DEBUG  then PUT( tab50 &	"; in" );	end if;
    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_IN_OUT ( ADA_IN_OUT :TREE ) is
  begin
    if  CODI.OUTPUT_CODE  then
      if	CODI.DEBUG  then PUT( tab50 &	"; in out" ); end if;
    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_OUT ( ADA_OUT :TREE ) is
  begin
    if  CODI.OUTPUT_CODE  then
      if	CODI.DEBUG  then PUT( tab50 &	"; out" ); end if;
    end if;
  end;

			----------------------
  procedure		CODE_SUBP_ENTRY_HEADER	( SUBP_ENTRY_HEADER	:TREE )
  is			----------------------
  begin
    if SUBP_ENTRY_HEADER.TY =	DN_PROCEDURE_SPEC
    then
null;
    elsif	SUBP_ENTRY_HEADER.TY = DN_FUNCTION_SPEC
    then
null;
    end if;
  end	CODE_SUBP_ENTRY_HEADER;
	----------------------


			-----------------
  procedure		CODE_PACKAGE_SPEC		( PACKAGE_SPEC :TREE )
  is			-----------------
  begin
    if  CODI.DEBUG  then PUT( tab50 & "; CODE_PACKAGE_SPEC" ); end if;
    NEW_LINE;

    CODE_DECL_S( D(	AS_DECL_S1, PACKAGE_SPEC ) );
    CODE_DECL_S( D(	AS_DECL_S2, PACKAGE_SPEC ) );

  end	CODE_PACKAGE_SPEC;
	-----------------


			-------------------
  procedure		CODE_EXCEPTION_DECL		( EXCEPTION_DECL :TREE )
  is			-------------------

		------------------
    procedure	CODE_SOURCE_NAME_S		( SOURCE_NAME_S :TREE )
    is		------------------

      SOURCE_NAME_SEQ	: SEQ_TYPE	:= LIST( SOURCE_NAME_S );
      SOURCE_NAME		: TREE;

    begin
      while  not IS_EMPTY( SOURCE_NAME_SEQ )  loop
        POP( SOURCE_NAME_SEQ,	SOURCE_NAME );
      end	loop;

    end	CODE_SOURCE_NAME_S;
	------------------

  begin
    CODE_SOURCE_NAME_S( D( AS_SOURCE_NAME_S, EXCEPTION_DECL	) );

  end	CODE_EXCEPTION_DECL;
	-------------------



		----------------------------------------------------

		--	DECL . ID_S_DECL .	E X P _ D	E C L	--

		----------------------------------------------------


			-------------
  procedure		CODE_EXP_DECL		( EXP_DECL :TREE )
  is			-------------

  begin
    if  EXP_DECL.TY	in CLASS_OBJECT_DECL
    then	CODE_OBJECT_DECL ( EXP_DECL );

    elsif	 EXP_DECL.TY = DN_NUMBER_DECL
    then	CODE_NUMBER_DECL ( EXP_DECL );

    end if;

  end	CODE_EXP_DECL;
	-------------


			----------------
  procedure		CODE_OBJECT_DECL		( OBJECT_DECL :TREE	)
  is			----------------

    SRC_NAME_SEQ	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S,	OBJECT_DECL ) );
    SRC_NAME	: TREE;

  begin
    while	 not IS_EMPTY( SRC_NAME_SEQ )	 loop
      POP( SRC_NAME_SEQ, SRC_NAME );
      if  not CODI.IN_GENERIC_BODY  or else  ( CODI.CUR_LEVEL /= CODI.GENERIC_BASE_LEVEL )  then
        CODE_VC_NAME( SRC_NAME, OBJECT_DECL );
      end if;
    end loop;

  end	CODE_OBJECT_DECL;
	----------------


			----------------
  procedure		CODE_NUMBER_DECL		( NUMBER_DECL :TREE	) is
  begin
    null;
  end	CODE_NUMBER_DECL;
	----------------


			---------------------------
  procedure		CODE_DEFERRED_CONSTANT_DECL	( DEFERRED_CONSTANT_DECL :TREE )
  is			---------------------------
  begin
    null; --PUT_LINE( "; DEFERRED CONSTANT A FAIRE " );

  end	CODE_DEFERRED_CONSTANT_DECL;
	---------------------------



			------------
  procedure		CODE_VC_NAME		( VC_NAME	:TREE; OBJECT_DECL :TREE := TREE_VOID )
  is			------------
  begin
    declare
      TYPE_SPEC	: TREE	:= D( SM_OBJ_TYPE, VC_NAME );


		-----------------------
      procedure	COMPILE_VC_NAME_INTEGER	( VC_NAME	:TREE )
      is		-----------------------

        OPER_TYPE		: CHARACTER	:= OPER_SIZ_CHAR( TYPE_SPEC );
        INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );

      begin
        PUT( "VAR "	& PRINT_NAME( D( LX_SYMREP, VC_NAME ) )	& "_disp, " & OPER_TYPE );
        if  CODI.DEBUG  then PUT( tab50	& "; variable entiere" ); end	if;
        NEW_LINE;
        DI( CD_LEVEL,     VC_NAME, INTEGER( CODI.CUR_LEVEL ) );

	if  INIT_EXP /= TREE_VOID  then
	  EXPRESSIONS.CODE_EXP( INIT_EXP );
	  CODI.STORE( VC_NAME );
	end if;

      end	COMPILE_VC_NAME_INTEGER;
	-----------------------


		---------------------
      procedure	COMPILE_VC_NAME_FIXED	( VC_NAME	:TREE )
      is		---------------------

        OPER_TYPE		: CHARACTER;
        INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );
        IS_GENERIC_FORMAL	: BOOLEAN		:= FALSE;
        VAR_NAME		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, VC_NAME ) );
      begin
        if  not CODI.IN_GENERIC_BODY  then
	OPER_TYPE := OPER_SIZ_CHAR( TYPE_SPEC );

        elsif  EXPRESSIONS.IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, TYPE_SPEC ) ) then
	IS_GENERIC_FORMAL := TRUE;
	OPER_TYPE := 'q';										-- Place maximale, on ne sait pas quelle taille actuelle sera prise

        else
	OPER_TYPE := OPER_SIZ_CHAR( TYPE_SPEC );
        end if;

<<NORMALE>>
       PUT( "VAR "	& VAR_NAME & "_disp, " & OPER_TYPE );
       if  CODI.DEBUG  then PUT( tab50	& "; variable fixed" ); end	if;
	NEW_LINE;
	DI( CD_LEVEL,     VC_NAME, INTEGER( CODI.CUR_LEVEL ) );

        if  INIT_EXP /= TREE_VOID  then
	if  IS_GENERIC_FORMAL  then
	  PUT_LINE( tab & "LVA " & IMAGE( CUR_LEVEL ) & ", " & VAR_NAME & "_disp" );
	end if;

	EXPRESSIONS.CODE_EXP( INIT_EXP );
	if  D( SM_EXP_TYPE, INIT_EXP ).TY = DN_FIXED  then
null;
	end if;

	if  not IS_GENERIC_FORMAL  then
	  CODI.STORE( VC_NAME );

	else											-- Acceder a variable de type instancie
	  PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
	  PUT_LINE( tab & "La , -" & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, TYPE_SPEC ) ) )  & "__st_ofs" );
	  PUT_LINE( tab & "CALLI" );
	end if;
        end if;

      end	COMPILE_VC_NAME_FIXED;
	---------------------


		---------------------
      procedure	COMPILE_VC_NAME_FLOAT	( VC_NAME	:TREE )
      is		---------------------

--        OPER_TYPE		: CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, VC_NAME ) );
        OPER_TYPE		: CHARACTER	:= OPER_SIZ_CHAR( TYPE_SPEC );
        INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );

      begin
        PUT( "VAR "	& PRINT_NAME( D( LX_SYMREP, VC_NAME ) )	& "_disp, " & OPER_TYPE );
        if  CODI.DEBUG  then PUT( tab50	& "; variable flottante" ); end if;
        NEW_LINE;
        DI( CD_LEVEL, VC_NAME, INTEGER(	CODI.CUR_LEVEL ) );

        if  INIT_EXP /= TREE_VOID  then
	EXPRESSIONS.CODE_EXP( INIT_EXP );
	CODI.STORE( VC_NAME	);
        end if;

      end	COMPILE_VC_NAME_FLOAT;
	---------------------


			---------------------------
      procedure		COMPILE_VC_NAME_ENUMERATION	( VC_NAME, TYPE_SPEC :TREE )
      is			---------------------------

        NAME	:constant	STRING	:= PRINT_NAME( D(LX_SYMREP, CODI.TYPE_SYMREP ) );

		-------------------------
        procedure	COMPILE_VC_NAME_BOOL_CHAR	( VC_NAME	:TREE )
        is	-------------------------

--	OPER_TYPE		: CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, VC_NAME ) );
	OPER_TYPE		: CHARACTER	:= OPER_SIZ_CHAR( TYPE_SPEC );
	INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );

        begin
	PUT( "VAR " & PRINT_NAME( D( LX_SYMREP,	VC_NAME )	) & "_disp, d" );
	if  CODI.DEBUG  then PUT( tab50 & "; variable bool char enum" ); end if;
	NEW_LINE;

	DI( CD_LEVEL,     VC_NAME, INTEGER( CODI.CUR_LEVEL ) );
	DB( CD_COMPILED,  VC_NAME, TRUE );

	if  INIT_EXP /= TREE_VOID  then
	  EXPRESSIONS.CODE_EXP( INIT_EXP );
	  CODI.STORE( VC_NAME );
	end if;

        end	COMPILE_VC_NAME_BOOL_CHAR;
		-------------------------

      begin
        if  NAME = "BOOLEAN"
        then  COMPILE_VC_NAME_BOOL_CHAR( VC_NAME );

        elsif  NAME	= "CHARACTER"
        then  COMPILE_VC_NAME_BOOL_CHAR( VC_NAME );

        else  COMPILE_VC_NAME_INTEGER( VC_NAME );
        end if;

      end	COMPILE_VC_NAME_ENUMERATION;
	---------------------------


		------------------
      procedure	COMPILE_ACCESS_VAR	( VAR_ID,	TYPE_SPEC	:TREE )
      is		------------------

        LVL		: LEVEL_NUM	renames CODI.CUR_LEVEL;
        LVL_STR		: constant STRING := IMAGE( CODI.CUR_LEVEL );
        VAR_STR		: constant STRING := PRINT_NAME( D( LX_SYMREP, VAR_ID ) );

      begin
        DI( CD_LEVEL,     VAR_ID, INTEGER( LVL ) );
        DB( CD_COMPILED,  VAR_ID, TRUE );

        PUT_LINE( "VAR " & VAR_STR & "_disp, q" );

        declare
		INIT_EXP		: TREE	:= D( SM_INIT_EXP, VAR_ID );
        begin
		if  INIT_EXP = TREE_VOID  then
		  PUT_LINE( tab & "LI" & tab & "0" );							-- null access
		else
		  EXPRESSIONS.CODE_EXP( INIT_EXP );
		end if;

		PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & VAR_STR & "_disp" );
        end;

      end	COMPILE_ACCESS_VAR;
	------------------




		-----------------
      procedure	COMPILE_ARRAY_VAR	( VC_NAME, TYPE_SPEC :TREE )
      is		-----------------
        VC_STR		:constant	STRING		:= PRINT_NAME( D( LX_SYMREP, VC_NAME ) );
        TYPE_NAME		: TREE			:= D( XD_SOURCE_NAME, TYPE_SPEC );
        TYPE_LEVEL		: INTEGER;
        TYPE_NAME_STR	:constant	STRING		:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
        LOCAL_TYPE_INFO_STR	:constant	STRING		:= '_' & VC_STR & "__type";
        DIM_NBR		: NATURAL			:= 1;
        LVL		: LEVEL_NUM		renames CODI.CUR_LEVEL;
        LVL_STR		:constant	STRING		:= IMAGE(	CODI.CUR_LEVEL );
        ANONYMOUS_SUBTYPE	: BOOLEAN			:= FALSE;
        USE_LOCAL_TYPE_INFO	: BOOLEAN			:= FALSE;

			--------------------
        procedure		PUT_TYPE_INFO_PREFIX
        is		--------------------
        begin
	if  USE_LOCAL_TYPE_INFO  then
	  PUT( LOCAL_TYPE_INFO_STR );
	else
	  REGIONS_PATH( TYPE_NAME );
	  PUT( TYPE_NAME_STR );
	end if;
        end	PUT_TYPE_INFO_PREFIX;
		--------------------

			--------------
        procedure		COVAR_ALLOCATE
        is		--------------
        begin
	PUT( tab & "Ld" & tab & IMAGE( TYPE_LEVEL ) & ", " );						-- LOAD SIZ FOR ALLOCATION
	PUT_TYPE_INFO_PREFIX;
	PUT_LINE(	".SIZ" );
	PUT_LINE(	tab & "LI" & tab & '8' );
	PUT_LINE(	tab & "DIV" );

	PUT_LINE(	tab & "CO_VAR" );
	PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR &	"_disp" );
	if  CODI.DEBUG  then PUT( tab50 & "; array data ptr at _disp" ); end if;
	NEW_LINE;

        end	COVAR_ALLOCATE;
		--------------


------------------------------
      procedure	UNCONSTRAINED_AGGREGATE_OBJECT	( AGG :TREE )
      is		------------------------------
	-- Objet non contraint initialise par agregat (RM83 4.3.2) :
	-- bornes deduites, bloc info ANONYME, __u re-pointe dessus.
	-- Idiome du doublet anonyme (cf. CODE_ARRAY_AGGREGATE_OPERAND).
	-- Deliberement conservateur : positionnel a cardinal statique,
	-- ou nomme a choix DN_NUMERIC_LITERAL (precedent
	-- IS_STATIC_INTEGER_BOUND). Tout le reste : refus BRUYANT.

        BASE_TYPE		: TREE		:= D( SM_BASE_TYPE, TYPE_SPEC );
        COMP_TYPE		: TREE		:= D( SM_COMP_TYPE, BASE_TYPE );
        COMP_BITS		: INTEGER	:= DI( CD_IMPL_SIZE, COMP_TYPE );
        COMP_BYTES		: INTEGER	:= COMP_BITS / CODI.STORAGE_UNIT;
        INFO_STR		:constant STRING	:= '_' & VC_STR & "__agg_info";

        SEEN_POSITIONAL	: BOOLEAN	:= FALSE;
        SEEN_NAMED		: BOOLEAN	:= FALSE;
        ALL_CHOICES_STATIC	: BOOLEAN	:= TRUE;
        NB_ELEMENTS		: NATURAL	:= 0;
        MIN_CHOICE		: INTEGER	:= INTEGER'LAST;
        MAX_CHOICE		: INTEGER	:= INTEGER'FIRST;

			-------
        procedure	EMIT_LI		( VALUE :INTEGER )
        is		-------
        begin
	if  VALUE < 0  then						-- convention LI 1 / NEG
	  PUT_LINE( tab & "LI" & tab & IMAGE( -VALUE ) );
	  PUT_LINE( tab & "NEG" );
	else
	  PUT_LINE( tab & "LI" & tab & IMAGE( VALUE ) );
	end if;
        end	EMIT_LI;
	-------

			----------------------
        function	IS_STATIC_CHOICE_EXP	( EXP :TREE ) return BOOLEAN
        is		----------------------
        begin
	return  EXP /= TREE_VOID  and then  EXP.TY = DN_NUMERIC_LITERAL;
        end	IS_STATIC_CHOICE_EXP;
	----------------------

			-----------------
        procedure	NOTE_CHOICE_VALUE	( VALUE :INTEGER )
        is		-----------------
        begin
	if  VALUE < MIN_CHOICE  then  MIN_CHOICE := VALUE;  end if;
	if  VALUE > MAX_CHOICE  then  MAX_CHOICE := VALUE;  end if;
        end	NOTE_CHOICE_VALUE;
	-----------------

			-----------------
        procedure	ANALYSE_AGGREGATE
        is		-----------------
	NORM_SEQ	: SEQ_TYPE	:= LIST( D( SM_NORMALIZED_COMP_S, AGG ) );
	ASSOC	: TREE;
        begin
	while not  IS_EMPTY( NORM_SEQ )  loop
	  POP( NORM_SEQ, ASSOC );

	  if  ASSOC.TY = DN_NAMED  then
	    SEEN_NAMED := TRUE;
				-------------------
				ANALYSE_CHOICE_LIST:
	    declare
	      CHOICES	: SEQ_TYPE	:= LIST( D( AS_CHOICE_S, ASSOC ) );
	      CH		: TREE;
	      EXP1	: TREE;
	      EXP2	: TREE;
	    begin
	      while not  IS_EMPTY( CHOICES )  loop
	        POP( CHOICES, CH );

	        if  CH.TY = DN_CHOICE_EXP  then
		EXP1 := D( AS_EXP, CH );
		if  IS_STATIC_CHOICE_EXP( EXP1 )  then
		  NOTE_CHOICE_VALUE( DI( SM_VALUE, EXP1 ) );
		else
		  ALL_CHOICES_STATIC := FALSE;
		end if;

	        elsif  CH.TY = DN_CHOICE_RANGE  then
		EXP1 := D( AS_EXP1, D( AS_DISCRETE_RANGE, CH ) );
		EXP2 := D( AS_EXP2, D( AS_DISCRETE_RANGE, CH ) );
		if  IS_STATIC_CHOICE_EXP( EXP1 )
		  and then  IS_STATIC_CHOICE_EXP( EXP2 )
		then
		  NOTE_CHOICE_VALUE( DI( SM_VALUE, EXP1 ) );
		  NOTE_CHOICE_VALUE( DI( SM_VALUE, EXP2 ) );
		else
		  ALL_CHOICES_STATIC := FALSE;
		end if;

	        else							-- DN_CHOICE_OTHERS...
				-- others : bornes indeterminables sur objet
				-- non contraint (RM83 4.3.2), sem aurait du
				-- refuser -- refus bruyant par prudence.
		ALL_CHOICES_STATIC := FALSE;
	        end if;
	      end loop;
	    end	ANALYSE_CHOICE_LIST;
				-------------------
	  else								-- expression nue
	    SEEN_POSITIONAL := TRUE;
	    NB_ELEMENTS := NB_ELEMENTS + 1;
	  end if;
	end loop;
        end	ANALYSE_AGGREGATE;
	-----------------

			-----------------
        function	FIRST_INDEX_RANGE	return TREE
        is		-----------------
	-- Range du sous-type d'index (idiome ADD_INDEX_DIMENSION) ;
	-- verifie au passage que le type est MONO-dimensionnel.
	IDX_S	: SEQ_TYPE	:= LIST( D( SM_INDEX_S, BASE_TYPE ) );
	IDX	: TREE;
        begin
	POP( IDX_S, IDX );

	if not  IS_EMPTY( IDX_S )  then
	  PUT_LINE( "; COMPILE_ARRAY_VAR : agregat non contraint MULTIDIM non fait" );
	  raise PROGRAM_ERROR;
	end if;

	if  IDX.TY = DN_INDEX  then
	  return D( SM_RANGE, D( SM_TYPE_SPEC, IDX ) );
	else
	  return D( SM_RANGE, IDX );
	end if;
        end	FIRST_INDEX_RANGE;
	-----------------

      begin									-- UNCONSTRAINED_AGGREGATE_OBJECT

        ANALYSE_AGGREGATE;

        if  SEEN_POSITIONAL  and  SEEN_NAMED  then				-- melange : illegal RM83 4.3
	PUT_LINE( "; COMPILE_ARRAY_VAR : agregat mixte positionnel/nomme" );
	raise PROGRAM_ERROR;
        end if;

        if  SEEN_NAMED  and then  not ALL_CHOICES_STATIC  then
	PUT_LINE( "; COMPILE_ARRAY_VAR : agregat non contraint a choix non statiques" );
	raise PROGRAM_ERROR;
        end if;

        if  SEEN_POSITIONAL  and then  NB_ELEMENTS = 0  then
	PUT_LINE( "; COMPILE_ARRAY_VAR : agregat vide" );
	raise PROGRAM_ERROR;
        end if;

        -- ---- Bloc info anonyme (layout aligne sur virtual at 4) ----
        PUT_LINE( "namespace " & INFO_STR );
        PUT_LINE( "  VAR SIZ,      d" );
        PUT_LINE( "  VAR _COMP_SIZ, d" );
        PUT_LINE( "  VAR _FST_1,    d" );
        PUT_LINE( "  VAR _LST_1,    d" );
        PUT_LINE( "end namespace" );

        -- ---- Bornes deduites ; laisse COUNT en sommet de pile ----
        if  SEEN_POSITIONAL  then
				-- RM83 4.3.2 : FST = INDEX'FIRST,
				-- LST = FST + n - 1 (n statique).
				---------------
				POSITIONAL_BOUNDS:
	declare
	  RNG	: TREE	:= FIRST_INDEX_RANGE;
	begin
	  EXPRESSIONS.CODE_EXP( D( AS_EXP1, RNG ) );			-- INDEX'FIRST
	  PUT_LINE( tab & "DUP" );
	  PUT_LINE( tab & "Sd  " & LVL_STR & ", " & INFO_STR & "._FST_1" );
	  EMIT_LI( INTEGER( NB_ELEMENTS ) - 1 );
	  PUT_LINE( tab & "ADD" );
	  PUT_LINE( tab & "Sd  " & LVL_STR & ", " & INFO_STR & "._LST_1" );
	  EMIT_LI( INTEGER( NB_ELEMENTS ) );				-- COUNT
	end	POSITIONAL_BOUNDS;
				---------------
        else								-- nomme statique
				-- RM83 4.3.2 : bornes = min/max des choix
				-- (couverture contigue garantie par sem).
	EMIT_LI( MIN_CHOICE );
	PUT_LINE( tab & "Sd  " & LVL_STR & ", " & INFO_STR & "._FST_1" );
	EMIT_LI( MAX_CHOICE );
	PUT_LINE( tab & "Sd  " & LVL_STR & ", " & INFO_STR & "._LST_1" );
	EMIT_LI( MAX_CHOICE - MIN_CHOICE + 1 );				-- COUNT
        end if;

        -- ---- COMP_SIZ ; SIZ := COUNT * COMP_BITS ----
        PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BITS ) );
        PUT_LINE( tab & "Sd  " & LVL_STR & ", " & INFO_STR & "._COMP_SIZ" );
        PUT_LINE( tab & "DUP" );						-- COUNT preserve pour l'allocation
        if  COMP_BITS /= 1  then
	PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BITS ) );
	PUT_LINE( tab & "MUL" );
        end if;
        PUT_LINE( tab & "Sd  " & LVL_STR & ", " & INFO_STR & ".SIZ" );

        -- ---- Allocation co-pile : COUNT * COMP_BYTES octets ----
        if  COMP_BYTES /= 1  then
	PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BYTES ) );
	PUT_LINE( tab & "MUL" );
        end if;
        PUT_LINE( tab & "CO_VAR" );
        PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "_disp" );
        if  CODI.DEBUG  then PUT( tab50 & "; array data ptr at _disp" ); end if;
        NEW_LINE;

        -- ---- Re-pointer __u sur le bloc anonyme (ecrase use__info du type) ----
        PUT_LINE( tab & "LVA " & LVL_STR & ", " & INFO_STR & ".SIZ" );
        PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "__u" );
        if  CODI.DEBUG  then PUT( tab50 & "; array info ptr at __u (agregat, bornes deduites)" ); end if;
        NEW_LINE;

        -- ---- Donnees : chemin existant inchange ----
        PUT_LINE( tab & "La" & tab & LVL_STR & ", " & VC_STR & "_disp" );
        EXPRESSIONS.CODE_AGGREGATE( AGG, TYPE_SPEC );

      end	UNCONSTRAINED_AGGREGATE_OBJECT;
	------------------------------

      begin

        declare
	SOURCE_CONSTRAINT		: TREE		:= TREE_VOID;
        begin
	if  OBJECT_DECL /= TREE_VOID  and then  D( AS_TYPE_DEF, OBJECT_DECL ) /= TREE_VOID  then
	  declare
	    TYPE_DEF	: TREE	:= D( AS_TYPE_DEF, OBJECT_DECL );
	  begin
	    if  TYPE_DEF.TY = DN_SUBTYPE_INDICATION  then
	      SOURCE_CONSTRAINT := D( AS_CONSTRAINT, TYPE_DEF );
	    elsif  TYPE_DEF.TY = DN_CONSTRAINED_ARRAY_DEF  then
	      SOURCE_CONSTRAINT := D( AS_CONSTRAINT, TYPE_DEF );
	    end if;
	  end;
          end if;

	if  SOURCE_CONSTRAINT /= TREE_VOID  or else  DB( CD_COMPILED, TYPE_SPEC ) = FALSE  then
	  ANONYMOUS_SUBTYPE := TRUE;
	  USE_LOCAL_TYPE_INFO := TRUE;
	  PUT_LINE( LOCAL_TYPE_INFO_STR & " = '" & LOCAL_TYPE_INFO_STR & "'" );
	  PUT( "namespace " & LOCAL_TYPE_INFO_STR );
	  if  CODI.DEBUG  then PUT( tab50 & "; array var constrained array type info" ); end if;
	  NEW_LINE;
	  TYPES_DECLS.PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( TYPE_SPEC, SOURCE_CONSTRAINT );
	end if;
        end;

        TYPE_LEVEL := DI( CD_LEVEL, TYPE_SPEC );

        PUT( "VAR "	& VC_STR & "_disp, q" );
        if  CODI.DEBUG  then PUT( tab50	& "; variable array : pointeur aux data" ); end if;
        NEW_LINE;
        PUT( "VAR "	& VC_STR & "__u, q"	);
        if  CODI.DEBUG  then PUT( tab50	& "; variable array : useinfo pointeur au rec info" ); end if;
        NEW_LINE;

        DI( CD_LEVEL, VC_NAME, INTEGER(	LVL ) );

        PUT( tab & "La" & INTEGER'IMAGE( TYPE_LEVEL ) & ", " );						-- LOAD ADDRESS FOR	INFO
        PUT_TYPE_INFO_PREFIX;
        PUT_LINE( ".use__info" );

        PUT( tab & "Sa" & tab	& LVL_STR	& ", " & VC_STR & "__u" );
        if  CODI.DEBUG  then PUT( tab50	& "; array info ptr at __u" ); end if;
        NEW_LINE;
				----------
				INITIALIZE:
        declare
	INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );
        begin
	if  INIT_EXP /= TREE_VOID  then

	  if  INIT_EXP.TY =	DN_STRING_LITERAL								-- vraie constante chaine
	  then
	    EXPRESSIONS.CODE_STRING_LITERAL( INIT_EXP, VC_STR );

	    PUT_LINE( tab &	"LCA" & tab & VC_STR & ".data_ptr" );
	    PUT_LINE( tab &	"La" );
	    PUT( tab & "Sa"	& tab & LVL_STR & ", " & VC_STR & "_disp" );
	    if  CODI.DEBUG	then PUT(	tab50 & "; array data ptr at _disp" ); end if;
	    NEW_LINE;

	    PUT_LINE( tab &	"LCA" & tab & VC_STR & ".info_ptr" );						-- LOAD CONSTANT ADDRESS FOR INFO
	    PUT_LINE( tab &	"La" );
	    PUT( tab & "Sa"	& tab & LVL_STR & ", " & VC_STR & "__u"	);
	    if  CODI.DEBUG	then PUT(	tab50 & "; array info ptr at __u" ); end if;
	    NEW_LINE;

	  elsif  INIT_EXP.TY = DN_FUNCTION_CALL								-- retour	de STRING	par fonction par exemple
	  then
	    EXPRESSIONS.CODE_EXP( INIT_EXP );								-- appel fonction, resultat =	adresse du descripteur

	    PUT_LINE( tab &	"DUP" );									-- dupliquer l'adresse du descripteur
	    PUT_LINE( tab &	"La" );									-- charger data_ptr	(qword a offset 0)
	    PUT( tab & "Sa"	& tab & LVL_STR & ", " & VC_STR & "_disp" );
	    if  CODI.DEBUG	then PUT(	tab50 & "; array data ptr from function result" ); end if;
	    NEW_LINE;

	    PUT_LINE( tab &	"La , 8" );								-- offset	+8 pour info_ptr
	    PUT( tab & "Sa"	& tab & LVL_STR & ", " & VC_STR & "__u"	);
	    if  CODI.DEBUG	then PUT(	tab50 & "; array info ptr from function result" ); end if;
	    NEW_LINE;


	  elsif  INIT_EXP.TY = DN_AGGREGATE  then
	    if  TYPE_SPEC.TY = DN_ARRAY  then								-- objet NON contraint : bornes déduites
	      UNCONSTRAINED_AGGREGATE_OBJECT( INIT_EXP );							-- nouveau, ci-dessous

	    else
	      COVAR_ALLOCATE;
	      if  CODI.DEBUG  then PUT( tab50 & "; array data aggregate" ); end if;
	      NEW_LINE;

	      PUT_LINE( tab &  "La" & tab & LVL_STR & ", " & VC_STR & "_disp" );
	      EXPRESSIONS.CODE_AGGREGATE( INIT_EXP, TYPE_SPEC );
	    end if;


	  elsif  INIT_EXP.TY = DN_QUALIFIED  then
  -- Initialiseur tableau qualifie : P.E2'(4 => 8, 5 => 3, OTHERS => 1).
  -- Il faut allouer l'objet destination ici, puis coder l'agregat
  -- dans les donnees de cet objet. CODE_QUALIFIED seul construit
  -- une valeur d'expression et ne remplace pas l'initialisation.
  	    declare
  	      QUAL_EXP : TREE := D( AS_EXP, INIT_EXP );
	    begin
	      if  QUAL_EXP.TY = DN_AGGREGATE  then
	        COVAR_ALLOCATE;
	        if  CODI.DEBUG  then
	          PUT( tab50 & "; array data qualified aggregate" );
	        end if;
	        NEW_LINE;

	        PUT_LINE( tab & "La" & tab & LVL_STR & ", " & VC_STR & "_disp" );
	        EXPRESSIONS.CODE_AGGREGATE( QUAL_EXP, TYPE_SPEC );

	      else
      -- Repli defensif : expression qualifiee non-agregat retournant
      -- un doublet tableau ; on copie les donnees vers la destination.
	        COVAR_ALLOCATE;
	        PUT_LINE( tab & "La" & tab & LVL_STR & ", " & VC_STR & "_disp" );
	        PUT( tab & "Ld" & tab & IMAGE( TYPE_LEVEL ) & ", " );
	        PUT_TYPE_INFO_PREFIX;
	        PUT_LINE( ".SIZ" );
	        PUT_LINE( tab & "LI" & tab & '8' );
	        PUT_LINE( tab & "DIV" );
	        EXPRESSIONS.CODE_EXP( INIT_EXP );
	        PUT_LINE( tab & "La" & tab & ", 0" );
	        PUT_LINE( tab & "BLKMOV" );
	      end if;
	    end;

	  elsif  INIT_EXP.TY = DN_FUNCTION_CALL  then
	    EXPRESSIONS.CODE_EXP( INIT_EXP );

	  else
	    PUT_LINE( "; COMPILE_ARRAY_VAR ASSOC.TY non gere " & NODE_NAME'IMAGE( INIT_EXP.TY ) );
	  end if;

	else											-- PAS D'INITIALISATION, ALLOUER
	  COVAR_ALLOCATE;

	end if;
        end			INITIALIZE;
				----------

        DI( CD_LEVEL,	VC_NAME, INTEGER( LVL ) );
        DB( CD_COMPILED,	VC_NAME, TRUE );

      end	COMPILE_ARRAY_VAR;
	-----------------


		------------------
      procedure	COMPILE_RECORD_VAR		( VC_NAME, TYPE_SPEC :TREE )
      is		------------------

        VC_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, VC_NAME ) );
        VC_ADDRESS		: TREE		:= D( SM_ADDRESS, VC_NAME );					-- adresse éventuelle
        INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );
        LVL		: LEVEL_NUM	renames CODI.CUR_LEVEL;
        LVL_STR		:constant	STRING	:= IMAGE(	LVL );
        TYPE_NAME		: TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
        TYPE_NAME_STR	:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );

      begin
        PUT( "VAR "	& VC_STR & "_disp, q" );								-- Ptr to	rec
        if  CODI.DEBUG  then	PUT( tab50 & "; variable record : pointeur aux data record"	); end if;
        NEW_LINE;
        PUT( "VAR "	& VC_STR & "__u, q"	);								-- Ptr to	rec
        if  CODI.DEBUG  then	PUT( tab50 & "; variable record : pointeur aux useinfo" ); end if;
        NEW_LINE;

        if  VC_ADDRESS /= TREE_VOID  then								-- Clause	adressage	présente
	PUT_LINE(	tab & "LI" & tab & PRINT_NUM(	D( SM_VALUE, VC_ADDRESS ) ) );
	PUT_LINE(	tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "_disp" );					-- Stocker l'adresse du rec dans le ptr

        else
	PUT( "VAR " & VC_STR & "__dat, " );								-- Espace	data
	REGIONS_PATH( TYPE_NAME );
	PUT_LINE(	TYPE_NAME_STR & ".size" );

	PUT_LINE(	tab & "LVA" & tab &	LVL_STR &	", " & VC_STR & "__dat" );
	PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR &	"_disp" );					-- Stocker l'adresse du rec dans le ptr
	if  CODI.DEBUG   then  PUT( tab50 & "; record fin" ); end if;
	NEW_LINE;
        end if;

        PUT( tab & "LVA" & tab & LVL_STR & ", " );
        REGIONS_PATH( TYPE_NAME );
        PUT_LINE( TYPE_NAME_STR & ".SIZ" );
        PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "__u" );

        DI( CD_LEVEL, VC_NAME, INTEGER( LVL ) );

put_line( "; CODE_VC_NAME " & NODE_NAME'IMAGE( VC_NAME.TY ) );

        if  VC_NAME.TY = DN_CONSTANT_ID  and then  D( SM_FIRST, VC_NAME ) /= VC_NAME  then			-- Cas de differe
	DI( CD_LEVEL, D( SM_FIRST, VC_NAME ), INTEGER( LVL ) );
        end if;
        DB( CD_COMPILED,  VC_NAME, TRUE	);

        if  INIT_EXP.TY = DN_AGGREGATE	then
	PUT_LINE( tab & "La " & LVL_STR & ", " & VC_STR & "_disp" );					-- Adresse de debut data
	EXPRESSIONS.CODE_AGGREGATE( INIT_EXP, TYPE_SPEC );


        elsif  INIT_EXP /= TREE_VOID  then
          -- Initialisation par expression quelconque (function_call, variable, ...) retournant un record
          -- @DST = data_ptr de la variable destination
          PUT_LINE( tab & "La  " & LVL_STR & ", " & VC_STR & "_disp" );   -- @DST

          declare
            TYPE_NAME2  : TREE            := D( XD_SOURCE_NAME, TYPE_SPEC );
            TN_STR2     : constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME2 ) );
          begin
            PUT( tab & "LI" & tab );
            CODI.REGIONS_PATH( TYPE_NAME2 );
            PUT_LINE( TN_STR2 & ".size" );                                 -- LEN
          end;

          EXPRESSIONS.CODE_EXP( INIT_EXP );                                -- empile @doublet source
          PUT_LINE( tab & "La  ,  0" );                                    -- @SRC = data_ptr source

          PUT_LINE( tab & "BLKMOV" );
        else
				-- Pilier 3.7 : elaboration des VALEURS de discriminants.
				-- Vue contrainte : SM_NORMALIZED_DSCRMT_S (expressions dans
				-- l'ordre des discriminants du record de base).
				-- Type a defauts (3.7.1) : SM_INIT_EXP des DISCRIMINANT_ID.
				-- Les offsets sont adresses via le namespace du record de BASE
				-- (les vues contraintes, nommees ou anonymes, n'ont que des alias).
	declare
	  BASE_REC	: TREE	:= TYPE_SPEC;
	  DSCRMT_EXP_S	: SEQ_TYPE;
	  USE_NORM	: BOOLEAN	:= FALSE;
	begin
	  if  TYPE_SPEC.TY = DN_CONSTRAINED_RECORD  then
	    BASE_REC     := D( SM_BASE_TYPE, TYPE_SPEC );
	    DSCRMT_EXP_S := LIST( D( SM_NORMALIZED_DSCRMT_S, TYPE_SPEC ) );
	    USE_NORM     := TRUE;
	  end if;

	  if  BASE_REC.TY = DN_RECORD  then
	    declare
	      BASE_NAME	: TREE		:= D( XD_SOURCE_NAME, BASE_REC );
	      BASE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, BASE_NAME ) );
	      DSCRMT_DECL_S	: SEQ_TYPE	:= LIST( D( SM_DISCRIMINANT_S, BASE_REC ) );
	      DSCRMT_DECL	: TREE;
	      DSCRMT_EXP	: TREE;
	    begin
	      while  not IS_EMPTY( DSCRMT_DECL_S )  loop
	        POP( DSCRMT_DECL_S, DSCRMT_DECL );
	        declare
	          DISCR_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, DSCRMT_DECL ) );
	          DISCR_ID	: TREE;
	        begin
	          while  not IS_EMPTY( DISCR_ID_S )  loop
	            POP( DISCR_ID_S, DISCR_ID );

	            if  USE_NORM  then
	              if  IS_EMPTY( DSCRMT_EXP_S )  then
	                PUT_LINE( "; COMPILE_RECORD_VAR : contrainte normalisee incomplete" );
	                raise PROGRAM_ERROR;
	              end if;
	              POP( DSCRMT_EXP_S, DSCRMT_EXP );
	            else
	              DSCRMT_EXP := D( SM_INIT_EXP, DISCR_ID );		-- defaut eventuel (3.7.1)
	            end if;

	            if  DSCRMT_EXP /= TREE_VOID  and then  DSCRMT_EXP /= TREE_NIL  then
	              PUT( tab & "LIVA "
	                & LVL_STR & ", "
	                & VC_STR & "_disp, " );
	              CODI.REGIONS_PATH( BASE_NAME );
	              PUT_LINE( BASE_STR & "."
	                & PRINT_NAME( D( LX_SYMREP, DISCR_ID ) ) );
	              EXPRESSIONS.CODE_EXP( DSCRMT_EXP );
	              PUT_LINE( tab & "S"
	                & CODI.OPER_SIZ_CHAR( D( SM_OBJ_TYPE, DISCR_ID ) ) );
	            end if;
	          end loop;
	        end;
	      end loop;
	    end;
	  end if;
	end;

				-- No explicit aggregate : initialize
				-- fields	that have	default values
	declare
	  COMP_DECL_S	: SEQ_TYPE;
	  COMP_DECL	: TREE;
	begin
	  if  TYPE_SPEC.TY = DN_CONSTRAINED_RECORD  then
	    COMP_DECL_S := LIST( D( AS_DECL_S, D( SM_COMP_LIST, D( SM_BASE_TYPE, TYPE_SPEC ) ) ) );

	  else
	    COMP_DECL_S := LIST( D( AS_DECL_S, D( SM_COMP_LIST, TYPE_SPEC ) ) );

	  end if;

	  while  not IS_EMPTY( COMP_DECL_S )  loop
	    POP( COMP_DECL_S, COMP_DECL );

	    if  COMP_DECL.TY /= DN_NULL_COMP_DECL  then

	    declare
	      COMP_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S,	COMP_DECL	) );
	      COMP_ID	: TREE;
	    begin
	      while  not IS_EMPTY( COMP_ID_S )	loop
	        POP( COMP_ID_S, COMP_ID );
	        declare
		FIELD_INIT	: TREE		:= D( SM_INIT_EXP, COMP_ID );
		COMP_TYPE		: TREE		:= D( SM_OBJ_TYPE, COMP_ID );
		COMP_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, COMP_ID ) );
	        begin
		if  FIELD_INIT /= TREE_VOID  then
		  if  FIELD_INIT.TY = DN_AGGREGATE  then						-- composant composite : descente recursive
		    PUT( tab & "LIVa "
		      & LVL_STR & ", "
		      & VC_STR & "_disp, " );
		    CODI.REGIONS_PATH( TYPE_NAME );
		    PUT_LINE( TYPE_NAME_STR & "."
		      & COMP_STR );
		    EXPRESSIONS.CODE_AGGREGATE( FIELD_INIT, COMP_TYPE );					-- l'adresse du champ est sur la pile, CODE_AGGREGATE la consomme

		  else										-- composant scalaire : store direct
		    PUT( tab & "LIVa "
		      & LVL_STR & ", "
		      & VC_STR & "_disp, " );
		    CODI.REGIONS_PATH( TYPE_NAME );
		    PUT_LINE( TYPE_NAME_STR & "."
		      & COMP_STR );
		    EXPRESSIONS.CODE_EXP( FIELD_INIT );
		    PUT_LINE( tab & "S"
		      & CODI.OPER_SIZ_CHAR( COMP_TYPE ) );
		  end if;
		end if;
	        end;
	      end	loop;
	    end;
	    end if;
	  end loop;
	end;
        end if;
      end	COMPILE_RECORD_VAR;
	------------------


      function FULL_VIEW ( TYPE_SPEC : TREE ) return TREE is
        TS	: TREE	:= TYPE_SPEC;
      begin
        loop
	if  TS.TY = DN_L_PRIVATE  or  TS.TY = DN_PRIVATE  then
	  TS := D( SM_TYPE_SPEC, TS );

	elsif  TS.TY = DN_INCOMPLETE  then
	  TS := D( XD_FULL_TYPE_SPEC, TS );

	else
	  return  TS;
	end if;
        end loop;

      end	FULL_VIEW;
	---------

    begin
      TYPE_SPEC := FULL_VIEW( TYPE_SPEC );

      case TYPE_SPEC.TY is
      when DN_ENUMERATION		=> TYPE_SYMREP := D( XD_SOURCE_NAME, TYPE_SPEC );
				   COMPILE_VC_NAME_ENUMERATION(	VC_NAME, TYPE_SPEC );
      when DN_INTEGER		=> COMPILE_VC_NAME_INTEGER(		VC_NAME );
      when DN_FIXED			=> COMPILE_VC_NAME_FIXED(		VC_NAME );
      when DN_FLOAT			=> COMPILE_VC_NAME_FLOAT(		VC_NAME );
      when DN_ACCESS		=> COMPILE_ACCESS_VAR(		VC_NAME, TYPE_SPEC );
      when DN_CONSTRAINED_RECORD
	| DN_RECORD		=> COMPILE_RECORD_VAR(		VC_NAME, TYPE_SPEC );
      when DN_CONSTRAINED_ARRAY
	| DN_ARRAY		=> COMPILE_ARRAY_VAR(		VC_NAME, TYPE_SPEC );
      when others =>
        PUT_LINE( "; ERREUR CODE_VC_NAME, TYPE_SPEC.TY = " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
        raise PROGRAM_ERROR;
      end	case;
    end;
    NEW_LINE;

  end	CODE_VC_NAME;
	------------



  --|-------------------------------------------------------------------------------------------
  procedure	CODE_TASK_DECL ( TASK_DECL :TREE )
  is
  begin
    null;
  end;


			---------------------
  procedure		CODE_RENAMES_OBJ_DECL	( RENAMES_OBJ_DECL :TREE )
  is			---------------------

    SOURCE_NAME	: TREE	:= D( AS_SOURCE_NAME, RENAMES_OBJ_DECL );

  begin
    if  SOURCE_NAME.TY in CLASS_VC_NAME  then
      declare
        NAME	: TREE		:= D( SM_INIT_EXP, SOURCE_NAME );
        SRC_STR	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, SOURCE_NAME ) );
        SRC_TYPE	: TREE		:= D( SM_OBJ_TYPE, SOURCE_NAME );
        LVL	: LEVEL_NUM	renames CODI.CUR_LEVEL;
        LVL_STR	: constant STRING	:= IMAGE( LVL );
      begin
        if NAME = TREE_VOID then
	NAME := D( AS_NAME, RENAMES_OBJ_DECL );
        end if;

        while  SRC_TYPE.TY = DN_PRIVATE  or else  SRC_TYPE.TY = DN_L_PRIVATE  loop
	SRC_TYPE := D( SM_TYPE_SPEC, SRC_TYPE );
        end loop;

      -- Le renommage est représenté par un pointeur vers les données réelles.
 --       PUT_LINE( "VAR " & SRC_STR & "_disp, q" );

 --       EXPRESSIONS.CODE_OBJECT_ADDRESS( NAME );
 --       PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & SRC_STR & "_disp" );

      -- Pour les composites, on garde le doublet TLALOC habituel.
 --       if  SRC_TYPE.TY = DN_RECORD  or else  SRC_TYPE.TY = DN_ARRAY  or else  SRC_TYPE.TY = DN_CONSTRAINED_ARRAY
 --       then
--	declare
--	  TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, SRC_TYPE );
--	  TYPE_NAME_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
--	begin
--	  PUT_LINE( "VAR " & SRC_STR & "__u, q" );

--	  PUT( tab & "LVA" & tab & LVL_STR & ", " );
--	  CODI.REGIONS_PATH( TYPE_NAME );
--	  PUT_LINE( TYPE_NAME_STR & ".SIZ" );

--	  PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & SRC_STR & "__u" );
--	end;
--        end if;

      -- Cas particulier important : une tranche est un objet composite dont
      -- les bornes peuvent etre dynamiques. Il faut donc reprendre le doublet
      -- anonyme construit par CODE_SLICE, et non pointer vers le use_info du
      -- type source complet.
        declare
	IS_COMPOSITE : constant BOOLEAN :=
	    SRC_TYPE.TY = DN_RECORD
	    or else SRC_TYPE.TY = DN_ARRAY
	    or else SRC_TYPE.TY = DN_CONSTRAINED_ARRAY;
        begin
	  if  IS_COMPOSITE  and then  NAME.TY = DN_SLICE  then
	    PUT_LINE( "VAR " & SRC_STR & "_disp, q" );
	    PUT_LINE( "VAR " & SRC_STR & "__u, q" );

	    EXPRESSIONS.CODE_SLICE( NAME, IS_DESTINATION => FALSE );
	    PUT_LINE( tab & "DUP" );
	    PUT_LINE( tab & "La" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & SRC_STR & "_disp" );
	    PUT_LINE( tab & "La" & tab & ", 8" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & SRC_STR & "__u" );

	  else
	    PUT_LINE( "VAR " & SRC_STR & "_disp, q" );

	    EXPRESSIONS.CODE_OBJECT_ADDRESS( NAME );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & SRC_STR & "_disp" );

	  -- Pour les composites non-tranches, on garde le doublet TLALOC habituel.
	    if  IS_COMPOSITE  then
	      declare
	        TYPE_NAME		: TREE		:= D( XD_SOURCE_NAME, SRC_TYPE );
	        TYPE_NAME_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	      begin
	        PUT_LINE( "VAR " & SRC_STR & "__u, q" );

	        PUT( tab & "LVA" & tab & LVL_STR & ", " );
	        CODI.REGIONS_PATH( TYPE_NAME );
	        PUT_LINE( TYPE_NAME_STR & ".SIZ" );

	        PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & SRC_STR & "__u" );
	      end;
	    end if;
	  end if;
        end;

        DI( CD_LEVEL, SOURCE_NAME, INTEGER( LVL ) );
        DB( CD_COMPILED, SOURCE_NAME, TRUE );
      end;
    end if;

  end	CODE_RENAMES_OBJ_DECL;
	---------------------


  --|-------------------------------------------------------------------------------------------
  procedure	CODE_RENAMES_EXC_DECL ( RENAMES_EXC_DECL :TREE )
  is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure	CODE_SIMPLE_RENAME_DECL ( SIMPLE_RENAME_DECL :TREE )
  is
  begin

    if SIMPLE_RENAME_DECL.TY = DN_RENAMES_OBJ_DECL then
      CODE_RENAMES_OBJ_DECL (	SIMPLE_RENAME_DECL );

    elsif	SIMPLE_RENAME_DECL.TY = DN_RENAMES_EXC_DECL then
      CODE_RENAMES_EXC_DECL (	SIMPLE_RENAME_DECL );

    end if;
  end	CODE_SIMPLE_RENAME_DECL;



 procedure CODE_NAMED_REP	( NAMED_REP :TREE );
 procedure CODE_RECORD_REP	( RECORD_REP :TREE );

			--------
 procedure		CODE_REP		( REP :TREE )
 is			--------
  begin

    if REP.TY in CLASS_NAMED_REP
    then	CODE_NAMED_REP ( REP );

    elsif	REP.TY = DN_RECORD_REP
    then	CODE_RECORD_REP ( REP );

    end if;
  end	CODE_REP;
	--------


			--------------
  procedure		CODE_NAMED_REP	( NAMED_REP :TREE )
  is			--------------
  begin

    if NAMED_REP.TY	= DN_ADDRESS
    then null; -- CODE_ADDRESS ( NAMED_REP );

    elsif	NAMED_REP.TY = DN_LENGTH_ENUM_REP
    then null; -- CODE_LENGTH_ENUM_REP ( NAMED_REP );

    end if;
  end	CODE_NAMED_REP;
	--------------



			---------------
  procedure		CODE_RECORD_REP	( RECORD_REP :TREE )
  is			---------------
  begin
    null;	-- CODE_ALIGNMENT_CLAUSE ( D ( AS_ALIGNMENT_CLAUSE, RECORD_REP ) );
  end	CODE_RECORD_REP;
	---------------


			----------------------------------------------------

			--	DECL . ID_DECL .  U	N I T _ D	E C L	--

			----------------------------------------------------


  procedure CODE_NON_GENERIC_DECL	( NON_GENERIC_DECL :TREE );

		--------------
  procedure	CODE_UNIT_DECL		( UNIT_DECL :TREE )
  is		--------------
  begin

    if UNIT_DECL.TY	= DN_GENERIC_DECL
    then	CODE_GENERIC_DECL (	UNIT_DECL	);

    elsif	UNIT_DECL.TY in CLASS_NON_GENERIC_DECL
    then	CODE_NON_GENERIC_DECL ( UNIT_DECL );

    end if;

  end	CODE_UNIT_DECL;
	--------------



			--=============--
  procedure		CODE_GENERIC_DECL		( GENERIC_DECL :TREE )
  is			--=============--

    GENERIC_ID	: TREE		:= D( AS_SOURCE_NAME, GENERIC_DECL );
    G_PARAMS	: SEQ_TYPE	:= LIST( D( SM_GENERIC_PARAM_S, GENERIC_ID ) );
    G_PARAM	: TREE;
    G_SPEC	: TREE		:= D( SM_SPEC, GENERIC_ID);

  begin

				------------------------
				TRAITE_FORMAL_PARAMETERS:
    while	 not IS_EMPTY( G_PARAMS )  loop
      POP( G_PARAMS, G_PARAM );
      if	G_PARAM.TY = DN_TYPE_DECL  then
        if  D( AS_TYPE_DEF, G_PARAM ).TY = DN_FORMAL_INTEGER_DEF  then
	DI( CD_IMPL_SIZE, D( SM_TYPE_SPEC, D( AS_SOURCE_NAME, G_PARAM ) ), INTG_SIZE * 8 );

        elsif  D( AS_TYPE_DEF, G_PARAM ).TY = DN_FORMAL_DSCRT_DEF  then
	DI( CD_IMPL_SIZE, D( SM_TYPE_SPEC, D( AS_SOURCE_NAME, G_PARAM ) ), INTG_SIZE * 8 );
        end if;
      end	if;
    end loop	TRAITE_FORMAL_PARAMETERS;
		------------------------

    if  G_SPEC.TY = DN_PROCEDURE_SPEC  or  G_SPEC.TY = DN_FUNCTION_SPEC  then
      PUT_LINE( "; GENERIC_SUBPROGRAM_SPEC" );

    else
      declare
        DECL_S	: SEQ_TYPE	:= LIST( D( AS_DECL_S1, D( AS_HEADER, GENERIC_DECL ) ) );
        DECL	: TREE;

      begin
        while  not IS_EMPTY( DECL_S )  loop
	POP( DECL_S, DECL );
	if  DECL.TY = DN_SUBPROG_ENTRY_DECL  and then  IN_SPEC_UNIT	 then
	  declare
	    LBL	: LABEL_TYPE	:= NEW_LABEL;
	    NAME	: TREE		:= D( AS_SOURCE_NAME, DECL );
	  begin
	    DI( CD_LABEL, NAME, INTEGER( LBL ) );
	    DI( CD_LEVEL, NAME, INTEGER( CODI.CUR_LEVEL )	+ 1 );
	    DB( CD_COMPILED, D( AS_SOURCE_NAME,	DECL ), TRUE );
	  end;
	end if;
        end loop;
      end;
    end if;

  end	CODE_GENERIC_DECL;
	--=============--



			---------------------
  procedure		CODE_NON_GENERIC_DECL	( NON_GENERIC_DECL :TREE )
  is			---------------------
  begin

    if  NON_GENERIC_DECL.TY =	DN_SUBPROG_ENTRY_DECL
    then	CODE_SUBPROG_ENTRY_DECL( NON_GENERIC_DECL );

    elsif	NON_GENERIC_DECL.TY	= DN_PACKAGE_DECL
    then	CODE_PACKAGE_DECL( NON_GENERIC_DECL );

    end if;
  end	CODE_NON_GENERIC_DECL;
	---------------------


			--------------------
  procedure		CODE_GENERIC_ACTUALS	( UNIT_KIND :TREE; ACTUALS_PREFIX :STRING := "";
						  ACTUALS_LEVEL :LEVEL_NUM := CODI.CUR_LEVEL )
  is			--------------------

    GNAME_SEQ	: SEQ_TYPE	:= LIST( D( AS_GENERAL_ASSOC_S, UNIT_KIND ) );
    FORMAL_SEQ	: SEQ_TYPE;
    ACTUAL	: TREE;
    FORMAL	: TREE;

		-----------
    function	GENERIC_DEF	return TREE
    is		-----------
      GEN_NAME	: TREE	:= D( AS_NAME, UNIT_KIND );
    begin
      while  GEN_NAME.TY = DN_SELECTED  loop
        GEN_NAME := D( AS_DESIGNATOR, GEN_NAME );
      end loop;
      return  D( SM_DEFN, GEN_NAME );

    end	GENERIC_DEF;
	-----------

		----------------
    function	ACTUAL_NAME_DEFN	( A :TREE )	return TREE
    is		----------------
      N	: TREE	:= A;
    begin
      while  N.TY = DN_SELECTED  loop
        N := D( AS_DESIGNATOR, N );
      end loop;

      return  D( SM_DEFN, N );

    end	ACTUAL_NAME_DEFN;
	----------------

  begin
    FORMAL_SEQ := LIST( D( SM_GENERIC_PARAM_S, GENERIC_DEF ) );

    while  not IS_EMPTY( GNAME_SEQ )  loop
      POP( GNAME_SEQ, ACTUAL );
      POP( FORMAL_SEQ, FORMAL );

      if  ACTUAL.TY = DN_ASSOC  then
        ACTUAL := D( AS_EXP, ACTUAL );
      end if;

--      while  ACTUAL.TY = DN_SELECTED  loop
--        ACTUAL := D( AS_NAME, ACTUAL );
--      end loop;

      declare
        DEFN		: TREE;
        LVL_STR		:constant	STRING	:= LEVEL_NUM'IMAGE(	ACTUALS_LEVEL );

      begin
        if  FORMAL.TY = DN_IN  or else  FORMAL.TY = DN_IN_OUT  or else  FORMAL.TY = DN_OUT  then

				---------------------
				ACTUAL_GENERIC_OBJECT:
	declare
	  NAME_SEQ	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, FORMAL ) );
	  ACTUAL_TYPE	: TREE		:= D( SM_EXP_TYPE, ACTUAL );
	  FORMAL_NAME	: TREE;
		------------------------
	procedure CODE_ACTUAL_OBJECT_VALUE	( ACTUAL :TREE; FORMAL_TYPE :TREE )
	is	------------------------
	   ANON	:constant STRING	:= "STR_" & NEW_LABEL;
	begin
	  if  FORMAL_TYPE.TY in CLASS_SCALAR  or else  FORMAL_TYPE.TY = DN_ACCESS  then
	      -- '&' caractère, entier, enum, variable scalaire, etc.
	    EXPRESSIONS.CODE_EXP( ACTUAL );

	  else
	      -- composite : il faut laisser @doublet sur pile
	    if ACTUAL.TY = DN_STRING_LITERAL then
	      EXPRESSIONS.CODE_STRING_LITERAL( ACTUAL, ANON );
	      PUT_LINE( tab & "LCA" & tab & ANON & ".data_ptr" );
	    else
	      EXPRESSIONS.CODE_EXP( ACTUAL );
	    end if;
	  end if;
	end	CODE_ACTUAL_OBJECT_VALUE;
		------------------------

	begin
	  while  ACTUAL_TYPE.TY = DN_PRIVATE  or else  ACTUAL_TYPE.TY = DN_L_PRIVATE  loop
	    ACTUAL_TYPE := D( SM_TYPE_SPEC, ACTUAL_TYPE );
	  end loop;

	  while  not IS_EMPTY( NAME_SEQ )  loop
	    POP( NAME_SEQ, FORMAL_NAME );

	    declare
	      FORMAL_STR	:constant STRING	:= ACTUALS_PREFIX & PRINT_NAME( D( LX_SYMREP, FORMAL_NAME ) );

	    begin
	      if  ACTUAL_TYPE.TY in CLASS_SCALAR  or else  ACTUAL_TYPE.TY = DN_ACCESS  then
	        PUT_LINE( "VAR " & FORMAL_STR & "_disp, q" );

	        CODE_ACTUAL_OBJECT_VALUE( ACTUAL, ACTUAL_TYPE );

	        PUT_LINE( tab & "S" & OPER_SIZ_CHAR( ACTUAL_TYPE ) & " " & LVL_STR & ", " & FORMAL_STR & "_disp" );

	      else
	        PUT_LINE( "VAR " & FORMAL_STR & "_disp, q" );
	        PUT_LINE( "VAR " & FORMAL_STR & "__u, q" );

	        CODE_ACTUAL_OBJECT_VALUE( ACTUAL, ACTUAL_TYPE );
	        PUT_LINE( tab & "DUP" );
	        PUT_LINE( tab & "La  ,  0" );
	        PUT_LINE( tab & "Sa " & LVL_STR & ", " & FORMAL_STR & "_disp" );
	        PUT_LINE( tab & "La  ,  8" );
	        PUT_LINE( tab & "Sa " & LVL_STR & ", " & FORMAL_STR & "__u" );
	      end if;
	    end;
	  end loop;
	end		ACTUAL_GENERIC_OBJECT;
			---------------------


        elsif  FORMAL.TY = DN_TYPE_DECL  or  FORMAL.TY = DN_SUBTYPE_DECL  then
	DEFN := D( SM_DEFN, ACTUAL );

				-------------------
				ACTUAL_GENERIC_TYPE:
	declare
	  DEFN_TYPE_SPEC	: TREE		:= D( SM_TYPE_SPEC,	DEFN );
	  DEFN_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
	  FORMAL_ID	: TREE		:= D( AS_SOURCE_NAME, FORMAL );
	  FORMAL_STR	:constant STRING	:= ACTUALS_PREFIX & PRINT_NAME( D( LX_SYMREP, FORMAL_ID ) );
	begin

	  if  DEFN_TYPE_SPEC.TY  in  CLASS_SCALAR  then
	        -- Micro-procedures LD et ST pour le type	actuel (contournees	par BRA)
	    declare
	      SIZ_CHAR	: CHARACTER	:= OPER_SIZ_CHAR( DEFN_TYPE_SPEC );
	    begin
		-- LD : pile = [adresse] → pile = [valeur]
	      PUT_LINE(	"BRA post_LD_" & FORMAL_STR );
	      PUT_LINE(	"LD_" & FORMAL_STR & ".elab:" );
	      PUT_LINE(	tab & "L"	& SIZ_CHAR & " -1, 0" );
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_LD_" & FORMAL_STR & ":" );

		-- ST : pile = [@param_out, valeur] →	pile = []
	      PUT_LINE(	"BRA post_ST_" & FORMAL_STR );
	      PUT_LINE(	"ST_" & FORMAL_STR & ".elab:" );
	      PUT_LINE(	tab & "S" & SIZ_CHAR & " -1, 0" );
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_ST_" & FORMAL_STR & ":" );
		-- ADR : pile = [@param_out, valeur] → pile = []

	      PUT_LINE(	"BRA post_INADR_" &	FORMAL_STR );
	      PUT_LINE(	"INADR_" & FORMAL_STR & ".elab:" );
	      PUT_LINE(	tab & "RTD 0" );								-- Rien a	faire pour un scalaire
	      PUT_LINE(	"post_INADR_" & FORMAL_STR & ":" );

	      PUT_LINE(	"BRA post_OUTADR_" & FORMAL_STR );
	      PUT_LINE(	"OUTADR_"	& FORMAL_STR & ".elab:" );
	      PUT_LINE(	tab & "La" );								-- Pointer Data
	      PUT_LINE(	tab & "RTD 0" );								-- Rien a	faire pour un scalaire
	      PUT_LINE(	"post_OUTADR_" & FORMAL_STR & ":" );
	    end;

	        -- VAR en ordre INVERSE des PRM	du modele	:
	        -- PRM: __u(8) __ld(16) __st(24)  → VAR: __st(-24) __ld(-16) __u(-8)

	    PUT_LINE( "VAR " & FORMAL_STR & "__outadr_ofs, q" );
	    PUT_LINE( tab & "LCA OUTADR_" &	FORMAL_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & FORMAL_STR & "__outadr_ofs" );

	    PUT_LINE( "VAR " & FORMAL_STR & "__inadr_ofs, q" );
	    PUT_LINE( tab & "LCA INADR_" & FORMAL_STR &	".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & FORMAL_STR & "__inadr_ofs"	);

	    PUT_LINE( "VAR " & FORMAL_STR & "__st_ofs, q" );
	    PUT_LINE( tab & "LCA ST_" & FORMAL_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & FORMAL_STR & "__st_ofs" );

	    PUT_LINE( "VAR " & FORMAL_STR & "__ld_ofs, q" );
	    PUT_LINE( tab & "LCA LD_" & FORMAL_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & FORMAL_STR & "__ld_ofs" );

	  elsif  DEFN_TYPE_SPEC.TY  in  CLASS_UNCONSTRAINED						-- COMPOSITE ARRAY OU RECORD GENERIQUES
	     or  DEFN_TYPE_SPEC.TY  in  CLASS_CONSTRAINED  then
					-- A REVOIR

	    begin
		-- LD : pile = [adresse] → pile = [valeur]
	      PUT_LINE(	"BRA post_LD_" & FORMAL_STR );
	      PUT_LINE(	"LD_" & FORMAL_STR & ".elab:" );
	      PUT_LINE(	tab & "LI 0" );				-- A REVOIR
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_LD_" & FORMAL_STR & ":" );

		-- ST : pile = [@param_out, valeur] →	pile = []
	      PUT_LINE(	"BRA post_ST_" & FORMAL_STR );
	      PUT_LINE(	"ST_" & FORMAL_STR & ".elab:" );
	      PUT_LINE(	tab & "DROP" );				-- A REVOIR
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_ST_" & FORMAL_STR & ":" );

		-- ADR : pile = [@param_out, valeur] → pile = []
	      PUT_LINE(	"BRA post_INADR_" &	FORMAL_STR );
	      PUT_LINE(	"INADR_" & FORMAL_STR	& ".elab:" );
	      PUT_LINE(	tab & "LIa" );								-- Indirection
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_INADR_" & FORMAL_STR & ":" );

	      PUT_LINE(	"BRA post_OUTADR_" & FORMAL_STR	);
	      PUT_LINE(	"OUTADR_"	& FORMAL_STR & ".elab:" );
	      PUT_LINE(	tab & "LIa" );								-- Indirection
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_OUTADR_" & FORMAL_STR & ":" );
	    end;

	    PUT_LINE( "VAR " & FORMAL_STR & "__outadr_ofs, q" );
	    PUT_LINE( tab & "LCA OUTADR_" &	FORMAL_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & FORMAL_STR & "__outadr_ofs" );

	    PUT_LINE( "VAR " & FORMAL_STR & "__inadr_ofs, q" );
	    PUT_LINE( tab & "LCA INADR_" & FORMAL_STR &	".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & FORMAL_STR & "__inadr_ofs"	);

	    PUT_LINE( "VAR " & FORMAL_STR & "__st_ofs, q" );
	    PUT_LINE( tab & "LCA ST_" & FORMAL_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & FORMAL_STR & "__st_ofs" );

	    PUT_LINE( "VAR " & FORMAL_STR & "__ld_ofs, q" );
	    PUT_LINE( tab & "LCA LD_" & FORMAL_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & FORMAL_STR & "__ld_ofs" );

	  else
	    PUT_LINE( "; CODE_PACKAGE_DECL : TYPE_ID GENERIQUE PAS GERE "	& NODE_NAME'IMAGE( DEFN_TYPE_SPEC.TY ) );

	  end if;

	  PUT_LINE( "VAR " & FORMAL_STR & "__u_ofs, q"	);
	  PUT( tab & "La" & tab & INTEGER'IMAGE( DI( CD_LEVEL, D( SM_TYPE_SPEC, DEFN ) ) ) & ", " );
	  CODI.REGIONS_PATH( DEFN	);
	  PUT_LINE( '_' & DEFN_STR & ".use__info"	);
	  PUT_LINE( tab	& "Sa" & tab & LVL_STR & ", "	& FORMAL_STR & "__u_ofs" );

	end	ACTUAL_GENERIC_TYPE;
		-------------------

        elsif  FORMAL.TY = DN_SUBPROG_ENTRY_DECL  then


				-----------------
				ACTUAL_SUBPROGRAM:
        declare
	FORMAL_ID		: TREE		:= D( AS_SOURCE_NAME, FORMAL );
	FORMAL_STR	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, FORMAL_ID ) );
	FORMAL_SPEC	: TREE		:= D( AS_HEADER, FORMAL );
	BRIDGE_STR  	:constant STRING	:= FORMAL_STR & "__bridge_" & NEW_LABEL;
          ACTUAL_SUBP 	: TREE		:= ACTUAL;
	ACTUAL_DEFN	: TREE		:= ACTUAL_NAME_DEFN( ACTUAL );

        begin
	if  ACTUAL_SUBP.TY = DN_ASSOC  then
	  ACTUAL_SUBP := D( AS_EXP, ACTUAL_SUBP );
	end if;

	if  ACTUAL_DEFN.TY = DN_ENTRY_ID  then
	  PUT_LINE( "VAR " & LETTERED_SUBNAME( FORMAL_STR )  & "__call_ofs, q" );

	elsif  ACTUAL_DEFN.TY = DN_BLTN_OPERATOR_ID  then
	  PUT_LINE( "VAR " & LETTERED_SUBNAME( FORMAL_STR )  & "__call_ofs, q" );

	elsif  ACTUAL_DEFN.TY = DN_ENUMERATION_ID  or  ACTUAL_DEFN.TY = DN_CHARACTER_ID  then
	  PUT_LINE( "VAR " & FORMAL_STR & "_disp, q" );
	  PUT_LINE( tab & "LI" & tab & IMAGE( DI( SM_POS, ACTUAL_DEFN ) ) );
	  PUT_LINE( tab & "Sb " & LVL_STR & ", " & FORMAL_STR & "_disp" );

	else

	declare
	  ACTUAL_STR	:constant STRING	:= LETTERED_SUBNAME( PRINT_NAME( D( LX_SYMREP, ACTUAL_DEFN ) ) )
					   & "_L" & IMAGE( DI( CD_LABEL, ACTUAL_DEFN ) );
	  SUBNAME_STR	:constant string	:= LETTERED_SUBNAME( FORMAL_STR );
begin

--          CODE_GENERIC_SUBPROGRAM_BRIDGE( BRIDGE_STR  => BRIDGE_STR,
--              FORMAL      => FORMAL,
--              FORMAL_ID   => FORMAL_ID,
--              FORMAL_SPEC => FORMAL_SPEC,
--              ACTUAL      => ACTUAL_SUBP );

	  PUT_LINE( "VAR " & SUBNAME_STR & "__call_ofs, q" );
	  PUT_LINE( tab & "LCA " & ACTUAL_STR & ".elab" );
	  PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & SUBNAME_STR & "__call_ofs" );
end;
end if;
	end	ACTUAL_SUBPROGRAM;
		-----------------

        end if;
      end;
    end loop;

    PUT( "VAR GFP_disp, q" );
    if  CODI.DEBUG  then
      PUT( tab50 & "; Lieu du Generic Frame Pointer " );
    end if;
    NEW_LINE;

  end	CODE_GENERIC_ACTUALS;
	--------------------


			--=======================--
  procedure		  CODE_SUBPROG_ENTRY_DECL	( SUBPROG_ENTRY_DECL :TREE )
  is			---------------------------

    SOURCE_NAME			: TREE	:= D( AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );

    SAVE_NO_SUB_PARAM		: BOOLEAN	:= CODI.NO_SUBP_PARAMS;
    SAVE_IN_GENERIC_INSTANTIATION	: BOOLEAN	:= CODI.IN_GENERIC_INSTANTIATION;
    SAVE_INSTANTIATION_MODEL_NAME	: TREE	:= CODI.INSTANTIATION_MODEL_NAME;
    SAVE_OUTPUT_CODE		: BOOLEAN	:= CODI.OUTPUT_CODE;
    IS_AN_INSTANTIATION		: BOOLEAN	:= D( AS_UNIT_KIND, SUBPROG_ENTRY_DECL ).TY = DN_INSTANTIATION;

  begin
    if  CODI.DEBUG  then PUT( tab50 & "; sub program entry decl (in instantiation "
	& BOOLEAN'IMAGE( CODI.IN_GENERIC_INSTANTIATION ) & " )" ); end if;
    NEW_LINE;

    if  not (SOURCE_NAME.TY in CLASS_SUBPROG_NAME)  then
      PUT_LINE( "ANOMALIE : EXPANDER.DECLARATIONS.CODE_SUBPROG_ENTRY_DECL ; SOURCE_NAME.TY pas dans CLASS_SUBPROG_NAME"	);
      raise PROGRAM_ERROR;
    else
      if	CODI.IN_SPEC_UNIT
      then DB( CD_COMPILED, SOURCE_NAME, TRUE );
      else
        if  not IN_GENERIC_INSTANTIATION  and then  DB( CD_COMPILED, SOURCE_NAME )  then
	return;
        end if;
      end	if;
    end if;

    if  IS_AN_INSTANTIATION  then                -- ce decl EST une instanciation (a8)
      CODI.IN_GENERIC_INSTANTIATION := TRUE;
      CODI.INSTANTIATION_MODEL_NAME := D( AS_NAME, D( AS_UNIT_KIND, SUBPROG_ENTRY_DECL ) );
      while  CODI.INSTANTIATION_MODEL_NAME.TY = DN_SELECTED  loop     -- cas TEXT_IO.xxx
        CODI.INSTANTIATION_MODEL_NAME := D( AS_DESIGNATOR, CODI.INSTANTIATION_MODEL_NAME );
      end loop;
    end if;
    -- sinon : sous-programme d'une instance de package →
    -- INSTANTIATION_MODEL_NAME reste celui posé par CODE_PACKAGE_DECL (le modèle du package)

    INC_LEVEL;
    declare
      HEADER	: TREE;
      LBL		: LABEL_TYPE	:= NEW_LABEL;
    begin

      if	CODI.IN_SPEC_UNIT  or else  not DB( CD_COMPILED, SOURCE_NAME )
      then  DI( CD_LABEL, SOURCE_NAME, INTEGER( LBL ) );
      end	if;

      DI(	CD_LEVEL,	SOURCE_NAME, INTEGER( CODI.CUR_LEVEL ) );
      DB(	CD_COMPILED, SOURCE_NAME, TRUE );

      if	not CODI.IN_GENERIC_INSTANTIATION  then CODI.OUTPUT_CODE := FALSE; end if;				-- ne pas	coder les	parametres (le body	fera ca)

      if	CODI.IN_GENERIC_INSTANTIATION  then
        HEADER := D( SM_SPEC, SOURCE_NAME );
				-------------------------------
				INSTANTIATION_SUBPROG_GENERIQUE:
        declare
	SOURCE_NAME	: TREE		:= D( AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );
	SUB_NAME		:constant	STRING	:= LETTERED_SUBNAME( PRINT_NAME( D( LX_SYMREP, SOURCE_NAME ) ) );
	LBL		: LABEL_TYPE	:= LABEL_TYPE( DI( CD_LABEL, SOURCE_NAME ) );
	LABELED_SUB_STR	:constant STRING	:= SUB_NAME & '_' & LABEL_STR( LBL );

        begin
	PUT_LINE(	"if defined " & LABELED_SUB_STR & '_' );

	if  IS_AN_INSTANTIATION  then
	  CODE_GENERIC_ACTUALS( D( AS_UNIT_KIND, SUBPROG_ENTRY_DECL ), LABELED_SUB_STR, CODI.CUR_LEVEL-1 );
	end if;

	PUT( "PRO" & tab & LABELED_SUB_STR );
	if  CODI.DEBUG  then PUT( tab50 & ";---------- PRO " & SUB_NAME ); end if;
	NEW_LINE;

	CODE_HEADER( HEADER	);

	PUT_LINE(	"ELB" & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL	) );
	PUT_LINE(	"begin:" );

	if  SOURCE_NAME.TY = DN_FUNCTION_ID  or	 SOURCE_NAME.TY = DN_OPERATOR_ID  then
	  PUT( tab & "LI" &	tab & '0'	);
	  if  CODI.DEBUG  then PUT( tab50 & "; lieu result" ); end if;
	  NEW_LINE;
	end if;

	PUT_LINE(	tab & "LVA" & tab &	LEVEL_NUM'IMAGE( CODI.CUR_LEVEL - 1 ) &	", GFP_disp" );

	declare
	  PRM_SECTIONS_S	: SEQ_TYPE	:= LIST( D( AS_PARAM_S, D( SM_SPEC, SOURCE_NAME )	) );

			----------------------------
	  procedure	INVERSE_RECURSE_PRM_SECTIONS	( REMAIN_SECTIONS :in out SEQ_TYPE )
	  is		----------------------------

	    PRM_SECTION		: TREE;
	  begin
	    if  IS_EMPTY( REMAIN_SECTIONS )  then return;	end if;
	    POP( REMAIN_SECTIONS, PRM_SECTION );
	    INVERSE_RECURSE_PRM_SECTIONS( REMAIN_SECTIONS	);

	    declare
	      NAME_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S,	PRM_SECTION ) );

			---------------------
	      procedure	INVERSE_RECURSE_NAMES	( NAMES :in out SEQ_TYPE )
	      is		---------------------
	        NAME	: TREE;

	      begin
	        if  IS_EMPTY( NAMES )	 then return; end if;
	        POP( NAMES,	NAME );
	        INVERSE_RECURSE_NAMES( NAMES );

	        if  (NAME.TY = DN_IN_ID) and (D( SM_OBJ_TYPE, NAME ).TY in CLASS_SCALAR)  then
		-- in scalaire : passer par copie (valeur)
		PUT_LINE(	tab & 'L' & OPER_SIZ_CHAR( D( SM_OBJ_TYPE, NAME ) ) & tab & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL )
			& ", -" &	PRINT_NAME( D( LX_SYMREP, NAME ) ) & "_ofs" );

	        else
		-- in composite (record, array) ou out / in_out :	propager l'adresse
		PUT_LINE(	tab & "La " & tab &	LEVEL_NUM'IMAGE( CODI.CUR_LEVEL )
			& ", -" &	PRINT_NAME( D( LX_SYMREP, NAME ) ) & "_ofs" );
	        end if;
	      end	INVERSE_RECURSE_NAMES;
		---------------------

	    begin
	      INVERSE_RECURSE_NAMES( NAME_S );
	    end;

	  end	INVERSE_RECURSE_PRM_SECTIONS;
		----------------------------

	begin
	  INVERSE_RECURSE_PRM_SECTIONS( PRM_SECTIONS_S );
	end;

	declare
	  MODEL_DEFN	: TREE	:= D( SM_DEFN, CODI.INSTANTIATION_MODEL_NAME );
	  MODEL_SPEC	: TREE	:= D( SM_SPEC, MODEL_DEFN );
	begin
	  if  MODEL_DEFN.TY = DN_GENERIC_ID
	      and then  PRINT_NAME( D( LX_SYMREP, MODEL_DEFN ) ) = "UNCHECKED_CONVERSION"
	  then

	    declare
			----------------------------------
	      procedure	CODE_UNCHECKED_CONVERSION_INSTANCE	( SUBPROG_ENTRY_DECL :TREE; SOURCE_NAME :TREE )
	      is
  UNIT_KIND : TREE := D( AS_UNIT_KIND, SUBPROG_ENTRY_DECL );

  ACTUALS   : SEQ_TYPE := LIST( D( AS_GENERAL_ASSOC_S, UNIT_KIND ) );
  SRC_ACT   : TREE;
  DST_ACT   : TREE;

  SRC_DEFN  : TREE;
  DST_DEFN  : TREE;

  SRC_TYPE  : TREE;
  DST_TYPE  : TREE;

  function ACTUAL_EXP ( A : TREE ) return TREE is
  begin
    if A.TY = DN_ASSOC then
      return D( AS_EXP, A );
    else
      return A;
    end if;
  end ACTUAL_EXP;

  function FULL_VIEW ( T : TREE ) return TREE is
    R : TREE := T;
  begin
    loop
      if R.TY = DN_PRIVATE or else R.TY = DN_L_PRIVATE then
        R := D( SM_TYPE_SPEC, R );

      elsif R.TY = DN_INCOMPLETE then
        R := D( XD_FULL_TYPE_SPEC, R );

      else
        return R;
      end if;
    end loop;
  end FULL_VIEW;

  procedure EMIT_TYPE_SIZE_BYTES ( T : TREE ) is
    TT : TREE := FULL_VIEW( T );
  begin
    if TT.TY = DN_RECORD then
      declare
        TN : TREE := D( XD_SOURCE_NAME, TT );
        TS : constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, TN ) );
      begin
        PUT( tab & "LI" & tab );
        REGIONS_PATH( TN );
        PUT_LINE( TS & ".size" );
      end;

    elsif TT.TY = DN_CONSTRAINED_ARRAY or else TT.TY = DN_ARRAY then
      declare
        TN : TREE := D( XD_SOURCE_NAME, TT );
        TS : constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, TN ) );
      begin
        PUT( tab & "Ld" & tab & IMAGE( DI( CD_LEVEL, TT ) ) & ", " );
        REGIONS_PATH( TN );
        PUT_LINE( TS & ".SIZ" );

        PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
        PUT_LINE( tab & "DIV" );
      end;

    elsif TT.TY in CLASS_SCALAR or else TT.TY = DN_ACCESS then
      PUT_LINE( tab & "LI" & tab & IMAGE( CODI.TYPE_SIZE( TT ) ) );

    else
      PUT_LINE( "; UNCHECKED_CONVERSION : taille cible non geree "
              & NODE_NAME'IMAGE( TT.TY ) );
      raise PROGRAM_ERROR;
    end if;
  end EMIT_TYPE_SIZE_BYTES;

function IS_COMPOSITE ( T : TREE ) return BOOLEAN is
  TT : TREE := FULL_VIEW( T );
begin
  return TT.TY = DN_RECORD
      or else TT.TY = DN_CONSTRAINED_RECORD
      or else TT.TY = DN_ARRAY
      or else TT.TY = DN_CONSTRAINED_ARRAY;
end IS_COMPOSITE;

begin
  POP( ACTUALS, SRC_ACT );
  POP( ACTUALS, DST_ACT );

  SRC_ACT := ACTUAL_EXP( SRC_ACT );
  DST_ACT := ACTUAL_EXP( DST_ACT );

  SRC_DEFN := D( SM_DEFN, SRC_ACT );
  DST_DEFN := D( SM_DEFN, DST_ACT );

  SRC_TYPE := FULL_VIEW( D( SM_TYPE_SPEC, SRC_DEFN ) );
  DST_TYPE := FULL_VIEW( D( SM_TYPE_SPEC, DST_DEFN ) );

  -- Version minimale robuste pour composite -> composite.
  if  (SRC_TYPE.TY = DN_ARRAY or else SRC_TYPE.TY = DN_CONSTRAINED_ARRAY
       or else SRC_TYPE.TY = DN_RECORD)
  and (DST_TYPE.TY = DN_ARRAY or else DST_TYPE.TY = DN_CONSTRAINED_ARRAY
       or else DST_TYPE.TY = DN_RECORD)
  then
    -- @DST = result__ofs.data_ptr
    PUT_LINE( tab & "La" & tab & IMAGE( CODI.CUR_LEVEL ) & ", -result__ofs" );
    PUT_LINE( tab & "La" & tab & ", 0" );

    -- LEN = taille du type cible en octets
    EMIT_TYPE_SIZE_BYTES( DST_TYPE );

    -- @SRC = S.data_ptr
    PUT_LINE( tab & "La" & tab & IMAGE( CODI.CUR_LEVEL ) & ", -S_ofs" );
    PUT_LINE( tab & "La" & tab & ", 0" );

    PUT_LINE( tab & "BLKMOV" );

elsif  IS_COMPOSITE( SRC_TYPE )
and then (DST_TYPE.TY in CLASS_SCALAR or else DST_TYPE.TY = DN_ACCESS)
then
  -- Source composite passée par adresse de doublet.
  -- result__ofs est un résultat scalaire.
  PUT_LINE( tab & "La" & tab & IMAGE( CODI.CUR_LEVEL ) & ", -S_ofs" );
  PUT_LINE( tab & "La" & tab & ", 0" );

  -- Lire les octets bruts avec la taille du type cible.
  PUT_LINE( tab & "L" & OPER_SIZ_CHAR( DST_TYPE ) );

  -- Stocker dans le slot résultat.
  PUT_LINE( tab & "S" & OPER_SIZ_CHAR( DST_TYPE )
          & tab & IMAGE( CODI.CUR_LEVEL ) & ", -result__ofs" );

  else
    PUT_LINE( "; UNCHECKED_CONVERSION : cas non encore gere "
            & NODE_NAME'IMAGE( SRC_TYPE.TY )
            & " -> "
            & NODE_NAME'IMAGE( DST_TYPE.TY ) );
    raise PROGRAM_ERROR;
  end if;
	      end	CODE_UNCHECKED_CONVERSION_INSTANCE;
		----------------------------------

	    begin
	      CODE_UNCHECKED_CONVERSION_INSTANCE( SUBPROG_ENTRY_DECL => SUBPROG_ENTRY_DECL,
					SOURCE_NAME        => SOURCE_NAME
				);
	    end;

	  elsif  MODEL_DEFN.TY = DN_GENERIC_ID  and then  MODEL_SPEC.TY in CLASS_SUBP_ENTRY_HEADER  then
				-----------------------
				DIRECT_SUBPROG_INSTANCE:						-- procedure NP is new P (...);
	    declare
	      MODEL_BDY	: TREE		:= D( XD_BODY, MODEL_DEFN );
	      MODEL_NAME	:constant STRING	:= LETTERED_SUBNAME( PRINT_NAME( D( LX_SYMREP, MODEL_DEFN ) ) );
	      MODEL_LBL	: LABEL_TYPE	:= LABEL_TYPE( DI( CD_LABEL, D( AS_SOURCE_NAME, MODEL_BDY ) ) );

	    begin
	      PUT( tab & "CALL" & tab );
	      REGIONS_PATH( MODEL_DEFN );
	      PUT_LINE( " ," & MODEL_NAME & '_' & LABEL_STR( MODEL_LBL ) );

	    end	DIRECT_SUBPROG_INSTANCE;
		-----------------------
	  else
	    PUT( tab & "CALL" & tab );
	    REGIONS_PATH( D( SM_DEFN, CODI.INSTANTIATION_MODEL_NAME ) );
	    PUT( PRINT_NAME( D( LX_SYMREP, CODI.INSTANTIATION_MODEL_NAME ) ) & ". ," );
			----------------------------------------
			SUBPROG_IN_GENERIC_PACKAGE_INSTANTIATION:
	    declare
	      MODEL_DECL	: TREE;

	    begin
	      while  not( IS_EMPTY( CODI.GENERIC_MODEL_DECL_SEQ ) )  loop
	        POP( CODI.GENERIC_MODEL_DECL_SEQ, MODEL_DECL );
	        if  MODEL_DECL.TY = DN_SUBPROG_ENTRY_DECL  then
		declare
		  NAME	: TREE	:= D( AS_SOURCE_NAME, MODEL_DECL );
		  LBL	: INTEGER	:= DI( CD_LABEL, NAME );
	          begin
		  PUT_LINE( PRINT_NAME( D( LX_SYMREP, NAME ) ) & "_L" & IMAGE( LBL ) );
		  exit;
	          end;
	        end if;
	      end loop;
	    end	SUBPROG_IN_GENERIC_PACKAGE_INSTANTIATION;
		----------------------------------------
            end if;
          end;

	if  SOURCE_NAME.TY = DN_FUNCTION_ID  or	 SOURCE_NAME.TY = DN_OPERATOR_ID  then

	  if  D( SM_UNIT_DESC, SOURCE_NAME ).TY /= DN_INSTANTIATION  then
	    declare
	      USED_OBJECT_ID	: TREE		:= D( AS_NAME, HEADER );
	      RESULT_TYPE_ID	: TREE		:= D( SM_DEFN, USED_OBJECT_ID	);
	      RESULT_TYPE_SPEC	: TREE		:= D( SM_TYPE_SPEC,	RESULT_TYPE_ID );
	      RESULT_SIZE_CHAR	: CHARACTER;
	    begin
	      if  RESULT_TYPE_SPEC.TY  in  CLASS_UNCONSTRAINED  then
	        PUT_LINE( "; RESULTAT UNCONSTRAINED A FAIRE" );
	      else
	        RESULT_SIZE_CHAR := OPER_SIZ_CHAR( RESULT_TYPE_SPEC );
	        if	RESULT_SIZE_CHAR /=	'v'  then
		PUT( tab & 'S' & RESULT_SIZE_CHAR
		& tab & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL	) & ", -result__ofs"  );
		if  CODI.DEBUG  then PUT( tab50	& "; retour resultat" ); end if;
		NEW_LINE;
	        else
		PUT_LINE( "; RESULTAT PAR REFERENCE A FAIRE" );
		raise PROGRAM_ERROR;
	        end if;
	      end if;
	    end;
	  else
	    null;			-- A VOIR
	  end if;
	end if;

	PUT_LINE(	tab & "UNLINK" & tab & LEVEL_NUM'IMAGE(	CODI.CUR_LEVEL ) );

	if  CODI.NO_SUBP_PARAMS  then
	  PUT_LINE( tab & "RTD" );
	else
	  if  SOURCE_NAME.TY = DN_FUNCTION_ID  then
	    PUT_LINE( tab & "RTD" & tab & "prm_siz-8" );
	  else
	    PUT_LINE( tab & "RTD" & tab & "prm_siz" );
	  end if;
	end if;
	PUT( "endPRO" );
	if  CODI.DEBUG  then PUT( tab50 & ";---------- end PRO " & SUB_NAME);	end if;
	NEW_LINE;
	PUT_LINE(	"end if" );

        end		INSTANTIATION_SUBPROG_GENERIQUE;
			-------------------------------

      else
        HEADER := D( AS_HEADER, SUBPROG_ENTRY_DECL );

				---------------------
				SOUS_PROGRAMME_NORMAL:
        begin
        if  CODI.IN_GENERIC_INSTANTIATION  then
	if  CODI.DEBUG  then PUT( tab50 & "; subprog in generic");	end if;
	NEW_LINE;

        else
	declare
	  SAVE_NO_SUB_PARAM	: BOOLEAN		:= CODI.NO_SUBP_PARAMS;
	begin
	  CODI.OUTPUT_CODE := FALSE;						-- ne pas	coder les	parametres (le body	fera ca)
	  CODE_HEADER( HEADER );
	  CODI.OUTPUT_CODE := TRUE;
	  CODI.NO_SUBP_PARAMS := SAVE_NO_SUB_PARAM;
	end;
        end if;
        end		SOUS_PROGRAMME_NORMAL;
			---------------------
      end	if;

    end;
    DEC_LEVEL;

    CODI.NO_SUBP_PARAMS := SAVE_NO_SUB_PARAM;
    CODI.IN_GENERIC_INSTANTIATION := SAVE_IN_GENERIC_INSTANTIATION;
    CODI.INSTANTIATION_MODEL_NAME := SAVE_INSTANTIATION_MODEL_NAME;
    CODI.OUTPUT_CODE := SAVE_OUTPUT_CODE;

   end	  CODE_SUBPROG_ENTRY_DECL;
	--=======================--



			--=================--
  procedure		  CODE_PACKAGE_DECL		( PACKAGE_DECL :TREE )
  is			--=================--

    PACK_ID		: TREE			:= D( AS_SOURCE_NAME, PACKAGE_DECL );
    PACK_NAME		:constant	STRING		:= PRINT_NAME( D( LX_SYMREP, PACK_ID ) );
    UNIT_KIND		: TREE			:= D( AS_UNIT_KIND,	PACKAGE_DECL );
    SAVE_NO_SUB_PARAM	: BOOLEAN			:= CODI.NO_SUBP_PARAMS;
    SAVE_MODEL_SEQ		: SEQ_TYPE		:= CODI.GENERIC_MODEL_DECL_SEQ;
    CAS_NORMAL		: BOOLEAN			:= PACK_NAME /= "STANDARD" and PACK_NAME /= "_STANDRD";
    SAVE_IN_GENERIC_INSTANTIATION	: BOOLEAN	:= CODI.IN_GENERIC_INSTANTIATION;
    SAVE_INSTANTIATION_MODEL_NAME	: TREE	:= CODI.INSTANTIATION_MODEL_NAME;
    SAVE_OUTPUT_CODE		: BOOLEAN	:= CODI.OUTPUT_CODE;

  begin
    if  CAS_NORMAL	then
      PUT_LINE( PACK_NAME & " = '" & PACK_NAME & "'" );
      PUT( "namespace " & PACK_NAME );
    end if;
    if  UNIT_KIND.TY = DN_INSTANTIATION
    then
      if	CODI.DEBUG  then PUT( tab50 &	";---------- GENERIC PACKAGE INSTANTIATION" ); end if;
      NEW_LINE;

      CODI.IN_GENERIC_INSTANTIATION := TRUE;

      CODI.INSTANTIATION_MODEL_NAME := D( AS_NAME, UNIT_KIND );
      while  CODI.INSTANTIATION_MODEL_NAME.TY = DN_SELECTED  loop
        CODI.INSTANTIATION_MODEL_NAME := D( AS_DESIGNATOR, CODI.INSTANTIATION_MODEL_NAME );
      end loop;

      CODI.GENERIC_MODEL_DECL_SEQ := LIST( D( AS_DECL_S1, D( SM_SPEC,	D( SM_DEFN, CODI.INSTANTIATION_MODEL_NAME ) ) ) );

      PUT( "elab_spec:" );
      if	CODI.DEBUG  then PUT_LINE( tab50 & ";    SPEC ELAB" ); end if;
      NEW_LINE;

      CODE_GENERIC_ACTUALS( UNIT_KIND );

      CODE_PACKAGE_SPEC( D( SM_SPEC, D( AS_SOURCE_NAME, PACKAGE_DECL ) ) );

      if  CODI.DEBUG  then
        PUT( tab50 & ";---------- end generic package instantiation " & PACK_NAME );
      end if;

      NEW_LINE;
      CODI.GENERIC_MODEL_DECL_SEQ := SAVE_MODEL_SEQ;
      CODI.IN_GENERIC_INSTANTIATION := FALSE;

    else
      if	CAS_NORMAL and CODI.DEBUG  then PUT( tab50 & ";---------- PACKAGE DECLARATION" ); end if;
      NEW_LINE;

      CODE_HEADER( D( AS_HEADER, PACKAGE_DECL ) );

      declare
        EXC_LBL		:constant	STRING	:= NEW_LABEL;
      begin
        PUT_LINE( "; EXC_LBL"	& tab & EXC_LBL );
      end;
    end if;

    if  CAS_NORMAL	then
      PUT_LINE( "end namespace" );
    end if;
    DB( CD_COMPILED, PACK_ID, TRUE );
    if  CODI.DEBUG	then  NEW_LINE; end	if;

    CODI.NO_SUBP_PARAMS := SAVE_NO_SUB_PARAM;
    CODI.IN_GENERIC_INSTANTIATION := SAVE_IN_GENERIC_INSTANTIATION;
    CODI.INSTANTIATION_MODEL_NAME := SAVE_INSTANTIATION_MODEL_NAME;
    CODI.OUTPUT_CODE := SAVE_OUTPUT_CODE;

  end	  CODE_PACKAGE_DECL;
	--=================--


			---------------
  procedure		CODE_USE_PRAGMA	( USE_PRAGMA :TREE )
  is			---------------
  begin

    if USE_PRAGMA.TY = DN_USE
    then null;	-- CODE_USE ( USE_PRAGMA );

    elsif	USE_PRAGMA.TY = DN_PRAGMA
    then null;	-- CODE_PRAGMA ( USE_PRAGMA );

    end if;
  end	CODE_USE_PRAGMA;
	---------------


	------------
end	DECLARATIONS;
	------------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
