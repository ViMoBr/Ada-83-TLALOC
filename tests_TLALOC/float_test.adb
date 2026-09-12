with TEXT_IO; use TEXT_IO;
procedure FLOAT_TEST is
  package FIO is new FLOAT_IO( FLOAT );
  X, Y, Z : FLOAT;
begin
  PUT_LINE("=== 1. Constantes ===");
  FIO.PUT(  3.14159, FORE=>2, AFT=>5, EXP=>3); NEW_LINE;
  FIO.PUT( -3.14159, FORE=>2, AFT=>5, EXP=>3); NEW_LINE;
  FIO.PUT(  0.0,     FORE=>2, AFT=>5, EXP=>3); NEW_LINE;
  FIO.PUT(  1.0,     FORE=>2, AFT=>5, EXP=>3); NEW_LINE;

  PUT_LINE("=== 2. Arithmetique ===");
  X := 2.5;
  Y := 3.0;
  Z := X + Y;  FIO.PUT(Z, FORE=>2, AFT=>2, EXP=>3); NEW_LINE;
  Z := X - Y;  FIO.PUT(Z, FORE=>2, AFT=>2, EXP=>3); NEW_LINE;
  Z := X * Y;  FIO.PUT(Z, FORE=>2, AFT=>2, EXP=>3); NEW_LINE;
  Z := X / Y;  FIO.PUT(Z, FORE=>2, AFT=>4, EXP=>3); NEW_LINE;

  PUT_LINE("=== 3. Negation et abs ===");
  X := -7.5;
  FIO.PUT(X,    FORE=>2, AFT=>2, EXP=>3); NEW_LINE;
  FIO.PUT(-X,   FORE=>2, AFT=>2, EXP=>3); NEW_LINE;
  FIO.PUT(abs X, FORE=>2, AFT=>2, EXP=>3); NEW_LINE;

  PUT_LINE("=== 4. Comparaisons ===");
  X := 1.0;
  Y := 2.0;
  if X < Y  then PUT_LINE("1.0 < 2.0 : OK"); end if;
  if Y > X  then PUT_LINE("2.0 > 1.0 : OK"); end if;
  if X <= X then PUT_LINE("1.0 <= 1.0 : OK"); end if;
  if X >= X then PUT_LINE("1.0 >= 1.0 : OK"); end if;
  if X /= Y then PUT_LINE("1.0 /= 2.0 : OK"); end if;
  X := 2.0;
  if X = Y  then PUT_LINE("2.0 = 2.0 : OK"); end if;

  PUT_LINE("=== 5. Negatifs ===");
  X := -1.0;
  Y := -2.0;
  if X > Y  then PUT_LINE("-1.0 > -2.0 : OK"); end if;
  if Y < X  then PUT_LINE("-2.0 < -1.0 : OK"); end if;

  PUT_LINE("=== 6. Conversion ===");
  X := FLOAT( 42 );
  FIO.PUT(X, FORE=>2, AFT=>1, EXP=>3); NEW_LINE;

  PUT_LINE("=== 7. Grands/petits ===");
  X := 123456.789;
  FIO.PUT(X, FORE=>2, AFT=>6, EXP=>3); NEW_LINE;
  X := 0.000123;
  FIO.PUT(X, FORE=>2, AFT=>6, EXP=>3); NEW_LINE;

  PUT_LINE("=== FIN ===");
end FLOAT_TEST;
