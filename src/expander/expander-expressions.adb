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
        if  D( SM_EXP_TYPE, NAME_EXP ).TY in CLASS_SCALAR  then
	PUT_LINE( tab & "L" & OPER_SIZ_CHAR( D( SM_EXP_TYPE, NAME_EXP ) ) );
        end if;

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
    DESIG_TYPE	: TREE	:= D( SM_EXP_TYPE, ADA_ALL );
  begin
    CODE_OBJECT_ADDRESS( ADA_ALL );

    while  DESIG_TYPE.TY = DN_PRIVATE  or else  DESIG_TYPE.TY = DN_L_PRIVATE  loop
      DESIG_TYPE := D( SM_TYPE_SPEC, DESIG_TYPE );
    end loop;

    if  DESIG_TYPE.TY in CLASS_SCALAR  or else DESIG_TYPE.TY = DN_ACCESS  then
      PUT_LINE( tab & "L" & OPER_SIZ_CHAR( DESIG_TYPE ) );
    end if;
  end	CODE_ALL;
	--------


				------------
  procedure			CODE_INDEXED	( INDEXED	:TREE )
  is				------------

    NAME		: TREE	:= D( AS_NAME, INDEXED );

  begin
    if  NAME.TY = DN_USED_OBJECT_ID  then
      declare
        ACCESS_TYPE		: TREE	:= D( SM_EXP_TYPE, NAME );
      begin
        while ACCESS_TYPE.TY = DN_PRIVATE or else ACCESS_TYPE.TY = DN_L_PRIVATE loop
	ACCESS_TYPE := D( SM_TYPE_SPEC, ACCESS_TYPE );
        end loop;

        if  ACCESS_TYPE.TY = DN_ACCESS  then
	declare
	  DESIG_TYPE	: TREE	:= D( SM_DESIG_TYPE, ACCESS_TYPE );
	begin
	  while  DESIG_TYPE.TY = DN_PRIVATE or else DESIG_TYPE.TY = DN_L_PRIVATE  loop
	    DESIG_TYPE := D( SM_TYPE_SPEC, DESIG_TYPE );
	  end loop;

	  if  DESIG_TYPE.TY = DN_INCOMPLETE  then
	    DESIG_TYPE := D( XD_FULL_TYPE_SPEC, DESIG_TYPE );
	  end if;

        -- Ici DESIG_TYPE doit être T1, donc DN_CONSTRAINED_ARRAY
	  declare
	    DESIG_NAME     : TREE := D( XD_SOURCE_NAME, DESIG_TYPE );
	    TYPE_NAME_STR  : constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, DESIG_NAME ) );
	    TYPE_LVL       : INTEGER := DI( CD_LEVEL, DESIG_TYPE );
	    INDEX_NUM      : INTEGER := 1;
	    NB_DIMS        : INTEGER := 0;

			-----
	    procedure	INDEX	( EXP : TREE )
	    is		-----
	    INDEX_NUM_IMG	:constant STRING	:= IMAGE( INDEX_NUM );
	  begin
	    CODE_EXP( EXP );

	    -- PILIER CHECKS (E-C) : FST_n <= index <= LST_n (LRM 4.1.1)
	    if  CODI.CHECKS_ENABLED  then
	      PUT_LINE( tab & "DUP" );
	      PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
	      REGIONS_PATH( DESIG_NAME );
	      PUT_LINE( TYPE_NAME_STR & "._FST_" & INDEX_NUM_IMG );
	      PUT_LINE( tab & "CLT" );
	      PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );
	      PUT_LINE( tab & "DUP" );
	      PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
	      REGIONS_PATH( DESIG_NAME );
	      PUT_LINE( TYPE_NAME_STR & "._LST_" & INDEX_NUM_IMG );
	      PUT_LINE( tab & "CGT" );
	      PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );
	    end if;

	    PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
	    REGIONS_PATH( DESIG_NAME );
	    PUT_LINE( TYPE_NAME_STR & "._FST_" & INDEX_NUM_IMG );

	    PUT_LINE( tab & "SUB" );

	    PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
	    REGIONS_PATH( DESIG_NAME );
	    if  INDEX_NUM < NB_DIMS  then
	      PUT_LINE( TYPE_NAME_STR & ".SIZ_" & INDEX_NUM_IMG );
	    else
	      PUT_LINE( TYPE_NAME_STR & "._COMP_SIZ" );
	    end if;

	    PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
	    PUT_LINE( tab & "DIV" );
	    PUT_LINE( tab & "MUL" );
	    PUT_LINE( tab & "ADD" );

	  end	INDEX;
		-----
	  begin
          -- Charge la valeur access : @data du tableau désigné.
	    CODE_EXP( NAME );

	    declare
	      CNT_SEQ	: SEQ_TYPE	:= LIST( D( AS_EXP_S, INDEXED ) );
	      DUMMY		: TREE;
	    begin
	      while  not IS_EMPTY( CNT_SEQ )  loop
	        POP( CNT_SEQ, DUMMY );
                NB_DIMS := NB_DIMS + 1;
	      end loop;
	    end;

	    declare
	      EXP_SEQ : SEQ_TYPE := LIST( D( AS_EXP_S, INDEXED ) );
	      EXP     : TREE;
	    begin
	      while  not IS_EMPTY( EXP_SEQ )  loop
	        POP( EXP_SEQ, EXP );
	        INDEX( EXP );
	        INDEX_NUM := INDEX_NUM + 1;
	      end loop;
	    end;

	    return;
	  end;
          end;
        end if;
      end;
    end if;

    if  NAME.TY = DN_ALL  then
      declare
        EXP_TYPE		: TREE		:= D( SM_EXP_TYPE, NAME );
        EXP_TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, EXP_TYPE );
        TYPE_NAME_STR	:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, EXP_TYPE_NAME ) );
        TYPE_LVL		: INTEGER		:= DI( CD_LEVEL, EXP_TYPE );
        INDEX_NUM		: INTEGER		:= 1;
        NB_DIMS		: INTEGER		:= 0;

		-----
        procedure	INDEX	( EXP :TREE )
        is	-----
          INDEX_NUM_IMG	:constant STRING	:= IMAGE( INDEX_NUM );
        begin
          CODE_EXP( EXP );

          -- PILIER CHECKS (E-C) : FST_n <= index <= LST_n (LRM 4.1.1)
          if  CODI.CHECKS_ENABLED  then
            PUT_LINE( tab & "DUP" );
            PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
            REGIONS_PATH( EXP_TYPE_NAME );
            PUT_LINE( TYPE_NAME_STR & "._FST_" & INDEX_NUM_IMG );
            PUT_LINE( tab & "CLT" );
            PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );
            PUT_LINE( tab & "DUP" );
            PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
            REGIONS_PATH( EXP_TYPE_NAME );
            PUT_LINE( TYPE_NAME_STR & "._LST_" & INDEX_NUM_IMG );
            PUT_LINE( tab & "CGT" );
            PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );
          end if;

          PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
          REGIONS_PATH( EXP_TYPE_NAME );
          PUT_LINE( TYPE_NAME_STR & "._FST_" & INDEX_NUM_IMG );

          PUT_LINE( tab & "SUB" );

          PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
          REGIONS_PATH( EXP_TYPE_NAME );
          if  INDEX_NUM < NB_DIMS  then
            PUT_LINE( TYPE_NAME_STR & ".SIZ_" & INDEX_NUM_IMG );
          else
            PUT_LINE( TYPE_NAME_STR & "._COMP_SIZ" );
          end if;

          PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
          PUT_LINE( tab & "DIV" );
          PUT_LINE( tab & "MUL" );
          PUT_LINE( tab & "ADD" );

        end	INDEX;
		-----

      begin
        CODE_OBJECT_ADDRESS( NAME );							-- @data pointee par l'access

        declare
          CNT_SEQ	: SEQ_TYPE	:= LIST( D( AS_EXP_S, INDEXED ) );
          DUMMY		: TREE;
        begin
          while  not IS_EMPTY( CNT_SEQ )  loop
            POP( CNT_SEQ, DUMMY );
            NB_DIMS := NB_DIMS + 1;
          end loop;
        end;

        declare
          EXP_SEQ	: SEQ_TYPE	:= LIST( D( AS_EXP_S, INDEXED ) );
          EXP		: TREE;
        begin
          while  not IS_EMPTY( EXP_SEQ )  loop
            POP( EXP_SEQ, EXP );
            INDEX( EXP );
            INDEX_NUM := INDEX_NUM + 1;
          end loop;
        end;

        return;
      end;
    end if;

    if  NAME.TY = DN_SELECTED	 then
      CODE_SELECTED( NAME, IS_SOURCE=> FALSE );
      NAME := D( AS_DESIGNATOR, NAME );
    end if;

    if  NAME.TY = DN_INDEXED  then
    declare
      PREFIX_TYPE      : TREE := D( SM_EXP_TYPE, NAME );
      PREFIX_BASE_TYPE : TREE;
      PREFIX_TYPE_NAME : TREE;
      TYPE_NAME_STR    : STRING(1 .. 200);
      TYPE_NAME_LEN    : NATURAL := 0;
      TYPE_LVL         : INTEGER;
      INDEX_NUM        : INTEGER := 1;
      NB_DIMS          : INTEGER := 0;

		---------------
      function	FULL_VIEW_LOCAL ( T : TREE ) return TREE
      is		---------------
         R : TREE := T;
      begin
         loop
            if  R.TY = DN_PRIVATE or else R.TY = DN_L_PRIVATE  then
               R := D( SM_TYPE_SPEC, R );

            elsif  R.TY = DN_INCOMPLETE  then
               R := D( XD_FULL_TYPE_SPEC, R );

            else
               return R;
            end if;
         end loop;

      end	FULL_VIEW_LOCAL;
	---------------

		-------------
      procedure	SET_TYPE_NAME ( S : STRING )
      is		-------------
      begin
       TYPE_NAME_LEN := S'LENGTH;
       TYPE_NAME_STR(1 .. TYPE_NAME_LEN) := S;

      end	SET_TYPE_NAME;
	-------------

		-----
      procedure	INDEX ( EXP : TREE )
      is		-----
         INDEX_NUM_IMG : constant STRING := IMAGE( INDEX_NUM );
      begin
         CODE_EXP( EXP );

         -- PILIER CHECKS (E-C) : FST_n <= index <= LST_n (LRM 4.1.1)
         if  CODI.CHECKS_ENABLED  then
            PUT_LINE( tab & "DUP" );
            PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
            REGIONS_PATH( PREFIX_TYPE_NAME );
            PUT_LINE( TYPE_NAME_STR(1 .. TYPE_NAME_LEN) & "._FST_" & INDEX_NUM_IMG );
            PUT_LINE( tab & "CLT" );
            PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );
            PUT_LINE( tab & "DUP" );
            PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
            REGIONS_PATH( PREFIX_TYPE_NAME );
            PUT_LINE( TYPE_NAME_STR(1 .. TYPE_NAME_LEN) & "._LST_" & INDEX_NUM_IMG );
            PUT_LINE( tab & "CGT" );
            PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );
         end if;

         PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
         REGIONS_PATH( PREFIX_TYPE_NAME );
         PUT_LINE( TYPE_NAME_STR(1 .. TYPE_NAME_LEN) & "._FST_" & INDEX_NUM_IMG );

         PUT_LINE( tab & "SUB" );

         PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
         REGIONS_PATH( PREFIX_TYPE_NAME );

         if  INDEX_NUM < NB_DIMS  then
            PUT_LINE( TYPE_NAME_STR(1 .. TYPE_NAME_LEN) & ".SIZ_" & INDEX_NUM_IMG );
         else
            PUT_LINE( TYPE_NAME_STR(1 .. TYPE_NAME_LEN) & "._COMP_SIZ" );
         end if;

         PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
         PUT_LINE( tab & "DIV" );
         PUT_LINE( tab & "MUL" );
         PUT_LINE( tab & "ADD" );
      end INDEX;

   begin
      PREFIX_TYPE := FULL_VIEW_LOCAL( PREFIX_TYPE );

      if  PREFIX_TYPE.TY = DN_CONSTRAINED_ARRAY  then
         PREFIX_BASE_TYPE := D( SM_BASE_TYPE, PREFIX_TYPE );
      else
         PREFIX_BASE_TYPE := PREFIX_TYPE;
      end if;

      PREFIX_TYPE_NAME := D( XD_SOURCE_NAME, PREFIX_TYPE );
      TYPE_LVL         := DI( CD_LEVEL, PREFIX_TYPE );

      SET_TYPE_NAME( '_' & PRINT_NAME( D( LX_SYMREP, PREFIX_TYPE_NAME ) ) );

      --  Calcule l'adresse de X2(1), c'est-à-dire l'adresse de début
      --  du tableau composant T2.
      CODE_INDEXED( NAME );

      declare
         CNT_SEQ : SEQ_TYPE := LIST( D( AS_EXP_S, INDEXED ) );
         DUMMY   : TREE;
      begin
         while  not IS_EMPTY( CNT_SEQ )  loop
            POP( CNT_SEQ, DUMMY );
            NB_DIMS := NB_DIMS + 1;
         end loop;
      end;

      declare
         EXP_SEQ : SEQ_TYPE := LIST( D( AS_EXP_S, INDEXED ) );
         EXP     : TREE;
      begin
         while  not IS_EMPTY( EXP_SEQ )  loop
            POP( EXP_SEQ, EXP );
            INDEX( EXP );
            INDEX_NUM := INDEX_NUM + 1;
         end loop;
      end;

      return;
   end;
    end if;


    declare
    ARRAY_NAME		:constant	STRING		:= PRINT_NAME( D( LX_SYMREP, NAME ) );
    ARRAY_DEFN		: TREE			:= D( SM_DEFN, NAME	);
    EXP_TYPE		: TREE			:= D( SM_EXP_TYPE, NAME );
    EXP_TYPE_NAME		: TREE			:= D( XD_SOURCE_NAME, EXP_TYPE );
    TYPE_NAME_STR		:constant	STRING		:= '_' & PRINT_NAME( D( LX_SYMREP, EXP_TYPE_NAME ) );
    ARRAY_LVL		: INTEGER			:= 0;
    TYPE_LVL		: INTEGER			:= DI( CD_LEVEL, EXP_TYPE );
    INDEX_NUM		: INTEGER			:= 1;
    NB_DIMS		: INTEGER			:= 0;
    IS_PARAM		: BOOLEAN			:= FALSE;
    USE_TYPE_INFO_DIRECT	: BOOLEAN			:= FALSE;

		-----
      procedure	INDEX	( EXP :TREE )
      is		-----

        INDEX_NUM_IMG	:constant	STRING	:= IMAGE(	INDEX_NUM	);
        LVL_IMG		:constant	STRING	:= IMAGE(	ARRAY_LVL	);

      begin
        CODE_EXP( EXP );

        -- PILIER CHECKS (E-C) : FST_n <= index <= LST_n (LRM 4.1.1),
        -- bornes chargees par la MEME sequence que le calcul d'offset
        -- ci-dessous, sous-cas par sous-cas.
        if  CODI.CHECKS_ENABLED  then
          PUT_LINE( tab & "DUP" );
          if  IS_PARAM  then
	    PUT_LINE(	tab & "LVA" & tab &	LVL_IMG &	", -" & ARRAY_NAME & "_ofs" );
            PUT_LINE( tab & "LIa" & tab & ", 0, " & INTEGER'IMAGE( CODI.ADDR_SIZE ) );
            PUT( tab & "Ld" & tab & ", " );
	    REGIONS_PATH( EXP_TYPE_NAME );
	    PUT_LINE( TYPE_NAME_STR & ".FST_" & INDEX_NUM_IMG );
          elsif  USE_TYPE_INFO_DIRECT  then
            PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
	    REGIONS_PATH( EXP_TYPE_NAME );
	    PUT_LINE( TYPE_NAME_STR & "._FST_" & INDEX_NUM_IMG );
          else
	    PUT( tab & "LId" & tab & LVL_IMG & ", "	& ARRAY_NAME & "__u" & ", " );
	    REGIONS_PATH( EXP_TYPE_NAME );
	    PUT_LINE( TYPE_NAME_STR & ".FST_" & INDEX_NUM_IMG );
          end if;
          PUT_LINE( tab & "CLT" );
          PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );

          PUT_LINE( tab & "DUP" );
          if  IS_PARAM  then
	    PUT_LINE(	tab & "LVA" & tab &	LVL_IMG &	", -" & ARRAY_NAME & "_ofs" );
            PUT_LINE( tab & "LIa" & tab & ", 0, " & INTEGER'IMAGE( CODI.ADDR_SIZE ) );
            PUT( tab & "Ld" & tab & ", " );
	    REGIONS_PATH( EXP_TYPE_NAME );
	    PUT_LINE( TYPE_NAME_STR & ".LST_" & INDEX_NUM_IMG );
          elsif  USE_TYPE_INFO_DIRECT  then
            PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
	    REGIONS_PATH( EXP_TYPE_NAME );
	    PUT_LINE( TYPE_NAME_STR & "._LST_" & INDEX_NUM_IMG );
          else
	    PUT( tab & "LId" & tab & LVL_IMG & ", "	& ARRAY_NAME & "__u" & ", " );
	    REGIONS_PATH( EXP_TYPE_NAME );
	    PUT_LINE( TYPE_NAME_STR & ".LST_" & INDEX_NUM_IMG );
          end if;
          PUT_LINE( tab & "CGT" );
          PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );
        end if;

        -- Charger FST_n depuis useinfo
        if  IS_PARAM  then

	PUT_LINE(	tab & "LVA" & tab &	LVL_IMG &	", -" & ARRAY_NAME & "_ofs" );
          PUT_LINE( tab & "LIa" & tab & ", 0, " & INTEGER'IMAGE( CODI.ADDR_SIZE ) );
          PUT( tab & "Ld" & tab & ", " );
	REGIONS_PATH( EXP_TYPE_NAME );
	PUT( TYPE_NAME_STR & ".FST_" & INDEX_NUM_IMG );

        elsif  USE_TYPE_INFO_DIRECT  then
          PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
	REGIONS_PATH( EXP_TYPE_NAME );
	PUT( TYPE_NAME_STR & "._FST_" & INDEX_NUM_IMG );

        else
	PUT( tab & "LId" & tab & LVL_IMG & ", "	& ARRAY_NAME & "__u" & ", " );
	REGIONS_PATH( EXP_TYPE_NAME );
	PUT( TYPE_NAME_STR & ".FST_" & INDEX_NUM_IMG );

        end if;


        if  CODI.DEBUG  then PUT( tab50	& "; (index - FST_"	& INDEX_NUM_IMG & ") * SIZ_" & INDEX_NUM_IMG ); end if;
        NEW_LINE;
        PUT_LINE( tab & "SUB"	);

        -- Charger COMP_SIZ depuis useinfo
        if  IS_PARAM  then
	PUT_LINE(	tab & "LVA" & tab &	LVL_IMG &	", -" & ARRAY_NAME & "_ofs" );
	PUT_LINE(	tab & "LIa" & tab &	", ," & INTEGER'IMAGE( CODI.ADDR_SIZE )	);
	PUT( tab & "Ld" & tab & ", " );
	REGIONS_PATH( EXP_TYPE_NAME );
	if  INDEX_NUM < NB_DIMS  then
	  PUT_LINE( TYPE_NAME_STR & ".SIZ_" & INDEX_NUM_IMG );		-- En bits
	else
	  PUT_LINE( TYPE_NAME_STR & ".COMP_SIZ" );			-- En bits
	end if;

        elsif  USE_TYPE_INFO_DIRECT  then
          PUT( tab & "Ld" & tab & INTEGER'IMAGE( TYPE_LVL ) & ", " );
	REGIONS_PATH( EXP_TYPE_NAME );
	if  INDEX_NUM < NB_DIMS  then
	  PUT_LINE( TYPE_NAME_STR & ".SIZ_" & INDEX_NUM_IMG );		-- En bits
	else
	  PUT_LINE( TYPE_NAME_STR & "._COMP_SIZ" );			-- En bits
	end if;

        else
	PUT( tab & "LId" & tab & LVL_IMG & ", "	& ARRAY_NAME & "__u" & ", " );
	REGIONS_PATH( EXP_TYPE_NAME );
	if  INDEX_NUM < NB_DIMS  then
	  PUT_LINE( TYPE_NAME_STR & ".SIZ_" & INDEX_NUM_IMG );		-- En bits
	else
	  PUT_LINE( TYPE_NAME_STR & ".COMP_SIZ" );			-- En bits
	end if;

        end if;

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

----
      declare
        CNT_SEQ	: SEQ_TYPE	:= LIST( D( AS_EXP_S, INDEXED ) );
        DUMMY	: TREE;
      begin
        while  not IS_EMPTY( CNT_SEQ )  loop
          POP( CNT_SEQ, DUMMY );
          NB_DIMS := NB_DIMS + 1;
        end loop;
      end;
---


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
--    SLICE_COMP_TYPE		: TREE	:= D( SM_COMP_TYPE,	SLICE_TYPE );
--    COMP_SIZE		: INTEGER	:= DI( CD_IMPL_SIZE, SLICE_COMP_TYPE );
    SLICE_ARRAY_TYPE	: TREE	:= SLICE_TYPE;
    SLICE_COMP_TYPE		: TREE;
    COMP_SIZE		: INTEGER;

  begin
    -- Une tranche d'un tableau contraint a souvent pour SM_EXP_TYPE un
    -- DN_CONSTRAINED_ARRAY. Le type composant est alors porte par le
    -- DN_ARRAY de base, pas directement par le subtype contraint.
    if  SLICE_ARRAY_TYPE.TY = DN_CONSTRAINED_ARRAY  then
      SLICE_ARRAY_TYPE := D( SM_BASE_TYPE, SLICE_ARRAY_TYPE );
    end if;

    SLICE_COMP_TYPE := D( SM_COMP_TYPE, SLICE_ARRAY_TYPE );
    COMP_SIZE := DI( CD_IMPL_SIZE, SLICE_COMP_TYPE );

    if  NAME.TY = DN_SELECTED	 then
      CODE_SELECTED( NAME );

    elsif	 NAME.TY = DN_USED_OBJECT_ID	then
      declare
        DEFN		: TREE		:= D( SM_DEFN, NAME	);
        DEFN_LVL		: INTEGER		:= DI( CD_LEVEL, DEFN );
        DEFN_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
        PREFIX_ARRAY_TYPE	: TREE		:= D( SM_EXP_TYPE, NAME );
		---------------------
        procedure	PUT_PREFIX_TYPE_FIELD	( FIELD : STRING )
        is	---------------------
          TYPE_NAME		: TREE		:= D( XD_SOURCE_NAME, PREFIX_ARRAY_TYPE );
          TYPE_NAME_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
        begin
          CODI.REGIONS_PATH( TYPE_NAME );
          PUT( TYPE_NAME_STR & FIELD );
        end	PUT_PREFIX_TYPE_FIELD;
		---------------------
      begin
        if  PREFIX_ARRAY_TYPE.TY = DN_CONSTRAINED_ARRAY  then
          PREFIX_ARRAY_TYPE := D( SM_BASE_TYPE, PREFIX_ARRAY_TYPE );
        end if;

        -- Adresse de début des données du tableau préfixe.
        if  DEFN.TY in CLASS_PARAM_NAME  then
          -- Paramètre composite : le slot -MSG_ofs contient l'adresse du doublet.
          -- On charge le data_ptr, offset 0 du doublet.
          PUT_LINE( tab & "LVA" & tab & IMAGE( DEFN_LVL ) & ", -" & DEFN_STR & "_ofs" );
          PUT_LINE( tab & "LIa" & tab & ", , 0" );
        else
          -- Variable tableau autonome : _disp contient directement data_ptr.
          PUT_LINE( tab & "La " & IMAGE( DEFN_LVL ) & ", " & DEFN_STR & "_disp" );
        end if;

        -- Offset de la borne inférieure de la slice :
        -- @data + (FIRST(slice) - FIRST(prefix)) * component_size
        CODE_EXP( D( AS_EXP1, DISCRETE_RANGE ) );

        if  DEFN.TY in CLASS_PARAM_NAME  then
          -- Paramètre composite : use_info_ptr est à l'offset 8 du doublet.
          PUT_LINE( tab & "LVA" & tab & IMAGE( DEFN_LVL ) & ", -" & DEFN_STR & "_ofs" );
          PUT_LINE( tab & "LIa" & tab & ", ," & INTEGER'IMAGE( CODI.ADDR_SIZE ) );
          PUT( tab & "Ld" & tab & ", " );
          PUT_PREFIX_TYPE_FIELD( ".FST_1" );
          NEW_LINE;
        else
          -- Variable autonome : __u contient use_info_ptr.
          PUT( tab & "LId " & IMAGE( DEFN_LVL ) & ", " & DEFN_STR & "__u" & ", " );
          PUT_PREFIX_TYPE_FIELD( ".FST_1" );
          NEW_LINE;
        end if;

--	PUT_LINE(	tab & "La " & IMAGE( DEFN_LVL	) & ", " & DEFN_STR & "_disp" );
--	CODE_EXP(	D( AS_EXP1, DISCRETE_RANGE ) );
--	PUT_LINE(	tab & "LId " & IMAGE( DEFN_LVL ) & ", " & DEFN_STR & "__u"
--		& ", " & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, SLICE_TYPE ) ) )
--		& ".FST_1" );

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
      CODE_EXP( D( AS_EXP1, DISCRETE_RANGE ) );
      PUT_LINE( tab	& "SUB" );
      PUT_LINE( tab	& "INC" );
      PUT_LINE( tab & "CLAMP0" );
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
        PUT_LINE( "VAR " & "_FST_1, d" );
        PUT_LINE( "VAR " & "_LST_1, d" );

        PUT_LINE( tab & "Sa" & tab & IMAGE( CODI.CUR_LEVEL )  & ", " & ANON_NAME & "_disp" );
        PUT_LINE( tab & "LVA"	&  tab & IMAGE( CODI.CUR_LEVEL )  & ", SIZ" );
        PUT_LINE( tab & "Sa" & tab & IMAGE( CODI.CUR_LEVEL )  & ", " & ANON_NAME & "__u" );
        PUT_LINE( tab & "LI" & tab & IMAGE( COMP_SIZE ) );							-- En bits
        PUT_LINE( tab & "Sd" & tab & IMAGE( CODI.CUR_LEVEL )  & ", COMP_SIZ" );
        CODE_EXP( D( AS_EXP1,	DISCRETE_RANGE ) );
        PUT_LINE( tab & "Sd" & tab & IMAGE( CODI.CUR_LEVEL )  & ", _FST_1" );
        CODE_EXP( D( AS_EXP2,	DISCRETE_RANGE ) );
        PUT_LINE( tab & "Sd" & tab & IMAGE( CODI.CUR_LEVEL )  & ", _LST_1" );

        PUT_LINE( tab & "Ld" & tab & IMAGE( CODI.CUR_LEVEL )  & ", _LST_1" );
        PUT_LINE( tab & "Ld" & tab & IMAGE( CODI.CUR_LEVEL )  & ", _FST_1" );
        PUT_LINE( tab & "SUB"	);
        PUT_LINE( tab & "INC"	);
        PUT_LINE( tab & "CLAMP0" );
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
	else
		-- Variable COMPOSITE nommee a travers un prefixe package
		-- (PACK1.ARG1.<champs>) : pousser le data_ptr, base de la
		-- chaine de selection.  Chemin absolu obligatoire : la
		-- variable vit dans le namespace du package, la reference
		-- vient d'ailleurs.
	  PUT( tab & "La " & IMAGE( DI( CD_LEVEL, DESIGNATOR_DEFN ) ) & ", " );
	  REGIONS_PATH( DESIGNATOR_DEFN );
	  PUT_LINE( DESIGNATOR_STR & "_disp" );
	end if;

        elsif  DESIGNATOR_DEFN.TY = DN_COMPONENT_ID  or else  DESIGNATOR_DEFN.TY = DN_DISCRIMINANT_ID  then

	if  IS_SOURCE  and then  REPRESENTED_ITEMS.HAS_COMPONENT_REP( DESIGNATOR_DEFN )  then

	  if  NAME.TY = DN_USED_OBJECT_ID  then

	    if  D( SM_DEFN, NAME ).TY in CLASS_PARAM_NAME  then
	        -- Paramètre composite : le paramètre contient l'adresse
	        -- du doublet {data_ptr,use_info_ptr}.
	      PUT_LINE( tab & "La " & IMAGE( DI( CD_LEVEL, D( SM_DEFN, NAME ) ) ) & ", "
			& '-' & PRINT_NAME( D( LX_SYMREP, NAME ) ) & "_ofs" );

	        -- Extraction de data_ptr depuis le doublet.
	      PUT_LINE( tab & "La" & tab & "-1, 0" );

	    else
	        -- Objet record autonome : NAME_disp contient directement
	        -- le pointeur vers les données.
	      PUT_LINE( tab & "La" & tab & IMAGE( DI( CD_LEVEL, D( SM_DEFN, NAME ) ) ) & ", "
			& PRINT_NAME( D( LX_SYMREP, NAME ) ) & "_disp" );
	    end if;

	  else
	      -- NAME est déjà un préfixe composite calculé par :
	      --   RECURSE_SELECTED(NAME)
	      -- ou
	      --   CODE_INDEXED(NAME)
	      --
	      -- Dans ce cas l'adresse des données est déjà au sommet de pile.
	    null;
	  end if;

	  REPRESENTED_ITEMS.CODE_LOAD_REP_COMPONENT( DESIGNATOR_DEFN );
	  return;
	end if;

	if  NAME.TY = DN_USED_OBJECT_ID  then

	  if  D( SM_DEFN,	NAME ).TY	in  CLASS_PARAM_NAME  then
	    PUT_LINE( tab	& "La "
		& IMAGE( DI( CD_LEVEL, D( SM_DEFN, NAME	) ) ) & ", "
		& '-' & PRINT_NAME(	D(LX_SYMREP, NAME )	) & "_ofs" );

	    if  ( D( SM_EXP_TYPE, DESIGNATOR ).TY in CLASS_SCALAR
			  or else D( SM_EXP_TYPE, DESIGNATOR ).TY = DN_ACCESS )
			  and  IS_SOURCE  then
	      PUT( tab & "LI" & OPER_SIZ_CHAR( D( SM_EXP_TYPE, DESIGNATOR )	) );

	    else
	      PUT( tab & "LIVA " );
	    end	if;

	    PUT( tab & ", 0, " );
	    REGIONS_PATH(	DESIGNATOR_DEFN );
	    PUT_LINE( DESIGNATOR_STR );

	  else
	    if	( D( SM_EXP_TYPE, DESIGNATOR ).TY in CLASS_SCALAR
			  or else D( SM_EXP_TYPE, DESIGNATOR ).TY = DN_ACCESS )
			  and  IS_SOURCE  then
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
	  if  ( D( SM_EXP_TYPE, DESIGNATOR ).TY in CLASS_SCALAR
		   or else D( SM_EXP_TYPE, DESIGNATOR ).TY = DN_ACCESS )
		   and  IS_SOURCE  then
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
	if CODI.DEBUG  then  PUT( tab50 & "; lieu resultat sur pile" ); end if;
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

      elsif  NAME.TY = DN_ALL  then
        CODE_OBJECT_ADDRESS( NAME );
        PROCESS_DESIGNATOR;

      elsif  NAME.TY = DN_USED_OBJECT_ID  then
--        declare
--	DEFN		: TREE		:= D( SM_DEFN, NAME	);
--	OBJ_TYPE		: TREE		:= D( SM_OBJ_TYPE, DEFN );
--	OBJ_LEVEL		: INTEGER		:= DI( CD_LEVEL, DEFN );
--	OBJ_NAME_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
--        begin
--	if  D( SM_EXP_TYPE,	NAME ).TY	in CLASS_SCALAR
--		  or else D( SM_EXP_TYPE, NAME ).TY = DN_ACCESS  then
--	  PUT_LINE( tab & "L" & OPER_SIZ_CHAR( DEFN ) & tab & IMAGE( OBJ_LEVEL ) & ", "	& OBJ_NAME_STR  );
--	end if;
--        end;

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
--      PUT_LINE( "; CODE_OBJECT_ADDRESS: renames slice a traiter plus tard" );
--      raise PROGRAM_ERROR;
      -- Adresse brute du premier composant de la tranche.
      -- CODE_SLICE en mode destination laisse : @data_slice, taille_octets.
      -- Pour un calcul d'adresse d'objet, on conserve seulement @data_slice.
      CODE_SLICE( NAME, IS_DESTINATION => TRUE );
      PUT_LINE( tab & "DROP" );

    when DN_ALL =>
      CODE_EXP( D( AS_NAME, NAME ) );							-- valeur access = @objet designe

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


			------------------------
  function		IS_GENERIC_FORMAL_OBJECT	( DEFN : TREE )	return BOOLEAN
  is			------------------------

    REGION_ID	: TREE;

  begin
    if  not (DEFN.TY in CLASS_PARAM_NAME)  then
      return FALSE;
    end if;

    REGION_ID := D( XD_REGION, DEFN );

    if  REGION_ID.TY /= DN_GENERIC_ID  then
      return  FALSE;
    end if;

    declare
      G_PARAMS	: SEQ_TYPE	:= LIST( D( SM_GENERIC_PARAM_S, REGION_ID ) );
      G_PARAM	: TREE;
    begin
      while not IS_EMPTY( G_PARAMS ) loop
        POP( G_PARAMS, G_PARAM );

        if G_PARAM.TY = DN_IN  or else  G_PARAM.TY = DN_IN_OUT  or else  G_PARAM.TY = DN_OUT  then
	declare
	  ID_SEQ	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, G_PARAM ) );
	  ID	: TREE;
	begin
	  while  not IS_EMPTY( ID_SEQ )  loop
	    POP( ID_SEQ, ID );

	    if  ID = DEFN  then
	      return  TRUE;
	    end if;
	  end loop;
	end;
        end if;
      end loop;
    end;

    return  FALSE;

  end	IS_GENERIC_FORMAL_OBJECT;
	------------------------

		----------------------------
  function	IS_GENERIC_FORMAL_SUBPROGRAM		( ID : TREE )	return BOOLEAN
  is		----------------------------
     GSEQ		: SEQ_TYPE;
     FORMAL	: TREE;
  begin
    if  not CODI.IN_GENERIC_BODY  or else  CODI.ENCLOSING_GENERIC = TREE_VOID  then
      return  FALSE;
    end if;

    GSEQ := LIST( D( SM_GENERIC_PARAM_S, CODI.ENCLOSING_GENERIC ) );

    while  not IS_EMPTY( GSEQ )  loop
      POP( GSEQ, FORMAL );

      if  FORMAL.TY = DN_SUBPROG_ENTRY_DECL  and then  D( AS_SOURCE_NAME, FORMAL ) = ID  then
        return  TRUE;
      end if;
    end loop;

    return  FALSE;

  end	IS_GENERIC_FORMAL_SUBPROGRAM;
	----------------------------


		-----------------
    function	IS_BASE_ATTRIBUTE		( A : TREE )	return BOOLEAN
    is		-----------------
    begin
      if  A.TY = DN_ATTRIBUTE  then
        declare
          A_NAME	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, D( AS_USED_NAME_ID, A ) ) );
        begin
          return  A_NAME = "BASE";
        end;
      end if;

      return FALSE;

    end	IS_BASE_ATTRIBUTE;
	-----------------

		----------------------
    function	NORMALIZED_PREFIX_NAME	( RAW_PREFIX :TREE ) 	return TREE
    is		----------------------
    begin
      if  IS_BASE_ATTRIBUTE( RAW_PREFIX )  then
        return  LAST_OF_SELECTED( D( AS_NAME, RAW_PREFIX ) );
      else
        return  LAST_OF_SELECTED( RAW_PREFIX );
      end if;

    end	NORMALIZED_PREFIX_NAME;
	----------------------


				--------------
  procedure			CODE_ATTRIBUTE		( ATTRIBUTE :TREE )
  is				--------------

    RAW_PREFIX		: TREE		:= D( AS_NAME, ATTRIBUTE );
    CHN_ATTR_NAME		: constant STRING	:= PRINT_NAME( D( LX_SYMREP, D( AS_USED_NAME_ID, ATTRIBUTE ) ) );

    PREFIX_NAME		: TREE		:= NORMALIZED_PREFIX_NAME( RAW_PREFIX );
    PREFIX_HAS_BASE		: BOOLEAN		:= IS_BASE_ATTRIBUTE( RAW_PREFIX );
    CHN_PREFIX		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, PREFIX_NAME ) );
    subtype CHN_STD		is STRING( 1 .. CHN_ATTR_NAME'LENGTH );
    CHN_ATTR		: CHN_STD		:= CHN_ATTR_NAME;						-- NORMALISER EN STRING A FIRST=1

		----------------
    function	PREFIX_TYPE_SPEC	return TREE
    is		----------------
      PREFIX_DEFN : TREE := D( SM_DEFN, PREFIX_NAME );
      TYPE_SPEC   : TREE := TREE_VOID;
    begin
      if  PREFIX_DEFN.TY in CLASS_TYPE_NAME  then
        TYPE_SPEC := D( SM_TYPE_SPEC, PREFIX_DEFN );

      elsif  PREFIX_DEFN.TY in CLASS_OBJECT_NAME  then
        TYPE_SPEC := D( SM_OBJ_TYPE, PREFIX_DEFN );

      else
        return  TREE_VOID;
      end if;

      if  TYPE_SPEC /= TREE_VOID  then
        if  TYPE_SPEC.TY = DN_PRIVATE  or else  TYPE_SPEC.TY = DN_L_PRIVATE  then
          TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
        end if;

        if  PREFIX_HAS_BASE  then
          case  TYPE_SPEC.TY  is
            when DN_INTEGER
               | DN_ENUMERATION
               | DN_FLOAT
               | DN_FIXED
               | DN_CONSTRAINED_ARRAY
               | DN_CONSTRAINED_RECORD
               | DN_CONSTRAINED_ACCESS =>
              TYPE_SPEC := D( SM_BASE_TYPE, TYPE_SPEC );

            when others =>
              null;
          end case;
        end if;
      end if;

      return  TYPE_SPEC;

    end	PREFIX_TYPE_SPEC;
	----------------

		----------
    function	FLOAT_BITS	return INTEGER
    is		----------
      T : TREE := PREFIX_TYPE_SPEC;
    begin
      if T /= TREE_VOID and then T.TY = DN_FLOAT then
        if DI( CD_IMPL_SIZE, T ) <= 32 then
          return 32;
        else
          return 64;
        end if;
      end if;

      return 64;

    end	FLOAT_BITS;
	----------

    procedure PUSH_INT ( I : INTEGER )
    is
    begin
      PUT_LINE( tab & "LI" & tab & INTEGER'IMAGE( I ) );
    end PUSH_INT;


    procedure PUSH_FLOAT_LITERAL ( S : STRING )
    is
    begin
      PUT_LINE( tab & "LIF" & tab & S );
    end PUSH_FLOAT_LITERAL;


    procedure CODE_FLOAT_DIGITS
    is
    begin
      if FLOAT_BITS <= 32 then
        PUSH_INT( 6 );
      else
        PUSH_INT( 15 );
      end if;
    end CODE_FLOAT_DIGITS;


    procedure CODE_FLOAT_MANTISSA
    is
    begin
      if FLOAT_BITS <= 32 then
        PUSH_INT( 24 );
      else
        PUSH_INT( 53 );
      end if;
    end CODE_FLOAT_MANTISSA;


    procedure CODE_FLOAT_EPSILON
    is
    begin
      if FLOAT_BITS <= 32 then
        PUSH_FLOAT_LITERAL( "1.1920928955078125E-7" );
      else
        PUSH_FLOAT_LITERAL( "2.2204460492503131E-16" );
      end if;
    end CODE_FLOAT_EPSILON;


    procedure CODE_FLOAT_EMAX
    is
    begin
      if FLOAT_BITS <= 32 then
        PUSH_INT( 128 );
      else
        PUSH_INT( 1024 );
      end if;
    end CODE_FLOAT_EMAX;


    procedure CODE_FLOAT_EMIN
    is
    begin
      if FLOAT_BITS <= 32 then
        PUSH_INT( -125 );
      else
        PUSH_INT( -1021 );
      end if;
    end CODE_FLOAT_EMIN;


    procedure CODE_FLOAT_SMALL
    is
    begin
      if FLOAT_BITS <= 32 then
        PUSH_FLOAT_LITERAL( "1.1754943508222875E-38" );
      else
        PUSH_FLOAT_LITERAL( "2.2250738585072014E-308" );
      end if;
    end CODE_FLOAT_SMALL;


    procedure CODE_FLOAT_LARGE
    is
    begin
      if FLOAT_BITS <= 32 then
        PUSH_FLOAT_LITERAL( "3.4028234663852886E38" );
      else
        PUSH_FLOAT_LITERAL( "1.7976931348623157E308" );
      end if;
    end CODE_FLOAT_LARGE;


		------------
    procedure	CODE_ADDRESS
    is		------------
    begin
      if  CODI.IN_GENERIC_BODY  and then  RAW_PREFIX.TY = DN_USED_OBJECT_ID  then
				-----------------
				OBJECT_IN_GENERIC:
        declare
	PREFIX_DEFN : TREE := D( SM_DEFN, RAW_PREFIX );
        begin
	if  PREFIX_DEFN.TY in CLASS_PARAM_NAME  then
				----------------
				PARAM_IN_GENERIC:
	  declare
	    PREFIX_LVL : INTEGER := DI( CD_LEVEL, PREFIX_DEFN );
	    TYPE_SPEC  : TREE    := D( SM_OBJ_TYPE, PREFIX_DEFN );
	    TYPE_NAME  : TREE    := D( XD_SOURCE_NAME, TYPE_SPEC );
	    TYPE_STR   : constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	  begin

	    if  IS_GENERIC_FORMAL_TYPE( TYPE_NAME )  then

	      if  PREFIX_DEFN.TY = DN_IN_ID  then
	        PUT_LINE( tab & "LVA"	& tab & IMAGE( PREFIX_LVL ) & ", -" & CHN_PREFIX & "_ofs" );
	        PUT_LINE( tab & "La " & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & "-GFP_ofs" );
	        PUT_LINE( tab & "La" & tab & ", -" & TYPE_STR & "__inadr_ofs" );				-- Conversion pout IN

	      elsif  PREFIX_DEFN.TY  in  CLASS_PARAM_IO_O  then
	        PUT_LINE( tab & "LVA"	& tab & IMAGE( PREFIX_LVL ) & ", -" & CHN_PREFIX & "_ofs" );
	        PUT_LINE( tab & "La " & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & "-GFP_ofs" );
	        PUT_LINE( tab & "La" & tab & ", -" & TYPE_STR & "__outadr_ofs" );				-- Conversion pour OUT ou IN_OUT

	      else
	        CODE_OBJECT_ADDRESS( RAW_PREFIX );
	        return;

	      end if;

	      PUT_LINE( tab & "CALLI" );
	      return;
	    end if;
            end		PARAM_IN_GENERIC;
			----------------
          end if;
        end	OBJECT_IN_GENERIC;
		-----------------
      end if;

      -- Cas général : ne pas utiliser PREFIX_NAME ici.
      -- Pour C3.Y'ADDRESS, RAW_PREFIX est encore le DN_SELECTED complet.
      CODE_OBJECT_ADDRESS( RAW_PREFIX );

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

        when DN_CONSTRAINED_RECORD =>							-- pilier 3.7 : objet contraint
	  PUT_LINE( tab & "LI" & tab & "1" );

        when DN_RECORD =>
		-- RM83 3.7.4 : X'CONSTRAINED, decidable statiquement par objet.
		-- Variable NON contrainte d'un type a defauts (mutable) -> FALSE ;
		-- constante -> TRUE ; type sans discriminants -> TRUE (une variable
		-- non contrainte d'un type a discriminants SANS defauts est illegale).
		-- Formels : la valeur exacte suit l'ACTUEL.  Sans defauts, tout
		-- actuel est necessairement contraint -> TRUE exact.  Avec defauts,
		-- approximation statique FALSE, commentee dans le FINC (precedent
		-- des conventions provisoires d'attributs ; exige par les A-tests
		-- ACVC -- A62006D applique l'attribut dans un corps jamais appele).
	  declare
	    HAS_DEFAULTS	: BOOLEAN	:= FALSE;
	    IS_FORMAL	: BOOLEAN	:= PREFIX_DEFN.TY = DN_IN_ID
					or PREFIX_DEFN.TY = DN_IN_OUT_ID
					or PREFIX_DEFN.TY = DN_OUT_ID;
	    DSCRMT_DECL_S	: SEQ_TYPE	:= LIST( D( SM_DISCRIMINANT_S, TYPE_SPEC ) );
	    DSCRMT_DECL	: TREE;
	  begin
	    while  not IS_EMPTY( DSCRMT_DECL_S )  loop
	      POP( DSCRMT_DECL_S, DSCRMT_DECL );

	      declare
	        DISCR_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, DSCRMT_DECL ) );
	        DISCR_ID	: TREE;
	      begin
	        while  not IS_EMPTY( DISCR_ID_S )  loop
	          POP( DISCR_ID_S, DISCR_ID );

	          if  D( SM_INIT_EXP, DISCR_ID ) /= TREE_VOID
	            and then  D( SM_INIT_EXP, DISCR_ID ) /= TREE_NIL
	          then
	            HAS_DEFAULTS := TRUE;
	          end if;
	        end loop;
	      end;
	    end loop;

	    if  not HAS_DEFAULTS  then
	      PUT_LINE( tab & "LI" & tab & "1" );					-- exact, formel compris
	    elsif  IS_FORMAL  then
	      PUT_LINE( "; ATTRIBUTE CONSTRAINED formel mutable : approximation statique FALSE"
			& " (valeur exacte = celle de l'actuel)" );
	      PUT_LINE( tab & "LI" & tab & "0" );
	    elsif  PREFIX_DEFN.TY = DN_VARIABLE_ID  then
	      PUT_LINE( tab & "LI" & tab & "0" );					-- variable mutable non contrainte
	    else
	      PUT_LINE( tab & "LI" & tab & "1" );					-- constante
	    end if;
	  end;

        when DN_CONSTRAINED_ARRAY
	   | DN_INTEGER
	   | DN_FLOAT
	   | DN_ENUMERATION
	   | DN_ACCESS =>
	  PUT_LINE( tab & "LI" & tab & "1" );

        when others =>
	  PUT_LINE( "; ATTRIBUTE CONSTRAINED : TYPE NON TRAITE "
	          & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
	  PUT_LINE( tab & "LI" & tab & "0" );
        end case;
      end if;

    end	CODE_CONSTRAINED;
	----------------


		------------------------------
    procedure	CODE_SCALAR_SUBTYPE_FIRST_LAST	( SUBTYPE_ID :TREE; TYPE_SPEC  :TREE; IS_LAST :BOOLEAN )
    is		------------------------------
      SUBTYPE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, SUBTYPE_ID ) );
      TYPE_LVL	: INTEGER		:= DI( CD_LEVEL, TYPE_SPEC );
      SIZ_CHAR	: CHARACTER	:= OPER_SIZ_CHAR( TYPE_SPEC );
    begin
      PUT( tab & 'L' & SIZ_CHAR & tab & IMAGE( TYPE_LVL ) & ", " );

      if  TYPE_LVL /= INTEGER( CODI.CUR_LEVEL )  or else  D( XD_REGION, SUBTYPE_ID ).TY = DN_PACKAGE_ID  then
        REGIONS_PATH( SUBTYPE_ID );
      end if;

      PUT( SUBTYPE_STR & "." );

      if  IS_LAST  then
        PUT_LINE( "LST" );
      else
        PUT_LINE( "FST" );
      end if;

    end	CODE_SCALAR_SUBTYPE_FIRST_LAST;
	------------------------------

		---------------
    procedure	CODE_FIRST_LAST	( IS_LAST	:BOOLEAN )
    is		---------------
      PREFIX_DEFN		: TREE		:= D( SM_DEFN, PREFIX_NAME );
      PREFIX_LVL		: INTEGER;

    begin

      if	PREFIX_NAME.TY = DN_USED_OBJECT_ID  then

     if  PREFIX_DEFN.TY = DN_COMPONENT_ID  then
        declare
	PARENT_TYPE_SPEC	: TREE	:= D( SM_TYPE_SPEC, D( XD_REGION, PREFIX_DEFN ) );
        begin
          PREFIX_LVL := DI( CD_LEVEL, PARENT_TYPE_SPEC );
        end;
      else
        PREFIX_LVL := DI( CD_LEVEL, PREFIX_DEFN );
      end if;

declare
  PREFIX_TYPE : TREE := D( SM_EXP_TYPE, PREFIX_NAME );
begin
  while PREFIX_TYPE.TY = DN_PRIVATE or else PREFIX_TYPE.TY = DN_L_PRIVATE loop
    PREFIX_TYPE := D( SM_TYPE_SPEC, PREFIX_TYPE );
  end loop;

  if  PREFIX_TYPE.TY = DN_ACCESS  then
    declare
      DESIG_TYPE : TREE := D( SM_DESIG_TYPE, PREFIX_TYPE );
    begin
      while DESIG_TYPE.TY = DN_PRIVATE or else DESIG_TYPE.TY = DN_L_PRIVATE loop
        DESIG_TYPE := D( SM_TYPE_SPEC, DESIG_TYPE );
      end loop;

      if  DESIG_TYPE.TY = DN_INCOMPLETE  then
        DESIG_TYPE := D( XD_FULL_TYPE_SPEC, DESIG_TYPE );
      end if;

      if  DESIG_TYPE.TY = DN_CONSTRAINED_ARRAY or else DESIG_TYPE.TY = DN_ARRAY  then
        declare
          TYPE_NAME : TREE := D( XD_SOURCE_NAME, DESIG_TYPE );
          TYPE_STR  : constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
          TYPE_LVL  : INTEGER := DI( CD_LEVEL, DESIG_TYPE );
          DIM_EXP   : TREE := D( AS_EXP, ATTRIBUTE );
          NUM_DIM   : INTEGER := 1;
        begin
          if DIM_EXP /= TREE_VOID then
            NUM_DIM := DI( SM_VALUE, DIM_EXP );
          end if;

          PUT( tab & "Ld" & tab & IMAGE( TYPE_LVL ) & ", " );
          REGIONS_PATH( TYPE_NAME );
          PUT( TYPE_STR );

          if IS_LAST then
            PUT( "._LST_" );
          else
            PUT( "._FST_" );
          end if;

          PUT_LINE( IMAGE( NUM_DIM ) );
          return;
        end;
      end if;
    end;
  end if;
end;


        if  ( D( SM_EXP_TYPE,	PREFIX_NAME ).TY = DN_CONSTRAINED_ARRAY	)					-- UNE VARIABLE TABLEAU
	or ( D( SM_EXP_TYPE, PREFIX_NAME ).TY = DN_ARRAY  and  D( SM_DEFN, PREFIX_NAME ).TY = DN_CONSTANT_ID )
	or ( D( SM_EXP_TYPE, PREFIX_NAME ).TY = DN_ARRAY  and  D( SM_DEFN, PREFIX_NAME ).TY = DN_VARIABLE_ID )	-- variable non contrainte (SC : STRING := "..") : __u -> descripteur local a bornes reelles
        then
	declare
	  ARRAY_LVL	: INTEGER		:= PREFIX_LVL;
	  PREFIX_TYPE	: TREE		:= D( SM_EXP_TYPE, PREFIX_NAME );
	  TYPE_STR	:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, PREFIX_TYPE ) ) );
	  DIM_EXP		: TREE		:= D( AS_EXP, ATTRIBUTE );
	  NUM_DIM		: INTEGER		:= 1;
	begin
	  if DIM_EXP /= TREE_VOID then
	    NUM_DIM := DI( SM_VALUE, DIM_EXP );
	  end if;

	  PUT( tab & "LId" & tab & IMAGE( ARRAY_LVL ) & ", " );
	  REGIONS_PATH( D( SM_DEFN, PREFIX_NAME ) );
	  PUT( CHN_PREFIX & "__u" & ", " );
	  REGIONS_PATH( D( XD_SOURCE_NAME, PREFIX_TYPE ) );
	  PUT( TYPE_STR );
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
	  ARRAY_LVL	: INTEGER		:= PREFIX_LVL;
	  PREFIX_TYPE	: TREE		:= D( SM_EXP_TYPE, PREFIX_NAME );
	  TYPE_STR	:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, PREFIX_TYPE	) ) );
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
        if  PREFIX_DEFN.TY in CLASS_TYPE_NAME  then

	if  CODI.IN_GENERIC_BODY  and then  IS_GENERIC_FORMAL_TYPE( PREFIX_DEFN )  then

				------------------
				GENERIC_FIRST_LAST:
	  declare
	    CHN_LID	:constant	STRING
			 := tab & "LId , -" & CHN_PREFIX & "__u_ofs, STANDARD._ENUM_USE_INFO";

	  begin
	    PUT_LINE( tab & "La " & IMAGE( CODI.GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
	    if  IS_LAST  then
	      PUT_LINE( CHN_LID & ".LST" );
	    else
	      PUT_LINE( CHN_LID & ".FST" );
	    end if;

	  end	GENERIC_FIRST_LAST;
		------------------
	else
				-----------------
				NORMAL_FIRST_LAST:
	  declare
	    TYPE_SPEC	: TREE	:= PREFIX_TYPE_SPEC;
	  begin

	    if  TYPE_SPEC.TY = DN_FLOAT  then
	      declare
	        TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
	        TYPE_STR	: constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	        TYPE_LVL	: INTEGER		:= DI( CD_LEVEL, TYPE_SPEC );
	      begin
	        PUT( tab & "Lq" & tab & IMAGE( TYPE_LVL ) & ", " );

	        if  TYPE_LVL /= INTEGER( CODI.CUR_LEVEL )  or else  D( XD_REGION, TYPE_NAME ).TY = DN_PACKAGE_ID
	        then
		REGIONS_PATH( TYPE_NAME );
	        end if;

	        PUT( TYPE_STR & "." );
	        if  IS_LAST  then
		PUT_LINE( "LST" );
	        else
		PUT_LINE( "FST" );
	        end if;
	      end;

	    elsif PREFIX_DEFN.TY = DN_SUBTYPE_ID  and then
		( TYPE_SPEC.TY = DN_INTEGER  or else  TYPE_SPEC.TY = DN_ENUMERATION
		  or else  TYPE_SPEC.TY = DN_FIXED )  then
	      CODE_SCALAR_SUBTYPE_FIRST_LAST( SUBTYPE_ID=> PREFIX_DEFN, TYPE_SPEC=> TYPE_SPEC, IS_LAST=> IS_LAST );

	    else
	      declare
	        PREFIX_TS	: TREE	:= D( SM_TYPE_SPEC, PREFIX_DEFN );
	        TYPE_RANGE	: TREE;
	      begin
	        -- Marque de sous-type de tableau CONTRAINT (VEC5'FIRST/'LAST) :
	        -- le DN_CONSTRAINED_ARRAY ne porte pas SM_RANGE.  Les bornes sont
	        -- dans les sous-types d'indice (SM_INDEX_SUBTYPE_S), qui portent
	        -- chacun SM_RANGE (meme idiome que CODE_RANGE_ATTRIBUTE_BOUND, D9,
	        -- et que les sites 3872/4078).  Dimension voulue = AS_EXP de
	        -- l'attribut (defaut 1).
	        if  PREFIX_TS.TY = DN_CONSTRAINED_ARRAY  then
	          declare
	            DIM_EXP	: TREE		:= D( AS_EXP, ATTRIBUTE );
	            NUM_DIM	: INTEGER		:= 1;
	            IDX_S	: SEQ_TYPE	:= LIST( D( SM_INDEX_SUBTYPE_S, PREFIX_TS ) );
	            IDX_TYPE	: TREE;
	          begin
	            if  DIM_EXP /= TREE_VOID  then
	              NUM_DIM := DI( SM_VALUE, DIM_EXP );
	            end if;
	            for K in 1 .. NUM_DIM  loop			-- avancer jusqu'a la dimension
	              POP( IDX_S, IDX_TYPE );
	            end loop;
	            TYPE_RANGE := D( SM_RANGE, IDX_TYPE );
	          end;
	        else
	          TYPE_RANGE := D( SM_RANGE, PREFIX_TS );	-- scalaires : comportement d'origine
	        end if;

	        PUT( tab & "LI" & tab );
	        if  IS_LAST  then
		PUT_LINE( PRINT_NUM( D( SM_VALUE, D( AS_EXP2, TYPE_RANGE ) ) ) );
	        else
		PUT_LINE( PRINT_NUM( D( SM_VALUE, D( AS_EXP1, TYPE_RANGE ) ) ) );
	        end if;
	      end;
	    end if;
--	    else
--	      declare
--	        TYPE_RANGE	: TREE	:= D( SM_RANGE, D( SM_TYPE_SPEC, PREFIX_DEFN ) );
--	      begin
--	        PUT( tab & "LI" & tab );
--	        if  IS_LAST  then
--		PUT_LINE( PRINT_NUM( D( SM_VALUE, D( AS_EXP2, TYPE_RANGE ) ) ) );
--	        else
--		PUT_LINE( PRINT_NUM( D( SM_VALUE, D( AS_EXP1, TYPE_RANGE ) ) ) );
--	        end if;
--	      end;
--	    end if;

	  end		NORMAL_FIRST_LAST;
			-----------------
	end if;
        end if;
      end	if;

    end	CODE_FIRST_LAST;
	---------------

		----------
    procedure	CODE_IMAGE
    is		----------
--      ARG		: TREE		:= D( AS_EXP, ATTRIBUTE );
--      ANON		:constant STRING	:= ANONYMOUS_NAME_AT( ATTRIBUTE );
--      LVL_STR		:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
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
      PUT_LINE( tab & "CALL" & tab & "STANDARD. ,INTEGER_IMAGE_L11" );

      -- Résultat de l'expression : adresse du doublet.
--      PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );

    end	CODE_IMAGE;
	----------

		-----------
    procedure	CODE_LENGTH
    is		-----------

--      PREFIX_TYPE		: TREE		:= D( SM_EXP_TYPE, PREFIX_NAME );				-- Un tableau
--      PREFIX_DEFN		: TREE		:= D( SM_DEFN, PREFIX_NAME );

--    begin

      PREFIX_DEFN		: TREE		:= D( SM_DEFN, PREFIX_NAME );					-- toujours present
      PREFIX_TYPE		: TREE		:= TREE_VOID;						-- differe : marque de type -> pas de SM_EXP_TYPE

    begin
      -- 'LENGTH d'une MARQUE de sous-type de tableau CONTRAINT (VEC5'LENGTH).
      -- Le prefixe designe un type, pas un objet : il ne porte pas SM_EXP_TYPE,
      -- et la longueur est STATIQUE.  On la calcule ici (LST - FST + 1, borne a 0
      -- par CLAMP0) depuis les sous-types d'indice, meme idiome que C-U1
      -- (CODE_FIRST_LAST) et CODE_RANGE_ATTRIBUTE_BOUND.  Sortie anticipee AVANT
      -- toute lecture de SM_EXP_TYPE.
      if  PREFIX_DEFN.TY = DN_SUBTYPE_ID  or else  PREFIX_DEFN.TY = DN_TYPE_ID  then
        declare
          TS	: TREE	:= D( SM_TYPE_SPEC, PREFIX_DEFN );
        begin
          if  TS.TY = DN_CONSTRAINED_ARRAY  then
            declare
              DIM_EXP	: TREE		:= D( AS_EXP, ATTRIBUTE );
              NUM_DIM	: INTEGER		:= 1;
              IDX_S	: SEQ_TYPE	:= LIST( D( SM_INDEX_SUBTYPE_S, TS ) );
              IDX_TYPE	: TREE;
              RNG	: TREE;
              LO, HI_B	: INTEGER;
              LEN	: INTEGER;
            begin
              if  DIM_EXP /= TREE_VOID  then
                NUM_DIM := DI( SM_VALUE, DIM_EXP );
              end if;
              for K in 1 .. NUM_DIM  loop
                POP( IDX_S, IDX_TYPE );
              end loop;
              RNG   := D( SM_RANGE, IDX_TYPE );
              LO    := DI( SM_VALUE, D( AS_EXP1, RNG ) );
              HI_B  := DI( SM_VALUE, D( AS_EXP2, RNG ) );
              LEN   := HI_B - LO + 1;
              if  LEN < 0  then  LEN := 0;  end if;			-- intervalle nul
              PUT_LINE( tab & "LI" & tab & IMAGE( LEN ) );
              return;
            end;
          end if;
        end;
      end if;

      PREFIX_TYPE := D( SM_EXP_TYPE, PREFIX_NAME );				-- prefixe = objet : chemin d'origine


		-- Cas Ada 83 : attribut LENGTH sur une valeur access-to-array.
		-- A1'LENGTH est implicitement A1.all'LENGTH.
		-- A1 est scalaire access : pas de A1__u.
      declare
        PTYPE : TREE := D( SM_EXP_TYPE, PREFIX_NAME );
      begin
        while  PTYPE.TY = DN_PRIVATE or else PTYPE.TY = DN_L_PRIVATE  loop
	PTYPE := D( SM_TYPE_SPEC, PTYPE );
        end loop;

        if  PTYPE.TY = DN_ACCESS  then
	declare
	  DESIG_TYPE : TREE := D( SM_DESIG_TYPE, PTYPE );
	begin
	  while  DESIG_TYPE.TY = DN_PRIVATE or else DESIG_TYPE.TY = DN_L_PRIVATE  loop
	    DESIG_TYPE := D( SM_TYPE_SPEC, DESIG_TYPE );
	  end loop;

	  if  DESIG_TYPE.TY = DN_INCOMPLETE  then
	    DESIG_TYPE := D( XD_FULL_TYPE_SPEC, DESIG_TYPE );
	  end if;

	  if  DESIG_TYPE.TY = DN_CONSTRAINED_ARRAY  or else  DESIG_TYPE.TY = DN_ARRAY  then
	    declare
	      TYPE_NAME : TREE := D( XD_SOURCE_NAME, DESIG_TYPE );
	      TYPE_STR  : constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	      TYPE_LVL  : INTEGER := DI( CD_LEVEL, DESIG_TYPE );
	      DIM_EXP   : TREE := D( AS_EXP, ATTRIBUTE );
	      NUM_DIM   : INTEGER := 1;
	    begin
	      if  DIM_EXP /= TREE_VOID  then
	        NUM_DIM := DI( SM_VALUE, DIM_EXP );
	      end if;

	      PUT( tab & "Ld" & tab & IMAGE( TYPE_LVL ) & ", " );
	      REGIONS_PATH( TYPE_NAME );
	      PUT_LINE( TYPE_STR & "._LST_" & IMAGE( NUM_DIM ) );

	      PUT( tab & "Ld" & tab & IMAGE( TYPE_LVL ) & ", " );
	      REGIONS_PATH( TYPE_NAME );
	      PUT_LINE( TYPE_STR & "._FST_" & IMAGE( NUM_DIM ) );

	      PUT_LINE( tab & "SUB" );
	      PUT_LINE( tab & "INC" );
	      PUT_LINE( tab & "CLAMP0" );
	      return;
	    end;
	  end if;
	end;
        end if;
      end;

      if  PREFIX_DEFN.TY = DN_COMPONENT_ID  then
        PREFIX_DEFN := D( SM_OBJ_TYPE, PREFIX_DEFN );
      end if;

      declare
        ARRAY_LVL		: INTEGER		:= DI( CD_LEVEL, PREFIX_DEFN );
        PREFIX_TYPE_STR	:constant	STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, PREFIX_TYPE ) ) );
        DIM_EXP		: TREE		:= D( AS_EXP, ATTRIBUTE );
        NUM_DIM		: INTEGER		:= 1;
     begin
        if  DIM_EXP /= TREE_VOID  then
          NUM_DIM := DI( SM_VALUE, DIM_EXP );
        end if;

        if  PREFIX_DEFN.TY in CLASS_PARAM_NAME  then							-- On a juste l'adresse de la	VAR disp

	PUT_LINE( tab & "LVA" & tab & IMAGE( ARRAY_LVL ) & ", -" & CHN_PREFIX & "_ofs" );
	PUT_LINE( tab & "LIa" & tab & ", ," & INTEGER'IMAGE( CODI.ADDR_SIZE ) );
	PUT_LINE( tab & "Ld" & tab & ", " & PREFIX_TYPE_STR & ".LST_" & IMAGE( NUM_DIM ) );			-- Offset LST_n
	PUT_LINE( tab & "LVA" & tab & IMAGE( ARRAY_LVL ) & ", -" & CHN_PREFIX & "_ofs" );
	PUT_LINE( tab & "LIa" & tab & ", ," & INTEGER'IMAGE( CODI.ADDR_SIZE ) );
	PUT_LINE( tab & "Ld" & tab & ", " & PREFIX_TYPE_STR & ".FST_" & IMAGE( NUM_DIM ) );			-- Offset FST_n
	PUT_LINE( tab & "SUB" );
	PUT_LINE( tab & "INC" );
	PUT_LINE( tab & "CLAMP0" );

        else
	PUT( tab & "LId" & tab & IMAGE( ARRAY_LVL ) & ", " );
	REGIONS_PATH( D( SM_DEFN, PREFIX_NAME ) );
	PUT( CHN_PREFIX & "__u" & ", " );
	REGIONS_PATH( D( XD_SOURCE_NAME, PREFIX_TYPE ) );
	PUT_LINE( PREFIX_TYPE_STR & ".LST_" & IMAGE( NUM_DIM ) );

	PUT( tab & "LId" & tab & IMAGE( ARRAY_LVL ) & ", " );
	REGIONS_PATH( D( SM_DEFN, PREFIX_NAME ) );
	PUT(  CHN_PREFIX & "__u" & ", " );
	REGIONS_PATH( D( XD_SOURCE_NAME, PREFIX_TYPE ) );
	PUT_LINE( PREFIX_TYPE_STR & ".FST_" & IMAGE( NUM_DIM ) );

	PUT_LINE( tab & "SUB" );
	PUT_LINE( tab & "INC" );
	PUT_LINE( tab & "CLAMP0" );
        end if;
      end;

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
	PUT_LINE( '_' & TYPE_STR & ".use__info" );
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
	PUT_LINE( tab & "LIq , -" & TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.NUMER " );			-- Charge l'entier NUMER
	PUT_LINE( tab & "CVTIF" );

	PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );			-- Adresse de frame generique
	PUT_LINE( tab & "LIq , -" & TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.DENOM" );			-- Charge l'entier DENOM
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
        if PREFIX_HAS_BASE then
          CODE_FLOAT_DIGITS;
        else

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
	      TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
	    end if;
	  end if;

	-- Extraire SM_ACCURACY du DN_FLOAT
	  if  TYPE_SPEC /= TREE_VOID  and then  TYPE_SPEC.TY = DN_FLOAT  then
	    ACCURACY := D( SM_ACCURACY, TYPE_SPEC );
	    if  ACCURACY /= TREE_VOID  then
	      if  ACCURACY.PT = HI  then
	        PUT_LINE( tab & "LI" & tab & IMAGE( NATURAL( ACCURACY.ABSS ) ) );
	      else
	        PUT_LINE( tab & "LI" & tab & PRINT_NUM( ACCURACY ) );
	      end if;
	    else
	      PUT_LINE( tab & "LI" & tab & "6" );							-- defaut	Ada 83 pour FLOAT
	    end if;
	  else
	    PUT_LINE( tab & "LI" & tab & "6" );								-- defaut	Ada 83 pour FLOAT
	  end if;
          end;
	CODE_FLOAT_DIGITS;
        end if;
      end if;
    when	'E' =>
      if	CHN_ATTR(	2 ) = 'M'	 then
        CODE_FLOAT_EMAX;										-- EMAX
      else
        CODE_FLOAT_EPSILON;										-- EPSILON
      end if;

    when	'F' =>
      if	CHN_ATTR(	2 ) = 'I'	 then						-- FIRST
        CODE_FIRST_LAST( IS_LAST => FALSE );
      else PUT_LINE( tab & "LI" & tab & '1' );					-- FORE a revoir
      end	if;

    when	'I' => CODE_IMAGE;							-- IMAGE

    when	'L' =>
      if	CHN_ATTR(	2 .. 3 ) = "AR"  then
        CODE_FLOAT_LARGE;                         -- LARGE
      elsif  CHN_ATTR( 2 .. 3	) = "AS"	then
        if  CHN_ATTR'LENGTH =	4  then						-- LAST
	CODE_FIRST_LAST( IS_LAST => TRUE );
        else null;								-- LAST_BIT
        end if;
      elsif  CHN_ATTR( 2 .. 3	) = "EN"	then CODE_LENGTH;				-- LENGTH

      end	if;

    when	'M' =>
      if	CHN_ATTR(	3 ) = 'N'	 then
        CODE_FLOAT_MANTISSA;							-- MANTISSA
      elsif  CHN_ATTR( 11 ) =	'A'  then
         CODE_FLOAT_EMAX;							-- MACHINE_EMAX
     elsif  CHN_ATTR( 11 ) =	'I'  then
        CODE_FLOAT_EMIN;							-- MACHINE_EMIN
      elsif  CHN_ATTR( 9 ) = 'M'   then
        CODE_FLOAT_MANTISSA;							-- MACHINE_MANTISSA
      elsif  CHN_ATTR( 9 ) = 'O'   then
        PUSH_INT( 1 );							-- MACHINE_OVERFLOWS
      elsif  CHN_ATTR( 10 ) =	'A'  then
        PUSH_INT( 2 );							-- MACHINE_RADIX
      elsif  CHN_ATTR( 10 ) =	'O'  then
        PUSH_INT( 1 );							-- MACHINE_ROUNDS
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
      elsif  CHN_ATTR( 2 ) = 'M'	then					-- SMALL
        declare
	T	: TREE	:= PREFIX_TYPE_SPEC;
        begin
          if T /= TREE_VOID and then T.TY = DN_FLOAT then
            CODE_FLOAT_SMALL;							-- FLOAT'SMALL
          else
            CODE_SMALL;							-- FIXED'SMALL, ancien chemin
          end if;
        end;
      elsif  CHN_ATTR( 2 ) = 'T'  then	 null;					-- STORAGE
      elsif  CHN_ATTR( 2 ) = 'U'  then						-- SUCC
        -- T'SUCC(X) : retourne X+1
        CODE_EXP( D( AS_EXP, ATTRIBUTE ) );
        PUT_LINE( tab & "INC"	);
      elsif  CHN_ATTR( 6 ) = 'E'  then
        CODE_FLOAT_EMAX;							-- SAFE_EMAX
      elsif  CHN_ATTR( 6 ) = 'L'  then
        CODE_FLOAT_LARGE;							-- SAFE_LARGE
      elsif  CHN_ATTR( 6 ) = 'S'  then
        CODE_FLOAT_SMALL;							-- SAFE_SMALL
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

		---------
  function	FULL_VIEW	( T : TREE )	return TREE
  is		---------
    R	: TREE	:= T;
  begin
    loop
      if  R.TY = DN_PRIVATE or else R.TY = DN_L_PRIVATE  then
        if D( SM_TYPE_SPEC, R ) = TREE_VOID then
	return R;
        end if;

        R := D( SM_TYPE_SPEC, R );

      elsif  R.TY = DN_INCOMPLETE  then
        if D( XD_FULL_TYPE_SPEC, R ) = TREE_VOID then
	return R;
        end if;

        R := D( XD_FULL_TYPE_SPEC, R );

      else
        return R;
      end if;
    end loop;

  end	FULL_VIEW;
	---------

		--------------
    function	COMP_SIZE_BITS	( T : TREE )	return INTEGER
    is		--------------
      E	: TREE	:= FULL_VIEW( T );
    begin
      if  E.TY = DN_ACCESS  then
        return CODI.ADDR_SIZE * CODI.STORAGE_UNIT;

      elsif  E.TY = DN_FLOAT  then
        return CODI.ADDR_SIZE * CODI.STORAGE_UNIT;

      else
        -- CD_IMPL_SIZE est la taille minimale en BITS posee par le front-end
        -- (1 pour BOOLEAN, 3 pour un enumere a 7 valeurs...).  La convention
        -- de stockage TLALOC est l'octet (piege n 10) : arrondir.
        declare
          RAW : INTEGER := DI( CD_IMPL_SIZE, E );
        begin
          return ( ( RAW + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT ) * CODI.STORAGE_UNIT;
        end;
      end if;

--     else
--        return DI( CD_IMPL_SIZE, E );
--      end if;

    end	COMP_SIZE_BITS;
	--------------


			----------------------------
	  procedure	CODE_ARRAY_AGGREGATE_OPERAND		( AGG : TREE; ANON : STRING; CONTEXT_TYPE :TREE )
	  is		----------------------------

            COMP_TYPE	: TREE		:= FULL_VIEW( D( SM_COMP_TYPE, D( SM_BASE_TYPE, CONTEXT_TYPE ) ) );
            COMP_BITS	: INTEGER		:= COMP_SIZE_BITS( COMP_TYPE );
            COMP_BYTES	: INTEGER		:= COMP_BITS / CODI.STORAGE_UNIT;

	    LVL		: constant STRING := IMAGE( CODI.CUR_LEVEL );

	    AGG_TYPE	: TREE := D( SM_EXP_TYPE, AGG );
	    RNG		: TREE := TREE_VOID;
			---------------
	    function	AGGREGATE_RANGE		return TREE
	    is		---------------
	      R		: TREE := D( SM_DISCRETE_RANGE, AGG );
	      SEQ		: SEQ_TYPE;
	      ASSOC	: TREE;
	      CHOICES	: SEQ_TYPE;
	      CH		: TREE;
	    begin
	      if R /= TREE_VOID then
	        return R;
	      end if;

	      -- Cas fréquent des agrégats nommés :
	      -- (1..TEST_NAME_LEN => ' ')
	      SEQ := LIST( D( SM_NORMALIZED_COMP_S, AGG ) );

	      while not IS_EMPTY( SEQ ) loop
	        POP( SEQ, ASSOC );

	        if ASSOC.TY = DN_NAMED then
		CHOICES := LIST( D( AS_CHOICE_S, ASSOC ) );

		while not IS_EMPTY( CHOICES ) loop
		  POP( CHOICES, CH );

		  if CH.TY = DN_CHOICE_RANGE then
		    return D( AS_DISCRETE_RANGE, CH );
		  end if;
		end loop;
	        end if;
	      end loop;

	      return  TREE_VOID;

	    end	AGGREGATE_RANGE;
		---------------
	  begin
	    if  AGG_TYPE = TREE_VOID  or else  AGG_TYPE.TY = DN_VOID  then
	      -- Dans une concaténation de STRING, le type contextuel est le
	      -- type résultat de l'opérateur "&".
	      AGG_TYPE := CONTEXT_TYPE;
	    end if;

	    RNG := AGGREGATE_RANGE;

	    if RNG = TREE_VOID then
	      PUT_LINE( "; CODE & concat : aggregate operand sans range explicite" );
	      raise PROGRAM_ERROR;
	    end if;

	    PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
	    PUT_LINE( "VAR" & tab & ANON & "__u,   q" );

	    PUT_LINE( "namespace " & ANON & "_info" );
	    PUT_LINE( "  VAR SIZ,      d" );
	    PUT_LINE( "  VAR _COMP_SIZ, d" );
	    PUT_LINE( "  VAR _FST_1,    d" );
	    PUT_LINE( "  VAR _LST_1,    d" );
	    PUT_LINE( "end namespace" );

	    -- FST_1
	    CODE_EXP( D( AS_EXP1, RNG ) );
	    PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info._FST_1" );

	    -- LST_1, en gardant une copie pour COUNT
	    CODE_EXP( D( AS_EXP2, RNG ) );
	    PUT_LINE( tab & "DUP" );
	    PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info._LST_1" );

	    -- COUNT = LST - FST + 1
	    CODE_EXP( D( AS_EXP1, RNG ) );
	    PUT_LINE( tab & "SUB" );
	    PUT_LINE( tab & "INC" );
	    PUT_LINE( tab & "CLAMP0" );

	    -- COMP_SIZ en bits
	    PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BITS ) );
	    PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info._COMP_SIZ" );

	    -- SIZ = COUNT * COMP_BITS
	    PUT_LINE( tab & "DUP" );
	    if COMP_BITS /= 1 then
	      PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BITS ) );
	      PUT_LINE( tab & "MUL" );
	    end if;
	    PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info.SIZ" );

	    -- Allocation données : COUNT * COMP_BYTES
	    if COMP_BYTES /= 1 then
	      PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BYTES ) );
	      PUT_LINE( tab & "MUL" );
	    end if;
	    PUT_LINE( tab & "CO_VAR" );
	    PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "_disp" );

	    -- use_info du doublet temporaire
	    PUT_LINE( tab & "LVA " & LVL & ", " & ANON & "_info.SIZ" );
	    PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "__u" );

	    -- Remplissage des données de l'agrégat.
	    -- CODE_AGGREGATE attend l'adresse des données au sommet de pile.
	    PUT_LINE( tab & "La  " & LVL & ", " & ANON & "_disp" );
	    CODE_AGGREGATE( AGG, AGG_TYPE );

	    -- Résultat attendu par la concat : adresse du doublet.
	    PUT_LINE( tab & "LVA " & LVL & ", " & ANON & "_disp" );

	  end	CODE_ARRAY_AGGREGATE_OPERAND;
		----------------------------


			------------------
	  procedure	CODE_ARRAY_OPERAND ( E : TREE; ANON : STRING; CONTEXT_TYPE :TREE )
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

    -- Info normalisée : bounds 1 .. len.
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

    -- Résultat attendu par la concat : @doublet.
	      PUT_LINE( tab & "LVA " & LVL & ", " & ANON & "_disp" );

	    elsif E.TY = DN_AGGREGATE then
	      CODE_ARRAY_AGGREGATE_OPERAND( E, ANON, CONTEXT_TYPE );

	    elsif  D( SM_EXP_TYPE, E ) /= TREE_VOID  and then  D( SM_EXP_TYPE, E ).TY in CLASS_SCALAR then
	    -- OPERANDE COMPOSANT (4.5.3) : composant & tableau, tableau & composant,
	    -- composant & composant.  Normalisation : tableau temporaire d'UN element
	    -- sur la co-pile, presente comme tout autre operande par son @doublet.
	      declare
	        COMP_TYPE	: TREE	:= FULL_VIEW( D( SM_COMP_TYPE, D( SM_BASE_TYPE, CONTEXT_TYPE ) ) );
	        COMP_BITS	: INTEGER	:= COMP_SIZE_BITS( COMP_TYPE );
	        COMP_BYTES	: INTEGER	:= COMP_BITS / CODI.STORAGE_UNIT;
	      begin
	        PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
	        PUT_LINE( "VAR" & tab & ANON & "__u,   q" );

	        PUT_LINE( "namespace " & ANON & "_info" );
	        PUT_LINE( "  VAR SIZ,      d" );
	        PUT_LINE( "  VAR _COMP_SIZ, d" );
	        PUT_LINE( "  VAR _FST_1,    d" );
	        PUT_LINE( "  VAR _LST_1,    d" );
	        PUT_LINE( "end namespace" );

	        CODE_EXP( E );							-- valeur scalaire du composant

	        PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BYTES ) );
	        PUT_LINE( tab & "CO_VAR" );					-- @data (1 composant)
	        PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "_disp" );

	        PUT_LINE( tab & "SI" & OPER_SIZ_CHAR( COMP_TYPE )
			& "  " & LVL & ", " & ANON & "_disp, 0" );		-- [data] := valeur

	        -- Info : bornes 1 .. 1
	        PUT_LINE( tab & "LI"  & tab & "1" );
	        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info._FST_1" );
	        PUT_LINE( tab & "LI"  & tab & "1" );
	        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info._LST_1" );
	        PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BITS ) );
	        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info._COMP_SIZ" );
	        PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BITS ) );
	        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "_info.SIZ" );

	        PUT_LINE( tab & "LVA " & LVL & ", " & ANON & "_info.SIZ" );
	        PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "__u" );

	        PUT_LINE( tab & "LVA " & LVL & ", " & ANON & "_disp" );		-- @doublet, comme les autres branches
	      end;

	    else
	      CODE_EXP( E );
	    end if;

	  end	CODE_ARRAY_OPERAND;
		------------------


			-----------------------
  procedure		CODE_COMPOSITE_OPERATOR	( OP_STR :STRING; PRM_1, PRM_2 :TREE; CONTEXT_TYPE :TREE )
  is			-----------------------

