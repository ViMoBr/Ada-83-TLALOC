with TEXT_IO; use TEXT_IO;
with DIRECT_IO;
			--------------
procedure			DIRECT_IO_TEST
is			--------------

  B : BOOLEAN := TRUE;

  package INT_IO	is new INTEGER_IO( INTEGER );
  use INT_IO;

  package LONG_FLOAT_DIRECT_IO is new DIRECT_IO( LONG_FLOAT );
  use LONG_FLOAT_DIRECT_IO;

  F	: LONG_FLOAT_DIRECT_IO.FILE_TYPE;
  R	: LONG_FLOAT	:= 3.1415;

begin
  PUT( " FLOAT SIZE (bits) = "  ); PUT( LONG_FLOAT'SIZE ); NEW_LINE;

  CREATE( F, OUT_FILE, "long_float_direct.dat" );
--put_line( "create ok" );
  WRITE( F, R );
--put_line( "write ok" );
  CLOSE( F );
put_line( "close ok" );

end	DIRECT_IO_TEST;
	--------------
