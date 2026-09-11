------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

		--------------------------------------------------------------------------------
		--	C O M M A N D   L A N G U A G E   I N T E R P R E T E R
		--
		--	Defines, parses, accesses DCL like commands :
		--
		--  TOOL VERB PARAMETERS /QUALIFIER /QUALIFIER=VALUE
		--
		--	TLALOC HELP
		--	TLALOC COMPILE /STOP_PHASE=WRITELIB essai.adb util.adb
		--	TLALOC COMPILE /OUTPUT="mon fichier.lis" src/essai.adb
		--	TLALOC CODE /TARGET=ARM64 essai
		--	TLALOC QUIT
		--
		--
		-- CLI.COMMAND_DEFINE.START( TOOL_NAME=> "TLALOC" );
		-- ADD_VERB( "HELP" );
		-- ADD_VERB( "COMPILE" );
		-- ADD_QUALIFIER( "STOP_PHASE", "WRITELIB,SYNTAX,LIB,SEMANTICS,EXPAND",
		--		IMPLICIT_FIRST_VALUE=> TRUE );
		-- ADD_QUALIFIER( "OPTIMIZE", "O1,O2",
		--		IMPLICIT_FIRST_VALUE=> TRUE, NEGATABLE=> TRUE );
		-- ADD_PARAMETER( "SOURCE" );
		-- ADD_VERB( "QUIT" );
		-- CLI.COMMAND_DEFINE.STOP;
		--
		-- Parameters and qualifiers following ADD_VERB apply to that verb,
		-- until the next ADD_VERB or STOP.
		--
		-- IS_PRESENT( "DEBUG" ) returns false if /NODEBUG is given
		-- /OPTIMIZE without value defaults to first value in list if
		--    IMPLICIT_FIRST_VALUE is flagged true. If flagged false some value must be
		--    given or COMMAND_ERROR exception is raised.
		-- /NOOPTIMIZE (if allowed by NEGATABLE definition flag) cannot have a value
		--    and user program decides what to do with STATUS_OF( "OPTIMIZE" ) which
		--    returns NEGATED.
		--
		-- Lexical rules :
		--    A qualifier starts with QUALIFIER_MARK (default '/') only when
		--    the mark is at the head of a token, i.e. preceded by a blank or
		--    by the beginning of the line. Inside a token the mark is an
		--    ordinary character, so src/essai.adb is one parameter value.
		--    A token at whose head the mark is found is a qualifier only if
		--    it has the shape of one : the mark, an identifier (letters,
		--    digits, underscores), then optionally '=' and a value. Any
		--    other token starting with the mark is a parameter value, so
		--    unix rooted names such as /tmp/log.txt need no quoting. A
		--    token shaped as a qualifier but not defined for the verb
		--    raises COMMAND_ERROR ; a file name which happens to have that
		--    shape, such as /tmp, must be quoted.
		--    A value containing blanks is enclosed in double quotes ; a
		--    doubled quote inside stands for one quote.
		--    Verbs, qualifier names and list values are case insensitive
		--    and may be abbreviated to any unambiguous prefix. GET_VALUE
		--    returns the full canonical (upper case) spelling for list
		--    values, and the user text unchanged for parameters and free
		--    value qualifiers.
		--
		-- Scope :
		--    Parameters and qualifiers added between START and the first
		--    ADD_VERB are common to every verb.
		--
		-- Defaults :
		--    DEFAULT gives the value of a list or free value qualifier when
		--    the user omits it altogether ; STATUS_OF then returns PRESENT
		--    and GET_VALUE returns DEFAULT. An empty DEFAULT means ABSENT.
		--
		-- Multiple values :
		--    ADD_PARAMETER( "SOURCE", MULTIPLE=> TRUE ) accepts one or more
		--    tokens. Qualifiers always apply to the command as a whole,
		--    never to one parameter, so they may appear anywhere on the
		--    line, including between the values of a MULTIPLE parameter.
		--    VALUE_COUNT( "SOURCE" ) gives how many and
		--    GET_VALUE( "SOURCE", I ) the I-th one. Only the last parameter
		--    of a verb may be MULTIPLE.
		--
		-- DEFINITION_ERROR is raised by COMMAND_DEFINE for 1) a duplicate name,
		--    i.e. repeated inside a verb, or already defined as common to all
		--    verbs. The same name may be reused in different verbs.
		--    2) a parameter or qualifier added before START, 3) a required
		--    parameter following an optional one, 4) a DEFAULT which is not
		--    in VALUES_LIST, or 5) a full table.
		---------------------------------------------------------------------------------


					---
package					CLI
is					---


			--------------
  package			COMMAND_DEFINE
  is			--------------

    procedure START			( TOOL_NAME :STRING; QUALIFIER_MARK :CHARACTER := '/' );
    procedure ADD_VERB		( NAME :STRING );
    procedure ADD_PARAMETER		( NAME :STRING;
				  REQUIRED :BOOLEAN := TRUE; MULTIPLE :BOOLEAN := FALSE );
    procedure ADD_QUALIFIER		( NAME :STRING; NEGATABLE :BOOLEAN := FALSE );
    procedure ADD_QUALIFIER		( NAME :STRING; VALUES_LIST :STRING;
				  IMPLICIT_FIRST_VALUE, NEGATABLE :BOOLEAN := FALSE;
				  DEFAULT :STRING := "" );
    procedure ADD_FREE_VALUE_QUALIFIER	( NAME :STRING;
				  NEGATABLE :BOOLEAN := FALSE;
				  DEFAULT :STRING := "" );
    procedure STOP;

    procedure SHOW_SYNTAX		( VERB :STRING := "" );
		-- Prints the grammar of one verb, or of the whole tool if VERB is empty.

    DEFINITION_ERROR	:exception;

	--------------
  end	COMMAND_DEFINE;
	--------------


  procedure PARSE_COMMAND;
  procedure PARSE_COMMAND_FROM_VERB	( LINE :STRING );

  COMMAND_ERROR		:exception;
  function  ERROR_MESSAGE				return STRING;


			--------------
  package			COMMAND_ACCESS
  is			--------------

    type  QUALIFIER_STATUS	is ( ABSENT, PRESENT, NEGATED );

    function  TOOL_NAME							return STRING;
    function  GET_VERB							return STRING;
    function  IS_PRESENT	( NAME :STRING )					return BOOLEAN;
    function  STATUS_OF	( QUALIFIER :STRING )				return QUALIFIER_STATUS;


    function  VALUE_COUNT	( NAME :STRING )					return NATURAL;
    function  GET_VALUE	( NAME :STRING; INDEX :POSITIVE := 1 )			return STRING;
		-- VALUE_COUNT is 0 when NAME is absent or negated, 1 for any single
 		-- valued name, N for a MULTIPLE parameter. GET_VALUE raises NO_VALUE
		-- when INDEX > VALUE_COUNT( NAME ).

    NO_SUCH_NAME		: exception;
    NO_VALUE		: exception;

	--------------
  end	COMMAND_ACCESS;
	--------------


	---
end	CLI;
	---

--	1	2	3	4	5	6	7	8	9	0	1	2
------------------------------------------------------------------------------------------------------------------------
