with TEXT_IO; use TEXT_IO;
			-----------
procedure			TEST_INT_IO
is			-----------

  type DURAT_ION		is delta 2.0**(-29) range -2.0**34 .. 2.0**34 - 1.0;

  package INT_IO	is new INTEGER_IO( INTEGER );

  I	: INTEGER	:= 12;
begin
  PUT( '<' ); INT_IO.PUT( I ); PUT( '>' );
  NEW_LINE;

end	TEST_INT_IO;
	-----------
