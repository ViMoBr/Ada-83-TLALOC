------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate( IDL )
--|-------------------------------------------------------------------------------------------------
--|		LALR_GRMR
procedure LALR_GRMR ( NOM_TEXTE :STRING ) is

  type STBL_TYPE	is record
		  CHANGED, CLOSURE  : BOOLEAN := FALSE;
		  STATE		: TREE	:= TREE_VOID;
		end record;
  STBL	: array( 1 .. 1100 ) of STBL_TYPE;

  type RTBL_TYPE	is record
		  STATE_NBR	: INTEGER := 0;
		  REQ_CHECK	: BOOLEAN;
		  FOLLOW		: TREE;
		end record;
  RTBL	: array( 1 .. 400 ) of RTBL_TYPE;

  MORE_PASSES		: BOOLEAN;
  MORE_CLOSURE_PASSES	: BOOLEAN;
  GR_STATE_SEQ		: SEQ_TYPE;

  --|-----------------------------------------------------------------------------------------------
  --|		FUNCTION GET_RULE_NBR
  function GET_RULE_NBR ( SYL_LIST :SEQ_TYPE ) return INTEGER is
    SYL	: TREE;
    RULE  : TREE;
  begin
    if IS_EMPTY( SYL_LIST ) then
      return 0;
    end if;
    SYL := HEAD( SYL_LIST );
    if SYL.TY /= DN_NONTERMINAL then
      return 0;
    end if;
    RULE := D( XD_RULE, SYL );
    if RULE.TY = DN_VOID then
      return 0;
    end if;
    return DI( XD_RULE_NBR, D( XD_RULEINFO, RULE ) );
  end;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE INITIALIZE
  procedure INITIALIZE is
    STATE_SEQ	: SEQ_TYPE	:= GR_STATE_SEQ;
    STATE		: TREE;
    STATE_NBR	: INTEGER;
    ITEM_SEQ	: SEQ_TYPE;
    ITEM		: TREE;
  begin
    while not IS_EMPTY( STATE_SEQ) loop
      POP( STATE_SEQ, STATE );
      STATE_NBR := DI( XD_STATE_NBR, STATE );
      PUT( "INIT" );
      INT_IO.PUT( STATE_NBR );
      NEW_LINE;
      STBL( STATE_NBR ).STATE := STATE;

      ITEM_SEQ := LIST( STATE);
      while not IS_EMPTY( ITEM_SEQ ) loop
        POP( ITEM_SEQ, ITEM );

INIT_MAKE_RTBL_ONE_ITEM:
        declare
	FOLLOW	: TREE;
        begin
	if DI ( XD_SYL_NBR, ITEM ) = 0 then			-- CLOSURE ITEM
	  STBL( STATE_NBR ).CLOSURE := TRUE;

	  declare
	    ALTERNATIVE	: TREE		:= D( XD_ALTERNATIVE, ITEM );
	    RULE		: TREE		:= D( XD_RULE, ALTERNATIVE );
	    RULE_INFO	: TREE		:= D( XD_RULEINFO, RULE );
	    RULE_NBR	: INTEGER		:= DI( XD_RULE_NBR, RULE_INFO );
	    RTBL_I	: RTBL_TYPE	renames RTBL( RULE_NBR );
	  begin
	    if RTBL_I.STATE_NBR /= STATE_NBR then		-- HAVE NOT ALREADY SEEN A CLOSURE ITEM FOR THIS RULE
	      RTBL_I.STATE_NBR := STATE_NBR;
	      RTBL_I.FOLLOW := MAKE( DN_TERMINAL_S );
	      LIST( RTBL_I.FOLLOW, (TREE_NIL,TREE_NIL) );
	    end if;
	    FOLLOW := RTBL_I.FOLLOW;
	  end;

	else				-- BASIS ITEM
	  FOLLOW := MAKE( DN_TERMINAL_S );
	  LIST( FOLLOW, (TREE_NIL,TREE_NIL) );
	end if;
	D( XD_FOLLOW, ITEM, FOLLOW );
        end INIT_MAKE_RTBL_ONE_ITEM;

      end loop;

      if STBL( STATE_NBR ).CLOSURE then
        ITEM_SEQ := LIST( STATE );
        while not IS_EMPTY( ITEM_SEQ ) loop
	POP( ITEM_SEQ, ITEM );

