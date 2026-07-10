-- CHK_ANON2 : sonde n 2 du residu A54B02A -- AVEC REPORT cette fois.
-- Bissecte le trajet reel : bloc L2 -> IDENT_INT L1 -> EQUAL L1
-- (recursif, PORTEUR DE HANDLER : contexte pilier 11 empile/depile a
-- chaque appel). Phases :
--   levee avant P1 : machinerie TEST/PUT_MSG (banniere)
--   entre P1 et P2 : IDENT_INT/EQUAL hors de toute elaboration
--   entre P2 et P3 : ELABORATION du sous-type (store des bornes)
--   entre P3 et P4 : LE SITE J (lecture des bornes par le check)
--   entre P4 et P5 : lecture directe des bornes par attribut (DYN'FIRST
--                    et DYN'LAST imprimes : diagnostic des valeurs)
with REPORT;  use REPORT;
with TEXT_IO; use TEXT_IO;

procedure CHK_ANON2 is
   K : INTEGER;
begin
   TEST ("CHK_ANON2", "SONDE DU RESIDU A54B02A AVEC UNE DESCRIPTION" &
         " SUFFISAMMENT LONGUE POUR FORCER LA CESURE DE PUT_MSG SUR" &
         " PLUSIEURS LIGNES COMME DANS LE TEST D ORIGINE");
   PUT_LINE ("CHK_ANON2 P1 banniere passee");

   K := IDENT_INT (2);
   PUT_LINE ("CHK_ANON2 P2 IDENT_INT/EQUAL passes hors elaboration");

   declare
      subtype STAT is INTEGER range 1 .. 50;
      subtype DYN  is STAT range 1 .. IDENT_INT (5);
      J : DYN;
   begin
      PUT_LINE ("CHK_ANON2 P3 elaboration du bloc passee");

      J := IDENT_INT (2);
      PUT_LINE ("CHK_ANON2 P4 site J passe : pas de levee");

      PUT_LINE ("CHK_ANON2 P5 DYN'FIRST =" & INTEGER'IMAGE (DYN'FIRST)
              & " DYN'LAST ="  & INTEGER'IMAGE (DYN'LAST));
   end;

   PUT_LINE ("CHK_ANON2 P6 fin");
   RESULT;
end CHK_ANON2;
