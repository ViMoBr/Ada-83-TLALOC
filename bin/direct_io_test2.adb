with TEXT_IO; use TEXT_IO;
with DIRECT_IO;
			---------------
procedure			DIRECT_IO_TEST2
is			---------------

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
  --  Instances DIRECT_IO
  --

  package INT_IO      is new INTEGER_IO( INTEGER );		use INT_IO;
  package LF_IO       is new FLOAT_IO( LONG_FLOAT );		use LF_IO;
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

  P_NEG : POINT := ( X => -42, Y => -42, Z => -42 );

  V1   : VECTEUR  := ( 11, 22, 33, 44 );
  V2   : VECTEUR  := ( 55, 66, 77, 88 );
  V3   : VECTEUR  := ( -1, -2, -3, -4 );

  --
  --  Variables de lecture
  --

  RC   : COULEUR  := VERT;
  RP   : POINT    := ( X => 0, Y => 0, Z => 0 );
  RV   : VECTEUR  := ( 0, 0, 0, 0 );
  TMP  : CLR_DIO.COUNT := 0;

  --
  --  Helper : afficher un POINT
  --

  procedure PUT_POINT( P : in POINT ) is
  begin
    PUT( "(" );
    PUT( P.X ); PUT( "," );
    PUT( P.Y ); PUT( "," );
    PUT( P.Z );
    PUT( ")" );
  end PUT_POINT;

  --
  --  Helper : afficher un VECTEUR
  --

  procedure PUT_VEC( V : in VECTEUR ) is
  begin
    PUT( "[" );
    PUT( V(1) ); PUT( " " );
    PUT( V(2) ); PUT( " " );
    PUT( V(3) ); PUT( " " );
    PUT( V(4) );
    PUT( "]" );
  end PUT_VEC;

