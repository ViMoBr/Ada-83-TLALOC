with TEXT_IO;
use TEXT_IO;
		--------
procedure		GET_LINE
is		--------
  S	: STRING( 1 .. 64 );
  LAST	: NATURAL;

begin
  PUT( "Ligne : " );
  GET_LINE( S, LAST );
  PUT("Recu : " );
  PUT_LINE( S( 1 .. LAST ) );

end	GET_LINE;
	--------
