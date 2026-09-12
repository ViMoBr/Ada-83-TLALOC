-- CHK_CSTPRM1 : temoin du n 81 bis. Constantes COMPOSITES en actuel
-- direct : record et tableau contraint (STRING nommee). Valeurs
-- verifiees a travers l'appel, dans les deux sens (lecture du contenu
-- passe, et non-alteration apres l'appel).
with TEXT_IO; use TEXT_IO;

procedure CHK_CSTPRM1 is
   type PAIR is record
      A, B : INTEGER;
   end record;

   CP : constant PAIR   := (A => 3, B => 4);
   CS : constant STRING := "TLALOC";
   V  : INTEGER := 0;

   function PSUM (P : PAIR) return INTEGER is
   begin
      return P.A + P.B;
   end PSUM;

   function NTH (S : STRING; I : INTEGER) return CHARACTER is
   begin
      return S (I);
   end NTH;

begin
   -- 1 : constante record en actuel
   V := PSUM (CP);
   if  V = 7  then
      PUT_LINE ("CHK_CSTPRM1 1 OK constante record");
   else
      PUT_LINE ("CHK_CSTPRM1 1 KO");
   end if;

   -- 2 : constante STRING (tableau contraint) en actuel, bornes du
   --     descripteur exercees par l'index check E-C au passage
   if  NTH (CS, 1) = 'T'  and  NTH (CS, 6) = 'C'  then
      PUT_LINE ("CHK_CSTPRM1 2 OK constante tableau contraint");
   else
      PUT_LINE ("CHK_CSTPRM1 2 KO");
   end if;

   -- 3 : la constante n'a pas ete alteree par le passage
   if  CP.A = 3  and  CP.B = 4  and  CS (3) = 'A'  then
      PUT_LINE ("CHK_CSTPRM1 3 OK constantes intactes");
   else
      PUT_LINE ("CHK_CSTPRM1 3 KO");
   end if;
end CHK_CSTPRM1;
