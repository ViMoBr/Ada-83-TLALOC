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
      if	CODI.NO_SUBP_PARAMS	and not FOR_FUNCTION  then
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
        DIM_NBR		: NATURAL			:= 1;
        LVL		: LEVEL_NUM		renames CODI.CUR_LEVEL;
        LVL_STR		:constant	STRING		:= IMAGE(	CODI.CUR_LEVEL );
        ANONYMOUS_SUBTYPE	: BOOLEAN			:= FALSE;

			--------------
        procedure		COVAR_ALLOCATE
        is		--------------
        begin
	PUT( tab & "Ld" & tab & IMAGE( TYPE_LEVEL ) & ", " );						-- LOAD SIZ FOR ALLOCATION
	PUT_LINE(	TYPE_NAME_STR & ".SIZ" );
	PUT_LINE(	tab & "LI" & tab & '8' );
	PUT_LINE(	tab & "DIV" );

	PUT_LINE(	tab & "CO_VAR" );
	PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR &	"_disp" );
	if  CODI.DEBUG  then PUT( tab50 & "; array data ptr at _disp" ); end if;
	NEW_LINE;

        end	COVAR_ALLOCATE;
		--------------

      begin

--        if  DB( CD_COMPILED, TYPE_SPEC ) = FALSE	then
--	ANONYMOUS_SUBTYPE := TRUE;
--	PUT_LINE(	TYPE_NAME_STR & " = '" & TYPE_NAME_STR & "'" );
--	PUT( "namespace " &	TYPE_NAME_STR );
--	if  CODI.DEBUG  then PUT( tab50 & "; array var constrained array type info" ); end if;
--	NEW_LINE;

declare
  SOURCE_CONSTRAINT : TREE := TREE_VOID;
begin
  if  OBJECT_DECL /= TREE_VOID  and then  D( AS_TYPE_DEF, OBJECT_DECL ) /= TREE_VOID  then
    declare
      TYPE_DEF : TREE := D( AS_TYPE_DEF, OBJECT_DECL );
    begin
      if  TYPE_DEF.TY = DN_SUBTYPE_INDICATION  then
        SOURCE_CONSTRAINT := D( AS_CONSTRAINT, TYPE_DEF );
      elsif  TYPE_DEF.TY = DN_CONSTRAINED_ARRAY_DEF  then
        SOURCE_CONSTRAINT := D( AS_CONSTRAINT, TYPE_DEF );
      end if;
    end;
  end if;

  if  DB( CD_COMPILED, TYPE_SPEC ) = FALSE  then
    ANONYMOUS_SUBTYPE := TRUE;
    PUT_LINE( TYPE_NAME_STR & " = '" & TYPE_NAME_STR & "'" );
    PUT( "namespace " & TYPE_NAME_STR );
    if  CODI.DEBUG  then PUT( tab50 & "; array var constrained array type info" ); end if;
    NEW_LINE;
    TYPES_DECLS.PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( TYPE_SPEC, SOURCE_CONSTRAINT );
  end if;
end;

