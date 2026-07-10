-- CHK_ANON0 : temoin du piege n 80 (fossile A54B02A).
-- 1-2 : plus de FAUX POSITIF sur sous-type anonyme (le motif exact du
--       fossile : contrainte dynamique dans la declaration d'objet).
-- 3-4 : les sous-types NOMMES dynamiques restent controles (non-regression).
-- 5   : DETTE CONSIGNEE, comportement FIGE : la contrainte anonyme n'est
--       PAS controlee -- une violation passe en silence. Si cette section
--       passe a "levee" un jour, c'est que la dette a ete soldee : mettre
--       a jour ce temoin et la note.
with TEXT_IO; use TEXT_IO;

procedure CHK_ANON0 is
   N : INTEGER := 5;
   I : INTEGER range 1 .. N;          -- sous-type ANONYME dynamique (motif A54B02A)
   subtype DYN is INTEGER range 1 .. N;
   J : DYN;
begin
   -- 1 : affectation dans la contrainte anonyme -> AUCUNE levee
   I := 2;
   PUT_LINE ("CHK_ANON0 1 OK anonyme dans les bornes, pas de faux positif");

   -- 2 : meme motif exact que A54B02A (valeur via variable)
   I := N - 3;
   PUT_LINE ("CHK_ANON0 2 OK anonyme, valeur dynamique, pas de faux positif");

   -- 3 : sous-type NOMME, dans les bornes -> pas de levee
   J := 2;
   PUT_LINE ("CHK_ANON0 3 OK nomme dans les bornes");

   -- 4 : sous-type NOMME, hors bornes -> CONSTRAINT_ERROR (non-regression E-A)
   begin
      J := N + 4;
      PUT_LINE ("CHK_ANON0 4 KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_ANON0 4 OK nomme hors bornes leve");
   end;

   -- 5 : DETTE (piege n 80) : contrainte ANONYME hors bornes NON controlee
   I := N + 4;
   PUT_LINE ("CHK_ANON0 5 OK dette consignee : anonyme hors bornes passe en silence");
end CHK_ANON0;