INIT_CLOSE_RTBL_ONE_ITEM:
	declare
	  SYL_LIST	: SEQ_TYPE	:= LIST( ITEM );
	  RULE_NBR	: INTEGER;
	  SYL		: TREE;
	  RULE		: TREE;
	  FOLLOW		: TREE;
	  FOLLOW_SEQ	: SEQ_TYPE;
	  FOLLOW_SAVE	: SEQ_TYPE;
	begin
	  RULE_NBR := GET_RULE_NBR( SYL_LIST );

	  if RULE_NBR = 0 then
	    goto FIN;
	  end if;

	  SYL_LIST := TAIL( SYL_LIST );
	  if IS_EMPTY( SYL_LIST ) then
	    goto FIN;
	  end if;

	  if RTBL( RULE_NBR ).STATE_NBR /= STATE_NBR then
	    PUT( "*** RULE TABLE INCORRECT." );
	    INT_IO.PUT( RULE_NBR );
	    INT_IO.PUT( RTBL( RULE_NBR ).STATE_NBR );
	    INT_IO.PUT( STATE_NBR );
	    NEW_LINE;
	    goto FIN;
	  end if;

	  FOLLOW := RTBL( RULE_NBR ).FOLLOW;
	  FOLLOW_SEQ := LIST( FOLLOW );
	  FOLLOW_SAVE := FOLLOW_SEQ;

	  loop
	    POP( SYL_LIST, SYL );
	    if SYL.TY = DN_TERMINAL then
	      FOLLOW_SEQ := TERM_LIST.UNION( FOLLOW_SEQ, SYL );
	      exit;
	    else
	      RULE := D( XD_RULE, SYL );
	      if RULE.TY = DN_VOID then
	        exit;
	      end if;
	      FOLLOW_SEQ := TERM_LIST.UNION( FOLLOW_SEQ, LIST( D( XD_RULEINFO, RULE ) ) );
	      if not DB( XD_IS_NULLABLE, RULE ) then
	        exit;
	      end if;
	    end if;
	    exit when IS_EMPTY( SYL_LIST );
	  end loop;

	  if not TERM_LIST.SAME( FOLLOW_SEQ, FOLLOW_SAVE ) then
	    LIST( FOLLOW, FOLLOW_SEQ );
	    STBL( STATE_NBR ).CHANGED := TRUE;
	  end if;
	end INIT_CLOSE_RTBL_ONE_ITEM;