--	TYPES_DECLS.PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( TYPE_SPEC );
--        end if;

        TYPE_LEVEL := DI( CD_LEVEL, TYPE_SPEC );

        PUT( "VAR "	& VC_STR & "_disp, q" );
        if  CODI.DEBUG  then PUT( tab50	& "; variable array : pointeur aux data" ); end if;
        NEW_LINE;
        PUT( "VAR "	& VC_STR & "__u, q"	);
        if  CODI.DEBUG  then PUT( tab50	& "; variable array : useinfo pointeur au rec info" ); end if;
        NEW_LINE;

        DI( CD_LEVEL, VC_NAME, INTEGER(	LVL ) );

        PUT( tab & "La" & INTEGER'IMAGE( TYPE_LEVEL ) & ", " );						-- LOAD ADDRESS FOR	INFO
        PUT_LINE( TYPE_NAME_STR & ".use__info" );

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
	    COVAR_ALLOCATE;
	    if  CODI.DEBUG	then PUT(	tab50 & "; array data aggregate" ); end	if;
	    NEW_LINE;

	    PUT_LINE( tab &	"La" & tab & LVL_STR & ", " &	VC_STR & "_disp" );
	    EXPRESSIONS.CODE_AGGREGATE( INIT_EXP, TYPE_SPEC );

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
  procedure		CODE_GENERIC_ACTUALS	( UNIT_KIND :TREE )
  is			--------------------

    GNAME_SEQ	: SEQ_TYPE	:= LIST( D( AS_GENERAL_ASSOC_S, UNIT_KIND ) );
    GNAME		: TREE;
  begin
    while  not IS_EMPTY( GNAME_SEQ )  loop
      POP( GNAME_SEQ, GNAME );

      if  GNAME.TY = DN_ASSOC  then
        GNAME := D( AS_EXP, GNAME );
      end if;

      declare
        DEFN		: TREE		:= D( SM_DEFN, GNAME );
        GNAME_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, GNAME ) );
        LVL_STR		:constant	STRING	:= LEVEL_NUM'IMAGE(	CODI.CUR_LEVEL );

      begin
        if  DEFN.TY = DN_TYPE_ID  or  DEFN.TY = DN_SUBTYPE_ID  then
				-------------------
				ACTUAL_GENERIC_TYPE:
	declare
	  DEFN_TYPE_SPEC	: TREE		:= D( SM_TYPE_SPEC,	DEFN );
	  DEFN_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
	begin

	  if  DEFN_TYPE_SPEC.TY  in  CLASS_SCALAR  then
	        -- Micro-procedures LD et ST pour le type	actuel (contournees	par BRA)
	    declare
	      SIZ_CHAR	: CHARACTER	:= OPER_SIZ_CHAR( DEFN_TYPE_SPEC );
	    begin
		-- LD : pile = [adresse] → pile = [valeur]
	      PUT_LINE(	"BRA post_LD_" & DEFN_STR );
	      PUT_LINE(	"LD_" & DEFN_STR & ".elab:" );
	      PUT_LINE(	tab & "L"	& SIZ_CHAR & " -1, 0" );
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_LD_" & DEFN_STR & ":" );

		-- ST : pile = [@param_out, valeur] →	pile = []
	      PUT_LINE(	"BRA post_ST_" & DEFN_STR );
	      PUT_LINE(	"ST_" & DEFN_STR & ".elab:" );
	      PUT_LINE(	tab & "S" & SIZ_CHAR & " -1, 0" );
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_ST_" & DEFN_STR & ":" );
		-- ADR : pile = [@param_out, valeur] → pile = []

	      PUT_LINE(	"BRA post_INADR_" &	DEFN_STR );
	      PUT_LINE(	"INADR_" & DEFN_STR	& ".elab:" );
	      PUT_LINE(	tab & "RTD 0" );								-- Rien a	faire pour un scalaire
	      PUT_LINE(	"post_INADR_" & DEFN_STR & ":" );

	      PUT_LINE(	"BRA post_OUTADR_" & DEFN_STR	);
	      PUT_LINE(	"OUTADR_"	& DEFN_STR & ".elab:" );
	      PUT_LINE(	tab & "La" );								-- Pointer Data
	      PUT_LINE(	tab & "RTD 0" );								-- Rien a	faire pour un scalaire
	      PUT_LINE(	"post_OUTADR_" & DEFN_STR & ":" );
	    end;

	        -- VAR en ordre INVERSE des PRM	du modele	:
	        -- PRM: __u(8) __ld(16) __st(24)  → VAR: __st(-24) __ld(-16) __u(-8)

	    PUT_LINE( "VAR " & GNAME_STR & "__outadr_ofs, q" );
	    PUT_LINE( tab & "LCA OUTADR_" &	DEFN_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & GNAME_STR & "__outadr_ofs" );

	    PUT_LINE( "VAR " & GNAME_STR & "__inadr_ofs, q" );
	    PUT_LINE( tab & "LCA INADR_" & DEFN_STR &	".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & GNAME_STR & "__inadr_ofs"	);

	    PUT_LINE( "VAR " & GNAME_STR & "__st_ofs, q" );
	    PUT_LINE( tab & "LCA ST_" & DEFN_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & GNAME_STR & "__st_ofs" );

	    PUT_LINE( "VAR " & GNAME_STR & "__ld_ofs, q" );
	    PUT_LINE( tab & "LCA LD_" & DEFN_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & GNAME_STR & "__ld_ofs" );

	  elsif  DEFN_TYPE_SPEC.TY  in  CLASS_UNCONSTRAINED						-- COMPOSITE ARRAY OU RECORD GENERIQUES
	     or  DEFN_TYPE_SPEC.TY  in  CLASS_CONSTRAINED  then
					-- A REVOIR

	    begin
		-- LD : pile = [adresse] → pile = [valeur]
	      PUT_LINE(	"BRA post_LD_" & DEFN_STR );
	      PUT_LINE(	"LD_" & DEFN_STR & ".elab:" );
	      PUT_LINE(	tab & "LI 0" );				-- A REVOIR
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_LD_" & DEFN_STR & ":" );

		-- ST : pile = [@param_out, valeur] →	pile = []
	      PUT_LINE(	"BRA post_ST_" & DEFN_STR );
	      PUT_LINE(	"ST_" & DEFN_STR & ".elab:" );
	      PUT_LINE(	tab & "DROP" );				-- A REVOIR
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_ST_" & DEFN_STR & ":" );

		-- ADR : pile = [@param_out, valeur] → pile = []
	      PUT_LINE(	"BRA post_INADR_" &	DEFN_STR );
	      PUT_LINE(	"INADR_" & DEFN_STR	& ".elab:" );
	      PUT_LINE(	tab & "LIa" );								-- Indirection
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_INADR_" & DEFN_STR & ":" );

	      PUT_LINE(	"BRA post_OUTADR_" & DEFN_STR	);
	      PUT_LINE(	"OUTADR_"	& DEFN_STR & ".elab:" );
	      PUT_LINE(	tab & "LIa" );								-- Indirection
	      PUT_LINE(	tab & "RTD 0" );
	      PUT_LINE(	"post_OUTADR_" & DEFN_STR & ":" );
	    end;

	    PUT_LINE( "VAR " & GNAME_STR & "__outadr_ofs, q" );
	    PUT_LINE( tab & "LCA OUTADR_" &	DEFN_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & GNAME_STR & "__outadr_ofs" );

	    PUT_LINE( "VAR " & GNAME_STR & "__inadr_ofs, q" );
	    PUT_LINE( tab & "LCA INADR_" & DEFN_STR &	".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & GNAME_STR & "__inadr_ofs"	);

	    PUT_LINE( "VAR " & GNAME_STR & "__st_ofs, q" );
	    PUT_LINE( tab & "LCA ST_" & DEFN_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & GNAME_STR & "__st_ofs" );

	    PUT_LINE( "VAR " & GNAME_STR & "__ld_ofs, q" );
	    PUT_LINE( tab & "LCA LD_" & DEFN_STR & ".elab" );
	    PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & GNAME_STR & "__ld_ofs" );

	  else
	    PUT_LINE( "; CODE_PACKAGE_DECL : TYPE_ID GENERIQUE PAS GERE "	& NODE_NAME'IMAGE( DEFN_TYPE_SPEC.TY ) );

	  end if;

	  PUT_LINE( "VAR " & GNAME_STR & "__u_ofs, q"	);
	  PUT( tab & "La" & tab & INTEGER'IMAGE( DI( CD_LEVEL, D( SM_TYPE_SPEC, DEFN ) ) ) & ", " );
	  CODI.REGIONS_PATH( DEFN	);
	  PUT_LINE( '_' & DEFN_STR & ".use__info"	);
	  PUT_LINE( tab	& "Sa" & tab & LVL_STR & ", "	& GNAME_STR & "__u_ofs" );

	end	ACTUAL_GENERIC_TYPE;
		-------------------

        elsif  DEFN.TY = DN_IN  or else  DEFN.TY = DN_IN_OUT  or else  DEFN.TY = DN_OUT  then
					---------------------
					ACTUAL_GENERIC_OBJECT:
	declare
	  NAME_SEQ	:SEQ_TYPE		:= LIST( D( AS_SOURCE_NAME_S, DEFN ) );
	  FORMAL_TYPE	: TREE		:= D( SM_OBJ_TYPE, DEFN );
	  FORMAL_NAME	: TREE;

	begin
	  while  FORMAL_TYPE.TY = DN_PRIVATE  or else  FORMAL_TYPE.TY = DN_L_PRIVATE  loop
	    FORMAL_TYPE := D( SM_TYPE_SPEC, FORMAL_TYPE );
	  end loop;

	  while  not IS_EMPTY( NAME_SEQ )  loop
	    POP( NAME_SEQ, FORMAL_NAME );

	    declare
	      FORMAL_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, FORMAL_NAME ) );
	    begin
	      if  FORMAL_TYPE.TY in CLASS_SCALAR  or else  FORMAL_TYPE.TY = DN_ACCESS  then
	        PUT_LINE( "VAR " & FORMAL_STR & "_disp, q" );
--	        EXPRESSIONS.CODE_EXP( ACTUAL_EXP );							-- A VOIR
	        PUT_LINE( tab & "S" & OPER_SIZ_CHAR( FORMAL_TYPE ) & " " & LVL_STR & ", " & FORMAL_STR & "_disp" );

	      else
	        PUT_LINE( "VAR " & FORMAL_STR & "_disp, q" );
	        PUT_LINE( "VAR " & FORMAL_STR & "__u, q" );

--	        EXPRESSIONS.CODE_EXP( ACTUAL_EXP );     							-- @doublet actuel
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
  is			--=======================--

    SOURCE_NAME	: TREE	    := D(	AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );
  begin
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

    if  D( AS_UNIT_KIND, SUBPROG_ENTRY_DECL ).TY = DN_INSTANTIATION  then
      CODE_GENERIC_ACTUALS( D( AS_UNIT_KIND, SUBPROG_ENTRY_DECL ) );
      CODI.INSTANTIATION_MODEL_NAME := D( AS_NAME, D( AS_UNIT_KIND, SUBPROG_ENTRY_DECL ) );
      CODI.IN_GENERIC_INSTANTIATION := TRUE;
    end if;

    INC_LEVEL;
    declare
      HEADER	: TREE	        := D( AS_HEADER, SUBPROG_ENTRY_DECL );
      LBL		: LABEL_TYPE	:= NEW_LABEL;
    begin

      if	CODI.IN_SPEC_UNIT  or else  not DB( CD_COMPILED, SOURCE_NAME )
      then  DI( CD_LABEL, SOURCE_NAME, INTEGER( LBL ) );
      end	if;

      DI(	CD_LEVEL,	SOURCE_NAME, INTEGER( CODI.CUR_LEVEL ) );
      DB(	CD_COMPILED, SOURCE_NAME, TRUE );

      if	not IN_GENERIC_INSTANTIATION	then CODI.OUTPUT_CODE := FALSE; end if;					-- ne pas	coder les	parametres (le body	fera ca)

      if	IN_GENERIC_INSTANTIATION  then
        declare
	SOURCE_NAME	: TREE		:= D( AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );
	SUB_NAME		:constant	STRING	:= LETTERED_SUBNAME( PRINT_NAME( D( LX_SYMREP, SOURCE_NAME ) ) );
	LBL		: LABEL_TYPE	:= LABEL_TYPE( DI( CD_LABEL, SOURCE_NAME ) );
        begin
	PUT_LINE(	"if defined " & SUB_NAME & '_' & LABEL_STR( LBL )	& '_' );
	PUT( "PRO" & tab & SUB_NAME &	'_' & LABEL_STR( LBL ) );
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

	  procedure INVERSE_RECURSE_PRM_SECTIONS ( REMAIN_SECTIONS :in out SEQ_TYPE )
	  is
	    PRM_SECTION		: TREE;
	  begin
	    if  IS_EMPTY( REMAIN_SECTIONS )  then return;	end if;
	    POP( REMAIN_SECTIONS, PRM_SECTION );
	    INVERSE_RECURSE_PRM_SECTIONS( REMAIN_SECTIONS	);

	    declare
	      NAME_S		: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S,	PRM_SECTION ) );

	      procedure INVERSE_RECURSE_NAMES (	NAMES :in	out SEQ_TYPE )
	      is
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

	    begin
	      INVERSE_RECURSE_NAMES( NAME_S );
	    end;
	  end	INVERSE_RECURSE_PRM_SECTIONS;

	begin
	  INVERSE_RECURSE_PRM_SECTIONS( PRM_SECTIONS_S );
	end;

	PUT( tab & "CALL" &	tab );
	REGIONS_PATH( D( SM_DEFN, CODI.INSTANTIATION_MODEL_NAME ) );

	PUT( PRINT_NAME( D(	LX_SYMREP, CODI.INSTANTIATION_MODEL_NAME ) ) & ". ," );
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
	        PUT_LINE( PRINT_NAME(	D( LX_SYMREP, NAME ) ) & "_L"	& IMAGE( LBL ) );
	        exit;
	      end;
	    end if;
	  end loop;
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
	if  SOURCE_NAME.TY = DN_FUNCTION_ID  then
	  PUT_LINE( tab & "RTD" & tab	& "prm_siz-8" );
	else
	  PUT_LINE( tab & "RTD" & tab	& "prm_siz" );
	end if;

	PUT( "endPRO" );
	if  CODI.DEBUG  then PUT( tab50 & ";---------- end PRO " & SUB_NAME);	end if;
	NEW_LINE;
	PUT_LINE(	"end if" );
        end;

      else
        declare
	SAVE_NO_SUB_PARAM	: BOOLEAN		:= CODI.NO_SUBP_PARAMS;
        begin
	CODI.OUTPUT_CODE := FALSE;						-- ne pas	coder les	parametres (le body	fera ca)
	CODE_HEADER( HEADER );
	CODI.OUTPUT_CODE := TRUE;
	CODI.NO_SUBP_PARAMS := SAVE_NO_SUB_PARAM;
        end;
      end	if;

    end;
    DEC_LEVEL;

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

      CODE_PACKAGE_SPEC( D(	SM_SPEC, D( AS_SOURCE_NAME, PACKAGE_DECL ) ) );

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
