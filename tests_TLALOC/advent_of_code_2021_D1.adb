with TEXT_IO;
use  TEXT_IO;
				----------------------
procedure				ADVENT_OF_CODE_2021_D1
is				----------------------

  DEPTHS_FILE		: FILE_TYPE;
  NUMBER_OF_INCREASES	: NATURAL		:= 0;
  package DEPTH_IO		is new INTEGER_IO( NATURAL );

begin
			---------------------
			INPUT_DEPTHS_FILE_NAME:
  declare
    FILE_NAME_BUFFER	: STRING( 1 .. 128 );
    FILE_NAME_LENGTH	: NATURAL;
  begin
    PUT( "PLEASE ENTER DEPTHS FILE NAME : " );
    GET_LINE( FILE_NAME_BUFFER, FILE_NAME_LENGTH );
    OPEN( DEPTHS_FILE, IN_FILE, FILE_NAME_BUFFER( 1 .. FILE_NAME_LENGTH ) );
    PUT_LINE( "OK THANKS, COMPUTING THE NUMBER OF DEPTH INCREASES..." );

  end	INPUT_DEPTHS_FILE_NAME;
	----------------------

			-----------------------
			COMPUTE_DEPTH_INCREASES:
  declare
    PRESENT_DEPTH		: NATURAL		:= 0;
    NEXT_DEPTH		: NATURAL;

  begin
    while  not END_OF_FILE( DEPTHS_FILE )  loop
      PUT( "present depth : " ); DEPTH_IO.PUT( PRESENT_DEPTH );
      DEPTH_IO.GET( DEPTHS_FILE, NEXT_DEPTH );
      PUT( "   next depth :" ); DEPTH_IO.PUT( NEXT_DEPTH );

      if  NEXT_DEPTH > PRESENT_DEPTH  then
        NUMBER_OF_INCREASES := NUMBER_OF_INCREASES + 1;
        PUT( " increase" );
        PRESENT_DEPTH := NEXT_DEPTH;
      end if;
      NEW_LINE;
    end loop;

  end	COMPUTE_DEPTH_INCREASES;
	-----------------------

  CLOSE( DEPTHS_FILE );
  NEW_LINE;
  PUT( "THE NUMBER OF DEPTH INCREASES IS : " ); DEPTH_IO.PUT( NUMBER_OF_INCREASES ); NEW_LINE( 2 );
  PUT_LINE( "BYE" );

end	ADVENT_OF_CODE_2021_D1;
	----------------------
