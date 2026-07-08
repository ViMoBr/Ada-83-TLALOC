with TEXT_IO;	use TEXT_IO;
					------
procedure				TEXT14
is					------

  -- Temoin du lot TEXT_IO / LRM chapitre 14 (session 8 juillet 2026).
  -- Auto-jugeant : compte OK/ECHECS, verdict greppable "TEXT14 PASSE".
  --
  -- Couvre : comptabilite COL/LINE/PAGE en sortie, coupure implicite a
  -- LINE_LENGTH bornee, SET_COL/SET_LINE (sortie), LAYOUT_ERROR de mise
  -- en page, relecture a travers les terminateurs (GET public), le
  -- look-ahead arme par END_OF_LINE puis traverse par GET(STRING)
  -- (ancien bug du chemin de lecture en bloc), scanners INTEGER_IO et
  -- ENUMERATION_IO sur fichier, cadrage a gauche de l'enumere avec
  -- WIDTH (blancs de queue, RM 14.3.9), END_ERROR, NAME_ERROR,
  -- STATUS_ERROR, MODE_ERROR, DATA_ERROR (fichier et chaine),
  -- LAYOUT_ERROR des PUT vers chaine.

  N_OK		: NATURAL		:= 0;
  N_KO		: NATURAL		:= 0;

  package	I_IO	is new INTEGER_IO( INTEGER );

  type COULEUR	is ( ROUGE, VERT, BLEU );
  package	C_IO	is new ENUMERATION_IO( COULEUR );

  F1		: FILE_TYPE;
  F2		: FILE_TYPE;

		-----
  procedure	CHECK	( LABEL :in STRING; COND :in BOOLEAN )
  is		-----
  begin
    if  COND  then
      N_OK := N_OK + 1;
    else
      N_KO := N_KO + 1;
      PUT( "* ECHEC " );
      PUT_LINE( LABEL );
    end if;

  end	CHECK;
	-----

