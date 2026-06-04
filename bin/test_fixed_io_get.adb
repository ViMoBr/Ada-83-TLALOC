with TEXT_IO;  use TEXT_IO;
			-----------------
procedure			TEST_FIXED_IO_GET
is			-----------------

  package DUR_IO is new FIXED_IO( DURATION );
  package FLT_IO is new FLOAT_IO( LONG_FLOAT );

  D : DURATION;

begin

declare
  S1 : STRING( 1 .. 12 );
  S2 : STRING( 1 .. 13 );
  S3 : STRING( 1 .. 14 );
begin
  DUR_IO.PUT( S1, DURATION'( 12.75 ),  AFT => 2, EXP => 0 );
--  PUT_LINE( "[" & S1 & "]" );
  PUT( '[' ); PUT( S1 ); PUT( ']' ); NEW_LINE;

  DUR_IO.PUT( S2, DURATION'( -12.75 ), AFT => 2, EXP => 0 );
--  PUT_LINE( "[" & S2 & "]" );
  PUT( '[' ); PUT( S2 ); PUT( ']' ); NEW_LINE;

  DUR_IO.PUT( S3, DURATION'( 12.75 ),  AFT => 4, EXP => 2 );
--  PUT_LINE( "[" & S3 & "]" );
  PUT( '[' ); PUT( S3 ); PUT( ']' ); NEW_LINE;
end;

  PUT_LINE( "Entrer 12.75 :" );
  DUR_IO.GET( D );

  FLT_IO.PUT( LONG_FLOAT( D ), FORE => 1, AFT => 6, EXP => 2 );
  NEW_LINE;

end	TEST_FIXED_IO_GET;
	-----------------
