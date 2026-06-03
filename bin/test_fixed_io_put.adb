with TEXT_IO;  use TEXT_IO;
			-----------------
procedure			TEST_FIXED_IO_PUT
is			-----------------

  package DUR_IO	is new FIXED_IO( DURATION );

begin
  DUR_IO.PUT( DURATION'( 0.0 ),     FORE => 1, AFT => 6, EXP => 0 );
  NEW_LINE;

  DUR_IO.PUT( DURATION'( 1.0 ),     FORE => 1, AFT => 6, EXP => 0 );
  NEW_LINE;

  DUR_IO.PUT( DURATION'( 0.5 ),     FORE => 1, AFT => 6, EXP => 0 );
  NEW_LINE;

  DUR_IO.PUT( DURATION'( 12.75 ),   FORE => 1, AFT => 6, EXP => 0 );
  NEW_LINE;

  DUR_IO.PUT( DURATION'( -12.75 ),  FORE => 1, AFT => 6, EXP => 0 );
  NEW_LINE;

  DUR_IO.PUT( DURATION'( 86399.75 ), FORE => 1, AFT => 6, EXP => 0 );
  NEW_LINE;

end	TEST_FIXED_IO_PUT;
	-----------------
