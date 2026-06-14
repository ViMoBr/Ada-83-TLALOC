------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( EXPANDER )
				------------
 	package body		INSTRUCTIONS
				------------
  is


  package CODI	renames EXPANDER.UTILS;
  use CODI;


  procedure			CODE_STM_S		( STM_S :TREE )
  is
  begin
    declare
      STM_SEQ : SEQ_TYPE := LIST ( STM_S );
      STM_ELEM : TREE;
    begin
      while not IS_EMPTY ( STM_SEQ ) loop
        POP( STM_SEQ, STM_ELEM );
        CODE_STM_ELEM( STM_ELEM );
      end loop;
    end;
  end	CODE_STM_S;


  procedure			CODE_STM_ELEM		( STM_ELEM :TREE )
  is
  begin

    if STM_ELEM.TY in CLASS_STM then
      CODE_STM( STM_ELEM );

    elsif STM_ELEM.TY = DN_STM_PRAGMA then
      CODE_STM_PRAGMA( STM_ELEM );

    end if;
  end	CODE_STM_ELEM;



  procedure			CODE_STM_PRAGMA		( STM_PRAGMA :TREE )
  is
  begin
    null;
  end;



				--====--
  procedure			CODE_STM			( STM :TREE )
  is
  begin

    if STM.TY = DN_LABELED
    then
      CODE_LABELED( STM );

    elsif STM.TY = DN_NULL_STM
    then
      CODE_NULL_STM( STM );

    elsif STM.TY = DN_ACCEPT
    then
      CODE_ACCEPT( STM );

    elsif STM.TY = DN_TERMINATE
    then
      CODE_TERMINATE( STM );

    elsif STM.TY = DN_ABORT
    then
      CODE_ABORT( STM );

    elsif STM.TY in CLASS_CLAUSES_STM
    then
      CODE_CLAUSES_STM( STM );

    elsif STM.TY in CLASS_BLOCK_LOOP
    then
      CODE_BLOCK_LOOP( STM );

    elsif STM.TY in CLASS_ENTRY_STM
    then
      CODE_ENTRY_STM( STM );

    elsif STM.TY in CLASS_STM_WITH_NAME
    then
      CODE_STM_WITH_NAME( STM );

    elsif STM.TY in CLASS_STM_WITH_EXP
    then
      CODE_STM_WITH_EXP( STM );

    end if;
  end	CODE_STM;
	--====--



  procedure			CODE_LABELED		( LABELED :TREE )
  is
  begin
    null;
  end	CODE_LABELED;



  procedure			CODE_NULL_STM		( NULL_STM :TREE )
  is
  begin
    null;
  end	CODE_NULL_STM;



  procedure			CODE_ACCEPT		( ADA_ACCEPT :TREE )
  is
  begin
    null;
  end	CODE_ACCEPT;



  procedure			CODE_TERMINATE		( ADA_TERMINATE :TREE )
  is
  begin
    null;
  end	CODE_TERMINATE;



  procedure			CODE_ABORT		( ADA_ABORT :TREE )
  is
  begin
    null;
  end	CODE_ABORT;



  procedure			CODE_CLAUSES_STM		( CLAUSES_STM :TREE )
  is
  begin
    if CLAUSES_STM.TY = DN_IF
    then
      CODE_IF( CLAUSES_STM );

    elsif CLAUSES_STM.TY = DN_SELECTIVE_WAIT
    then
      CODE_SELECTIVE_WAIT( CLAUSES_STM );

    end if;
  end	CODE_CLAUSES_STM;


				-------
  procedure			CODE_IF			( ADA_IF :TREE )
  is
    POST_IF_LBL	:constant STRING	:= NEW_LABEL;
  begin
    if  CODI.DEBUG  then PUT( tab50 & "; debut if" ); end if;
    NEW_LINE;
    CODE_TEST_CLAUSE_ELEM_S( D( AS_TEST_CLAUSE_ELEM_S, ADA_IF ), POST_IF_LBL );
    CODE_STM_S( D( AS_STM_S, ADA_IF ) );								-- partie else
    PUT( POST_IF_LBL & ':' );
    if  CODI.DEBUG  then PUT( tab50 & "; post if" ); end if;
    NEW_LINE;

  end	CODE_IF;
	-------


		-----------------------
  procedure	CODE_SELECT_ALTERNATIVE	( SELECT_ALTERNATIVE :TREE )
  is
  begin
    null;
  end;


		-----------------------
  procedure	CODE_TEST_CLAUSE_ELEM_S	( TEST_CLAUSE_ELEM_S :TREE; STM_END_LBL :STRING )
  is
    TEST_CLAUSE_ELEM_SEQ	: SEQ_TYPE	:= LIST( TEST_CLAUSE_ELEM_S );
    TEST_CLAUSE_ELEM	: TREE;
  begin
    while  not IS_EMPTY( TEST_CLAUSE_ELEM_SEQ )  loop
      POP( TEST_CLAUSE_ELEM_SEQ, TEST_CLAUSE_ELEM );

      if  TEST_CLAUSE_ELEM.TY = DN_COND_CLAUSE  then
        CODE_COND_CLAUSE( TEST_CLAUSE_ELEM, STM_END_LBL );

      elsif  TEST_CLAUSE_ELEM.TY = DN_SELECT_ALTERNATIVE  then
        CODE_SELECT_ALTERNATIVE ( TEST_CLAUSE_ELEM );

      elsif  TEST_CLAUSE_ELEM.TY = DN_SELECT_ALT_PRAGMA  then
        CODE_SELECT_ALT_PRAGMA( TEST_CLAUSE_ELEM );

      end if;

    end loop;

  end	CODE_TEST_CLAUSE_ELEM_S;
	-----------------------


		----------------
  procedure	CODE_COND_CLAUSE		( COND_CLAUSE :TREE; STM_END_LBL :STRING )
  is
  begin
    declare
      EXP			: TREE		:= D( AS_EXP, COND_CLAUSE );
      NEXT_CLAUSE_LBL	:constant STRING	:= NEW_LABEL;
    begin
      EXPRESSIONS.CODE_EXP( EXP );									-- Expression booleenne de decision
      PUT_LINE( tab & "BF" & tab & NEXT_CLAUSE_LBL );
      INSTRUCTIONS.CODE_STM_S( D( AS_STM_S, COND_CLAUSE ) );
      PUT_LINE( tab & "BRA" & tab & STM_END_LBL );
      PUT_LINE( NEXT_CLAUSE_LBL & ':' );
    end;

  end	CODE_COND_CLAUSE;
	----------------


  procedure			CODE_SELECTIVE_WAIT		( SELECTIVE_WAIT :TREE )
  is
  begin
    null;
  end	CODE_SELECTIVE_WAIT;



  procedure			CODE_BLOCK_LOOP		( BLOCK_LOOP :TREE )
  is
  begin

    if BLOCK_LOOP.TY = DN_LOOP
    then
      CODE_LOOP( BLOCK_LOOP );

    elsif BLOCK_LOOP.TY = DN_BLOCK
    then
      CODE_BLOCK( BLOCK_LOOP );

    end if;
  end	CODE_BLOCK_LOOP;


				---------
  procedure			CODE_LOOP			( ADA_LOOP :TREE )
  is
    LOOP_STM_S		: TREE		:= D( AS_STM_S,       ADA_LOOP );
    LOOP_NAME_ID		: TREE		:= D( AS_SOURCE_NAME, ADA_LOOP );
    ITERATION		: TREE		:= D( AS_ITERATION,   ADA_LOOP );
    LOOP_LBL_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, LOOP_NAME_ID ) );
    AFTER_LOOP_LBL		: LABEL_TYPE	:= NEW_LABEL;
    AFTER_LOOP_LBL_STR	:constant STRING	:= LABEL_STR( AFTER_LOOP_LBL );
  begin
    DI( CD_AFTER_LOOP, ADA_LOOP, INTEGER( AFTER_LOOP_LBL ) );
    DI( CD_LEVEL,      ADA_LOOP, INTEGER( CODI.CUR_LEVEL ) );

