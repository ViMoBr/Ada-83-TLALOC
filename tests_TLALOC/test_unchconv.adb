with UNCHECKED_CONVERSION;
		-------------------------
procedure		TEST_UNCHECKED_CONVERSION
is		-------------------------

  function INT_TO_FLOAT	is new UNCHECKED_CONVERSION( INTEGER, FLOAT );

  I	: INTEGER	:= 1;
  F	: FLOAT	:= 3.14;

begin
    F := INT_TO_FLOAT( I );

end	TEST_UNCHECKED_CONVERSION;
	-------------------------
