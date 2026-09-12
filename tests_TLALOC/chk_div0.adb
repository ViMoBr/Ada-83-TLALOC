-- CHK_DIV0 : temoin E-E. Juge : (1) valeurs justes hors zero (le DUP
-- ne desequilibre rien) ; (2-4) /0, rem 0, mod 0 -> NUMERIC_ERROR --
-- et PAS CONSTRAINT_ERROR : c'est le juge concret de Q7 ; (5) non
-- rattrapee -> la sentinelle NOMME NUMERIC_ERROR (premier exercice de
-- l'identite via ne_raise_), $? = 1.
with TEXT_IO; use TEXT_IO;

procedure CHK_DIV0 is
   A : INTEGER := 12;
   Z : INTEGER := 0;
   R : INTEGER := 0;
begin
   if  A / 4 = 3  and  A rem 5 = 2  and  A mod (-5) = -3  then
      PUT_LINE ("CHK_DIV0 1 OK valeurs justes");
   else
      PUT_LINE ("CHK_DIV0 1 KO");
   end if;

   begin
      R := A / Z;
      PUT_LINE ("CHK_DIV0 2 KO pas de levee");
   exception
      when NUMERIC_ERROR    => PUT_LINE ("CHK_DIV0 2 OK NUMERIC_ERROR sur /");
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_DIV0 2 KO mauvaise exception");
   end;

   begin
      R := A rem Z;
      PUT_LINE ("CHK_DIV0 3 KO pas de levee");
   exception
      when NUMERIC_ERROR    => PUT_LINE ("CHK_DIV0 3 OK NUMERIC_ERROR sur rem");
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_DIV0 3 KO mauvaise exception");
   end;

   begin
      R := A mod Z;
      PUT_LINE ("CHK_DIV0 4 KO pas de levee");
   exception
      when NUMERIC_ERROR    => PUT_LINE ("CHK_DIV0 4 OK NUMERIC_ERROR sur mod");
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_DIV0 4 KO mauvaise exception");
   end;

   PUT_LINE ("CHK_DIV0 5 attendu : EXCEPTION NON RATTRAPEE : NUMERIC_ERROR, $? = 1");
   R := (A + R) / Z;
   PUT_LINE ("CHK_DIV0 5 KO ligne atteinte");
end CHK_DIV0;
