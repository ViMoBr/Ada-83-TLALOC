with TEXT_IO; use TEXT_IO;
with SEQUENTIAL_IO;
			-----------
procedure			SEQ_IO_TEST
is			-----------

  --
  --  Temoin auto-jugeant de SEQUENTIAL_IO (forme canonique ENUM_TEST/TEXT14).
  --  Oracle du filet = la ligne "SEQ_IO_TEST PASSE".
  --  50 assertions, 7 sections :
  --    1  COULEUR   : create/write/close, open/MODE/IS_OPEN, roundtrip
  --                   sequentiel complet, EOF apres le dernier element
  --    2  POINT     : roundtrip record + EOF
  --    3  VECTEUR   : roundtrip tableau + EOF
  --    4  Boucle while not END_OF_FILE (idiome sur, positions exactes)
  --    5  RESET     : rembobinage simple, puis RESET avec changement de
  --                   mode (IN -> OUT reecriture complete -> IN relecture)
  --    6  Exceptions : END_ERROR (lecture apres le dernier element,
  --                   element TRONQUE - verrou du fossile SD -32/-40),
  --                   MODE_ERROR (READ sur OUT, END_OF_FILE sur OUT,
  --                   WRITE sur IN), STATUS_ERROR (READ/RESET/MODE fermes)
  --    7  DELETE (juge par IS_OPEN apres tentative de re-OPEN ;
  --                   NAME_ERROR accepte pour le futur lot 14.2.1)
  --  Non asserte (dette 14.2.1) : CREATE/OPEN sur fichier deja ouvert,
  --  echec d'OPEN -> NAME_ERROR, CLOSE/DELETE sur fichier ferme.
  --  Note visibilite : les comparaisons de FILE_MODE exigent un
  --  "use <instance>" local — l'egalite predefinie de FILE_MODE est
  --  declaree DANS l'instance et n'est pas directement visible a
  --  l'exterieur (LRM 8.4(5) ; l'infixe ne se qualifie pas). Le
  --  frontend est conforme.
  --

  --
  --  Types de test
  --

  type COULEUR		is (ROUGE, VERT, BLEU, BLANC, NOIR);

  type POINT is record
    X : INTEGER;
    Y : INTEGER;
    Z : INTEGER;
  end record;

  type VECTEUR		is array( 1 .. 4 ) of INTEGER;

  --
  --  Instances
  --

  package INT_IO      is new INTEGER_IO( INTEGER );		use INT_IO;
  package CLR_SIO     is new SEQUENTIAL_IO( COULEUR );
  package POINT_SIO   is new SEQUENTIAL_IO( POINT );
  package VEC_SIO     is new SEQUENTIAL_IO( VECTEUR );

  --
  --  Fichiers
  --

  FC      : CLR_SIO.FILE_TYPE;
  FC_MODE : CLR_SIO.FILE_MODE;
  FP      : POINT_SIO.FILE_TYPE;
  FV      : VEC_SIO.FILE_TYPE;

  --
  --  Donnees de test
  --

  C1   : COULEUR  := ROUGE;
  C2   : COULEUR  := BLEU;
  C3   : COULEUR  := BLANC;
  C4   : COULEUR  := NOIR;
  C5   : COULEUR  := VERT;

  P1   : POINT    := ( X =>  1,  Y =>  2,  Z =>  3 );
  P2   : POINT    := ( X => 16,  Y => 32,  Z => 64 );
  P3   : POINT    := ( X => -5,  Y =>  0,  Z => 99 );

  V1   : VECTEUR  := ( 11, 22, 33, 44 );
  V2   : VECTEUR  := ( 55, 66, 77, 88 );
  V3   : VECTEUR  := ( -1, -2, -3, -4 );

  --
  --  Variables de lecture
  --

  RC   : COULEUR  := VERT;
  RP   : POINT    := ( X => 0, Y => 0, Z => 0 );
  RV   : VECTEUR  := ( 0, 0, 0, 0 );

  --
  --  Auto-jugement (forme canonique du 5 juillet 2026)
  --

  NB_OK     : INTEGER := 0;
  NB_ECHECS : INTEGER := 0;

  procedure CHECK( OK : in BOOLEAN; SECTION : in INTEGER; NUMERO : in INTEGER ) is
  begin
    if OK then
      NB_OK := NB_OK + 1;
    else
      NB_ECHECS := NB_ECHECS + 1;
      PUT( "* ECHEC section" ); PUT( SECTION, 3 );
      PUT( " test" );           PUT( NUMERO, 3 );  NEW_LINE;
    end if;
  end CHECK;

