------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with TEXT_IO; use TEXT_IO;

separate ( EXPANDER	)

				-----------
	package body		EXPRESSIONS
				-----------
is


  package	CODI	renames EXPANDER.UTILS;
  use CODI;

				--====--
  procedure			CODE_EXP			( EXP :TREE )
  is
  begin
    if EXP.TY in CLASS_NAME  then
      CODE_NAME( EXP );

    elsif	 EXP.TY in CLASS_EXP_EXP  then
      CODE_EXP_EXP(	EXP );

    end if;
  end	CODE_EXP;
	--====--


				---------
  procedure			CODE_NAME			( NAME : TREE )
  is				---------

			---------------
    procedure		CODE_DESIGNATOR		( DESIGNATOR : TREE	)
    is
		--------------
      procedure	CODE_USED_NAME		( USED_NAME :TREE )
      is
      begin

        if USED_NAME.TY = DN_USED_OP  then
	CODE_USED_OP( USED_NAME );

        elsif USED_NAME.TY = DN_USED_NAME_ID  then
	CODE_USED_NAME_ID( USED_NAME );

        end if;
      end	CODE_USED_NAME;
	--------------

		----------------
      procedure	CODE_USED_OBJECT		( USED_OBJECT :TREE	)
      is
      begin

        if USED_OBJECT.TY = DN_USED_CHAR  then
	CODE_USED_CHAR( USED_OBJECT );

        elsif USED_OBJECT.TY = DN_USED_OBJECT_ID	then
	CODE_USED_OBJECT_ID( USED_OBJECT );

        end if;
      end	CODE_USED_OBJECT;
	----------------

    begin
      if	DESIGNATOR.TY in CLASS_USED_NAME  then
        CODE_USED_NAME(  NAME	);

      elsif  DESIGNATOR.TY in	CLASS_USED_OBJECT  then
        CODE_USED_OBJECT( NAME );

      end	if;
    end	CODE_DESIGNATOR;
	---------------

			-------------
    procedure		CODE_NAME_EXP		( NAME_EXP :TREE )
    is

		-------------
      procedure	CODE_NAME_VAL		( NAME_VAL : TREE )
      is
      begin
        if  NAME_VAL.TY = DN_SELECTED  then
	CODE_SELECTED( NAME_VAL );

        elsif  NAME_VAL.TY = DN_ATTRIBUTE  then
	CODE_ATTRIBUTE( NAME_VAL );

        elsif  NAME_VAL.TY = DN_FUNCTION_CALL  then
	CODE_FUNCTION_CALL(	NAME_VAL );

        end if;
      end	CODE_NAME_VAL;
	-------------


    begin
      if	NAME_EXP.TY in CLASS_NAME_VAL	 then
        CODE_NAME_VAL(  NAME_EXP );

      elsif NAME_EXP.TY = DN_ALL  then
        CODE_ALL( NAME_EXP );

      elsif  NAME_EXP.TY = DN_INDEXED  then
        CODE_INDEXED( NAME_EXP );									-- LAISSE	UNE ADRESSE
--        declare
--	NAME		: TREE		:= D( AS_NAME, NAME_EXP );
--	ARRAY_BASE_TYPE	: TREE		:= D( SM_BASE_TYPE,	D( SM_EXP_TYPE, NAME) );
--	ARRAY_COMP_TYPE	: TREE		:= D( SM_COMP_TYPE,	ARRAY_BASE_TYPE );
--	COMP_SIZE		: CHARACTER	:= OPER_SIZ_CHAR( ARRAY_COMP_TYPE );
--        begin
--	PUT( tab & 'L' & COMP_SIZE );
--	if  CODI.DEBUG  then PUT( tab50 & "; charge depuis adresse empilee " ); end if;
--	NEW_LINE;
--        end;

      elsif  NAME_EXP.TY = DN_SLICE  then
        CODE_SLICE(	NAME_EXP );

      end	if;
    end	CODE_NAME_EXP;
	-------------

  begin
    if  NAME.TY in CLASS_DESIGNATOR  then
      CODE_DESIGNATOR(  NAME );

    elsif	 NAME.TY in CLASS_NAME_EXP  then
      CODE_NAME_EXP( NAME );

    end if;
  end	CODE_NAME;
	---------


				------------
  procedure			CODE_EXP_EXP		( EXP_EXP	:TREE; TYPE_SPEC_HINT :TREE := TREE_VOID )
  is				------------

			------------
    procedure		CODE_EXP_VAL		( EXP_VAL	:TREE )
    is
		----------------
      procedure	CODE_EXP_VAL_EXP		( EXP_VAL_EXP :TREE	)
      is
	        --------------
        procedure CODE_QUAL_CONV	( QUAL_CONV :TREE )
        is
        begin

	if  QUAL_CONV.TY = DN_CONVERSION  then
	  CODE_CONVERSION( QUAL_CONV );

	elsif  QUAL_CONV.TY	= DN_QUALIFIED  then
	  CODE_QUALIFIED( QUAL_CONV );

	end if;
        end	CODE_QUAL_CONV;
		--------------

	        ---------------
        procedure CODE_MEMBERSHIP	( MEMBERSHIP :TREE )
        is
        begin

	if  MEMBERSHIP.TY =	DN_RANGE_MEMBERSHIP	 then
	  CODE_RANGE_MEMBERSHIP( MEMBERSHIP );

	elsif  MEMBERSHIP.TY = DN_TYPE_MEMBERSHIP  then
	  CODE_TYPE_MEMBERSHIP( MEMBERSHIP );

	end if;
        end	CODE_MEMBERSHIP;
		---------------

      begin
        if EXP_VAL_EXP.TY in CLASS_QUAL_CONV then
	CODE_QUAL_CONV( EXP_VAL_EXP );

        elsif EXP_VAL_EXP.TY in CLASS_MEMBERSHIP then
	CODE_MEMBERSHIP( EXP_VAL_EXP );

        elsif EXP_VAL_EXP.TY = DN_PARENTHESIZED then
	CODE_PARENTHESIZED(	EXP_VAL_EXP );

        end if;

      end	CODE_EXP_VAL_EXP;
      ----------------

    begin
      if	EXP_VAL.TY in CLASS_EXP_VAL_EXP  then
        CODE_EXP_VAL_EXP( EXP_VAL );

      elsif  EXP_VAL.TY = DN_NUMERIC_LITERAL then
        CODE_NUMERIC_LITERAL(	EXP_VAL );

      elsif EXP_VAL.TY = DN_NULL_ACCESS	 then
        CODE_NULL_ACCESS( EXP_VAL );

      elsif  EXP_VAL.TY = DN_SHORT_CIRCUIT  then
        CODE_SHORT_CIRCUIT( EXP_VAL );

      end	if;
    end	CODE_EXP_VAL;
	------------

			------------
    procedure		CODE_AGG_EXP		( AGG_EXP, TYPE_SPEC_HINT :TREE )
    is
    begin
      if AGG_EXP.TY	= DN_AGGREGATE  then
        CODE_AGGREGATE( AGG_EXP, TYPE_SPEC_HINT );

      elsif AGG_EXP.TY = DN_STRING_LITERAL  then
        CODE_STRING_LITERAL( AGG_EXP, ANONYMOUS_NAME_AT( AGG_EXP ) );

      end	if;
    end	CODE_AGG_EXP;
	------------

  begin
    if EXP_EXP.TY in CLASS_EXP_VAL  then
      CODE_EXP_VAL ( EXP_EXP );

    elsif	EXP_EXP.TY in CLASS_AGG_EXP  then
      CODE_AGG_EXP(	EXP_EXP, TYPE_SPEC_HINT );

    elsif	EXP_EXP.TY = DN_QUALIFIED_ALLOCATOR  then
      CODE_QUALIFIED_ALLOCATOR( EXP_EXP	);

    elsif	EXP_EXP.TY = DN_SUBTYPE_ALLOCATOR  then
      CODE_SUBTYPE_ALLOCATOR(	EXP_EXP );

    end if;

  end	CODE_EXP_EXP;
	------------


				------------
  procedure			CODE_USED_OP		( USED_OP	:TREE )
  is				------------
    DEFN		: TREE		:= D( SM_DEFN, USED_OP ) ;
    SYM		: TREE		:= D( LX_SYMREP, DEFN );
  begin
    put_line( "; used op " & PRINT_NAME( SYM ) );
  end	CODE_USED_OP;
	------------


				-----------------
  procedure			CODE_USED_NAME_ID		( USED_NAME_ID :TREE )
  is				-----------------
  begin
    declare
      DEFN	: TREE	:= D( SM_DEFN,   USED_NAME_ID	);
      SYMREP	: TREE	:= D( LX_SYMREP, USED_NAME_ID	);
    begin
      if DEFN.TY = DN_EXCEPTION_ID then