-- Operateurs predefinis dont les operandes sont des TABLEAUX (LRM 3.6.2) :
--   "="  "/="            : implantes par BLKCMP (lot D1)
--   "<"  "<="  ">"  ">=" : implantes par LEXCMP (lot D2)
--   "AND"  "OR"  "XOR"  "NOT" : implantes par BLKAND/BLKOU/BLKOUX/BLKNOT (lot D3)
-- Les deux operandes sont du meme type tableau (4.5.2) : CONTEXT_TYPE, qui fournit
-- la taille de composant et sert de repli aux agregats/litteraux sans SM_EXP_TYPE.
-- Convention : le resultat (BOOLEAN 0/1) est laisse seul sur la pile.

    COMP_TYPE	: TREE		:= FULL_VIEW( D( SM_COMP_TYPE, D( SM_BASE_TYPE, CONTEXT_TYPE ) ) );
    COMP_BITS	: INTEGER		:= COMP_SIZE_BITS( COMP_TYPE );
    COMP_BYTES	: INTEGER		:= COMP_BITS / CODI.STORAGE_UNIT;
    LVL		:constant STRING	:= IMAGE( CODI.CUR_LEVEL );

    CMP_UID	:constant STRING	:= NEW_LABEL;
    ANON_G	:constant STRING	:= ANONYMOUS_NAME_AT( PRM_1 ) & "_" & CMP_UID & "_G";
    ANON_D	:constant STRING	:= ANONYMOUS_NAME_AT( PRM_2 ) & "_" & CMP_UID & "_D";
    ANON_R	:constant STRING	:= ANONYMOUS_NAME_AT( PRM_1 ) & "_" & CMP_UID & "_R";
    LBL_END	:constant STRING	:= NEW_LABEL;

    TYPE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, CONTEXT_TYPE ) ) );

		-------------
    procedure	SETUP_OPERAND	( E : TREE;  ANON : STRING )
    is		-------------
    -- Normalise l'operande en @doublet (litteral, tranche, agregat, expression)
    -- puis en extrait data_ptr, info_ptr et la longueur en OCTETS (bornee a 0).
    begin
      PUT_LINE( "VAR" & tab & ANON & "_data, q" );
      PUT_LINE( "VAR" & tab & ANON & "_info, q" );
      PUT_LINE( "VAR" & tab & ANON & "_len,  q" );

      CODE_ARRAY_OPERAND( E, ANON, CONTEXT_TYPE );				-- @doublet
      PUT_LINE( tab & "DUP" );
      PUT_LINE( tab & "La  ,  0" );
      PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "_data" );
      PUT_LINE( tab & "La  ,  8" );
      PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "_info" );

      -- LEN = (LST_1 - FST_1 + 1) * COMP_BYTES
      PUT_LINE( tab & "LId " & LVL & ", " & ANON & "_info, " & TYPE_STR & ".LST_1" );
      PUT_LINE( tab & "LId " & LVL & ", " & ANON & "_info, " & TYPE_STR & ".FST_1" );
      PUT_LINE( tab & "SUB" );
      PUT_LINE( tab & "INC" );
      PUT_LINE( tab & "CLAMP0" );						-- piege n 52
      if COMP_BYTES /= 1 then
        PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BYTES ) );
        PUT_LINE( tab & "MUL" );
      end if;
      PUT_LINE( tab & "Sa  " & LVL & ", " & ANON & "_len" );

    end	SETUP_OPERAND;
	-------------
  begin
    if  OP_STR = """="""  or  OP_STR = """/="""  then

      if CODI.DEBUG then PUT_LINE( "; CODE composite " & OP_STR & ' ' & TYPE_STR ); end if;

      SETUP_OPERAND( PRM_1, ANON_G );
      SETUP_OPERAND( PRM_2, ANON_D );

      -- Longueurs egales ?  Longueurs differentes => FALSE (4.5.2) : c'est un
      -- resultat, pas une erreur.  Idiome DUP/BF/DROP du court-circuit.
      PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len" );
      PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_len" );
      PUT_LINE( tab & "CEQ" );
      PUT_LINE( tab & "DUP" );
      PUT_LINE( tab & "BF" & tab & LBL_END );					-- le 0 restant EST le resultat
      PUT_LINE( tab & "DROP" );

      -- Contenus egaux ?  Convention BLKCMP (miroir BLKMOV) : pile = @A, LEN, @B.
      PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_data" );
      PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len"  );
      PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_data" );
      PUT_LINE( tab & "BLKCMP" );									-- empile 0/1

      PUT_LINE( LBL_END & ':' );

      if  OP_STR = """/="""  then
        PUT_LINE( tab & "LI"  & tab & "1" );
        PUT_LINE( tab & "OUX" );									-- NOT booleen (piege n 5)
      end if;

    elsif  OP_STR = """<"""  or  OP_STR = """<="""  or  OP_STR = """>"""  or  OP_STR = """>="""  then

      -- Relationnels composites (lot D2, LRM 4.5.2) : ordre lexicographique,
      -- regle du prefixe.  LEXCMP normalise chaque composant a 64 bits (signe
      -- selon SGN), itere par composant (repe cmpsb inutilisable : little-endian
      -- multi-octets, signes) et empile -1/0/+1.  La confrontation a 0 par
      -- CLT/CLE/CGT/CGE rend le BOOLEAN -- contrat de nature scalaire respecte
      -- (piege n 55).  Les longueurs viennent de SETUP_OPERAND, en octets,
      -- bornees a 0 par CLAMP0 (piege n 52) : tableaux nuls couverts.
      -- LRM 4.5.2 : composants necessairement DISCRETS (le front-end rejette
      -- le reste) -- signe ssi INTEGER, non signe pour enumeres/CHARACTER/BOOLEAN.

      if CODI.DEBUG then PUT_LINE( "; CODE composite " & OP_STR & ' ' & TYPE_STR ); end if;

      SETUP_OPERAND( PRM_1, ANON_G );
      SETUP_OPERAND( PRM_2, ANON_D );

      declare
        SGN : STRING( 1 .. 1 ) := "0";									-- enumeres, CHARACTER, BOOLEAN
      begin
        if  COMP_TYPE.TY = DN_INTEGER
        or  COMP_TYPE.TY = DN_UNIVERSAL_INTEGER  then
          SGN := "1";										-- composants signes
        end if;

        PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_data" );
        PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len"  );
        PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_data" );
        PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_len"  );
        PUT_LINE( tab & "LEXCMP" & tab & IMAGE( COMP_BYTES ) & ", " & SGN );
      end;

      PUT_LINE( tab & "LI"  & tab & "0" );								-- lexcmp ? 0
      if    OP_STR = """<"""   then  PUT_LINE( tab & "CLT" );
      elsif OP_STR = """<="""  then  PUT_LINE( tab & "CLE" );
      elsif OP_STR = """>"""   then  PUT_LINE( tab & "CGT" );
      else                           PUT_LINE( tab & "CGE" );
      end if;

    elsif  OP_STR = """AND"""  or  OP_STR = """OR"""  or  OP_STR = """XOR"""  or  OP_STR = """NOT"""  then

      -- Logiques composites (lot D3, LRM 4.5.1) : composants BOOLEAN, un octet
      -- par composant (piege n 56), valeurs 0/1 -> operations octet a octet.
      -- Bornes du resultat = celles de l'operande GAUCHE (4.5.1) : le __u du
      -- resultat REUTILISE l'info de G ; seule la data est allouee (co-pile,
      -- meme idiome que la concat).  NOT est unaire : PRM_2 = PRM_1, ignore.
      -- PILIER CHECKS (E-B) : l'egalite des longueurs est CONTROLEE (4.5.1),
      -- CONSTRAINT_ERROR par STANDARD.ce_raise_ -- la RESTRICTION D3 est soldee.
      -- L'operation itere LEN_G octets, garanti = LEN_D (checks ON).

      if CODI.DEBUG then PUT_LINE( "; CODE composite " & OP_STR & ' ' & TYPE_STR ); end if;

      -- Doublet resultat : les deux VAR doivent rester ADJACENTES
      -- ([@] = data_ptr, [@+8] = info_ptr).
      PUT_LINE( "VAR" & tab & ANON_R & "_disp, q" );
      PUT_LINE( "VAR" & tab & ANON_R & "__u,   q" );

      SETUP_OPERAND( PRM_1, ANON_G );
      if  OP_STR /= """NOT"""  then
        SETUP_OPERAND( PRM_2, ANON_D );

        -- ---- PILIER CHECKS (E-B) : LEN_G = LEN_D (LRM 4.5.1) ----
        -- Longueurs en OCTETS = nombre de composants (BOOLEAN, 1 octet --
        -- piege n 56), deja bornees a 0 par CLAMP0 dans SETUP_OPERAND :
        -- deux tableaux nuls sont EGAUX, aucune levee (piege n 52).
        -- Effet de pile net NUL : s'insere sans toucher la suite.
        if  CODI.CHECKS_ENABLED  then
          PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len" );
          PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_len" );
          PUT_LINE( tab & "CNE" );
          PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );
        end if;
      end if;

      -- ---- data resultat : LEN_G octets sur la co-pile ----
      PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len" );
      PUT_LINE( tab & "CO_VAR" );					-- depile taille, empile @data_res
      PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_R & "_disp" );

      -- ---- descripteur : bornes de l'operande gauche (4.5.1) ----
      PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_info" );
      PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_R & "__u" );

      -- ---- copie G -> R (convention BLKMOV : @DST, LEN, @SRC) ----
      PUT_LINE( tab & "La  " & LVL & ", " & ANON_R & "_disp" );
      PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len"  );
      PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_data" );
      PUT_LINE( tab & "BLKMOV" );

      -- ---- application de l'operateur sur place ----
      if  OP_STR = """NOT"""  then
        PUT_LINE( tab & "La  " & LVL & ", " & ANON_R & "_disp" );
        PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len"  );
        PUT_LINE( tab & "BLKNOT" );
      else
        PUT_LINE( tab & "La  " & LVL & ", " & ANON_R & "_disp" );	-- @DST
        PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len"  );	-- LEN
        PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_data" );	-- @SRC
        if    OP_STR = """AND"""  then  PUT_LINE( tab & "BLKAND" );
        elsif OP_STR = """OR"""   then  PUT_LINE( tab & "BLKOU"  );
        else                            PUT_LINE( tab & "BLKOUX" );
        end if;
      end if;

      -- ---- @doublet resultat sur la pile ----
      PUT_LINE( tab & "LVA " & LVL & ", " & ANON_R & "_disp" );

    else
      -- Operateur composite non reconnu : stub BRUYANT equilibre (pieges n 53
      -- et 55) -- nature @doublet, operande gauche normalise, traceable.
      PUT_LINE( "; CODE_COMPOSITE_OPERATOR : " & OP_STR & " NON TRAITE -- resultat force = operande gauche" );
      CODE_ARRAY_OPERAND( PRM_1, ANON_G, CONTEXT_TYPE );		-- @doublet
    end if;

  end	CODE_COMPOSITE_OPERATOR;
	-----------------------


			--------------------
  procedure		CODE_RECORD_EQUALITY	( OP_STR :STRING; PRM_1, PRM_2 :TREE; CONTEXT_TYPE :TREE )
  is			--------------------