<<FIN>>
	null;
        end loop;
      end if;
    end loop;
  end INITIALIZE;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE TRANS_CLOSE
  procedure TRANS_CLOSE is
    STATE		: TREE;
    RULE		: TREE;
    RULE_NBR	: INTEGER;
    ITEM		: TREE;
    ITEM_SEQ	: SEQ_TYPE;
    ITEM_SUBSEQ	: SEQ_TYPE;

    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE TRANS_CLOSE_CLOSURE_ONE_ITEM
    procedure TRANS_CLOSE_CLOSURE_ONE_ITEM ( STATE_NBR :INTEGER; ITEM :TREE ) is
      SYL_LIST	: SEQ_TYPE	:= LIST( ITEM);
      RULE_NBR	: INTEGER;
      SYL		: TREE;
      RULE	: TREE;
      FOLLOW	: TREE;
      FOLLOW_SEQ	: SEQ_TYPE;
      FOLLOW_SAVE	: SEQ_TYPE;
    begin
      RULE_NBR := GET_RULE_NBR( SYL_LIST );
      if RULE_NBR = 0 then
        return;
      end if;
      if RTBL( RULE_NBR ).STATE_NBR /= STATE_NBR then
        PUT( "*** RULE TABLE INCORRECT." );
        INT_IO.PUT( RULE_NBR );
        INT_IO.PUT( RTBL( RULE_NBR ).STATE_NBR );
        INT_IO.PUT( STATE_NBR );
        NEW_LINE;
        return;
      end if;

      loop
        SYL_LIST := TAIL( SYL_LIST );			-- CAN'T BE EMPTY
        exit when IS_EMPTY( SYL_LIST );
        SYL := HEAD( SYL_LIST);
        exit when SYL.TY = DN_TERMINAL;
        RULE := D( XD_RULE, SYL);
        exit when RULE.TY = DN_VOID;
        exit when not DB( XD_IS_NULLABLE, RULE );
      end loop;
      if IS_EMPTY( SYL_LIST ) then
        FOLLOW := RTBL( RULE_NBR ).FOLLOW;
        FOLLOW_SEQ := LIST( FOLLOW );
        FOLLOW_SAVE := FOLLOW_SEQ;
        FOLLOW_SEQ := TERM_LIST.UNION( FOLLOW_SEQ, LIST( D( XD_FOLLOW, ITEM ) ) );

        if not TERM_LIST.SAME( FOLLOW_SEQ, FOLLOW_SAVE ) then
	LIST( FOLLOW, FOLLOW_SEQ );
	RTBL( RULE_NBR ).REQ_CHECK := TRUE;
	MORE_CLOSURE_PASSES := TRUE;
	end if;
        end if;
      end TRANS_CLOSE_CLOSURE_ONE_ITEM;

    begin
      for STATE_NBR in STBL'range loop
        if STBL( STATE_NBR ).CHANGED then
	STBL( STATE_NBR ).CHANGED := FALSE;
	STATE := STBL( STATE_NBR ).STATE;
	ITEM_SEQ := LIST( STATE );
	if STBL( STATE_NBR ).CLOSURE then
	  PUT ( "CL ");
	  INT_IO.PUT( STATE_NBR, 1 );
	  NEW_LINE;
	  ITEM_SUBSEQ := ITEM_SEQ;
	  while not IS_EMPTY( ITEM_SUBSEQ) loop

MAKE_RTBL_ONE_ITEM:
	  declare
	    ITEM		: TREE	:= HEAD( ITEM_SUBSEQ );
	    RULE		: TREE;
	    RULE_NBR	: INTEGER;
	  begin
	    if DI( XD_SYL_NBR, ITEM ) = 0 then			-- CLOSURE ITEM
	      RULE := D( XD_RULE, D( XD_ALTERNATIVE, ITEM ) );
	      RULE_NBR := DI( XD_RULE_NBR, D( XD_RULEINFO, RULE ) );
	      declare
	        RTBL_I: RTBL_TYPE renames RTBL( RULE_NBR );
	      begin
	        if RTBL_I.STATE_NBR /= STATE_NBR then		-- HAVE NOT ALREADY SEEN A CLOSURE ITEM FOR THIS RULE
		RTBL_I.STATE_NBR := STATE_NBR;
		RTBL_I.REQ_CHECK := FALSE;
		RTBL_I.FOLLOW := D( XD_FOLLOW, ITEM);
	        end if;
	      end;
	    end if;
	  end MAKE_RTBL_ONE_ITEM;

	  ITEM_SUBSEQ := TAIL( ITEM_SUBSEQ );
	end loop;
				-- CHECK ALL ITEMS ONCE
	MORE_CLOSURE_PASSES := FALSE;
	ITEM_SUBSEQ := ITEM_SEQ;
	while not IS_EMPTY( ITEM_SUBSEQ ) loop
	  TRANS_CLOSE_CLOSURE_ONE_ITEM( STATE_NBR, HEAD( ITEM_SUBSEQ ) );
	  ITEM_SUBSEQ := TAIL( ITEM_SUBSEQ );
	end loop;
				-- NOW CHECK ITEMS THAT HAVE BEEN CHANGED
	while MORE_CLOSURE_PASSES loop
	  MORE_CLOSURE_PASSES := FALSE;
	  ITEM_SUBSEQ := ITEM_SEQ;
	  while not IS_EMPTY( ITEM_SUBSEQ) loop
	    ITEM := HEAD( ITEM_SUBSEQ);
	    if DI( XD_SYL_NBR, ITEM) /= 0 then
	      ITEM_SUBSEQ := TAIL( ITEM_SUBSEQ );
	    else
	      RULE := D( XD_RULE, D( XD_ALTERNATIVE, ITEM ) );
	      RULE_NBR := DI( XD_RULE_NBR, D( XD_RULEINFO, RULE ) );
	      if RTBL( RULE_NBR ).REQ_CHECK then
	        RTBL( RULE_NBR ).REQ_CHECK := FALSE;
	        loop
		TRANS_CLOSE_CLOSURE_ONE_ITEM( STATE_NBR, ITEM );
		ITEM_SUBSEQ := TAIL ( ITEM_SUBSEQ );
		exit when IS_EMPTY ( ITEM_SUBSEQ );
		ITEM := HEAD( ITEM_SUBSEQ );
		exit when D( XD_RULE, D( XD_ALTERNATIVE, ITEM ) ) /= RULE;
	        end loop;
	      else
	        loop
		ITEM_SUBSEQ := TAIL( ITEM_SUBSEQ );
		exit when IS_EMPTY( ITEM_SUBSEQ );
		ITEM := HEAD( ITEM_SUBSEQ );
		exit when D( XD_RULE, D( XD_ALTERNATIVE, ITEM)) /= RULE;
	        end loop;
	      end if;
	    end if;
	  end loop;
	end loop;
        end if;
        PUT( "GOTO " );
        INT_IO.PUT( STATE_NBR, 1 );
        NEW_LINE;
        ITEM_SUBSEQ := ITEM_SEQ;
        while not IS_EMPTY( ITEM_SUBSEQ ) loop

