with TEXT_IO;
use  TEXT_IO;

			--------------
procedure			BUG2_AGGREGATE
is			--------------

  package INT_IO is new INTEGER_IO( INTEGER );

  type VECTEUR	is array( 1 .. 4 ) of INTEGER;

  type REC_V	is record
		  V	: VECTEUR;
		end record;

  RV		: REC_V		:= ( V => ( 11, 22, 33, 44 ) );

begin

  PUT( "RV.V(1)" ); INT_IO.PUT( RV.V(1) ); NEW_LINE;
  PUT( "RV.V(2)" ); INT_IO.PUT( RV.V(2) ); NEW_LINE;
  PUT( "RV.V(3)" ); INT_IO.PUT( RV.V(3) ); NEW_LINE;
  PUT( "RV.V(4)" ); INT_IO.PUT( RV.V(4) ); NEW_LINE;

end	BUG2_AGGREGATE;
	--------------
