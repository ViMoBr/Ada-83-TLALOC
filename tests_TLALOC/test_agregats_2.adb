with TEXT_IO;
use  TEXT_IO;

			---------------
procedure			TEST_AGREGATS_2
is			---------------

  package INT_IO is new INTEGER_IO( INTEGER );

  ERRORS : INTEGER := 0;

  type POINT is
    record
      X : INTEGER;
      Y : INTEGER;
      Z : INTEGER;
    end record;

  type VECTEUR is array( 1 .. 4 ) of INTEGER;
  type VEC_ZERO is array( 0 .. 3 ) of INTEGER;
  type MATRICE is array( 1 .. 2, 1 .. 3 ) of INTEGER;
  type CUBE is array( 1 .. 2, 1 .. 2, 1 .. 3 ) of INTEGER;
  type TABLEAU_DE_POINTS is array( 1 .. 3 ) of POINT;

  type HYBRIDE is
    record
      A : INTEGER;
      V : VECTEUR;
      P : POINT;
    end record;

  V_POS    : VECTEUR := ( 8, 16, 32, 64 );
  V_NAMED  : VECTEUR := ( 1 => 0, 2 .. 3 => 1, 4 => -1 );
  V_OTHERS : VECTEUR := ( 0, 1, others => -1 );
  V_ZERO   : VEC_ZERO := ( 0 => 10, 1 => 20, 2 => 30, 3 => 40 );

  M_POS : MATRICE := ( ( 1, 2, 3 ), ( 4, 5, 6 ) );
  M_OTH : MATRICE := ( 1 => ( 10, 20, 30 ), 2 => ( others => 99 ) );

  C1 : CUBE :=
    ( ( ( 1, 2, 3 ), ( 4, 5, 6 ) ),
      ( ( 7, 8, 9 ), ( 10, 11, 12 ) ) );

  TP : TABLEAU_DE_POINTS :=
    ( ( 1, 2, 3 ), ( 4, 5, 6 ), ( 7, 8, 9 ) );

  H : HYBRIDE :=
    ( A => 77, V => ( 11, 22, 33, 44 ), P => ( 5, 6, 7 ) );

type REC_V is
  record
    V : VECTEUR;
  end record;

RV : REC_V := ( V => ( 11, 22, 33, 44 ) );
			---------
  procedure		PUT_INT	( I : INTEGER )
  is			---------
  begin
    INT_IO.PUT( I, 0 );
  end	PUT_INT;
	---------

			-----
  procedure		CHECK	( LABEL : STRING; GOT, EXPECTED : INTEGER )
  is			-----
  begin
    PUT( LABEL );
    PUT( " : " );

    if  GOT = EXPECTED  then
      PUT( "OK " );
      PUT_INT( GOT );
    else
      PUT( "ERREUR obtenu=" );
      PUT_INT( GOT );
      PUT( " attendu=" );
      PUT_INT( EXPECTED );
      ERRORS := ERRORS + 1;
    end if;

    NEW_LINE;
  end	CHECK;
	-----

			-------------------
  procedure		CHECK_VECTEUR_PARAM	( V : VECTEUR; A, B, C, D : INTEGER )
  is			-------------------
  begin
    CHECK( "param V(1)", V(1), A );
    CHECK( "param V(2)", V(2), B );
    CHECK( "param V(3)", V(3), C );
    CHECK( "param V(4)", V(4), D );
  end	CHECK_VECTEUR_PARAM;
	-------------------

			------------------
  procedure		CHECK_MATRICE_PARAM	( M : MATRICE )
  is			------------------
  begin
    CHECK( "param M(1,1)", M(1,1), 1 );
    CHECK( "param M(1,3)", M(1,3), 3 );
    CHECK( "param M(2,1)", M(2,1), 4 );
    CHECK( "param M(2,3)", M(2,3), 6 );
  end	CHECK_MATRICE_PARAM;
	------------------

			----------------
  procedure		CHECK_POINTS_PARAM	( T : TABLEAU_DE_POINTS )
  is			----------------
  begin
    CHECK( "param T(1).X", T(1).X, 1 );
    CHECK( "param T(2).Y", T(2).Y, 5 );
    CHECK( "param T(3).Z", T(3).Z, 9 );
  end	CHECK_POINTS_PARAM;
	----------------

			-------------------
  procedure		CHECK_DYNAMIC_BOUNDS	( N : INTEGER )
  is			-------------------
    type DYN_VEC is array( 1 .. N ) of INTEGER;

    D1 : DYN_VEC := ( 1 => 100, 2 .. N => 200 );
    D2 : DYN_VEC := ( others => 7 );
  begin
    CHECK( "dyn D1(1)", D1(1), 100 );
    CHECK( "dyn D1(N)", D1(N), 200 );
    CHECK( "dyn D2(1)", D2(1), 7 );
    CHECK( "dyn D2(N)", D2(N), 7 );
  end	CHECK_DYNAMIC_BOUNDS;
	-------------------