TRANS_CLOSE_GOTO_ONE_ITEM:
	declare
	  ITEM		: TREE		:= HEAD( ITEM_SUBSEQ );
	  ALT_NBR		: INTEGER;
	  SYL_NBR		: INTEGER;
	  GOTO_STATE	: TREE		:= D( XD_GOTO, ITEM );
	  GOTO_ITEMSEQ	: SEQ_TYPE;
	  GOTO_ITEM	: TREE;
	  FOLLOW		: TREE;
	  FOLLOW_SEQ	: SEQ_TYPE;
	  FOLLOW_SAVE	: SEQ_TYPE;
	begin
	  if GOTO_STATE.TY /= DN_VOID then
	    ALT_NBR := DI( XD_ALT_NBR, D( XD_ALTERNATIVE, ITEM ) );
	    SYL_NBR := DI( XD_SYL_NBR, ITEM ) + 1;
	    GOTO_ITEMSEQ := LIST( GOTO_STATE );
	    loop
	      GOTO_ITEM := HEAD( GOTO_ITEMSEQ );
	      exit when DI( XD_ALT_NBR, D( XD_ALTERNATIVE, GOTO_ITEM ) ) = ALT_NBR
		      and then DI( XD_SYL_NBR, GOTO_ITEM) = SYL_NBR;
	      GOTO_ITEMSEQ := TAIL( GOTO_ITEMSEQ );		-- NEVER EMPTY, BECAUSE DESIRED ITEM IS IN GO TO STATE
	    end loop;
	    FOLLOW := D( XD_FOLLOW, GOTO_ITEM );
	    FOLLOW_SAVE := LIST( FOLLOW );
	    FOLLOW_SEQ := TERM_LIST.UNION( FOLLOW_SAVE, LIST( D( XD_FOLLOW, ITEM ) ) );
	    if not TERM_LIST.SAME( FOLLOW_SEQ, FOLLOW_SAVE ) then
	      MORE_PASSES := TRUE;
	      STBL( DI( XD_STATE_NBR, GOTO_STATE ) ).CHANGED := TRUE;
	      LIST ( FOLLOW, FOLLOW_SEQ );
	    end if;
	  end if;
	end TRANS_CLOSE_GOTO_ONE_ITEM;

	ITEM_SUBSEQ := TAIL( ITEM_SUBSEQ );
        end loop;
      end if;
    end loop;
  end TRANS_CLOSE;

begin
  OPEN_IDL_TREE_FILE( NOM_TEXTE & ".lar" );
  GR_STATE_SEQ := LIST( D( XD_STATELIST, D( XD_USER_ROOT, TREE_ROOT ) ) );
  INITIALIZE;
  loop
    MORE_PASSES := FALSE;
    TRANS_CLOSE;
    exit when not MORE_PASSES;
  end loop;
  CLOSE_IDL_TREE_FILE;
--|-------------------------------------------------------------------------------------------------
end LALR_GRMR;
