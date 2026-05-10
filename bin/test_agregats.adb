			-------------
procedure			TEST_AGREGATS
is			-------------

  type POINT is record
    X : INTEGER;
    Y : INTEGER;
    Z : INTEGER;
  end record;

  type VECTEUR	is array( 1 .. 4 ) of INTEGER;

  P1	: POINT	:= ( X=> 16, Y=> 32, Z=> 64 );	-- NAMED RECORD AGGREGATE (VERSION SIMPLE)
  V1	: VECTEUR	:= ( 0, 1, 2, 3 );			-- POSITIONAL ARRAY AGGREGATE (FAIT 1 DIMENSION)

  P2	: POINT	:= ( 128, 256, 512 );		-- POSITIONAL RECORD AGGREGATE (PAS GERE)
  V2	: VECTEUR	:= ( 1=> 0, 2..3=> 1, 4=> -1 );	-- NAMED ARRAY AGGREGATE (A FAIRE)
  V3	: VECTEUR	:= ( 0, 1, others=> -1 );		-- POSITIONAL ARRAY AGGREGATE avec OTHERS (A FAIRE)

  procedure INGERE_VECTEUR	( VEC :VECTEUR ) is begin null; end;
  procedure INGERE_POINT	( PT :POINT ) is begin null; end;

begin
  INGERE_VECTEUR( VECTEUR'(8, 16, 32, 64) );
  INGERE_POINT( (10,12,14) );

end	TEST_AGREGATS;
	-------------
