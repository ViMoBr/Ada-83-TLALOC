------------------------------------------------------------------------
--	M6. NOUVEAU FICHIER : chk_test0.adb (temoin auto-jugeant E-A)
------------------------------------------------------------------------

-- CHK_TEST0 : temoin E-A du pilier checks. Juge le chemin COMPLET
-- check -> BT STANDARD.ce_raise_ -> trampoline -> deroulage pilier 11,
-- rattrape (2,3,4) et non rattrape (6, sentinelle + $? = 1).
-- Section 2 = temoin SIGNE obligatoire (valeur negative, cf. lot D2).
-- Section 5 = valeur non alteree par les checks (DUP preservant) ET
-- levee AVANT store (S garde sa valeur d'avant les violations).
with TEXT_IO; use TEXT_IO;

procedure CHK_TEST0
is
   subtype SMALL is INTEGER   range 1 .. 10;
   subtype UPPER is CHARACTER range 'A' .. 'Z';
   S    : SMALL     := 5;
   C    : UPPER     := 'A';
   I    : INTEGER   := 7;
   NEGV : INTEGER   := -3;
   CH   : CHARACTER := 'q';

begin
   -- 1 : dans les bornes -> aucune levee
   S := I;
   PUT_LINE ("CHK_TEST0 1 OK affectation dans les bornes");

   -- 2 : hors bornes par le BAS, valeur NEGATIVE (temoin signe)
   begin
      S := NEGV;
      PUT_LINE ("CHK_TEST0 2 KO pas de levee");
   exception
      when CONSTRAINT_ERROR =>
         PUT_LINE ("CHK_TEST0 2 OK CONSTRAINT_ERROR rattrapee (borne basse, negatif)");
   end;

   -- 3 : hors bornes par le HAUT (expression, pas une variable simple)
   begin
      S := I + I;
      PUT_LINE ("CHK_TEST0 3 KO pas de levee");
   exception
      when CONSTRAINT_ERROR =>
         PUT_LINE ("CHK_TEST0 3 OK CONSTRAINT_ERROR rattrapee (borne haute)");
   end;

   -- 4 : enumere contraint (CHARACTER minuscule hors 'A'..'Z')
   begin
      C := CH;
      PUT_LINE ("CHK_TEST0 4 KO pas de levee");
   exception
      when CONSTRAINT_ERROR =>
         PUT_LINE ("CHK_TEST0 4 OK CONSTRAINT_ERROR rattrapee (enumere)");
   end;

   -- 5 : S vaut encore 7 (section 1) : les levees 2 et 3 ont eu lieu
   --     AVANT le store, et les DUP des checks n'alterent pas la valeur
   if  S = 7  then
      PUT_LINE ("CHK_TEST0 5 OK valeur preservee");
   else
      PUT_LINE ("CHK_TEST0 5 KO valeur alteree");
   end if;

   -- 6 : non rattrapee -> sentinelle (DERNIERE section)
   PUT_LINE ("CHK_TEST0 6 attendu : EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR, $? = 1");
   S := NEGV;
   PUT_LINE ("CHK_TEST0 6 KO ligne atteinte apres violation");
end CHK_TEST0;
