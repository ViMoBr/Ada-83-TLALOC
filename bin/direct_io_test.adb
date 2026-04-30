with TEXT_IO; use TEXT_IO;
--with DIRECT_IO;
			--------------
procedure			DIRECT_IO_TEST
is			--------------

  package INT_IO	is new INTEGER_IO( INTEGER );

  G	: FILE_TYPE;

--  package FLT_DIRECT_IO is new DIRECT_IO( FLOAT );
--  use FLT_DIRECT_IO;

--  F	: FLT_DIRECT_IO.FILE_TYPE;
  R	: FLOAT	:= 3.5;

  use INT_IO;

begin
  PUT( " FLOAT SIZE (bits) = "  ); PUT( R'SIZE ); NEW_LINE;

  CREATE( G, OUT_FILE, "io_int.dat" );
  PUT( G, 128 );
  CLOSE( G );

--  CREATE( F, OUT_FILE, "flt_direct.dat" );
--  WRITE( F, R );
--  CLOSE( F );

end	DIRECT_IO_TEST;
	--------------
