with TEXT_IO;	use TEXT_IO;
					-------
procedure				TEXT14P
is					-------

  -- Sonde de bisection du segfault de TEXT14/U5 (8 juillet 2026).
  -- Chaque etape de la sequence U5 est suivie d'un marqueur console :
  -- le dernier marqueur affiche est la derniere etape REUSSIE, le
  -- crash est dans l'etape suivante.
  --
  -- Grille de lecture :
  --   P01-P07  ecriture (deja exercee en U1-U4, ne devrait pas casser)
  --   P08      CLOSE           : premiere fermeture explicite du filet
  --   P09      OPEN IN_FILE    : chemin possiblement jamais exerce
  --   P10-P12  GET public      : READ_SYSTEM_CALL mono-caractere sur
  --                              descripteur reel (les anciens temoins
  --                              lisaient la console par redirection)
  --   P13-P14  look-ahead END_OF_LINE puis GET(STRING) a travers
  --   P15      scanner INTEGER_IO sur fichier
  --   P16-P17  GET_LINE fichier
  --   P18-P19  END_OF_FILE puis END_ERROR
  --   P20      DELETE

  package	I_IO	is new INTEGER_IO( INTEGER );

  type COULEUR	is ( ROUGE, VERT, BLEU );
  package	C_IO	is new ENUMERATION_IO( COULEUR );

  F	: FILE_TYPE;
  C	: CHARACTER;
  S2	: STRING( 1 .. 2 );
  BUF	: STRING( 1 .. 40 );
  LST	: NATURAL;
  N	: INTEGER;

begin
  PUT_LINE( "P00 debut" );

  CREATE( F, OUT_FILE, "TEXT14P.TXT" );
  PUT_LINE( "P01 CREATE" );

  PUT_LINE( F, "ABC" );
  PUT_LINE( "P02 PUT_LINE ABC" );

  PUT_LINE( F, "DE" );
  PUT_LINE( "P03 PUT_LINE DE" );

  I_IO.PUT( F, 42, 1 );
  PUT_LINE( "P04 I_IO.PUT 42" );

  NEW_LINE( F );
  PUT_LINE( "P05 NEW_LINE" );

  C_IO.PUT( F, VERT, 6 );
  PUT_LINE( "P06 C_IO.PUT VERT" );

  NEW_LINE( F );
  PUT_LINE( "P07 NEW_LINE" );

  CLOSE( F );
  PUT_LINE( "P08 CLOSE" );

  OPEN( F, IN_FILE, "TEXT14P.TXT" );
  PUT_LINE( "P09 OPEN IN_FILE" );

  GET( F, C );
  PUT( "P10 GET -> " );  PUT( C );  NEW_LINE;

  GET( F, C );
  PUT( "P11 GET -> " );  PUT( C );  NEW_LINE;

  GET( F, C );
  PUT( "P12 GET -> " );  PUT( C );  NEW_LINE;

  if  END_OF_LINE( F )  then
    PUT_LINE( "P13 EOL VRAI (attendu)" );
  else
    PUT_LINE( "P13 EOL FAUX (ANORMAL)" );
  end if;

  GET( F, S2 );
  PUT( "P14 GET S2 -> " );  PUT( S2 );  NEW_LINE;

  I_IO.GET( F, N );
  PUT( "P15 I_IO.GET -> " );  I_IO.PUT( N, 1 );  NEW_LINE;

  GET_LINE( F, BUF, LST );
  PUT( "P16 GET_LINE LST = " );  I_IO.PUT( LST, 1 );  NEW_LINE;

  GET_LINE( F, BUF, LST );
  PUT( "P17 GET_LINE [" );
  if  LST >= 1  then
    PUT( BUF( 1 .. LST ) );
  end if;
  PUT_LINE( "]" );

  if  END_OF_FILE( F )  then
    PUT_LINE( "P18 EOF VRAI (attendu)" );
  else
    PUT_LINE( "P18 EOF FAUX (ANORMAL)" );
  end if;

  begin
    GET( F, C );
    PUT_LINE( "P19 pas d'exception (ANORMAL)" );
  exception
    when END_ERROR	=> PUT_LINE( "P19 END_ERROR (attendu)" );
    when others		=> PUT_LINE( "P19 autre exception (ANORMAL)" );
  end;

  DELETE( F );
  PUT_LINE( "P20 DELETE, fin" );

end	TEXT14P;
	-------
