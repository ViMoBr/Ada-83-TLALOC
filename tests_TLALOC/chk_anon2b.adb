-- CHK_ANON2B : la sonde 2 (avec REPORT) mais les bornes sont IMPRIMEES
-- AVANT le site J, dans des INTEGER (aucun check sur ces cibles).
-- Donne la valeur reelle de DYN'FIRST/DYN'LAST au moment ou le check
-- de J va les lire.
with REPORT;  use REPORT;
with TEXT_IO; use TEXT_IO;

procedure CHK_ANON2B is
   F, L : INTEGER;
begin
   TEST ("CHK_ANON2B", "SONDE 2B : BORNES IMPRIMEES AVANT LE SITE J");
   PUT_LINE ("CHK_ANON2B P1 banniere passee");

   declare
      subtype STAT is INTEGER range 1 .. 50;
      subtype DYN  is STAT range 1 .. IDENT_INT (5);
      J : DYN;
   begin
      F := DYN'FIRST;
      L := DYN'LAST;
      PUT_LINE ("CHK_ANON2B P2 FIRST =" & INTEGER'IMAGE (F)
              & " LAST ="  & INTEGER'IMAGE (L));

      J := IDENT_INT (2);
      PUT_LINE ("CHK_ANON2B P3 site J passe");
   end;

   PUT_LINE ("CHK_ANON2B P4 fin");
   RESULT;
end CHK_ANON2B;