begin

  ------------------------------------------------------------------
  PUT_LINE( "=== U1. Comptabilite COL/LINE en sortie ===" );
  ------------------------------------------------------------------

  CREATE( F1, OUT_FILE, "TEXT14_A.TXT" );
  CHECK( "U1.1 COL initiale",  COL( F1 )  = 1 );
  CHECK( "U1.2 LINE initiale", LINE( F1 ) = 1 );
  CHECK( "U1.3 PAGE initiale", PAGE( F1 ) = 1 );

  PUT( F1, "ABC" );
  CHECK( "U1.4 COL apres PUT chaine", COL( F1 ) = 4 );

  NEW_LINE( F1 );
  CHECK( "U1.5 COL apres NEW_LINE",  COL( F1 )  = 1 );
  CHECK( "U1.6 LINE apres NEW_LINE", LINE( F1 ) = 2 );

  PUT( F1, 'Z' );
  CHECK( "U1.7 COL apres PUT caractere", COL( F1 ) = 2 );
  NEW_LINE( F1 );

  ------------------------------------------------------------------
  PUT_LINE( "=== U2. SET_COL en sortie (avant / arriere) ===" );
  ------------------------------------------------------------------

  SET_COL( F1, 8 );
  CHECK( "U2.1 SET_COL en avant", COL( F1 ) = 8 );
  PUT( F1, 'X' );
  CHECK( "U2.2 COL apres X", COL( F1 ) = 9 );

  SET_COL( F1, 3 );							-- en arriere : NEW_LINE implicite
  CHECK( "U2.3 SET_COL en arriere, COL",  COL( F1 )  = 3 );
  CHECK( "U2.4 SET_COL en arriere, LINE", LINE( F1 ) = 4 );

  ------------------------------------------------------------------
  PUT_LINE( "=== U3. Coupure implicite a LINE_LENGTH bornee ===" );
  ------------------------------------------------------------------

  SET_LINE_LENGTH( F1, 5 );
  CHECK( "U3.1 LINE_LENGTH lue", LINE_LENGTH( F1 ) = 5 );

  PUT( F1, "ABCDEFGHIJKL" );						-- part de COL=3, coupe a 5
  CHECK( "U3.2 LINE apres coupures", LINE( F1 ) = 6 );
  CHECK( "U3.3 COL apres coupures",  COL( F1 )  = 5 );

  begin
    SET_COL( F1, 9 );							-- 9 > longueur de ligne bornee
    CHECK( "U3.4 LAYOUT_ERROR SET_COL", FALSE );
  exception
    when LAYOUT_ERROR	=> CHECK( "U3.4 LAYOUT_ERROR SET_COL", TRUE );
    when others		=> CHECK( "U3.4 LAYOUT_ERROR SET_COL", FALSE );
  end;

  SET_LINE_LENGTH( F1, 0 );						-- retour au non borne

  ------------------------------------------------------------------
  PUT_LINE( "=== U4. SET_LINE en sortie et longueur de page ===" );
  ------------------------------------------------------------------

  SET_LINE( F1, 9 );
  CHECK( "U4.1 SET_LINE en avant", LINE( F1 ) = 9 );
  CHECK( "U4.2 COL remise a 1",    COL( F1 )  = 1 );

  SET_PAGE_LENGTH( F1, 10 );
  SET_LINE( F1, 3 );							-- en arriere : NEW_PAGE implicite
  CHECK( "U4.3 SET_LINE arriere, PAGE", PAGE( F1 ) = 2 );
  CHECK( "U4.4 SET_LINE arriere, LINE", LINE( F1 ) = 3 );

  begin
    SET_LINE( F1, 12 );							-- 12 > longueur de page bornee
    CHECK( "U4.5 LAYOUT_ERROR SET_LINE", FALSE );
  exception
    when LAYOUT_ERROR	=> CHECK( "U4.5 LAYOUT_ERROR SET_LINE", TRUE );
    when others		=> CHECK( "U4.5 LAYOUT_ERROR SET_LINE", FALSE );
  end;

  SET_PAGE_LENGTH( F1, 0 );
  DELETE( F1 );

  ------------------------------------------------------------------
  PUT_LINE( "=== U5. Relecture : GET a travers les terminateurs ===" );
  ------------------------------------------------------------------

  CREATE( F2, OUT_FILE, "TEXT14_B.TXT" );
  PUT_LINE( F2, "ABC" );
  PUT_LINE( F2, "DE" );
  I_IO.PUT( F2, 42, 1 );
  NEW_LINE( F2 );
  C_IO.PUT( F2, VERT, 6 );						-- image + blancs de QUEUE (RM 14.3.9)
  NEW_LINE( F2 );
  CLOSE( F2 );

  OPEN( F2, IN_FILE, "TEXT14_B.TXT" );

  declare
    C1, C2, C3	: CHARACTER;
    S2		: STRING( 1 .. 2 );
    BUF		: STRING( 1 .. 40 );
    LST		: NATURAL;
    N		: INTEGER;
  begin
    GET( F2, C1 );
    GET( F2, C2 );
    GET( F2, C3 );
    CHECK( "U5.1 trois caracteres", C1 = 'A' and C2 = 'B' and C3 = 'C' );

    CHECK( "U5.2 END_OF_LINE arme le look-ahead", END_OF_LINE( F2 ) );

    GET( F2, S2 );							-- traverse CR LF malgre le look-ahead
    CHECK( "U5.3 GET(STRING) apres END_OF_LINE", S2 = "DE" );

    I_IO.GET( F2, N );							-- le scanner saute les terminateurs
    CHECK( "U5.4 scanner entier sur fichier", N = 42 );

    GET_LINE( F2, BUF, LST );						-- solde du reste de la ligne du 42
    CHECK( "U5.5 solde de ligne vide", LST = 0 );

    GET_LINE( F2, BUF, LST );
    CHECK( "U5.6 cadrage enum a gauche",
           LST = 6  and then  BUF( 1 .. 6 ) = "VERT  " );

    CHECK( "U5.7 END_OF_FILE en fin de donnees", END_OF_FILE( F2 ) );

    begin
      GET( F2, C1 );
      CHECK( "U5.8 END_ERROR au terminateur de fichier", FALSE );
    exception
      when END_ERROR	=> CHECK( "U5.8 END_ERROR au terminateur de fichier", TRUE );
      when others	=> CHECK( "U5.8 END_ERROR au terminateur de fichier", FALSE );
    end;
  end;

  ------------------------------------------------------------------
  PUT_LINE( "=== U6. Gardes de mode et d'etat ===" );
  ------------------------------------------------------------------

  begin
    PUT( F2, 'x' );							-- F2 est en IN_FILE
    CHECK( "U6.1 MODE_ERROR PUT sur IN_FILE", FALSE );
  exception
    when MODE_ERROR	=> CHECK( "U6.1 MODE_ERROR PUT sur IN_FILE", TRUE );
    when others		=> CHECK( "U6.1 MODE_ERROR PUT sur IN_FILE", FALSE );
  end;

  begin
    SET_LINE_LENGTH( F2, 5 );						-- illegale en entree
    CHECK( "U6.2 MODE_ERROR SET_LINE_LENGTH", FALSE );
  exception
    when MODE_ERROR	=> CHECK( "U6.2 MODE_ERROR SET_LINE_LENGTH", TRUE );
    when others		=> CHECK( "U6.2 MODE_ERROR SET_LINE_LENGTH", FALSE );
  end;

  DELETE( F2 );

  begin
    CLOSE( F2 );							-- deja fermee par DELETE
    CHECK( "U6.3 STATUS_ERROR CLOSE ferme", FALSE );
  exception
    when STATUS_ERROR	=> CHECK( "U6.3 STATUS_ERROR CLOSE ferme", TRUE );
    when others		=> CHECK( "U6.3 STATUS_ERROR CLOSE ferme", FALSE );
  end;

  begin
    OPEN( F2, IN_FILE, "TEXT14_N_EXISTE_PAS.TXT" );
    CHECK( "U6.4 NAME_ERROR OPEN inexistant", FALSE );
  exception
    when NAME_ERROR	=> CHECK( "U6.4 NAME_ERROR OPEN inexistant", TRUE );
    when others		=> CHECK( "U6.4 NAME_ERROR OPEN inexistant", FALSE );
  end;

  ------------------------------------------------------------------
  PUT_LINE( "=== U7. DATA_ERROR et LAYOUT_ERROR des variantes chaine ===" );
  ------------------------------------------------------------------

  declare
    N		: INTEGER;
    CV		: COULEUR;
    LST		: POSITIVE;
    S2		: STRING( 1 .. 2 );
    S6		: STRING( 1 .. 6 );
  begin
    begin
      I_IO.GET( "2#9#", N, LST );					-- chiffre incompatible avec la base
      CHECK( "U7.1 DATA_ERROR chiffre hors base", FALSE );
    exception
      when DATA_ERROR	=> CHECK( "U7.1 DATA_ERROR chiffre hors base", TRUE );
      when others	=> CHECK( "U7.1 DATA_ERROR chiffre hors base", FALSE );
    end;

    begin
      I_IO.GET( "  xyz", N, LST );					-- aucun chiffre
      CHECK( "U7.2 DATA_ERROR image sans chiffre", FALSE );
    exception
      when DATA_ERROR	=> CHECK( "U7.2 DATA_ERROR image sans chiffre", TRUE );
      when others	=> CHECK( "U7.2 DATA_ERROR image sans chiffre", FALSE );
    end;

    begin
      C_IO.GET( "ZUT", CV, LST );					-- image enum inconnue
      CHECK( "U7.3 DATA_ERROR enum inconnu", FALSE );
    exception
      when DATA_ERROR	=> CHECK( "U7.3 DATA_ERROR enum inconnu", TRUE );
      when others	=> CHECK( "U7.3 DATA_ERROR enum inconnu", FALSE );
    end;

    begin
      I_IO.PUT( S2, 12345 );						-- champ trop court
      CHECK( "U7.4 LAYOUT_ERROR PUT entier", FALSE );
    exception
      when LAYOUT_ERROR	=> CHECK( "U7.4 LAYOUT_ERROR PUT entier", TRUE );
      when others	=> CHECK( "U7.4 LAYOUT_ERROR PUT entier", FALSE );
    end;

    C_IO.PUT( S6, BLEU );
    CHECK( "U7.5 PUT enum vers chaine, blancs de queue", S6 = "BLEU  " );

    C_IO.GET( "  vert reste", CV, LST );
    CHECK( "U7.6 GET enum depuis chaine", CV = VERT and LST = 6 );
  end;

  ------------------------------------------------------------------
  PUT_LINE( "=== U8. Cas residuels LRM : FF, null string, DATA_ERROR fichier ===" );
  ------------------------------------------------------------------

  -- PUT d'une chaine nulle : doit ne rien faire, sans exception.
  declare
    S0 : STRING( 1 .. 0 );
  begin
    CREATE( F1, OUT_FILE, "TEXT14_NULL.TXT" );
    PUT( F1, S0 );
    CHECK( "U8.1 PUT chaine nulle", COL( F1 ) = 1 );
    DELETE( F1 );
  exception
    when others =>
      CHECK( "U8.1 PUT chaine nulle", FALSE );
  end;

