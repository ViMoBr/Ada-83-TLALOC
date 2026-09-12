with TEXT_IO; use TEXT_IO;
with DIRECT_IO;
			--------------
procedure			DIRECT_IO_TEST
is			--------------

  --
  --  Temoin auto-jugeant de DIRECT_IO (forme canonique ENUM_TEST/TEXT14).
  --  Oracle du filet = la ligne "DIRECT_IO_TEST PASSE".
  --  65 assertions, 9 sections :
  --    1  COULEUR   : create/write/SIZE/close, open/MODE, lectures seq
  --                   et positionnees, roundtrip valeurs
  --    2  POINT     : roundtrip record, EOF apres lecture complete,
  --                   INDEX apres lecture positionnee
  --    3  VECTEUR   : roundtrip tableau, seq + positionne
  --    4  SET_INDEX / INDEX / END_OF_FILE
  --    5  RESET + reecriture partielle INOUT (agregat qualifie en actual)
  --    6  Boucle while not END_OF_FILE (idiome sur, positions exactes)
  --    7  WRITE positionne au-dela de la fin : extension + trou a zero
  --    8  Exceptions : END_ERROR (seq a EOF, positionne hors fichier,
  --                   element TRONQUE), MODE_ERROR (READ sur OUT,
  --                   END_OF_FILE sur OUT, WRITE sur IN),
  --                   STATUS_ERROR (READ/SIZE/RESET fichier ferme)
  --    9  DELETE (juge par IS_OPEN apres tentative de re-OPEN ;
  --                   NAME_ERROR accepte pour le futur lot 14.2.1)
  --  Non asserte (dette 14.2.1, gardes absentes du package) :
  --  CREATE/OPEN sur fichier deja ouvert -> STATUS_ERROR ; echec
  --  d'OPEN -> NAME_ERROR ; CLOSE/DELETE sur fichier ferme -> STATUS_ERROR.
  --

  --
  --  Types de test
  --

  type COULEUR	is (ROUGE, VERT, BLEU, BLANC, NOIR);

  type POINT is record
    X : INTEGER;
    Y : INTEGER;
    Z : INTEGER;
  end record;

  type VECTEUR	is array( 1 .. 4 ) of INTEGER;

  --
  --  Instances
  --

  package INT_IO      is new INTEGER_IO( INTEGER );		use INT_IO;
  package CLR_DIO     is new DIRECT_IO( COULEUR );
  package POINT_DIO   is new DIRECT_IO( POINT );
  package VEC_DIO     is new DIRECT_IO( VECTEUR );

  --
  --  Fichiers
  --

  FC   : CLR_DIO.FILE_TYPE;
  FP   : POINT_DIO.FILE_TYPE;
  FV   : VEC_DIO.FILE_TYPE;

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
  P4   : POINT    := ( X => 42,  Y => -1,  Z =>  7 );

  P_NEW  : POINT  := ( X => 777, Y => 888, Z => 999 );
  P_NEG  : POINT  := ( X => -42, Y => -42, Z => -42 );

  V1   : VECTEUR  := ( 11, 22, 33, 44 );
  V2   : VECTEUR  := ( 55, 66, 77, 88 );
  V3   : VECTEUR  := ( -1, -2, -3, -4 );
  V_ZERO : VECTEUR := ( 0, 0, 0, 0 );

  --
  --  Variables de lecture
  --

  RC      : COULEUR  := VERT;
  RP      : POINT    := ( X => 0, Y => 0, Z => 0 );
  RV      : VECTEUR  := ( 0, 0, 0, 0 );
  DUMMY_B : BOOLEAN  := FALSE;
  DUMMY_N : INTEGER  := 0;

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
  PUT_LINE( "=== 1. DIRECT_IO sur type enumere COULEUR ===" );
  -- ---------------------------------------------------------------

  CLR_DIO.CREATE( FC, CLR_DIO.OUT_FILE, "couleur_direct.dat" );
  PUT( "  COULEUR'SIZE = " ); PUT( COULEUR'SIZE ); PUT_LINE( " bits (info)" );

  CLR_DIO.WRITE( FC, C1 );
  CLR_DIO.WRITE( FC, C2 );
  CLR_DIO.WRITE( FC, C3 );
  CLR_DIO.WRITE( FC, C4 );
  CLR_DIO.WRITE( FC, C5 );

  CHECK( INTEGER( CLR_DIO.SIZE( FC ) ) = 5,      1,  1 );	-- SIZE apres 5 writes

  CLR_DIO.CLOSE( FC );
  CHECK( not CLR_DIO.IS_OPEN( FC ),              1,  2 );	-- IS_OPEN apres CLOSE

  CLR_DIO.OPEN( FC, CLR_DIO.IN_FILE, "couleur_direct.dat" );
  CHECK( CLR_DIO.IS_OPEN( FC ),                  1,  3 );	-- IS_OPEN apres OPEN
declare
use CLR_DIO;
begin
  CHECK( CLR_DIO.MODE( FC ) = CLR_DIO.IN_FILE,   1,  4 );	-- MODE
end;
  CLR_DIO.READ( FC, RC );
  CHECK( RC = ROUGE,                             1,  5 );	-- seq #1
  CLR_DIO.READ( FC, RC );
  CHECK( RC = BLEU,                              1,  6 );	-- seq #2

  CLR_DIO.READ( FC, RC, 5 );
  CHECK( RC = VERT,                              1,  7 );	-- positionne #5
  CLR_DIO.READ( FC, RC, 3 );
  CHECK( RC = BLANC,                             1,  8 );	-- positionne #3
  CLR_DIO.READ( FC, RC, 1 );
  CHECK( RC = ROUGE,                             1,  9 );	-- positionne #1

  CHECK( INTEGER( CLR_DIO.SIZE( FC ) ) = 5,      1, 10 );	-- SIZE en relecture

  CLR_DIO.CLOSE( FC );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 2. DIRECT_IO sur record POINT ===" );
  -- ---------------------------------------------------------------

  POINT_DIO.CREATE( FP, POINT_DIO.OUT_FILE, "point_direct.dat" );
  PUT( "  POINT'SIZE = " ); PUT( POINT'SIZE ); PUT_LINE( " bits (info)" );

  POINT_DIO.WRITE( FP, P1 );
  POINT_DIO.WRITE( FP, P2 );
  POINT_DIO.WRITE( FP, P3 );
  POINT_DIO.WRITE( FP, P4 );

  CHECK( INTEGER( POINT_DIO.SIZE( FP ) ) = 4,    2,  1 );	-- SIZE apres 4 writes
  POINT_DIO.CLOSE( FP );

			-- Relecture sequentielle complete, roundtrip record
  POINT_DIO.OPEN( FP, POINT_DIO.IN_FILE, "point_direct.dat" );

  POINT_DIO.READ( FP, RP );  CHECK( RP = P1,     2,  2 );
  POINT_DIO.READ( FP, RP );  CHECK( RP = P2,     2,  3 );
  POINT_DIO.READ( FP, RP );  CHECK( RP = P3,     2,  4 );
  POINT_DIO.READ( FP, RP );  CHECK( RP = P4,     2,  5 );
  CHECK( POINT_DIO.END_OF_FILE( FP ),            2,  6 );	-- EOF apres lecture complete
  POINT_DIO.CLOSE( FP );

			-- Lectures positionnees en ordre quelconque
  POINT_DIO.OPEN( FP, POINT_DIO.IN_FILE, "point_direct.dat" );

  POINT_DIO.READ( FP, RP, 4 );
  CHECK( RP = P4,                                2,  7 );
  CHECK( INTEGER( POINT_DIO.INDEX( FP ) ) = 5,   2,  8 );	-- INDEX = FROM+1 apres READ positionne
  POINT_DIO.READ( FP, RP, 1 );
  CHECK( RP = P1,                                2,  9 );
  POINT_DIO.READ( FP, RP, 2 );
  CHECK( RP = P2,                                2, 10 );
  CHECK( INTEGER( POINT_DIO.INDEX( FP ) ) = 3,   2, 11 );

  POINT_DIO.CLOSE( FP );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 3. DIRECT_IO sur tableau VECTEUR ===" );
  -- ---------------------------------------------------------------

  VEC_DIO.CREATE( FV, VEC_DIO.OUT_FILE, "vec_direct.dat" );
  PUT( "  VECTEUR'SIZE = " ); PUT( VECTEUR'SIZE ); PUT_LINE( " bits (info)" );

  VEC_DIO.WRITE( FV, V1 );
  VEC_DIO.WRITE( FV, V2 );
  VEC_DIO.WRITE( FV, V3 );

  CHECK( INTEGER( VEC_DIO.SIZE( FV ) ) = 3,      3,  1 );
  VEC_DIO.CLOSE( FV );

  VEC_DIO.OPEN( FV, VEC_DIO.IN_FILE, "vec_direct.dat" );

  VEC_DIO.READ( FV, RV );     CHECK( RV = V1,    3,  2 );	-- seq #1
  VEC_DIO.READ( FV, RV );     CHECK( RV = V2,    3,  3 );	-- seq #2
  VEC_DIO.READ( FV, RV, 3 );  CHECK( RV = V3,    3,  4 );	-- positionne #3
  VEC_DIO.READ( FV, RV, 1 );  CHECK( RV = V1,    3,  5 );	-- positionne #1

  VEC_DIO.CLOSE( FV );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 4. SET_INDEX, INDEX et END_OF_FILE (sur POINT) ===" );
  -- ---------------------------------------------------------------

  POINT_DIO.OPEN( FP, POINT_DIO.IN_FILE, "point_direct.dat" );

  CHECK( INTEGER( POINT_DIO.INDEX( FP ) ) = 1,   4,  1 );	-- INDEX a l'ouverture
  CHECK( not POINT_DIO.END_OF_FILE( FP ),        4,  2 );	-- EOF au debut

  POINT_DIO.SET_INDEX( FP, 4 );
  CHECK( INTEGER( POINT_DIO.INDEX( FP ) ) = 4,   4,  3 );	-- INDEX apres SET_INDEX(4)
  CHECK( not POINT_DIO.END_OF_FILE( FP ),        4,  4 );	-- EOF avant derniere lecture

  POINT_DIO.READ( FP, RP );
  CHECK( RP = P4,                                4,  5 );	-- dernier element
  CHECK( INTEGER( POINT_DIO.INDEX( FP ) ) = 5,   4,  6 );	-- INDEX apres derniere lecture
  CHECK( POINT_DIO.END_OF_FILE( FP ),            4,  7 );	-- EOF apres derniere lecture

  POINT_DIO.SET_INDEX( FP, 1 );
  CHECK( INTEGER( POINT_DIO.INDEX( FP ) ) = 1,   4,  8 );	-- retour au debut
  CHECK( not POINT_DIO.END_OF_FILE( FP ),        4,  9 );

  POINT_DIO.CLOSE( FP );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 5. RESET et reecriture partielle INOUT (sur POINT) ===" );
  -- ---------------------------------------------------------------

  POINT_DIO.OPEN( FP, POINT_DIO.INOUT_FILE, "point_direct.dat" );

  POINT_DIO.WRITE( FP, P_NEW, 2 );					-- variable
  POINT_DIO.WRITE( FP, POINT'( X => 777, Y => 888, Z => 999 ), 2 );	-- agregat qualifie en actual
  POINT_DIO.WRITE( FP, P_NEG, 4 );

  POINT_DIO.RESET( FP, POINT_DIO.IN_FILE );
declare
use POINT_DIO;
begin
  CHECK( POINT_DIO.MODE( FP ) = POINT_DIO.IN_FILE, 5, 1 );	-- MODE apres RESET
end;
  CHECK( INTEGER( POINT_DIO.INDEX( FP ) ) = 1,     5, 2 );	-- INDEX apres RESET

  POINT_DIO.READ( FP, RP, 1 );  CHECK( RP = P1,    5, 3 );
  POINT_DIO.READ( FP, RP, 2 );  CHECK( RP = P_NEW, 5, 4 );	-- reecrit
  POINT_DIO.READ( FP, RP, 3 );  CHECK( RP = P3,    5, 5 );	-- intact
  POINT_DIO.READ( FP, RP, 4 );  CHECK( RP = P_NEG, 5, 6 );	-- reecrit

  POINT_DIO.CLOSE( FP );
			-- point_direct.dat vaut desormais P1, P_NEW, P3, P_NEG


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 6. Boucle while not END_OF_FILE (sur VECTEUR) ===" );
  -- ---------------------------------------------------------------
			-- Idiome SUR pour DIRECT_IO : END_OF_FILE compare des
			-- positions exactes, pas de look-ahead (contra piege n. 79)

  VEC_DIO.OPEN( FV, VEC_DIO.IN_FILE, "vec_direct.dat" );

  declare
    IDX : INTEGER := 1;
  begin
    while not VEC_DIO.END_OF_FILE( FV ) loop
      VEC_DIO.READ( FV, RV );
      if    IDX = 1 then CHECK( RV = V1,           6,  1 );
      elsif IDX = 2 then CHECK( RV = V2,           6,  2 );
      elsif IDX = 3 then CHECK( RV = V3,           6,  3 );
      end if;
      IDX := IDX + 1;
    end loop;
    CHECK( IDX = 4,                                6,  4 );	-- exactement 3 elements lus
  end;

  VEC_DIO.CLOSE( FV );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 7. WRITE positionne au-dela de la fin (extension) ===" );
  -- ---------------------------------------------------------------
			-- LRM 14.2 : ecrire a TO > SIZE etend le fichier ;
			-- le trou (element 4) est lu a zero (fichier creux Linux)

  VEC_DIO.OPEN( FV, VEC_DIO.INOUT_FILE, "vec_direct.dat" );

  VEC_DIO.WRITE( FV, V1, 5 );
  CHECK( INTEGER( VEC_DIO.SIZE( FV ) ) = 5,        7,  1 );	-- SIZE etendu
  VEC_DIO.READ( FV, RV, 4 );
  CHECK( RV = V_ZERO,                              7,  2 );	-- trou a zero
  VEC_DIO.READ( FV, RV, 5 );
  CHECK( RV = V1,                                  7,  3 );	-- element ecrit

  VEC_DIO.CLOSE( FV );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 8. Exceptions ===" );
  -- ---------------------------------------------------------------

			-- 8.1 END_ERROR : lecture sequentielle a EOF
  CLR_DIO.OPEN( FC, CLR_DIO.IN_FILE, "couleur_direct.dat" );
  CLR_DIO.SET_INDEX( FC, 6 );
  begin
    CLR_DIO.READ( FC, RC );
    CHECK( FALSE,                                  8,  1 );
  exception
    when CLR_DIO.END_ERROR => CHECK( TRUE,         8,  1 );
    when others            => CHECK( FALSE,        8,  1 );
  end;

			-- 8.2 END_ERROR : lecture positionnee hors fichier
  begin
    CLR_DIO.READ( FC, RC, 99 );
    CHECK( FALSE,                                  8,  2 );
  exception
    when CLR_DIO.END_ERROR => CHECK( TRUE,         8,  2 );
    when others            => CHECK( FALSE,        8,  2 );
  end;
  CLR_DIO.CLOSE( FC );

			-- 8.3 END_ERROR : element TRONQUE (fichier de 5 octets
			-- ouvert comme fichier de POINT ; BYTES_READ < SIZE_BYTES)
  POINT_DIO.OPEN( FP, POINT_DIO.IN_FILE, "couleur_direct.dat" );
  begin
    POINT_DIO.READ( FP, RP );
    CHECK( FALSE,                                  8,  3 );
  exception
    when POINT_DIO.END_ERROR => CHECK( TRUE,       8,  3 );
    when others              => CHECK( FALSE,      8,  3 );
  end;
  POINT_DIO.CLOSE( FP );

			-- 8.4 MODE_ERROR : READ sur OUT_FILE
  CLR_DIO.CREATE( FC, CLR_DIO.OUT_FILE, "scratch_direct.dat" );
  CLR_DIO.WRITE( FC, C1 );
  begin
    CLR_DIO.READ( FC, RC );
    CHECK( FALSE,                                  8,  4 );
  exception
    when CLR_DIO.MODE_ERROR => CHECK( TRUE,        8,  4 );
    when others             => CHECK( FALSE,       8,  4 );
  end;

			-- 8.5 MODE_ERROR : END_OF_FILE sur OUT_FILE
  begin
    DUMMY_B := CLR_DIO.END_OF_FILE( FC );
    CHECK( FALSE,                                  8,  5 );
  exception
    when CLR_DIO.MODE_ERROR => CHECK( TRUE,        8,  5 );
    when others             => CHECK( FALSE,       8,  5 );
  end;
  CLR_DIO.CLOSE( FC );

			-- 8.6 MODE_ERROR : WRITE sur IN_FILE
  CLR_DIO.OPEN( FC, CLR_DIO.IN_FILE, "scratch_direct.dat" );
  begin
    CLR_DIO.WRITE( FC, C1 );
    CHECK( FALSE,                                  8,  6 );
  exception
    when CLR_DIO.MODE_ERROR => CHECK( TRUE,        8,  6 );
    when others             => CHECK( FALSE,       8,  6 );
  end;
  CLR_DIO.CLOSE( FC );

			-- 8.7 STATUS_ERROR : READ sur fichier ferme
  begin
    CLR_DIO.READ( FC, RC );
    CHECK( FALSE,                                  8,  7 );
  exception
    when CLR_DIO.STATUS_ERROR => CHECK( TRUE,      8,  7 );
    when others               => CHECK( FALSE,     8,  7 );
  end;

			-- 8.8 STATUS_ERROR : SIZE sur fichier ferme
  begin
    DUMMY_N := INTEGER( CLR_DIO.SIZE( FC ) );
    CHECK( FALSE,                                  8,  8 );
  exception
    when CLR_DIO.STATUS_ERROR => CHECK( TRUE,      8,  8 );
    when others               => CHECK( FALSE,     8,  8 );
  end;

			-- 8.9 STATUS_ERROR : RESET sur fichier ferme
  begin
    CLR_DIO.RESET( FC );
    CHECK( FALSE,                                  8,  9 );
  exception
    when CLR_DIO.STATUS_ERROR => CHECK( TRUE,      8,  9 );
    when others               => CHECK( FALSE,     8,  9 );
  end;


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 9. DELETE ===" );
  -- ---------------------------------------------------------------
			-- Juge de suppression : la tentative de re-OPEN echoue.
			-- Regime actuel : echec d'OPEN SILENCIEUX -> IS_OPEN FALSE
			-- (dette 14.2.1) ; le handler NAME_ERROR accepte d'avance
			-- le regime futur du lot de gardes.

  CLR_DIO.OPEN( FC, CLR_DIO.INOUT_FILE, "scratch_direct.dat" );
  CLR_DIO.DELETE( FC );
  CHECK( not CLR_DIO.IS_OPEN( FC ),                9,  1 );
  begin
    CLR_DIO.OPEN( FC, CLR_DIO.IN_FILE, "scratch_direct.dat" );
    CHECK( not CLR_DIO.IS_OPEN( FC ),              9,  2 );
  exception
    when CLR_DIO.NAME_ERROR => CHECK( TRUE,        9,  2 );
  end;

  CLR_DIO.OPEN( FC, CLR_DIO.INOUT_FILE, "couleur_direct.dat" );
  CLR_DIO.DELETE( FC );
  CHECK( not CLR_DIO.IS_OPEN( FC ),                9,  3 );
  begin
    CLR_DIO.OPEN( FC, CLR_DIO.IN_FILE, "couleur_direct.dat" );
    CHECK( not CLR_DIO.IS_OPEN( FC ),              9,  4 );
  exception
    when CLR_DIO.NAME_ERROR => CHECK( TRUE,        9,  4 );
  end;

  POINT_DIO.OPEN( FP, POINT_DIO.INOUT_FILE, "point_direct.dat" );
  POINT_DIO.DELETE( FP );
  CHECK( not POINT_DIO.IS_OPEN( FP ),              9,  5 );
  begin
    POINT_DIO.OPEN( FP, POINT_DIO.IN_FILE, "point_direct.dat" );
    CHECK( not POINT_DIO.IS_OPEN( FP ),            9,  6 );
  exception
    when POINT_DIO.NAME_ERROR => CHECK( TRUE,      9,  6 );
  end;

  VEC_DIO.OPEN( FV, VEC_DIO.INOUT_FILE, "vec_direct.dat" );
  VEC_DIO.DELETE( FV );
  CHECK( not VEC_DIO.IS_OPEN( FV ),                9,  7 );
  begin
    VEC_DIO.OPEN( FV, VEC_DIO.IN_FILE, "vec_direct.dat" );
    CHECK( not VEC_DIO.IS_OPEN( FV ),              9,  8 );
  exception
    when VEC_DIO.NAME_ERROR => CHECK( TRUE,        9,  8 );
  end;


  -- ---------------------------------------------------------------
  --  Verdict
  -- ---------------------------------------------------------------

  NEW_LINE;
  PUT( "RESULTAT : " ); PUT( NB_OK, 3 );
  PUT( " OK, " );       PUT( NB_ECHECS, 3 );
  PUT( " ECHECS" );     NEW_LINE;
  if NB_ECHECS = 0 then
    PUT_LINE( "DIRECT_IO_TEST PASSE" );
  else
    PUT_LINE( "DIRECT_IO_TEST ECHOUE" );
  end if;

end	DIRECT_IO_TEST;
	--------------