--
--				SIMPLE BOUCLE
--
    if  ITERATION = TREE_VOID  then
      PUT_LINE( LOOP_LBL_STR & ':' );
      CODE_STM_S( LOOP_STM_S );
      PUT_LINE( tab & "BRA" & tab & LOOP_LBL_STR );

--
--				BOUCLE WHILE
--
    elsif  ITERATION.TY = DN_WHILE  then
      PUT_LINE( LOOP_LBL_STR & ':' );
      EXPRESSIONS.CODE_EXP( D( AS_EXP, ITERATION ) );
      PUT_LINE( tab & "BF" & tab & LABEL_STR( AFTER_LOOP_LBL ) );
      CODE_STM_S( LOOP_STM_S );
      PUT_LINE( tab & "BRA" & tab & LOOP_LBL_STR );

    elsif  ITERATION.TY in CLASS_FOR_REV  then

				FOR_OR_REVERSE_LOOP:

      declare
        ITERATION_ID	: TREE		:= D( AS_SOURCE_NAME, ITERATION );
--        ITERATION_RANGE	: TREE		:= D( AS_DISCRETE_RANGE, ITERATION );
        ITERATION_RANGE	: TREE		:= D( SM_RANGE, D( SM_OBJ_TYPE, ITERATION_ID ) );
        RANGE_LOW		: TREE		:= D( AS_EXP1, ITERATION_RANGE );
        RANGE_HIGH		: TREE		:= D( AS_EXP2, ITERATION_RANGE );
        TYPE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, ITERATION_ID ) );
        ITERATION_ID_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, ITERATION_ID ) );
        ITERATION_ID_TAG	: LABEL_TYPE	:= NEW_LABEL;
        ITERATION_ID_VARSTR	:constant STRING	:= ITERATION_ID_STR & LABEL_STR( ITERATION_ID_TAG ) & "_disp";
        LVL		: LEVEL_NUM	renames CODI.CUR_LEVEL;
        LVL_STR		:constant STRING	:= INTEGER'IMAGE( LVL );
      begin
        DI( CD_LEVEL,  ITERATION_ID, LVL );
        DI( CD_OFFSET, ITERATION_ID, INTEGER( ITERATION_ID_TAG ) );

        PUT( "VAR" & tab & ITERATION_ID_VARSTR & ", " & TYPE_CHAR );
        if  CODI.DEBUG  then PUT( tab50 & "; compteur boucle " & LOOP_LBL_STR); end if;
        NEW_LINE;
        EXPRESSIONS.CODE_EXP( RANGE_LOW );
        PUT_LINE( tab & "S" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & ITERATION_ID_VARSTR );

        PUT( "VAR" & tab & "LMT_" & ITERATION_ID_VARSTR & ", " & TYPE_CHAR );
        if  CODI.DEBUG  then PUT( tab50 & "; limite boucle " & LOOP_LBL_STR); end if;
        NEW_LINE;
        EXPRESSIONS.CODE_EXP( RANGE_HIGH );
        PUT_LINE( tab & "S" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & "LMT_" & ITERATION_ID_VARSTR );

--			VERIFIER POUR NULL RANGE

        PUT( tab & "L" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & ITERATION_ID_VARSTR );
        if  CODI.DEBUG  then
	PUT( tab50 & "; test null range " & LOOP_LBL_STR );
        end if;
        NEW_LINE;
        PUT_LINE( tab & "L" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & "LMT_" & ITERATION_ID_VARSTR );
        PUT_LINE( tab & "CGT" );
        PUT_LINE( tab & "BT" & tab & AFTER_LOOP_LBL_STR );

--			INVERSER CNT LMT POUR REVERSE

        if  ITERATION.TY = DN_REVERSE  then
	PUT( tab & "L" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & ITERATION_ID_VARSTR );
	if  CODI.DEBUG  then
	  PUT( tab50 & "; inversion range " & LOOP_LBL_STR );
	end if;
	NEW_LINE;
	PUT_LINE( tab & "L" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & "LMT_" & ITERATION_ID_VARSTR );
	PUT_LINE( tab & "S" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & ITERATION_ID_VARSTR );
	PUT_LINE( tab & "S" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & "LMT_" & ITERATION_ID_VARSTR );
        end if;

--			DEBUT ET CORPS DE BOUCLE

        PUT( LOOP_LBL_STR & ':' );
        if  CODI.DEBUG  then
	PUT( tab50 & "; corps boucle " & LOOP_LBL_STR );
        end if;
        NEW_LINE;
        CODE_STM_S ( LOOP_STM_S );

--			TEST DE SORTIE

        PUT( tab & "L" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & ITERATION_ID_VARSTR );
        if  CODI.DEBUG  then
	PUT( tab50 & "; test de sortie " & LOOP_LBL_STR );
        end if;
        NEW_LINE;
        PUT_LINE( tab & "L" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & "LMT_" & ITERATION_ID_VARSTR );
        PUT_LINE( tab & "CEQ" );
        PUT_LINE( tab & "BT" & tab & AFTER_LOOP_LBL_STR );

--			MISE A JOUR DU COMPTEUR

        PUT( tab & "L" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & ITERATION_ID_VARSTR );
        if  CODI.DEBUG  then
	PUT( tab50 & "; mise a jour compteur " & LOOP_LBL_STR );
        end if;
        NEW_LINE;

        if  ITERATION.TY = DN_FOR  then
          PUT_LINE( tab & "INC" );

        elsif  ITERATION.TY = DN_REVERSE  then
	PUT_LINE( tab & "DEC" );

        end if;
        PUT_LINE( tab & "S" & TYPE_CHAR & ' ' & LVL_STR & ',' & tab & ITERATION_ID_VARSTR );

        PUT( tab & "BRA" & tab & LOOP_LBL_STR );
        if  CODI.DEBUG  then
	PUT( tab50 & "; iteration suivante " & LOOP_LBL_STR );
        end if;
        NEW_LINE;

      end			FOR_OR_REVERSE_LOOP;
			-------------------
    end if;

    PUT( AFTER_LOOP_LBL_STR & ':' );
    if  CODI.DEBUG  then
      PUT( tab50 & "; post loop " & LOOP_LBL_STR );
    end if;
    NEW_LINE;

  end	CODE_LOOP;
	---------


				----------
  procedure			CODE_BLOCK		( BLOCK :TREE )
  is
    LOOP_NAME_ID	: TREE		:= D( AS_SOURCE_NAME, BLOCK );
    PROC_LBL        :constant STRING	:= PRINT_NAME( D( LX_SYMREP, LOOP_NAME_ID ) );
  begin
    PUT_LINE( "namespace" & tab &  PROC_LBL );
    INC_LEVEL;
    STRUCTURES.CODE_BLOCK_BODY( D( AS_BLOCK_BODY, BLOCK ) );
    PUT_LINE( tab & "UNLINK" & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) );					-- RESTAURER LE DISPLAY ET LA PILE APRES LE BLOC
    DEC_LEVEL;
    PUT_LINE( "endPRO" );										-- POUR CALCUL DU LOC_SIZ AVANT FERMETURE DU NAMESPACE

  end	CODE_BLOCK;



  procedure			CODE_ENTRY_STM		( ENTRY_STM :TREE )
  is
  begin

    if  ENTRY_STM.TY = DN_COND_ENTRY  then
      CODE_COND_ENTRY ( ENTRY_STM );

    elsif  ENTRY_STM.TY = DN_TIMED_ENTRY  then
      CODE_TIMED_ENTRY ( ENTRY_STM );

    end if;
  end	CODE_ENTRY_STM;



  procedure			CODE_COND_ENTRY		( COND_ENTRY :TREE )
  is
  begin
    null;
  end	CODE_COND_ENTRY;



  procedure			CODE_TIMED_ENTRY		( TIMED_ENTRY :TREE )
  is
  begin
    null;
  end	CODE_TIMED_ENTRY;



 procedure			CODE_STM_WITH_NAME		( STM_WITH_NAME :TREE )
  is
  begin
    if  STM_WITH_NAME.TY = DN_GOTO
    then
      CODE_GOTO( STM_WITH_NAME );

    elsif  STM_WITH_NAME.TY = DN_RAISE
    then
      CODE_RAISE( STM_WITH_NAME );

    elsif  STM_WITH_NAME.TY in CLASS_CALL_STM
    then
      CODE_CALL_STM( STM_WITH_NAME );

    end if;
  end	CODE_STM_WITH_NAME;



  procedure			CODE_GOTO			( ADA_GOTO :TREE )
  is
  begin
    null;
  end;



				----------
  procedure			CODE_RAISE		( ADA_RAISE :TREE )
  is
  begin
    declare
      NAME	: TREE	:= D( AS_NAME, ADA_RAISE );
    begin
      if  NAME = TREE_VOID  then