-- Pilier 3.7 (RM83 4.5.2) : "=" / "/=" de records.
-- SANS variantes : BLKCMP total (champs arrondis au STORAGE_UNIT, contigus).
-- A VARIANTES : le layout ADDITIF laisse des zones mortes -> BLKCMP total
-- serait faux ; generation champ par champ (ET cumules) avec cascade
-- statique sur la valeur du discriminant gouvernant (variante ACTIVE seule
-- comparee).  Indispensable au bootstrap : idl.adb compare des TREE.
-- Convention BLKCMP (miroir BLKMOV) : pile = @A, LEN, @B  ->  0/1.

    BASE	: TREE	:= CONTEXT_TYPE;

		--------------------
    procedure	OPERAND_DATA_ADDRESS	( E : TREE )
    is		--------------------
    begin
      if  E.TY = DN_AGGREGATE  then
        PUT_LINE( "; CODE_RECORD_EQUALITY : operande agregat non supporte" );
        raise PROGRAM_ERROR;
      end if;

      CODE_EXP( E );

      if  E.TY = DN_USED_OBJECT_ID  or else  E.TY = DN_FUNCTION_CALL  then
        PUT_LINE( tab & "La  ,  0" );							-- @doublet -> data_ptr
      end if;
    end	OPERAND_DATA_ADDRESS;
	--------------------

  begin
    if  BASE.TY = DN_CONSTRAINED_RECORD  then
      BASE := D( SM_BASE_TYPE, BASE );
    end if;

    declare
      BASE_NAME	: TREE		:= D( XD_SOURCE_NAME, BASE );
      BASE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, BASE_NAME ) );
      LVL	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
      VP_ROOT	: TREE		:= D( AS_VARIANT_PART, D( SM_COMP_LIST, BASE ) );

		----------
      procedure	PATH_FIELD	( F_STR : STRING )
      is		----------
      begin
        CODI.REGIONS_PATH( BASE_NAME );
        PUT( BASE_STR & "." & F_STR );
      end	PATH_FIELD;
	----------

    begin
      if CODI.DEBUG then PUT_LINE( "; CODE record equality " & OP_STR & ' ' & BASE_STR ); end if;

      if  VP_ROOT = TREE_VOID  or else  VP_ROOT = TREE_NIL  then

		-- Record SANS variantes : BLKCMP total (champs arrondis au
		-- STORAGE_UNIT et contigus : comparaison memoire sure).
        OPERAND_DATA_ADDRESS( PRM_1 );							-- @A

        PUT( tab & "LI" & tab );							-- LEN (statique)
        CODI.REGIONS_PATH( BASE_NAME );
        PUT_LINE( BASE_STR & ".size" );

        OPERAND_DATA_ADDRESS( PRM_2 );							-- @B

        PUT_LINE( tab & "BLKCMP" );							-- empile 0/1

      else
		-- Record A VARIANTES (RM83 4.5.2) : discriminants, champs fixes,
		-- puis champs de la variante ACTIVE seulement -- le layout additif
		-- laisse des zones mortes, BLKCMP total serait faux.  Generation
		-- statique : comparaisons champ par champ cumulees par ET (pas de
		-- court-circuit : ET d'un accumulateur deja a 0 reste 0 ; lire la
		-- zone morte de l'autre operande est sur, memoire allouee), et
		-- cascade de tests sur la valeur du discriminant gouvernant.
        declare
	EQ_UID	:constant STRING	:= NEW_LABEL;
	A_VAR	:constant STRING	:= "EQA_" & EQ_UID;
	B_VAR	:constant STRING	:= "EQB_" & EQ_UID;

		--------------
	procedure	EMIT_FIELD_CMP	( COMP_ID : TREE )
	is		--------------
	  F_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, COMP_ID ) );
	  F_TYPE	: TREE		:= D( SM_OBJ_TYPE, COMP_ID );
	begin
	  while  F_TYPE.TY = DN_PRIVATE  or else  F_TYPE.TY = DN_L_PRIVATE  loop
	    F_TYPE := D( SM_TYPE_SPEC, F_TYPE );
	  end loop;

	  if  F_TYPE.TY = DN_CONSTRAINED_RECORD  then
	    F_TYPE := D( SM_BASE_TYPE, F_TYPE );
	  end if;

	  if  F_TYPE.TY = DN_RECORD  then
	    declare
	      SUB_VP	: TREE		:= D( AS_VARIANT_PART, D( SM_COMP_LIST, F_TYPE ) );
	      SUB_NAME	: TREE		:= D( XD_SOURCE_NAME, F_TYPE );
	      SUB_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, SUB_NAME ) );
	    begin
	      if  SUB_VP /= TREE_VOID  and then  SUB_VP /= TREE_NIL  then
	        PUT_LINE( "; CODE_RECORD_EQUALITY : champ record a variantes imbrique non supporte" );
	        raise PROGRAM_ERROR;
	      end if;

	      PUT_LINE( tab & "La  " & LVL & ", " & A_VAR );
	      PUT( tab & "LVA" & tab & ", " );	PATH_FIELD( F_STR );	NEW_LINE;	-- @A.F

	      PUT( tab & "LI" & tab );
	      CODI.REGIONS_PATH( SUB_NAME );
	      PUT_LINE( SUB_STR & ".size" );						-- LEN

	      PUT_LINE( tab & "La  " & LVL & ", " & B_VAR );
	      PUT( tab & "LVA" & tab & ", " );	PATH_FIELD( F_STR );	NEW_LINE;	-- @B.F

	      PUT_LINE( tab & "BLKCMP" );
	      PUT_LINE( tab & "ET" );
	    end;

	  elsif  F_TYPE.TY = DN_ARRAY  or else  F_TYPE.TY = DN_CONSTRAINED_ARRAY  then
	    PUT_LINE( "; CODE_RECORD_EQUALITY : champ tableau de record a variantes non supporte" );
	    raise PROGRAM_ERROR;

	  else		-- scalaire, enumere, access ; float compare bit a bit (comme BLKCMP)
	    declare
	      C : CHARACTER := CODI.OPER_SIZ_CHAR( F_TYPE );
	    begin
	      PUT( tab & "LI" & C & tab & LVL & ", " & A_VAR & ", " );
	      PATH_FIELD( F_STR );	NEW_LINE;

	      PUT( tab & "LI" & C & tab & LVL & ", " & B_VAR & ", " );
	      PATH_FIELD( F_STR );	NEW_LINE;

	      PUT_LINE( tab & "CEQ" );
	      PUT_LINE( tab & "ET" );
	    end;
	  end if;

	end	EMIT_FIELD_CMP;
		--------------

		-------
	procedure	WALK_EQ	( CL : TREE )
	is		-------
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
	          EMIT_FIELD_CMP( COMP_ID );
	        end loop;
	      end;
	    end if;
	  end loop;

	  declare
	    VP	: TREE	:= D( AS_VARIANT_PART, CL );
	  begin
	    if  VP /= TREE_VOID  and then  VP /= TREE_NIL  then
	      declare
	        GOV_ID	: TREE		:= D( SM_DEFN, D( AS_NAME, VP ) );
	        GOV_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, GOV_ID ) );
	        GOV_CHAR	: CHARACTER	:= CODI.OPER_SIZ_CHAR( D( SM_OBJ_TYPE, GOV_ID ) );
	        LBL_DONE	:constant STRING	:= NEW_LABEL;
	        VAR_S	: SEQ_TYPE	:= LIST( D( AS_VARIANT_S, VP ) );
	        VAR_E	: TREE;
	      begin
	        while  not IS_EMPTY( VAR_S )  loop
	          POP( VAR_S, VAR_E );

	          if  VAR_E.TY = DN_VARIANT  then
	            declare
	              LBL_NEXT	:constant STRING	:= NEW_LABEL;
	              CHOICES	: SEQ_TYPE	:= LIST( D( AS_CHOICE_S, VAR_E ) );
	              CH	: TREE;
	              IS_OTHERS	: BOOLEAN	:= FALSE;
	              N_TESTS	: NATURAL	:= 0;
	            begin
	              while  not IS_EMPTY( CHOICES )  loop
	                POP( CHOICES, CH );

	                if  CH.TY = DN_CHOICE_OTHERS  then
	                  IS_OTHERS := TRUE;						-- seul et dernier (RM83 3.7.3)

	                elsif  CH.TY = DN_CHOICE_EXP  then
	                  PUT( tab & "LI" & GOV_CHAR & tab & LVL & ", " & A_VAR & ", " );
	                  PATH_FIELD( GOV_STR );	NEW_LINE;			-- discriminant (deja verifie egal)

	                  PUT_LINE( tab & "LI" & tab & IMAGE( DI( SM_VALUE, D( AS_EXP, CH ) ) ) );
	                  PUT_LINE( tab & "CEQ" );

	                  N_TESTS := N_TESTS + 1;
	                  if  N_TESTS >= 2  then
	                    PUT_LINE( tab & "OU" );					-- choix multiples : A | B
	                  end if;

	                else
	                  PUT_LINE( "; CODE_RECORD_EQUALITY : choix de variante non gere "
			& NODE_NAME'IMAGE( CH.TY ) );
	                  raise PROGRAM_ERROR;
	                end if;
	              end loop;

	              if  not IS_OTHERS  then
	                PUT_LINE( tab & "BF" & tab & LBL_NEXT );
	              end if;

	              WALK_EQ( D( AS_COMP_LIST, VAR_E ) );				-- variantes imbriquees : recursion

	              PUT_LINE( tab & "BRA" & tab & LBL_DONE );

	              if  not IS_OTHERS  then
	                PUT_LINE( LBL_NEXT & ':' );
	              end if;
	            end;
	          end if;
	        end loop;

	        PUT_LINE( LBL_DONE & ':' );
	      end;
	    end if;
	  end;

	end	WALK_EQ;
		-------

        begin
	PUT_LINE( "VAR" & tab & A_VAR & ", q" );
	PUT_LINE( "VAR" & tab & B_VAR & ", q" );

	OPERAND_DATA_ADDRESS( PRM_1 );
	PUT_LINE( tab & "Sa  " & LVL & ", " & A_VAR );					-- @dataA

	OPERAND_DATA_ADDRESS( PRM_2 );
	PUT_LINE( tab & "Sa  " & LVL & ", " & B_VAR );					-- @dataB

	PUT_LINE( tab & "LI" & tab & "1" );						-- accumulateur

			-- 1. Discriminants
	declare
	  DSCRMT_DECL_S	: SEQ_TYPE	:= LIST( D( SM_DISCRIMINANT_S, BASE ) );
	  DSCRMT_DECL	: TREE;
	begin
	  while  not IS_EMPTY( DSCRMT_DECL_S )  loop
	    POP( DSCRMT_DECL_S, DSCRMT_DECL );

	    declare
	      DISCR_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, DSCRMT_DECL ) );
	      DISCR_ID	: TREE;
	    begin
	      while  not IS_EMPTY( DISCR_ID_S )  loop
	        POP( DISCR_ID_S, DISCR_ID );
	        EMIT_FIELD_CMP( DISCR_ID );
	      end loop;
	    end;
	  end loop;
	end;

			-- 2. Champs fixes puis cascade de la variante active
	WALK_EQ( D( SM_COMP_LIST, BASE ) );
        end;
      end if;

      if  OP_STR = """/="""  then
        PUT_LINE( tab & "LI"  & tab & "1" );
        PUT_LINE( tab & "OUX" );							-- NOT booleen (piege n 5)
      end if;
    end;

  end	CODE_RECORD_EQUALITY;
	--------------------


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
      if  DEFN.TY = DN_BLTN_OPERATOR_ID  or  DEFN.TY = DN_OPERATOR_ID  then
      declare
        OP_STR		:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
        PRM_S		: SEQ_TYPE	:= LIST( PARAMS );
        PRM_1, PRM_2	: TREE;
        RES_TYPE		: TREE		:= D( SM_EXP_TYPE, FUNCTION_CALL );
        IS_FLOAT		: BOOLEAN		:= RES_TYPE.TY = DN_FLOAT  or  RES_TYPE.TY = DN_UNIVERSAL_REAL;

      begin
        if OP_STR = """-"""
	  and then RES_TYPE /= TREE_VOID
	  and then RES_TYPE.TY = DN_FIXED
	  and then D( SM_VALUE, FUNCTION_CALL ).TY = DN_REAL_VAL
        then
	CODE_STATIC_FIXED_VALUE( D( SM_VALUE, FUNCTION_CALL ), RES_TYPE );
	return;
        end if;

