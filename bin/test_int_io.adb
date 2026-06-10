with TEXT_IO; use TEXT_IO;
			-----------
procedure			TEST_INT_IO
is			-----------

  package INT_IO	is new INTEGER_IO( INTEGER );

  I	: INTEGER	:= 12;
  S1	: STRING( 1 .. 10 );
  S2	: STRING( 1 .. 10 );
  L	: POSITIVE;

begin

  PUT( '<' ); INT_IO.PUT( I ); PUT( '>' );
  NEW_LINE;

  INT_IO.PUT( S1, 255, BASE => 10 );
  PUT_LINE( S1 );

  INT_IO.PUT( S2, 255, BASE => 16 );
  PUT_LINE( S2 );

  INT_IO.GET( "  -123 xxx", I, L );
  INT_IO.PUT( I ); NEW_LINE;

  INT_IO.GET( "16#FF# reste", I, L );
  INT_IO.PUT( I ); NEW_LINE;

  declare
    S : STRING( 1 .. 3 );
  begin
    INT_IO.PUT( S, 12345 );
    PUT_LINE( S );
  end;

end	TEST_INT_IO;
	-----------
