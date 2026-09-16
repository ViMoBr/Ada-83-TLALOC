with TEXT_IO;
use TEXT_IO;
		--------
procedure		GET_CHAR
is		--------
  C	: CHARACTER;
begin
  PUT( "Tape un caractere : " );
  GET( C );
  PUT_LINE( "" );
  PUT( "Lu = " );
  PUT( C );
  NEW_LINE;

end	GET_CHAR;
	--------