--        POP( PRM_S, PRM_1 );
--        if  IS_EMPTY( PRM_S )  then
--	CODE_EXP( PRM_1 );
--	goto UNARY;
--        end if;

        POP( PRM_S, PRM_1 );
        if  IS_EMPTY( PRM_S )  then

          -- NOT composite (lot D3) : router vers CODE_COMPOSITE_OPERATOR
          -- AVANT CODE_EXP (PRM_2 := PRM_1, ignore par la branche NOT).
          if  OP_STR = """NOT"""  then
            declare
              PRM1_TYPE : TREE := D( SM_EXP_TYPE, PRM_1 );
            begin
              if  PRM1_TYPE /= TREE_VOID
                and then ( PRM1_TYPE.TY = DN_ARRAY  or  PRM1_TYPE.TY = DN_CONSTRAINED_ARRAY )
              then
                CODE_COMPOSITE_OPERATOR( OP_STR, PRM_1, PRM_1, PRM1_TYPE );
                return;
              end if;
            end;
          end if;

          CODE_EXP( PRM_1 );
          goto UNARY;
        end if;

        POP( PRM_S, PRM_2 );

        if  OP_STR = """&"""  then
				----------------------
				CONCATENATION_OPERATOR:
	declare
            COMP_TYPE	: TREE		:= FULL_VIEW( D( SM_COMP_TYPE, D( SM_BASE_TYPE, RES_TYPE ) ) );
            COMP_BITS	: INTEGER		:= COMP_SIZE_BITS( COMP_TYPE );
            COMP_BYTES	: INTEGER		:= COMP_BITS / CODI.STORAGE_UNIT;
            LVL		:constant STRING	:= IMAGE( CODI.CUR_LEVEL );

	  CONCAT_UID	:constant STRING	:= NEW_LABEL;
	  ANON_G		:constant STRING	:= ANONYMOUS_NAME_AT( PRM_1 ) & "_" & CONCAT_UID & "_G";
	  ANON_D		:constant STRING	:= ANONYMOUS_NAME_AT( PRM_2 ) & "_" & CONCAT_UID & "_D";
	  ANON_R		:constant STRING	:= ANONYMOUS_NAME_AT( FUNCTION_CALL ) & "_" & CONCAT_UID & "_R";

            TYPE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, RES_TYPE ) ) );



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
            PUT_LINE( "  VAR _COMP_SIZ, d" );
            PUT_LINE( "  VAR _FST_1,    d" );
            PUT_LINE( "  VAR _LST_1,    d" );
            PUT_LINE( "end namespace" );

            -- ---- Operande gauche ----
            CODE_ARRAY_OPERAND( PRM_1, ANON_G, RES_TYPE );
            -- @doublet_g sur pile
            PUT_LINE( tab & "DUP" );
            PUT_LINE( tab & "La  ,  0" );
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_G & "_data" );
            PUT_LINE( tab & "La  ,  8" );
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_G & "_info" );

            -- LEN_G = (LST_1 - FST_1 + 1) * COMP_BYTES
            PUT_LINE( tab & "LId " & LVL & ", " & ANON_G & "_info, " & TYPE_STR & ".LST_1" );
            PUT_LINE( tab & "LId " & LVL & ", " & ANON_G & "_info, " & TYPE_STR & ".FST_1" );
            PUT_LINE( tab & "SUB" );
            PUT_LINE( tab & "INC" );
	  PUT_LINE( tab & "CLAMP0" );
            if COMP_BYTES /= 1 then
              PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BYTES ) );
              PUT_LINE( tab & "MUL" );
            end if;
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_G & "_len" );

            -- ---- Operande droit ----
            CODE_ARRAY_OPERAND( PRM_2, ANON_D, RES_TYPE );
            PUT_LINE( tab & "DUP" );
            PUT_LINE( tab & "La  ,  0" );
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_D & "_data" );
            PUT_LINE( tab & "La  ,  8" );
            PUT_LINE( tab & "Sa  " & LVL & ", " & ANON_D & "_info" );

            PUT_LINE( tab & "LId " & LVL & ", " & ANON_D & "_info, " & TYPE_STR & ".LST_1" );
            PUT_LINE( tab & "LId " & LVL & ", " & ANON_D & "_info, " & TYPE_STR & ".FST_1" );
            PUT_LINE( tab & "SUB" );
            PUT_LINE( tab & "INC" );
	  PUT_LINE( tab & "CLAMP0" );
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
            PUT_LINE( tab & "Sd  " & LVL & ", " & ANON_R & "_info._FST_1" );
            -- LST_1 = (LEN_G + LEN_D) / COMP_BYTES
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_G & "_len" );
            PUT_LINE( tab & "La  " & LVL & ", " & ANON_D & "_len" );
            PUT_LINE( tab & "ADD" );
            if COMP_BYTES /= 1 then
              PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BYTES ) );
              PUT_LINE( tab & "DIV" );
            end if;
            PUT_LINE( tab & "Sd  " & LVL & ", " & ANON_R & "_info._LST_1" );
            -- COMP_SIZ en bits
            PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BITS ) );
            PUT_LINE( tab & "Sd  " & LVL & ", " & ANON_R & "_info._COMP_SIZ" );

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

          end		CONCATENATION_OPERATOR;
			----------------------
	return;
        end if;
				-------------------
				COMPOSITE_OPERATORS:
        declare
          PRM1_TYPE : TREE := D( SM_EXP_TYPE, PRM_1 );
        begin
          if  PRM1_TYPE = TREE_VOID  or else  PRM1_TYPE.TY = DN_VOID  then					-- litteral/agregat : regarder l'autre operande
            PRM1_TYPE := D( SM_EXP_TYPE, PRM_2 );
          end if;
          if  PRM1_TYPE /= TREE_VOID
            and then ( PRM1_TYPE.TY = DN_ARRAY  or  PRM1_TYPE.TY = DN_CONSTRAINED_ARRAY )
          then
            CODE_COMPOSITE_OPERATOR( OP_STR, PRM_1, PRM_2, PRM1_TYPE );
            return;
          end if;

          if  PRM1_TYPE /= TREE_VOID							-- pilier 3.7 : egalite de records
            and then ( PRM1_TYPE.TY = DN_RECORD  or  PRM1_TYPE.TY = DN_CONSTRAINED_RECORD )
            and then ( OP_STR = """="""  or  OP_STR = """/=""" )
          then
            CODE_RECORD_EQUALITY( OP_STR, PRM_1, PRM_2, PRM1_TYPE );
            return;
          end if;
        end		COMPOSITE_OPERATORS;
			-------------------

        CODE_EXP( PRM_1 );
        if  PRM_2.TY = DN_AGGREGATE  then
	CODE_AGGREGATE( PRM_2, D( SM_EXP_TYPE, PRM_1 ) );
        else
	CODE_EXP( PRM_2 );
        end if;
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
	  PUT_LINE( "; CODE_DN_BLTN_OPERATOR_ID : EXPONENTIELLE ENTIERE GENERALE A FAIRE" );
	end if;

        elsif OP_STR = """AND""" then  PUT_LINE( tab & "ET"  );
        elsif OP_STR = """OR"""  then  PUT_LINE( tab & "OU"  );
        elsif OP_STR = """XOR""" then  PUT_LINE( tab & "OUX" );


	end if;
	return;
