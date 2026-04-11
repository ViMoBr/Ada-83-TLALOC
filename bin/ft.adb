with TEXT_IO; use TEXT_IO;
procedure FT is
  package FIO is new FLOAT_IO( FLOAT );
  X : FLOAT :=  3.14159;
  Y : FLOAT :=  -3.14159;
begin
  if X > 0.0 then
    PUT( "X= " ); FIO.PUT( X );
    PUT_LINE(" X est positif");
  end if;

  if Y < 0.0 then
    PUT( "Y= " ); FIO.PUT( Y );
    PUT_LINE(" Y est negatif");
  end if;

end FT;
