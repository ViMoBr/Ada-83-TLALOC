			-------------
procedure			TEST_AGREGATS
is			-------------

  type POINT	is record
		  X : INTEGER;
		  Y : INTEGER;
		  Z : INTEGER;
		end record;

  P1	: POINT	:= ( X=> 16, Y=> 32, Z=> 64 );							-- NAMED RECORD AGGREGATE (VERSION SIMPLE)
  P2	: POINT	:= ( 128, 256, 512 );								-- POSITIONAL RECORD AGGREGATE (PAS GERE)


  type SEGMENT	is record
		  A : POINT;
		  B : POINT;
		end record;

  S1	: SEGMENT	:= ( A => (1,2,3), B => (4,5,6) );							-- RECORD de RECORDS


  type VECTEUR	is array( 1 .. 4 ) of INTEGER;

  V1	: VECTEUR	:= ( 0, 1, 2, 3 );									-- POSITIONAL ARRAY AGGREGATE (FAIT 1 DIMENSION)

  V2	: VECTEUR	:= ( 1=> 0, 2..3=> 1, 4=> -1 );							-- NAMED ARRAY AGGREGATE (A FAIRE)
  V3	: VECTEUR	:= ( 0, 1, others=> -1 );								-- POSITIONAL ARRAY AGGREGATE avec OTHERS (A FAIRE)


  type HYBRIDE	is record
		  A	: POINT;
		  TA	: VECTEUR;
		end record;

  H1	: HYBRIDE	:= ( A=> (8,9,10), TA=> ( 12, 13, 14, 15) );

  type SEGMENT2	is record
		  A,
		  B : POINT	:= (8, 16, 32);
		end record;

  SEG2_A	: SEGMENT2;
  SEG2_B	: SEGMENT2	:= ( A => (1,2,3), B => (4,5,6) );


  type MATRICE		is array( 1..4, 1..3, 1..4 ) of INTEGER;					-- array 3D

  M1	: MATRICE		:= ( ( (1,2,3,4), ( 5,6,7,8 ), ( 9,10,11,12 ), ( 13,14,15,16 ) ),
			     ( (1,2,3,4), others=> ( 0,0,0,0 ) ),
			     ( 3..4=> (100,200,300,400), 1..2=>(5,6,7,8) ),
			     ( others=> (10,20,30,40) )
			);					-- array 3D


  type TABLEAU_DE_POINTS	is array( 1..3 ) of POINT;							-- array de records

  TP1	: TABLEAU_DE_POINTS	:= ( (1,0,0), (0,1,0), (0,0,1) );						-- array de records


--  procedure INGERE_VECTEUR	( VEC :VECTEUR ) is begin null; end;
--  procedure INGERE_POINT	( PT :POINT ) is begin null; end;

begin
  null;
--  INGERE_VECTEUR( VECTEUR'(8, 16, 32, 64) );
--  INGERE_POINT( (10,12,14) );

end	TEST_AGREGATS;
	-------------