<<UNARY>>
	if  OP_STR = """-"""   then
	  if IS_FLOAT then PUT_LINE( tab & "FNEG" ); else PUT_LINE( tab & "NEG" ); end if;
	end if;
	if  OP_STR = """ABS"""  then
	if  IS_FLOAT  then PUT_LINE( tab & "FABS" ); else PUT_LINE( tab & "ABS" ); end if;
	end if;

	if  OP_STR = """NOT"""  then
		-- NOT scalaire (booleen 0/1) : le NOT COMPOSITE (tableaux de
		-- booleens) est route en amont par COMPOSITE_OPERATORS (lot D3)
		-- et n'atteint jamais ce point.
		-- Restaure apres regression : ce bloc, commente au lot D3, avait
		-- ete perdu par ecrasement lors d'une integration de fichier
		-- complet (voir journal, regression enum_test).
	  PUT_LINE( tab & "LI" & tab & "1" );
	  PUT_LINE( tab & "OUX" );							-- NOT booleen 0/1 (piege n 5)
          end if;

		-- Garde anti-trou-silencieux (piege n 53, meme anti-motif que
		-- CODE_RETURN / C7-C8) : un operateur unaire non reconnu doit se
		-- signaler a l'expansion, pas corrompre la pile en silence.
		-- "+" unaire = identite, legitimement sans emission.
	if  OP_STR /= """-"""  and then  OP_STR /= """ABS"""
	  and then  OP_STR /= """NOT"""  and then  OP_STR /= """+"""
	then
	  PUT_LINE( "; CODE_DN_BLTN_OPERATOR_ID : operateur unaire non gere " & OP_STR );
	  raise PROGRAM_ERROR;
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

          if  RET_TS.TY = DN_CONSTRAINED_RECORD  then						-- pilier 3.7 : vue contrainte -> base
            RET_TS := D( SM_BASE_TYPE, RET_TS );						-- (meme taille : layout additif ;
          end if;										--  symboles .size/.use__info de la base)
        end if;

        if  RET_TS /= TREE_VOID  and then  RET_TS.TY = DN_RECORD  then
          -- Allouer un doublet anonyme avec son espace donnees, empiler son adresse comme result__ofs
          declare
            ANON_STR  : constant STRING := ANONYMOUS_NAME_AT( FUNCTION_CALL );
            TYPE_NAME : TREE            := D( XD_SOURCE_NAME, RET_TS );
            TN_STR    : constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
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

    QUALIFIED	: TREE		:= D( AS_QUALIFIED, QUALIFIED_ALLOCATOR );
    DESIG_TYPE	: TREE		:= FULL_VIEW( D( SM_EXP_TYPE, QUALIFIED ) );
    ANON		:constant STRING	:= "NEW_" & NEW_LABEL;

    DESIG_NAME	: TREE		:= D( XD_SOURCE_NAME, DESIG_TYPE );
    DESIG_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, DESIG_NAME ) );

  begin
    if  DESIG_TYPE.TY = DN_RECORD  then
      PUT( tab & "LI" & tab );
      REGIONS_PATH( DESIG_NAME );
      PUT_LINE( DESIG_STR & ".size" );
    else
      PUT( tab & "Ld" & tab & IMAGE( DI( CD_LEVEL, DESIG_TYPE ) ) & ", " );
      REGIONS_PATH( DESIG_NAME );
      PUT_LINE( DESIG_STR & ".SIZ" );
      PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
      PUT_LINE( tab & "DIV" );
    end if;
    PUT_LINE( tab & "HEAP_ALLOC" );

    if  D( AS_EXP, QUALIFIED ).TY = DN_AGGREGATE  then
      PUT_LINE( "VAR " & ANON & "_ptr, q" );
      PUT_LINE( tab & "DUP" );
      PUT_LINE( tab & "Sa" & tab & IMAGE( CODI.CUR_LEVEL ) & ", " & ANON & "_ptr" );
      CODE_AGGREGATE( D( AS_EXP, QUALIFIED ), DESIG_TYPE );
      PUT_LINE( tab & "La" & tab & IMAGE( CODI.CUR_LEVEL ) & ", " & ANON & "_ptr" );
    end if;

  end	CODE_QUALIFIED_ALLOCATOR;
	------------------------


				----------------------
  procedure			CODE_SUBTYPE_ALLOCATOR	( SUBTYPE_ALLOCATOR	:TREE )
  is				----------------------
    DESIG_TYPE	: TREE	:= FULL_VIEW( D( SM_DESIG_TYPE, SUBTYPE_ALLOCATOR ) );
    DESIG_NAME	: TREE	:= D( XD_SOURCE_NAME, DESIG_TYPE );
    DESIG_STR	:constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, DESIG_NAME ) );

  begin
    if  DESIG_TYPE.TY = DN_RECORD  then
      PUT( tab & "LI" & tab );
      REGIONS_PATH( DESIG_NAME );
      PUT_LINE( DESIG_STR & ".size" );

    else
      PUT( tab & "Ld" & tab & IMAGE( DI( CD_LEVEL, DESIG_TYPE ) ) & ", " );
      REGIONS_PATH( DESIG_NAME );
      PUT_LINE( DESIG_STR & ".SIZ" );
      PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
      PUT_LINE( tab & "DIV" );
    end if;
    PUT_LINE( tab & "HEAP_ALLOC" );

  end	CODE_SUBTYPE_ALLOCATOR;
	----------------------


			--------------------
  procedure		CODE_ARRAY_AGGREGATE_OLD	( AGGREGATE, TYPE_SPEC :TREE )
  is			--------------------

    INDEX_S		: SEQ_TYPE;

  begin
      if  TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY  then
        INDEX_S := LIST( D( SM_INDEX_SUBTYPE_S, TYPE_SPEC ) );
      elsif  TYPE_SPEC.TY = DN_ARRAY  then
        INDEX_S := LIST( D( SM_INDEX_S, TYPE_SPEC ) );							-- DN_ARRAY se produit avec QUALIFIED
      else
        PUT_LINE( "; CODE_ARRAY_AGGREGATE TYPE_SPEC NON GERE " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
        raise PROGRAM_ERROR;
      end if;
				----------------------
				ASSIGN_ARRAY_AGGREGATE:
      declare
        NB_DIMS		: NATURAL		:= 0;
        IS_DYNAMIC		: BOOLEAN		:= FALSE;
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

        if  CODI.DEBUG  then PUT_LINE( tab50 & "; Assign_array_aggregate type " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
        end if;
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
	        PUT_LINE( tab & "CLAMP0" );
                end;

              elsif  CH.TY = DN_CHOICE_OTHERS  then

                -- others sans range explicite :
                -- le range vient du type cible de l'agregat.
                declare
                  BASE_ARRAY : TREE := D( SM_BASE_TYPE, TYPE_SPEC );
                  IDX_S      : SEQ_TYPE := LIST( D( SM_INDEX_S, BASE_ARRAY ) );
                  IDX        : TREE;
                  IDX_TYPE   : TREE;
                  RNG        : TREE;
                  LO         : TREE;
                  HI         : TREE;
                begin
                  POP( IDX_S, IDX );

                  -- Dans le cas :
                  --   array (1 .. LENGTH(...)) of Natural := (others => 0)
                  -- IDX est un DN_INDEX, dont SM_TYPE_SPEC porte le SM_RANGE.
                  IDX_TYPE := D( SM_TYPE_SPEC, IDX );
                  RNG      := D( SM_RANGE, IDX_TYPE );

                  LO := D( AS_EXP1, RNG );
                  HI := D( AS_EXP2, RNG );

                  -- COUNT = HI - LO + 1
                  CODE_EXP( HI );
                  CODE_EXP( LO );
                  PUT_LINE( tab & "SUB" );
                  PUT_LINE( tab & "INC" );
	        PUT_LINE( tab & "CLAMP0" );
                end;

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
          return;					-- traitement complet, pas de EXTRACT_DIMENSIONS
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
	    FST		: TREE	:= D( AS_EXP1, RNG );
	    LST		: TREE	:= D( AS_EXP2, RNG );
	  begin
	    if  FST.TY = DN_CONVERSION  then FST := D( AS_EXP, FST ); end if;
	    DIM_TBL( NB_DIMS ).FST := DI( SM_VALUE, FST );
	    if  LST.TY = DN_CONVERSION  then LST := D( AS_EXP, LST ); end if;
	    DIM_TBL( NB_DIMS ).LST := DI( SM_VALUE, LST );
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

  end	CODE_ARRAY_AGGREGATE_OLD;
	--------------------



-- Replacement proposal for EXPANDER.EXPRESSIONS.CODE_ARRAY_AGGREGATE.
-- The procedure is still an assigning aggregate: the destination data address
-- is expected on top of the LLIR stack and is consumed by the generated code.

  procedure		CODE_ARRAY_AGGREGATE	( AGGREGATE, TYPE_SPEC :TREE )
  is			--------------------

    MAX_DIMS	: constant NATURAL	:= 8;

    type DIM_INFO is record
      FST_EXP	: TREE;
      LST_EXP	: TREE;
    end record;

    DIM_TBL	: array( 1 .. MAX_DIMS ) of DIM_INFO;
    NB_DIMS	: NATURAL	:= 0;

    COMP_TYPE	: TREE		:= TREE_VOID;
    COMP_BITS	: INTEGER	:= 0;
    COMP_BYTES	: INTEGER	:= 0;

    LVL_STR	: constant STRING	:= IMAGE( CODI.CUR_LEVEL );
    ANON	: constant STRING	:= ANONYMOUS_NAME_AT( AGGREGATE ) & "_aga";

			---------
    function		VAR_NAME	( PREFIX :STRING; NUM :NATURAL ) return STRING
    is			---------
    begin
      return ANON & "." & PREFIX & "_" & IMAGE( NUM );
    end	VAR_NAME;
	---------

			--------
    function		FST_NAME	( NUM :NATURAL ) return STRING is
    begin
      return VAR_NAME( "_FST", NUM );
    end	FST_NAME;
	--------

			--------
    function		LST_NAME	( NUM :NATURAL ) return STRING is
    begin
      return VAR_NAME( "_LST", NUM );
    end	LST_NAME;
	--------

			--------
    function		LEN_NAME	( NUM :NATURAL ) return STRING is
    begin
      return VAR_NAME( "_LEN", NUM );
    end	LEN_NAME;
	--------

			--------
    function		STR_NAME	( NUM :NATURAL ) return STRING is
    begin
      return VAR_NAME( "_STR", NUM );
    end	STR_NAME;
	--------

			--------
    function		PTR_NAME	( NUM :NATURAL ) return STRING is
    begin
      return VAR_NAME( "_PTR", NUM );
    end	PTR_NAME;
	--------

			--------
    function		CNT_NAME	( NUM :NATURAL ) return STRING is
    begin
      return VAR_NAME( "_CNT", NUM );
    end	CNT_NAME;
	--------

			---------
    function		EMIS_NAME	( NUM :NATURAL ) return STRING is
    begin
      return VAR_NAME( "_EMIS", NUM );
    end	EMIS_NAME;
	---------

			-------------------
    procedure		ADD_DIMENSION_RANGE		( RNG :TREE )
    is			-------------------
      FST	: TREE;
      LST	: TREE;
    begin
      if  RNG = TREE_VOID  then
        PUT_LINE( "; CODE_ARRAY_AGGREGATE : range de dimension absente" );
        raise PROGRAM_ERROR;
      end if;

      if  NB_DIMS = MAX_DIMS  then
        PUT_LINE( "; CODE_ARRAY_AGGREGATE : plus de 8 dimensions" );
        raise PROGRAM_ERROR;
      end if;

      NB_DIMS := NB_DIMS + 1;

      FST := D( AS_EXP1, RNG );
      LST := D( AS_EXP2, RNG );

      DIM_TBL( NB_DIMS ).FST_EXP := FST;
      DIM_TBL( NB_DIMS ).LST_EXP := LST;
    end	ADD_DIMENSION_RANGE;
	---------------------

			-------------------
    procedure		ADD_INDEX_DIMENSION		( INDEX_NODE :TREE )
    is			-------------------
      RNG	: TREE;
      IDX_TYPE	: TREE;
    begin
      -- In a constrained array, SM_INDEX_SUBTYPE_S generally contains
      -- constrained subtypes that directly carry SM_RANGE.
      --
      -- In an unconstrained array, SM_INDEX_S may contain DN_INDEX nodes;
      -- their SM_TYPE_SPEC carries the range.  This is the shape seen in
      -- aggregates such as 1 .. LENGTH(...).
      if  INDEX_NODE.TY = DN_INDEX  then
        IDX_TYPE := D( SM_TYPE_SPEC, INDEX_NODE );
        RNG      := D( SM_RANGE, IDX_TYPE );
      else
        RNG      := D( SM_RANGE, INDEX_NODE );
      end if;

      ADD_DIMENSION_RANGE( RNG );
    end	ADD_INDEX_DIMENSION;
	-------------------

			--------------------
    function		FIRST_RANGE_FROM_AGG	( AGG :TREE ) return TREE
    is			--------------------
      RNG	: TREE		:= D( SM_DISCRETE_RANGE, AGG );
      SEQ	: SEQ_TYPE;
      ASSOC	: TREE;
      CHOICES	: SEQ_TYPE;
      CH	: TREE;
    begin
      if  RNG /= TREE_VOID  then
        return RNG;
      end if;

      SEQ := LIST( D( SM_NORMALIZED_COMP_S, AGG ) );
      while not  IS_EMPTY( SEQ )  loop
        POP( SEQ, ASSOC );

        if  ASSOC.TY = DN_NAMED  then
          CHOICES := LIST( D( AS_CHOICE_S, ASSOC ) );
          while not  IS_EMPTY( CHOICES )  loop
            POP( CHOICES, CH );
            if  CH.TY = DN_CHOICE_RANGE  then
              return D( AS_DISCRETE_RANGE, CH );
            end if;
          end loop;
        end if;
      end loop;

      return TREE_VOID;
    end	FIRST_RANGE_FROM_AGG;
	--------------------

			----------------------
    function		FIRST_NESTED_AGGREGATE	( AGG :TREE ) return TREE
    is			----------------------
      SEQ	: SEQ_TYPE	:= LIST( D( SM_NORMALIZED_COMP_S, AGG ) );
      ASSOC	: TREE;
      EXP	: TREE;
    begin
      while not  IS_EMPTY( SEQ )  loop
        POP( SEQ, ASSOC );

        if  ASSOC.TY = DN_AGGREGATE  then
          return ASSOC;

        elsif  ASSOC.TY = DN_NAMED  then
          EXP := D( AS_EXP, ASSOC );
          if  EXP.TY = DN_AGGREGATE  then
            return EXP;
          end if;
        end if;
      end loop;

      return TREE_VOID;
    end	FIRST_NESTED_AGGREGATE;
	----------------------

			-----------------
    procedure		ADD_AGG_DIMENSION	( AGG :TREE; INDEX_NODE :TREE )
    is			-----------------
      RNG	: TREE	:= TREE_VOID;
    begin
      if  AGG /= TREE_VOID  then
        RNG := FIRST_RANGE_FROM_AGG( AGG );
      end if;

      if  RNG /= TREE_VOID  then
        ADD_DIMENSION_RANGE( RNG );
      else
        -- Positional aggregate or constrained index fallback.
        ADD_INDEX_DIMENSION( INDEX_NODE );
      end if;
    end	ADD_AGG_DIMENSION;
	---------------------------

			------------------
    procedure		COLLECT_DIMENSIONS	( AGG :TREE; TS :TREE )
    is			------------------
      CUR_TYPE	: TREE	:= TS;
      CUR_AGG	: TREE	:= AGG;
      BASE_TYPE	: TREE;
      INDEX_S	: SEQ_TYPE;
      INDEX_NODE: TREE;
    begin
      while  CUR_TYPE.TY = DN_ARRAY
      or else CUR_TYPE.TY = DN_CONSTRAINED_ARRAY  loop

        if  CUR_TYPE.TY = DN_CONSTRAINED_ARRAY  then
          INDEX_S := LIST( D( SM_INDEX_SUBTYPE_S, CUR_TYPE ) );
        else
          INDEX_S := LIST( D( SM_INDEX_S, CUR_TYPE ) );
        end if;

        while not  IS_EMPTY( INDEX_S )  loop
          POP( INDEX_S, INDEX_NODE );

          if  CUR_TYPE.TY = DN_ARRAY  then
            ADD_AGG_DIMENSION( CUR_AGG, INDEX_NODE );
            if  CUR_AGG /= TREE_VOID  then
              CUR_AGG := FIRST_NESTED_AGGREGATE( CUR_AGG );
            end if;
          else
            ADD_INDEX_DIMENSION( INDEX_NODE );
          end if;
        end loop;

        BASE_TYPE := D( SM_BASE_TYPE, CUR_TYPE );
        COMP_TYPE := FULL_VIEW( D( SM_COMP_TYPE, BASE_TYPE ) );
        CUR_TYPE  := COMP_TYPE;
      end loop;

      if  NB_DIMS = 0  then
        PUT_LINE( "; CODE_ARRAY_AGGREGATE TYPE_SPEC NON GERE " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
        raise PROGRAM_ERROR;
      end if;

      if  COMP_TYPE = TREE_VOID  then
        BASE_TYPE := D( SM_BASE_TYPE, TYPE_SPEC );
        COMP_TYPE := FULL_VIEW( D( SM_COMP_TYPE, BASE_TYPE ) );
      end if;
    end	COLLECT_DIMENSIONS;
	----------------------

			----------------
    procedure		CODE_BOUND	( EXP :TREE )
    is			----------------
      B	: TREE	:= EXP;
    begin
      -- Do not use SM_VALUE here.  DN_CONSTRAINED_ARRAY may still contain
      -- dynamic bounds, for instance LENGTH(ACTUAL_LIST).
      while  B.TY = DN_CONVERSION  loop
        B := D( AS_EXP, B );
      end loop;

      CODE_EXP( B );
    end	CODE_BOUND;
	----------------

			------------------------
    procedure		DECLARE_TEMPORARIES
    is			------------------------
    begin
      PUT_LINE( "namespace " & ANON );
      for  I  in  1 .. NB_DIMS  loop
        PUT_LINE( "  VAR _FST_"  & IMAGE( I ) & ", d" );
        PUT_LINE( "  VAR _LST_"  & IMAGE( I ) & ", d" );
        PUT_LINE( "  VAR _LEN_"  & IMAGE( I ) & ", d" );
        PUT_LINE( "  VAR _STR_"  & IMAGE( I ) & ", d" );
        PUT_LINE( "  VAR _PTR_"  & IMAGE( I ) & ", q" );
        PUT_LINE( "  VAR _CNT_"  & IMAGE( I ) & ", d" );
        PUT_LINE( "  VAR _EMIS_" & IMAGE( I ) & ", d" );
      end loop;
      PUT_LINE( "end namespace" );
    end	DECLARE_TEMPORARIES;
	------------------------

			--------------------------
    procedure		COMPUTE_DYNAMIC_DIMS
    is			--------------------------
    begin
      for  I  in  1 .. NB_DIMS  loop
        CODE_BOUND( DIM_TBL( I ).FST_EXP );
        PUT_LINE( tab & "Sd  " & LVL_STR & ", " & FST_NAME( I ) );

        CODE_BOUND( DIM_TBL( I ).LST_EXP );
        PUT_LINE( tab & "Sd  " & LVL_STR & ", " & LST_NAME( I ) );

        PUT_LINE( tab & "Ld  " & LVL_STR & ", " & LST_NAME( I ) );
        PUT_LINE( tab & "Ld  " & LVL_STR & ", " & FST_NAME( I ) );
        PUT_LINE( tab & "SUB" );
        PUT_LINE( tab & "INC" );
        PUT_LINE( tab & "CLAMP0" );
        PUT_LINE( tab & "Sd  " & LVL_STR & ", " & LEN_NAME( I ) );
      end loop;

      PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BYTES ) );
      PUT_LINE( tab & "Sd  " & LVL_STR & ", " & STR_NAME( NB_DIMS ) );

      for  K  in reverse  1 .. NB_DIMS - 1  loop
        PUT_LINE( tab & "Ld  " & LVL_STR & ", " & STR_NAME( K + 1 ) );
        PUT_LINE( tab & "Ld  " & LVL_STR & ", " & LEN_NAME( K + 1 ) );
        PUT_LINE( tab & "MUL" );
        PUT_LINE( tab & "Sd  " & LVL_STR & ", " & STR_NAME( K ) );
      end loop;
    end	COMPUTE_DYNAMIC_DIMS;
	--------------------------

			---------------------
    procedure		EMIT_INC_EMIS	( DEPTH :NATURAL )
    is			---------------------
    begin
      PUT_LINE( tab & "Ld  " & LVL_STR & ", " & EMIS_NAME( DEPTH ) );
      PUT_LINE( tab & "INC" );
      PUT_LINE( tab & "Sd  " & LVL_STR & ", " & EMIS_NAME( DEPTH ) );
    end	EMIT_INC_EMIS;
	---------------------

			-----------------------
    procedure		EMIT_ADVANCE_PTR	( DEPTH :NATURAL )
    is			-----------------------
    begin
      PUT_LINE( tab & "La  " & LVL_STR & ", " & PTR_NAME( DEPTH ) );
      PUT_LINE( tab & "Ld  " & LVL_STR & ", " & STR_NAME( DEPTH ) );
      PUT_LINE( tab & "ADD" );
      PUT_LINE( tab & "Sa  " & LVL_STR & ", " & PTR_NAME( DEPTH ) );
    end	EMIT_ADVANCE_PTR;
	-----------------------

			-----------------
    procedure		EMIT_AGG_AT_DEPTH	( AGG :TREE; DEPTH :NATURAL );
			-----------------

			-------------
    procedure		EMIT_ONE_COMP	( COMP :TREE; DEPTH :NATURAL )
    is			-------------
    begin
      if  COMP.TY = DN_AGGREGATE  then
        PUT_LINE( tab & "La  " & LVL_STR & ", " & PTR_NAME( DEPTH ) );

        if  DEPTH < NB_DIMS  then
          EMIT_AGG_AT_DEPTH( COMP, DEPTH + 1 );
        else
          CODE_AGGREGATE( COMP, COMP_TYPE );
        end if;

      elsif  COMP.TY in CLASS_EXP  then
        EXPRESSIONS.CODE_EXP( COMP );
        PUT_LINE( tab & "SI" & EXP_TYPE_CHAR( COMP ) & "  " & LVL_STR & ", " & PTR_NAME( DEPTH ) & ", 0" );

      else
        PUT_LINE( "; EMIT_ONE_COMP : composante non geree " & NODE_NAME'IMAGE( COMP.TY ) );
      end if;

      EMIT_ADVANCE_PTR( DEPTH );
      EMIT_INC_EMIS( DEPTH );
    end	EMIT_ONE_COMP;
	-------------

			---------------------
    procedure		EMIT_COUNT_FOR_CHOICE	( CH :TREE; DEPTH :NATURAL )
    is			---------------------
      RNG	: TREE;
    begin
      if  CH.TY = DN_CHOICE_RANGE  then
        RNG := D( AS_DISCRETE_RANGE, CH );
        CODE_BOUND( D( AS_EXP2, RNG ) );
        CODE_BOUND( D( AS_EXP1, RNG ) );
        PUT_LINE( tab & "SUB" );
        PUT_LINE( tab & "INC" );
        PUT_LINE( tab & "CLAMP0" );

      elsif  CH.TY = DN_CHOICE_OTHERS  then
        PUT_LINE( tab & "Ld  " & LVL_STR & ", " & LEN_NAME( DEPTH ) );
        PUT_LINE( tab & "Ld  " & LVL_STR & ", " & EMIS_NAME( DEPTH ) );
        PUT_LINE( tab & "SUB" );

      else
        -- Single discrete choice.
        PUT_LINE( tab & "LI" & tab & "1" );
      end if;
    end	EMIT_COUNT_FOR_CHOICE;
	---------------------

			------------------------
    procedure		EMIT_REPEATED_COMP	( COMP :TREE; CH :TREE; DEPTH :NATURAL )
    is			------------------------
      LBL_LOOP	: constant STRING	:= NEW_LABEL;
      LBL_END	: constant STRING	:= NEW_LABEL;
    begin
      EMIT_COUNT_FOR_CHOICE( CH, DEPTH );
      PUT_LINE( tab & "Sd  " & LVL_STR & ", " & CNT_NAME( DEPTH ) );

      PUT_LINE( tab & "Ld  " & LVL_STR & ", " & CNT_NAME( DEPTH ) );
      PUT_LINE( tab & "LI" & tab & "0" );
      PUT_LINE( tab & "CLE" );
      PUT_LINE( tab & "BT  " & LBL_END );

      PUT_LINE( LBL_LOOP & ':' );
      EMIT_ONE_COMP( COMP, DEPTH );

      PUT_LINE( tab & "Ld  " & LVL_STR & ", " & CNT_NAME( DEPTH ) );
      PUT_LINE( tab & "DEC" );
      PUT_LINE( tab & "DUP" );
      PUT_LINE( tab & "Sd  " & LVL_STR & ", " & CNT_NAME( DEPTH ) );
      PUT_LINE( tab & "LI" & tab & "0" );
      PUT_LINE( tab & "CGT" );
      PUT_LINE( tab & "BT  " & LBL_LOOP );

      PUT_LINE( LBL_END & ':' );
    end	EMIT_REPEATED_COMP;
	------------------------

			-----------------
    procedure		EMIT_AGG_AT_DEPTH	( AGG :TREE; DEPTH :NATURAL )
    is			-----------------
      SEQ	: SEQ_TYPE	:= LIST( D( SM_NORMALIZED_COMP_S, AGG ) );
      ASSOC	: TREE;
    begin
      -- Consume the incoming data address and keep it in a depth-local
      -- temporary.  This avoids carrying the current pointer on the LLIR
      -- stack while nested dynamic loops are generated.
      PUT_LINE( tab & "Sa  " & LVL_STR & ", " & PTR_NAME( DEPTH ) );

      PUT_LINE( tab & "LI" & tab & "0" );
      PUT_LINE( tab & "Sd  " & LVL_STR & ", " & EMIS_NAME( DEPTH ) );

      while not  IS_EMPTY( SEQ )  loop
        POP( SEQ, ASSOC );

        if  ASSOC.TY = DN_NAMED  then
          declare
            COMP_EXP	: TREE		:= D( AS_EXP, ASSOC );
            CHOICES		: SEQ_TYPE	:= LIST( D( AS_CHOICE_S, ASSOC ) );
            CH		: TREE;
            HAD_CHOICE	: BOOLEAN	:= FALSE;
          begin
            while not  IS_EMPTY( CHOICES )  loop
              POP( CHOICES, CH );
              HAD_CHOICE := TRUE;
              EMIT_REPEATED_COMP( COMP_EXP, CH, DEPTH );
            end loop;

            if  not HAD_CHOICE  then
              EMIT_ONE_COMP( COMP_EXP, DEPTH );
            end if;
          end;

        else
          EMIT_ONE_COMP( ASSOC, DEPTH );
        end if;
      end loop;
    end	EMIT_AGG_AT_DEPTH;
	-----------------

  begin
    if  TYPE_SPEC.TY /= DN_CONSTRAINED_ARRAY
    and then TYPE_SPEC.TY /= DN_ARRAY  then
      PUT_LINE( "; CODE_ARRAY_AGGREGATE TYPE_SPEC NON GERE " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
      raise PROGRAM_ERROR;
    end if;

    if  CODI.DEBUG  then
      PUT_LINE( tab50 & "; Assign_array_aggregate dynamic type " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
    end if;

    COLLECT_DIMENSIONS( AGGREGATE, TYPE_SPEC );

    COMP_TYPE := FULL_VIEW( COMP_TYPE );
    COMP_BITS  := COMP_SIZE_BITS( COMP_TYPE );
    COMP_BYTES := COMP_BITS / CODI.STORAGE_UNIT;
    if  COMP_BYTES = 0  then
      COMP_BYTES := 1;
    end if;

    DECLARE_TEMPORARIES;
    COMPUTE_DYNAMIC_DIMS;
    EMIT_AGG_AT_DEPTH( AGGREGATE, 1 );

  end	CODE_ARRAY_AGGREGATE;
	--------------------


				--------------
  procedure			CODE_AGGREGATE		( AGGREGATE, TYPE_SPEC :TREE )
  is				--------------

    EFFECTIVE_TYPE		: TREE			:= TYPE_SPEC;
    LVL_STR		:constant	STRING		:= IMAGE(	CODI.CUR_LEVEL );
    NORM_SEQ		: SEQ_TYPE		:= LIST( D( SM_NORMALIZED_COMP_S, AGGREGATE ) );

  begin
    while  EFFECTIVE_TYPE.TY = DN_PRIVATE  or else  EFFECTIVE_TYPE.TY = DN_L_PRIVATE  loop
      EFFECTIVE_TYPE := D( SM_TYPE_SPEC, EFFECTIVE_TYPE );
    end loop;

    if  EFFECTIVE_TYPE.TY = DN_CONSTRAINED_RECORD  then
      EFFECTIVE_TYPE := D( SM_BASE_TYPE, EFFECTIVE_TYPE );
    end if;

    if  EFFECTIVE_TYPE = TREE_VOID  then
      PUT_LINE( "; CODE_AGGREGATE : type contexte absent pour l'agregat" );
      raise PROGRAM_ERROR;
    end if;

    if  EFFECTIVE_TYPE.TY = DN_CONSTRAINED_ARRAY  or  TYPE_SPEC.TY = DN_ARRAY  then				-- L'adresse de debut data est deja empilee
      CODE_ARRAY_AGGREGATE( AGGREGATE, EFFECTIVE_TYPE );

    elsif  EFFECTIVE_TYPE.TY = DN_RECORD  then								-- L'adresse du doublet est deja empilee
      declare
        TYPE_NAME		: TREE			:= D( XD_SOURCE_NAME, EFFECTIVE_TYPE );
        TYPE_NAME_STR	:constant	STRING		:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );

      begin
        if REPRESENTED_ITEMS.HAS_RECORD_REP( EFFECTIVE_TYPE ) then							-- Intercepter les records representes
	REPRESENTED_ITEMS.CODE_REPRESENTED_RECORD_AGGREGATE( AGGREGATE, EFFECTIVE_TYPE );
	return;
        end if;

        if  CODI.DEBUG  then PUT_LINE( tab50 & "; Assign_record_aggregate type " & NODE_NAME'IMAGE( EFFECTIVE_TYPE.TY ) );
        end if;

			-- Pilier 3.7 : chemin canonique.  SM_NORMALIZED_COMP_S est la liste
			-- PLATE des valeurs dans l'ordre [discriminants] ++ [comp_list racine]
			-- ++ [variante active, recursivement] -- le front-end a deja normalise
			-- les formes positionnelle, nommee et mixte.  La variante active est
			-- choisie par la valeur STATIQUE du discriminant gouvernant (garantie
			-- RM83 4.3.1 des qu'une partie variante existe).
				---------------------------
				CANONICAL_RECORD_AGGREGATE:
        declare
	MAX_DISCR	:constant		:= 15;
	DISCR_IDS	: array ( 1 .. MAX_DISCR ) of TREE;
	DISCR_VALS	: array ( 1 .. MAX_DISCR ) of INTEGER;
	DISCR_CNT	: NATURAL		:= 0;
	COMP_EXP	: TREE;

		------------------
	procedure	EMIT_ONE_COMPONENT	( COMP_ID : TREE; COMP_EXP : TREE )
	is		------------------
	  COMP_TYPE	: TREE		:= D( SM_OBJ_TYPE, COMP_ID );
	  COMP_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, COMP_ID ) );
	begin
	  while  COMP_TYPE.TY = DN_PRIVATE  or else  COMP_TYPE.TY = DN_L_PRIVATE  loop
	    COMP_TYPE := D( SM_TYPE_SPEC, COMP_TYPE );
	  end loop;

	  if  COMP_TYPE.TY = DN_CONSTRAINED_RECORD  then
	    COMP_TYPE := D( SM_BASE_TYPE, COMP_TYPE );
	  end if;

	  PUT_LINE( tab & "DUP" );
	  PUT( tab & "LVA" & tab & ", " );
	  CODI.REGIONS_PATH( TYPE_NAME );
	  PUT_LINE( TYPE_NAME_STR & "." & COMP_STR );

	  if  COMP_EXP.TY = DN_AGGREGATE  then
	    CODE_AGGREGATE( COMP_EXP, COMP_TYPE );

	  elsif  COMP_TYPE.TY = DN_RECORD  then
	    PUT( tab & "LI" & tab );
	    CODI.REGIONS_PATH( D( XD_SOURCE_NAME, COMP_TYPE ) );
	    PUT_LINE( '_' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, COMP_TYPE ) ) ) & ".size" );

	    CODE_EXP( COMP_EXP );
	    PUT_LINE( tab & "La  ,  0" );
	    PUT_LINE( tab & "BLKMOV" );

	  else
	    CODE_EXP( COMP_EXP );
	    PUT_LINE( tab & "S" & CODI.OPER_SIZ_CHAR( COMP_TYPE ) );
	  end if;

	end	EMIT_ONE_COMPONENT;
		------------------

		------------------
	function	LOOKUP_DISCR_VALUE	( DISCR_DEFN : TREE ) return INTEGER
	is		------------------
	begin
	  for I in 1 .. DISCR_CNT loop
	    if  DISCR_IDS( I ) = DISCR_DEFN  then
	      return DISCR_VALS( I );
	    end if;
	  end loop;

	  PUT_LINE( "; CODE_AGGREGATE record : discriminant de variante sans valeur statique" );
	  raise PROGRAM_ERROR;
	end	LOOKUP_DISCR_VALUE;
		------------------

		---------------
	function	VARIANT_MATCHES	( VAR_E : TREE; VAL : INTEGER ) return BOOLEAN
	is		---------------
	  CHOICES	: SEQ_TYPE	:= LIST( D( AS_CHOICE_S, VAR_E ) );
	  CH		: TREE;
	begin
	  while  not IS_EMPTY( CHOICES )  loop
	    POP( CHOICES, CH );

	    if  CH.TY = DN_CHOICE_EXP  then
	      if  DI( SM_VALUE, D( AS_EXP, CH ) ) = VAL  then
	        return TRUE;
	      end if;

	    elsif  CH.TY = DN_CHOICE_OTHERS  then
	      return TRUE;								-- toujours en derniere position (RM83 3.7.3)

	    else
	      PUT_LINE( "; CODE_AGGREGATE record : choix de variante non gere "
			& NODE_NAME'IMAGE( CH.TY ) );
	      raise PROGRAM_ERROR;
	    end if;
	  end loop;

	  return FALSE;
	end	VARIANT_MATCHES;
		---------------

		--------------
	procedure	WALK_COMP_LIST	( CL : TREE )
	is		--------------
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

	          if  IS_EMPTY( NORM_SEQ )  then
	            PUT_LINE( "; CODE_AGGREGATE record : forme normalisee incomplete" );
	            raise PROGRAM_ERROR;
	          end if;

	          POP( NORM_SEQ, COMP_EXP );
	          EMIT_ONE_COMPONENT( COMP_ID, COMP_EXP );
	        end loop;
	      end;
	    end if;
	  end loop;

	  declare
	    VP	: TREE	:= D( AS_VARIANT_PART, CL );
	  begin
	    if  VP /= TREE_VOID  and then  VP /= TREE_NIL  then
	      declare
	        GOV_DEFN	: TREE		:= D( SM_DEFN, D( AS_NAME, VP ) );
	        VAL	: INTEGER	:= LOOKUP_DISCR_VALUE( GOV_DEFN );
	        VAR_S	: SEQ_TYPE	:= LIST( D( AS_VARIANT_S, VP ) );
	        VAR_E	: TREE;
	      begin
	        while  not IS_EMPTY( VAR_S )  loop
	          POP( VAR_S, VAR_E );

	          if  VAR_E.TY = DN_VARIANT  and then  VARIANT_MATCHES( VAR_E, VAL )  then
	            WALK_COMP_LIST( D( AS_COMP_LIST, VAR_E ) );
	            return;
	          end if;
	        end loop;

	        PUT_LINE( "; CODE_AGGREGATE record : aucune variante pour la valeur"
			& INTEGER'IMAGE( VAL ) );
	        raise PROGRAM_ERROR;
	      end;
	    end if;
	  end;

	end	WALK_COMP_LIST;
		--------------

        begin
	if  not IS_EMPTY( NORM_SEQ )  then

				-- 1. Discriminants, dans l'ordre de declaration ; leur valeur
				-- statique (SM_VALUE) est retenue pour choisir les variantes.
	  declare
	    DSCRMT_DECL_S	: SEQ_TYPE	:= LIST( D( SM_DISCRIMINANT_S, EFFECTIVE_TYPE ) );
	    DSCRMT_DECL	: TREE;
	  begin
	    while  not IS_EMPTY( DSCRMT_DECL_S )  loop
	      POP( DSCRMT_DECL_S, DSCRMT_DECL );

	      declare
	        DISCR_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, DSCRMT_DECL ) );
	        DISCR_ID	: TREE;
	      begin
	        while  not IS_EMPTY( DISCR_ID_S )  loop
	          POP( DISCR_ID_S, DISCR_ID );

	          if  IS_EMPTY( NORM_SEQ )  then
	            PUT_LINE( "; CODE_AGGREGATE record : discriminant absent de la forme normalisee" );
	            raise PROGRAM_ERROR;
	          end if;

	          POP( NORM_SEQ, COMP_EXP );

	          declare
	            SV	: TREE	:= D( SM_VALUE, COMP_EXP );
	          begin
	            if  ( ( SV.PT  = HI  and then  SV.NOTY = DN_NUM_VAL )
	         or else ( SV.PT /= HI  and then  SV.TY   = DN_NUM_VAL ) )
	              and then  DISCR_CNT < MAX_DISCR
	            then
	              DISCR_CNT := DISCR_CNT + 1;
	              DISCR_IDS ( DISCR_CNT ) := DISCR_ID;
	              DISCR_VALS( DISCR_CNT ) := DI( SM_VALUE, COMP_EXP );
	            end if;
	          end;

	          EMIT_ONE_COMPONENT( DISCR_ID, COMP_EXP );
	        end loop;
	      end;
	    end loop;
	  end;

				-- 2. Comp_list racine puis variante active, recursivement.
	  WALK_COMP_LIST( D( SM_COMP_LIST, EFFECTIVE_TYPE ) );

	  PUT_LINE( tab & "DROP" );							-- enlever @data record
	  return;
	end if;
        end	CANONICAL_RECORD_AGGREGATE;
		---------------------------

			-- Repli (agregat sans forme normalisee) : chemins historiques.
				-----------------------------
				NAMED_ASSIGN_RECORD_AGGREGATE:

        declare
	ASSOC_S   : SEQ_TYPE := LIST( D( AS_GENERAL_ASSOC_S, AGGREGATE ) );
	ASSOC     : TREE;
	HAS_NAMED : BOOLEAN := FALSE;
		------------------
	procedure	STORE_RECORD_FIELD ( FIELD_ID : TREE; FIELD_EXP : TREE )
	is	------------------
	  FIELD_TYPE	: TREE		:= D( SM_OBJ_TYPE, FIELD_ID );
	  FIELD_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, FIELD_ID ) );
	begin
	  while  FIELD_TYPE.TY = DN_PRIVATE  or else  FIELD_TYPE.TY = DN_L_PRIVATE  loop
	    FIELD_TYPE := D( SM_TYPE_SPEC, FIELD_TYPE );
	  end loop;

	  if  FIELD_TYPE.TY = DN_CONSTRAINED_RECORD  then
	    FIELD_TYPE := D( SM_BASE_TYPE, FIELD_TYPE );
	  end if;

	  PUT_LINE( tab & "DUP" );
	  PUT( tab & "LVA" & tab & ", " );
	  CODI.REGIONS_PATH( TYPE_NAME );
	  PUT_LINE( TYPE_NAME_STR & "." & FIELD_STR );

	  if  FIELD_EXP.TY = DN_AGGREGATE  then
	    CODE_AGGREGATE( FIELD_EXP, FIELD_TYPE );

	  elsif  FIELD_TYPE.TY = DN_RECORD  then
	    PUT( tab & "LI" & tab );
	    CODI.REGIONS_PATH( D( XD_SOURCE_NAME, FIELD_TYPE ) );
	    PUT_LINE( '_' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, FIELD_TYPE ) ) ) & ".size" );

	    EXPRESSIONS.CODE_EXP( FIELD_EXP );
	    PUT_LINE( tab & "La  ,  0" );
	    PUT_LINE( tab & "BLKMOV" );

	  else
	    EXPRESSIONS.CODE_EXP( FIELD_EXP );
	    PUT_LINE( tab & "S" & CODI.OPER_SIZ_CHAR( FIELD_TYPE ) );
	  end if;

          end	STORE_RECORD_FIELD;
		------------------

        begin
	while  not IS_EMPTY( ASSOC_S )  loop
	  POP( ASSOC_S, ASSOC );

	  if  ASSOC.TY = DN_NAMED  then
	    HAS_NAMED := TRUE;

	    declare
	      FIELD_EXP	: TREE		:= D( AS_EXP, ASSOC );
	      CHOICES	: SEQ_TYPE	:= LIST( D( AS_CHOICE_S, ASSOC ) );
	      CH		: TREE;
	      FIELD_ID	: TREE;
	    begin
	      while  not IS_EMPTY( CHOICES )  loop
	        POP( CHOICES, CH );

	        if  CH.TY = DN_CHOICE_EXP  then
		FIELD_ID := D( SM_DEFN, D( AS_EXP, CH ) );

		if  FIELD_ID = TREE_VOID  or else  FIELD_ID = TREE_NIL  then
		  PUT_LINE( "; CODE_AGGREGATE record : choix sans SM_DEFN" );
		  raise PROGRAM_ERROR;
		end if;

		STORE_RECORD_FIELD( FIELD_ID, FIELD_EXP );

	        elsif CH.TY = DN_CHOICE_OTHERS then
		PUT_LINE( "; CODE_AGGREGATE record : others non encore traite" );
		raise PROGRAM_ERROR;

	        else
		PUT_LINE( "; CODE_AGGREGATE record : choix non gere " & NODE_NAME'IMAGE( CH.TY ) );
		raise PROGRAM_ERROR;
	        end if;
	      end loop;
	    end;
	  end if;
	end loop;

	if  HAS_NAMED  then
	  PUT_LINE( tab & "DROP" );      -- enlever @record initial
	  return;
	end if;
        end	NAMED_ASSIGN_RECORD_AGGREGATE;
		-----------------------------

				-----------------------
				ASSIGN_RECORD_AGGREGATE:
        declare
	COMP_DECL_S	: SEQ_TYPE	:= LIST( D( AS_DECL_S, D( SM_COMP_LIST, EFFECTIVE_TYPE ) ) );
	COMP_EXP		: TREE;
	COMP_DECL		: TREE;

        begin
SCAN_DECLS:
	while not IS_EMPTY( COMP_DECL_S )  loop
	  POP( COMP_DECL_S, COMP_DECL );

if  COMP_DECL.TY /= DN_NULL_COMP_DECL  then

	  declare
	    COMP_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, COMP_DECL ) );
	    COMP_ID	: TREE;

	  begin
