with TEXT_IO;  use TEXT_IO;
			-----------------
procedure			TEST_FIXED_IO_GET
is			-----------------

  package DUR_IO is new FIXED_IO( DURATION );
  package FLT_IO is new FLOAT_IO( LONG_FLOAT );

  D : DURATION;

begin
  PUT_LINE( "Entrer 12.75 :" );
  DUR_IO.GET( D );

  FLT_IO.PUT( LONG_FLOAT( D ), FORE => 1, AFT => 6, EXP => 2 );
  NEW_LINE;

end	TEST_FIXED_IO_GET;
	-----------------