null;--	     declare

      elsif DEFN.TY	= DN_PACKAGE_ID then
        if not DB( CD_COMPILED, DEFN ) then
	declare
	  PACKAGE_SPEC	: TREE	:= D( SM_SPEC, DEFN	);
	begin
	  PUT_LINE( "; RFP"	& PRINT_NAME( SYMREP ) );
	  DB( CD_COMPILED, DEFN, TRUE	);
	  DECLARATIONS.CODE_DECL_S( D( AS_DECL_S1, PACKAGE_SPEC ) );
	end;
        end if;

      elsif DEFN.TY	= DN_PROCEDURE_ID then
        if not DB( CD_COMPILED, DEFN ) then
	declare
	  PROC_LBL	:constant	STRING	:= NEW_LABEL;
	begin
	  DI  ( CD_LEVEL,	   DEFN, 1 );
	  DI  ( CD_PARAM_SIZE, DEFN, 0 );
	  DB  ( CD_COMPILED,   DEFN, TRUE );
	end;
        end if;
      end	if;
    end;
  end	CODE_USED_NAME_ID;
	-----------------


				--------------
  procedure			CODE_USED_CHAR		( USED_CHAR :TREE )
  is				--------------
  begin
    PUT_LINE( tab &	"LI" & tab & IMAGE(	DI( SM_VALUE, USED_CHAR ) ) );
  end	CODE_USED_CHAR;
	--------------


				-------------------
  procedure			CODE_USED_OBJECT_ID		( USED_OBJECT_ID :TREE )
  is				-------------------
    DEFN		: TREE		:= D( SM_DEFN, USED_OBJECT_ID	) ;
  begin
    case DEFN.TY is
    when DN_CONSTANT_ID | DN_VARIABLE_ID	=> CODE_VC_ID( DEFN	);
    when DN_ITERATION_ID			=>
      declare
        ITERATION_ID	: TREE		renames DEFN;
        ITERATION_ID_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, ITERATION_ID ) );
        ITERATION_ID_TAG	: LABEL_TYPE	:= LABEL_TYPE( DI( CD_OFFSET,	ITERATION_ID ) );
        ITERATION_ID_VARSTR	:constant	STRING	:= ITERATION_ID_STR	& LABEL_STR( ITERATION_ID_TAG	) & "_disp";
        TYPE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, ITERATION_ID ) );
      begin
        PUT_LINE( tab & "L" &	TYPE_CHAR	& tab & IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ", " & ITERATION_ID_VARSTR );
      end;

    when DN_ENUMERATION_ID | DN_CHARACTER_ID	=> PUT_LINE( tab & "LI" & tab & IMAGE( DI( SM_REP, DEFN ) ) );

    when DN_IN_ID |	DN_IN_OUT_ID		=>
      if  not CODI.IN_GENERIC_BODY  then
        LOAD_MEM( DEFN );

      elsif  EXPRESSIONS.IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, D( SM_OBJ_TYPE, DEFN ) ) )  then
        PUT_LINE( tab & "LVA " & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ','
		    & tab & '-' & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & "_ofs" );

        PUT_LINE( tab & "La " & LEVEL_NUM'IMAGE( CODI.GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
        PUT_LINE( tab & "La ," & tab & '-' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, D( SM_OBJ_TYPE, DEFN ) ) ) )
			& "__ld_ofs" );
        PUT_LINE( tab & "CALLI" );

      else
        LOAD_MEM( DEFN );

      end if;

    when DN_OUT_ID				=>
	PUT_LINE( "; CODE_USED_OBJECT_ID : OUT_ID a faire " );

    when DN_NUMBER_ID			=>
	CODE_EXP( D( SM_INIT_EXP, DEFN ) );

    when DN_DISCRIMINANT_ID			=>
	PUT_LINE( "; CODE_USED_OBJECT_ID : DISCRIMINANT_ID a faire " );

    when others => PUT_LINE( "; CODE_USED_OBJECT_ID : " & NODE_NAME'IMAGE( DEFN.TY ) & " pas gere !" );
	raise PROGRAM_ERROR;
    end case;

  end	CODE_USED_OBJECT_ID;
	-------------------


				--------
  procedure			CODE_ALL			( ADA_ALL	:TREE )
  is				--------
  begin
    null;
  end	CODE_ALL;
	--------


				------------
  procedure			CODE_INDEXED	( INDEXED	:TREE )
  is				------------

    NAME			: TREE	:= D( AS_NAME, INDEXED );

  begin

    if  NAME.TY = DN_SELECTED	 then
      CODE_SELECTED( NAME, IS_SOURCE=> FALSE );
      NAME := D( AS_DESIGNATOR, NAME );
    end if;

    declare
    ARRAY_NAME		:constant	STRING		:= PRINT_NAME( D( LX_SYMREP, NAME ) );
    ARRAY_DEFN		: TREE			:= D( SM_DEFN, NAME	);
    EXP_TYPE		: TREE			:= D( SM_EXP_TYPE, NAME );
    EXP_TYPE_NAME		: TREE			:= D( XD_SOURCE_NAME, EXP_TYPE );
    TYPE_NAME_STR		:constant	STRING		:= PRINT_NAME( D( LX_SYMREP, EXP_TYPE_NAME ) );
    ARRAY_LVL		: INTEGER			:= 0;
    TYPE_LVL		: INTEGER			:= DI( CD_LEVEL, EXP_TYPE );
    INDEX_NUM		: INTEGER			:= 1;
    IS_PARAM		: BOOLEAN			:= FALSE;
    USE_TYPE_INFO_DIRECT	: BOOLEAN			:= FALSE;

		-----
      procedure	INDEX	( EXP :TREE )
      is		-----

        INDEX_NUM_IMG	:constant	STRING	:= IMAGE(	INDEX_NUM	);
        LVL_IMG		:constant	STRING	:= IMAGE(	ARRAY_LVL	);

      begin
        CODE_EXP( EXP );

        -- Charger FST_n depuis useinfo
        if  IS_PARAM  then
	PUT_LINE(	tab & "LVA" & tab &	LVL_IMG &	", -" & ARRAY_NAME & "_ofs" );
	PUT_LINE(	tab & "LIa" & tab &	", ," & INTEGER'IMAGE( CODI.ADDR_SIZE )	);
	PUT( tab & "Ld" & tab & ", " );

        elsif  USE_TYPE_INFO_DIRECT  then
          PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );

        else
	PUT( tab & "LId" & tab & LVL_IMG & ", "	& ARRAY_NAME & "__u" & ", " );
        end if;

        REGIONS_PATH( EXP_TYPE_NAME );
        PUT( TYPE_NAME_STR & ".FST_" & INDEX_NUM_IMG );
        if  CODI.DEBUG  then PUT( tab50	& "; (index - FST_"	& INDEX_NUM_IMG & ") * SIZ_" & INDEX_NUM_IMG ); end if;
        NEW_LINE;
        PUT_LINE( tab & "SUB"	);

        -- Charger COMP_SIZ depuis useinfo
        if  IS_PARAM  then
	PUT_LINE(	tab & "LVA" & tab &	LVL_IMG &	", -" & ARRAY_NAME & "_ofs" );
	PUT_LINE(	tab & "LIa" & tab &	", ," & INTEGER'IMAGE( CODI.ADDR_SIZE )	);
	PUT( tab & "Ld" & tab & ", " );

        elsif  USE_TYPE_INFO_DIRECT  then
          PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );

        else
	PUT( tab & "LId" & tab & LVL_IMG & ", "	& ARRAY_NAME & "__u" & ", " );
        end if;
        REGIONS_PATH( EXP_TYPE_NAME );
        PUT_LINE( TYPE_NAME_STR & ".COMP_SIZ" );								-- En bits
        PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
        PUT_LINE( tab & "DIV" );									-- En STORAGE_UNIT
        PUT_LINE( tab & "MUL"	);
        PUT( tab & "ADD" );
        if  CODI.DEBUG  then PUT( tab50	& "; add offset to start address" ); end if;
        NEW_LINE;

      end	INDEX;
	-----

    begin
      if ARRAY_DEFN.TY /= DN_COMPONENT_ID  then

        ARRAY_LVL := DI( CD_LEVEL, ARRAY_DEFN );

        if  ARRAY_DEFN.TY in CLASS_PARAM_NAME  then
	-- Parametre composite : charger ptr_data via le doublet
	IS_PARAM := TRUE;
	PUT_LINE(	tab & "LVA" & tab &	IMAGE( ARRAY_LVL ) & ", -" & ARRAY_NAME	& "_ofs" );
	PUT(  tab	& "LIa" &	tab & ", , 0" );

        else
	-- Variable locale : acces direct a _disp dans le	frame
	PUT(  tab	& "La" & tab & INTEGER'IMAGE(	ARRAY_LVL	) & ", " & ARRAY_NAME & "_disp" );
        end if;
        if  CODI.DEBUG  then PUT( tab50	& "; array data start address on stack"	); end if;
        NEW_LINE;

      else

        if CODI.DEBUG then
	PUT_LINE(	"; EXPRESSIONS.CODE_INDEXED adresse component id" );
        end if;
        -- Cas R.A(N) : l'adresse de R.A a deja ete empilee par CODE_SELECTED.
        -- Il n'y a pas de A__u objet ; les infos viennent du type TABLE.
        USE_TYPE_INFO_DIRECT := TRUE;

      end	if;

      declare
        EXP_SEQ	: SEQ_TYPE	:= LIST( D( AS_EXP_S, INDEXED	) );
        EXP	: TREE;
      begin
        while  not IS_EMPTY( EXP_SEQ )	loop
	POP( EXP_SEQ, EXP );
	INDEX( EXP );
	INDEX_NUM	:= INDEX_NUM + 1;
        end loop;
      end;

    end;
  end	CODE_INDEXED;
	------------


				----------
  procedure			CODE_SLICE		( SLICE :TREE; IS_DESTINATION	:BOOLEAN := TRUE )
  is				----------
    NAME			: TREE	:= D( AS_NAME, SLICE );
    DISCRETE_RANGE		: TREE	:= D( AS_DISCRETE_RANGE, SLICE );
    SLICE_TYPE		: TREE	:= D( SM_EXP_TYPE, SLICE );
    SLICE_COMP_TYPE		: TREE	:= D( SM_COMP_TYPE,	SLICE_TYPE );
    COMP_SIZE		: INTEGER	:= DI( CD_IMPL_SIZE, SLICE_COMP_TYPE );
  begin
    if  NAME.TY = DN_SELECTED	 then
      CODE_SELECTED( NAME );

    elsif	 NAME.TY = DN_USED_OBJECT_ID	then
      declare
	DEFN		: TREE		:= D( SM_DEFN, NAME	);
	DEFN_LVL		: INTEGER		:= DI( CD_LEVEL, DEFN );
	DEFN_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
      begin
	PUT_LINE(	tab & "La " & IMAGE( DEFN_LVL	) & ", " & DEFN_STR & "_disp" );
	CODE_EXP(	D( AS_EXP1, DISCRETE_RANGE ) );
	PUT_LINE(	tab & "LId " & IMAGE( DEFN_LVL ) & ", " & DEFN_STR & "__u"
		& ", " & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, SLICE_TYPE ) ) )
		& ".FST_1" );
	PUT_LINE(	tab & "SUB" );
	PUT_LINE(	tab & "LI" & tab & IMAGE( COMP_SIZE / CODI.STORAGE_UNIT ) );
	PUT_LINE(	tab & "MUL" );
	PUT_LINE(	tab & "ADD" );
      end;

    else
      PUT_LINE( "; CODE_SLICE : NAME.TY A FAIRE : " & NODE_NAME'IMAGE( NAME.TY ) );
    end if;

    if  IS_DESTINATION  then										-- Taille	pour un BLKMOV
      CODE_EXP( D( AS_EXP2, DISCRETE_RANGE ) );
      PUT_LINE( tab	& "INC" );
      CODE_EXP( D( AS_EXP1, DISCRETE_RANGE ) );
      PUT_LINE( tab	& "SUB" );
      PUT_LINE( tab	& "LI" & tab & IMAGE( COMP_SIZE / CODI.STORAGE_UNIT ) );
      PUT_LINE( tab	& "MUL" );

    else
      declare
        ANON_NAME	:constant	STRING		:= ANONYMOUS_NAME_AT( SLICE );
        LEVEL	: LEVEL_NUM		:= CODI.CUR_LEVEL;
      begin
        PUT( "namespace " & ANON_NAME );
        if  CODI.DEBUG  then PUT( tab50	& "; ensemble doublet @data/@info pour slice anonyme source" ); end if;
        NEW_LINE;
        PUT_LINE( "VAR " & ANON_NAME & "_disp, q"	);
        PUT_LINE( "VAR " & ANON_NAME & "__u, q" );

        PUT_LINE( "VAR " & "SIZ, d" );
        PUT_LINE( "VAR " & "COMP_SIZ, d" );
        PUT_LINE( "VAR " & "FST_1, d" );
        PUT_LINE( "VAR " & "LST_1, d" );

        PUT_LINE( tab & "Sa" & tab & IMAGE( CODI.CUR_LEVEL )  & ", " & ANON_NAME & "_disp" );
        PUT_LINE( tab & "LVA"	&  tab & IMAGE( CODI.CUR_LEVEL )  & ", SIZ" );
        PUT_LINE( tab & "Sa" & tab & IMAGE( CODI.CUR_LEVEL )  & ", " & ANON_NAME & "__u" );
        PUT_LINE( tab & "LI" & tab & IMAGE( COMP_SIZE ) );							-- En bits
        PUT_LINE( tab & "Sd" & tab & IMAGE( CODI.CUR_LEVEL )  & ", COMP_SIZ" );
        CODE_EXP( D( AS_EXP1,	DISCRETE_RANGE ) );
        PUT_LINE( tab & "Sd" & tab & IMAGE( CODI.CUR_LEVEL )  & ", FST_1" );
        CODE_EXP( D( AS_EXP2,	DISCRETE_RANGE ) );
        PUT_LINE( tab & "Sd" & tab & IMAGE( CODI.CUR_LEVEL )  & ", LST_1" );

        PUT_LINE( tab & "Ld" & tab & IMAGE( CODI.CUR_LEVEL )  & ", LST_1" );
        PUT_LINE( tab & "INC"	);
        PUT_LINE( tab & "Ld" & tab & IMAGE( CODI.CUR_LEVEL )  & ", FST_1" );
        PUT_LINE( tab & "SUB"	);
        PUT_LINE( tab & "LI" & tab & IMAGE( COMP_SIZE ) );							-- En bits
        PUT_LINE( tab & "MUL"	);
        PUT_LINE( tab & "Sd" & tab & IMAGE( CODI.CUR_LEVEL )  & ", SIZ" );

        PUT_LINE( tab & "LVA"	&  tab & IMAGE( CODI.CUR_LEVEL )  & ", " & ANON_NAME & "_disp" );

        PUT_LINE( "end namespace");
      end;

    end if;
  end	CODE_SLICE;
	----------


				-------------
  procedure			CODE_SELECTED	( SELECTED :TREE; IS_SOURCE :BOOLEAN :=	TRUE;
						  CONTEXT :TREE := TREE_VOID )
  is				-------------

    EXP_TYPE	: TREE	:= D( SM_EXP_TYPE, SELECTED );
    DEFN		: TREE	:= D( SM_DEFN, D( AS_DESIGNATOR, SELECTED ) );
    VAR_ID	: TREE;

			----------------
    procedure		RECURSE_SELECTED	( SELECTED :TREE )
    is			----------------

      NAME		: TREE		:= D( AS_NAME, SELECTED );
		------------------
      procedure	PROCESS_DESIGNATOR
      is		------------------

        DESIGNATOR		: TREE		:= D( AS_DESIGNATOR, SELECTED	);
        DESIGNATOR_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DESIGNATOR	) );
        DESIGNATOR_DEFN	: TREE		:= D( SM_DEFN, DESIGNATOR );
        DESIGNATOR_LEVEL	: INTEGER;

      begin
	if  DESIGNATOR_DEFN.TY = DN_VARIABLE_ID	 then
	  if  D( SM_EXP_TYPE, DESIGNATOR ).TY in CLASS_SCALAR  then
	    DESIGNATOR_LEVEL := DI( CD_LEVEL, DESIGNATOR_DEFN );
	    PUT_LINE( tab &	"L" & OPER_SIZ_CHAR( D( SM_EXP_TYPE, DESIGNATOR ) )
			& tab & IMAGE( DESIGNATOR_LEVEL ) & ", " & DESIGNATOR_STR  );
	  end if;

	elsif  DESIGNATOR_DEFN.TY = DN_COMPONENT_ID  then

	  if  NAME.TY = DN_USED_OBJECT_ID  then

	    if  D( SM_DEFN,	NAME ).TY	in  CLASS_PARAM_NAME  then
	      PUT_LINE( tab	& "La "
		& IMAGE( DI( CD_LEVEL, D( SM_DEFN, NAME	) ) ) & ", "
		& '-' & PRINT_NAME(	D(LX_SYMREP, NAME )	) & "_ofs" );

	      if	D( SM_EXP_TYPE, DESIGNATOR ).TY in CLASS_SCALAR  and  IS_SOURCE  then
	        PUT( tab & "LI" & OPER_SIZ_CHAR( D( SM_EXP_TYPE, DESIGNATOR )	) );

	      else
	        PUT( tab & "LIVA " );
	      end	if;

	      PUT( tab & ", 0, " );
	      REGIONS_PATH(	DESIGNATOR_DEFN );
	      PUT_LINE( DESIGNATOR_STR );

	    else
	      if	D( SM_EXP_TYPE, DESIGNATOR ).TY in CLASS_SCALAR  and  IS_SOURCE  then
	        PUT( tab & "LI" & OPER_SIZ_CHAR( D( SM_EXP_TYPE, DESIGNATOR )	) );
	      else
	        PUT( tab & "LIVA " );
	      end	if;

	      PUT( tab & IMAGE( DI( CD_LEVEL, D( SM_DEFN,	NAME ) ) ) & ", " );
	      PUT( PRINT_NAME( D(LX_SYMREP, NAME ) ) & "_disp, " );
	      REGIONS_PATH(	DESIGNATOR_DEFN );
	      PUT_LINE( DESIGNATOR_STR );

	    end if;

	  else
	    -- NAME est une expression composite resolue en adresse directe sur la pile
	    if  D( SM_EXP_TYPE, DESIGNATOR ).TY in CLASS_SCALAR  and  IS_SOURCE  then
	      -- Champ scalaire terminal : load direct depuis l'adresse en sommet de pile
	      PUT( tab & "L" & OPER_SIZ_CHAR( D( SM_EXP_TYPE, DESIGNATOR ) ) );
	      PUT( tab & ", " );
	      REGIONS_PATH( DESIGNATOR_DEFN );
	      PUT_LINE( DESIGNATOR_STR );
	    else
	      -- Champ composite : calculer l'adresse pour sélection ultérieure
	      PUT( tab & "LVA" & tab & ", " );
	      REGIONS_PATH( DESIGNATOR_DEFN );
	      PUT_LINE( DESIGNATOR_STR );
	    end if;

	  end if;

	elsif  DESIGNATOR_DEFN.TY = DN_CONSTANT_ID
		or  DESIGNATOR_DEFN.TY = DN_NUMBER_ID
		or  DESIGNATOR_DEFN.TY = DN_ENUMERATION_ID
	then
	  PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( SM_VALUE, DESIGNATOR ) )	);

	elsif  DESIGNATOR_DEFN.TY = DN_FUNCTION_ID
	then
	  PUT( tab & "LI" & tab &	"0" );
	  if	CODI.DEBUG  then  PUT( tab50 & "; lieu resultat sur pile" ); end if;
	  NEW_LINE;
	  INSTRUCTIONS.CODE_PROCEDURE_CALL(	CONTEXT, DESIGNATOR );

	else
	  PUT_LINE( "; CODE_SELECTED.RECURSE_SELECTED DESIGNATOR.TY PAS FAIT: " & NODE_NAME'IMAGE( DESIGNATOR_DEFN.TY	) );
	end if;

      end	PROCESS_DESIGNATOR;
	------------------
    begin
      if	NAME.TY =	DN_SELECTED  then
        RECURSE_SELECTED( NAME ) ;
        PROCESS_DESIGNATOR;

      elsif  NAME.TY = DN_INDEXED  then
        CODE_INDEXED( NAME ) ;
        PROCESS_DESIGNATOR;

      elsif  NAME.TY = DN_USED_OBJECT_ID  then
        declare
	DEFN		: TREE		:= D( SM_DEFN, NAME	);
	OBJ_TYPE		: TREE		:= D( SM_OBJ_TYPE, DEFN );
	OBJ_LEVEL		: INTEGER		:= DI( CD_LEVEL, DEFN );
	OBJ_NAME_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
        begin
	if  D( SM_EXP_TYPE,	NAME ).TY	in CLASS_SCALAR  then
	  PUT_LINE( tab & "L" & OPER_SIZ_CHAR( DEFN ) & tab & IMAGE( OBJ_LEVEL ) & ", "	& OBJ_NAME_STR  );
	end if;
        end;

        PROCESS_DESIGNATOR;

      elsif  NAME.TY = DN_USED_NAME_ID	then
        PROCESS_DESIGNATOR;

      end	if;
    end	RECURSE_SELECTED;
	----------------

  begin
    RECURSE_SELECTED( SELECTED );

  end	CODE_SELECTED;
	-------------


			--^^^^^^^^^^^^^^^--
  procedure		CODE_OBJECT_ADDRESS		( NAME : TREE )
  is			-------------------
  begin
    case  NAME.TY  is
    when DN_USED_OBJECT_ID =>
				----------------------
				USED_OBJECT_ID_ADDRESS:
      declare
        DEFN	: TREE		:= D( SM_DEFN, NAME );
        OBJ_TYPE	: TREE		:= D( SM_EXP_TYPE, NAME );
        DEFN_STR	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
        DEFN_LVL	: INTEGER		:= DI( CD_LEVEL, DEFN );

      begin
      -- Cas d’un alias déjà construit : son _disp contient l’adresse réelle.
        if  DEFN.TY in CLASS_VC_NAME  and then  DB( SM_RENAMES_OBJ, DEFN )
        then
	PUT_LINE( tab & "La" & tab & IMAGE( DEFN_LVL ) & ", " & DEFN_STR & "_disp" );

        elsif  DEFN.TY in CLASS_PARAM_NAME  then
        -- Paramètre scalaire in : adresse de la copie locale.
	if  DEFN.TY = DN_IN_ID  and then  OBJ_TYPE.TY in CLASS_SCALAR  then
	  PUT_LINE( tab & "LVa" & tab & IMAGE( DEFN_LVL ) & ", -" & DEFN_STR & "_ofs" );

        -- Paramètre out/in_out scalaire : le slot contient déjà @destination.
	elsif  OBJ_TYPE.TY in CLASS_SCALAR  then
	  PUT_LINE( tab & "La" & tab & IMAGE( DEFN_LVL ) & ", -" & DEFN_STR & "_ofs" );

        -- Paramètre composite : le slot contient @doublet ; on extrait data_ptr.
	else
	  PUT_LINE( tab & "La" & tab & IMAGE( DEFN_LVL ) & ", -" & DEFN_STR & "_ofs" );
	  PUT_LINE( tab & "La" & tab & ", 0" );
	end if;

        else
        -- Variable autonome.
	if  OBJ_TYPE.TY in CLASS_SCALAR  then
	  PUT_LINE( tab & "LVa" & tab & IMAGE( DEFN_LVL ) & ", " & DEFN_STR & "_disp" );
	else
	  PUT_LINE( tab & "La" & tab & IMAGE( DEFN_LVL ) & ", " & DEFN_STR & "_disp" );
          end if;
        end if;
      end		USED_OBJECT_ID_ADDRESS;
		----------------------

    when DN_SELECTED =>
      CODE_SELECTED( NAME, IS_SOURCE => FALSE );

    when DN_INDEXED =>
      CODE_INDEXED( NAME );

    when DN_SLICE =>
      PUT_LINE( "; CODE_OBJECT_ADDRESS: renames slice a traiter plus tard" );
      raise PROGRAM_ERROR;

    when DN_ALL =>
    -- À reprendre quand DN_ALL sera complet.
      PUT_LINE( "; CODE_OBJECT_ADDRESS: DN_ALL a faire" );
      raise PROGRAM_ERROR;

    when others =>
      PUT_LINE( "; CODE_OBJECT_ADDRESS: NAME.TY non gere " & NODE_NAME'IMAGE( NAME.TY ) );
    raise PROGRAM_ERROR;

    end case;

  end	CODE_OBJECT_ADDRESS;
	-------------------


			----------------------
  function		IS_GENERIC_FORMAL_TYPE	( TYPE_DEFN : TREE )	return BOOLEAN
  is			----------------------

    REGION_ID	: TREE	:= D( XD_REGION, TYPE_DEFN );

  begin
    if  REGION_ID.TY /= DN_GENERIC_ID  then
      return FALSE;
    end if;
				------------------
				SEARCH_FORMAL_TYPE:
    declare
      G_PARAMS	: SEQ_TYPE	:= LIST( D( SM_GENERIC_PARAM_S, REGION_ID ) );
      G_PARAM	: TREE;
    begin
      while  not IS_EMPTY( G_PARAMS )  loop
        POP( G_PARAMS, G_PARAM );

        if  G_PARAM.TY = DN_TYPE_DECL
        and then  D( AS_SOURCE_NAME, G_PARAM ) = TYPE_DEFN
        then
          return TRUE;
        end if;
      end loop;
    end			SEARCH_FORMAL_TYPE;
			------------------
    return FALSE;

  end	IS_GENERIC_FORMAL_TYPE;
	----------------------



				--------------
  procedure			CODE_ATTRIBUTE		( ATTRIBUTE :TREE )
  is				--------------

    PREFIX_NAME		: TREE		:= LAST_OF_SELECTED( D( AS_NAME, ATTRIBUTE ) );
    CHN_PREFIX		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, PREFIX_NAME ) );
    CHN_ATTR_NAME		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, D( AS_USED_NAME_ID, ATTRIBUTE ) ) );
    subtype CHN_STD		is STRING( 1 .. CHN_ATTR_NAME'LENGTH );
    CHN_ATTR		: CHN_STD		:= CHN_ATTR_NAME;						-- NORMALISER EN STRING A FIRST=1



		------------
    procedure	CODE_ADDRESS
    is		------------
      PREFIX_DEFN		: TREE		:= D( SM_DEFN, PREFIX_NAME );
      PREFIX_LVL		: INTEGER		:= DI( CD_LEVEL, PREFIX_DEFN );
      TYPE_SPEC		: TREE		:= D( SM_OBJ_TYPE, PREFIX_DEFN );
      TYPE_NAME		: TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
      TYPE_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
    begin
      if  CODI.IN_GENERIC_BODY  then

        if  PREFIX_DEFN.TY = DN_IN_ID  then
	PUT_LINE( tab & "LVA"	& tab & IMAGE( PREFIX_LVL ) & ", -" & CHN_PREFIX & "_ofs" );
          PUT_LINE( tab & "La " & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & "-GFP_ofs" );
          PUT_LINE( tab & "La" & tab & ", -" & TYPE_STR & "__inadr_ofs" );					-- Conversion pout IN

        elsif  PREFIX_DEFN.TY  in  CLASS_PARAM_IO_O  then
	PUT_LINE( tab & "LVA"	& tab & IMAGE( PREFIX_LVL ) & ", -" & CHN_PREFIX & "_ofs" );
          PUT_LINE( tab & "La " & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & "-GFP_ofs" );
          PUT_LINE( tab & "La" & tab & ", -" & TYPE_STR & "__outadr_ofs" );					-- Conversion pour OUT ou IN_OUT

        else
	PUT_LINE( "; CODE_ADDRESS PREFIX_DEFN.TY pas gere " & NODE_NAME'IMAGE( PREFIX_DEFN.TY ) );

        end if;

        PUT_LINE( tab & "CALLI" );

      end if;

    end	CODE_ADDRESS;
	------------


		----------------
    procedure	CODE_CONSTRAINED
    is		----------------
      PREFIX_DEFN		: TREE	:= D( SM_DEFN, PREFIX_NAME );
      TYPE_SPEC		: TREE	:= TREE_VOID;
    begin
      if  PREFIX_DEFN.TY in CLASS_TYPE_NAME  then
        TYPE_SPEC := D( SM_TYPE_SPEC, PREFIX_DEFN );

      elsif  PREFIX_DEFN.TY in CLASS_OBJECT_NAME  then
        TYPE_SPEC := D( SM_OBJ_TYPE, PREFIX_DEFN );

      else
        PUT_LINE( "; ATTRIBUTE CONSTRAINED : PREFIX NON TRAITE "
	        & NODE_NAME'IMAGE( PREFIX_DEFN.TY ) );
        PUT_LINE( tab & "LI" & tab & "0" );
        return;
      end if;

      if  IS_GENERIC_FORMAL_TYPE( PREFIX_DEFN )  then
	declare
	  TYPE_NAME	: TREE := D( XD_SOURCE_NAME, TYPE_SPEC );
	  TYPE_STR	: constant STRING := PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	begin
	  -- Convention provisoire :
	  -- un type formel est considere contraint ssi sa taille n'est pas -1.
	  -- Cela couvre correctement le cas vise pour DIRECT_IO : type private contraint.
	  PUT_LINE( tab & "La " & INTEGER'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & "-GFP_ofs" );
	  PUT_LINE( tab & "LId , -" & TYPE_STR & "__u_ofs" );
	  PUT_LINE( tab & "LI" & tab & "-1" );
	  PUT_LINE( tab & "CNE" );
	end;

      else
	if  TYPE_SPEC.TY = DN_PRIVATE  or  TYPE_SPEC.TY = DN_L_PRIVATE  then
	  TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
	end if;

        case TYPE_SPEC.TY is
        when DN_ARRAY =>
	  PUT_LINE( tab & "LI" & tab & "0" );

        when DN_CONSTRAINED_ARRAY
	   | DN_INTEGER
	   | DN_FLOAT
	   | DN_ENUMERATION
	   | DN_ACCESS
	   | DN_RECORD =>
	  PUT_LINE( tab & "LI" & tab & "1" );

        when others =>
	  PUT_LINE( "; ATTRIBUTE CONSTRAINED : TYPE NON TRAITE "
	          & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
	  PUT_LINE( tab & "LI" & tab & "0" );
        end case;
      end if;

    end	CODE_CONSTRAINED;
	----------------

		---------------
    procedure	CODE_FIRST_LAST	( IS_LAST	:BOOLEAN )
    is		---------------
      PREFIX_DEFN		: TREE		:= D( SM_DEFN, PREFIX_NAME );
    begin

      if	PREFIX_NAME.TY = DN_USED_OBJECT_ID  then							-- UNE VARIABLE TABLEAU
        if  ( D( SM_EXP_TYPE,	PREFIX_NAME ).TY = DN_CONSTRAINED_ARRAY	)
         or ( D( SM_EXP_TYPE,	PREFIX_NAME ).TY = DN_ARRAY  and  D( SM_DEFN, PREFIX_NAME ).TY = DN_CONSTANT_ID	)
        then
	declare
	  ARRAY_LVL	: INTEGER		:= DI( CD_LEVEL, PREFIX_DEFN );
	  PREFIX_TYPE	: TREE		:= D( SM_EXP_TYPE, PREFIX_NAME );
	  TYPE_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, PREFIX_TYPE	) ) );
	  DIM_EXP		: TREE		:= D( AS_EXP, ATTRIBUTE );
	  NUM_DIM		: INTEGER		:= 1;
	begin
	  if DIM_EXP /= TREE_VOID then
	    NUM_DIM := DI( SM_VALUE, DIM_EXP );
	  end if;
	  PUT( tab & "LId" & tab & IMAGE( ARRAY_LVL ) & ", " & CHN_PREFIX & "__u" & ", " & TYPE_STR );
	  if  IS_LAST  then
	    PUT( ".LST_"  );
	  else
	    PUT( ".FST_" );
	  end if;
	  PUT_LINE( IMAGE( NUM_DIM ) );
	end;

        elsif  ( D( SM_EXP_TYPE, PREFIX_NAME ).TY = DN_ARRAY
	       or  D( SM_EXP_TYPE, PREFIX_NAME ).TY = DN_CONSTRAINED_ARRAY )
	and  PREFIX_DEFN.TY in CLASS_PARAM_NAME
        then
	-- Parametre array : acces useinfo via le doublet
	declare
	  ARRAY_LVL	: INTEGER		:= DI( CD_LEVEL, PREFIX_DEFN );
	  PREFIX_TYPE	: TREE		:= D( SM_EXP_TYPE, PREFIX_NAME );
	  TYPE_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, PREFIX_TYPE	) ) );
	  DIM_EXP		: TREE		:= D( AS_EXP, ATTRIBUTE );
	  NUM_DIM		: INTEGER		:= 1;
	begin
	  if DIM_EXP /= TREE_VOID then
	    NUM_DIM := DI( SM_VALUE, DIM_EXP );
	  end if;
	  PUT_LINE( tab & "LVA" & tab	& IMAGE( ARRAY_LVL ) & ", -" & CHN_PREFIX & "_ofs" );
	  PUT_LINE( tab & "LIa" & tab	& ", ," &	INTEGER'IMAGE( CODI.ADDR_SIZE	) );
	  PUT( tab & "Ld" &	tab & ", " & TYPE_STR );
	  if  IS_LAST  then
	    PUT( ".LST_"  );
	  else
	    PUT( ".FST_" );
	  end if;
	  PUT_LINE( IMAGE( NUM_DIM ) );
	end;

        end if;

      elsif  PREFIX_NAME.TY =	DN_USED_NAME_ID  then							-- UN NOM	DE TYPE
        if  PREFIX_DEFN.TY = DN_TYPE_ID	 then

	if  CODI.IN_GENERIC_BODY  and then  IS_GENERIC_FORMAL_TYPE( PREFIX_DEFN )  then

	  declare
	    CHN_LID	:constant	STRING
			 := tab & "LId , -" & CHN_PREFIX & "__u_ofs, STANDARD.ENUM_USE_INFO";

	  begin
	    PUT_LINE( tab & "La " & IMAGE( CODI.GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
	    if  IS_LAST  then
	      PUT_LINE( CHN_LID & ".LST" );
	    else
	      PUT_LINE( CHN_LID & ".FST" );
	    end if;
	  end;

	else
	  declare
	    TYPE_RANGE	: TREE	:= D( SM_RANGE, D( SM_TYPE_SPEC, PREFIX_DEFN ) );
	  begin
	    PUT( tab & "LI" & tab );
	    if  IS_LAST  then
	      PUT_LINE( PRINT_NUM( D( SM_VALUE, D( AS_EXP2, TYPE_RANGE ) ) ) );
	    else
	      PUT_LINE( PRINT_NUM( D( SM_VALUE, D( AS_EXP1, TYPE_RANGE ) ) ) );
	    end if;
	  end;
	end if;
        end if;
      end	if;

    end	CODE_FIRST_LAST;
	---------------

		----------
    procedure	CODE_IMAGE
    is		----------
--      ARG		: TREE		:= D( AS_EXP, ATTRIBUTE );
--      ANON	:constant STRING	:= ANONYMOUS_NAME_AT( ATTRIBUTE );
--      LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
    begin
      -- Réserver le doublet résultat STRING attendu par INTEGER_IMAGE.
--      PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
--      PUT_LINE( "VAR" & tab & ANON & "__u,   q" );
--      PUT_LINE( "namespace " & ANON & "_info" );
--      PUT_LINE( "  VAR SIZ,      d" );
--      PUT_LINE( "  VAR COMP_SIZ, d" );
--      PUT_LINE( "  VAR FST_1,    d" );
--      PUT_LINE( "  VAR LST_1,    d" );
--      PUT_LINE( "end namespace" );

      -- Initialiser info_ptr du doublet résultat.
--      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_info.SIZ" );
--      PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON & "__u" );

      -- Convention fonction retournant array :
      -- empiler d'abord result__ofs, puis les paramètres Ada.
      -- Paramètre ITEM.
--      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );
--      CODE_EXP( ARG );

      -- Appel de la primitive Ada cachée.
      PUT_LINE( tab & "CALL" & tab & "STANDARD. ,INTEGER_IMAGE_L9" );

      -- Résultat de l'expression : adresse du doublet.
--      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );

    end	CODE_IMAGE;
	----------

		-----------
    procedure	CODE_LENGTH
    is		-----------
      PREFIX_TYPE		: TREE		:= D( SM_EXP_TYPE, PREFIX_NAME );				-- Un tableau
      PREFIX_DEFN		: TREE		:= D( SM_DEFN, PREFIX_NAME );
      ARRAY_LVL		: INTEGER		:= DI( CD_LEVEL, PREFIX_DEFN );
      PREFIX_TYPE_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, PREFIX_TYPE	) ) );
    begin
      if	PREFIX_DEFN.TY in CLASS_PARAM_NAME  then							-- On a juste l'adresse de la	VAR disp

        PUT_LINE( tab & "LVA"	& tab & IMAGE( ARRAY_LVL ) & ", -" & CHN_PREFIX &	"_ofs" );
        PUT_LINE( tab & "LIa"	& tab & ", ," & INTEGER'IMAGE( CODI.ADDR_SIZE ) );
        PUT_LINE( tab & "Ld" & tab & ", " & PREFIX_TYPE_STR	& ".LST_1");
        PUT_LINE( tab & "INC"	);
        PUT_LINE( tab & "LVA"	& tab & IMAGE( ARRAY_LVL ) & ", -" & CHN_PREFIX &	"_ofs" );
        PUT_LINE( tab & "LIa"	& tab & ", ," & INTEGER'IMAGE( CODI.ADDR_SIZE ) );
        PUT_LINE( tab & "Ld" & tab & ", " & PREFIX_TYPE_STR	& ".FST_1");
        PUT_LINE( tab & "SUB"	);

      else
        declare
	CHN_LID		:constant	STRING	:= tab & "LId" & tab & IMAGE(	ARRAY_LVL	) & ", "
					   & CHN_PREFIX & "__u" & ", " & PREFIX_TYPE_STR;
        begin
	PUT_LINE(	CHN_LID &	".LST_1" );
	PUT_LINE(	tab & "INC" );
	PUT_LINE(	CHN_LID &	".FST_1" );
	PUT_LINE(	tab & "SUB" );
        end;
      end	if;

    end	CODE_LENGTH;
	-----------

		--------
    procedure	CODE_POS
    is		--------
      PREFIX_DEFN		: TREE		:= D( SM_DEFN, PREFIX_NAME );
    begin
      null;
    end	CODE_POS;
    --------

		---------
    procedure	CODE_SIZE
    is		---------
      PREFIX_DEFN		: TREE	:= D( SM_DEFN, PREFIX_NAME );
      TYPE_SPEC		: TREE;
    begin
      if  PREFIX_DEFN.TY in CLASS_TYPE_NAME  then
        TYPE_SPEC := D( SM_TYPE_SPEC, PREFIX_DEFN );

      elsif  PREFIX_DEFN.TY in CLASS_OBJECT_NAME  then
        TYPE_SPEC := D( SM_OBJ_TYPE, PREFIX_DEFN );

      else
        PUT_LINE( "; ATTRIBUTE SIZE : PREFIX NON TRAITE " & NODE_NAME'IMAGE( PREFIX_DEFN.TY ) );
      end if;
			---------
			TYPE_SIZE:
      declare
        TYPE_NAME		: TREE	:= D( XD_SOURCE_NAME, TYPE_SPEC );
        TYPE_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );

      begin
        if  IS_GENERIC_FORMAL_TYPE( PREFIX_DEFN )  then							-- TYPE FORMEL GENERIQUE
	PUT_LINE( tab & "La " & INTEGER'IMAGE( CODI.GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
--	PUT_LINE( tab & "La " & INTEGER'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & "-GFP_ofs" );
	PUT_LINE( tab & "LId , -" & TYPE_STR & "__u_ofs" );

        else
	if  TYPE_SPEC.TY = DN_PRIVATE  or  TYPE_SPEC.TY = DN_L_PRIVATE  then
	  TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
	end if;

	PUT( tab & "LId" & tab );
	PUT( INTEGER'IMAGE( DI( CD_LEVEL, TYPE_SPEC ) ) & ", " );
	CODI.REGIONS_PATH( TYPE_NAME );
	PUT_LINE( TYPE_STR & ".use__info" );
        end if;

      end		TYPE_SIZE;
		---------

    end	CODE_SIZE;
	---------


		----------
    procedure	CODE_SMALL
    is		----------
      PREFIX_DEFN		: TREE		:= D( SM_DEFN, PREFIX_NAME );
      TYPE_SPEC		: TREE		:= D( SM_TYPE_SPEC, PREFIX_DEFN );

    begin
      if  CODI.IN_GENERIC_BODY  and then  IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, TYPE_SPEC ) )  then		-- Passer par le use__info
        declare
	TYPE_NAME		: TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
	TYPE_STR		: constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
        begin
	PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );			-- Adresse de frame generique
	PUT_LINE( tab & "LIq , -" & TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.NUMER " );			-- Charge l'entier NUMER
	PUT_LINE( tab & "CVTIF" );

	PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );			-- Adresse de frame generique
	PUT_LINE( tab & "LIq , -" & TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.DENOM" );			-- Charge l'entier DENOM
	PUT_LINE( tab & "CVTIF" );
	PUT_LINE( tab & "FDIV" );									-- / DENOM
        end;

      else
        declare
	BASE_TYPE		: TREE		:= D( SM_BASE_TYPE, TYPE_SPEC );
	BASE_TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, BASE_TYPE );
	BASE_SPEC		: TREE		:= D( SM_TYPE_SPEC, BASE_TYPE_NAME );
	SMALL_VAL		: TREE		:= D( CD_IMPL_SMALL, BASE_SPEC );

	NUM_PART		: LONG_INTEGER	:= LONG_INTEGER'VALUE( PRINT_NUM( D( XD_NUMER, SMALL_VAL ) ) );
	DEN_PART		: LONG_INTEGER	:= LONG_INTEGER'VALUE( PRINT_NUM( D( XD_DENOM, SMALL_VAL ) ) );
	REAL_SMALL	: LONG_FLOAT	:= LONG_FLOAT( NUM_PART ) / LONG_FLOAT( DEN_PART );
	package LF_IO	is new FLOAT_IO( LONG_FLOAT );
        begin
	PUT( tab & "LIF" & tab ); LF_IO.PUT( REAL_SMALL ); NEW_LINE;
        end;
      end if;

    end	CODE_SMALL;
	----------


		----------
    procedure	CODE_WIDTH
    is		----------
      PREFIX_DEFN	: TREE := D( SM_DEFN, PREFIX_NAME );
      TYPE_SPEC	: TREE := TREE_VOID;
      BITS	: INTEGER := 0;
    begin
      if  PREFIX_DEFN.TY in CLASS_TYPE_NAME  then
        TYPE_SPEC := D( SM_TYPE_SPEC, PREFIX_DEFN );

      elsif  PREFIX_DEFN.TY in CLASS_OBJECT_NAME  then
        TYPE_SPEC := D( SM_OBJ_TYPE, PREFIX_DEFN );

      else
        PUT_LINE( "; ATTRIBUTE WIDTH : PREFIX NON TRAITE " & NODE_NAME'IMAGE( PREFIX_DEFN.TY ) );
        PUT_LINE( tab & "LI" & tab & "0" );
        return;
      end if;

      if  TYPE_SPEC.TY = DN_PRIVATE  or  TYPE_SPEC.TY = DN_L_PRIVATE  then
        TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
      end if;

      if  IS_GENERIC_FORMAL_TYPE( PREFIX_DEFN )  then
	declare
	  TYPE_NAME	: TREE := D( XD_SOURCE_NAME, TYPE_SPEC );
	  TYPE_STR	: constant STRING := PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	begin
	  if  CODI.DEBUG  then  PUT_LINE( "; WIDTH POUR FORMAL TYPE" );  end if;
	  PUT_LINE( tab & "LI" & tab & '0' );								-- lieu resultat sur pile
	  PUT_LINE( tab & "La " & INTEGER'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & "-GFP_ofs" );			-- Adresse de frame generique
	  PUT_LINE( tab & "LId , -" & TYPE_STR & "__u_ofs" );						-- Charge le SIZ en bits
	  PUT_LINE( tab & "CALL" & tab & "STANDARD. ,WIDTH_L3" );						-- Calculer le nombre de chiffres plus signe
	end;

      else
        case TYPE_SPEC.TY is
        when DN_INTEGER =>
	declare
			----------------------
	  function	SIGNED_WIDTH_FROM_SIZE	( BITS : INTEGER ) return INTEGER
	  is		----------------------
	  begin
	    case BITS is
	    when 8  => return 4;   -- -128 .. 127
	    when 16 => return 6;   -- -32768 .. 32767
	    when 32 => return 11;  -- -2147483648 .. 2147483647
	    when 64 => return 20;  -- -9223372036854775808 .. 9223372036854775807
	    when others =>
	      if    BITS <= 8   then return 4;
	      elsif BITS <= 16  then return 6;
	      elsif BITS <= 32  then return 11;
	      elsif BITS <= 64  then return 21;
	      else                   return 40;								-- 128 bits
	      end if;
              end case;

            end	SIGNED_WIDTH_FROM_SIZE;
		----------------------

          begin
	  BITS := DI( CD_IMPL_SIZE, TYPE_SPEC );
	  PUT_LINE( tab & "LI" & tab & INTEGER'IMAGE( SIGNED_WIDTH_FROM_SIZE( BITS ) ) );
	end;
        when others =>
	  PUT_LINE( "; ATTRIBUTE WIDTH : TYPE NON TRAITE "
	          & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
	  PUT_LINE( tab & "LI" & tab & "0" );
        end case;
      end if;

    end	CODE_WIDTH;
	----------


  begin
    case	CHN_ATTR(	1 )  is

    when	'A' =>
      if	CHN_ATTR(	2 ) = 'D'	 then CODE_ADDRESS;					-- ADDRESS
      else PUT_LINE( tab & "LI" & tab & '3' );					-- AFT a revoir
      end	if;

    when	'B' => null;							-- BASE

    when	'C' =>
      if	CHN_ATTR(	2 ) = 'A'	 then null;					-- CALLABLE
      elsif  CHN_ATTR( 2 .. 3	) = "ON"	then CODE_CONSTRAINED;			-- CONSTRAINED
      elsif  CHN_ATTR( 2 .. 3	) = "OU"	then null;				-- COUNT
      end	if;

    when	'D' =>
      if	CHN_ATTR(	2 ) = 'E'	 then null;					-- DELTA
      else								-- DIGITS
        declare
	PREFIX_DEFN	: TREE	:= D( SM_DEFN, PREFIX_NAME );
	TYPE_SPEC	: TREE	:= TREE_VOID;
	ACCURACY	: TREE;
        begin
	-- Chercher le TYPE_SPEC du prefix, quel que soit	le type de noeud
	if  PREFIX_DEFN.TY = DN_TYPE_ID
	or  PREFIX_DEFN.TY = DN_SUBTYPE_ID
	then
	  TYPE_SPEC := D( SM_TYPE_SPEC, PREFIX_DEFN );
	end if;

	-- Traverser private/constrained vers le type reel
	if  TYPE_SPEC /= TREE_VOID  then
	  if  TYPE_SPEC.TY = DN_L_PRIVATE  or  TYPE_SPEC.TY = DN_PRIVATE  then
	    TYPE_SPEC := D(	SM_TYPE_SPEC, TYPE_SPEC );
	  end if;
	end if;

	-- Extraire SM_ACCURACY du DN_FLOAT
	if  TYPE_SPEC /= TREE_VOID  and then  TYPE_SPEC.TY = DN_FLOAT  then
	  ACCURACY := D( SM_ACCURACY,	TYPE_SPEC	);
	  if  ACCURACY /= TREE_VOID  then
	    if  ACCURACY.PT	= HI  then
	      PUT_LINE( tab	& "LI" & tab & IMAGE( NATURAL( ACCURACY.ABSS ) ) );
	    else
	      PUT_LINE( tab	& "LI" & tab & PRINT_NUM( ACCURACY ) );
	    end if;
	  else
	    PUT_LINE( tab &	"LI" & tab & "6" );		-- defaut	Ada 83 pour FLOAT
	  end if;
	else
	  PUT_LINE( tab & "LI" & tab & "6" );		-- defaut	Ada 83 pour FLOAT
	end if;
        end;
      end	if;

    when	'E' =>
      if	CHN_ATTR(	2 ) = 'M'	 then null;					-- EMAX
      else null;								-- EPSILON
      end	if;

    when	'F' =>
      if	CHN_ATTR(	2 ) = 'I'	 then						-- FIRST
        CODE_FIRST_LAST( IS_LAST => FALSE );
      else PUT_LINE( tab & "LI" & tab & '1' );					-- FORE a revoir
      end	if;

    when	'I' => CODE_IMAGE;							-- IMAGE

    when	'L' =>
      if	CHN_ATTR(	2 .. 3 ) = "AR"  then null;					-- LARGE
      elsif  CHN_ATTR( 2 .. 3	) = "AS"	then
        if  CHN_ATTR'LENGTH =	4  then						-- LAST
	CODE_FIRST_LAST( IS_LAST => TRUE );
        else null;								-- LAST_BIT
        end if;
      elsif  CHN_ATTR( 2 .. 3	) = "EN"	then CODE_LENGTH;				-- LENGTH

      end	if;

    when	'M' =>
      if	CHN_ATTR(	3 ) = 'N'	 then null;					-- MANTISSA
      elsif  CHN_ATTR( 11 ) =	'A'  then	 null;					-- MACHINE_EMAX
      elsif  CHN_ATTR( 11 ) =	'I'  then	 null;					-- MACHINE_EMIN
      elsif  CHN_ATTR( 9 ) = 'M'   then	 null;					-- MACHINE_MANTISSA
      elsif  CHN_ATTR( 9 ) = 'O'   then	 null;					-- MACHINE_OVERFLOW
      elsif  CHN_ATTR( 10 ) =	'A'  then	 null;					-- MACHINE_RADIX
      elsif  CHN_ATTR( 10 ) =	'O'  then	 null;					-- MACHINE_ROUNDS
      end	if;

    when	'P' =>
      if	CHN_ATTR'LENGTH = 8	 then null;					-- POSITION
      elsif  CHN_ATTR( 2 ) = 'O'  then						-- POS
        -- T'POS(X)	: retourne le numero d'ordre (identite sans clause de rep)
        CODE_EXP( D( AS_EXP, ATTRIBUTE ) );
      elsif  CHN_ATTR( 2 ) = 'R'  then						-- PRED
        -- T'PRED(X) : retourne X-1
        CODE_EXP( D( AS_EXP, ATTRIBUTE ) );
        PUT_LINE( tab & "DEC"	);
      end	if;

    when	'R' => null;							-- RANGE

    when	'S' =>
      if	CHN_ATTR(	2 ) = 'I'		then CODE_SIZE;				-- SIZE
      elsif  CHN_ATTR( 2 ) = 'M'	then CODE_SMALL;				-- SMALL
      elsif  CHN_ATTR( 2 ) = 'T'  then	 null;					-- STORAGE
      elsif  CHN_ATTR( 2 ) = 'U'  then						-- SUCC
        -- T'SUCC(X) : retourne X+1
        CODE_EXP( D( AS_EXP, ATTRIBUTE ) );
        PUT_LINE( tab & "INC"	);
      elsif  CHN_ATTR( 6 ) = 'E'  then	 null;					-- SAFE_EMAX
      elsif  CHN_ATTR( 6 ) = 'L'  then	 null;					-- SAFE_LARGE
      elsif  CHN_ATTR( 6 ) = 'S'  then	 null;					-- SAFE_SMALL
      end	if;

    when	'T' =>	null;							-- TERMINATED

    when	'V' =>
      if	CHN_ATTR'LENGTH = 5	 then null;					-- VALUE
      else								-- VAL
        -- T'VAL(N)	: retourne la valeur de position N (identite sans	clause de	rep)
        CODE_EXP( D( AS_EXP, ATTRIBUTE ) );
      end	if;

    when	'W' => CODE_WIDTH;							-- WIDTH

    when others => null;
    end case;

  end	CODE_ATTRIBUTE;
	--------------


			-----------------------
  procedure		CODE_STATIC_FIXED_VALUE	( VALUE, FIXED_TYPE :TREE )
  is			-----------------------

    SMALL		: TREE		:= D( CD_IMPL_SMALL, FIXED_TYPE );
    NUMER_SMALL	: LONG_INTEGER	:= LONG_INTEGER'VALUE( PRINT_NUM( D( XD_NUMER, SMALL ) ) );

  begin
    if NUMER_SMALL /= 1 then
      PUT_LINE( "; CODE_STATIC_FIXED_VALUE: SMALL.NUMER /= 1 A FAIRE" );
      return;
    end if;

    PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_NUMER, VALUE ) ) );
    PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_DENOM, SMALL ) ) );
    PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_DENOM, VALUE ) ) );
    PUT_LINE( tab & "CVTIX" );

  end	CODE_STATIC_FIXED_VALUE;
	-----------------------


				------------------
  procedure			CODE_FUNCTION_CALL		( FUNCTION_CALL :TREE )
  is				------------------
    NAME		: TREE		:= D( AS_NAME,		FUNCTION_CALL );
    PARAMS	: TREE		:= D( SM_NORMALIZED_PARAM_S,	FUNCTION_CALL );

		------------------------
    procedure	CODE_DN_BLTN_OPERATOR_ID
    is
      DEFN		: TREE		:= D( SM_DEFN,		NAME );
    begin
    if DEFN.TY = DN_BLTN_OPERATOR_ID
    or DEFN.TY = DN_OPERATOR_ID
    then
      declare
        OP_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
        PRM_S		: SEQ_TYPE	:= LIST( PARAMS );
        PRM_1, PRM_2	: TREE;
        RES_TYPE		: TREE		:= D( SM_EXP_TYPE, FUNCTION_CALL );
        IS_FLOAT		: BOOLEAN		:= RES_TYPE.TY = DN_FLOAT;

      begin
        if OP_STR = """-"""
	  and then RES_TYPE /= TREE_VOID
	  and then RES_TYPE.TY = DN_FIXED
	  and then D( SM_VALUE, FUNCTION_CALL ).TY = DN_REAL_VAL
        then
	CODE_STATIC_FIXED_VALUE( D( SM_VALUE, FUNCTION_CALL ), RES_TYPE );
	return;
        end if;

        POP( PRM_S, PRM_1 );
        if  IS_EMPTY( PRM_S )  then
	CODE_EXP( PRM_1 );
	goto UNARY;
        end if;
        POP( PRM_S, PRM_2 );

        if  OP_STR = """&"""  then
          declare
            COMP_TYPE	: TREE		:= D( SM_COMP_TYPE, D( SM_BASE_TYPE, RES_TYPE ) );
            COMP_BITS	: INTEGER		:= DI( CD_IMPL_SIZE, COMP_TYPE );
            COMP_BYTES	: INTEGER		:= COMP_BITS / CODI.STORAGE_UNIT;
            LVL		:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
            ANON_G		:constant STRING	:= ANONYMOUS_NAME_AT( PRM_1 );
            ANON_D		:constant STRING	:= ANONYMOUS_NAME_AT( PRM_2 );
            ANON_R		:constant STRING	:= ANONYMOUS_NAME_AT( FUNCTION_CALL );
            TYPE_STR	:constant STRING
					:= PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, RES_TYPE ) ) );

			------------------
	  procedure	CODE_ARRAY_OPERAND ( E : TREE; ANON : STRING )
	  is		------------------
	    LVL	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
	  begin
	    if  E.TY = DN_STRING_LITERAL  then
	      CODE_STRING_LITERAL( E, ANON );
	      PUT_LINE( tab & "LCA" & tab & ANON & ".data_ptr" );

	    elsif E.TY = DN_SLICE then
	    -- CODE_EXP(slice) laisse : @data_slice, len_slice.
	      PUT_LINE( "VAR" & tab & ANON & "_slice_data, q" );
	      PUT_LINE( "VAR" & tab & ANON & "_slice_len,  q" );

	      PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
	      PUT_LINE( "VAR" & tab & ANON & "__u,   q" );

	      PUT_LINE( "namespace " & ANON & "_info" );
	      PUT_LINE( "  VAR SIZ,      d" );
	      PUT_LINE( "  VAR COMP_SIZ, d" );
	      PUT_LINE( "  VAR FST_1,    d" );
	      PUT_LINE( "  VAR LST_1,    d" );
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

    -- Info normalisée : bounds 1 .. len.
	      PUT_LINE( tab & "LI" & tab & "1" );
	      PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info.FST_1" );

	      PUT_LINE( tab & "La  " & LVL & ", " & ANON & "_slice_len" );
	      PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info.LST_1" );

	      PUT_LINE( tab & "LI" & tab & "8" );
	      PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info.COMP_SIZ" );

	      PUT_LINE( tab & "La  " & LVL & ", " & ANON & "_slice_len" );
	      PUT_LINE( tab & "LI" & tab & "8" );
	      PUT_LINE( tab & "MUL" );
	      PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info.SIZ" );

    -- Résultat attendu par la concat : @doublet.
	      PUT_LINE( tab & "LVA " & LVL & ", " & ANON & "_disp" );

	    else
	      CODE_EXP( E );
	    end if;

	  end	CODE_ARRAY_OPERAND;
		------------------

          begin
            if  CODI.DEBUG  then PUT_LINE( "; CODE & concat " & TYPE_STR ); end if;
            -- ---- Variables de travail dans la VARzone ----
            PUT_LINE( "VAR" & tab & ANON_G & "_data, q" );   -- data_ptr gauche
            PUT_LINE( "VAR" & tab & ANON_G & "_info, q" );   -- info_ptr gauche
            PUT_LINE( "VAR" & tab & ANON_D & "_data, q" );   -- data_ptr droit
            PUT_LINE( "VAR" & tab & ANON_D & "_info, q" );   -- info_ptr droit
            PUT_LINE( "VAR" & tab & ANON_G & "_len,  q" );   -- longueur g en octets
            PUT_LINE( "VAR" & tab & ANON_D & "_len,  q" );   -- longueur d en octets
            -- Descripteur resultat
            PUT_LINE( "VAR" & tab & ANON_R & "_disp, q" );
            PUT_LINE( "VAR" & tab & ANON_R & "__u,   q" );
            -- Bloc info inline pour le resultat
            PUT_LINE( "namespace " & ANON_R & "_info" );
            PUT_LINE( "  VAR SIZ,      d" );
            PUT_LINE( "  VAR COMP_SIZ, d" );
            PUT_LINE( "  VAR FST_1,    d" );
            PUT_LINE( "  VAR LST_1,    d" );
            PUT_LINE( "end namespace" );

            -- ---- Operande gauche ----
            CODE_ARRAY_OPERAND( PRM_1, ANON_G );
            -- @doublet_g sur pile
            PUT_LINE( tab & "DUP" );
            PUT_LINE( tab & "La  ,  0" );
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_G & "_data" );
            PUT_LINE( tab & "La  ,  8" );
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_G & "_info" );

            -- LEN_G = (LST_1 - FST_1 + 1) * COMP_BYTES
            PUT_LINE( tab & "LId " & LVL & ", " & ANON_G & "_info, " & TYPE_STR & ".LST_1" );
            PUT_LINE( tab & "INC" );
            PUT_LINE( tab & "LId " & LVL & ", " & ANON_G & "_info, " & TYPE_STR & ".FST_1" );
            PUT_LINE( tab & "SUB" );
            if COMP_BYTES /= 1 then
              PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BYTES ) );
              PUT_LINE( tab & "MUL" );
            end if;
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_G & "_len" );

            -- ---- Operande droit ----
            CODE_ARRAY_OPERAND( PRM_2, ANON_D );
            PUT_LINE( tab & "DUP" );
            PUT_LINE( tab & "La  ,  0" );
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_D & "_data" );
            PUT_LINE( tab & "La  ,  8" );
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_D & "_info" );

            PUT_LINE( tab & "LId " & LVL & ", " & ANON_D & "_info, " & TYPE_STR & ".LST_1" );
            PUT_LINE( tab & "INC" );
            PUT_LINE( tab & "LId " & LVL & ", " & ANON_D & "_info, " & TYPE_STR & ".FST_1" );
            PUT_LINE( tab & "SUB" );
            if COMP_BYTES /= 1 then
              PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BYTES ) );
              PUT_LINE( tab & "MUL" );
            end if;
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_D & "_len" );

            -- ---- Allouer LEN_G + LEN_D octets sur la co-pile ----
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len" );
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_len" );
            PUT_LINE( tab & "ADD" );
            PUT_LINE( tab & "CO_VAR" );               -- depile taille, empile @data_res
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_R & "_disp" );

            -- ---- Remplir le bloc info du resultat ----
            -- FST_1 = 1
            PUT_LINE( tab & "LI"  & tab & "1" );
            PUT_LINE( tab & "Sd  " & LVL & ", " & ANON_R & "_info.FST_1" );
            -- LST_1 = (LEN_G + LEN_D) / COMP_BYTES
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len" );
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_len" );
            PUT_LINE( tab & "ADD" );
            if COMP_BYTES /= 1 then
              PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BYTES ) );
              PUT_LINE( tab & "DIV" );
            end if;
            PUT_LINE( tab & "Sd  " & LVL & ", " & ANON_R & "_info.LST_1" );
            -- COMP_SIZ en bits
            PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BITS ) );
            PUT_LINE( tab & "Sd  " & LVL & ", " & ANON_R & "_info.COMP_SIZ" );

