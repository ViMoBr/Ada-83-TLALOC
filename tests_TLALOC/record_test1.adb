-- RECORD_TEST1 -- Pilier LRM 3.7 / 3.7.1 / 3.7.2 / 3.7.3 -- lot R-A
-- Discriminants sans defauts, sous-types contraints, variantes statiques,
-- agregats, affectation, egalite (sans variantes), parametres et retour.
-- Hors perimetre : composants dependant d'un discriminant, controles
-- CONSTRAINT_ERROR, egalite de records a variantes.

with TEXT_IO; use TEXT_IO;

procedure RECORD_TEST1 is

  type BUF ( LEN : INTEGER ) is
    record
      X : INTEGER;
      Y : INTEGER;
    end record;

  subtype BUF5 is BUF( 5 );                     -- dscrmt_constraint sur sous-type

  type KIND is ( LEAF, UNARY, BINARY );

  type NODE ( PT : KIND ) is
    record
      COL : INTEGER;
      case PT is
        when LEAF   => VAL : INTEGER;
        when UNARY  => OPU : INTEGER;
        when BINARY => GAU : INTEGER;
                       DTE : INTEGER;
      end case;
    end record;

  type WRAP is
    record
      H : INTEGER;
      P : BUF( 3 );                             -- record contraint composant
    end record;

  type ARR is array ( 1 .. 3 ) of BUF( 2 );     -- record contraint element

  B  : BUF5;
  C  : BUF( 9 );                                -- contrainte directe sur objet
  N1 : NODE( LEAF );
  N2 : NODE( BINARY );
  P1 : BUF( 7 );
  P2 : BUF( 7 );
  W  : WRAP;
  A  : ARR;
  S  : INTEGER;

  procedure BUMP ( R : in out BUF ) is
  begin
    R.X := R.X + R.LEN;                         -- lecture du discriminant du formel
  end BUMP;

  function MAKE ( V : INTEGER ) return BUF5 is
    R : BUF5;
  begin
    R := ( 5, V, V + 1 );
    return R;
  end MAKE;

begin
  PUT_LINE( "=== R1 : elaboration des discriminants ===" );
  B.X := 10;  B.Y := 20;
  PUT_LINE( INTEGER'IMAGE( B.LEN ) );           --  5
  PUT_LINE( INTEGER'IMAGE( B.X + B.Y ) );       --  30
  PUT_LINE( INTEGER'IMAGE( C.LEN ) );           --  9

  PUT_LINE( "=== R2 : agregats avec discriminants ===" );
  B := ( 5, 1, 2 );                             -- positionnel
  C := ( LEN => 9, X => 3, Y => 4 );            -- nomme
  PUT_LINE( INTEGER'IMAGE( B.X + B.Y ) );       --  3
  PUT_LINE( INTEGER'IMAGE( C.X + C.Y ) );       --  7

  PUT_LINE( "=== R3 : variantes statiques ===" );
  N1 := ( LEAF,   1, 42 );
  N2 := ( BINARY, 2, 21, 22 );
  PUT_LINE( INTEGER'IMAGE( N1.VAL ) );          --  42
  PUT_LINE( INTEGER'IMAGE( N2.GAU + N2.DTE ) ); --  43
  if N1.PT = LEAF   then PUT_LINE( " 0" ); end if;
  if N2.PT = BINARY then PUT_LINE( " 2" ); end if;

  PUT_LINE( "=== R4 : affectation complete et egalite (sans variantes) ===" );
  P1 := ( 7, 100, 200 );
  P2 := P1;
  PUT_LINE( INTEGER'IMAGE( P2.Y ) );            --  200
  if P1 = P2 then PUT_LINE( "VRAI" ); else PUT_LINE( "FAUX" ); end if;  -- VRAI
  P2.X := 0;
  if P1 = P2 then PUT_LINE( "VRAI" ); else PUT_LINE( "FAUX" ); end if;  -- FAUX

  PUT_LINE( "=== R5 : composant de record et de tableau ===" );
  W.H := 1;
  W.P := ( 3, 8, 9 );
  PUT_LINE( INTEGER'IMAGE( W.P.X + W.P.Y ) );   --  17
  PUT_LINE( INTEGER'IMAGE( W.P.LEN ) );         --  3
  A( 2 ) := ( 2, 5, 6 );
  PUT_LINE( INTEGER'IMAGE( A( 2 ).Y ) );        --  6
  PUT_LINE( INTEGER'IMAGE( A( 2 ).LEN ) );      --  2

  PUT_LINE( "=== R6 : parametres et retour de fonction ===" );
  B := ( 5, 1, 2 );
  BUMP( B );
  PUT_LINE( INTEGER'IMAGE( B.X ) );             --  6
  declare
    Q : BUF5 := MAKE( 40 );
  begin
    PUT_LINE( INTEGER'IMAGE( Q.X ) );           --  40
    PUT_LINE( INTEGER'IMAGE( Q.Y ) );           --  41
    PUT_LINE( INTEGER'IMAGE( Q.LEN ) );         --  5
  end;

  PUT_LINE( "=== R7 : discriminant dans le controle ===" );
  case N2.PT is
    when LEAF   => PUT_LINE( " 0" );
    when UNARY  => PUT_LINE( " 1" );
    when BINARY => PUT_LINE( " 2" );            --  2
  end case;
  S := 0;
  for I in 1 .. B.LEN loop
    S := S + I;
  end loop;
  PUT_LINE( INTEGER'IMAGE( S ) );               --  15

  PUT_LINE( "=== fin RECORD_TEST1 ===" );
end RECORD_TEST1;