begin
  PUT_LINE( "=== objets tableaux 1D ===" );
  CHECK( "V_POS(1)",    V_POS(1),    8 );
  CHECK( "V_POS(4)",    V_POS(4),    64 );
  CHECK( "V_NAMED(1)",  V_NAMED(1),  0 );
  CHECK( "V_NAMED(2)",  V_NAMED(2),  1 );
  CHECK( "V_NAMED(3)",  V_NAMED(3),  1 );
  CHECK( "V_NAMED(4)",  V_NAMED(4), -1 );
  CHECK( "V_OTHERS(1)", V_OTHERS(1), 0 );
  CHECK( "V_OTHERS(4)", V_OTHERS(4), -1 );
  CHECK( "V_ZERO(0)",   V_ZERO(0),   10 );
  CHECK( "V_ZERO(3)",   V_ZERO(3),   40 );

  PUT_LINE( "=== parametre tableau et indexation scalaire ===" );
  CHECK_VECTEUR_PARAM( VECTEUR'( 8, 16, 32, 64 ), 8, 16, 32, 64 );
  CHECK_VECTEUR_PARAM( V_NAMED, 0, 1, 1, -1 );

  PUT_LINE( "=== tableaux multidimensionnels ===" );
  CHECK( "M_POS(1,1)", M_POS(1,1), 1 );
  CHECK( "M_POS(2,3)", M_POS(2,3), 6 );
  CHECK( "M_OTH(1,2)", M_OTH(1,2), 20 );
  CHECK( "M_OTH(2,3)", M_OTH(2,3), 99 );
  CHECK( "C1(1,2,3)", C1(1,2,3), 6 );
  CHECK( "C1(2,2,3)", C1(2,2,3), 12 );
  CHECK_MATRICE_PARAM( M_POS );

  PUT_LINE( "=== tableaux de records et record contenant tableau ===" );
  CHECK( "TP(1).X", TP(1).X, 1 );
  CHECK( "TP(2).Y", TP(2).Y, 5 );
  CHECK( "TP(3).Z", TP(3).Z, 9 );
  CHECK_POINTS_PARAM( TP );
  CHECK( "H.A",    H.A,    77 );

  CHECK( "H.V(1)", H.V(1), 11 );
  CHECK( "H.V(2)", H.V(2), 22 );
  CHECK( "H.V(3)", H.V(3), 33 );
  CHECK( "H.V(4)", H.V(4), 44 );

  CHECK( "H.V(3)", H.V(3), 33 );

  CHECK( "RV.V(1)", RV.V(1), 11 );
  CHECK( "RV.V(2)", RV.V(2), 22 );
  CHECK( "RV.V(3)", RV.V(3), 33 );
  CHECK( "RV.V(4)", RV.V(4), 44 );

  H.V(2) := 222;
  H.V(3) := 333;
  H.V(4) := 444;

  CHECK( "H.V(2) apres assign", H.V(2), 222 );
  CHECK( "H.V(3) apres assign", H.V(3), 333 );
  CHECK( "H.V(4) apres assign", H.V(4), 444 );

  CHECK_VECTEUR_PARAM( H.V, 11, 222, 333, 444 );
  CHECK_VECTEUR_PARAM( RV.V, 11, 22, 33, 44 );

  CHECK( "H.P.Z",  H.P.Z,  7 );

  PUT_LINE( "=== bornes dynamiques locales ===" );
  CHECK_DYNAMIC_BOUNDS( 4 );

  PUT_LINE( "=== bilan ===" );
  if  ERRORS = 0  then
    PUT_LINE( "TOUS LES TESTS SONT OK" );
  else
    PUT( "NOMBRE D'ERREURS = " );
    PUT_INT( ERRORS );
    NEW_LINE;
  end if;

end	TEST_AGREGATS_2;
	---------------