begin

  -- ---------------------------------------------------------------
  PUT_LINE( "=== 1. DIRECT_IO sur type enumere COULEUR ===" );
  -- ---------------------------------------------------------------

  CLR_DIO.CREATE( FC, CLR_DIO.OUT_FILE, "couleur_direct.dat" );
  PUT( "  COULEUR'SIZE = " ); PUT( COULEUR'SIZE ); PUT_LINE( " bits" );

  CLR_DIO.WRITE( FC, C1 );
  CLR_DIO.WRITE( FC, C2 );
  CLR_DIO.WRITE( FC, C3 );
  CLR_DIO.WRITE( FC, C4 );
  CLR_DIO.WRITE( FC, C5 );

  PUT( "  size apres 5 writes = " );
  PUT( INTEGER( CLR_DIO.SIZE( FC ) ) ); NEW_LINE;

  CLR_DIO.CLOSE( FC );
  PUT_LINE( "  create+write+close ok" );

  CLR_DIO.OPEN( FC, CLR_DIO.IN_FILE, "couleur_direct.dat" );

  CLR_DIO.READ( FC, RC );
  PUT( "  seq #1 = " ); PUT( COULEUR'POS( RC ) ); NEW_LINE;

  CLR_DIO.READ( FC, RC );
  PUT( "  seq #2 = " ); PUT( COULEUR'POS( RC ) ); NEW_LINE;

  -- Lecture positionnee
  CLR_DIO.READ( FC, RC, 5 );
  PUT( "  positioned #5 = " ); PUT( COULEUR'POS( RC ) ); NEW_LINE;

  CLR_DIO.READ( FC, RC, 3 );
  PUT( "  positioned #3 = " ); PUT( COULEUR'POS( RC ) ); NEW_LINE;

  CLR_DIO.CLOSE( FC );
  PUT_LINE( "  read+close ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 2. DIRECT_IO sur record POINT (3 INTEGER) ===" );
  -- ---------------------------------------------------------------

  POINT_DIO.CREATE( FP, POINT_DIO.OUT_FILE, "point_direct.dat" );
  PUT( "  POINT'SIZE = " ); PUT( POINT'SIZE ); PUT_LINE( " bits" );

  POINT_DIO.WRITE( FP, P1 );
  POINT_DIO.WRITE( FP, P2 );
  POINT_DIO.WRITE( FP, P3 );
  POINT_DIO.WRITE( FP, P4 );

  PUT( "  size apres 4 writes = " );
  PUT( INTEGER( POINT_DIO.SIZE( FP ) ) ); NEW_LINE;

  POINT_DIO.CLOSE( FP );
  PUT_LINE( "  create+write+close ok" );

  -- Relecture sequentielle complete
  POINT_DIO.OPEN( FP, POINT_DIO.IN_FILE, "point_direct.dat" );

  POINT_DIO.READ( FP, RP );
  PUT( "  seq #1 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.READ( FP, RP );
  PUT( "  seq #2 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.READ( FP, RP );
  PUT( "  seq #3 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.READ( FP, RP );
  PUT( "  seq #4 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.CLOSE( FP );

  -- Lectures positionnees en ordre quelconque
  POINT_DIO.OPEN( FP, POINT_DIO.IN_FILE, "point_direct.dat" );

  POINT_DIO.READ( FP, RP, 4 );
  PUT( "  positioned #4 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.READ( FP, RP, 1 );
  PUT( "  positioned #1 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.READ( FP, RP, 2 );
  PUT( "  positioned #2 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.CLOSE( FP );
  PUT_LINE( "  lectures positionnees ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 3. DIRECT_IO sur tableau VECTEUR (array 1..4 of INTEGER) ===" );
  -- ---------------------------------------------------------------

  VEC_DIO.CREATE( FV, VEC_DIO.OUT_FILE, "vec_direct.dat" );
  PUT( "  VECTEUR'SIZE = " ); PUT( VECTEUR'SIZE ); PUT_LINE( " bits" );

  VEC_DIO.WRITE( FV, V1 );
  VEC_DIO.WRITE( FV, V2 );
  VEC_DIO.WRITE( FV, V3 );

  PUT( "  size apres 3 writes = " );
  PUT( INTEGER( VEC_DIO.SIZE( FV ) ) ); NEW_LINE;

  VEC_DIO.CLOSE( FV );
  PUT_LINE( "  create+write+close ok" );

  VEC_DIO.OPEN( FV, VEC_DIO.IN_FILE, "vec_direct.dat" );

  VEC_DIO.READ( FV, RV );
  PUT( "  seq #1 = " ); PUT_VEC( RV ); NEW_LINE;

  VEC_DIO.READ( FV, RV );
  PUT( "  seq #2 = " ); PUT_VEC( RV ); NEW_LINE;

  VEC_DIO.READ( FV, RV, 3 );
  PUT( "  positioned #3 = " ); PUT_VEC( RV ); NEW_LINE;

  VEC_DIO.READ( FV, RV, 1 );
  PUT( "  positioned #1 = " ); PUT_VEC( RV ); NEW_LINE;

  VEC_DIO.CLOSE( FV );
  PUT_LINE( "  read+close ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 4. SET_INDEX et END_OF_FILE (sur POINT) ===" );
  -- ---------------------------------------------------------------

  POINT_DIO.OPEN( FP, POINT_DIO.IN_FILE, "point_direct.dat" );

  -- Aller en fin de fichier via SET_INDEX
  POINT_DIO.SET_INDEX( FP, 4 );
  PUT( "  INDEX apres SET_INDEX(4) = " );
  PUT( INTEGER( POINT_DIO.INDEX( FP ) ) ); NEW_LINE;

  PUT( "  END_OF_FILE avant derniere lecture = " );
  if POINT_DIO.END_OF_FILE( FP ) then
    PUT_LINE( "TRUE" );
  else
    PUT_LINE( "FALSE" );
  end if;

  POINT_DIO.READ( FP, RP );
  PUT( "  dernier element = " ); PUT_POINT( RP ); NEW_LINE;

  PUT( "  END_OF_FILE apres derniere lecture = " );
  if POINT_DIO.END_OF_FILE( FP ) then
    PUT_LINE( "TRUE" );
  else
    PUT_LINE( "FALSE" );
  end if;

  -- SET_INDEX retour au debut
  POINT_DIO.SET_INDEX( FP, 1 );
  PUT( "  INDEX apres SET_INDEX(1) = " );
  PUT( INTEGER( POINT_DIO.INDEX( FP ) ) ); NEW_LINE;

  PUT( "  END_OF_FILE apres retour debut = " );
  if POINT_DIO.END_OF_FILE( FP ) then
    PUT_LINE( "TRUE" );
  else
    PUT_LINE( "FALSE" );
  end if;

  POINT_DIO.CLOSE( FP );
  PUT_LINE( "  SET_INDEX + END_OF_FILE ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 5. RESET et reecriture partielle (sur POINT) ===" );
  -- ---------------------------------------------------------------

  -- Ouvrir en INOUT_FILE, reecrire element 2 et 4
  POINT_DIO.OPEN( FP, POINT_DIO.INOUT_FILE, "point_direct.dat" );
  PUT_LINE( "  open INOUT_FILE ok" );

  declare
    P_NEW : POINT := ( X => 777, Y => 888, Z => 999 );
  begin
    PUT( "  P_NEW X (en bloc) = " ); PUT( P_NEW.X ); PUT( " Y=" ); PUT( P_NEW.Y ); PUT( " Z=" ); PUT( P_NEW.Z ); NEW_LINE;

--    POINT_DIO.WRITE( FP, P_NEW, 2 );
    POINT_DIO.WRITE( FP, POINT'( X => 777, Y => 888, Z => 999 ), 2 );
    POINT_DIO.WRITE( FP, P_NEG, 4 );
  end;

  -- RESET en IN_FILE pour relire
  POINT_DIO.RESET( FP, POINT_DIO.IN_FILE );
  PUT_LINE( "  RESET IN_FILE ok" );

  PUT( "  apres RESET INDEX = " );
  PUT( INTEGER( POINT_DIO.INDEX( FP ) ) ); NEW_LINE;

  POINT_DIO.READ( FP, RP, 1 );
  PUT( "  verify #1 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.READ( FP, RP, 2 );
  PUT( "  verify #2 (reecrit) = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.READ( FP, RP, 3 );
  PUT( "  verify #3 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.READ( FP, RP, 4 );
  PUT( "  verify #4 (reecrit) = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_DIO.CLOSE( FP );
  PUT_LINE( "  RESET + reecriture ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 6. IS_OPEN ===" );
  -- ---------------------------------------------------------------

  PUT( "  FP IS_OPEN apres CLOSE = " );
  if POINT_DIO.IS_OPEN( FP ) then
    PUT_LINE( "TRUE (anormal)" );
  else
    PUT_LINE( "FALSE (correct)" );
  end if;

  POINT_DIO.OPEN( FP, POINT_DIO.IN_FILE, "point_direct.dat" );
  PUT( "  FP IS_OPEN apres OPEN = " );
  if POINT_DIO.IS_OPEN( FP ) then
    PUT_LINE( "TRUE (correct)" );
  else
    PUT_LINE( "FALSE (anormal)" );
  end if;

  POINT_DIO.CLOSE( FP );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 7. Boucle de lecture sequentielle avec END_OF_FILE ===" );
  -- ---------------------------------------------------------------

  -- Relire le fichier VECTEUR en boucle
  VEC_DIO.OPEN( FV, VEC_DIO.IN_FILE, "vec_direct.dat" );
  PUT_LINE( "  parcours sequentiel vec_direct.dat :" );

  declare
    IDX : INTEGER := 1;
  begin
    while not VEC_DIO.END_OF_FILE( FV ) loop
      VEC_DIO.READ( FV, RV );
      PUT( "  element " ); PUT( IDX ); PUT( " = " );
      PUT_VEC( RV ); NEW_LINE;
      IDX := IDX + 1;
    end loop;
  end;

  VEC_DIO.CLOSE( FV );
  PUT_LINE( "  boucle END_OF_FILE ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 8. DELETE ===" );
  -- ---------------------------------------------------------------

  -- Supprimer les trois fichiers de test
--  CLR_DIO.OPEN( FC, CLR_DIO.INOUT_FILE, "couleur_direct.dat" );
--  CLR_DIO.DELETE( FC );
--  PUT_LINE( "  couleur_direct.dat deleted" );

--  PUT( "  FC IS_OPEN apres DELETE = " );
--  if CLR_DIO.IS_OPEN( FC ) then
--    PUT_LINE( "TRUE (anormal)" );
--  else
--    PUT_LINE( "FALSE (correct)" );
--  end if;

--  POINT_DIO.OPEN( FP, POINT_DIO.INOUT_FILE, "point_direct.dat" );
--  POINT_DIO.DELETE( FP );
--  PUT_LINE( "  point_direct.dat deleted" );

--  VEC_DIO.OPEN( FV, VEC_DIO.INOUT_FILE, "vec_direct.dat" );
--  VEC_DIO.DELETE( FV );
--  PUT_LINE( "  vec_direct.dat deleted" );

--  PUT_LINE( "  DELETE ok" );

  -- ---------------------------------------------------------------
  PUT_LINE( "=== FIN DIRECT_IO_TEST2 ===" );
  -- ---------------------------------------------------------------

end	DIRECT_IO_TEST2;
	-----------------
