with DIRECT_IO;
			--------------
procedure			DIRECT_IO_TEST
is			--------------

  package FLT_DIRECT_IO is new DIRECT_IO( FLOAT );
  use FLT_DIRECT_IO;
  F	: FLT_DIRECT_IO.FILE_TYPE;

  R	: FLOAT	:= 3.5;

begin
  CREATE( F, OUT_FILE, "flt_direct.dat" );
  WRITE( F, R );
  CLOSE( F );

end	DIRECT_IO_TEST;
	--------------