-- SIZ est en bits.  Les longueurs ANON_*_len sont en octets,
-- car elles sont aussi les compteurs de BLKMOV.
	  PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len" );
	  PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_len" );
	  PUT_LINE( tab & "ADD" );
	  if CODI.STORAGE_UNIT /= 1 then
	    PUT_LINE( tab & "LI"  & tab & IMAGE( CODI.STORAGE_UNIT ) );
	    PUT_LINE( tab & "MUL" );
	  end if;
	  PUT_LINE( tab & "Sd  " & LVL & ", " & ANON_R & "_info.SIZ" );

            -- ---- Initialiser info_ptr du descripteur resultat ----
            PUT_LINE( tab & "LVA " & LVL & ", " & ANON_R & "_info.SIZ" );
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_R & "__u" );

            -- ---- BLKMOV operande gauche -> @data_res ----
            -- Convention BLKMOV : pile = ... @DST, LEN, @SRC  puis POP RSI, POP RCX, POP RDI
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_R & "_disp" );  -- @DST
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len"  );  -- LEN
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_data" );  -- @SRC
            PUT_LINE( tab & "BLKMOV" );

            -- ---- BLKMOV operande droit -> @data_res + LEN_G ----
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_R & "_disp" );
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len"  );
            PUT_LINE( tab & "ADD" );                                    -- @DST + LEN_G
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_len"  );  -- LEN
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_data" );  -- @SRC
            PUT_LINE( tab & "BLKMOV" );

            -- ---- Laisser @doublet_r sur la pile ----
            PUT_LINE( tab & "LVA " & LVL & ", " & ANON_R & "_disp" );
          end;
	return;
        end if;

        CODE_EXP( PRM_1 );
        CODE_EXP( PRM_2 );

        -- Pour les	comparaisons le type resultat	est BOOLEAN,
        -- il faut tester le type du premier operande
        if  not IS_FLOAT  then
	if  PRM_1.TY = DN_NUMERIC_LITERAL  and then
		D( SM_VALUE, PRM_1 ).PT /= HI  and then  D( SM_VALUE, PRM_1 ).TY = DN_REAL_VAL  then
	  IS_FLOAT := TRUE;
	else
	  declare
	    PRM_TYPE	: TREE	:= D( SM_EXP_TYPE, PRM_1 );
	  begin
	    IS_FLOAT := PRM_TYPE.TY = DN_FLOAT;
	  end;
	end if;
        end if;

        if    OP_STR = """+"""   then
	if IS_FLOAT then PUT_LINE( tab & "FADD"	); else PUT_LINE( tab & "ADD"	); end if;
        elsif OP_STR = """-"""   then
	if IS_FLOAT then PUT_LINE( tab & "FSUB"	); else PUT_LINE( tab & "SUB"	); end if;
        elsif OP_STR = """*"""   then
	if IS_FLOAT then PUT_LINE( tab & "FMUL"	); else PUT_LINE( tab & "MUL"	); end if;
        elsif OP_STR = """/"""   then
	if IS_FLOAT then PUT_LINE( tab & "FDIV"	); else PUT_LINE( tab & "DIV"	); end if;
        elsif OP_STR = """MOD""" then  PUT_LINE( tab & "MODI" );
        elsif OP_STR = """REM""" then  PUT_LINE( tab & "REMI" );
        elsif OP_STR = """="""   then
	if IS_FLOAT then PUT_LINE( tab & "FCEQ"	); else PUT_LINE( tab & "CEQ"	); end if;
        elsif OP_STR = """>"""   then
	if IS_FLOAT then PUT_LINE( tab & "FCGT"	); else PUT_LINE( tab & "CGT"	); end if;
        elsif OP_STR = """<"""   then
	if IS_FLOAT then PUT_LINE( tab & "FCLT"	); else PUT_LINE( tab & "CLT"	); end if;
        elsif OP_STR = """/="""  then
	if IS_FLOAT then PUT_LINE( tab & "FCNE"	); else PUT_LINE( tab & "CNE"	); end if;
        elsif OP_STR = """>=""" then
	if IS_FLOAT then PUT_LINE( tab & "FCGE"	); else PUT_LINE( tab & "CGE"	); end if;
        elsif OP_STR = """<=""" then
	if IS_FLOAT then PUT_LINE( tab & "FCLE"	); else PUT_LINE( tab & "CLE"	); end if;

        elsif OP_STR = """**""" then
	if  IS_FLOAT  then
	  PUT_LINE( tab & "FEXP" );

	elsif  PRM_1.TY = DN_NUMERIC_LITERAL  and then  DI( SM_VALUE, PRM_1 ) = 2  then
	  PUT_LINE( tab & "DEC" );
	  PUT_LINE( tab & "SHL" );

	else
	  PUT_LINE( "; CODE_DN_BLTN_OPERATOR_ID : EXP ENTIERE GENERALE A FAIRE" );
	end if;


        end if;
        return;
