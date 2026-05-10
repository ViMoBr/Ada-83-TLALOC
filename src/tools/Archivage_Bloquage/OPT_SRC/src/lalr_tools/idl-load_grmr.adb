------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT	MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with GRMR_TBL, GRMR_OPS;
use  GRMR_TBL, GRMR_OPS;
separate(	IDL )
--|--------------------------------------------------------------------------------------------------
--|		LOAD_GRMR
--|--------------------------------------------------------------------------------------------------
procedure	LOAD_GRMR	( NOM_TEXTE :STRING	) is

  procedure READ_PARSE_TABLES	is
    PTFILE		: FILE_TYPE;
    PTCHAR		: CHARACTER;
    PTINDEX		: INTEGER;
    LAST			: NATURAL;
    NTER_TEXT		: STRING(	1 .. 256 );
    NTER_TXTREP		: TREE;
    STRING_SEEN		: BOOLEAN;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE	STORE_ACTION
    procedure STORE_ACTION is
      ACTION		: INTEGER;
      ACTION_OP		: GRMR_OP;
      TXT			: STRING(	1 .. 10 );
      LAST		: INTEGER;
      SYM			: TREE;
    begin
      STRING_SEEN := FALSE;
      GRMR.AC_TBL_LAST := PTINDEX;
      INT_IO.GET ( PTFILE, ACTION );
      if ACTION < 0	then
        GRMR.AC_TBL( PTINDEX ) := AC_SHORT( ACTION );
      else
        ACTION_OP := GRMR_OP'VAL( ACTION / 1000 );
        if ACTION_OP not in GRMR_OP_QUOTE then
	GRMR.AC_TBL(PTINDEX) := AC_SHORT( ACTION );
        else
	GET_LINE(	PTFILE, TXT, LAST );
	SYM := STORE_SYM( TXT( 1 .. LAST ) );
	GRMR.AC_TBL( PTINDEX ) := AC_SHORT( ACTION + INTEGER( SYM.PG ) );
	GRMR.AC_TBL_LAST :=	GRMR.AC_TBL_LAST + 1;
	GRMR.AC_TBL( GRMR.AC_TBL_LAST	) := AC_SHORT( SYM.LN );
	STRING_SEEN := TRUE;
        end if;
      end	if;
    end STORE_ACTION;

  begin
    OPEN(	PTFILE, IN_FILE, "parse.tbl" );
    while	not END_OF_FILE( PTFILE ) loop
      GET( PTFILE, PTCHAR );
      INT_IO.GET( PTFILE, PTINDEX );

      if PTCHAR = 'S' then
        PUT( PTCHAR	);
        INT_IO.PUT(	PTINDEX );
        GRMR.ST_TBL_LAST := PTINDEX;
        INT_IO.GET(	PTFILE, GRMR.ST_TBL( PTINDEX ) );
        INT_IO.PUT(	GRMR.ST_TBL( PTINDEX ) );
        NEW_LINE;

      elsif PTCHAR = 'T' then
        GRMR.AC_SYM_LAST := PTINDEX;
        STORE_ACTION;
        declare
	I	: INTEGER;
        begin
	INT_IO.GET ( PTFILE, I );
	GRMR.AC_SYM( PTINDEX ) := AC_BYTE( I );
        end;
        SKIP_LINE( PTFILE );
      elsif PTCHAR = 'A' then
        STORE_ACTION;
        if not STRING_SEEN then
	SKIP_LINE( PTFILE );
        end if;
      elsif PTCHAR = 'N' then
        PUT( PTCHAR	);
        INT_IO.PUT(	PTINDEX );
        GRMR.NTER_LAST := PTINDEX;
        GET( PTFILE, PTCHAR );				--| SAUTER L'ESPACE
        GET_LINE( PTFILE, NTER_TEXT, LAST );
        PUT_LINE( '	' & NTER_TEXT( 1 ..	LAST ) );
        NTER_TXTREP	:= STORE_TEXT ( NTER_TEXT( 1 .. LAST ) );
        GRMR.NTER_PG( PTINDEX	) := AC_BYTE( NTER_TXTREP.PG );
        GRMR.NTER_LN( PTINDEX	) := AC_BYTE( NTER_TXTREP.LN );
      else
        PUT( PTCHAR	);
        INT_IO.PUT(	PTINDEX );
        PUT_LINE( "*****TABLE ERROR" );
        raise PROGRAM_ERROR;
      end	if;
    end loop;
    CLOSE( PTFILE );
    PUT_LINE( "PARSE TABLES READ." );
  end READ_PARSE_TABLES;

  procedure WRITE_BINARY is
    use GRMR_TBL_IO;
    BIN_FILE	: GRMR_TBL_IO.FILE_TYPE;
  begin
    CREATE( BIN_FILE, OUT_FILE, "parse.bin" );
    WRITE( BIN_FILE, GRMR_TBL.GRMR );
    CLOSE( BIN_FILE	);
  end WRITE_BINARY;


begin
  CREATE_IDL_TREE_FILE( NOM_TEXTE & ".lar" );
  declare
    DUMMY		: TREE	:= STORE_SYM( "_ADDRESS");
    USER_ROOT	: TREE	:= MAKE( DN_USER_ROOT );
  begin
    D( XD_USER_ROOT, TREE_ROOT, USER_ROOT );
    READ_PARSE_TABLES;
    CLOSE_IDL_TREE_FILE;
    WRITE_BINARY;
  end;
--|--------------------------------------------------------------------------------------------------
end LOAD_GRMR;
