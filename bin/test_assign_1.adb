with TEXT_IO;
use  TEXT_IO;
procedure TEST_ASSIGN_1
is

  type COULEUR	is ( ROUGE, BLEU, BLANC );

  type SUBREC	is record
		X	: INTEGER;
		Y	: INTEGER;
		end record;

  type TABLE	is array( 1 .. 8 ) of SUBREC;
  A		: TABLE;

  type RECTEST	is record
		I	: INTEGER;
		F	: FLOAT;
		E	: COULEUR;
		C	: SUBREC;
		A	: TABLE;
		end record;

  package INT_IO	is new INTEGER_IO( INTEGER );
  package FLT_IO	is new FLOAT_IO( FLOAT );
  package COLOR_IO	is new ENUMERATION_IO( COULEUR );

  R, R1		: RECTEST;
  R2		: RECTEST	:= (5, 1.8, ROUGE, (12,24), ((1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8)));
  N		: INTEGER	:= 3;

begin
-- CAS 1 OK
  R.I := 12;          -- composante Integer
  PUT( "cas 1 R.I " ); INT_IO.PUT( R.I, WIDTH=> 3 ); NEW_LINE;

-- CAS 2 OK
  R.F := 1.25;        -- composante Float ou Fixed
  PUT( "cas 2 R.F " ); FLT_IO.PUT( R.F ); NEW_LINE;

-- CAS 3 OK
  R.E := Rouge;       -- composante Enum
  PUT( "cas 3 R.E " ); COLOR_IO.PUT( R.E ); NEW_LINE;

-- CAS 4 OK
  R1.C := R2.C;       -- composante record, BLKMOV
  PUT( "cas 4 R1.C [" ); INT_IO.PUT( R1.C.X ); PUT( ',' ); INT_IO.PUT( R1.C.Y ); PUT( ']' ); NEW_LINE;

-- CAS 5 OK
  R1.C := ( X=> 4, Y=> 8 );    -- composante record par agrégat
  PUT( "cas 5 R1.C [" ); INT_IO.PUT( R1.C.X ); PUT( ',' ); INT_IO.PUT( R1.C.Y ); PUT( ']' ); NEW_LINE;

-- CAS 6 OK
  A(N).X := 12; A(N).Y := 13;       -- indexed puis selected
  PUT( "cas 6 A(N).X A(N).Y   [" ); INT_IO.PUT( A(N).X ); PUT( ',' ); INT_IO.PUT( A(N).Y ); PUT( ']' ); NEW_LINE;

-- CAS 7 segfaulte
  R.A(N) := (12,12);       -- selected puis indexed, si supporté
  PUT( "cas 7 R.A(N) [" ); INT_IO.PUT( R.A(N).X ); PUT( ',' ); INT_IO.PUT( R.A(N).Y ); PUT( ']' ); NEW_LINE;

end	TEST_ASSIGN_1;