<<UNARY>>
        if OP_STR =	"""-""" then
	if IS_FLOAT then PUT_LINE( tab & "FNEG"	); else PUT_LINE( tab & "NEG"	); end if;
        end if;
        if OP_STR =	"""ABS"""	then
	if IS_FLOAT then PUT_LINE( tab & "FABS"	); else PUT_LINE( tab & "ABS"	); end if;
        end if;
        if OP_STR =	"""NOT"""	then
	PUT_LINE(	tab & "LI" & tab & "1" );
	PUT_LINE(	tab & "OUX" );
        end if;
      end;

    else
      PUT_LINE( "; CODE_DN_BLTN_OPERATOR_ID : DEFN.TY="
	      & NODE_NAME'IMAGE( DEFN.TY )
	      & " NON TRAITE POUR "
	      & PRINT_NAME(	D( LX_SYMREP, DEFN ) ) );
    end if;
    end	CODE_DN_BLTN_OPERATOR_ID;
	------------------------

		--------------------
    procedure	PREPARE_ARRAY_RETURN
    is		--------------------
      ANON	:constant STRING	:= ANONYMOUS_NAME_AT( FUNCTION_CALL );
      LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
    begin
      PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
      PUT_LINE( "VAR" & tab & ANON & "__u,   q" );
      PUT_LINE( "namespace " & ANON & "_info" );
      PUT_LINE( "  VAR SIZ,      d" );
      PUT_LINE( "  VAR COMP_SIZ, d" );
      PUT_LINE( "  VAR FST_1,    d" );
      PUT_LINE( "  VAR LST_1,    d" );
      PUT_LINE( "end namespace" );

      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_info.SIZ" );
      PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON & "__u" );
    -- Empiler l'adresse du doublet comme result__ofs (dernier PRM)
      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );

    end	PREPARE_ARRAY_RETURN;
	--------------------

  begin
    if  NAME.TY = DN_ATTRIBUTE  then									-- Appel de fonction sous forme d'attribut

      if  D( SM_EXP_TYPE, FUNCTION_CALL ).TY = DN_ARRAY  then						-- Le cas de 'IMAGE
        PREPARE_ARRAY_RETURN;
      end if;

      declare
        PRM_S	: SEQ_TYPE	:= LIST( PARAMS );
        PRM	: TREE;
      begin
        POP( PRM_S,	PRM );
        CODE_EXP( PRM );										-- Un seul paramètre pour les attributs fonctions
      end;
      CODE_ATTRIBUTE( NAME );										-- Gerer l'appel de fonction au besoin
      return;											-- On a fini pour ce cas

    elsif	 NAME.TY = DN_USED_NAME_ID  then
      declare
        FUNC_DEF	: TREE	:= D( SM_DEFN, NAME );
        FUNC_SPEC	: TREE	:= D( SM_SPEC, FUNC_DEF );
        RET_NAME	: TREE	:= D( AS_NAME, FUNC_SPEC );    -- nom du type de retour (DN_FUNCTION_SPEC)
        RET_TS	: TREE	:= TREE_VOID;
      begin
        -- Resoudre le type de retour jusqu'au TYPE_SPEC effectif
        if  RET_NAME /= TREE_VOID  then
          RET_TS := D( SM_TYPE_SPEC, D( SM_DEFN, RET_NAME ) );
          while  RET_TS.TY = DN_L_PRIVATE  or  RET_TS.TY = DN_PRIVATE  loop
            RET_TS := D( SM_TYPE_SPEC, RET_TS );
          end loop;
        end if;

        if  RET_TS /= TREE_VOID  and then  RET_TS.TY = DN_RECORD  then
          -- Allouer un doublet anonyme avec son espace donnees, empiler son adresse comme result__ofs
          declare
            ANON_STR  : constant STRING := ANONYMOUS_NAME_AT( FUNCTION_CALL );
            TYPE_NAME : TREE            := D( XD_SOURCE_NAME, RET_TS );
            TN_STR    : constant STRING := PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
            LVL_STR   : constant STRING := IMAGE( CODI.CUR_LEVEL );
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

        else
          -- Cas scalaire, array, etc. : placeholder qword nul
          PUT( tab & "LI" & tab & "0" );
          if  CODI.DEBUG  then PUT( tab50 & "; lieu resultat sur pile" ); end if;
          NEW_LINE;
        end if;
      end;
      INSTRUCTIONS.CODE_PROCEDURE_CALL( FUNCTION_CALL, NAME );

    elsif	 NAME.TY = DN_USED_OP  then
      CODE_DN_BLTN_OPERATOR_ID;

    elsif	 NAME.TY = DN_SELECTED  then
      CODE_SELECTED( NAME, CONTEXT=> FUNCTION_CALL );

    else
      PUT_LINE( "; CODE_FUNCTION_CALL NAME.TY PAS GERE : " & NODE_NAME'IMAGE( NAME.TY ) );
    end if;

  end	CODE_FUNCTION_CALL;
	------------------


				------------------------
  procedure			CODE_QUALIFIED_ALLOCATOR	( QUALIFIED_ALLOCATOR :TREE )
  is				------------------------
  begin
    null;
  end	CODE_QUALIFIED_ALLOCATOR;
	------------------------


				----------------------
  procedure			CODE_SUBTYPE_ALLOCATOR	( SUBTYPE_ALLOCATOR	:TREE )
  is				----------------------
  begin
    null;
  end	CODE_SUBTYPE_ALLOCATOR;
	----------------------


				--------------
  procedure			CODE_AGGREGATE		( AGGREGATE, TYPE_SPEC :TREE )
  is				--------------

    TYPE_NAME		: TREE			:= D( XD_SOURCE_NAME, TYPE_SPEC );
    TYPE_NAME_STR		:constant	STRING		:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
    LVL_STR		:constant	STRING		:= IMAGE(	CODI.CUR_LEVEL );
    NORM_SEQ		: SEQ_TYPE		:= LIST( D( SM_NORMALIZED_COMP_S, AGGREGATE ) );

    INDEX_S		: SEQ_TYPE;

  begin
    if  TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY  or  TYPE_SPEC.TY = DN_ARRAY  then					-- L'adresse de debut data est deja empilee

      if  TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY  then
        INDEX_S := LIST( D( SM_INDEX_SUBTYPE_S, TYPE_SPEC ) );
      else
        INDEX_S := LIST( D( SM_INDEX_S, TYPE_SPEC ) );
      end if;
				----------------------
				ASSIGN_ARRAY_AGGREGATE:
      declare
        NB_DIMS	: NATURAL		:= 0;

        -- Tableaux de dimensions et de strides (max 8 dimensions suffit en Ada 83 pratique)
        type DIM_INFO	is record
			  FST	: INTEGER;
			  LST	: INTEGER;
			  STRIDE	: INTEGER;							-- en octets, pas pour avancer d'un élément
			end record;
        DIM_TBL	: array( 1 .. 8 ) of DIM_INFO;

        COMP_SIZ_BITS	: INTEGER		:= DI( CD_IMPL_SIZE, D( SM_COMP_TYPE, D( SM_BASE_TYPE, TYPE_SPEC ) ) );
        COMP_SIZ_BYTES	: INTEGER		:= COMP_SIZ_BITS / 8;

		-----------------
        procedure	EMIT_AGG_AT_DEPTH	( AGG :TREE; DEPTH :NATURAL )
        is	-----------------
          -- Invariant : à l'entrée, l'adresse du bloc à remplir est sur la pile.
          --             à la sortie, cette adresse a été DROP-ée.
	SEQ	: SEQ_TYPE	:= LIST( D( SM_NORMALIZED_COMP_S, AGG ) );
	ASSOC	: TREE;
	FST	: INTEGER		:= DIM_TBL( DEPTH ).FST;
	LST	: INTEGER		:= DIM_TBL( DEPTH ).LST;
	STRIDE	: INTEGER		:= DIM_TBL( DEPTH ).STRIDE;
	STRIDE_S	: constant STRING	:= IMAGE( STRIDE );
	EMIS	: INTEGER		:= 0;

		-------------
	procedure	EMIT_ONE_COMP	( COMP :TREE )
	is	-------------
 	begin
	  PUT_LINE( tab & "DUP" );

	  if  COMP.TY = DN_AGGREGATE  then
	    if  DEPTH < NB_DIMS  then
 	      EMIT_AGG_AT_DEPTH( COMP, DEPTH + 1 );
	    else
	      CODE_AGGREGATE( COMP, TYPE_SPEC );
	    end if;

	  elsif  COMP.TY in CLASS_EXP  then
	    EXPRESSIONS.CODE_EXP( COMP );
	    PUT_LINE( tab & "S" & EXP_TYPE_CHAR( COMP ) );

	  else
	    PUT_LINE( "; EMIT_ONE_COMP : composante non geree " & NODE_NAME'IMAGE( COMP.TY ) );
	  end if;

	  PUT_LINE( tab & "LI" & tab & STRIDE_S );
	  PUT_LINE( tab & "ADD" );

	end	EMIT_ONE_COMP;
		-------------

        begin				-- EMIT_AGG_AT_DEPTH

	while not  IS_EMPTY( SEQ )  loop
	  POP( SEQ, ASSOC );

	  if  ASSOC.TY = DN_NAMED  then
	    declare
	      COMP_EXP	: TREE		:= D( AS_EXP, ASSOC );
	      CHOICES	: SEQ_TYPE	:= LIST( D( AS_CHOICE_S, ASSOC ) );
	      CH		: TREE;
	      REPEAT	: INTEGER		:= 1;
	    begin
	      while not  IS_EMPTY( CHOICES )  loop
	        POP( CHOICES, CH );
	        if  CH.TY = DN_CHOICE_RANGE  then
		declare
		  RNG	: TREE		:= D( AS_DISCRETE_RANGE, CH );
		  LO	: INTEGER		:= DI( SM_VALUE, D( AS_EXP1, RNG ) );
		  HI	: INTEGER		:= DI( SM_VALUE, D( AS_EXP2, RNG ) );
		begin
		  REPEAT := HI - LO + 1;
		end;
	        elsif  CH.TY = DN_CHOICE_OTHERS  then
		REPEAT := LST - FST + 1 - EMIS;
	        end if;
	      end loop;

	      if  REPEAT < 4  then
	        for  I  in  1 .. REPEAT  loop
		EMIT_ONE_COMP( COMP_EXP );
	        end loop;

	      else
	        declare
		LBL_STR	:constant STRING	:= ANONYMOUS_NAME_AT( CH );
		CNT_STR	:constant STRING	:= "CNT_" & LBL_STR;
		LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
	        begin
		PUT_LINE( "VAR" & tab & CNT_STR & ", " & 'd' );
		PUT_LINE( tab & "LI" & tab & IMAGE( REPEAT ) );
		PUT_LINE( tab & "Sd " & LVL_STR & ',' & tab & CNT_STR );
		PUT_LINE( LBL_STR & ':' );

		EMIT_ONE_COMP( COMP_EXP );

		PUT_LINE( tab & "LI" & tab & '0' );
		PUT_LINE( tab & "Ld " & LVL_STR & ',' & tab & CNT_STR );
		PUT_LINE( tab & "DEC" );
		PUT_LINE( tab & "CEQ" );
		PUT_LINE( tab & "BF" & tab & LBL_STR );

	        end;
	      end if;
	      EMIS := EMIS + REPEAT;
	    end;

	  else
			-- DN_AGGREGATE positionnel ou CLASS_EXP positionnel
	    EMIT_ONE_COMP( ASSOC );
	    EMIS := EMIS + 1;
	  end if;

	end loop;

	PUT_LINE( tab & "DROP" );    -- jeter l'adresse finale (au-delà du dernier élément)

        end	EMIT_AGG_AT_DEPTH;
		-----------------

      begin    											-- ASSIGN_ARRAY_AGGREGATE
        -- ============================================================
        -- CAS DYNAMIQUE : DN_ARRAY unconstrained avec bornes en range
        -- Les bornes (FST, LST) ne sont pas statiques dans SM_INDEX_S
        -- mais dans le DN_CHOICE_RANGE du premier DN_NAMED de l'agr.
        -- Algorithme : boucle LLIR sur (LST-FST+1) iterations.
        -- Precondition : @data_dest est en sommet de pile.
        -- ============================================================
        if  TYPE_SPEC.TY = DN_ARRAY  then
                        -------------------------
                        DYNAMIC_ARRAY_AGGREGATE:
          declare
            NORM_DYN	: SEQ_TYPE	:= LIST( D( SM_NORMALIZED_COMP_S, AGGREGATE ) );
            ASSOC		: TREE;
            LVL_STR		:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
            LBL_LOOP	:constant STRING	:= NEW_LABEL;
            LBL_END		:constant STRING	:= NEW_LABEL;
            CNT_VAR		:constant STRING	:= ANONYMOUS_NAME_AT( AGGREGATE ) & "_cnt";
            PTR_VAR		:constant STRING	:= ANONYMOUS_NAME_AT( AGGREGATE ) & "_ptr";
	  COMP_TYPE	: TREE		:= D( SM_COMP_TYPE, D( SM_BASE_TYPE, TYPE_SPEC ) );
            COMP_SCHAR	: CHARACTER         := OPER_SIZ_CHAR( COMP_TYPE );
          begin
            -- Sauvegarder @data_dest (sommet de pile) dans PTR_VAR
            PUT_LINE( "VAR" & tab & PTR_VAR & ", q" );
            PUT_LINE( "VAR" & tab & CNT_VAR & ", q" );
            PUT_LINE( tab & "Sa  " & LVL_STR & ", " & PTR_VAR );

            -- Extraire le premier DN_NAMED (et unique dans le cas 1..N => expr)
            POP( NORM_DYN, ASSOC );
            declare
              COMP_EXP : TREE     := D( AS_EXP,      ASSOC );
              CHOICES  : SEQ_TYPE := LIST( D( AS_CHOICE_S, ASSOC ) );
              CH       : TREE;
            begin
              POP( CHOICES, CH );

              if  CH.TY = DN_CHOICE_RANGE  then
                declare
                  RNG : TREE := D( AS_DISCRETE_RANGE, CH );
                begin
                  -- COUNT = EXP2 - EXP1 + 1
                  CODE_EXP( D( AS_EXP2, RNG ) );   -- COMPL (dynamique)
                  CODE_EXP( D( AS_EXP1, RNG ) );   -- 1     (statique)
                  PUT_LINE( tab & "SUB" );
                  PUT_LINE( tab & "INC" );
                end;

              elsif  CH.TY = DN_CHOICE_OTHERS  then
                -- others sans range explicite : ne devrait pas arriver ici
                PUT_LINE( "; DYNAMIC_ARRAY_AGGREGATE others sans range : A FAIRE" );
                PUT_LINE( tab & "LI  0" );

              end if;
              PUT_LINE( tab & "Sa  " & LVL_STR & ", " & CNT_VAR );

              -- Tester COUNT <= 0 : si oui, ne rien émettre
              PUT_LINE( tab & "La  " & LVL_STR & ", " & CNT_VAR );
              PUT_LINE( tab & "LI" & tab & "0" );
              PUT_LINE( tab & "CLE" );
              PUT_LINE( tab & "BT  " & LBL_END );

              -- ---- Boucle : écrire COMP_EXP COUNT fois ----
              PUT_LINE( LBL_LOOP & ':' );

              -- Charger @dest courant depuis PTR_VAR
              PUT_LINE( tab & "La  " & LVL_STR & ", " & PTR_VAR );
              -- Évaluer la valeur à écrire
              CODE_EXP( COMP_EXP );
              -- Stocker : Sb -1, 0 => POP_RAX=@dest, POP_RBX=valeur, [rax]=bl
              PUT_LINE( tab & "S" & COMP_SCHAR & "  -1, 0" );

              -- Avancer PTR_VAR de COMP_SIZ_BYTES
              PUT_LINE( tab & "La  " & LVL_STR & ", " & PTR_VAR );
              PUT_LINE( tab & "LI" & tab & IMAGE( COMP_SIZ_BYTES ) );
              PUT_LINE( tab & "ADD" );
              PUT_LINE( tab & "Sa  " & LVL_STR & ", " & PTR_VAR );

              -- Décrémenter CNT_VAR, reboucler si > 0
              PUT_LINE( tab & "La  " & LVL_STR & ", " & CNT_VAR );
              PUT_LINE( tab & "DEC" );
              PUT_LINE( tab & "DUP" );
              PUT_LINE( tab & "Sa  " & LVL_STR & ", " & CNT_VAR );
              PUT_LINE( tab & "LI" & tab & "0" );
              PUT_LINE( tab & "CGT" );
              PUT_LINE( tab & "BT  " & LBL_LOOP );

              PUT_LINE( LBL_END & ':' );
            end;
          end      DYNAMIC_ARRAY_AGGREGATE;
                  -------------------------
          return;   -- traitement complet, pas de EXTRACT_DIMENSIONS
        end if;

				------------------
				EXTRACT_DIMENSIONS:
        declare
	INDEX_NODE	: TREE;
        begin
	while not  IS_EMPTY( INDEX_S )  loop
	  POP( INDEX_S, INDEX_NODE );
	  NB_DIMS := NB_DIMS + 1;
	  declare
	    RNG		: TREE	:= D( SM_RANGE, INDEX_NODE );
	  begin
	    DIM_TBL( NB_DIMS ).FST := DI( SM_VALUE, D( AS_EXP1, RNG ) );
	    DIM_TBL( NB_DIMS ).LST := DI( SM_VALUE, D( AS_EXP2, RNG ) );
	  end;
	end loop;

        end	EXTRACT_DIMENSIONS;
		------------------

        DIM_TBL( NB_DIMS ).STRIDE := COMP_SIZ_BYTES;
        for  K  in reverse  1 .. NB_DIMS - 1  loop
	DIM_TBL( K ).STRIDE := DIM_TBL( K + 1 ).STRIDE * ( DIM_TBL( K + 1 ).LST - DIM_TBL( K + 1 ).FST + 1 );
        end loop;
        EMIT_AGG_AT_DEPTH( AGGREGATE, 1 );

      end	ASSIGN_ARRAY_AGGREGATE;
	----------------------

    elsif  TYPE_SPEC.TY = DN_RECORD  then								-- L'adresse du doublet est deja empilee
				-----------------------
				ASSIGN_RECORD_AGGREGATE:
      declare
        COMP_DECL_S		: SEQ_TYPE	:= LIST( D( AS_DECL_S, D( SM_COMP_LIST, TYPE_SPEC ) ) );
        COMP_EXP		: TREE;
        COMP_DECL		: TREE;

      begin
SCAN_DECLS:
        while not IS_EMPTY( COMP_DECL_S )  loop
	POP( COMP_DECL_S, COMP_DECL );
	declare
	  COMP_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, COMP_DECL ) );
	  COMP_ID		: TREE;

	begin
