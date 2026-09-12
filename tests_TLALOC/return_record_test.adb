with TEXT_IO; use TEXT_IO;

procedure RETURN_RECORD_TEST is

   type POINT is record
      X : INTEGER;
      Y : INTEGER;
   end record;

   function MAKE_POINT( X, Y : INTEGER ) return POINT;
   function ADD_POINTS( A, B : POINT ) return POINT;

   P0 : POINT := ( 8, 10 );
   P1 : POINT := MAKE_POINT( 3, 7 );          -- function_call record -> variable
   P2 : POINT := ( X => 10, Y => 20 );        -- agregat direct
   P3 : POINT := ADD_POINTS( P1, P2 );        -- function_call utilisant deux records

-- Cas 1 : résultat de fonction utilisé directement comme paramètre (pas de variable intermédiaire)
  P4 : POINT := ADD_POINTS( MAKE_POINT(1,2), MAKE_POINT(3,4) );   -- attendu : X=4, Y=6

-- Cas 2 : record contenant un champ record (CODE_AGGREGATE branche composite qu'on a corrigée)
  type SEGMENT is record
	A : POINT;
	B : POINT;
	end record;

  S0	: SEGMENT	:= ( (1,2), (3,4) );
  S1	: SEGMENT	:= ( A => MAKE_POINT(5,6), B => MAKE_POINT(7,8) );
  S2	: SEGMENT	:= ( MAKE_POINT(9,10), (11,12) );

  package INT_IO is new INTEGER_IO( INTEGER ); use INT_IO;

  function MAKE_POINT( X, Y : INTEGER ) return POINT is
  begin
    return ( X => X, Y => Y );        -- branche agregat dans CODE_RETURN
  end MAKE_POINT;

  function ADD_POINTS( A, B : POINT ) return POINT is
  begin
    return ( X => A.X + B.X,          -- branche agregat, composantes scalaires
               Y => A.Y + B.Y );
  end ADD_POINTS;

begin
  PUT( "P0 = [" ); PUT( P0.X ); PUT( ',' ); PUT( P0.Y ); PUT( ']' ); NEW_LINE;
  PUT( "P1 = [" ); PUT( P1.X ); PUT( ',' ); PUT( P1.Y ); PUT( ']' ); NEW_LINE;
  PUT( "P2 = [" ); PUT( P2.X ); PUT( ',' ); PUT( P2.Y ); PUT( ']' ); NEW_LINE;
  PUT( "P3 = [" ); PUT( P3.X ); PUT( ',' ); PUT( P3.Y ); PUT( ']' ); NEW_LINE;
  PUT( "P4 = [" ); PUT( P4.X ); PUT( ',' ); PUT( P4.Y ); PUT( ']' ); NEW_LINE;

  PUT( "S0 = [[" );
  PUT( S0.A.X ); PUT( ',' ); PUT( S0.A.Y );
  PUT( "],[" );
  PUT( S0.B.X ); PUT( ',' ); PUT( S0.B.Y );
  PUT( ']' ); NEW_LINE;

  PUT( "S1 = [[" );
  PUT( S1.A.X ); PUT( ',' ); PUT( S1.A.Y );
  PUT( "],[" );
  PUT( S1.B.X ); PUT( ',' ); PUT( S1.B.Y );
  PUT( ']' ); NEW_LINE;

  PUT( "S2 = [[" );
  PUT( S2.A.X ); PUT( ',' ); PUT( S2.A.Y );
  PUT( "],[" );
  PUT( S2.B.X ); PUT( ',' ); PUT( S2.B.Y );
  PUT( ']' ); NEW_LINE;

end RETURN_RECORD_TEST;
