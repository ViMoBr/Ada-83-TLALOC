with TEXT_IO; use TEXT_IO;
			-----------
procedure			TEST_INT_IO
is			-----------

  package INT_IO	is new INTEGER_IO( INTEGER );

  I	: INTEGER	:= 12;
begin
  PUT( '<' ); INT_IO.PUT( I ); PUT( '>' );
  NEW_LINE;

end	TEST_INT_IO;
	-----------
