------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( CLI )


				--------------
package body			COMMAND_DEFINE
is				--------------


		--------------------------------------------------------------------------------
		--	Local utilities
		--------------------------------------------------------------------------------

			----------------------
  procedure		RAISE_DEFINITION_ERROR	( MESSAGE :STRING )
  is			----------------------
  begin
    ERROR_LENGTH := MESSAGE'LENGTH;
    if  ERROR_LENGTH > MAX_MESSAGE_LENGTH  then
      ERROR_LENGTH := MAX_MESSAGE_LENGTH;
    end if;
    ERROR_TEXT( 1 .. ERROR_LENGTH ) := MESSAGE( MESSAGE'FIRST .. MESSAGE'FIRST + ERROR_LENGTH - 1 );
    raise  DEFINITION_ERROR;

  end	RAISE_DEFINITION_ERROR;
	----------------------


			-----
  function		STORE		( TEXT :STRING )		return SPAN
  is			-----
    -- Appends TEXT to DEFINITION_POOL. An empty TEXT gives the empty span.
    S	: SPAN;
  begin
    if  TEXT'LENGTH = 0  then
      return  S;
    end if;
    if  DEFINITION_TOP + TEXT'LENGTH > DEFINITION_POOL_SIZE  then
      RAISE_DEFINITION_ERROR( "Definition pool full" );
    end if;
    S.FIRST := DEFINITION_TOP + 1;
    S.LAST  := DEFINITION_TOP + TEXT'LENGTH;
    DEFINITION_POOL( S.FIRST .. S.LAST ) := TEXT;
    DEFINITION_TOP := S.LAST;
    return  S;

  end	STORE;
	-----


			-------------
  function		IS_IDENTIFIER	( NAME :STRING )		return BOOLEAN
  is			-------------
    -- NAME is expected in upper case.
  begin
    if  NAME'LENGTH = 0  or else  NAME( NAME'FIRST ) not in 'A' .. 'Z'  then
      return  FALSE;
    end if;
    for  I in NAME'RANGE  loop
      case  NAME(I)  is
      when 'A' .. 'Z' | '0' .. '9' | '_' =>
        null;
      when others =>
        return FALSE;
      end case;
    end loop;
    return  TRUE;

  end	IS_IDENTIFIER;
	-------------


			-------
  function		IN_LIST		( LIST, ITEM :STRING )		return BOOLEAN
  is			-------
    -- Exact match of ITEM among the comma separated items of LIST.
    FIRST	: POSITIVE	:= LIST'FIRST;
  begin
    for  I in LIST'FIRST .. LIST'LAST + 1  loop
      if  I > LIST'LAST  or else  LIST(I) = ','  then
        if  LIST( FIRST .. I - 1 ) = ITEM  then
	return TRUE;
        end if;
        FIRST := I + 1;
      end if;
    end loop;
    return  FALSE;

  end	IN_LIST;
	-------


			------
  function		BARRED		( LIST :STRING )		return STRING
  is			------
    -- "A,B,C" -> "A|B|C", for SHOW_SYNTAX.
    R	: STRING( LIST'RANGE )	:= LIST;
  begin
    for  I in R'RANGE  loop
      if  R( I ) = ','  then
	R( I ) := '|';
      end if;
    end loop;
    return  R;

  end	BARRED;
	------


			---------
  function		NEW_ENTRY	( A_KIND :ENTRY_KIND; NAME :STRING )	return POSITIVE
  is			---------
    -- Common checks, then appends an entry owned by DEFINING_VERB.
    U	:constant STRING	:= TO_UPPER( NAME );
    E	: ENTRY_RECORD;
  begin
    if  not DEFINING  then
      RAISE_DEFINITION_ERROR( "START must be called before adding " & NAME );
    end if;

    if  not IS_IDENTIFIER( U )  then
      RAISE_DEFINITION_ERROR( "Not an identifier : " & NAME );
    end if;

    if  A_KIND = VERB  then
      if  FIND_VERB( U ) /= 0  then
	RAISE_DEFINITION_ERROR( "Duplicate verb : " & U );
      end if;
    elsif  FIND_ENTRY( U, DEFINING_VERB ) /= 0  then
      RAISE_DEFINITION_ERROR( "Duplicate name : " & U );
    end if;

    if  ENTRY_COUNT = MAX_ENTRIES  then
      RAISE_DEFINITION_ERROR( "Entry table full at " & U );
    end if;

    E.KIND := A_KIND;
    E.NAME := STORE( U );
    E.VERB_INDEX := DEFINING_VERB;
    ENTRY_COUNT := ENTRY_COUNT + 1;
    ENTRIES( ENTRY_COUNT ) := E;
    return  ENTRY_COUNT;

  end	NEW_ENTRY;
	---------


			-----
  procedure		START		( TOOL_NAME :STRING; QUALIFIER_MARK :CHARACTER := '/' )
  is			-----
  begin
    -- A new START discards any previous definition and command.
    ENTRY_COUNT := 0;
    DEFINITION_TOP := 0;
    VALUE_TOP := 0;
    COMMAND_TOP := 0;
    DEFINING_VERB := 0;
    CURRENT_VERB := 0;
    ERROR_LENGTH := 0;
    DEFINED := FALSE;
    DEFINING := TRUE;

    if  TOOL_NAME'LENGTH = 0  then
      RAISE_DEFINITION_ERROR( "Empty tool name" );
    end if;

    if  QUALIFIER_MARK = ' '  or  QUALIFIER_MARK = '"'  or  QUALIFIER_MARK = '='  then
      RAISE_DEFINITION_ERROR( "Invalid qualifier mark" );
    end if;

    MARK := QUALIFIER_MARK;
    TOOL := STORE( TO_UPPER( TOOL_NAME ) );

  end	START;
	-----


			--------
  procedure		ADD_VERB		( NAME :STRING )
  is			--------
  begin
    DEFINING_VERB := NEW_ENTRY( VERB, NAME );

  end	ADD_VERB;
	--------


			-------------
  procedure		ADD_PARAMETER		( NAME :STRING;
						  REQUIRED :BOOLEAN := TRUE;
						  MULTIPLE :BOOLEAN := FALSE )
  is			-------------

    I	: POSITIVE;
  begin
    -- Ordering rules against the parameters already owned by this verb
    -- (or common to all verbs).
    for  J in 1 .. ENTRY_COUNT  loop
      if  ENTRIES(J).KIND = PARAMETER
	 and then  ( ENTRIES(J).VERB_INDEX = DEFINING_VERB
		    or  ENTRIES(J).VERB_INDEX = 0 )  then
	if  ENTRIES(J).MULTIPLE  then
	  RAISE_DEFINITION_ERROR( "Only the last parameter may be MULTIPLE, "
				  & "cannot add " & NAME );
	end if;

	if  REQUIRED  and not  ENTRIES(J).REQUIRED  then
	  RAISE_DEFINITION_ERROR( "Required parameter after an optional one : " & NAME );
	end if;
      end if;
    end loop;
    I := NEW_ENTRY( PARAMETER, NAME );
    ENTRIES(I).REQUIRED := REQUIRED;
    ENTRIES(I).MULTIPLE := MULTIPLE;

  end	ADD_PARAMETER;
	-------------


			-------------
  procedure		ADD_QUALIFIER		( NAME :STRING; NEGATABLE :BOOLEAN := FALSE )
  is			-------------

    I	: POSITIVE;

  begin
    I := NEW_ENTRY( FLAG_QUALIFIER, NAME );
    ENTRIES( I ).NEGATABLE := NEGATABLE;

  end	ADD_QUALIFIER;
	-------------


			-------------
  procedure		ADD_QUALIFIER		( NAME :STRING; VALUES_LIST :STRING;
						  IMPLICIT_FIRST_VALUE, NEGATABLE :BOOLEAN := FALSE;
						  DEFAULT :STRING := "" )
  is			-------------

    U_LIST	:constant STRING	:= TO_UPPER( VALUES_LIST );
    U_DEFAULT	:constant STRING	:= TO_UPPER( DEFAULT );
    I		: POSITIVE;

  begin
    if  U_LIST'LENGTH = 0  then
      RAISE_DEFINITION_ERROR( "Empty values list for " & NAME );
    end if;

    if  U_DEFAULT'LENGTH /= 0  and then  not IN_LIST( U_LIST, U_DEFAULT )  then
      RAISE_DEFINITION_ERROR( "DEFAULT " & U_DEFAULT & " is not in the values list of " & NAME );
    end if;

    I := NEW_ENTRY( LIST_QUALIFIER, NAME );
    ENTRIES( I ).NEGATABLE := NEGATABLE;
    ENTRIES( I ).IMPLICIT_FIRST := IMPLICIT_FIRST_VALUE;
    ENTRIES( I ).VALUES_LIST := STORE( U_LIST );
    ENTRIES( I ).DEFAULT := STORE( U_DEFAULT );

  end	ADD_QUALIFIER;
	-------------


			------------------------
  procedure		ADD_FREE_VALUE_QUALIFIER	( NAME :STRING;
						  NEGATABLE :BOOLEAN := FALSE;
						  DEFAULT :STRING := "" )
  is			------------------------

    I	: POSITIVE;

  begin
    I := NEW_ENTRY( FREE_QUALIFIER, NAME );
    ENTRIES( I ).NEGATABLE := NEGATABLE;
    ENTRIES( I ).DEFAULT := STORE( DEFAULT );								-- user text, case kept

  end	ADD_FREE_VALUE_QUALIFIER;
	------------------------


			----
  procedure		STOP
  is			----
  begin
    if  not DEFINING  then
      RAISE_DEFINITION_ERROR( "STOP without START" );
    end if;
    DEFINING := FALSE;
    DEFINED := TRUE;

  end	STOP;
	----


			-----------
  procedure		SHOW_SYNTAX		( VERB :STRING := "" )
  is			-----------
    -- Note : inside this procedure the formal VERB hides the literal
    -- ENTRY_KIND'(VERB), hence the use of FIND_VERB and IS_A_VERB below.
    V	: NATURAL;

		---------
    function	IS_A_VERB		( I :POSITIVE )		return BOOLEAN
    is		---------
    begin
      return  ENTRIES( I ).VERB_INDEX = 0
	     and then  ENTRIES(I).KIND not in PARAMETER .. FREE_QUALIFIER;
    end	IS_A_VERB;
	---------

		---------
    procedure	SHOW_VERB		( V :POSITIVE )
    is		---------
      -- Owned by V, or common to all verbs.
      function OWNED( I :POSITIVE ) return BOOLEAN is
      begin
	return ENTRIES(I).VERB_INDEX = V or ENTRIES(I).VERB_INDEX = 0;
      end OWNED;

    begin
      TEXT_IO.PUT( DEFINITION_TEXT( TOOL ) & " " & DEFINITION_TEXT( ENTRIES(V).NAME ) );
      for  I in 1 .. ENTRY_COUNT  loop
	if  ENTRIES( I ).KIND = PARAMETER  and then  OWNED( I )  then
	  TEXT_IO.PUT( " " );
	  if  not ENTRIES(I).REQUIRED  then
	    TEXT_IO.PUT( "[" );
	  end if;
	  TEXT_IO.PUT( DEFINITION_TEXT( ENTRIES(I).NAME ) );
	  if  ENTRIES( I ).MULTIPLE  then
	    TEXT_IO.PUT( "..." );
	  end if;
	  if  not ENTRIES(I).REQUIRED  then
	    TEXT_IO.PUT( "]" );
	  end if;
	end if;
      end loop;
      TEXT_IO.NEW_LINE;
      for  I in 1 .. ENTRY_COUNT  loop
	if  ENTRIES( I ).KIND in FLAG_QUALIFIER .. FREE_QUALIFIER  and then  OWNED( I )  then
	  TEXT_IO.PUT( "    " & MARK );
	  if  ENTRIES( I ).NEGATABLE  then
	    TEXT_IO.PUT( "[NO]" );
	  end if;
	  TEXT_IO.PUT( DEFINITION_TEXT( ENTRIES(I).NAME ) );

	  case  ENTRIES( I ).KIND  is
	  when  LIST_QUALIFIER =>
	    if  ENTRIES( I ).IMPLICIT_FIRST  then
		TEXT_IO.PUT( "[" );
	    end if;
	    TEXT_IO.PUT( "=" & BARRED( DEFINITION_TEXT( ENTRIES(I).VALUES_LIST ) ) );
	    if  ENTRIES( I ).IMPLICIT_FIRST  then
	      TEXT_IO.PUT( "]" );
	    end if;
	  when FREE_QUALIFIER =>
	    TEXT_IO.PUT( "=value" );
	  when others =>
	    null;
	  end case;

	  if  ENTRIES( I ).DEFAULT.LAST >= ENTRIES( I ).DEFAULT.FIRST  then
	    TEXT_IO.PUT( "   (default " & DEFINITION_TEXT( ENTRIES(I).DEFAULT ) & ")" );
	  end if;
	  TEXT_IO.NEW_LINE;
	end if;
      end loop;

    end	SHOW_VERB;
	---------

  begin
    if  VERB'LENGTH = 0  then
      for  I in 1 .. ENTRY_COUNT  loop
        if  IS_A_VERB( I )  then
	SHOW_VERB( I );
        end if;
      end loop;
    else
      V := FIND_VERB( VERB );
      if  V = 0  then
        raise  COMMAND_ACCESS.NO_SUCH_NAME;
      end if;
      SHOW_VERB( V );
    end if;

  end	SHOW_SYNTAX;
	-----------


	--------------
end	COMMAND_DEFINE;
	--------------


--	1	2	3	4	5	6	7	8	9	0	1	2
------------------------------------------------------------------------------------------------------------------------