null;--        EMIT( RAI );
      else
        declare
	EXCEPTION_ID	: TREE		:= D( SM_DEFN, NAME );
--	LBL		: LABEL_TYPE;
        begin
	if D( CD_LABEL, EXCEPTION_ID ).TY /= DN_NUM_VAL then
null;
--	  LBL := NEW_LABEL;
--	  DI  ( CD_LABEL, EXCEPTION_ID, INTEGER( LBL ) );
--	  EMIT( EXL, LBL, S=> PRINT_NAME( D( LX_SYMREP, NAME ) ),
--				COMMENT=> "NUMERO D EXCEPTION EXTERNE SUR RAISE" );
	end if;
--          EMIT( RAI, DI( CD_LABEL, EXCEPTION_ID ) );
        end;
      end if;
    end;
  end	CODE_RAISE;
	----------


			---------------
  procedure		CODE_ENTRY_CALL	( ENTRY_CALL :TREE )
  is
  begin
    null;
  end	CODE_ENTRY_CALL;
	---------------


				-------------
  procedure			CODE_CALL_STM		( CALL_STM :TREE )
  is
    NAME_ID		: TREE	:= D( AS_NAME, CALL_STM );
  begin
    while  NAME_ID.TY = DN_SELECTED  loop
      NAME_ID := D( AS_DESIGNATOR, NAME_ID );
    end loop;

    if  CALL_STM.TY = DN_PROCEDURE_CALL  then
        CODE_PROCEDURE_CALL ( CALL_STM, NAME_ID );

    elsif  CALL_STM.TY = DN_ENTRY_CALL  then
      CODE_ENTRY_CALL ( CALL_STM );

    end if;

  end	CODE_CALL_STM;
	-------------

				-------------------
  procedure			CODE_PROCEDURE_CALL		( PROCEDURE_CALL :TREE; USED_NAME_ID : TREE )
  is
    NORM_ACT_PRM_S	: SEQ_TYPE	:= LIST( D( SM_NORMALIZED_PARAM_S, PROCEDURE_CALL ) );
    SUB_NAME	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, USED_NAME_ID ) );

    PROC_ID	: TREE		:= D( SM_DEFN, USED_NAME_ID );
    LBL		: LABEL_TYPE	:= LABEL_TYPE( DI( CD_LABEL, PROC_ID ) );

    SPEC_PRM_GRP_S	: SEQ_TYPE	:= LIST( D( AS_PARAM_S, D( SM_SPEC, PROC_ID) ) );
    FRM_PRM_GRP	: TREE;
    SPEC_PRM_ID_S	: SEQ_TYPE;


		---------------------
    function	IS_IN_CURRENT_GENERIC	( ID : TREE ) return BOOLEAN
    is		---------------------
      REGION : TREE := ID;
    begin
      if  not CODI.IN_GENERIC_BODY  then
        return FALSE;
      end if;

      while  REGION /= TREE_VOID  loop
        if  REGION = CODI.ENCLOSING_GENERIC  then
          return TRUE;
        end if;

        exit when REGION = TREE_VOID;

        REGION := D( XD_REGION, REGION );
      end loop;
      return FALSE;

    end	IS_IN_CURRENT_GENERIC;
	---------------------

		-----------------------------
    procedure	INVERSE_RECURSE_ON_PARAMETERS
    is		-----------------------------
      ACT_PRM	: TREE;
      FRM_PRM_ID	: TREE;
    begin

      while  not IS_EMPTY( NORM_ACT_PRM_S )  loop

        if  IS_EMPTY( SPEC_PRM_ID_S )  then
	POP( SPEC_PRM_GRP_S, FRM_PRM_GRP );
	SPEC_PRM_ID_S := LIST( D( AS_SOURCE_NAME_S, FRM_PRM_GRP ) );
        end if;
        POP( SPEC_PRM_ID_S, FRM_PRM_ID );
        POP( NORM_ACT_PRM_S, ACT_PRM );

        INVERSE_RECURSE_ON_PARAMETERS;

        if  ACT_PRM.TY = DN_SELECTED  then
	EXPRESSIONS.CODE_SELECTED( ACT_PRM );

        elsif  ACT_PRM.TY = DN_USED_OBJECT_ID  then
	declare
	  DEFN		: TREE	:= D( SM_DEFN, ACT_PRM );
	  EXP_TYPE	: TREE	:= D( SM_EXP_TYPE, ACT_PRM );
	  DEFN_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
	begin
	  if  DEFN.TY = DN_CONSTANT_ID  then

	    if EXP_TYPE.TY = DN_ENUMERATION then
	      PUT_LINE( tab & "LI" & tab & INTEGER'IMAGE( DI( SM_VALUE, ACT_PRM ) ) );

	    elsif EXP_TYPE.TY = DN_ARRAY then
	      PUT( tab & "LVA" & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ',' & tab & DEFN_STR & "_disp" );
	      if  CODI.DEBUG  then PUT( tab50 & "; array actual" ); end if;
	      NEW_LINE;

	    end if;


	  elsif  DEFN.TY = DN_VARIABLE_ID  then
	    if FRM_PRM_ID.TY = DN_IN_ID then
	      LOAD_MEM( DEFN );
	    else
	      if  D( SM_OBJ_TYPE, DEFN ).TY in CLASS_SCALAR  then
	        PUT_LINE( tab & "LVA" & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ',' & tab & DEFN_STR & "_disp" );
	      else
	        PUT_LINE( tab & "LVA" & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ',' & tab & DEFN_STR & "_disp" );
	      end if;
	    end if;

	  elsif  DEFN.TY = DN_IN_ID  then								-- Appel avec un parametre entrant de la procedure englobante

	    if  not CODI.IN_GENERIC_BODY  then
	      LOAD_MEM( DEFN );
	    elsif  EXPRESSIONS.IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, D( SM_OBJ_TYPE, DEFN ) ) )  then
	      PUT_LINE( tab & "LVA " & IMAGE( DI( CD_LEVEL, DEFN ) ) & ','
		    & tab & '-' & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & "_ofs" );
	      PUT_LINE( tab & "La" & LEVEL_NUM'IMAGE( CODI.GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
	      PUT_LINE( tab & "La ," & tab & '-' & PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, D( SM_OBJ_TYPE, DEFN ) ) ) )
			& "__ld_ofs" );
	      PUT_LINE( tab & "CALLI" );

	    else
	      LOAD_MEM( DEFN );
	    end if;

	  elsif  DEFN.TY = DN_OUT_ID  or  DEFN.TY = DN_IN_OUT_ID  then					-- Param out/in_out de la procedure englobante
	    if  FRM_PRM_ID.TY = DN_IN_ID  then
	      -- out/inout -> in : dereferencement, charger la valeur pointee par le parametre
	      declare
	        SIZ_CHAR	: CHARACTER	:= CODI.OPER_SIZ_CHAR( D( SM_OBJ_TYPE, DEFN ) );
	      begin
	        PUT_LINE( tab & "LI" & SIZ_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ',' & tab
			& '-' & DEFN_STR & "_ofs" );							-- load indirect : lire la valeur via l'adresse du param
	      end;
	    else
	      -- out/inout -> out/inout : propager l'adresse
	      PUT_LINE( tab & "La " & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ',' & tab
		      & '-' & DEFN_STR & "_ofs" );							-- transmettre l'adresse telle quelle
	    end if;

	  elsif  DEFN.TY = DN_ITERATION_ID  then                         -- Variable de boucle for
	    declare
	      ITERATION_ID_STR	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
	      ITERATION_ID_TAG	: LABEL_TYPE	:= LABEL_TYPE( DI( CD_OFFSET, DEFN ) );
	      ITERATION_ID_VARSTR	: constant STRING	:= ITERATION_ID_STR
						& LABEL_STR( ITERATION_ID_TAG ) & "_disp";
	      TYPE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, DEFN ) );
	    begin
	      PUT_LINE( tab & "L" & TYPE_CHAR & ' '
			& INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ','
			& tab & ITERATION_ID_VARSTR );
	    end;

	  elsif  DEFN.TY = DN_ENUMERATION_ID  then							-- Appel avec un énuméré
	    PUT_LINE( tab & "LI" & ' ' & INTEGER'IMAGE( DI( SM_POS, DEFN ) ) );

	  elsif  DEFN.TY = DN_COMPONENT_ID  then							-- Appel avec un énuméré

	    PUT_LINE( tab & "LI" & ' ' );

	  else
	    PUT_LINE( tab & "; CODE_PROCEDURE_CALL.INVERSE_RECURSE_ON_PARAMETERS : DEFN.TY NON FAIT "
		    & NODE_NAME'IMAGE( DEFN.TY ) );

	  end if;
	end;

        elsif  ACT_PRM.TY = DN_STRING_LITERAL  then
	declare
	  NOM_ANONYME	:constant STRING	:= "STR_" & NEW_LABEL;
	begin
	  EXPRESSIONS.CODE_STRING_LITERAL( ACT_PRM, NOM_ANONYME );
	  PUT_LINE( tab & "LCA" & tab & NOM_ANONYME & ".data_ptr" );					-- LOAD CONSTANT ADDRESS
	end;

        elsif  ACT_PRM.TY = DN_SLICE  then								-- SLICE PARAMETER
	EXPRESSIONS.CODE_SLICE( ACT_PRM, IS_DESTINATION=> FALSE );


        elsif  ACT_PRM.TY = DN_AGGREGATE
	 or  ( ACT_PRM.TY = DN_QUALIFIED  and then D( AS_EXP, ACT_PRM).TY = DN_AGGREGATE ) then

	if  ACT_PRM.TY = DN_QUALIFIED  then ACT_PRM := D( AS_EXP, ACT_PRM); end if;
	declare
	  ANONYMOUS_STR	:constant STRING	:= ANONYMOUS_NAME_AT( ACT_PRM );
	  TYPE_SPEC	: TREE		:= D( SM_EXP_TYPE, ACT_PRM );
	  TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
	  TYPE_NAME_STR	:constant	STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	begin
	  PUT_LINE( tab & "VAR " & ANONYMOUS_STR	& "_disp, q" );
	  PUT_LINE( tab & "VAR " & ANONYMOUS_STR	& "__u, q" );
	  PUT( tab & "VAR " & ANONYMOUS_STR	& "__dat, " );
	  CODI.REGIONS_PATH( TYPE_NAME );
	  PUT_LINE( TYPE_NAME_STR & ".SIZ" );

	  PUT_LINE( tab & "LVA " & IMAGE( CODI.CUR_LEVEL ) & ", " & ANONYMOUS_STR & "__dat" );
	  PUT_LINE( tab & "Sa " & IMAGE( CODI.CUR_LEVEL ) & ", " & ANONYMOUS_STR & "_disp" );

	  PUT( tab & "La " & IMAGE( DI( CD_LEVEL, TYPE_SPEC ) ) & ", " );
	  CODI.REGIONS_PATH( TYPE_NAME );
	  PUT_LINE( TYPE_NAME_STR & ".use__info" );
	  PUT_LINE( tab & "Sa " & IMAGE( CODI.CUR_LEVEL ) & ", " & ANONYMOUS_STR & "__u" );

	  PUT_LINE( tab & "LVA " & IMAGE( CODI.CUR_LEVEL ) & ", " & ANONYMOUS_STR & "__dat" );
	  EXPRESSIONS.CODE_AGGREGATE( ACT_PRM, TYPE_SPEC );
	  PUT_LINE( tab & "LVA " & IMAGE( CODI.CUR_LEVEL ) & ", " & ANONYMOUS_STR & "_disp" );
	end;

        else
	EXPRESSIONS.CODE_EXP( ACT_PRM );
        end if;
      end loop;
    end	INVERSE_RECURSE_ON_PARAMETERS;
	-----------------------------

  begin
    if  IS_IN_CURRENT_GENERIC( PROC_ID )  then
      PUT( tab & "La " & INTEGER'IMAGE( CODI.GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
      if  CODI.DEBUG  then PUT( tab50 & "; propagation GFP generique" ); end if;
      NEW_LINE;
    end if;

    if not IS_EMPTY( SPEC_PRM_GRP_S ) then
      POP( SPEC_PRM_GRP_S, FRM_PRM_GRP );
      SPEC_PRM_ID_S := LIST( D( AS_SOURCE_NAME_S, FRM_PRM_GRP ) );

      INVERSE_RECURSE_ON_PARAMETERS;

    end if;

    PUT( tab & "CALL" & tab );
    CODI.REGIONS_PATH( PROC_ID );
    PUT_LINE( " ," & SUB_NAME & '_' & LABEL_STR( LBL ) );

  end	CODE_PROCEDURE_CALL;
	-------------------


			-----------------
  procedure		CODE_STM_WITH_EXP		( STM_WITH_EXP :TREE )
  is			-----------------
  begin

    if  STM_WITH_EXP.TY = DN_RETURN
    then
      CODE_RETURN( STM_WITH_EXP );

    elsif  STM_WITH_EXP.TY = DN_DELAY
    then
      CODE_DELAY( STM_WITH_EXP );

    elsif  STM_WITH_EXP.TY = DN_CASE
    then
      CODE_CASE( STM_WITH_EXP );

    elsif  STM_WITH_EXP.TY in CLASS_STM_WITH_EXP_NAME
    then
      CODE_STM_WITH_EXP_NAME( STM_WITH_EXP );

    end if;

  end	CODE_STM_WITH_EXP;
	-----------------

				-----------
  procedure			CODE_RETURN		( ADA_RETURN :TREE )
  is
  begin
    declare
      EXP			: TREE		:= D( AS_EXP, ADA_RETURN );
      BLOCK_BODY		: TREE		:= D( AS_BODY, CODI.ENCLOSING_BODY );
      ENCLOSING_LEVEL	: INTEGER		:= DI( CD_LEVEL, BLOCK_BODY );
    begin
      if  EXP /= TREE_VOID  then
    		---------------------
		STORE_FUNCTION_RESULT:
        declare
          EXPR_TYPE		: TREE		:= D ( SM_EXP_TYPE, EXP );
        begin

put_line( "; CODE_RETURN : EXPR TYPE = " & NODE_NAME'IMAGE( EXPR_TYPE.TY ) );

	if  EXPR_TYPE.TY in CLASS_SCALAR  then
	  EXPRESSIONS.CODE_EXP( EXP );
	  PUT_LINE( tab & "S" & CODI.EXP_TYPE_CHAR( EXP ) & ' ' & INTEGER'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & "-result__ofs" );

elsif  EXPR_TYPE.TY = DN_ARRAY  or  EXPR_TYPE.TY = DN_CONSTRAINED_ARRAY  then
  declare
    SRC_LVL_STR : constant STRING := INTEGER'IMAGE( CODI.CUR_LEVEL );
    RES_LVL_STR : constant STRING := INTEGER'IMAGE( ENCLOSING_LEVEL );
--    LVL_STR : constant STRING := INTEGER'IMAGE( CODI.CUR_LEVEL );
  begin
    EXPRESSIONS.CODE_EXP( EXP );
    -- Pile : @doublet_src
    -- doublet_src = [data_ptr_src : q, info_ptr_src : q]
    -- result__ofs contient @doublet_dest, initialisé par l'appelant.
    -- Convention BLKMOV : pile = ... @DST, LEN, @SRC.

    declare
      INFO_SRC : constant STRING := "RET_INFO_" & NEW_LABEL;
    begin
      PUT_LINE( "VAR" & tab & INFO_SRC & ", q" );

      -- Copier data_ptr : data_ptr_dest <- data_ptr_src
      -- EXP laisse @doublet_src sur pile ; on en garde une copie.
      PUT_LINE( tab & "DUP" );
      PUT_LINE( tab & "La  ,  0" );
      PUT_LINE( tab & "SIq  " & RES_LVL_STR & ", -result__ofs,  0" );

      -- Sauver info_ptr_src = [@doublet_src + 8].
      PUT_LINE( tab & "DUP" );
      PUT_LINE( tab & "La  ,  8" );
      PUT_LINE( tab & "Sa  " & SRC_LVL_STR & ", " & INFO_SRC );
      PUT_LINE( tab & "DROP" );

      -- Copier 16 octets d'info vers info_ptr_dest = [@doublet_dest + 8].
      PUT_LINE( tab & "La  " & RES_LVL_STR & ", -result__ofs" );
      PUT_LINE( tab & "La  ,  8" );
      PUT_LINE( tab & "LI" & tab & "16" );
      PUT_LINE( tab & "La  " & SRC_LVL_STR & ", " & INFO_SRC );
      PUT_LINE( tab & "BLKMOV" );
    end;
  end;

          elsif  EXPR_TYPE.TY = DN_ENUM_LITERAL_S  then
            EXPRESSIONS.CODE_EXP( EXP );
raise PROGRAM_ERROR;

	elsif  EXPR_TYPE.TY = DN_RECORD
	or     EXPR_TYPE.TY = DN_L_PRIVATE
	or     EXPR_TYPE.TY = DN_PRIVATE
	then
				-- Copier les donnees dans le doublet alloue par l appelant (adresse dans result__ofs)
	  declare
	    TYPE_SPEC	: TREE	:= EXPR_TYPE;
	  begin
	    while  TYPE_SPEC.TY = DN_L_PRIVATE  or  TYPE_SPEC.TY = DN_PRIVATE  loop
	      TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
	    end loop;
	    declare
	      TYPE_NAME	: TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
	      TN_STR	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
	      LVL_STR	: constant STRING	:= INTEGER'IMAGE( CODI.CUR_LEVEL );
	    begin
	      if  EXP.TY = DN_AGGREGATE  then
	      -- result__ofs contient l'adresse du doublet alloue par l'appelant
	      -- Extraire data_ptr (offset 0 du doublet) pour CODE_AGGREGATE
	        PUT_LINE( tab & "La  " & LVL_STR & ',' & tab & "-result__ofs" );
	        PUT_LINE( tab & "La  ,  0" );                           -- data_ptr = [doublet + 0]
	        EXPRESSIONS.CODE_AGGREGATE( EXP, TYPE_SPEC );

	      else
	      -- EXP est une variable ou expression composite : BLKMOV vers la destination
	      -- Destination : data_ptr du doublet result__ofs
	        PUT_LINE( tab & "La  " & LVL_STR & ',' & tab & "-result__ofs" );
	        PUT_LINE( tab & "La  ,  0" );                           -- @DST = data_ptr du doublet appelant

	        PUT( tab & "LI" & tab );
	        CODI.REGIONS_PATH( TYPE_NAME );
	        PUT_LINE( TN_STR & ".size" );                           -- LEN

	        EXPRESSIONS.CODE_EXP( EXP );                            -- empiле @doublet source
	        PUT_LINE( tab & "La  ,  0" );                           -- @SRC = data_ptr du doublet source

	        PUT_LINE( tab & "BLKMOV" );
	      end if;
	    end;
	  end;

          end if;
        end	STORE_FUNCTION_RESULT;
        		---------------------
      end if;

      -- Emettre les UNLINK pour chaque bloc declare traverse entre CUR_LEVEL et le niveau de la procedure englobante
      for  L in reverse LEVEL_NUM( ENCLOSING_LEVEL + 1 ) .. CODI.CUR_LEVEL  loop
        PUT_LINE( tab & "UNLINK" & LEVEL_NUM'IMAGE( L ) );
      end loop;

      PUT_LINE( tab & "BRA ret_lbl" );
    end;

  end	CODE_RETURN;
	-----------



  procedure			CODE_DELAY		( ADA_DELAY :TREE )
  is
  begin
    null;
  end	CODE_DELAY;



  procedure			CODE_CASE			( ADA_CASE :TREE )
  is
  begin
    null;
  end	CODE_CASE;



  procedure			CODE_STM_WITH_EXP_NAME	( STM_WITH_EXP_NAME :TREE )
  is
  begin
    if  STM_WITH_EXP_NAME.TY = DN_CODE
    then
      CODE_CODE( STM_WITH_EXP_NAME );

    elsif  STM_WITH_EXP_NAME.TY = DN_ASSIGN
    then
      CODE_ASSIGN( STM_WITH_EXP_NAME );

    elsif  STM_WITH_EXP_NAME.TY = DN_EXIT
    then
      CODE_EXIT( STM_WITH_EXP_NAME );

    end if;
  end	CODE_STM_WITH_EXP_NAME;


				---------
  procedure			CODE_CODE			( CODE :TREE )
  is
    OP_TYPE_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, D( AS_NAME, CODE ) ) );
    AGGREG		: TREE		:= D( AS_EXP, CODE );
    NAMED_ASSOC_LIST	: SEQ_TYPE	:= LIST( D( AS_GENERAL_ASSOC_S, AGGREG ) );
    NAMED_ASSOC		: TREE;
  begin

    while  not IS_EMPTY( NAMED_ASSOC_LIST )  loop
      POP( NAMED_ASSOC_LIST, NAMED_ASSOC );
      declare
        CHOICE_LIST		: SEQ_TYPE	:= LIST( D( AS_CHOICE_S, NAMED_ASSOC ) );
        CHOICE_EXP		: TREE;
        USED_OBJECT_ID	: TREE		:= D( AS_EXP, NAMED_ASSOC );
      begin

				-- OPERATION ASM 0 PARAMETRE

        if  OP_TYPE_STR = "ASM_OP_0"  then
	POP( CHOICE_LIST, CHOICE_EXP );
	if  PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "OPCODE"  then
	  PUT_LINE( tab & PRINT_NAME( D( LX_SYMREP, USED_OBJECT_ID ) ) );
	end if;

				-- OPERATION ASM 1 PARAMETRE

        elsif  OP_TYPE_STR = "ASM_OP_1"  then
	POP( CHOICE_LIST, CHOICE_EXP );
	if  PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "OPCODE"  then
	  PUT( tab & PRINT_NAME( D( LX_SYMREP, USED_OBJECT_ID ) ) );
	end if;

	if  PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "VAL"  then
	  declare
	    NUM_REP	:constant STRING	:=   PRINT_NAME( D( LX_NUMREP, USED_OBJECT_ID ) );
	  begin
	    if  NUM_REP'LENGTH >= 4 and then NUM_REP( NUM_REP'FIRST .. NUM_REP'FIRST+2) = "16#"  then
	      PUT_LINE( tab & "0x" & NUM_REP( NUM_REP'FIRST+3 .. NUM_REP'LAST-1 ) );
	    else
	      PUT_LINE( tab & NUM_REP );
	    end if;
	  end;
	end if;

				-- OPERATION ASM 2 PARAMETRES

        elsif  OP_TYPE_STR = "ASM_OP_2"  then
	POP( CHOICE_LIST, CHOICE_EXP );
	if  PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "OPCODE"  then
	  PUT( tab & PRINT_NAME( D( LX_SYMREP, USED_OBJECT_ID ) ) );
	end if;

	if  PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "LVL"  then
	  PUT( ' ' & PRINT_NAME( D( LX_NUMREP, USED_OBJECT_ID ) ) );
	end if;

	if  PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "OFS"  then
	  if  USED_OBJECT_ID.TY = DN_NUMERIC_LITERAL  then
	    PUT_LINE( " ," & tab & PRINT_NAME( D( LX_NUMREP, USED_OBJECT_ID ) ) );
	  elsif  USED_OBJECT_ID.TY = DN_FUNCTION_CALL
	     and then PRINT_NAME( D( LX_SYMREP, D(AS_NAME, USED_OBJECT_ID ) ) ) = """-"""
	  then
	    declare
	      NAMED_ASSOC_LIST	: SEQ_TYPE	:= LIST( D( AS_GENERAL_ASSOC_S, USED_OBJECT_ID ) );
	      NAMED_ASSOC		: TREE;
	      FUNCTION_NAME_STRING	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, D(AS_NAME, USED_OBJECT_ID ) ) );
	    begin
	      POP( NAMED_ASSOC_LIST, NAMED_ASSOC );
	      PUT_LINE( " ," & tab & '-' & PRINT_NAME( D( LX_NUMREP, NAMED_ASSOC ) ) );
	    end;
	  end if;
	end if;

				-- OPERATION ASM 3 PARAMETRES

        elsif  OP_TYPE_STR = "ASM_OP_3"  then
	POP( CHOICE_LIST, CHOICE_EXP );
	if  PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "OPCODE"  then
	  PUT( tab & PRINT_NAME( D( LX_SYMREP, USED_OBJECT_ID ) ) );
	end if;

	if  PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "LVL"  then
	  PUT( ' ' & PRINT_NAME( D( LX_NUMREP, USED_OBJECT_ID ) ) );
	end if;

	if  PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "DISP"  then
	  if  USED_OBJECT_ID.TY = DN_NUMERIC_LITERAL  then
	    PUT( " ," & tab & PRINT_NAME( D( LX_NUMREP, USED_OBJECT_ID ) ) );
	  elsif  USED_OBJECT_ID.TY = DN_FUNCTION_CALL
	     and then PRINT_NAME( D( LX_SYMREP, D(AS_NAME, USED_OBJECT_ID ) ) ) = """-"""
	  then
	    declare
	      NAMED_ASSOC_LIST	: SEQ_TYPE	:= LIST( D( AS_GENERAL_ASSOC_S, USED_OBJECT_ID ) );
	      NAMED_ASSOC		: TREE;
	      FUNCTION_NAME_STRING	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, D(AS_NAME, USED_OBJECT_ID ) ) );
	    begin
	      POP( NAMED_ASSOC_LIST, NAMED_ASSOC );
	      PUT( " ," & tab & '-' & PRINT_NAME( D( LX_NUMREP, NAMED_ASSOC ) ) );
	    end;
	  end if;
	end if;

	if  PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "OFS"  then
	  if  USED_OBJECT_ID.TY = DN_NUMERIC_LITERAL  then
	    PUT_LINE( ',' & tab & PRINT_NAME( D( LX_NUMREP, USED_OBJECT_ID ) ) );
	  elsif  USED_OBJECT_ID.TY = DN_FUNCTION_CALL
	     and then PRINT_NAME( D( LX_SYMREP, D(AS_NAME, USED_OBJECT_ID ) ) ) = """-"""
	  then
	    declare
	      NAMED_ASSOC_LIST	: SEQ_TYPE	:= LIST( D( AS_GENERAL_ASSOC_S, USED_OBJECT_ID ) );
	      NAMED_ASSOC		: TREE;
	      FUNCTION_NAME_STRING	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, D(AS_NAME, USED_OBJECT_ID ) ) );
	    begin
	      POP( NAMED_ASSOC_LIST, NAMED_ASSOC );
	      PUT_LINE( " ," & tab & '-' & PRINT_NAME( D( LX_NUMREP, NAMED_ASSOC ) ) );
	    end;
	  end if;
	end if;

        end if;

      end;
    end loop;

  end	CODE_CODE;
	---------


				-----------
  procedure			CODE_ASSIGN		( ASSIGN :TREE )
  is				-----------

    DST_NAME	: TREE	:= D( AS_NAME, ASSIGN );							-- DESTINATION DONT ON VEUT L ADRESSE POUR Y METTRE LA SOURCE
    SRC_EXP	: TREE	:= D( AS_EXP, ASSIGN );							-- EXPRESSION SOURCE A AFFECTER
    BASE_DST_NAME	: TREE	:= DST_NAME;								-- Pour le cas DN_SELECTED eventuel

  begin
    declare

		---------
      procedure	STORE_VAL		( VAL_TYPE_SPEC :TREE )
      is		---------
        TYPE_SPEC	: TREE	:= VAL_TYPE_SPEC;
      begin
        if  TYPE_SPEC.TY = DN_L_PRIVATE  or  TYPE_SPEC.TY = DN_PRIVATE  then
	TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
        end if;

        case TYPE_SPEC.TY is
        when DN_ACCESS =>
          PUT_LINE( tab & "Sa" );

        when DN_ENUMERATION | DN_INTEGER | DN_FIXED | DN_FLOAT =>
          PUT_LINE( tab & "S" & CODI.OPER_SIZ_CHAR( TYPE_SPEC ) );						-- Juste stocker la valeur sur pile

        when others =>
          PUT_LINE ( "!!! STORE_VAL TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
          raise PROGRAM_ERROR;
        end case;

      end	STORE_VAL;
	---------

    begin

      if D( SM_EXP_TYPE, DST_NAME ).TY = DN_VOID then
        PUT_LINE( "!!! CODE_ASSIGN: destination selected non typee ou composante inexistante probleme frontend probable" );
        raise PROGRAM_ERROR;
      end if;

      if  DST_NAME.TY = DN_ALL  then									-- AFFECTATION A UN ELEMENT POINTE
        PUT_LINE( "; CODE_ASSIGN DN_ALL A FAIRE : calcul adresse pointee" );
        raise PROGRAM_ERROR;
--        EXPRESSIONS.CODE_EXP( D( AS_NAME, DST_NAME ) );							-- valeur de P = adresse désignée
--        EXPRESSIONS.CODE_EXP( SRC_EXP );								-- EXPRESSION A AFFECTER
--        STORE_VAL( D( SM_EXP_TYPE, DST_NAME ) );

      elsif  DST_NAME.TY = DN_SELECTED  then								-- AFFECTATION A UN SELECTED (COMPOSANTE DE RECORD PAR EX.)
			--------------------
			DESTINATION_SELECTED:
        declare
	DST_TYPE : TREE := D( SM_EXP_TYPE, DST_NAME );
        begin
      -- Calculer l'adresse destination : @R.C, @A(I).C, etc.
	EXPRESSIONS.CODE_SELECTED( DST_NAME, IS_SOURCE => FALSE );

	if  DST_TYPE.TY = DN_RECORD  then

	  if  SRC_EXP.TY = DN_AGGREGATE  then
	    EXPRESSIONS.CODE_AGGREGATE( SRC_EXP, DST_TYPE );
	  else
	    PUT( tab & "LI" & tab );
	    CODI.REGIONS_PATH( D( XD_SOURCE_NAME, DST_TYPE ) );
	    PUT_LINE( PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, DST_TYPE ) ) ) & ".size" );
	    EXPRESSIONS.CODE_EXP( SRC_EXP );
