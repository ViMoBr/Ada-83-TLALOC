with TEXT_IO; use TEXT_IO;
procedure GET_TEST is
  package FIO is new FLOAT_IO( FLOAT );
  X : FLOAT;
begin
  PUT("Entrez un flottant : ");
  FIO.GET( X );
  PUT("Vous avez entre : ");
  FIO.PUT( X, FORE=>2, AFT=>6, EXP=>3 );
  NEW_LINE;
end GET_TEST;
