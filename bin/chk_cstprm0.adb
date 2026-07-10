-- CHK_CSTPRM0 : temoin du fossile n 81. Constantes scalaires en
-- position d'ACTUEL DIRECT, valeurs VERIFIEES (pas seulement absence
-- de plantage -- c'est l'invisibilite par non-verification qui a
-- protege le fossile pendant des mois).
with TEXT_IO; use TEXT_IO;

procedure CHK_CSTPRM0 is
   CST3 : constant INTEGER   := 3;
   N    : INTEGER            := 4;
   CDYN : constant INTEGER   := N + 3;              -- constante a valeur DYNAMIQUE
   CCH  : constant CHARACTER := 'K';                -- constante enumeree (non-regression LI)

   function SUM (A, B : INTEGER) return INTEGER is
   begin
      return A + B;
   end SUM;

   function PICK (C : CHARACTER; I : INTEGER) return INTEGER is
   begin
      if  C = 'K'  then
         return I;
      end if;
      return -1;
   end PICK;

   -- mimique EXACTE du motif d'EQUAL fautif : constante en 1er actuel,
   -- expression en 2eme, appel recursif
   function EQ (X, Y : INTEGER) return BOOLEAN is
   begin
      if  X > CST3  then
         return EQ (CST3, Y - X + CST3);
      elsif  X > 0  then
         return EQ (X - 1, Y - 1);
      else
         return Y = 0;
      end if;
   end EQ;

begin
   -- 1 : constante en 1er actuel
   if  SUM (CST3, N) = 7  then
      PUT_LINE ("CHK_CSTPRM0 1 OK constante en 1er actuel");
   else
      PUT_LINE ("CHK_CSTPRM0 1 KO");
   end if;

   -- 2 : constante en 2eme actuel
   if  SUM (N, CST3) = 7  then
      PUT_LINE ("CHK_CSTPRM0 2 OK constante en 2eme actuel");
   else
      PUT_LINE ("CHK_CSTPRM0 2 KO");
   end if;

   -- 3 : deux constantes
   if  SUM (CST3, CST3) = 6  then
      PUT_LINE ("CHK_CSTPRM0 3 OK deux constantes");
   else
      PUT_LINE ("CHK_CSTPRM0 3 KO");
   end if;

   -- 4 : constante a valeur DYNAMIQUE (le cas que LI SM_VALUE raterait)
   if  SUM (CDYN, 0) = 7  then
      PUT_LINE ("CHK_CSTPRM0 4 OK constante dynamique");
   else
      PUT_LINE ("CHK_CSTPRM0 4 KO");
   end if;

   -- 5 : constante enumeree (non-regression de la branche LI)
   if  PICK (CCH, 9) = 9  then
      PUT_LINE ("CHK_CSTPRM0 5 OK constante enumeree");
   else
      PUT_LINE ("CHK_CSTPRM0 5 KO");
   end if;

   -- 6 : le motif EQUAL exact, recursif
   if  EQ (5, 5)  and  not EQ (5, 6)  then
      PUT_LINE ("CHK_CSTPRM0 6 OK motif EQUAL recursif");
   else
      PUT_LINE ("CHK_CSTPRM0 6 KO");
   end if;
end CHK_CSTPRM0;
