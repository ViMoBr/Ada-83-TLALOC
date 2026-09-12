------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------
--	Test driver for CLI. Reads command lines (from the verb) on standard
--	input, one per line, and dumps what COMMAND_ACCESS returns.
--	Lines starting with '#' are echoed as comments. End of file quits.
------------------------------------------------------------------------
with TEXT_IO;
with CLI;

procedure TEST_CLI is

  use CLI.COMMAND_ACCESS;

  LINE	:STRING( 1 .. 1024 );
  LAST	:NATURAL;

  procedure SHOW( NAME :STRING ) is
    -- One line per name : status and values, or NO_SUCH_NAME.
    S	:QUALIFIER_STATUS;
  begin
    TEXT_IO.PUT( "    " & NAME & " : " );
    S := STATUS_OF( NAME );
    TEXT_IO.PUT( QUALIFIER_STATUS'IMAGE( S ) );
    for I in 1 .. VALUE_COUNT( NAME ) loop
      TEXT_IO.PUT( " [" & GET_VALUE( NAME, I ) & "]" );
    end loop;
    TEXT_IO.NEW_LINE;
  exception
    when NO_SUCH_NAME =>
      TEXT_IO.PUT_LINE( "no such name for this verb" );
  end SHOW;

begin
  CLI.COMMAND_DEFINE.START( TOOL_NAME=> "TLALOC" );
  CLI.COMMAND_DEFINE.ADD_QUALIFIER( "LOG" );			-- common to all verbs
  CLI.COMMAND_DEFINE.ADD_VERB( "HELP" );
  CLI.COMMAND_DEFINE.ADD_PARAMETER( "TOPIC", REQUIRED=> FALSE );
  CLI.COMMAND_DEFINE.ADD_VERB( "COMPILE" );
  CLI.COMMAND_DEFINE.ADD_QUALIFIER( "STOP_PHASE", "WRITELIB,SYNTAX,LIB,SEMANTICS,EXPAND",
				     IMPLICIT_FIRST_VALUE=> TRUE );
  CLI.COMMAND_DEFINE.ADD_QUALIFIER( "OPTIMIZE", "O1,O2",
				     IMPLICIT_FIRST_VALUE=> TRUE, NEGATABLE=> TRUE,
				     DEFAULT=> "O1" );
  CLI.COMMAND_DEFINE.ADD_FREE_VALUE_QUALIFIER( "OUTPUT", NEGATABLE=> TRUE );
  CLI.COMMAND_DEFINE.ADD_PARAMETER( "SOURCE", MULTIPLE=> TRUE );
  CLI.COMMAND_DEFINE.ADD_VERB( "CODE" );
  CLI.COMMAND_DEFINE.ADD_QUALIFIER( "TARGET", "ARM64,X86_64,RISCV" );
  CLI.COMMAND_DEFINE.ADD_PARAMETER( "UNIT" );
  CLI.COMMAND_DEFINE.ADD_VERB( "QUIT" );
  CLI.COMMAND_DEFINE.STOP;

  CLI.COMMAND_DEFINE.SHOW_SYNTAX;
  TEXT_IO.NEW_LINE;

  loop
    TEXT_IO.GET_LINE( LINE, LAST );
    if LAST > 0 and then LINE(1) = '#' then
      TEXT_IO.PUT_LINE( LINE( 1 .. LAST ) );
    else
      TEXT_IO.PUT_LINE( "> " & LINE( 1 .. LAST ) );
      begin
	CLI.PARSE_COMMAND_FROM_VERB( LINE( 1 .. LAST ) );
	TEXT_IO.PUT_LINE( "  verb " & GET_VERB );
	SHOW( "LOG" );
	SHOW( "TOPIC" );
	SHOW( "SOURCE" );
	SHOW( "STOP_PHASE" );
	SHOW( "OPTIMIZE" );
	SHOW( "OUTPUT" );
	SHOW( "TARGET" );
	SHOW( "UNIT" );
      exception
	when CLI.COMMAND_ERROR =>
	  TEXT_IO.PUT_LINE( "  ERROR : " & CLI.ERROR_MESSAGE );
      end;
    end if;
  end loop;

exception
  when TEXT_IO.END_ERROR =>
    TEXT_IO.PUT_LINE( "-- end of test" );
  when CLI.COMMAND_DEFINE.DEFINITION_ERROR =>
    TEXT_IO.PUT_LINE( "DEFINITION ERROR : " & CLI.ERROR_MESSAGE );

end TEST_CLI;
