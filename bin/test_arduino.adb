with SEQUENTIAL_IO;
			------------
procedure			TEST_ARDUINO
is			------------

  package CHAR_IO	is new SEQUENTIAL_IO( CHARACTER );
  use CHAR_IO;

  PORT	: FILE_TYPE;
  C	: CHARACTER;

begin
  OPEN( PORT, OUT_FILE, "/dev/ttyACM0" );
  C := 'H';  WRITE( PORT, C );
  C := 'i';  WRITE( PORT, C );
  CLOSE( PORT );

end	TEST_ARDUINO;
	------------
