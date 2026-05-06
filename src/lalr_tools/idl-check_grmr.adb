------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with GRMR_OPS, GRMR_TBL;
use  GRMR_OPS, GRMR_TBL;
separate(	IDL )
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE	CHECK_GRMR
--|-------------------------------------------------------------------------------------------------
procedure	CHECK_GRMR ( NOM_TEXTE :STRING ) is
  USER_ROOT		: TREE;
  GR_STATE_SEQ		: SEQ_TYPE;

  STATE			: TREE;
  STATE_NBR		: INTEGER;
  TER_GO_COUNT		: INTEGER;
  NONTER_GO_COUNT		: INTEGER;
  REDUCE_COUNT		: INTEGER;

  REDUCE_NBR_TERS		: array (1 .. 6) of	INTEGER;
  REDUCE_ITEM		: array (1 .. 6) of	TREE;

  type SYLTBL_TYPE		is record
			  STATE_NBR	: INTEGER;
			  REDUCE		: BOOLEAN;
			end record;

  SYLTBL			: array (- INTEGER(170) .. 350) of SYLTBL_TYPE;

  ALT_SEM_TBL		: array (0 .. 700) of INTEGER;
        -- SEMANTICS FOR ALT (OR 0)

  --|-----------------------------------------------------------------------------------------------
  --|	FUNCTION INTEGER_IMAGE
  function INTEGER_IMAGE ( V :INTEGER )	return STRING is
  begin
    if V < 0 then
      return '-' & INTEGER_IMAGE(- V);
    elsif	V >= 10 then
      return INTEGER_IMAGE ( V / 10 ) &	INTEGER_IMAGE ( V mod 10 );
    else
      return "" & CHARACTER'VAL ( CHARACTER'POS (	'0' ) + V	);
    end if;
  end INTEGER_IMAGE;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE	SCAN_GRAMMAR
  procedure SCAN_GRAMMAR is
    STATE_SEQ		: SEQ_TYPE	:= GR_STATE_SEQ;
    TER_GO_SUM		: INTEGER		:= 0;
    NONTER_GO_SUM		: INTEGER		:= 0;
    REDUCE_SUM		: INTEGER		:= 0;

    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE	SCAN_STATE
    procedure SCAN_STATE is
      ITEM_SEQ		: SEQ_TYPE	:= LIST (	STATE );
      ITEM		: TREE;
      SYL_SEQ		: SEQ_TYPE;
      SYL			: TREE;
      SYL_NBR		: INTEGER;
      RULE		: TREE;
      GOTO_STATE		: TREE;

      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE	CHECK_REDUCE
      procedure CHECK_REDUCE ( ITEM :TREE ) is
	      -- MARK SYMBOLS USED FOR REDUCE; CHECK FOR REDUCE-REDUCE CONFLICT
        NBR_TERS		: INTEGER		:= 0;
        FOLLOW_SEQ		: SEQ_TYPE	:= LIST( D( XD_FOLLOW, ITEM )	);
        TER		: TREE;
        TER_NBR		: INTEGER;
      begin
        while not IS_EMPTY( FOLLOW_SEQ ) loop
	TER := HEAD( FOLLOW_SEQ ); FOLLOW_SEQ := TAIL( FOLLOW_SEQ );
	TER_NBR := DI( XD_TER_NBR, TER );
	if SYLTBL( -TER_NBR	).STATE_NBR /= STATE_NBR then
	  SYLTBL(	-TER_NBR ).STATE_NBR := STATE_NBR;
	elsif SYLTBL( -TER_NBR ).REDUCE then
	  ERROR( D( LX_SRCPOS, D( XD_ALTERNATIVE, ITEM ) ),
	         "RED/RED CONF STATE " & INTEGER_IMAGE( STATE_NBR )
				& " - " &	PRINT_NAME( D( XD_SYMREP, TER	) ) );
	end if;
	SYLTBL( -TER_NBR ).REDUCE := TRUE;
	NBR_TERS := NBR_TERS + 1;
        end loop;
        REDUCE_NBR_TERS( REDUCE_COUNT )	:= NBR_TERS;
        REDUCE_ITEM( REDUCE_COUNT ) := ITEM;
      end	CHECK_REDUCE;
      --|----------------------------------------------------------------------------------------------
      --|		FUNCTION REDUCE_ACTION
      function REDUCE_ACTION ( ITEM :TREE ) return INTEGER is
        ALT		: TREE	:= D ( XD_ALTERNATIVE, ITEM );
        ALT_NBR		: INTEGER	:= DI( XD_ALT_NBR, ALT );
        ALT_SEM		: INTEGER	:= ALT_SEM_TBL( ALT_NBR );
	      -- 0 OR ACTION ENTRY
        SEM_S		: SEQ_TYPE;
        SEM		: TREE;
        SEM_OP_POS		: INTEGER;
        SEM_OP_KIND	: GRMR_OP;
        CODE		: INTEGER;
        TXT		: TREE;

        --|-------------------------------------------------------------------------------------------
        --|	PROCEDURE	REDUCE_CODE
        function REDUCE_CODE ( ALT :TREE ) return	INTEGER is
	NBR_POPS	: INTEGER	:= 0;
	SYL_LIST	: SEQ_TYPE	:= LIST (	ALT );
        begin
	while not	IS_EMPTY(	SYL_LIST ) loop
	  SYL_LIST := TAIL(	SYL_LIST );
	  NBR_POPS := NBR_POPS + 1;
	end loop;
	return - ( 10_000 +	NBR_POPS * 1000 + DI ( XD_RULE_NBR, D (	XD_RULEINFO, D ( XD_RULE, ALT	) ) )
	         );
        end REDUCE_CODE;

      begin
        if ALT_SEM /= 0 then
	return ALT_SEM; -- ALREADY COMPUTED
        end if;

        SEM_S := LIST( D( XD_SEMANTICS,	ALT ) );
        if IS_EMPTY( SEM_S ) then							-- NO SEMANTICS, JUST USE REDUCE CODE
	ALT_SEM := REDUCE_CODE( ALT );
        else									-- SEMANTICS, INDIRECT INTO REST OF ALT	TBL
	ALT_SEM := - (GRMR.AC_TBL_LAST + 1);						-- BRANCH	TO WHERE SEMANTICS WILL START
	while not	IS_EMPTY(	SEM_S) loop
	  POP( SEM_S, SEM );
	  GRMR.AC_TBL_LAST := GRMR.AC_TBL_LAST + 1;
	  SEM_OP_POS       := DI( XD_SEM_OP, SEM );
	  SEM_OP_KIND      := GRMR_OP'VAL( SEM_OP_POS );
	  CODE	         := 1000 * SEM_OP_POS;
	  if SEM_OP_KIND in	GRMR_OP_NODE then
	    CODE := CODE + DI( XD_KIND, SEM );
	  elsif SEM_OP_KIND	in GRMR_OP_QUOTE then
	    TXT  := D( XD_KIND, SEM );
	    CODE := CODE + INTEGER( TXT.PG );
	    GRMR.AC_TBL( GRMR.AC_TBL_LAST ) := AC_SHORT( CODE );
	    GRMR.AC_TBL_LAST := GRMR.AC_TBL_LAST + 1;
	    CODE := INTEGER( TXT.LN );
	  end if;
	  GRMR.AC_TBL( GRMR.AC_TBL_LAST ) := AC_SHORT( CODE );
	end loop;
	GRMR.AC_TBL_LAST :=	GRMR.AC_TBL_LAST + 1;
	GRMR.AC_TBL( GRMR.AC_TBL_LAST	) := AC_SHORT( REDUCE_CODE ( ALT ) );
        end if;
	      -- SAVE COMPUTED VALUE AND RETURN
        ALT_SEM_TBL( ALT_NBR ) := ALT_SEM;
        return ALT_SEM;

      end	REDUCE_ACTION;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE	GEN_TER_INFO
      procedure GEN_TER_INFO is
	      -- FILL IN INFO FOR TERMINALS AND	DONT CARE	IN ACTION	TABLE
        ITEM_SEQ		: SEQ_TYPE;
        ITEM		: TREE;
        GOTO_STATE		: TREE;
        TEMP_INTEGER	: INTEGER;
        TEMP_TREE		: TREE;
        SYL_LIST		: SEQ_TYPE;
        SYL		: TREE;
        SYL_NBR		: INTEGER;
      begin
	   -- WRITE TER GOTO ACTIONS
        if TER_GO_COUNT > 0 then
	ITEM_SEQ := LIST( STATE );
	while not	IS_EMPTY(	ITEM_SEQ ) loop
	  ITEM :=	HEAD( ITEM_SEQ ); ITEM_SEQ :=	TAIL( ITEM_SEQ );
	  GOTO_STATE := D( XD_GOTO, ITEM);
	  if GOTO_STATE.TY /= DN_VOID	then
	    SYL := HEAD( LIST( ITEM )	);
	    if SYL.TY = DN_TERMINAL then
	      SYL_NBR := DI	( XD_TER_NBR, SYL );
	      if SYLTBL(- SYL_NBR).STATE_NBR = STATE_NBR then
	        SYLTBL(- SYL_NBR).STATE_NBR := 0;
	        GRMR.AC_SYM_LAST := GRMR.AC_SYM_LAST + 1;
	        GRMR.AC_SYM( GRMR.AC_SYM_LAST )	:= AC_BYTE( SYL_NBR	);
	        GRMR.AC_TBL( GRMR.AC_SYM_LAST )	:= AC_SHORT( DI ( XD_STATE_NBR, GOTO_STATE ) );
	      end	if;
	    end if;
	  end if;
	end loop;
        end if;

	      -- WRITE NON-DEFAULT REDUCE ACTIONS
	      -- FIRST MAKE	#1 LONGEST REDUCE (IT WILL BE	DONT CARE)
        for I in 2 .. REDUCE_COUNT loop
	if REDUCE_NBR_TERS (I) > REDUCE_NBR_TERS (1) then
	  TEMP_INTEGER := REDUCE_NBR_TERS(1);
	  TEMP_TREE := REDUCE_ITEM(1);
	  REDUCE_NBR_TERS(1) := REDUCE_NBR_TERS(I);
	  REDUCE_ITEM(1) :=	REDUCE_ITEM(I);
	  REDUCE_NBR_TERS(I) := TEMP_INTEGER;
	  REDUCE_ITEM(I) :=	TEMP_TREE;
	end if;

		    -- NOW COMPUTE REDUCE ACTION AND PUT OUT FOR EACH TER
	TEMP_INTEGER := REDUCE_ACTION( REDUCE_ITEM(I) );
	SYL_LIST := LIST ( D ( XD_FOLLOW, REDUCE_ITEM( I ) ) );
	while not	IS_EMPTY ( SYL_LIST	) loop
	  GRMR.AC_SYM_LAST := GRMR.AC_SYM_LAST + 1;
	  GRMR.AC_SYM( GRMR.AC_SYM_LAST ) := AC_BYTE( DI ( XD_TER_NBR, HEAD (	SYL_LIST ) ) );
	  GRMR.AC_TBL( GRMR.AC_SYM_LAST ) := AC_SHORT( TEMP_INTEGER	);
	  SYL_LIST := TAIL ( SYL_LIST	);
	end loop;
        end loop;

	      -- NOW PUT OUT DONT CARE ACTION
        GRMR.AC_SYM_LAST := GRMR.AC_SYM_LAST + 1;
        GRMR.AC_SYM( GRMR.AC_SYM_LAST )	:= 0;
        if REDUCE_COUNT > 0 then
	GRMR.AC_TBL( GRMR.AC_SYM_LAST	) := AC_SHORT( REDUCE_ACTION ( REDUCE_ITEM( 1 ) )	);
        else
	GRMR.AC_TBL( GRMR.AC_SYM_LAST	) := 0;
        end if;
      end	GEN_TER_INFO;

    begin
      while not IS_EMPTY( ITEM_SEQ) loop
        POP( ITEM_SEQ, ITEM );
        SYL_SEQ := LIST( ITEM	);
        if IS_EMPTY( SYL_SEQ)	then
	REDUCE_COUNT := REDUCE_COUNT + 1;
	CHECK_REDUCE( ITEM );
        else
	SYL := HEAD( SYL_SEQ );
	if SYL.TY	= DN_TERMINAL then
	  SYL_NBR	:= - DI (	XD_TER_NBR, SYL );
	  if SYLTBL( SYL_NBR ).STATE_NBR /= STATE_NBR then
	    TER_GO_COUNT :=	TER_GO_COUNT + 1;
	    SYLTBL( SYL_NBR	).STATE_NBR := STATE_NBR;
	    SYLTBL( SYL_NBR	).REDUCE := FALSE;
	  end if;
	else
	  RULE :=	D( XD_RULE, SYL );
	  if RULE.TY /= DN_VOID then
	    SYL_NBR := DI( XD_RULE_NBR, D( XD_RULEINFO, RULE ) );
	    if SYLTBL( SYL_NBR ).STATE_NBR /= STATE_NBR then
	      NONTER_GO_COUNT := NONTER_GO_COUNT + 1;
	      SYLTBL( SYL_NBR ).STATE_NBR := STATE_NBR;
	      SYLTBL( SYL_NBR ).REDUCE := FALSE;
	    end if;
	  end if;
	end if;
        end if;
      end	loop;

	      -- CHECK FOR SHIFT-REDUCE CONFLICTS
      if REDUCE_COUNT > 0 then
        ITEM_SEQ :=	LIST ( STATE );
        while not IS_EMPTY ( ITEM_SEQ )	loop
	POP ( ITEM_SEQ, ITEM );
	SYL_SEQ := LIST ( ITEM );
	if not IS_EMPTY ( SYL_SEQ ) then
	  SYL := HEAD ( SYL_SEQ );
	  if SYL.TY = DN_TERMINAL then
	    SYL_NBR := - DI	( XD_TER_NBR, SYL );
	    if SYLTBL( SYL_NBR ).REDUCE then
	      ERROR ( D ( LX_SRCPOS, SYL ), "SHIFT/RED CONF STATE "	& INTEGER_IMAGE ( STATE_NBR )
			& " - " &	PRINT_NAME ( D ( XD_SYMREP, SYL ) ) );
	    end if;
	  end if;
	end if;
        end loop;
      end	if;

	      -- WRITE NONTER ACTIONS
      if NONTER_GO_COUNT > 0 then
        ITEM_SEQ :=	LIST( STATE );
        while not IS_EMPTY( ITEM_SEQ ) loop
	POP( ITEM_SEQ, ITEM	);
	GOTO_STATE := D ( XD_GOTO, ITEM );
	if GOTO_STATE.TY /=	DN_VOID then
	  SYL := HEAD( LIST	( ITEM ) );
	  if SYL.TY = DN_NONTERMINAL then
	    SYL_NBR := DI( XD_RULE_NBR, D( XD_RULEINFO, D( XD_RULE,	SYL ) ) );
	    if SYLTBL( SYL_NBR ).STATE_NBR = STATE_NBR then
	      SYLTBL( SYL_NBR ).STATE_NBR := 0;
	      GRMR.AC_SYM_LAST := GRMR.AC_SYM_LAST + 1;
	      GRMR.AC_SYM( GRMR.AC_SYM_LAST ) := AC_BYTE(	SYL_NBR );
	      GRMR.AC_TBL( GRMR.AC_SYM_LAST ) := AC_SHORT( DI( XD_STATE_NBR, GOTO_STATE	) );
	    end if;
	  end if;
	end if;
        end loop;
      end	if;

	      -- WRITE STATE TABLE ENTRY
      GRMR.ST_TBL_LAST := GRMR.ST_TBL_LAST + 1;
	      -- ASSUME NO SEMANTICS FOR NOW !!!!
      if TER_GO_COUNT = 0 and	then NONTER_GO_COUNT = 0 and then REDUCE_COUNT = 1 then
        GRMR.ST_TBL( GRMR.ST_TBL_LAST )	:= REDUCE_ACTION( ITEM );
      else
        GRMR.ST_TBL( GRMR.ST_TBL_LAST )	:= GRMR.AC_SYM_LAST	+ 1;
        GEN_TER_INFO;
      end	if;
    end SCAN_STATE;

  begin
    while	not IS_EMPTY ( STATE_SEQ ) loop
      POP	( STATE_SEQ, STATE );
      STATE_NBR := DI ( XD_STATE_NBR, STATE );
      TER_GO_COUNT := 0;
      NONTER_GO_COUNT := 0;
      REDUCE_COUNT := 0;
      SCAN_STATE;
      INT_IO.PUT ( STATE_NBR );
      INT_IO.PUT ( TER_GO_COUNT );
      INT_IO.PUT ( NONTER_GO_COUNT );
      INT_IO.PUT ( REDUCE_COUNT );
      NEW_LINE;
      NONTER_GO_SUM	:= NONTER_GO_SUM + NONTER_GO_COUNT;
      TER_GO_SUM :=	TER_GO_SUM + TER_GO_COUNT;
      REDUCE_SUM :=	REDUCE_SUM + REDUCE_COUNT;
    end loop;
    PUT (	"******" );
    INT_IO.PUT ( TER_GO_SUM );
    INT_IO.PUT ( NONTER_GO_SUM );
    INT_IO.PUT ( REDUCE_SUM );
    NEW_LINE;
  end SCAN_GRAMMAR;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE	WRITE_TABLES
  procedure WRITE_TABLES is
    OFILE			: FILE_TYPE;
    STATE_IND		: INTEGER	:= 1;
    RULE_LIST		: SEQ_TYPE;
    RULE			: TREE;
    AC_SUB		: INTEGER;
    TXT_LN		: INTEGER;
  begin
    CREATE( OFILE, OUT_FILE, "parse.tbl" );
    PUT( "NBR OF STATES IS" );
    INT_IO.PUT( GRMR.ST_TBL_LAST );
    PUT( " - MAX");
    INT_IO.PUT( GRMR.ST_TBL'LAST );
    NEW_LINE;
    PUT( "NBR OF ACTION SYMBOLS IS" );
    INT_IO.PUT( GRMR.AC_SYM_LAST );
    PUT( " - MAX" );
    INT_IO.PUT( GRMR.AC_SYM'LAST );
    NEW_LINE;
    PUT( "LAST ACTION ENTRY IS" );
    INT_IO.PUT( GRMR.AC_TBL_LAST );
    PUT( " - MAX" );
    INT_IO.PUT( GRMR.AC_TBL'LAST );
    NEW_LINE;
    for I	in 1 .. GRMR.AC_SYM_LAST loop
      while STATE_IND <= GRMR.ST_TBL_LAST and then GRMR.ST_TBL( STATE_IND ) <= I loop
        PUT( OFILE,	'S' );
        INT_IO.PUT(	OFILE, STATE_IND, 4	);
        INT_IO.PUT(	OFILE, GRMR.ST_TBL(	STATE_IND	) );
        NEW_LINE( OFILE );
        STATE_IND := STATE_IND + 1;
      end	loop;
      PUT( OFILE, 'T' );
      INT_IO.PUT( OFILE, I, 5	);
      INT_IO.PUT( OFILE, INTEGER( GRMR.AC_TBL( I ) ) );
      INT_IO.PUT( OFILE, INTEGER( GRMR.AC_SYM( I ) ) );
      NEW_LINE( OFILE );
    end loop;
    while	STATE_IND	<= GRMR.ST_TBL_LAST	loop
      PUT	( OFILE, 'S' );
      INT_IO.PUT( OFILE, STATE_IND, 4 );
      INT_IO.PUT( OFILE, GRMR.ST_TBL( STATE_IND )	);
      NEW_LINE( OFILE );
      STATE_IND := STATE_IND + 1;
    end loop;

    PUT (	"NUMBER OF ACTION ENTRIES IS"	);
    INT_IO.PUT( GRMR.AC_TBL_LAST );
    NEW_LINE;

    AC_SUB := GRMR.AC_SYM'LAST;
    while	AC_SUB < GRMR.AC_TBL_LAST loop
      AC_SUB := AC_SUB + 1;
      PUT( OFILE, 'A' );
      INT_IO.PUT( OFILE, AC_SUB, 5 );
      declare
        DATA		: INTEGER		:= INTEGER( GRMR.AC_TBL( AC_SUB ) );
        DATA_KIND		: GRMR_OP;
        TXT		: TREE;
      begin
        if DATA < 1000 then
	INT_IO.PUT ( OFILE,	DATA );
        elsif (DATA	/ 1000) >	GRMR_OP'POS ( GRMR_OP'LAST ) then
	INT_IO.PUT ( OFILE,	DATA );
	PUT( OFILE, "###############");
	PUT_LINE(	"##### ERROR IN TABLE");
        else
	DATA_KIND	:= GRMR_OP'VAL( DATA / 1000 );
	if DATA_KIND not in	GRMR_OP_QUOTE then
	  INT_IO.PUT( OFILE, DATA );
	else
	  INT_IO.PUT( OFILE, GRMR_OP'POS( DATA_KIND ) * 1000 );
	  AC_SUB := AC_SUB + 1;
	  TXT_LN := INTEGER( GRMR.AC_TBL( AC_SUB ) );
	  if TXT_LN in 0..INTEGER( LINE_NBR'LAST ) then
	    TXT := (P, PG=>	PAGE_IDX(	DATA mod 1000 ), TY=> DN_SYMBOL_REP, LN=> LINE_IDX( TXT_LN ));
	    PUT( OFILE, PRINT_NAME ( TXT ) );
	  else
	    INT_IO.PUT ( OFILE, DATA mod 1000 );
	    PUT( OFILE, ' '	);
	    INT_IO.PUT ( OFILE, TXT_LN, 0 );
	    PUT( OFILE, "**********" );
	    PUT_LINE( "***** ERROR IN TABLE" );
	  end if;
	end if;
        end if;
      end;
      NEW_LINE ( OFILE );
    end loop;

    GRMR.NTER_LAST := 0;
    RULE_LIST := LIST ( D ( XD_GRAMMAR,	USER_ROOT));
    while	not IS_EMPTY ( RULE_LIST ) loop
      POP	( RULE_LIST, RULE );
      GRMR.NTER_LAST := GRMR.NTER_LAST + 1;
      PUT	( OFILE, 'N' );
      INT_IO.PUT ( OFILE, GRMR.NTER_LAST, 4 );
      PUT	( OFILE, ' ' );
      PUT_LINE ( OFILE, PRINT_NAME ( D ( XD_NAME,	RULE ) ) );
    end loop;
    PUT (	"NUMBER OF NONTERMINALS IS");
    INT_IO.PUT ( GRMR.NTER_LAST );
    NEW_LINE;
    CLOSE	( OFILE );
  end WRITE_TABLES;

begin
  OPEN_IDL_TREE_FILE( NOM_TEXTE & ".lar" );
  USER_ROOT := D( XD_USER_ROOT, TREE_ROOT );
  GR_STATE_SEQ := LIST( D( XD_STATELIST, USER_ROOT ) );

  if DI( XD_ERR_COUNT, TREE_ROOT ) > 0 then
    INT_IO.PUT( DI(	XD_ERR_COUNT, TREE_ROOT ), 1 );
    PUT_LINE (  " ERRORS IN EARLY PHASES." );
  end if;

  for I in SYLTBL'range loop
    SYLTBL( I ).STATE_NBR := 0;
  end loop;

  GRMR.ST_TBL_LAST := 0;
  GRMR.AC_SYM_LAST := 1;
  GRMR.AC_TBL_LAST := GRMR.AC_SYM'LAST;			-- I.E., NOTHING WITH GREATER	INDEX YET
  GRMR.AC_SYM( 1 ) := 0;
  GRMR.AC_TBL( 1 ) := 0;			-- ERROR AS FIRST ELT
  GRMR.NTER_LAST :=	0;

  ALT_SEM_TBL := (others=> 0);

  SCAN_GRAMMAR;
  WRITE_TABLES;

  CLOSE_IDL_TREE_FILE;
--|-------------------------------------------------------------------------------------------------
end CHECK_GRMR;