-- DATA_ERROR sur scanner entier fichier.
  CREATE( F1, OUT_FILE, "TEXT14_BADINT.TXT" );
  PUT( F1, "xyz" );
  CLOSE( F1 );
  OPEN( F1, IN_FILE, "TEXT14_BADINT.TXT" );
  declare
    N : INTEGER;
  begin
    begin
      I_IO.GET( F1, N );
      CHECK( "U8.2 DATA_ERROR entier fichier", FALSE );
    exception
      when DATA_ERROR =>
        CHECK( "U8.2 DATA_ERROR entier fichier", TRUE );
      when others =>
        CHECK( "U8.2 DATA_ERROR entier fichier", FALSE );
    end;
  end;
  DELETE( F1 );

-- FF devant un entier : le scanner doit sauter le terminateur de page.
  CREATE( F1, OUT_FILE, "TEXT14_FFINT.TXT" );
  NEW_PAGE( F1 );
  I_IO.PUT( F1, 17, 1 );
  CLOSE( F1 );
  OPEN( F1, IN_FILE, "TEXT14_FFINT.TXT" );
  declare
    N : INTEGER;
  begin
    I_IO.GET( F1, N );
    CHECK( "U8.3 scanner entier apres FF", N = 17 );
  end;
  DELETE( F1 );

  CREATE( F1, OUT_FILE, "TEXT14_FFEOL.TXT" );
  NEW_PAGE( F1 );
  PUT( F1, "X" );
  CLOSE( F1 );
  OPEN( F1, IN_FILE, "TEXT14_FFEOL.TXT" );
  CHECK( "U8.4 END_OF_LINE sur FF", END_OF_LINE( F1 ) );
  DELETE( F1 );

  ------------------------------------------------------------------
  -- Verdict
  ------------------------------------------------------------------

  NEW_LINE;
  PUT( "RESULTAT : " );
  I_IO.PUT( N_OK, 3 );
  PUT( " OK, " );
  I_IO.PUT( N_KO, 3 );
  PUT_LINE( " ECHECS" );

  if  N_KO = 0  then
    PUT_LINE( "TEXT14 PASSE" );
  else
    PUT_LINE( "TEXT14 ECHOUE" );
  end if;

end	TEXT14;
	------
