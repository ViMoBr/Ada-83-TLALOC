with TEXT_IO;
use  TEXT_IO;
			-------
procedure			IO_TEST
is			-------

  F		: FILE_TYPE;
  G		: FILE_TYPE;
  CH		: CHARACTER;
  BUF		: STRING( 1 .. 80 );
  LAST		: NATURAL;

  package INT_IO is new INTEGER_IO( INTEGER );  use INT_IO;

begin

  --  1. Ecriture sur fichier explicite
  PUT_LINE( "=== 1. Ecriture fichier ===" );
  CREATE( F, OUT_FILE, "io_test.dat" );
  PUT( F, "Ligne un" );
  NEW_LINE( F );
  PUT( F, "Ligne deux" );
  NEW_LINE( F );
  PUT( F, "42" );
  NEW_LINE( F );
  CLOSE( F );
  PUT_LINE( "Fichier io_test.dat cree." );

  --  2. Relecture du fichier
  PUT_LINE( "=== 2. Relecture fichier ===" );
  OPEN( G, IN_FILE, "io_test.dat" );
  GET_LINE( G, BUF, LAST );
  PUT( "Lu ligne 1 : [" );
  PUT( STANDARD_OUTPUT, BUF( 1 .. LAST ) );
  PUT_LINE( "]" );

  GET_LINE( G, BUF, LAST );
  PUT( "Lu ligne 2 : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );

  GET_LINE( G, BUF, LAST );
  PUT( "Lu ligne 3 : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  CLOSE( G );

  --  3. Fichier par defaut via SET_OUTPUT
  PUT_LINE( "=== 3. SET_OUTPUT fichier ===" );
  CREATE( F, OUT_FILE, "io_def.dat" );
  SET_OUTPUT( F );
  PUT_LINE( "Ceci va dans io_def.dat" );
  PUT( "Valeur = " );
  INT_IO.PUT( 999 );
  NEW_LINE;
  SET_OUTPUT( STANDARD_OUTPUT );
  CLOSE( F );
  PUT_LINE( "Retour console apres SET_OUTPUT." );

  --  4. Relecture du fichier par defaut
  PUT_LINE( "=== 4. Relecture io_def.dat ===" );
  OPEN( G, IN_FILE, "io_def.dat" );
  GET_LINE( G, BUF, LAST );
  PUT( "Lu : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  GET_LINE( G, BUF, LAST );
  PUT( "Lu : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  CLOSE( G );

  --  5. INTEGER_IO bases
  PUT_LINE( "=== 5. INTEGER_IO bases ===" );
  PUT( "Decimal  255 = " );  INT_IO.PUT( 255 );          NEW_LINE;
  PUT( "Hex      255 = " );  INT_IO.PUT( 255, BASE=>16 ); NEW_LINE;
  PUT( "Binaire   10 = " );  INT_IO.PUT( 10,  BASE=>2 );  NEW_LINE;
  PUT( "Octal    255 = " );  INT_IO.PUT( 255, BASE=>8 );  NEW_LINE;
  PUT( "Negatif  -42 = " );  INT_IO.PUT( -42 );           NEW_LINE;
  PUT( "Neg hex  -26 = " );  INT_IO.PUT( -26, BASE=>16 ); NEW_LINE;
  PUT( "Width 10     = [" ); INT_IO.PUT( 7, WIDTH=>10 );  PUT_LINE( "]" );
  PUT( "Zero         = " );  INT_IO.PUT( 0 );             NEW_LINE;
  PUT( "Zero hex     = " );  INT_IO.PUT( 0, BASE=>16 );   NEW_LINE;

  --  6. Ecriture INTEGER_IO dans fichier puis relecture
  PUT_LINE( "=== 6. INTEGER_IO dans fichier ===" );
  CREATE( F, OUT_FILE, "io_int.dat" );
  INT_IO.PUT( F, 12345 );
  NEW_LINE( F );
  INT_IO.PUT( F, -67, BASE => 16 );
  NEW_LINE( F );
  CLOSE( F );

  OPEN( G, IN_FILE, "io_int.dat" );
  GET_LINE( G, BUF, LAST );
  PUT( "Lu entier fichier : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  GET_LINE( G, BUF, LAST );
  PUT( "Lu entier fichier : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  CLOSE( G );

  PUT_LINE( "=== Fin du test ===" );

end	IO_TEST;
	-------
