-- CHK_ANON3 : sonde n 3. Reproduit SANS REPORT la vraie signature du
-- trajet A54B02A : la borne du sous-type vient d'une fonction dont le
-- corps passe par une fonction RECURSIVE et PORTEUSE DE HANDLER (mimique
-- d'EQUAL : contexte de reprise pilier 11 empile/depile a chaque appel).
-- P1 imprime les bornes AVANT le site J (cibles INTEGER : aucune
-- interference de check). Lectures possibles :
--   P1 = 1 et 5, P2 passe   -> non reproduit : discriminant chez REPORT
--   P1 = 1 et autre chose   -> l'ELABORATION a stocke un debris : le
--                              protocole resultat a travers handler +
--                              recursion est le fossile, reproduit ici
--   P1 = 1 et 5, P2 leve    -> les donnees sont saines, la LECTURE du
--                              check est fautive (tres improbable)
with TEXT_IO; use TEXT_IO;

procedure CHK_ANON3 is

   F, L : INTEGER;

   function EQ (X, Y : INTEGER) return BOOLEAN is
      Z : BOOLEAN;
   begin
      if  X > 0  then
         Z := EQ (X - 1, Y - 1);        -- recursion, comme EQUAL
      else
         Z := Y = 0;
      end if;
      return Z;
   exception
      when others => return FALSE;      -- HANDLER, comme EQUAL
   end EQ;

   function IDENT (X : INTEGER) return INTEGER is
   begin
      if  EQ (X, X)  then
         return X;
      end if;
      return 0;
   end IDENT;

begin
   PUT_LINE ("CHK_ANON3 P0");

   declare
      subtype STAT is INTEGER range 1 .. 50;
      subtype DYN  is STAT range 1 .. IDENT (5);
      J : DYN;
   begin
      F := DYN'FIRST;
      L := DYN'LAST;
      PUT_LINE ("CHK_ANON3 P1 FIRST =" & INTEGER'IMAGE (F)
              & " LAST ="  & INTEGER'IMAGE (L));

      J := IDENT (2);
      PUT_LINE ("CHK_ANON3 P2 site J passe");
   end;

   PUT_LINE ("CHK_ANON3 P3 fin");
end CHK_ANON3;
