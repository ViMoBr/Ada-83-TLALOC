procedure TEST_INDEXED
is
  type GA_TYPE	is array( 1 .. 128 ) of INTEGER;
  GA_NAME	: GA_TYPE;

  I	: INTEGER	:= 8;
  J	: INTEGER	:= 4;
begin
  GA_NAME( 4 ) := I;
  I := GA_NAME( J );

end	TEST_INDEXED;
