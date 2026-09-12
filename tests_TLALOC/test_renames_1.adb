with TEXT_IO;
procedure TEST_RENAMES_1
is

  package INT_IO is new TEXT_IO.INTEGER_IO(INTEGER);
  use TEXT_IO, INT_IO;

  type REC is record
    A : INTEGER;
    B : INTEGER;
  end record;

  type TAB is array (1 .. 3) of REC;

  R : REC := (A => 10, B => 20);
  T : TAB := ((1,2), (3,4), (5,6));

  X	: INTEGER	renames R.B;
  Y	: REC	renames T(2);
  R2	: REC	renames Y;

begin
  PUT("X avant = "); PUT(X); NEW_LINE;

  X := 99;
  PUT("R.B apres X := 99 = "); PUT(R.B); NEW_LINE;

  Y.A := 300;
  Y.B := 400;

  PUT( "T(2).A = " ); PUT( T(2).A ); NEW_LINE;
  PUT( "T(2).B = " ); PUT( T(2).B ); NEW_LINE;

  Y := R;
  R.A := 111;
  R.B := 222;

  PUT( "R.A = " ); PUT( R.A ); NEW_LINE;
  PUT( "R.B = " ); PUT( R.B ); NEW_LINE;

  Y.A := 333;
  Y.B := 444;

  PUT( "Y.A = " ); PUT( Y.A ); NEW_LINE;
  PUT( "Y.B = " ); PUT( Y.B ); NEW_LINE;

end	TEST_RENAMES_1;
