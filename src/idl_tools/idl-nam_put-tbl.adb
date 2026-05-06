------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with TEXT_IO; use  TEXT_IO;
separate ( IDL.NAM_PUT )
--|--------------------------------------------------------------------------------------------------
--|	TBL
--|--------------------------------------------------------------------------------------------------
package body TBL is

  TBL_ERROR	: exception;

  --|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION UPPER_CASE
  --|
  function UPPER_CASE ( A :STRING ) return STRING	is
    S	: STRING(	1 .. A'LENGTH )	:= A;
    DECAL	: constant := CHARACTER'POS( 'A' ) - CHARACTER'POS( 'a' );
  begin
    for I	in 1 .. S'LENGTH loop
      if S( I ) in 'a' .. 'z'	then
        S( I ) := CHARACTER'VAL( CHARACTER'POS( S( I ) ) + DECAL );
      end	if;
    end loop;
    return S;
  end UPPER_CASE;
  --|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION LOWER_CASE
  --|
  function LOWER_CASE ( A :STRING ) return STRING	is
    S	: STRING(	1 .. A'LENGTH )	:= A;
    DECAL	: constant := CHARACTER'POS( 'a' ) - CHARACTER'POS( 'A' );
  begin
    for I	in 1 .. S'LENGTH loop
      if S( I ) in 'A' .. 'Z'	then
        S( I ) := CHARACTER'VAL( CHARACTER'POS( S( I ) ) + DECAL );
      end	if;
    end loop;
    return S;
  end LOWER_CASE;
  --|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		PROCEDURE	READ_TABLES
  --|
  procedure READ_TABLES ( NOM_TABLE :STRING ) is
    TABLE_FILE		: TEXT_IO.FILE_TYPE;
    BUFFER		: STRING(	1 .. 120 );
    B_CHAR		: CHARACTER;
    B_NUM			: INTEGER;
    LAST			: NATURAL;
    FIRST_COL, LAST_COL	: NATURAL;

    LAST_FIELD		: FIELD_IDX	:= 0;

    ATTR_SEEN_FOR_THIS_NODE	: BOOLEAN	:= FALSE;

    package MY_INTEGER_IO is new INTEGER_IO( INTEGER );
    use MY_INTEGER_IO;
    --|----------------------------------------------------------------------------------------------
    --|		PROCEDURE	NIBBLE_NAME
    --|
    procedure NIBBLE_NAME is
    begin
      FIRST_COL := LAST_COL +	1;
      while FIRST_COL <= LAST	and then (BUFFER( FIRST_COL )	= ' ' or else BUFFER( FIRST_COL ) = ASCII.HT) loop
        FIRST_COL := FIRST_COL + 1;
      end	loop;
      LAST_COL := FIRST_COL;
      while LAST_COL <= LAST and then BUFFER( LAST_COL ) /=	' ' and then BUFFER( LAST_COL	) /= ASCII.HT loop
        LAST_COL :=	LAST_COL + 1;
      end	loop;
      LAST_COL := LAST_COL - 1;
    end NIBBLE_NAME;

  begin
    ATTR_IDX_OF_NODE( 0 ) := 0;
    START_NODE( 0 )	:= 0;
    END_NODE( 0 ) := 0;

    TEXT_IO.OPEN( TABLE_FILE,	TEXT_IO.IN_FILE, NOM_TEXTE & ".tbl" );

    loop
      exit when END_OF_FILE (	TABLE_FILE );
      GET( TABLE_FILE, B_CHAR	);

      if B_CHAR = 'C' then
        GET_LINE( TABLE_FILE,	BUFFER, LAST );
        LAST_COL :=	0;
        NIBBLE_NAME;
        CLASS_IMAGE( LAST_CLASS ) := new STRING'(	BUFFER( FIRST_COL..LAST_COL )	);
        START_NODE(	LAST_CLASS ) := LAST_NODE;
        LAST_CLASS := LAST_CLASS + 1;

      elsif B_CHAR = 'E' then
        GET_LINE ( TABLE_FILE, BUFFER, LAST );
        LAST_COL :=	0;
        NIBBLE_NAME;

        for C in reverse 0 ..	LAST_CLASS-1 loop
	if CLASS_IMAGE( C ).all = BUFFER( FIRST_COL..LAST_COL ) then
	  END_NODE( C ) := LAST_NODE -1;
	end if;
        end loop;

      elsif B_CHAR = 'N' then
        GET     ( TABLE_FILE,	B_NUM );
        GET_LINE( TABLE_FILE,	BUFFER, LAST );
        LAST_COL :=	0;
        if LAST_NODE /= NODE_IDX( B_NUM	) then
	SET_OUTPUT( STANDARD_OUTPUT );
	PUT_LINE(	"**** NODES OUT OF SYNC LAST NODE = "
		 & INTEGER'IMAGE ( INTEGER( TBL.LAST_NODE ) )
		 & "  B_NUM = "
		 & NATURAL'IMAGE ( INTEGER( B_NUM ) )
		 );
	raise TBL_ERROR;
        end if;
        NIBBLE_NAME;
        NODE_IMAGE(	LAST_NODE	) := new STRING'( BUFFER( FIRST_COL..LAST_COL ) );
        LAST_NODE := LAST_NODE + 1;
        ATTR_SEEN_FOR_THIS_NODE := FALSE;
        START_FIELD( LAST_NODE ) := 1;
        END_FIELD( LAST_NODE ) := 0;

      elsif B_CHAR = 'A' or B_CHAR = 'B' or B_CHAR = 'I' then
        GET     ( TABLE_FILE,	B_NUM );
        GET_LINE( TABLE_FILE,	BUFFER, LAST );
        LAST_COL :=	0;
        if B_NUM < 0 then
	B_NUM := - B_NUM;								--| NUMERO NEGATIF
	ATTR_KIND( ATTR_IDX( B_NUM ) ) := 'S';						--| SEQUENCE/LISTE
        else
	ATTR_KIND( ATTR_IDX( B_NUM ) ) := B_CHAR;
        end if;
        NIBBLE_NAME;
        ATTR_IMAGE(	ATTR_IDX(	B_NUM ) )	:= new STRING'( BUFFER( FIRST_COL..LAST_COL ) );
        if LAST_ATTR < ATTR_IDX( B_NUM ) then
	LAST_ATTR	:= ATTR_IDX( B_NUM );
        end if;

        if not ATTR_SEEN_FOR_THIS_NODE then
	ATTR_SEEN_FOR_THIS_NODE := TRUE;
	START_FIELD( LAST_NODE ) := LAST_FIELD;
        end if;
        ATTR_IDX_OF_NODE( LAST_FIELD ) := ATTR_IDX( B_NUM );
        END_FIELD( LAST_NODE ) := LAST_FIELD;
        LAST_FIELD := LAST_FIELD + 1;
      end	if;
    end loop;

    LAST_NODE  := LAST_NODE -	1;
    LAST_CLASS := LAST_CLASS - 1;

    TEXT_IO.CLOSE( TABLE_FILE	);

  exception
    when END_ERROR =>
      TEXT_IO.CLOSE( TABLE_FILE );
  end READ_TABLES;

--|-------------------------------------------------------------------------------------------------
end TBL;
