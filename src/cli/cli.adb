------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with TEXT_IO;
					---
package body				CLI
					---
is

		--------------------------------------------------------------------------------
		--	Shared state, visible to both subunits
		--------------------------------------------------------------------------------

  MAX_ENTRIES		:constant := 128;								-- verbs + parameters + qualifiers
  MAX_VALUES		:constant := 128;								-- values found in one command
  DEFINITION_POOL_SIZE	:constant := 4096;								-- names, lists, defaults
  COMMAND_POOL_SIZE		:constant := 4096;								-- text of one command
  MAX_MESSAGE_LENGTH	:constant := 256;

  type  SPAN		is record
			  FIRST		:POSITIVE := 1;
			  LAST		:NATURAL  := 0;						-- (1,0) is the empty span
  end record;

  type  ENTRY_KIND		is ( VERB, PARAMETER, FLAG_QUALIFIER,
			     LIST_QUALIFIER, FREE_QUALIFIER );

  type  ENTRY_RECORD	is record
			  KIND		:ENTRY_KIND;
			  NAME		:SPAN;							-- in DEFINITION_POOL, upper case
			  VERB_INDEX	:NATURAL	:= 0;						-- owner verb, 0 = common to all
			  REQUIRED	:BOOLEAN	:= FALSE;						-- PARAMETER
			  MULTIPLE	:BOOLEAN 	:= FALSE;						-- PARAMETER
			  NEGATABLE	:BOOLEAN	:= FALSE;						-- qualifiers
			  IMPLICIT_FIRST	:BOOLEAN	:= FALSE;						-- LIST_QUALIFIER
			  VALUES_LIST	:SPAN;							-- LIST_QUALIFIER, "A,B,C"
			   DEFAULT	:SPAN;							-- LIST/FREE_QUALIFIER
    -- Filled by PARSE_COMMAND :
			  STATUS		:COMMAND_ACCESS.QUALIFIER_STATUS := COMMAND_ACCESS.ABSENT;
			  VALUES_FOUND	:NATURAL	:= 0;						-- number of VALUES owned
			end record;

  ENTRIES			: array( 1..MAX_ENTRIES ) of ENTRY_RECORD;
  ENTRY_COUNT		: NATURAL		:= 0;

  type  VALUE_RECORD	is record
			  TEXT		:SPAN;							-- in COMMAND_POOL
			  OWNER		:NATURAL	:= 0;						-- index in ENTRIES
			end record;
  VALUES			:array( 1..MAX_VALUES ) of VALUE_RECORD;
  VALUE_TOP		:NATURAL := 0;

  DEFINITION_POOL		: STRING( 1..DEFINITION_POOL_SIZE );
  COMMAND_POOL		: STRING( 1..COMMAND_POOL_SIZE );
  DEFINITION_TOP		: NATURAL		:= 0;
  COMMAND_TOP		: NATURAL		:= 0;

  TOOL			: SPAN;									-- in DEFINITION_POOL
  MARK			: CHARACTER	:= '/';
  DEFINING		: BOOLEAN		:= FALSE;							-- between START and STOP
  DEFINED			: BOOLEAN		:= FALSE;							-- STOP has been called
  DEFINING_VERB		: NATURAL		:= 0;							-- last ADD_VERB while defining
  CURRENT_VERB		: NATURAL		:= 0;							-- verb of the parsed command

  ERROR_TEXT		: STRING( 1..MAX_MESSAGE_LENGTH );
  ERROR_LENGTH		: NATURAL		:= 0;


		--------------------------------------------------------------------------------
		--	Shared utilities
		--------------------------------------------------------------------------------

			--------
  function		TO_UPPER		( S :STRING )		return STRING
  is			--------
    R	: STRING( S'RANGE )	:= S;
  begin
    for  I in R'RANGE  loop
      if  R( I ) in 'a'..'z'  then
        R( I ) := CHARACTER'VAL( CHARACTER'POS( R( I ) ) - 32 );
      end if;
    end loop;
    return  R;

  end	TO_UPPER;
	--------


			---------------
  function		DEFINITION_TEXT	( S :SPAN )			return STRING
  is			---------------
    R	:constant STRING( 1 .. S.LAST - S.FIRST + 1 ) := DEFINITION_POOL( S.FIRST .. S.LAST );
  begin
    return R;

  end	DEFINITION_TEXT;
	---------------


			------------
  function		COMMAND_TEXT	( S :SPAN )			return STRING
  is			------------
    R	:constant STRING( 1 .. S.LAST - S.FIRST + 1 ) := COMMAND_POOL( S.FIRST .. S.LAST );
  begin
    return R;

  end	COMMAND_TEXT;
	------------


			----------
  function		FIND_ENTRY	( NAME :STRING; VERB_INDEX :NATURAL )	return NATURAL
  is			----------
    -- Exact match of an upper case NAME among the entries of VERB and the
    -- common ones ; 0 if none. Prefix matching for the user's text is done
    -- by the parser, not here.
    U	:constant STRING	:= TO_UPPER( NAME );

  begin
    for  I in 1 .. ENTRY_COUNT  loop
      if  ( ENTRIES( I ).KIND /= VERB )
	 and then ( ENTRIES( I ).VERB_INDEX = VERB_INDEX or ENTRIES( I ).VERB_INDEX = 0 )
	 and then DEFINITION_TEXT( ENTRIES( I ).NAME ) = U then
	return  I;
      end if;
    end loop;
    return  0;

  end	FIND_ENTRY;
	----------


			---------
  function		FIND_VERB	( NAME :STRING )		return NATURAL
  is			---------
    -- Exact match of NAME (any case) among the verbs ; 0 if none.
    U	:constant STRING := TO_UPPER( NAME );

  begin
    for  I in 1 .. ENTRY_COUNT  loop
      if  ENTRIES(I).KIND = VERB  and then  DEFINITION_TEXT( ENTRIES(I).NAME ) = U  then
        return  I;
      end if;
    end loop;
    return  0;

  end	FIND_VERB;
	---------


			-------------------
  procedure		RAISE_COMMAND_ERROR	( MESSAGE :STRING )
  is			-------------------
  begin
    ERROR_LENGTH := MESSAGE'LENGTH;
    if  ERROR_LENGTH > MAX_MESSAGE_LENGTH  then
      ERROR_LENGTH := MAX_MESSAGE_LENGTH;
    end if;
    ERROR_TEXT( 1 .. ERROR_LENGTH ) := MESSAGE( MESSAGE'FIRST .. MESSAGE'FIRST + ERROR_LENGTH - 1 );
    raise  COMMAND_ERROR;

  end	RAISE_COMMAND_ERROR;
	-------------------


  package body	COMMAND_DEFINE	is separate;


			-------------
  procedure		PARSE_COMMAND
  is			-------------

		-- Reads one line : TOOL_NAME VERB ... ; the tool name is checked, the
		-- rest goes to PARSE_COMMAND_FROM_VERB. TEXT_IO.END_ERROR propagates.
    LINE		: STRING( 1 .. COMMAND_POOL_SIZE );
    LAST		: NATURAL;
    FIRST		: INTEGER;
    STOP		: INTEGER;

  begin
    TEXT_IO.GET_LINE( LINE, LAST );

    FIRST := 1;
    while  FIRST <= LAST  and then  ( LINE( FIRST ) = ' ' or LINE( FIRST ) = ASCII.HT )  loop
      FIRST := FIRST + 1;
    end loop;

    if  FIRST > LAST  then
      RAISE_COMMAND_ERROR( "Empty command" );
    end if;

    STOP := FIRST;
    while  STOP <= LAST  and then  LINE( STOP ) /= ' '  and then  LINE( STOP ) /= ASCII.HT  loop
      STOP := STOP + 1;
    end loop;

    if  TO_UPPER( LINE( FIRST .. STOP - 1 ) ) /= DEFINITION_TEXT( TOOL )  then
      RAISE_COMMAND_ERROR( "Command must start with " & DEFINITION_TEXT( TOOL )
			   & ", not with " & LINE( FIRST .. STOP - 1 ) );
    end if;

    PARSE_COMMAND_FROM_VERB( LINE( STOP .. LAST ) );

  end	PARSE_COMMAND;
	-------------


			-----------------------
  procedure		PARSE_COMMAND_FROM_VERB	( LINE :STRING )
  is			-----------------------

    MAX_TOKEN_LENGTH	:constant := 1024;

    TOKEN			: STRING( 1 .. MAX_TOKEN_LENGTH );
    TOKEN_LENGTH		: NATURAL		:= 0;
    HEAD_QUOTED		: BOOLEAN		:= FALSE;							-- first char of TOKEN was inside quotes
    POSITION		: INTEGER		:= LINE'FIRST;						-- scanning LINE
    NAME_LAST		: NATURAL		:= 0;							-- qualifier shaped token : TOKEN(2..NAME_LAST)
    HAS_VALUE		: BOOLEAN		:= FALSE;							-- ... is the name, value after '='
    CURRENT_PARAMETER	: NATURAL		:= 0;							-- entry receiving parameter values

    FOUND			: BOOLEAN;

		--------------------------------------------------------------------------------
		--	Tokenizer
		--------------------------------------------------------------------------------

		--------
    function	IS_BLANK	( C :CHARACTER ) return BOOLEAN
    is		--------
    begin
      return C = ' ' or C = ASCII.HT;
    end	IS_BLANK;
	--------

		------
    procedure	APPEND	( C :CHARACTER )
    is		------
    begin
      if  TOKEN_LENGTH = MAX_TOKEN_LENGTH  then
	RAISE_COMMAND_ERROR( "Token too long" );
      end if;

      TOKEN_LENGTH := TOKEN_LENGTH + 1;
      TOKEN( TOKEN_LENGTH ) := C;
    end	APPEND;
	------

		----------
    procedure	NEXT_TOKEN	( FOUND :out BOOLEAN )
    is		----------

      -- Blank separated ; "..." groups, a doubled quote inside stands
      -- for one quote ; quotes are removed from TOKEN.
      IN_QUOTES	: BOOLEAN		:= FALSE;
      C		: CHARACTER;

    begin
      TOKEN_LENGTH := 0;
      HEAD_QUOTED  := FALSE;
      while  POSITION <= LINE'LAST  and then  IS_BLANK( LINE( POSITION ) )  loop
	POSITION := POSITION + 1;
      end loop;
      FOUND := POSITION <= LINE'LAST;
      while  POSITION <= LINE'LAST  loop
	C := LINE( POSITION );
	if  C = '"'  then
	  if  IN_QUOTES and then POSITION < LINE'LAST
	     and then  LINE( POSITION + 1 ) = '"'  then
	    APPEND( '"' );
	    POSITION := POSITION + 1;

	  else
	    if  not IN_QUOTES  and  TOKEN_LENGTH = 0  then
	      HEAD_QUOTED := TRUE;
	    end if;
	    IN_QUOTES := not IN_QUOTES;
	  end if;
	elsif  not IN_QUOTES  and then  IS_BLANK( C )  then
	  exit;
	else
	  APPEND( C );
	end if;
	POSITION := POSITION + 1;
      end loop;

      if  IN_QUOTES  then
	RAISE_COMMAND_ERROR( "Unbalanced quotes" );
      end if;

    end	NEXT_TOKEN;
	----------

		----------------
    function	QUALIFIER_SHAPED		return BOOLEAN
    is		----------------
      -- MARK, an identifier, then end or '='. Sets NAME_LAST, HAS_VALUE.
    begin
      HAS_VALUE := FALSE;

      if  (HEAD_QUOTED or TOKEN_LENGTH < 2)  or else  TOKEN( 1 ) /= MARK  then
        return  FALSE;
      end if;

      if  TOKEN( 2 ) not in 'A' .. 'Z'  and  TOKEN( 2 ) not in 'a' .. 'z'  then
        return  FALSE;
      end if;

      NAME_LAST := 1;
      for  I in 2 .. TOKEN_LENGTH  loop
	case  TOKEN( I )  is
	when 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '_' =>
	  NAME_LAST := I;
	when '=' =>
	  HAS_VALUE := TRUE;
	  return  TRUE;
	when others =>
	  return  FALSE;
	end case;
      end loop;
      return  TRUE;

    end	QUALIFIER_SHAPED;
	----------------

		--------------------------------------------------------------------------------
		--	Matching by unambiguous prefix (exact match wins)
		--------------------------------------------------------------------------------

		-----
    function	MATCH	( U :STRING; WANT_VERB, NEGATABLE_ONLY :BOOLEAN )		return NATURAL
    is		-----

      -- U is upper case and not empty. Verbs, or qualifiers of the
      -- current verb ; 0 if none ; COMMAND_ERROR if ambiguous.
      FOUND	:NATURAL	:= 0;
      COUNT	:NATURAL	:= 0;

		---------
      function	CANDIDATE	( I :POSITIVE )	return BOOLEAN
      is		---------
      begin
        if  WANT_VERB  then
	return  ENTRIES( I ).KIND = VERB;
        else
	return  ENTRIES( I ).KIND in FLAG_QUALIFIER .. FREE_QUALIFIER
		 and then ( ENTRIES( I ).VERB_INDEX = CURRENT_VERB
			    or ENTRIES( I ).VERB_INDEX = 0 )
		 and then ( not NEGATABLE_ONLY or ENTRIES(I).NEGATABLE );
        end if;

      end	CANDIDATE;
	---------

    begin
      for  I in 1 .. ENTRY_COUNT  loop
	if  CANDIDATE( I )  then
	  declare
	    N	:constant STRING	:= DEFINITION_TEXT( ENTRIES(I).NAME );
	  begin
	    if  N = U  then
	      return  I;
	    end if;
	    if  N'LENGTH > U'LENGTH
	       and then  N( N'FIRST .. N'FIRST + U'LENGTH - 1 ) = U  then
	      COUNT := COUNT + 1;
	      FOUND := I;
	    end if;
	  end;
	end if;
      end loop;
      if  COUNT > 1  then
	RAISE_COMMAND_ERROR( "Ambiguous abbreviation : " & U );
      end if;
      return  FOUND;

    end	MATCH;
	-----

		----------
    function	FIRST_ITEM	( LIST :STRING )	return STRING
    is		----------
    begin
      for  I in LIST'RANGE  loop
	if  LIST(I) = ','  then
	  return  LIST( LIST'FIRST .. I - 1 );
	end if;
      end loop;
      return  LIST;

    end 	FIRST_ITEM;
	----------

		----------
    function	MATCH_ITEM	( LIST, TEXT :STRING )	return STRING
    is		----------

      -- Canonical item of the comma separated LIST designated by TEXT.
      U		:constant STRING	:= TO_UPPER( TEXT );
      FIRST	:INTEGER		:= LIST'FIRST;
      COUNT	:NATURAL		:= 0;
      F_FIRST	:INTEGER		:= 1;
      F_LAST	:INTEGER		:= 0;

    begin
      for  I in LIST'FIRST .. LIST'LAST + 1  loop
	if  I > LIST'LAST  or else  LIST(I) = ','  then
	  if  LIST( FIRST .. I - 1 ) = U  then
	    return  LIST( FIRST .. I - 1 );
	  end if;

	  if  I - FIRST > U'LENGTH
	     and then  LIST( FIRST .. FIRST + U'LENGTH - 1 ) = U  then
	    COUNT := COUNT + 1;
	    F_FIRST := FIRST;
	    F_LAST := I - 1;
	  end if;
	  FIRST := I + 1;
	end if;

      end loop;

      if  COUNT = 0  then
        RAISE_COMMAND_ERROR( "Invalid value " & TEXT & ", expected one of " & LIST );
      elsif  COUNT > 1  then
        RAISE_COMMAND_ERROR( "Ambiguous value " & TEXT & " among " & LIST );
      end if;
      return  LIST( F_FIRST .. F_LAST );

    end	MATCH_ITEM;
	----------

		--------------------------------------------------------------------------------
		--	Storing results
		--------------------------------------------------------------------------------

		---------
    procedure	ADD_VALUE		( I :POSITIVE; TEXT :STRING )
    is		---------

      S	:SPAN;

    begin
      if  VALUE_TOP = MAX_VALUES  then
        RAISE_COMMAND_ERROR( "Too many values" );
      end if;

      if  COMMAND_TOP + TEXT'LENGTH > COMMAND_POOL_SIZE  then
        RAISE_COMMAND_ERROR( "Command too long" );
      end if;

      if  TEXT'LENGTH > 0  then
	S.FIRST := COMMAND_TOP + 1;
	S.LAST  := COMMAND_TOP + TEXT'LENGTH;
	COMMAND_POOL( S.FIRST .. S.LAST ) := TEXT;
	COMMAND_TOP := S.LAST;
      end if;

      VALUE_TOP := VALUE_TOP + 1;
      VALUES( VALUE_TOP ).TEXT := S;
      VALUES( VALUE_TOP ).OWNER := I;
      ENTRIES( I ).VALUES_FOUND := ENTRIES( I ).VALUES_FOUND + 1;
      ENTRIES( I ).STATUS := COMMAND_ACCESS.PRESENT;

    end	ADD_VALUE;
	---------

		-------------------
    procedure	ADD_PARAMETER_VALUE	( TEXT :STRING )
    is		-------------------

      NEXT	:NATURAL	:= 0;

    begin
      if  CURRENT_PARAMETER = 0
	 or else  not ENTRIES( CURRENT_PARAMETER ).MULTIPLE  then
	-- Common parameters come first in ENTRIES, then the verb's own.
	for  I in CURRENT_PARAMETER + 1 .. ENTRY_COUNT  loop
	  if  ENTRIES(I).KIND = PARAMETER
	     and then  ( ENTRIES( I ).VERB_INDEX = CURRENT_VERB
			or ENTRIES( I ).VERB_INDEX = 0 )  then
	    NEXT := I;
	    exit;
	  end if;
	end loop;
	if  NEXT = 0  then
	  RAISE_COMMAND_ERROR( "Too many parameters : " & TEXT );
	end if;
	CURRENT_PARAMETER := NEXT;
      end if;
      ADD_VALUE( CURRENT_PARAMETER, TEXT );

    end	ADD_PARAMETER_VALUE;
	-------------------

		-------------
    procedure	ADD_QUALIFIER
    is		-------------

      -- TOKEN is qualifier shaped ; NAME_LAST and HAS_VALUE are set.
      NAME	:constant STRING := TO_UPPER( TOKEN( 2 .. NAME_LAST ) );
      I		: NATURAL;
      NEGATED	: BOOLEAN	:= FALSE;
      use COMMAND_ACCESS;

    begin
      I := MATCH( NAME, FALSE, FALSE );
      if  I = 0  and then  NAME'LENGTH > 2
	 and then  NAME( NAME'FIRST .. NAME'FIRST + 1 ) = "NO"  then
	I := MATCH( NAME( NAME'FIRST + 2 .. NAME'LAST ), FALSE, TRUE );
	NEGATED := I /= 0;
      end if;

      if  I = 0  then
        RAISE_COMMAND_ERROR( "Unknown qualifier " & TOKEN( 1 .. NAME_LAST ) );
      end if;

      if  ENTRIES( I ).STATUS /= COMMAND_ACCESS.ABSENT  then
        RAISE_COMMAND_ERROR( "Duplicate qualifier " & TOKEN( 1 .. NAME_LAST ) );
      end if;
      if  NEGATED  then
        if  HAS_VALUE  then
	RAISE_COMMAND_ERROR( "A negated qualifier cannot have a value : "
			       & TOKEN( 1 .. NAME_LAST ) );
        end if;
        ENTRIES( I ).STATUS := COMMAND_ACCESS.NEGATED;
        return;
      end if;

      declare
        VALUE	:constant STRING	:= TOKEN( NAME_LAST + 2 .. TOKEN_LENGTH );
      begin
        case  ENTRIES( I ).KIND  is
        when  FLAG_QUALIFIER =>
	    if  HAS_VALUE  then
	      RAISE_COMMAND_ERROR( "No value allowed for " & TOKEN( 1 .. NAME_LAST ) );
	    end if;
	    ENTRIES( I ).STATUS := COMMAND_ACCESS.PRESENT;
        when  LIST_QUALIFIER =>
	    if  HAS_VALUE  and then  VALUE'LENGTH > 0  then
	      ADD_VALUE( I, MATCH_ITEM( DEFINITION_TEXT( ENTRIES( I ).VALUES_LIST ), VALUE ) );
	    elsif  ENTRIES( I ).IMPLICIT_FIRST  and  not HAS_VALUE  then
	      ADD_VALUE( I, FIRST_ITEM( DEFINITION_TEXT( ENTRIES( I ).VALUES_LIST ) ) );
	    else
	      RAISE_COMMAND_ERROR( "Value required for " & TOKEN( 1 .. NAME_LAST ) );
	    end if;
        when  FREE_QUALIFIER =>
	    if  HAS_VALUE  and then  VALUE'LENGTH > 0  then
	      ADD_VALUE( I, VALUE );
	    else
	      RAISE_COMMAND_ERROR( "Value required for " & TOKEN( 1 .. NAME_LAST ) );
	    end if;
        when others =>
	null;
        end case;
      end;

    end	ADD_QUALIFIER;
	-------------

		-------------
    procedure	RESET_COMMAND
    is		-------------
    begin
      COMMAND_TOP := 0;
      VALUE_TOP := 0;
      CURRENT_VERB := 0;
      ERROR_LENGTH := 0;
      for  I in 1 .. ENTRY_COUNT  loop
	ENTRIES(I).STATUS := COMMAND_ACCESS.ABSENT;
	ENTRIES(I).VALUES_FOUND := 0;
      end loop;

    end	RESET_COMMAND;
	-------------

		-----------------
    procedure	CHECK_AND_DEFAULT
    is		-----------------
      -- Missing required parameters ; defaults of absent qualifiers.
      use COMMAND_ACCESS;
    begin
      for  I in 1 .. ENTRY_COUNT  loop
	if  ENTRIES( I ).VERB_INDEX = CURRENT_VERB  or  ENTRIES( I ).VERB_INDEX = 0  then
	  if  ENTRIES( I ).KIND = PARAMETER  then
	    if  ENTRIES( I ).REQUIRED  and  ENTRIES(I).VALUES_FOUND = 0  then
	      RAISE_COMMAND_ERROR( "Missing parameter " & DEFINITION_TEXT( ENTRIES( I ).NAME ) );
	    end if;

	  elsif  ENTRIES( I ).KIND in LIST_QUALIFIER .. FREE_QUALIFIER
	     and then  ENTRIES( I ).STATUS = COMMAND_ACCESS.ABSENT
	     and then  ENTRIES( I ).DEFAULT.LAST >= ENTRIES( I ).DEFAULT.FIRST  then
	    ADD_VALUE( I, DEFINITION_TEXT( ENTRIES(I).DEFAULT ) );
	  end if;
	end if;
      end loop;

    end	CHECK_AND_DEFAULT;
	-----------------

  begin
    if not DEFINED then
      RAISE_COMMAND_ERROR( "Command language not defined (STOP not called)" );
    end if;

    RESET_COMMAND;

    -- The verb
    NEXT_TOKEN( FOUND );
    if  not FOUND  then
      RAISE_COMMAND_ERROR( "Verb expected" );
    end if;

    if  QUALIFIER_SHAPED  then
      RAISE_COMMAND_ERROR( "Verb expected before " & TOKEN( 1 .. TOKEN_LENGTH ) );
    end if;

    CURRENT_VERB := MATCH( TO_UPPER( TOKEN( 1 .. TOKEN_LENGTH ) ), TRUE, FALSE );
    if  CURRENT_VERB = 0  then
      RAISE_COMMAND_ERROR( "Unknown verb " & TOKEN( 1 .. TOKEN_LENGTH ) );
    end if;

    -- Parameters and qualifiers, in any order
    loop
      NEXT_TOKEN( FOUND );
      exit when not FOUND;
      if  QUALIFIER_SHAPED then
        ADD_QUALIFIER;
      else
        ADD_PARAMETER_VALUE( TOKEN( 1 .. TOKEN_LENGTH ) );
      end if;
    end loop;

    CHECK_AND_DEFAULT;

  exception
    when  COMMAND_ERROR =>
      CURRENT_VERB := 0;
      raise;

  end	PARSE_COMMAND_FROM_VERB;
	-----------------------


			-------------
  function		ERROR_MESSAGE		return STRING
  is			-------------
  begin
    return ERROR_TEXT( 1 .. ERROR_LENGTH );

  end	ERROR_MESSAGE;
	-------------


  package body	COMMAND_ACCESS is separate;


	---
end	CLI;
	---

--	1	2	3	4	5	6	7	8	9	0	1	2
------------------------------------------------------------------------------------------------------------------------
