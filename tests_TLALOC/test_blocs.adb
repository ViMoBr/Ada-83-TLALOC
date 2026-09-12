with TEXT_IO, DIRECT_IO;
use  TEXT_IO;
		----------
procedure		TEST_BLOCS
is		----------

  package INT_IO	is new INTEGER_IO( INTEGER );
  use INT_IO;

  LEVEL_1	: INTEGER	:= 10;

  type POINT is record
    X : INTEGER;
    Y : INTEGER;
    Z : INTEGER;
  end record;

  PT : POINT := ( X => 111, Y => 222, Z => 333 );

  package POINT_DIO     is new DIRECT_IO( POINT );

  FP   : POINT_DIO.FILE_TYPE;

begin
  POINT_DIO.CREATE( FP, POINT_DIO.INOUT_FILE, "point_direct.dat" );
  POINT_DIO.WRITE( FP, PT );
  POINT_DIO.WRITE( FP, PT );
  POINT_DIO.WRITE( FP, PT );
  POINT_DIO.WRITE( FP, PT );
  POINT_DIO.CLOSE( FP );

  PUT( "Niveau 1" ); PUT( LEVEL_1 ); NEW_LINE;

				---------
				BLOC_LVL2:
  declare
    LEVEL_2	: INTEGER	:= 20;
  begin
    PUT( "Niveau 2" ); PUT( LEVEL_2 ); NEW_LINE;

declare
  P_NEW : POINT := ( X => 777, Y => 888, Z => 999 );
begin
  POINT_DIO.OPEN( FP, POINT_DIO.INOUT_FILE, "point_direct.dat" );
  POINT_DIO.WRITE( FP, P_NEW, 2 );
  POINT_DIO.WRITE( FP, P_NEW, 4 );
  POINT_DIO.READ( FP, PT, 1 );
  PUT( "(1) X=" ); PUT( PT.X ); PUT( " Y=" ); PUT( PT.Y ); PUT( " Z=" ); PUT( PT.Z ); NEW_LINE;
  POINT_DIO.READ( FP, PT, 2 );
  PUT( "(2) X=" ); PUT( PT.X ); PUT( " Y=" ); PUT( PT.Y ); PUT( " Z=" ); PUT( PT.Z ); NEW_LINE;
  POINT_DIO.READ( FP, PT, 3 );
  PUT( "(3) X=" ); PUT( PT.X ); PUT( " Y=" ); PUT( PT.Y ); PUT( " Z=" ); PUT( PT.Z ); NEW_LINE;
  POINT_DIO.READ( FP, PT, 4 );
  PUT( "(4) X=" ); PUT( PT.X ); PUT( " Y=" ); PUT( PT.Y ); PUT( " Z=" ); PUT( PT.Z ); NEW_LINE;
end;
  POINT_DIO.CLOSE( FP );

			---------
			BLOC_LVL3:
    declare
      LEVEL_3	: INTEGER	:= 30;
    begin
      PUT( "Niveau 3" ); PUT( LEVEL_3 ); NEW_LINE;

    end		BLOC_LVL3;
		---------

  end	BLOC_LVL2;
	---------

end	TEST_BLOCS;
	----------
