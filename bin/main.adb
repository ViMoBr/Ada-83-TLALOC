with UNCHECKED_DEALLOCATION;
with TEXT_IO;
with SYSTEM;
			----
procedure			MAIN
is			----

  LOOP_ERROR	: exception;

  S		: STRING (1 .. 128)		:= (others=> '#');
  L		: NATURAL			:= 0;

  type DEPTH_TYPE		is range 0 .. 9000;
  type DEPTH_COUNT 		is range 0 .. SYSTEM.MAX_INT;
  package DPTH_IO		is new TEXT_IO.INTEGER_IO( DEPTH_TYPE );
  package DECO_IO		is new TEXT_IO.INTEGER_IO( DEPTH_COUNT );

  F		: TEXT_IO.FILE_TYPE;

		--------------------------
  function	GET_NUMBER_OF_MEASUREMENTS		return DEPTH_COUNT
  is		--------------------------
    type LOOP_INDEX		is range 1 .. SYSTEM.MAX_INT;
    LAST			: DEPTH_COUNT := 0;
    UNUSED_DEPTH		: DEPTH_TYPE;

  begin
    TEXT_IO.OPEN( FILE=> F, MODE=> TEXT_IO.IN_FILE, NAME=> S( 1 .. L ) );
    for  I in LOOP_INDEX range 1 .. SYSTEM.MAX_INT  loop
      exit when  TEXT_IO.END_OF_FILE( F );
      DPTH_IO.GET( FILE => F, ITEM => UNUSED_DEPTH );
      LAST := LAST + 1;
    end loop;

    if  not TEXT_IO.END_OF_FILE( F )  then
         raise  LOOP_ERROR;
      end if;
      TEXT_IO.CLOSE( F );
      return  LAST;

   end	GET_NUMBER_OF_MEASUREMENTS;
	--------------------------


			---
  procedure		RUN
  is			---

    N	: constant DEPTH_COUNT := GET_NUMBER_OF_MEASUREMENTS;

    subtype DEPTH_INDEX	is DEPTH_COUNT range 1 .. DEPTH_COUNT'LAST;
    type DEPTH_ARRAY	is array (DEPTH_INDEX range <>) of DEPTH_TYPE;

		--------
    procedure	RUN_MAIN		( DEPTH :in out DEPTH_ARRAY )
    is		--------

      NUMBER_OF_INCREASES	: DEPTH_COUNT	:= 0;
      D			: DEPTH_ARRAY renames DEPTH;

    begin
      TEXT_IO.OPEN( FILE => F, MODE => TEXT_IO.IN_FILE, NAME => S( 1 .. L ) );

      for I in DEPTH_INDEX range 1 .. D'LAST loop
        DPTH_IO.GET( FILE => F, ITEM => D( I ) );
      end loop;
      TEXT_IO.CLOSE( F );

      for  I in DEPTH_INDEX range 2 .. D'LAST  loop
        if  D( I ) > D( I-1 )  then
	NUMBER_OF_INCREASES := NUMBER_OF_INCREASES + 1;
        end if;
      end loop;

      TEXT_IO.PUT( "ANSWER: " );
      DECO_IO.PUT( ITEM  => NUMBER_OF_INCREASES, WIDTH => 0 );
      TEXT_IO.NEW_LINE;

    end	RUN_MAIN;
	--------

			--------
    procedure		USE_FILE
    is			--------

      type DEPTH_ACCESS	is access DEPTH_ARRAY;
      D			: DEPTH_ACCESS;

      procedure FREE	is new UNCHECKED_DEALLOCATION( OBJECT=> DEPTH_ARRAY, NAME=> DEPTH_ACCESS );

    begin
      D := new DEPTH_ARRAY( 1 .. N );
      RUN_MAIN( D.all );
      FREE( D );

    exception
      when others =>
        FREE( D );
        raise;

    end	USE_FILE;
	--------


		--------------
  procedure	READ_TEXT_FILE
  is		--------------
  begin
    USE_FILE;
    if TEXT_IO.IS_OPEN( F ) then
      TEXT_IO.CLOSE( F );
    end if;

  exception
    when others =>
      if  TEXT_IO.IS_OPEN( F )  then
        TEXT_IO.CLOSE( F );
      end if;
      raise;

  end	READ_TEXT_FILE;
	--------------

  begin
    READ_TEXT_FILE;

  end	RUN;
	---
begin
   TEXT_IO.GET_LINE( S, L );
   PUT( S( 1 .. L ) );
   NEW_LINE;
   case L is
      when 0 =>
         TEXT_IO.PUT( "SPECIFY ONE COMMAND ARGUMENT, THE INPUT FILE." );
         TEXT_IO.NEW_LINE;
         return;
      when others => RUN;
   end case;

end	MAIN;
	----