--	    PUT_LINE( tab & "La" );
	    PUT_LINE( tab & "BLKMOV" );
	  end if;

	elsif  DST_TYPE.TY = DN_ARRAY  or else  DST_TYPE.TY = DN_CONSTRAINED_ARRAY  then

	  if  SRC_EXP.TY = DN_AGGREGATE  then
	    EXPRESSIONS.CODE_AGGREGATE( SRC_EXP, DST_TYPE );
	  else
	    PUT( tab & "LI" & tab );
	    CODI.REGIONS_PATH( D( XD_SOURCE_NAME, DST_TYPE ) );
	    PUT_LINE( PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, DST_TYPE ) ) ) & ".size" );
	    EXPRESSIONS.CODE_EXP( SRC_EXP );
--	    PUT_LINE( tab & "La" );
	    PUT_LINE( tab & "BLKMOV" );
	  end if;

	else
         -- Scalaire : pile = @destination, valeur
	  EXPRESSIONS.CODE_EXP( SRC_EXP );
	  STORE_VAL( DST_TYPE );
	end if;
        end	DESTINATION_SELECTED;
		--------------------


      elsif  DST_NAME.TY = DN_INDEXED  then								-- AFFECTATION A UN ELEMENT DE TABLEAU
				-------------------
				DESTINATION_INDEXED:
        declare
	INDEXED_TYPE	: TREE	:= D( SM_EXP_TYPE, DST_NAME );
        begin
	EXPRESSIONS.CODE_INDEXED( DST_NAME );								-- CALCULER L ADRESSE DESTINATION

	if  SRC_EXP.TY = DN_AGGREGATE  then
	  EXPRESSIONS.CODE_AGGREGATE( SRC_EXP, D( SM_EXP_TYPE, DST_NAME ) );

	elsif  SRC_EXP.TY in CLASS_UNCONSTRAINED_COMPOSITE
	     or  ( SRC_EXP.TY = DN_USED_OBJECT_ID
		 and then  D( SM_EXP_TYPE, DST_NAME ).TY in CLASS_UNCONSTRAINED_COMPOSITE )
	then
	  PUT( tab & "LI" & tab );
	  CODI.REGIONS_PATH( D( XD_SOURCE_NAME, INDEXED_TYPE ) );
	  PUT_LINE( PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, INDEXED_TYPE ) ) ) & ".size" );			-- LEN (taille en octets, calculee par FASM)
	  EXPRESSIONS.CODE_EXP( SRC_EXP );								-- EVALUER L EXPRESSION A AFFECTER
	  PUT_LINE( tab & "La" );
	  PUT_LINE( "BLKMOV" );

        else
	EXPRESSIONS.CODE_EXP( SRC_EXP );								-- EVALUER L EXPRESSION A AFFECTER
	STORE_VAL( D( SM_EXP_TYPE, DST_NAME ) );
        end if;

        end	DESTINATION_INDEXED;
		-------------------

      elsif  DST_NAME.TY = DN_USED_OBJECT_ID  then							-- AFFECTATION A UN OBJET
				--------------------------
				DESTINATION_USED_OBJECT_ID:
        declare
	NAME_TYPE	: TREE		:= D( SM_EXP_TYPE, DST_NAME );
	DEFN	: TREE		:= D( SM_DEFN, DST_NAME );

			--------------
	procedure		STORE_OR_CALLI
	is		--------------
	    -- Si dans un body generique et parametre out/in_out, utiliser CALLI vers ST
	    -- pour respecter la taille du type actuel. Sinon, store classique.
	    -- Convention: pile = [..., @param_out, valeur]  (valeur en sommet, empilee par l'appelant)
	    -- ST fait SIb -1,0 : POP_RBX (valeur), INDIRECT_BASE_IN_RAX (deref @param → @dest), STORE
	begin
	  if  CODI.IN_GENERIC_BODY
	      and then  EXPRESSIONS.IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, NAME_TYPE ) )
	      and then  ( DEFN.TY = DN_OUT_ID  or  DEFN.TY = DN_IN_OUT_ID )
	  then
	    declare
	      FORMAL_TYPE_NAME :constant STRING := PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, NAME_TYPE ) ) );
	    begin
	        -- Charger l'adresse de ST via le GFP
	        -- Utiliser le niveau du parametre (= niveau de la procedure, pas du bloc declare)
	      PUT_LINE( tab & "La " & INTEGER'IMAGE( CODI.GENERIC_BASE_LEVEL+1 ) & ',' & tab & "-GFP_ofs" );
	      PUT_LINE( tab & "La ," & tab & '-' & FORMAL_TYPE_NAME & "__st_ofs" );
	      PUT_LINE( tab & "CALLI" );
	    end;
	  else
	    CODI.STORE( DEFN );
	  end if;
	end	STORE_OR_CALLI;
		--------------

        begin
				-- Resolve private to full type
	if  NAME_TYPE.TY = DN_L_PRIVATE  or  NAME_TYPE.TY = DN_PRIVATE  then
	  NAME_TYPE := D( SM_TYPE_SPEC, NAME_TYPE );
	end if;

	if  DEFN.TY in CLASS_VC_NAME  and then  DB( SM_RENAMES_OBJ, DEFN )  then
				--------------
				MANAGE_RENAMES:
	  declare
	    DEFN_STR	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
	    DEFN_LVL	: INTEGER		:= DI( CD_LEVEL, DEFN );
	  begin
	    if  NAME_TYPE.TY in CLASS_SCALAR  then
	      EXPRESSIONS.CODE_EXP( SRC_EXP );
	      PUT_LINE( tab & "SI" & CODI.OPER_SIZ_CHAR( NAME_TYPE ) & tab & IMAGE( DEFN_LVL ) & ", "
			& DEFN_STR & "_disp, 0" );
	      return;
	    end if;
	  end	MANAGE_RENAMES;
		--------------
          end if;

          if  NAME_TYPE.TY = DN_ACCESS  then								-- OBJET ASSIGNE DE TYPE ACCES
	  EXPRESSIONS.CODE_EXP( SRC_EXP );
	  CODI.STORE( DEFN );

	elsif  NAME_TYPE.TY = DN_ARRAY  or  NAME_TYPE.TY = DN_CONSTRAINED_ARRAY  then								-- OBJET ASSIGNE TABLEAU
	  CODE_OBJECT( DEFN );
	  if  SRC_EXP.TY = DN_USED_OBJECT_ID  then
	    CODE_OBJECT( D( SM_DEFN, SRC_EXP ) );
	    CODE_OBJECT( SRC_EXP );

	  elsif  SRC_EXP.TY = DN_AGGREGATE  then
	    EXPRESSIONS.CODE_AGGREGATE( SRC_EXP, NAME_TYPE );

	  else
	    EXPRESSIONS.CODE_EXP( SRC_EXP );
            end if;

	elsif  NAME_TYPE.TY = DN_ENUMERATION  then							-- OBJET ASSIGNE ENUMERATION (DONT BOOLEAN, CHARACTER)
	  if  CODI.IN_GENERIC_BODY  and then  ( DEFN.TY = DN_OUT_ID  or  DEFN.TY = DN_IN_OUT_ID )  then
	    PUT_LINE( tab & "LVA " & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ','
		    & tab & '-' & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & "_ofs" );
	    PUT_LINE( tab & "La" );
	  end if;
	  EXPRESSIONS.CODE_EXP( SRC_EXP );
	  STORE_OR_CALLI;

	elsif  NAME_TYPE.TY = DN_INTEGER  or  NAME_TYPE.TY = DN_FIXED  or  NAME_TYPE.TY = DN_FLOAT  then		-- OBJET ASSIGNE SCALAIRE

	  if  CODI.IN_GENERIC_BODY  then

	    if  DEFN.TY = DN_OUT_ID  or  DEFN.TY = DN_IN_OUT_ID  then
	      PUT_LINE( tab & "LVA " & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ','
		    & tab & '-' & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & "_ofs" );
	      PUT_LINE( tab & "La" );

	    elsif  EXPRESSIONS.IS_GENERIC_FORMAL_TYPE( D( XD_SOURCE_NAME, NAME_TYPE ) )  then
	      PUT_LINE( tab & "LVA " & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ','
		    & tab & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & "_disp" );
	    end if;

	  end if;

	  EXPRESSIONS.CODE_EXP( SRC_EXP );
	  STORE_OR_CALLI;

	elsif  NAME_TYPE.TY = DN_RECORD  then								-- OBJET ASSIGNE RECORD
	  if  DEFN.TY = DN_COMPONENT_ID  then
	    PUT_LINE( "; !!! ASSIGN DST COMPONENT_ID DN_RECORD A FAIRE" );

	  else
	    CODI.LOAD_MEM( DEFN );									-- @variable (adresse du doublet @data @use__info)
	  end if;
	  PUT_LINE( tab & "La" );									-- @DST (adresse des data)

	  PUT( tab & "LI" & tab );
	  CODI.REGIONS_PATH( D( XD_SOURCE_NAME, NAME_TYPE ) );
	  PUT_LINE( PRINT_NAME( D( LX_SYMREP, D( XD_SOURCE_NAME, NAME_TYPE ) ) ) & ".size" );			-- LEN (taille en octets, calculee par FASM)

	  if  SRC_EXP.TY = DN_AGGREGATE  then
	    EXPRESSIONS.CODE_AGGREGATE( SRC_EXP, NAME_TYPE );
	  else
	    EXPRESSIONS.CODE_EXP( SRC_EXP );								-- @variable (adresse du doublet)
	    PUT_LINE( tab & "La" );									-- @SRC (adresse des data)
	    PUT_LINE( tab & "BLKMOV" );									-- COPY_BLOCK  @DST LEN @SRC
	  end if;

	else											-- AUTRE TYPE SCALAIRE (type formel generique, etc.)
	  if  CODI.IN_GENERIC_BODY  and then  ( DEFN.TY = DN_OUT_ID  or  DEFN.TY = DN_IN_OUT_ID )  then
	    PUT_LINE( tab & "LVa " & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ',' & tab & '-' & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & "_ofs" );
	    PUT_LINE( tab & "La" );
	  end if;
	  EXPRESSIONS.CODE_EXP( SRC_EXP );
	  STORE_OR_CALLI;

          end if;

        end	DESTINATION_USED_OBJECT_ID;
		--------------------------

      elsif  DST_NAME.TY = DN_SLICE  then								-- AFFECTATION A UNE TRANCHE
        EXPRESSIONS.CODE_SLICE( DST_NAME );
        EXPRESSIONS.CODE_EXP( SRC_EXP );
        PUT_LINE( tab & "La" );
        PUT_LINE( tab & "BLKMOV" );									-- COPY_BLOCK;	- @DST @SRC LEN
      end if;
    end;
  end	CODE_ASSIGN;
	-----------


			---------
  procedure		CODE_EXIT			( ADA_EXIT :TREE )
  is			---------
  begin
    declare
      LVB_LBL		:constant STRING	:= NEW_LABEL;
      EXP			: TREE		:= D ( AS_EXP, ADA_EXIT );
      LOOP_STM		: TREE		:= D ( SM_STM, ADA_EXIT );
      EXITED_LOOP_LEVEL	: LEVEL_NUM	:= LEVEL_NUM( DI( CD_LEVEL, LOOP_STM ) );
      AFTER_LOOP_LABEL	: LABEL_TYPE	:= LABEL_TYPE( DI( CD_AFTER_LOOP, LOOP_STM ) );
    begin
      if EXP = TREE_VOID then
        if EXITED_LOOP_LEVEL /= CODI.CUR_LEVEL then
	PUT_LINE( tab & "UNLINK" & tab & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL+1 - EXITED_LOOP_LEVEL ) );
        end if;
        PUT_LINE( tab & "BRA" & tab & LABEL_STR( AFTER_LOOP_LABEL ) );

      else
        EXPRESSIONS.CODE_EXP( EXP );
        if EXITED_LOOP_LEVEL /= CODI.CUR_LEVEL then
          declare
            SKIP_LBL	:constant STRING	:= NEW_LABEL;
          begin
	  PUT_LINE( tab & "BF" & tab & SKIP_LBL );
	  PUT_LINE( tab & "UNLINK" & tab & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL+1 - EXITED_LOOP_LEVEL ) );
	  PUT_LINE( tab & "BRA" & tab & LABEL_STR( AFTER_LOOP_LABEL ) );
            PUT_LINE( SKIP_LBL & ':' );
          end;
        else
	PUT_LINE( tab & "BT" & tab & LABEL_STR( AFTER_LOOP_LABEL ) );

        end if;
      end if;
    end;

  end	CODE_EXIT;
	---------


	------------
end	INSTRUCTIONS;
	------------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
