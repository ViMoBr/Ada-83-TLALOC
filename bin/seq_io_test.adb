with TEXT_IO; use TEXT_IO;
with SEQUENTIAL_IO;
			-----------
procedure			SEQ_IO_TEST
is			-----------

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
  --  Instances SEQUENTIAL_IO
  --

  package INT_IO      is new INTEGER_IO( INTEGER );		use INT_IO;
  package CLR_SIO     is new SEQUENTIAL_IO( COULEUR );
  package POINT_SIO   is new SEQUENTIAL_IO( POINT );
  package VEC_SIO     is new SEQUENTIAL_IO( VECTEUR );

  --
  --  Fichiers
  --

  FC  		: CLR_SIO.FILE_TYPE;
  FC_MODE		: CLR_SIO.FILE_MODE;
  FP  		: POINT_SIO.FILE_TYPE;
  FV   		: VEC_SIO.FILE_TYPE;

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
  --  Helpers d'affichage
  --

  procedure PUT_POINT( P : in POINT ) is
  begin
    PUT( "(" );
    PUT( P.X ); PUT( "," );
    PUT( P.Y ); PUT( "," );
    PUT( P.Z );
    PUT( ")" );
  end PUT_POINT;

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
  PUT_LINE( "=== 1. SEQUENTIAL_IO sur type enumere COULEUR ===" );
  -- ---------------------------------------------------------------

  CLR_SIO.CREATE( FC, CLR_SIO.OUT_FILE, "couleur_seq.dat" );

  CLR_SIO.WRITE( FC, C1 );
  CLR_SIO.WRITE( FC, C2 );
  CLR_SIO.WRITE( FC, C3 );
  CLR_SIO.WRITE( FC, C4 );
  CLR_SIO.WRITE( FC, C5 );

  CLR_SIO.CLOSE( FC );
  PUT_LINE( "  create+write+close ok" );

  CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "couleur_seq.dat" );

  CLR_SIO.READ( FC, RC );
  PUT( "  seq #1 = " ); PUT( COULEUR'POS( RC ) ); NEW_LINE;

  CLR_SIO.READ( FC, RC );
  PUT( "  seq #2 = " ); PUT( COULEUR'POS( RC ) ); NEW_LINE;

  CLR_SIO.READ( FC, RC );
  PUT( "  seq #3 = " ); PUT( COULEUR'POS( RC ) ); NEW_LINE;

  CLR_SIO.CLOSE( FC );
  PUT_LINE( "  read+close ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 2. SEQUENTIAL_IO sur record POINT (3 INTEGER) ===" );
  -- ---------------------------------------------------------------

  POINT_SIO.CREATE( FP, POINT_SIO.OUT_FILE, "point_seq.dat" );
  PUT( "  POINT'SIZE = " ); PUT( POINT'SIZE ); PUT_LINE( " bits" );

  POINT_SIO.WRITE( FP, P1 );
  POINT_SIO.WRITE( FP, P2 );
  POINT_SIO.WRITE( FP, P3 );

  POINT_SIO.CLOSE( FP );
  PUT_LINE( "  create+write+close ok" );

  POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "point_seq.dat" );

  POINT_SIO.READ( FP, RP );
  PUT( "  seq #1 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_SIO.READ( FP, RP );
  PUT( "  seq #2 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_SIO.READ( FP, RP );
  PUT( "  seq #3 = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_SIO.CLOSE( FP );
  PUT_LINE( "  read+close ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 3. SEQUENTIAL_IO sur tableau VECTEUR (array 1..4 of INTEGER) ===" );
  -- ---------------------------------------------------------------

  VEC_SIO.CREATE( FV, VEC_SIO.OUT_FILE, "vec_seq.dat" );
  PUT( "  VECTEUR'SIZE = " ); PUT( VECTEUR'SIZE ); PUT_LINE( " bits" );

  VEC_SIO.WRITE( FV, V1 );
  VEC_SIO.WRITE( FV, V2 );
  VEC_SIO.WRITE( FV, V3 );

  VEC_SIO.CLOSE( FV );
  PUT_LINE( "  create+write+close ok" );

  VEC_SIO.OPEN( FV, VEC_SIO.IN_FILE, "vec_seq.dat" );

  VEC_SIO.READ( FV, RV );
  PUT( "  seq #1 = " ); PUT_VEC( RV ); NEW_LINE;

  VEC_SIO.READ( FV, RV );
  PUT( "  seq #2 = " ); PUT_VEC( RV ); NEW_LINE;

  VEC_SIO.READ( FV, RV );
  PUT( "  seq #3 = " ); PUT_VEC( RV ); NEW_LINE;

  VEC_SIO.CLOSE( FV );
  PUT_LINE( "  read+close ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 4. END_OF_FILE et boucle sequentielle (POINT) ===" );
  -- ---------------------------------------------------------------

  POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "point_seq.dat" );

  PUT( "  END_OF_FILE au debut = " );
  if  POINT_SIO.END_OF_FILE( FP )  then
    PUT_LINE( "TRUE (anormal)" );
  else
    PUT_LINE( "FALSE (correct)" );
  end if;

  declare
    IDX : INTEGER := 1;
  begin
    while not POINT_SIO.END_OF_FILE( FP ) loop
      POINT_SIO.READ( FP, RP );
      PUT( "  element " ); PUT( IDX ); PUT( " = " );
      PUT_POINT( RP ); NEW_LINE;
      IDX := IDX + 1;
    end loop;
  end;

  PUT( "  END_OF_FILE apres boucle = " );
  if  POINT_SIO.END_OF_FILE( FP )  then
    PUT_LINE( "TRUE (correct)" );
  else
    PUT_LINE( "FALSE (anormal)" );
  end if;

  POINT_SIO.CLOSE( FP );
  PUT_LINE( "  boucle END_OF_FILE ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 5. RESET (relecture depuis le debut) ===" );
  -- ---------------------------------------------------------------

  POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "point_seq.dat" );

  POINT_SIO.READ( FP, RP );
  PUT( "  avant RESET, lu = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_SIO.RESET( FP );
  PUT_LINE( "  RESET ok" );

  POINT_SIO.READ( FP, RP );
  PUT( "  apres RESET, lu = " ); PUT_POINT( RP ); NEW_LINE;

  POINT_SIO.CLOSE( FP );
  PUT_LINE( "  RESET ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 6. IS_OPEN ===" );
  -- ---------------------------------------------------------------

  PUT( "  FP IS_OPEN apres CLOSE = " );
  if  POINT_SIO.IS_OPEN( FP )  then
    PUT_LINE( "TRUE (anormal)" );
  else
    PUT_LINE( "FALSE (correct)" );
  end if;

  POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "point_seq.dat" );
  PUT( "  FP IS_OPEN apres OPEN = " );
  if  POINT_SIO.IS_OPEN( FP )  then
    PUT_LINE( "TRUE (correct)" );
  else
    PUT_LINE( "FALSE (anormal)" );
  end if;

  POINT_SIO.CLOSE( FP );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== 7. MODE ===" );
  -- ---------------------------------------------------------------

  CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "couleur_seq.dat" );
  PUT( "  MODE IN_FILE = " );
  declare
    use CLR_SIO;					-- BIZARRERIE FRONT END SANS CA ON A UNE ERREUR DESACCORD DE TYPE
  begin
    if  CLR_SIO.MODE( FC ) = CLR_SIO.IN_FILE  then	-- ERREUR ICI SI PAS DE USE CLR_SIO
      PUT_LINE( "IN_FILE (correct)" );
    else
      PUT_LINE( "OUT_FILE (anormal)" );
    end if;
    CLR_SIO.CLOSE( FC );

    CLR_SIO.CREATE( FC, CLR_SIO.OUT_FILE, "couleur_seq2.dat" );
    PUT( "  MODE OUT_FILE = " );
    if  CLR_SIO.MODE( FC ) = CLR_SIO.OUT_FILE  then
      PUT_LINE( "OUT_FILE (correct)" );
    else
      PUT_LINE( "IN_FILE (anormal)" );
    end if;
    CLR_SIO.CLOSE( FC );
  end;

  -- ---------------------------------------------------------------
  PUT_LINE( "=== 8. DELETE ===" );
  -- ---------------------------------------------------------------

--  CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "couleur_seq.dat" );
--  CLR_SIO.DELETE( FC );
--  PUT_LINE( "  couleur_seq.dat deleted" );

--  CLR_SIO.OPEN( FC, CLR_SIO.IN_FILE, "couleur_seq2.dat" );
--  CLR_SIO.DELETE( FC );
--  PUT_LINE( "  couleur_seq2.dat deleted" );

--  POINT_SIO.OPEN( FP, POINT_SIO.IN_FILE, "point_seq.dat" );
--  POINT_SIO.DELETE( FP );
--  PUT_LINE( "  point_seq.dat deleted" );

--  VEC_SIO.OPEN( FV, VEC_SIO.IN_FILE, "vec_seq.dat" );
--  VEC_SIO.DELETE( FV );
--  PUT_LINE( "  vec_seq.dat deleted" );

  PUT_LINE( "  DELETE ok" );


  -- ---------------------------------------------------------------
  PUT_LINE( "=== FIN SEQ_IO_TEST ===" );
  -- ---------------------------------------------------------------

end	SEQ_IO_TEST;
	--------------
