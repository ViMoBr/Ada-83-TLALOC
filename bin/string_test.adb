with TEXT_IO;
use  TEXT_IO;
			-----------
procedure			STRING_TEST
is			-----------
  L	: NATURAL;
  package NAT_IO is new INTEGER_IO( NATURAL );

  F : FILE_TYPE;

begin
  PUT( "STRING TEST " );
  PUT( '!' );
  NEW_LINE;

  CREATE( F, OUT_FILE, "test.txt" );
  SET_LINE_LENGTH( F, 128 );
  SET_OUTPUT( F );
  PUT_LINE( "bonjour fichier défaut" );
  NEW_LINE( 2 );
  PUT_LINE( "au revoir fichier défaut" );
  CLOSE( F );

  PUT_LINE( "Entrez un nombre entier : " );
  NAT_IO.GET( L );

  PUT_LINE( "Merci" );

end	STRING_TEST;
	-----------
