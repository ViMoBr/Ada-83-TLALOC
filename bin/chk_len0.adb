-- CHK_LEN0 : temoin E-B. Juge le check LEN_G = LEN_D des logiques
-- composites : levee sur longueurs inegales (2, 5), PAS de levee ni
-- de resultat fausse sur longueurs egales (1), y compris via tranches
-- dynamiques (3) et tableaux NULS des deux cotes (4, piege n 52).
with TEXT_IO; use TEXT_IO;

procedure CHK_LEN0 is
   type BVEC is array (INTEGER range <>) of BOOLEAN;
   B3A : BVEC (1 .. 3) := (TRUE,  TRUE,  FALSE);
   B3B : BVEC (1 .. 3) := (TRUE,  FALSE, TRUE);
   B5  : BVEC (1 .. 5) := (others => TRUE);
   R3  : BVEC (1 .. 3) := (others => FALSE);
begin
   -- 1 : longueurs egales -> pas de levee ET resultat juste
   R3 := B3A and B3B;
   if  R3 (1) and not R3 (2) and not R3 (3)  then
      PUT_LINE ("CHK_LEN0 1 OK and 3/3 sans levee, resultat juste");
   else
      PUT_LINE ("CHK_LEN0 1 KO resultat faux");
   end if;

   -- 2 : longueurs inegales (3 vs 5) -> CONSTRAINT_ERROR rattrapee
   begin
      R3 := B3A and B5;
      PUT_LINE ("CHK_LEN0 2 KO pas de levee");
   exception
      when CONSTRAINT_ERROR =>
         PUT_LINE ("CHK_LEN0 2 OK CONSTRAINT_ERROR rattrapee (3 vs 5)");
   end;

   -- 3 : tranches dynamiques de MEME longueur -> pas de levee
   R3 := B5 (1 .. 3) xor B5 (2 .. 4);
   PUT_LINE ("CHK_LEN0 3 OK xor de tranches 3/3 sans levee");

   -- 4 : deux tableaux NULS -> longueurs 0 = 0, pas de levee
   declare
      N1 : BVEC (1 .. 0);
      N2 : BVEC (5 .. 4);
   begin
      N1 := N1 or N2;
      PUT_LINE ("CHK_LEN0 4 OK or de tableaux nuls sans levee");
   end;

   -- 5 : non rattrapee -> sentinelle (DERNIERE section)
   PUT_LINE ("CHK_LEN0 5 attendu : EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR, $? = 1");
   R3 := B5 (1 .. 2) or B3A;
   PUT_LINE ("CHK_LEN0 5 KO ligne atteinte apres violation");
end CHK_LEN0;