SCAN_IDS:
	    while  not IS_EMPTY( COMP_ID_S )  loop
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
		  EFFECTIVE_COMP_TYPE	: TREE	:= COMP_TYPE;
		begin
	            while  EFFECTIVE_COMP_TYPE.TY = DN_L_PRIVATE
			or  EFFECTIVE_COMP_TYPE.TY = DN_PRIVATE  loop
	              EFFECTIVE_COMP_TYPE := D( SM_TYPE_SPEC, EFFECTIVE_COMP_TYPE );
	            end loop;

	            if  EFFECTIVE_COMP_TYPE.TY = DN_RECORD  then
	            -- Composante record : BLKMOV depuis les donnees de la source vers l'offset dans le parent
	              declare
	                CN_STR : constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, EFFECTIVE_COMP_TYPE ) ) );
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
	  end if;
          end loop		SCAN_DECLS;
          PUT_LINE( tab & "DROP" );									-- Enlever l'adresse de debut data record de reference

        end	ASSIGN_RECORD_AGGREGATE;
		-----------------------
      end;
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
	    PUT_LINE( tab & "LIq , -" & TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.DENOM" );			-- Charge l'entier DENOM small

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
    PUT_LINE( tab & "LI" & tab & "0" );
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
		PUT_LINE( tab & "LIq , -" & TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.NUMER" );		-- Charge l'entier NUMER
		PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		PUT_LINE( tab & "LIq , -" & TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.DENOM" );		-- Charge l'entier DENOM
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
		  PUT_LINE( tab & "LIq , -" & SRC_TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.NUMER" );		-- Charge l'entier NUMER
		  PUT_LINE( tab & "CVTIF" );
		  PUT_LINE( tab & "FMUL" );
		  PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		  PUT_LINE( tab & "LIq , -" & SRC_TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.DENOM" );		-- Charge l'entier DENOM
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
		PUT_LINE( tab & "LIq , -" & TARGET_TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.DENOM" );		-- Charge l'entier DENOM
		PUT_LINE( tab & "CVTIF" );
		PUT_LINE( tab & "FMUL" );								-- MANTISSA * DENOM
		PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		PUT_LINE( tab & "LIq , -" & TARGET_TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.NUMER" );		-- Charge l'entier NUMER
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
		PUT_LINE( tab & "LIq , -" & TARGET_TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.DENOM" );		-- Charge l'entier DENOM
		PUT_LINE( tab & "La " & IMAGE( GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );		-- Adresse de frame generique
		PUT_LINE( tab & "LIq , -" & TARGET_TYPE_STR & "__u_ofs, STANDARD._FIXED_USE_INFO.NUMER" );		-- Charge l'entier NUMER
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
    PUT_LINE( "  VAR _COMP_SIZ, d" );
    PUT_LINE( "  VAR _FST_1,    d" );
    PUT_LINE( "  VAR _LST_1,    d" );
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
        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "._FST_1" );
        CODE_EXP( D( AS_EXP2, DR ) );
        PUT_LINE( tab & "DUP" );
        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "._LST_1" );
      else
        -- Pas de range explicite : FST=1, LST=nb d'elements dans l'agrégat
        PUT_LINE( tab & "LI  1" );
        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "._FST_1" );
        -- LST = nombre d'associations (taille de NORM_SEQ)
        -- Pour 'others', c'est la range entière -> fallback LI 0
        PUT_LINE( tab & "LI  0" );
        PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "._LST_1" );
      end if;
    end;
    -- COMP_SIZ
    PUT_LINE( tab & "LI"  & tab & IMAGE( COMP_BITS ) );
    PUT_LINE( tab & "Sd  " & LVL & ", " & ANON & "._COMP_SIZ" );

    -- ---- Allouer (LST - FST + 1) * COMP_BYTES octets sur co-pile ----
    PUT_LINE( tab & "Ld  " & LVL & ", " & ANON & "._LST_1" );
    PUT_LINE( tab & "INC" );
    PUT_LINE( tab & "Ld  " & LVL & ", " & ANON & "._FST_1" );
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
    PUT_LINE( tab & "Ld  " & LVL & ", " & ANON & "._LST_1" );
    PUT_LINE( tab & "INC" );
    PUT_LINE( tab & "Ld  " & LVL & ", " & ANON & "._FST_1" );
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
              PUT_LINE( "  VAR _COMP_SIZ, d" );
              PUT_LINE( "  VAR _FST_1,    d" );
              PUT_LINE( "  VAR _LST_1,    d" );
              PUT_LINE( "end namespace" );
              PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
              PUT_LINE( "VAR" & tab & ANON & "__u,   q" );

              -- ---- Calculer et stocker FST_1 ----
              CODE_EXP( D( AS_EXP1, RNG ) );               -- 1 (statique mais on le génère)
              PUT_LINE( tab & "Sd  " & LVL_STR & ", " & ANON & "_info._FST_1" );

              -- ---- Calculer et stocker LST_1 = COMPL ----
              CODE_EXP( D( AS_EXP2, RNG ) );               -- COMPL (dynamique)
              PUT_LINE( tab & "DUP" );
              PUT_LINE( tab & "Sd  " & LVL_STR & ", " & ANON & "_info._LST_1" );

              -- ---- COUNT = LST_1 - FST_1 + 1 (LST encore en pile) ----
              CODE_EXP( D( AS_EXP1, RNG ) );               -- FST_1
              PUT_LINE( tab & "SUB" );
              PUT_LINE( tab & "INC" );
	    PUT_LINE( tab & "CLAMP0" );
              -- ---- Stocker COMP_SIZ en bits ----
              PUT_LINE( tab & "LI" & tab & IMAGE( COMP_BITS ) );
              PUT_LINE( tab & "Sd  " & LVL_STR & ", " & ANON & "_info._COMP_SIZ" );

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

          elsif  AGG_TYPE.TY = DN_CONSTRAINED_ARRAY  then
            -- Agrégat qualifié d'un sous-type CONTRAINT : VEC3'(1 => 5, others => 8).
            -- Bornes et SIZ viennent du descripteur du sous-type : __u pointe sur le
            -- bloc info du TYPE, aucune copie d'info ; data alloué sur la co-pile.
            declare
              LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
              ANON		:constant STRING	:= ANONYMOUS_NAME_AT( SRC_EXP );
              TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, AGG_TYPE );
	    TYPE_LVL	: constant STRING	:= IMAGE( DI( CD_LEVEL, AGG_TYPE ) );
              TN_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
            begin
              PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
              PUT_LINE( "VAR" & tab & ANON & "__u,   q" );

              PUT( tab & "La  " & TYPE_LVL & ", " );			-- __u := use__info du type
              CODI.REGIONS_PATH( TYPE_NAME );
              PUT_LINE( TN_STR & ".use__info" );
              PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON & "__u" );

              PUT( tab & "Ld  " & TYPE_LVL & ", " );			-- data := CO_VAR( SIZ/8 )
              CODI.REGIONS_PATH( TYPE_NAME );
              PUT_LINE( TN_STR & ".SIZ" );
              PUT_LINE( tab & "LI" & tab & IMAGE( CODI.STORAGE_UNIT ) );
              PUT_LINE( tab & "DIV" );
              PUT_LINE( tab & "CO_VAR" );
              PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON & "_disp" );

              PUT_LINE( tab & "La  " & LVL_STR & ", " & ANON & "_disp" );	-- @data pour CODE_AGGREGATE
              CODE_AGGREGATE( SRC_EXP, AGG_TYPE );

              PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );	-- @doublet
            end;

          elsif  AGG_TYPE.TY = DN_RECORD  or else  AGG_TYPE.TY = DN_CONSTRAINED_RECORD  then
            -- Pilier 3.7 lot R-B : agregat qualifie de record -- MUT'(LEAF, 3, 9).
            -- Meme mecanique que le sous-type contraint de tableau ci-dessus :
            -- doublet anonyme (data en VAR de taille statique du record de BASE),
            -- __u := use__info du type, @data pour CODE_AGGREGATE, et @doublet
            -- laisse sur la pile (convention des expressions record).
            declare
              REC_TS	: TREE	:= AGG_TYPE;
            begin
              if  REC_TS.TY = DN_CONSTRAINED_RECORD  then			-- vue contrainte -> base
                REC_TS := D( SM_BASE_TYPE, REC_TS );
              end if;

              declare
                LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
                ANON	:constant STRING	:= ANONYMOUS_NAME_AT( SRC_EXP );
                TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, REC_TS );
                TYPE_LVL	:constant STRING	:= IMAGE( DI( CD_LEVEL, REC_TS ) );
                TN_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
              begin
                PUT_LINE( "VAR" & tab & ANON & "_disp, q" );
                PUT_LINE( "VAR" & tab & ANON & "__u,   q" );
                PUT( "VAR" & tab & ANON & "__dat, " );
                CODI.REGIONS_PATH( TYPE_NAME );
                PUT_LINE( TN_STR & ".size" );

                PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "__dat" );
                PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON & "_disp" );

                PUT( tab & "La  " & TYPE_LVL & ", " );			-- __u := use__info du type
                CODI.REGIONS_PATH( TYPE_NAME );
                PUT_LINE( TN_STR & ".use__info" );
                PUT_LINE( tab & "Sa  " & LVL_STR & ", " & ANON & "__u" );

                PUT_LINE( tab & "La  " & LVL_STR & ", " & ANON & "_disp" );	-- @data pour CODE_AGGREGATE
                CODE_AGGREGATE( SRC_EXP, AGG_TYPE );

                PUT_LINE( tab & "LVA " & LVL_STR & ", " & ANON & "_disp" );	-- @doublet
              end;
            end;

          else
            PUT_LINE( "; CODE_QUALIFIED : agregat qualifie de type non gere "
		& NODE_NAME'IMAGE( AGG_TYPE.TY ) );
            raise PROGRAM_ERROR;
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
    EXP  : TREE := D( AS_EXP, RANGE_MEMBERSHIP );
    RNG  : TREE := D( AS_RANGE, RANGE_MEMBERSHIP );
    OP   : TREE := D( AS_MEMBERSHIP_OP, RANGE_MEMBERSHIP );
  begin
  -- EXP >= FIRST
    CODE_EXP( EXP );
    CODE_DISCRETE_RANGE_BOUND( RNG, IS_LAST => FALSE );
    PUT_LINE( tab & "CGE" );

  -- LAST >= EXP, équivalent EXP <= LAST
    CODE_DISCRETE_RANGE_BOUND( RNG, IS_LAST => TRUE );
    CODE_EXP( EXP );
    PUT_LINE( tab & "CGE" );

    PUT_LINE( tab & "ET" );

    if  OP.TY = DN_NOT_IN  then
      PUT_LINE( tab & "LI" & tab & "1" );
      PUT_LINE( tab & "OUX" );
    end if;
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

    when DN_RECORD | DN_CONSTRAINED_RECORD
	| DN_ARRAY | DN_CONSTRAINED_ARRAY
	| DN_PRIVATE | DN_L_PRIVATE =>
      LOAD_MEM( VC_ID );

    when others
    =>
      PUT_LINE( ';'	& tab & "CODE_VC_ID ERROR " &	NODE_NAME'IMAGE( VC_TYPE.TY ) );
      raise PROGRAM_ERROR;
    end case;

  end	CODE_VC_ID;
	----------

			--^^^^^^^^^^^^^^^^^^^^^--
  procedure		CODE_DISCRETE_RANGE_BOUND	( DISCRETE_RANGE :TREE; IS_LAST :BOOLEAN )
  is			-------------------------

		--------------------------
    procedure	CODE_RANGE_ATTRIBUTE_BOUND	( RANGE_ATTRIBUTE :TREE )
    is		--------------------------

      RAW_PREFIX  : TREE := D( AS_NAME, RANGE_ATTRIBUTE );
      PREFIX_NAME	: TREE	:= RAW_PREFIX;
      DIM_EXP	: TREE	:= D( AS_EXP, RANGE_ATTRIBUTE );
      NUM_DIM	: INTEGER	:= 1;

    begin
      if  DIM_EXP /= TREE_VOID  then
        NUM_DIM := DI( SM_VALUE, DIM_EXP );
      end if;

  -- Cas important pour A62006D :
  -- C3.X'RANGE, où C3.X est un DN_SELECTED et X est un composant array.
  -- Il ne faut pas prendre LAST_OF_SELECTED, car X seul est un component_id.
      if  RAW_PREFIX.TY = DN_SELECTED  then
        declare
	PREFIX_TYPE : TREE := D( SM_EXP_TYPE, RAW_PREFIX );
        begin
	while  PREFIX_TYPE.TY = DN_PRIVATE  or else  PREFIX_TYPE.TY = DN_L_PRIVATE  loop
	  PREFIX_TYPE := D( SM_TYPE_SPEC, PREFIX_TYPE );
	end loop;

	if  PREFIX_TYPE.TY = DN_CONSTRAINED_ARRAY  or else  PREFIX_TYPE.TY = DN_ARRAY  then
	  declare
	    TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, PREFIX_TYPE );
	    TYPE_STR	: constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	    TYPE_LVL	: INTEGER		:= DI( CD_LEVEL, PREFIX_TYPE );
	  begin
	    PUT( tab & "Ld" & tab & IMAGE( TYPE_LVL ) & ", " );

	    if  TYPE_LVL /= INTEGER( CODI.CUR_LEVEL )  or else  D( XD_REGION, TYPE_NAME ).TY = DN_PACKAGE_ID
	    then
	      REGIONS_PATH( TYPE_NAME );
	    end if;

	    PUT( TYPE_STR & "." );

	    if  IS_LAST  then
	      PUT( "_LST_" );
	    else
	      PUT( "_FST_" );
	    end if;

	    PUT_LINE( IMAGE( NUM_DIM ) );
	    return;
	  end;
	end if;
        end;
      end if;

      if  RAW_PREFIX.TY = DN_USED_OBJECT_ID  then
        declare
	PREFIX_DEFN	: TREE		:= D( SM_DEFN, RAW_PREFIX );
	ARRAY_LVL		: INTEGER		:= DI( CD_LEVEL, PREFIX_DEFN );
	PREFIX_TYPE	: TREE		:= D( SM_EXP_TYPE, RAW_PREFIX );
	PREFIX_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, PREFIX_DEFN ) );
        begin

	if  PREFIX_TYPE.TY = DN_ACCESS  then
	  declare
	    DESIG_TYPE : TREE := D( SM_DESIG_TYPE, PREFIX_TYPE );
	  begin
	    while  DESIG_TYPE.TY = DN_PRIVATE or else DESIG_TYPE.TY = DN_L_PRIVATE  loop
	      DESIG_TYPE := D( SM_TYPE_SPEC, DESIG_TYPE );
	    end loop;

	    if  DESIG_TYPE.TY = DN_INCOMPLETE  then
	      DESIG_TYPE := D( XD_FULL_TYPE_SPEC, DESIG_TYPE );
	    end if;

	    if  DESIG_TYPE.TY = DN_CONSTRAINED_ARRAY
	      or else DESIG_TYPE.TY = DN_ARRAY
	    then
	      declare
	        TYPE_NAME : TREE := D( XD_SOURCE_NAME, DESIG_TYPE );
	        TYPE_STR  : constant STRING := '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	        TYPE_LVL  : INTEGER := DI( CD_LEVEL, DESIG_TYPE );
	      begin
	        PUT( tab & "Ld" & tab & IMAGE( TYPE_LVL ) & ", " );
	        REGIONS_PATH( TYPE_NAME );
	        PUT( TYPE_STR );

	        if  IS_LAST  then
	          PUT( "._LST_" );
	        else
	          PUT( "._FST_" );
	        end if;

	        PUT_LINE( IMAGE( NUM_DIM ) );
	        return;
	      end;
	    end if;
	  end;
	end if;

	while  PREFIX_TYPE.TY = DN_PRIVATE  or else  PREFIX_TYPE.TY = DN_L_PRIVATE  loop
	  PREFIX_TYPE := D( SM_TYPE_SPEC, PREFIX_TYPE );
	end loop;

	declare
	  TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, PREFIX_TYPE );
	  TYPE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	begin
	  if  PREFIX_DEFN.TY in CLASS_PARAM_NAME  then
	    PUT_LINE( tab & "LVA" & tab & IMAGE( ARRAY_LVL ) & ", -" & PREFIX_STR & "_ofs" );
	    PUT_LINE( tab & "LIa" & tab & ", ," & INTEGER'IMAGE( CODI.ADDR_SIZE ) );
	    PUT( tab & "Ld"  & tab & ", " & TYPE_STR & "." );

	  elsif  PREFIX_DEFN.TY in CLASS_VC_NAME  then
	    PUT( tab & "LId" & tab & IMAGE( ARRAY_LVL ) & ", " & PREFIX_STR & "__u, " );
	    REGIONS_PATH( TYPE_NAME );
	    PUT(  TYPE_STR & "." );

	  else
	    PUT_LINE( "; RANGE_ATTRIBUTE: prefix object non traite " & NODE_NAME'IMAGE( PREFIX_DEFN.TY ) );
	    PUT_LINE( tab & "LI" & tab & "0" );
	    return;
	  end if;

	  if  IS_LAST  then
	    PUT( "LST_" );
	  else
	    PUT( "FST_" );
	  end if;
	  PUT_LINE( IMAGE( NUM_DIM ) );
	end;
        end;

    elsif  RAW_PREFIX.TY = DN_USED_NAME_ID  then
      declare
        PREFIX_DEFN		: TREE	:= D( SM_DEFN, RAW_PREFIX );
        TYPE_SPEC		: TREE	:= TREE_VOID;

      begin
        if  PREFIX_DEFN.TY in CLASS_TYPE_NAME  then
          TYPE_SPEC := D( SM_TYPE_SPEC, PREFIX_DEFN );
          while  TYPE_SPEC.TY = DN_PRIVATE  or else  TYPE_SPEC.TY = DN_L_PRIVATE  loop
            TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
          end loop;

          if  TYPE_SPEC.TY in CLASS_SCALAR  then
            CODE_DISCRETE_RANGE_BOUND( D( SM_RANGE, TYPE_SPEC ), IS_LAST );

          elsif  TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY  then
          -- T'RANGE(N), T marque de sous-type tableau CONTRAINT : les bornes sont
          -- les VAR _FST_N/_LST_N du descripteur du type, initialisees a
          -- l'elaboration.  Meme idiome que le prefixe SELECTED ci-dessus.
            declare
              TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
              TYPE_STR	: constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
              TYPE_LVL	: INTEGER		:= DI( CD_LEVEL, TYPE_SPEC );					-- piege n 58
            begin
              PUT( tab & "Ld" & tab & IMAGE( TYPE_LVL ) & ", " );

              if  TYPE_LVL /= INTEGER( CODI.CUR_LEVEL )
                or else  D( XD_REGION, TYPE_NAME ).TY = DN_PACKAGE_ID
              then
                REGIONS_PATH( TYPE_NAME );
              end if;

              PUT( TYPE_STR & "." );

              if  IS_LAST  then
                PUT( "_LST_" );
              else
                PUT( "_FST_" );
              end if;

              PUT_LINE( IMAGE( NUM_DIM ) );
            end;

	else
            PUT_LINE( "; RANGE_ATTRIBUTE: prefix type non scalaire non traite " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
            PUT_LINE( tab & "LI" & tab & "0" );
          end if;
        end if;
      end;

    else
      PUT_LINE( "; RANGE_ATTRIBUTE: prefix non traite " & NODE_NAME'IMAGE( RAW_PREFIX.TY ) );
      PUT_LINE( tab & "LI" & tab & "0" );
    end if;

  end	CODE_RANGE_ATTRIBUTE_BOUND;
	--------------------------

  begin
    if  DISCRETE_RANGE.TY = DN_RANGE  then
      if IS_LAST then
        CODE_EXP( D( AS_EXP2, DISCRETE_RANGE ) );
      else
        CODE_EXP( D( AS_EXP1, DISCRETE_RANGE ) );
      end if;

    elsif  DISCRETE_RANGE.TY = DN_RANGE_ATTRIBUTE  then
      CODE_RANGE_ATTRIBUTE_BOUND( DISCRETE_RANGE );

    elsif  DISCRETE_RANGE.TY = DN_DISCRETE_SUBTYPE  then
      declare
        SUB_IND        : TREE := D( AS_SUBTYPE_INDICATION, DISCRETE_RANGE );
        SUB_CONSTRAINT : TREE := D( AS_CONSTRAINT, SUB_IND );
      begin
        if  SUB_CONSTRAINT /= TREE_VOID  then
          CODE_DISCRETE_RANGE_BOUND( SUB_CONSTRAINT, IS_LAST );

        else
          declare
            TYPE_NAME : TREE := LAST_OF_SELECTED( D( AS_NAME, SUB_IND ) );
            TYPE_DEFN : TREE := D( SM_DEFN, TYPE_NAME );
            TYPE_SPEC : TREE := D( SM_TYPE_SPEC, TYPE_DEFN );
          begin
            while  TYPE_SPEC.TY = DN_PRIVATE
              or else TYPE_SPEC.TY = DN_L_PRIVATE
            loop
              TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
            end loop;

            CODE_DISCRETE_RANGE_BOUND( D( SM_RANGE, TYPE_SPEC ), IS_LAST );
          end;
        end if;
      end;

    else
      PUT_LINE( "; CODE_DISCRETE_RANGE_BOUND: range non traite " & NODE_NAME'IMAGE( DISCRETE_RANGE.TY ) );
      PUT_LINE( tab & "LI" & tab & "0" );
    end if;

  end	CODE_DISCRETE_RANGE_BOUND;
	-------------------------


			----------------
  procedure		CODE_RANGE_CHECK		( TYPE_SPEC :TREE )
  is			----------------
	-- PILIER CHECKS (E-A) : check de gamme scalaire (LRM 3.5.4). La valeur controlee est au
	-- SOMMET de pile et y RESTE (idiome DUP -- s'insere entre evaluation et consommation).
	-- Bornes : celles du SOUS-TYPE DE LA VUE (motif pilier 3.7), lues dans _<SUBTYPE>.FST/.LST
	-- elaborees par TYPES_DECLS -- meme chemin statique/dynamique.
	-- Elision : sous-type = type de base, par comparaison de NOEUDS, jamais de bornes (note §5).
	--   Le placeholder d'un formel generique est son propre SM_BASE_TYPE (dump CHK_DUMP0) :
	--   l'elision couvre donc AUSSI les corps partages -- bornes du formel via GENERIC_FIRST_LAST
	--   a l'etape E-D, pas ici.
	-- E-A : DN_INTEGER et DN_ENUMERATION seulement ; fixed/float -> perimetre 2 (note §4).
	-- Comparaisons CLT/CGT signees, coherentes par construction : fetch codi movsx des deux cotes.
  begin
    if  not CODI.CHECKS_ENABLED  then
      return;
    end if;

    if  TYPE_SPEC.TY /= DN_INTEGER  and  TYPE_SPEC.TY /= DN_ENUMERATION  then
      return;											-- fixed/float : perimetre 2
    end if;

    if  TYPE_SPEC = D( SM_BASE_TYPE, TYPE_SPEC )  then
      return;											-- pas de contrainte : elision
    end if;

    -- PIEGE n 80 (fossile A54B02A) : sous-type ANONYME -- contrainte portee par la
    -- declaration d'objet. XD_SOURCE_NAME remonte au TYPE DE BASE : le check
    -- chargerait les bornes du bloc du base (pour les predefinies : bloc de
    -- STANDARD JAMAIS ELABORE -> faux positif deterministe). Le controle contre
    -- les bornes du base serait vide de toute facon : ELISION par comparaison des
    -- NOEUDS de nom. La contrainte anonyme reste NON CONTROLEE : dette consignee
    -- (NOTE_MODELE_CHECKS, restrictions).
    if  D( XD_SOURCE_NAME, TYPE_SPEC )
      = D( XD_SOURCE_NAME, D( SM_BASE_TYPE, TYPE_SPEC ) )  then
      return;
    end if;

    declare
      SUBTYPE_NAME	:constant TREE	:= D( XD_SOURCE_NAME, TYPE_SPEC );
      SUBTYPE_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, SUBTYPE_NAME ) );
      TYPE_LVL	:constant INTEGER	:= DI( CD_LEVEL, TYPE_SPEC );
      SIZ_CHAR	:constant CHARACTER	:= OPER_SIZ_CHAR( TYPE_SPEC );

		----------
      procedure	LOAD_BOUND	( IS_LAST :BOOLEAN )
      is		----------
      begin											-- idiome CODE_SCALAR_SUBTYPE_FIRST_LAST
        PUT( tab & 'L' & SIZ_CHAR & tab & IMAGE( TYPE_LVL ) & ", " );
        if  TYPE_LVL /= INTEGER( CODI.CUR_LEVEL )
         or else  D( XD_REGION, SUBTYPE_NAME ).TY = DN_PACKAGE_ID
        then
          REGIONS_PATH( SUBTYPE_NAME );
        end if;
        PUT( SUBTYPE_STR & "." );
        if  IS_LAST  then  PUT_LINE( "LST" );  else  PUT_LINE( "FST" );  end if;
      end	LOAD_BOUND;
	----------

    begin
      PUT_LINE( tab & "DUP" );
      LOAD_BOUND( IS_LAST => FALSE );
      PUT_LINE( tab & "CLT" );									-- val < FST ?
      PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );
      PUT_LINE( tab & "DUP" );
      LOAD_BOUND( IS_LAST => TRUE );
      PUT_LINE( tab & "CGT" );									-- val > LST ?
      PUT_LINE( tab & "BT" & tab & "STANDARD.ce_raise_" );
    end;

  end	CODE_RANGE_CHECK;
	----------------


	-----------
end	EXPRESSIONS;
	-----------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