begin

  -- ---------------------------------------------------------------
  PUT_LINE( "=== 1. SEQUENTIAL_IO sur type enumere COULEUR ===" );
  -- ---------------------------------------------------------------

  CLR_SIO.CREATE( FC, CLR_SIO.OUT_FILE, "couleur_seq.dat" );
  PUT( "  COULEUR'SIZE = " ); PUT( COULEUR'SIZE ); PUT_LINE( " bits (info)" );

  CLR_SIO.WRITE( FC, C1 );
  CLR_SIO.WRITE( FC, C2 );
  CLR_SIO.WRITE( FC, C3 );
  CLR_SIO.WRITE( FC, C4 );
  CLR_SIO.WRITE( FC, C5 );

  CLR_SIO.CLOSE( FC );
  CHECK( not CLR_SIO.IS_OPEN( FC ),                1,  1 );	-- IS_OPEN apres CLOSE

  CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "couleur_seq.dat" );
  CHECK( CLR_SIO.IS_OPEN( FC ),                    1,  2 );	-- IS_OPEN apres OPEN

  declare
    use CLR_SIO;			-- visibilite de "=" sur FILE_MODE (LRM 8.4)
  begin
    CHECK( CLR_SIO.MODE( FC ) = CLR_SIO.IN_FILE,   1,  3 );	-- MODE
  end;

  CLR_SIO.READ( FC, RC );  CHECK( RC = ROUGE,      1,  4 );
  CLR_SIO.READ( FC, RC );  CHECK( RC = BLEU,       1,  5 );
  CLR_SIO.READ( FC, RC );  CHECK( RC = BLANC,      1,  6 );
  CLR_SIO.READ( FC, RC );  CHECK( RC = NOIR,       1,  7 );
  CLR_SIO.READ( FC, RC );  CHECK( RC = VERT,       1,  8 );
  CHECK( CLR_SIO.END_OF_FILE( FC ),                1,  9 );	-- EOF apres le dernier

  CLR_SIO.CLOSE( FC );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 2. SEQUENTIAL_IO sur record POINT ===" );
  -- ---------------------------------------------------------------

  POINT_SIO.CREATE( FP, POINT_SIO.OUT_FILE, "point_seq.dat" );
  PUT( "  POINT'SIZE = " ); PUT( POINT'SIZE ); PUT_LINE( " bits (info)" );

  POINT_SIO.WRITE( FP, P1 );
  POINT_SIO.WRITE( FP, P2 );
  POINT_SIO.WRITE( FP, P3 );
  POINT_SIO.CLOSE( FP );

  POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "point_seq.dat" );

  POINT_SIO.READ( FP, RP );  CHECK( RP = P1,       2,  1 );
  POINT_SIO.READ( FP, RP );  CHECK( RP = P2,       2,  2 );
  POINT_SIO.READ( FP, RP );  CHECK( RP = P3,       2,  3 );
  CHECK( POINT_SIO.END_OF_FILE( FP ),              2,  4 );

  POINT_SIO.CLOSE( FP );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 3. SEQUENTIAL_IO sur tableau VECTEUR ===" );
  -- ---------------------------------------------------------------

  VEC_SIO.CREATE( FV, VEC_SIO.OUT_FILE, "vec_seq.dat" );
  PUT( "  VECTEUR'SIZE = " ); PUT( VECTEUR'SIZE ); PUT_LINE( " bits (info)" );

  VEC_SIO.WRITE( FV, V1 );
  VEC_SIO.WRITE( FV, V2 );
  VEC_SIO.WRITE( FV, V3 );
  VEC_SIO.CLOSE( FV );

  VEC_SIO.OPEN( FV, VEC_SIO.IN_FILE, "vec_seq.dat" );

  VEC_SIO.READ( FV, RV );  CHECK( RV = V1,         3,  1 );
  VEC_SIO.READ( FV, RV );  CHECK( RV = V2,         3,  2 );
  VEC_SIO.READ( FV, RV );  CHECK( RV = V3,         3,  3 );
  CHECK( VEC_SIO.END_OF_FILE( FV ),                3,  4 );

  VEC_SIO.CLOSE( FV );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 4. Boucle while not END_OF_FILE (sur POINT) ===" );
  -- ---------------------------------------------------------------
			-- Idiome SUR pour SEQUENTIAL_IO : END_OF_FILE compare
			-- des positions exactes, pas de look-ahead d'un
			-- caractere (contra piege n. 79 de TEXT_IO)

  POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "point_seq.dat" );

  CHECK( not POINT_SIO.END_OF_FILE( FP ),          4,  1 );	-- EOF au debut

  declare
    IDX : INTEGER := 1;
  begin
    while not POINT_SIO.END_OF_FILE( FP ) loop
      POINT_SIO.READ( FP, RP );
      if    IDX = 1 then CHECK( RP = P1,           4,  2 );
      elsif IDX = 2 then CHECK( RP = P2,           4,  3 );
      elsif IDX = 3 then CHECK( RP = P3,           4,  4 );
      end if;
      IDX := IDX + 1;
    end loop;
    CHECK( IDX = 4,                                4,  5 );	-- exactement 3 elements lus
  end;

  CHECK( POINT_SIO.END_OF_FILE( FP ),              4,  6 );	-- EOF apres la boucle
  POINT_SIO.CLOSE( FP );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 5. RESET ===" );
  -- ---------------------------------------------------------------

			-- 5a. Rembobinage simple en lecture
  POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "point_seq.dat" );

  POINT_SIO.READ( FP, RP );
  CHECK( RP = P1,                                  5,  1 );	-- avant RESET
  POINT_SIO.RESET( FP );
  POINT_SIO.READ( FP, RP );
  CHECK( RP = P1,                                  5,  2 );	-- relu depuis le debut
  POINT_SIO.READ( FP, RP );
  CHECK( RP = P2,                                  5,  3 );	-- la sequence continue

  POINT_SIO.CLOSE( FP );

			-- 5b. RESET avec changement de mode : IN -> OUT
			-- (reecriture COMPLETE des 5 elements, en ordre inverse,
			-- pour ne pas dependre d'une eventuelle troncature) -> IN
  CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "couleur_seq.dat" );

  CLR_SIO.RESET( FC, CLR_SIO.OUT_FILE );
  declare
    use CLR_SIO;			-- visibilite de "=" sur FILE_MODE (LRM 8.4)
  begin
    CHECK( CLR_SIO.MODE( FC ) = CLR_SIO.OUT_FILE,  5,  4 );
  end;

  CLR_SIO.WRITE( FC, C5 );
  CLR_SIO.WRITE( FC, C4 );
  CLR_SIO.WRITE( FC, C3 );
  CLR_SIO.WRITE( FC, C2 );
  CLR_SIO.WRITE( FC, C1 );

  CLR_SIO.RESET( FC, CLR_SIO.IN_FILE );
  declare
    use CLR_SIO;
  begin
    CHECK( CLR_SIO.MODE( FC ) = CLR_SIO.IN_FILE,   5,  5 );
  end;

  CLR_SIO.READ( FC, RC );  CHECK( RC = VERT,       5,  6 );
  CLR_SIO.READ( FC, RC );  CHECK( RC = NOIR,       5,  7 );
  CLR_SIO.READ( FC, RC );  CHECK( RC = BLANC,      5,  8 );
  CLR_SIO.READ( FC, RC );  CHECK( RC = BLEU,       5,  9 );
  CLR_SIO.READ( FC, RC );  CHECK( RC = ROUGE,      5, 10 );
  CHECK( CLR_SIO.END_OF_FILE( FC ),                5, 11 );

  CLR_SIO.CLOSE( FC );
			-- couleur_seq.dat vaut desormais VERT NOIR BLANC BLEU ROUGE


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 6. Exceptions ===" );
  -- ---------------------------------------------------------------

			-- 6.1 END_ERROR : lecture apres le dernier element
  CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "couleur_seq.dat" );
  for I in 1 .. 5 loop
    CLR_SIO.READ( FC, RC );
  end loop;
  begin
    CLR_SIO.READ( FC, RC );
    CHECK( FALSE,                                  6,  1 );
  exception
    when CLR_SIO.END_ERROR => CHECK( TRUE,         6,  1 );
    when others            => CHECK( FALSE,        6,  1 );
  end;
  CLR_SIO.CLOSE( FC );

			-- 6.2 END_ERROR : element TRONQUE (fichier de 5 octets
			-- ouvert comme fichier de POINT ; BYTES_READ < SIZE_BYTES
			-- — verrou du fossile SD -32/-40)
  POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "couleur_seq.dat" );
  begin
    POINT_SIO.READ( FP, RP );
    CHECK( FALSE,                                  6,  2 );
  exception
    when POINT_SIO.END_ERROR => CHECK( TRUE,       6,  2 );
    when others              => CHECK( FALSE,      6,  2 );
  end;
  POINT_SIO.CLOSE( FP );

			-- 6.3 MODE_ERROR : READ sur OUT_FILE
  CLR_SIO.CREATE( FC, CLR_SIO.OUT_FILE, "scratch_seq.dat" );
  CLR_SIO.WRITE( FC, C1 );
  begin
    CLR_SIO.READ( FC, RC );
    CHECK( FALSE,                                  6,  3 );
  exception
    when CLR_SIO.MODE_ERROR => CHECK( TRUE,        6,  3 );
    when others             => CHECK( FALSE,       6,  3 );
  end;

			-- 6.4 MODE_ERROR : END_OF_FILE sur OUT_FILE
  begin
    if CLR_SIO.END_OF_FILE( FC ) then
      CHECK( FALSE,                                6,  4 );
    else
      CHECK( FALSE,                                6,  4 );
    end if;
  exception
    when CLR_SIO.MODE_ERROR => CHECK( TRUE,        6,  4 );
    when others             => CHECK( FALSE,       6,  4 );
  end;
  CLR_SIO.CLOSE( FC );

			-- 6.5 MODE_ERROR : WRITE sur IN_FILE
  CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "scratch_seq.dat" );
  begin
    CLR_SIO.WRITE( FC, C1 );
    CHECK( FALSE,                                  6,  5 );
  exception
    when CLR_SIO.MODE_ERROR => CHECK( TRUE,        6,  5 );
    when others             => CHECK( FALSE,       6,  5 );
  end;
  CLR_SIO.CLOSE( FC );

			-- 6.6 STATUS_ERROR : READ sur fichier ferme
  begin
    CLR_SIO.READ( FC, RC );
    CHECK( FALSE,                                  6,  6 );
  exception
    when CLR_SIO.STATUS_ERROR => CHECK( TRUE,      6,  6 );
    when others               => CHECK( FALSE,     6,  6 );
  end;

			-- 6.7 STATUS_ERROR : RESET sur fichier ferme
  begin
    CLR_SIO.RESET( FC );
    CHECK( FALSE,                                  6,  7 );
  exception
    when CLR_SIO.STATUS_ERROR => CHECK( TRUE,      6,  7 );
    when others               => CHECK( FALSE,     6,  7 );
  end;

			-- 6.8 STATUS_ERROR : MODE sur fichier ferme
  begin
    FC_MODE := CLR_SIO.MODE( FC );
    CHECK( FALSE,                                  6,  8 );
  exception
    when CLR_SIO.STATUS_ERROR => CHECK( TRUE,      6,  8 );
    when others               => CHECK( FALSE,     6,  8 );
  end;


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 7. DELETE ===" );
  -- ---------------------------------------------------------------
			-- Juge de suppression : la tentative de re-OPEN echoue.
			-- Regime actuel : echec d'OPEN SILENCIEUX -> IS_OPEN FALSE
			-- (dette 14.2.1) ; le handler NAME_ERROR accepte d'avance
			-- le regime futur du lot de gardes.

  CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "scratch_seq.dat" );
  CLR_SIO.DELETE( FC );
  CHECK( not CLR_SIO.IS_OPEN( FC ),                7,  1 );
  begin
    CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "scratch_seq.dat" );
    CHECK( not CLR_SIO.IS_OPEN( FC ),              7,  2 );
  exception
    when CLR_SIO.NAME_ERROR => CHECK( TRUE,        7,  2 );
  end;

  CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "couleur_seq.dat" );
  CLR_SIO.DELETE( FC );
  CHECK( not CLR_SIO.IS_OPEN( FC ),                7,  3 );
  begin
    CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "couleur_seq.dat" );
    CHECK( not CLR_SIO.IS_OPEN( FC ),              7,  4 );
  exception
    when CLR_SIO.NAME_ERROR => CHECK( TRUE,        7,  4 );
  end;

  POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "point_seq.dat" );
  POINT_SIO.DELETE( FP );
  CHECK( not POINT_SIO.IS_OPEN( FP ),              7,  5 );
  begin
    POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "point_seq.dat" );
    CHECK( not POINT_SIO.IS_OPEN( FP ),            7,  6 );
  exception
    when POINT_SIO.NAME_ERROR => CHECK( TRUE,      7,  6 );
  end;

  VEC_SIO.OPEN( FV, VEC_SIO.IN_FILE, "vec_seq.dat" );
  VEC_SIO.DELETE( FV );
  CHECK( not VEC_SIO.IS_OPEN( FV ),                7,  7 );
  begin
    VEC_SIO.OPEN( FV, VEC_SIO.IN_FILE, "vec_seq.dat" );
    CHECK( not VEC_SIO.IS_OPEN( FV ),              7,  8 );
  exception
    when VEC_SIO.NAME_ERROR => CHECK( TRUE,        7,  8 );
  end;


  -- ---------------------------------------------------------------
  --  Verdict
  -- ---------------------------------------------------------------

  NEW_LINE;
  PUT( "RESULTAT : " ); PUT( NB_OK, 3 );
  PUT( " OK, " );       PUT( NB_ECHECS, 3 );
  PUT( " ECHECS" );     NEW_LINE;
  if NB_ECHECS = 0 then
    PUT_LINE( "SEQ_IO_TEST PASSE" );
  else
    PUT_LINE( "SEQ_IO_TEST ECHOUE" );
  end if;

end	SEQ_IO_TEST;
	-----------