SCAN_IDS:
	  while not IS_EMPTY( COMP_ID_S )  loop
	    POP( COMP_ID_S, COMP_ID	);
	    exit SCAN_DECLS  when  IS_EMPTY( NORM_SEQ );							-- securite : agregat plus court que decls
	    POP( NORM_SEQ, COMP_EXP );
	    declare
	      COMP_TYPE	: TREE		:= D( SM_OBJ_TYPE, COMP_ID );
	      COMP_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, COMP_ID ) );

	    begin
	      if  COMP_EXP.TY = DN_AGGREGATE  then
	        PUT_LINE( tab & "DUP" );
	        PUT( tab & "LVA" & tab & ", " );							-- composant composite : calculer adresse dans zone parent
	        CODI.REGIONS_PATH( TYPE_NAME );
	        PUT_LINE( TYPE_NAME_STR & "." & COMP_STR );
	        CODE_AGGREGATE( COMP_EXP, COMP_TYPE );							-- adresse du sous-composant empilée, appel récursif

	      else
	        declare
	          EFFECTIVE_COMP_TYPE : TREE := COMP_TYPE;
	        begin
	          while  EFFECTIVE_COMP_TYPE.TY = DN_L_PRIVATE
	             or  EFFECTIVE_COMP_TYPE.TY = DN_PRIVATE  loop
	            EFFECTIVE_COMP_TYPE := D( SM_TYPE_SPEC, EFFECTIVE_COMP_TYPE );
	          end loop;

	          if  EFFECTIVE_COMP_TYPE.TY = DN_RECORD  then
	            -- Composante record : BLKMOV depuis les donnees de la source vers l'offset dans le parent
	            declare
	              CN_STR : constant STRING := PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, EFFECTIVE_COMP_TYPE ) ) );
	            begin
	              -- @DST = adresse de la composante dans le record parent
	              PUT_LINE( tab & "DUP" );
	              PUT( tab & "LVA" & tab & ", " );
	              CODI.REGIONS_PATH( TYPE_NAME );
	              PUT_LINE( TYPE_NAME_STR & "." & COMP_STR );

	              PUT( tab & "LI" & tab );
	              CODI.REGIONS_PATH( D( XD_SOURCE_NAME, EFFECTIVE_COMP_TYPE ) );
	              PUT_LINE( CN_STR & ".size" );              -- LEN

	              EXPRESSIONS.CODE_EXP( COMP_EXP );         -- empiле @doublet source
	              PUT_LINE( tab & "La  ,  0" );              -- @SRC = data_ptr

	              PUT_LINE( tab & "BLKMOV" );
	            end;

	          else
	            -- Composante scalaire : store direct
	            PUT_LINE( tab & "DUP" );
	            PUT( tab & "LVA" & tab & ", " );
	            CODI.REGIONS_PATH( TYPE_NAME );
	            PUT_LINE( TYPE_NAME_STR & "." & COMP_STR );
	            EXPRESSIONS.CODE_EXP( COMP_EXP );
	            PUT_LINE( tab & "S" & CODI.OPER_SIZ_CHAR( EFFECTIVE_COMP_TYPE ) );
	          end if;
	        end;
	      end if;
	    end;
	  end loop		SCAN_IDS;
	end;
        end loop		SCAN_DECLS;
        PUT_LINE( tab & "DROP" );									-- Enlever l'adresse de debut data record de reference

      end		ASSIGN_RECORD_AGGREGATE;
		-----------------------
    end if;

  end	CODE_AGGREGATE;
	--------------


				-------------------
  procedure			CODE_STRING_LITERAL		( STRING_LITERAL :TREE; STR_NAME :STRING )
  is				-------------------

    CST_CHN	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, STRING_LITERAL ) );
    STR_CONST	:STRING		renames	CST_CHN( CST_CHN'FIRST+1 .. CST_CHN'LAST-1 );

  begin
    PUT( "STR " & STR_NAME & ", """ & STR_CONST & '"' );
    if CODI.DEBUG then PUT( tab50 & "; constante string=""" & STR_CONST & """" );	end if;
    NEW_LINE;

  end	CODE_STRING_LITERAL;
	-------------------


				--------------------
  procedure			CODE_NUMERIC_LITERAL	( NUMERIC_LITERAL :TREE )
  is				--------------------

    VAL		: TREE	:= D( SM_VALUE, NUMERIC_LITERAL );
    NUM_LIT_TYPE	: TREE	:= D( SM_EXP_TYPE, NUMERIC_LITERAL );

  begin
    if  CODI.DEBUG  then PUT_LINE( "; CODE_NUMERIC_LITERAL " & NODE_NAME'IMAGE( NUM_LIT_TYPE.TY ) );
    end if;

    if  VAL.PT = HI	 and then	 VAl.NOTY	= DN_NUM_VAL							-- Valuer entiere courte
    then
      PUT_LINE( tab	& "LI" & tab & IMAGE( DI( SM_VALUE, NUMERIC_LITERAL ) ) );

    elsif	 VAL.TY =	DN_NUM_VAL  then									-- Valeur entiere longue INTEGER
      PUT_LINE( tab	& "LI" & tab & PRINT_NUM( VAL	) );

    elsif	 VAL.TY =	DN_REAL_VAL  then									-- Valeur decimale FLOAT ou FIXED
				------------------------
				PUSH_REAL_FLOAT_OR_FIXED:						-- Cible FIXED LONG_FLOAT deja empile
      declare
        LIT_STR		:constant STRING	:= PRINT_NAME( D( LX_NUMREP, NUMERIC_LITERAL ) );
        VALUE		: TREE		:= D( SM_VALUE, NUMERIC_LITERAL );

      begin
        if  NUM_LIT_TYPE.TY = DN_FIXED  then								-- Valeur FIXED limitation temporaire NUMER = 1

	if  CODI.IN_GENERIC_BODY  and then  IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, NUM_LIT_TYPE ) )  then	-- Passer par le use__info
	  declare
	    TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, NUM_LIT_TYPE );
	    TYPE_STR	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );

	  begin											-- ATTENTION HYPOTHESE NUMER_SMALL = 1
	    PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_NUMER, VALUE ) ) );					-- Numerateur valeur NV

	    PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );			-- Adresse de frame generique
	    PUT_LINE( tab & "LIq , -" & TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.DENOM" );			-- Charge l'entier DENOM small

	    PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_DENOM, VALUE ) ) );					-- Denominateur valeur DV

	    PUT_LINE( tab & "CVTIX" );								-- (NV DS) / (DV NS)
	  end;

	else
	  declare
	    TARGET_SMALL	: TREE		:= D( CD_IMPL_SMALL, NUM_LIT_TYPE );
	    NUMER_SMALL	: LONG_INTEGER	:= LONG_INTEGER'VALUE( PRINT_NUM( D( XD_NUMER, TARGET_SMALL ) ) );
	    DENOM_SMALL	: LONG_INTEGER	:= LONG_INTEGER'VALUE( PRINT_NUM( D( XD_DENOM, TARGET_SMALL ) ) );

	  begin											-- ATTENTION HYPOTHESE NUMER_SMALL = 1
	    PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_NUMER, VALUE ) ) );					-- NV
	    PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_DENOM, TARGET_SMALL ) ) );				-- DS
	    PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_DENOM, VALUE ) ) );					-- DV
	    PUT_LINE( tab & "CVTIX" );								-- NV * DS / DV
	  end;
	end if;

        else											-- Valeur flottante
	declare
	  LIT_STR	:constant STRING	:= PRINT_NAME( D( LX_NUMREP, NUMERIC_LITERAL ) );
	begin
	  PUT_LINE( tab	& "LIF" &	tab & LIT_STR );
	end;
        end if;
      end		PUSH_REAL_FLOAT_OR_FIXED;
		------------------------
    end if;

  end	CODE_NUMERIC_LITERAL;
	--------------------


				----------------
  procedure			CODE_NULL_ACCESS		( NULL_ACCESS :TREE	)
  is				----------------
  begin
    null;
  end	CODE_NULL_ACCESS;
	----------------


				------------------
  procedure			CODE_SHORT_CIRCUIT		( SHORT_CIRCUIT :TREE )
  is				------------------

    EXP1		: TREE		:= D( AS_EXP1, SHORT_CIRCUIT );
    EXP2		: TREE		:= D( AS_EXP2, SHORT_CIRCUIT );
    OP		: TREE		:= D( AS_SHORT_CIRCUIT_OP, SHORT_CIRCUIT );
    LBL_SKIP	:constant	STRING	:= NEW_LABEL;

  begin
    CODE_EXP( EXP1 );

    if  OP.TY = DN_AND_THEN  then
      -- A and then	B : si A est FALSE,	resultat = FALSE (ne pas evaluer B)
      PUT_LINE( tab	& "DUP" );									-- dupliquer A pour	le test
      PUT_LINE( tab	& "BF" & tab & LBL_SKIP );								-- si A=FALSE, sauter (garder	FALSE sur	la pile)
      PUT_LINE( tab	& "DROP" );									-- jeter le duplicat de A (A etait TRUE)
      CODE_EXP( EXP2 );										-- evaluer B, resultat = B
      PUT_LINE( LBL_SKIP & ':' );

    elsif	 OP.TY = DN_OR_ELSE	 then
      -- A or else B : si A est TRUE, resultat = TRUE (ne pas evaluer	B)
      PUT_LINE( tab	& "DUP" );									-- dupliquer A pour	le test
      PUT_LINE( tab	& "BT" & tab & LBL_SKIP );								-- si A=TRUE, sauter (garder TRUE sur la pile)
      PUT_LINE( tab	& "DROP" );									-- jeter le duplicat de A (A etait FALSE)
      CODE_EXP( EXP2 );										-- evaluer B, resultat = B
      PUT_LINE( LBL_SKIP & ':' );

    end if;

  end	CODE_SHORT_CIRCUIT;
	------------------


				------------------
  procedure			CODE_PARENTHESIZED	( PARENTHESIZED :TREE )
  is				------------------
  begin
    CODE_EXP( D( AS_EXP, PARENTHESIZED ) );

  end	CODE_PARENTHESIZED;
	------------------


				---------------
  procedure			CODE_CONVERSION		( CONVERSION :TREE )
  is				---------------

    SRC_EXP	: TREE		:= D( AS_EXP,      CONVERSION	);
    SRC_TYPE	: TREE		:= D( SM_EXP_TYPE, SRC_EXP );
    TARGET_TYPE	: TREE		:= D( SM_EXP_TYPE, CONVERSION	);
    STATIC_VAL	: TREE		:= D( SM_VALUE,    CONVERSION	);

  begin
    if  STATIC_VAL /= TREE_VOID									-- VOIR STATIC VAL REELLE ?
    and then  ( ( STATIC_VAL.PT = HI  and then  STATIC_VAL.NOTY = DN_NUM_VAL )
	      or else  STATIC_VAL.TY = DN_NUM_VAL )
    then
      if	STATIC_VAL.PT = HI  then
        PUT_LINE( tab & "LI" & tab & IMAGE( DI( SM_VALUE, CONVERSION ) ) );
      else
        PUT_LINE( tab & "LI" & tab & PRINT_NUM( STATIC_VAL ) );
      end	if;

      if  TARGET_TYPE.TY = DN_FLOAT  then
        PUT_LINE( tab & "CVTIF" );
      end	if;

    else
      CODE_EXP( SRC_EXP );

      if  not( CODI.IN_GENERIC_BODY )
        or else (
		SRC_TYPE.TY not in DN_UNIVERSAL_INTEGER .. DN_UNIVERSAL_REAL
		and then  not( IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, SRC_TYPE ) ) ) )
      then											-- Laisser les PRIVATE
        if  TARGET_TYPE.TY = DN_PRIVATE  then
	TARGET_TYPE := D( SM_TYPE_SPEC, TARGET_TYPE );
        end if;

        if  SRC_TYPE.TY = DN_PRIVATE  then
	SRC_TYPE := D( SM_TYPE_SPEC, SRC_TYPE );
        end if;
      end if;

      if  CODI.DEBUG  then  PUT_LINE( "; CODE CONVERSION SOURCE " & NODE_NAME'IMAGE( SRC_TYPE.TY )
				& " TARGET " & NODE_NAME'IMAGE( TARGET_TYPE.TY ) );
      end if;

      if	TARGET_TYPE.TY in CLASS_TYPE_SPEC  then
        case  TARGET_TYPE.TY	is
        when DN_INTEGER | DN_ENUMERATION =>
				--------------
				INTEGER_TARGET:
	begin
	  if  SRC_TYPE.TY = DN_FLOAT  then								-- Verifier si la source est flottante (conversion float ->	entier)
	    PUT_LINE( tab & "CVTFI" );								-- conversion double IEEE 754	-> entier	(troncature)

	  elsif  SRC_TYPE.TY = DN_FIXED  then

				------------
				FIXED_TO_INT:
	    begin
	      if  CODI.IN_GENERIC_BODY  and then  IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, SRC_TYPE ) )  then	-- Passer par le use__info
	        declare
		TYPE_NAME		: TREE := D( XD_SOURCE_NAME, SRC_TYPE );
		TYPE_STR		:constant STRING := PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );

	        begin										-- L'entier MANTISSA est empilé
		PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		PUT_LINE( tab & "LIq , -" & TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.NUMER" );		-- Charge l'entier NUMER
		PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		PUT_LINE( tab & "LIq , -" & TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.DENOM" );		-- Charge l'entier DENOM
		PUT_LINE( tab & "CVTXI" );								-- / DENOM
	        end;

	      else
	        declare
		SMALL_VAL	: TREE		:= D( CD_IMPL_SMALL, SRC_TYPE );
		NUMER	: LONG_INTEGER	:= LONG_INTEGER'VALUE( PRINT_NUM( D( XD_NUMER, SMALL_VAL ) ) );
		DENOM	: LONG_INTEGER	:= LONG_INTEGER'VALUE( PRINT_NUM( D( XD_DENOM, SMALL_VAL ) ) );
	        begin
		PUT_LINE( tab & "LI" & tab & LONG_INTEGER'IMAGE( NUMER ) );
		PUT_LINE( tab & "LI" & tab & LONG_INTEGER'IMAGE( DENOM ) );
		PUT_LINE( tab & "CVTXI" );
	        end;
	      end if;

	    end		FIXED_TO_INT;
			------------
	  end if;

	end	INTEGER_TARGET;
		--------------

        when DN_FLOAT =>										-- Cible FLOAT
			------------
			FLOAT_TARGET:
	begin
	  if  SRC_TYPE.TY /= DN_FLOAT  and  SRC_TYPE.TY /= DN_UNIVERSAL_REAL  then				-- Si la source n'est pas deja flottante, convertir entier -> float

	    if  SRC_TYPE.TY = DN_FIXED  then								-- Source FIXED
				--------------
				FIXED_TO_FLOAT:
	      begin
	        if  CODI.IN_GENERIC_BODY  and then  IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, SRC_TYPE ) )  then	-- Passer par le use__info
					-------------------------
					FIXED_TO_FLOAT_IN_GENERIC:
		declare
		  TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, SRC_TYPE );
		  SRC_TYPE_STR	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
		begin
		  PUT_LINE( tab & "CVTIF" );								-- La mantisse fixed est deja au sommet de la pile.
		  PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		  PUT_LINE( tab & "LIq , -" & SRC_TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.NUMER" );		-- Charge l'entier NUMER
		  PUT_LINE( tab & "CVTIF" );
		  PUT_LINE( tab & "FMUL" );
		  PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		  PUT_LINE( tab & "LIq , -" & SRC_TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.DENOM" );		-- Charge l'entier DENOM
		  PUT_LINE( tab & "CVTIF" );
		  PUT_LINE( tab & "FDIV" );

		end	FIXED_TO_FLOAT_IN_GENERIC;
			-------------------------
	        else
					-------------------------
					FIXED_TO_FLOAT_USUAL:
		declare
		  SOURCE_SMALL	: TREE		:= D( CD_IMPL_SMALL, SRC_TYPE );
		  NUMER_SMALL	: LONG_INTEGER
				  := LONG_INTEGER'VALUE( PRINT_NUM( D( XD_NUMER, SOURCE_SMALL ) ) );
		  DENOM_SMALL	: LONG_INTEGER
				  := LONG_INTEGER'VALUE( PRINT_NUM( D( XD_DENOM, SOURCE_SMALL ) ) );
		begin
		  PUT_LINE( tab & "CVTIF" );								-- La mantisse fixed est deja au sommet de la pile.

		  if  NUMER_SMALL /= 1  then
		    PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_NUMER, SOURCE_SMALL ) ) );
		    PUT_LINE( tab & "CVTIF" );
		    PUT_LINE( tab & "FMUL" );
		  end if;

		  if DENOM_SMALL /= 1 then
		    PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_DENOM, SOURCE_SMALL ) ) );
		    PUT_LINE( tab & "CVTIF" );
		    PUT_LINE( tab & "FDIV" );
		  end if;
	          end	FIXED_TO_FLOAT_USUAL;
			--------------------
	        end if;
	      end	FIXED_TO_FLOAT;
		--------------


	    else
	      PUT( tab &	"CVTIF" );								-- conversion entier signe 64	-> double	IEEE 754
	      if  CODI.DEBUG  then
	        PUT( TAB50 & "; CODE_CONVERSION FLOAT TARGET FROM " & NODE_NAME'IMAGE( SRC_TYPE.TY ) );
	      end if;
	      NEW_LINE;
	    end if;
	  end if;
			-- float->float :	no-op, meme representation IEEE 754 double
	end	FLOAT_TARGET;
		------------

        when DN_FIXED =>										-- Cible FIXED
				------------
				FIXED_TARGET:
	declare
	  SRC_TYPE	: TREE	:= D( SM_EXP_TYPE, SRC_EXP );
	  TARGET_SMALL	: TREE	:= D( CD_IMPL_SMALL, TARGET_TYPE );

	begin
	  if  CODI.IN_GENERIC_BODY  and then  IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, TARGET_TYPE ) )  then	-- Passer par le use__info

	      if  SRC_TYPE.TY = DN_FLOAT  or  SRC_TYPE.TY = DN_UNIVERSAL_REAL  then

					-------------------------
					FLOAT_TO_FIXED_IN_GENERIC:
	        declare
		TYPE_NAME		: TREE		:= D( XD_SOURCE_NAME, TARGET_TYPE );
		TARGET_TYPE_STR	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	        begin
		PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		PUT_LINE( tab & "LIq , -" & TARGET_TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.DENOM" );		-- Charge l'entier DENOM
		PUT_LINE( tab & "CVTIF" );
		PUT_LINE( tab & "FMUL" );								-- MANTISSA * DENOM
		PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		PUT_LINE( tab & "LIq , -" & TARGET_TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.NUMER" );		-- Charge l'entier NUMER
		PUT_LINE( tab & "CVTIF" );
		PUT_LINE( tab & "FDIV" );								-- / NUMER
		PUT_LINE( tab & "CVTFIR" );

	        end	FLOAT_TO_FIXED_IN_GENERIC;
			-------------------------

	      elsif  SRC_TYPE.TY = DN_INTEGER  or  SRC_TYPE.TY = DN_UNIVERSAL_INTEGER  then
				---------------------------
				INTEGER_TO_FIXED_IN_GENERIC:
	        declare
		TYPE_NAME		: TREE		:= D( XD_SOURCE_NAME, TARGET_TYPE );
		TARGET_TYPE_STR	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	        begin
		PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		PUT_LINE( tab & "LIq , -" & TARGET_TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.DENOM" );		-- Charge l'entier DENOM
		PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		PUT_LINE( tab & "LIq , -" & TARGET_TYPE_STR & "__u_ofs, STANDARD.FIXED_USE_INFO.NUMER" );		-- Charge l'entier NUMER
		PUT_LINE( tab & "CVTIX" );

	        end	INTEGER_TO_FIXED_IN_GENERIC;
			---------------------------

	      elsif  SRC_TYPE.TY = DN_FIXED  then
				-------------------------
				FIXED_TO_FIXED_IN_GENERIC:
	        declare
		SOURCE_SMALL	: TREE	:= D( CD_IMPL_SMALL, SRC_TYPE );
	        begin
		if PRINT_NUM( D( XD_NUMER, SOURCE_SMALL ) ) = PRINT_NUM( D( XD_NUMER, TARGET_SMALL ) )		-- Comparaisons de chaînes à revoir
		   and then PRINT_NUM( D( XD_DENOM, SOURCE_SMALL ) ) = PRINT_NUM( D( XD_DENOM, TARGET_SMALL ) )
		then
		  null;  -- meme representation : conversion identite

		else
		  PUT_LINE( "; FIXED TO FIXED WITH DIFFERENT SMALL A FAIRE" );
		end if;

	        end	FIXED_TO_FIXED_IN_GENERIC;
			-------------------------
	      end if;

	  else
	    if  SRC_TYPE.TY = DN_INTEGER  then								-- INTEGER deja empile
	      PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_DENOM, TARGET_SMALL ) ) );				-- DENOM
	      PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_NUMER, TARGET_SMALL ) ) );				-- NUMER
	      PUT_LINE( tab & "CVTIX" );

	    elsif  SRC_TYPE.TY = DN_FLOAT  or  SRC_TYPE.TY = DN_UNIVERSAL_REAL  then				-- LONG_FLOAT deja empile
				--------------------
				FLOAT_TO_FIXED_USUAL:
	      declare
	        NUMER_SMALL	: LONG_INTEGER	:= LONG_INTEGER'VALUE( PRINT_NUM( D( XD_NUMER, TARGET_SMALL ) ) );
	        DENOM_SMALL	: LONG_INTEGER	:= LONG_INTEGER'VALUE( PRINT_NUM( D( XD_DENOM, TARGET_SMALL ) ) );

	      begin
	        if  DENOM_SMALL /= 1  then
		PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_DENOM, TARGET_SMALL ) ) );
		PUT_LINE( tab & "CVTIF" );
		PUT_LINE( tab & "FMUL" );
	        end if;

	        if  NUMER_SMALL /= 1  then
		PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( XD_NUMER, TARGET_SMALL ) ) );
		PUT_LINE( tab & "CVTIF" );
		PUT_LINE( tab & "FDIV" );
	        end if;

	        PUT_LINE( tab & "CVTFIR" );

	    end	FLOAT_TO_FIXED_USUAL;
		--------------------

	    elsif  SRC_TYPE.TY = DN_FIXED  and then  TARGET_TYPE /= SRC_TYPE  then
	      PUT_LINE( "; FIXED to FIXED a faire" );
	    end if;
	  end if;
								-- A COMPLETER pour FIXED vers FIXED
	end	FIXED_TARGET;
		------------

        when others	=>
	PUT_LINE( "; EXPRESSIONS.CODE_CONVERSION cible non faite " & NODE_NAME'IMAGE( TARGET_TYPE.TY ) );
	null;
        end case;
      end	if;

    end if;

  end	CODE_CONVERSION;
	---------------


procedure CODE_ARRAY_AGGREGATE_DYNAMIC ( AGG, TYPE_SPEC : TREE )
  is
    BASE_TYPE  : TREE    := D( SM_BASE_TYPE, TYPE_SPEC );
    COMP_TYPE  : TREE    := D( SM_COMP_TYPE, BASE_TYPE );
    COMP_BITS  : INTEGER := DI( CD_IMPL_SIZE, COMP_TYPE );
    COMP_BYTES : INTEGER := COMP_BITS / CODI.STORAGE_UNIT;
    LVL        : constant STRING := IMAGE( CODI.CUR_LEVEL );
    TYPE_NAME  : TREE    := D( XD_SOURCE_NAME, TYPE_SPEC );
    TYPE_STR   : constant STRING := PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
    ANON       : constant STRING := ANONYMOUS_NAME_AT( AGG );

    -- Bornes de l'agrégat : SM_DISCRETE_RANGE ou les CHOICES du premier NAMED
    NORM_SEQ   : SEQ_TYPE := LIST( D( SM_NORMALIZED_COMP_S, AGG ) );
  begin
    -- ---- Declarations ----
    PUT_LINE( "namespace " & ANON );
    PUT_LINE( "  VAR SIZ,      d" );
    PUT_LINE( "  VAR COMP_SIZ, d" );
    PUT_LINE( "  VAR FST_1,    d" );
    PUT_LINE( "  VAR LST_1,    d" );
    PUT_LINE( "end namespace" );
    PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
    PUT_LINE( "VAR" & tab & ANON & "__u,   q" );

    -- ---- Calculer et stocker FST et LST ----
    -- Pour STRING'(1..COMPL=>'0'), SM_DISCRETE_RANGE de l'agrégat
    -- donne la range (AS_EXP1=1, AS_EXP2=COMPL).
    declare
      DR : TREE := D( SM_DISCRETE_RANGE, AGG );
    begin
      if DR /= TREE_VOID then
        CODE_EXP( D( AS_EXP1, DR ) );
        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & ".FST_1" );
        CODE_EXP( D( AS_EXP2, DR ) );
        PUT_LINE( tab & "DUP" );
        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & ".LST_1" );
      else
        -- Pas de range explicite : FST=1, LST=nb d'elements dans l'agrégat
        PUT_LINE( tab & "LI  1" );
        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & ".FST_1" );
        -- LST = nombre d'associations (taille de NORM_SEQ)
        -- Pour 'others', c'est la range entière -> fallback LI 0
        PUT_LINE( tab & "LI  0" );
        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & ".LST_1" );
      end if;
    end;
    -- COMP_SIZ
    PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BITS ) );
    PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & ".COMP_SIZ" );

    -- ---- Allouer (LST - FST + 1) * COMP_BYTES octets sur co-pile ----
    PUT_LINE( tab & "Ld  " & LVL & ", " & ANON & ".LST_1" );
    PUT_LINE( tab & "INC" );
    PUT_LINE( tab & "Ld  " & LVL & ", " & ANON & ".FST_1" );
    PUT_LINE( tab & "SUB" );
    -- SIZ total en bits
    if COMP_BITS /= CODI.STORAGE_UNIT then
      PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BITS ) );
      PUT_LINE( tab & "MUL" );
      PUT_LINE( tab & "LI"  & tab & IMAGE( CODI.STORAGE_UNIT ) );
      PUT_LINE( tab & "DIV" );
    end if;
    PUT_LINE( tab & "DUP" );
    PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & ".SIZ" );
    -- Re-calculer en octets pour l'allocation
    PUT_LINE( tab & "Ld  " & LVL & ", " & ANON & ".LST_1" );
    PUT_LINE( tab & "INC" );
    PUT_LINE( tab & "Ld  " & LVL & ", " & ANON & ".FST_1" );
    PUT_LINE( tab & "SUB" );
    if COMP_BYTES /= 1 then
      PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BYTES ) );
      PUT_LINE( tab & "MUL" );
    end if;
    PUT_LINE( tab & "CO_VAR" );               -- @data sur pile
    PUT_LINE( tab & "DUP" );
    PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "_disp" );  -- sauvegarder data_ptr

    -- ---- Remplir info_ptr ----
    PUT_LINE( tab & "LVA " & LVL & ", " & ANON & ".SIZ" );
    PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "__u" );

    -- ---- Appeler CODE_AGGREGATE avec @data en tête de pile ----
    -- (CO_VAR a laissé @data, DUP l'a copié, Sa l'a consommé,
    -- il reste le premier @data sur la pile pour CODE_AGGREGATE)
    CODE_AGGREGATE( AGG, TYPE_SPEC );

    -- ---- Laisser @doublet sur la pile ----
    PUT_LINE( tab & "LVA " & LVL & ", " & ANON & "_disp" );
  end CODE_ARRAY_AGGREGATE_DYNAMIC;


				--------------
  procedure			CODE_QUALIFIED		( QUALIFIED :TREE )
  is				--------------

    SRC_EXP	: TREE		:= D( AS_EXP,      QUALIFIED );
    VAL		: TREE		:= D( SM_VALUE,    QUALIFIED );

  begin
    -- Si	la valeur	est connue statiquement, emettre un LI direct
    if  VAL /= TREE_VOID
    and then  ( ( VAL.PT = HI	 and then	 VAL.NOTY	= DN_NUM_VAL )
	      or else  VAL.TY = DN_NUM_VAL )
    then
      if	VAL.PT = HI  then
        PUT_LINE( tab & "LI" & tab & IMAGE( DI( SM_VALUE, QUALIFIED )	) );
      else
        PUT_LINE( tab & "LI" & tab & PRINT_NUM( VAL ) );
      end	if;

    else

put_line( "; CODE_QUALIFIED : DN_QUALIFIED" & NODE_NAME'IMAGE( SRC_EXP.TY ) );

      if  SRC_EXP.TY = DN_AGGREGATE  then
        declare
          AGG_TYPE : TREE := D( SM_EXP_TYPE, QUALIFIED );
        begin
          if  AGG_TYPE.TY = DN_ARRAY  then
            -- =========================================================
            -- Agrégat qualifié de tableau non contraint :
            -- STRING'(1..COMPL=>'0')
            -- Il faut allouer les données sur la co-pile, construire
            -- le descripteur, PUIS appeler CODE_AGGREGATE.
            -- =========================================================
            declare
              BASE_TYPE  : TREE    := D( SM_BASE_TYPE, AGG_TYPE );
              COMP_TYPE  : TREE    := D( SM_COMP_TYPE, BASE_TYPE );
              COMP_BITS  : INTEGER := DI( CD_IMPL_SIZE, COMP_TYPE );
              COMP_BYTES : INTEGER := COMP_BITS / CODI.STORAGE_UNIT;
              LVL_STR    : constant STRING := IMAGE( CODI.CUR_LEVEL );
              ANON       : constant STRING := ANONYMOUS_NAME_AT( SRC_EXP );
              TYPE_STR   : constant STRING
                         := PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, AGG_TYPE ) ) );

              -- Extraire les bornes depuis le DN_CHOICE_RANGE du DN_NAMED
              NORM_SEQ   : SEQ_TYPE := LIST( D( SM_NORMALIZED_COMP_S, SRC_EXP ) );
              ASSOC      : TREE;
              CH         : TREE;
              RNG        : TREE;
            begin
              POP( NORM_SEQ, ASSOC );
              declare
                CHOICES : SEQ_TYPE := LIST( D( AS_CHOICE_S, ASSOC ) );
              begin
                POP( CHOICES, CH );
                RNG := D( AS_DISCRETE_RANGE, CH );   -- DN_RANGE(EXP1=1, EXP2=COMPL)
              end;

              -- ---- Déclarations dans la VARzone ----
              PUT_LINE( "namespace " & ANON & "_info" );
              PUT_LINE( "  VAR SIZ,      d" );
              PUT_LINE( "  VAR COMP_SIZ, d" );
              PUT_LINE( "  VAR FST_1,    d" );
              PUT_LINE( "  VAR LST_1,    d" );
              PUT_LINE( "end namespace" );
              PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
              PUT_LINE( "VAR" & tab & ANON & "__u,   q" );

              -- ---- Calculer et stocker FST_1 ----
              CODE_EXP( D( AS_EXP1, RNG ) );               -- 1 (statique mais on le génère)
              PUT_LINE( tab & "Sd  " & LVL_STR & ", " & ANON & "_info.FST_1" );

              -- ---- Calculer et stocker LST_1 = COMPL ----
              CODE_EXP( D( AS_EXP2, RNG ) );               -- COMPL (dynamique)
              PUT_LINE( tab & "DUP" );
              PUT_LINE( tab & "Sd  " & LVL_STR & ", " & ANON & "_info.LST_1" );

              -- ---- COUNT = LST_1 - FST_1 + 1 (LST encore en pile) ----
              CODE_EXP( D( AS_EXP1, RNG ) );               -- FST_1
              PUT_LINE( tab & "SUB" );
              PUT_LINE( tab & "INC" );

              -- ---- Stocker COMP_SIZ en bits ----
              PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BITS ) );
              PUT_LINE( tab & "Sd  " & LVL_STR & ", " & ANON & "_info.COMP_SIZ" );

              -- ---- Stocker SIZ = COUNT * COMP_BITS ----
              -- COUNT encore en pile
              PUT_LINE( tab & "DUP" );
              if COMP_BITS /= 1 then
                PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BITS ) );
                PUT_LINE( tab & "MUL" );
              end if;
              PUT_LINE( tab & "Sd  " & LVL_STR & ", " & ANON & "_info.SIZ" );

              -- ---- Allouer COUNT * COMP_BYTES octets sur la co-pile ----
              -- COUNT encore en pile
              if COMP_BYTES /= 1 then
                PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BYTES ) );
                PUT_LINE( tab & "MUL" );
              end if;
              PUT_LINE( tab & "CO_VAR" );          -- depile taille, empile @data
              PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON & "_disp" );

              -- ---- Initialiser info_ptr ----
              PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_info.SIZ" );
              PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON & "__u" );

              -- ---- Appeler CODE_AGGREGATE avec @data en tête de pile ----
              -- CODE_AGGREGATE(DN_ARRAY) attend @data en sommet de pile
              PUT_LINE( tab & "La  " & LVL_STR & ", " & ANON & "_disp" );
              CODE_AGGREGATE( SRC_EXP, AGG_TYPE );

              -- ---- Laisser @doublet sur la pile ----
              PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );
            end;

          else
            CODE_AGGREGATE( SRC_EXP, AGG_TYPE );
          end if;
        end;

      -- Expression	qualifiee	dynamique	: generer	le code de l'expression
--      if  SRC_EXP.TY = DN_AGGREGATE  then
--        CODE_AGGREGATE( SRC_EXP, D( SM_EXP_TYPE, QUALIFIED ) );
--        declare
--          AGG_TYPE : TREE := D( SM_EXP_TYPE, QUALIFIED );
--        begin
--          if  AGG_TYPE.TY = DN_ARRAY  or  AGG_TYPE.TY = DN_CONSTRAINED_ARRAY  then
--            -- Agrégat de tableau : calculer les bornes, allouer sur co-pile
--            CODE_ARRAY_AGGREGATE_DYNAMIC( SRC_EXP, AGG_TYPE );
--          else
--            CODE_AGGREGATE( SRC_EXP, AGG_TYPE );
--          end if;
--        end;

      else
        CODE_EXP( SRC_EXP );
      end if;

    end if;

  end	CODE_QUALIFIED;
	--------------


				---------------------
  procedure			CODE_RANGE_MEMBERSHIP	( RANGE_MEMBERSHIP :TREE )
  is				---------------------
  begin
    null;
  end	CODE_RANGE_MEMBERSHIP;
	---------------------


				--------------------
  procedure			CODE_TYPE_MEMBERSHIP	( TYPE_MEMBERSHIP :TREE )
  is				--------------------
  begin
    null;
  end	CODE_TYPE_MEMBERSHIP;
	--------------------


				----------
  procedure			CODE_VC_ID		( VC_ID :TREE	)
  is
    VC_TYPE	: TREE		:= D( SM_OBJ_TYPE, VC_ID );
    VC_LEVEL	: LEVEL_NUM	:= DI( CD_LEVEL, VC_ID );
    VC_STR   : constant STRING := PRINT_NAME( D( LX_SYMREP, VC_ID ) );
  begin
    while  VC_TYPE.TY = DN_PRIVATE  or else  VC_TYPE.TY = DN_L_PRIVATE  loop
      VC_TYPE := D( SM_TYPE_SPEC, VC_TYPE );
    end loop;

    if  DB( SM_RENAMES_OBJ, VC_ID )  then
      if  VC_TYPE.TY in CLASS_SCALAR  then
        PUT_LINE( tab & "LI" & OPER_SIZ_CHAR( VC_TYPE ) & tab & IMAGE( VC_LEVEL ) & ", " & VC_STR & "_disp, 0" );
      else
      -- Composite : renvoyer l’adresse du doublet alias (_disp, __u),
      -- exactement comme LOAD_MEM le fait pour une variable composite.
        PUT_LINE( tab & "LVA" & tab & IMAGE( VC_LEVEL ) & ", " & VC_STR & "_disp" );
      end if;

      return;
    end if;

    case VC_TYPE.TY is

    when DN_INTEGER	| DN_ACCESS | DN_ENUMERATION | DN_FLOAT | DN_FIXED
    =>
      if  not CODI.IN_GENERIC_BODY  then
        LOAD_MEM( VC_ID );

      elsif  IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, VC_TYPE ) )  then

	PUT( tab & "LVA " & IMAGE( VC_LEVEL ) & ',' & tab );
	if  VC_LEVEL /= INTEGER( CUR_LEVEL )
	or else	D( XD_REGION, VC_ID ).TY = DN_PACKAGE_ID
	then
	  REGIONS_PATH( VC_ID );
	end if;
	PUT_LINE(	PRINT_NAME( D( LX_SYMREP, VC_ID ) )  & "_disp" );

	PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
	PUT_LINE( tab & "La ," & tab & '-' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, VC_TYPE ) ) )  & "__ld_ofs" );
	PUT_LINE( tab & "CALLI" );

      else
        LOAD_MEM( VC_ID );
      end if;

    when DN_RECORD | DN_PRIVATE | DN_L_PRIVATE =>
      LOAD_MEM( VC_ID );

    when DN_ARRAY |	DN_CONSTRAINED_ARRAY =>
      LOAD_MEM( VC_ID );

    when others
    =>
      PUT_LINE( ';'	& tab & "CODE_VC_ID ERROR " &	NODE_NAME'IMAGE( VC_TYPE.TY ) );
      raise PROGRAM_ERROR;
    end case;

  end	CODE_VC_ID;
	----------


	-----------
end	EXPRESSIONS;
	-----------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
