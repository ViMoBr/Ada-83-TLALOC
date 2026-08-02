------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate( IDL )
--|--------------------------------------------------------------------------------------------------
--|		PRINT_STAT
--|--------------------------------------------------------------------------------------------------
procedure PRINT_STAT ( NOM_TEXTE :STRING ) is						--| IMPRESSION DES ÉTATS LALR POUR DÉBOGAGE
  USER_ROOT	: TREE;
  STATE_SEQ	: SEQ_TYPE;
  STATE		: TREE;
  ITEM_SEQ	: SEQ_TYPE;
  ITEM		: TREE;
  ALT		: TREE;
  SYL_SEQ		: SEQ_TYPE;
  SYL		: TREE;
  TEMP_SEQ	: SEQ_TYPE;
  GOTO_STATE	: TREE;
  FOLLOW		: TREE;
  OLD_FOLLOW	: TREE;
  OFILE		: TEXT_IO.FILE_TYPE;
begin
  OPEN_IDL_TREE_FILE( NOM_TEXTE & ".lar" );
  CREATE( OFILE, OUT_FILE, NOM_TEXTE & "_PARSE_TBL.txt" );
  SET_OUTPUT( OFILE );
  USER_ROOT := D( XD_USER_ROOT, TREE_ROOT );
  STATE_SEQ := LIST( D( XD_STATELIST, USER_ROOT ) );
  while not IS_EMPTY( STATE_SEQ ) loop
    POP( STATE_SEQ, STATE );
    NEW_LINE;
    PUT( "STATE NO." );
    INT_IO.PUT( DI( XD_STATE_NBR, STATE ) );
    PUT( " ::" );
    NEW_LINE;
    ITEM_SEQ := LIST( STATE );
    OLD_FOLLOW := TREE_VOID;
    while not IS_EMPTY( ITEM_SEQ ) loop
      POP( ITEM_SEQ, ITEM );
      ALT := D( XD_ALTERNATIVE, ITEM );
      INT_IO.PUT( DI( XD_ALT_NBR, ALT ) );
      PUT( ": " & PRINT_NAME( D( XD_NAME, D( XD_RULE, ALT ) ) ) & " ::=" );
      SYL_SEQ := LIST( ALT );
      for I in 1 .. DI( XD_SYL_NBR, ITEM ) loop
        if IS_EMPTY( SYL_SEQ ) then
	PUT( " ***TOO-FEW-SYLLABLES***" );
	exit;
        end if;
        POP( SYL_SEQ, SYL );
        PUT( ' ' & PRINT_NAME( D( XD_SYMREP, SYL ) ) );
      end loop;
      TEMP_SEQ := LIST( ITEM );
      if SYL_SEQ.FIRST /= TEMP_SEQ.FIRST then
        PUT( " ***BAD-TAIL-IN-ITEM***" );
      end if;
      PUT( " @" );
      while not IS_EMPTY( SYL_SEQ ) loop
        POP( SYL_SEQ, SYL );
        PUT( ' ' & PRINT_NAME( D( XD_SYMREP, SYL ) ) );
      end loop;
      GOTO_STATE := D( XD_GOTO, ITEM );
      if GOTO_STATE.TY /= DN_VOID then
        PUT ( " ===> ");
        INT_IO.PUT( DI( XD_STATE_NBR, GOTO_STATE ), 1 );
      else
        FOLLOW := D( XD_FOLLOW, ITEM );
        SYL_SEQ := LIST( FOLLOW );
        if not IS_EMPTY( SYL_SEQ ) then
	PUT( " --->");
	while not IS_EMPTY( SYL_SEQ ) loop
	  POP( SYL_SEQ, SYL );
	  PUT( ' ' & PRINT_NAME( D( XD_SYMREP, SYL ) ) );
	end loop;
        end if;
      end if;
      NEW_LINE;
    end loop;
  end loop;
  CLOSE( OFILE );
  SET_OUTPUT( STANDARD_OUTPUT );
  CLOSE_IDL_TREE_FILE;
--|--------------------------------------------------------------------------------------------------
end PRINT_STAT;
