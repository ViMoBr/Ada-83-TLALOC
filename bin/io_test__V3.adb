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
  PUT( BUF( 1 .. LAST ) );
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

  --  7. RESET : ecrire, puis RESET en lecture et relire
  PUT_LINE( "=== 7. RESET fichier ===" );
  CREATE( F, OUT_FILE, "io_reset.dat" );
  PUT_LINE( F, "Premiere ligne" );
  PUT_LINE( F, "Deuxieme ligne" );
  PUT_LINE( F, "Troisieme ligne" );
  RESET( F, IN_FILE );
  GET_LINE( F, BUF, LAST );
  PUT( "Apres RESET lu : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  GET_LINE( F, BUF, LAST );
  PUT( "Apres RESET lu : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  CLOSE( F );

  --  8. SKIP_LINE : ecrire 4 lignes, relire en sautant
  PUT_LINE( "=== 8. SKIP_LINE ===" );
  CREATE( F, OUT_FILE, "io_skip.dat" );
  PUT_LINE( F, "Ligne A" );
  PUT_LINE( F, "Ligne B" );
  PUT_LINE( F, "Ligne C" );
  PUT_LINE( F, "Ligne D" );
  RESET( F, IN_FILE );
  SKIP_LINE( F );
  GET_LINE( F, BUF, LAST );
  PUT( "Apres SKIP 1 lu : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  SKIP_LINE( F );
  GET_LINE( F, BUF, LAST );
  PUT( "Apres SKIP 1 lu : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  CLOSE( F );

  --  9. NEW_PAGE : ecriture avec saut de page
  PUT_LINE( "=== 9. NEW_PAGE ===" );
  CREATE( F, OUT_FILE, "io_page.dat" );
  PUT_LINE( F, "Page 1 contenu" );
  NEW_PAGE( F );
  PUT_LINE( F, "Page 2 contenu" );
  CLOSE( F );
  OPEN( G, IN_FILE, "io_page.dat" );
  GET_LINE( G, BUF, LAST );
  PUT( "Page 1 : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  SKIP_LINE( G );
  GET_LINE( G, BUF, LAST );
  PUT( "Page 2 : [" );
  PUT( BUF( 1 .. LAST ) );
  PUT_LINE( "]" );
  CLOSE( G );

  -- 10. END_OF_FILE : lire tout un fichier ligne par ligne
  PUT_LINE( "=== 10. END_OF_FILE ===" );
  CREATE( F, OUT_FILE, "io_eof.dat" );
  PUT_LINE( F, "Alpha" );
  PUT_LINE( F, "Beta" );
  PUT_LINE( F, "Gamma" );
  RESET( F, IN_FILE );
  loop
    exit when END_OF_FILE( F );
    GET_LINE( F, BUF, LAST );
    PUT( "EOF lu : [" );
    PUT( BUF( 1 .. LAST ) );
    PUT_LINE( "]" );
    exit;
  end loop;
  PUT_LINE( "EOF atteint." );
  CLOSE( F );

  PUT_LINE( "=== Fin du test ===" );

end	IO_TEST;
	-------
