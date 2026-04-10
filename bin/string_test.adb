with TEXT_IO;
use  TEXT_IO;
			-----------
procedure			STRING_TEST
is			-----------
  L	: NATURAL;
  C	: CHARACTER;
  BUF	: STRING( 1 ..128 );

  package NAT_IO is new INTEGER_IO( NATURAL );

  F : FILE_TYPE;

begin
--  PUT( "-----" );
--  PUT( CURRENT_OUTPUT, "NAT_IO TEST " ); NEW_LINE;
--  PUT_LINE( CURRENT_OUTPUT, "NAT_IO TEST " );
--  PUT( CURRENT_OUTPUT, "NAT_IO TEST " ); NEW_LINE;
--  PUT( "-----" );
--  NAT_IO.PUT( 12345 ); NEW_LINE;
--  NAT_IO.PUT( 1024, BASE=> 16 ); NEW_LINE;
--  NAT_IO.PUT( 258, BASE=> 2 );
--  NAT_IO.PUT( 0 );
--  NEW_LINE;

--  PUT( "STRING TEST " );
--  PUT( '!' );
--  NEW_LINE;

  PUT( "CREATE" ); NEW_LINE;
  CREATE( F, OUT_FILE, "test.txt" );
--  SET_LINE_LENGTH( F, 128 );
--  SET_OUTPUT( F );
  PUT_LINE( F, "ligne_1" );
  PUT_LINE( F, "ligne_2" );
--  NEW_LINE( 2 );
--  NAT_IO.PUT( 1024+128, BASE=> 16 ); NEW_LINE;

--  PUT_LINE( "au revoir fichier défaut" );
  CLOSE( F );

  PUT( "OPEN" ); NEW_LINE;
  OPEN( F, IN_FILE, "test.txt" );
  PUT( STANDARD_OUTPUT, "GET" ); NEW_LINE;
  GET( F, C );
  PUT( '<' ); NAT_IO.PUT( CHARACTER'POS( C ) ); PUT( C ); PUT( '>' );
  PUT( STANDARD_OUTPUT, "GET_LINE" ); NEW_LINE;
--  GET_LINE( F, BUF, L );
--  PUT( "GET CHAR : " ); GET( F, C ); PUT( C ); NEW_LINE;
  PUT( "CLOSE" ); NEW_LINE;
  CLOSE( F );

--  PUT_LINE( "Entrez un nombre entier : " );
--  NAT_IO.GET( L );

--  PUT_LINE( "Merci" );

end	STRING_TEST;
	-----------
