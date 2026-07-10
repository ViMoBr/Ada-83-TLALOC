-- CHK_ANON1 : sonde de bissection du residu A54B02A.
-- Reproduit les DEUX differences entre chk_anon0 (qui passe) et
-- A54B02A (qui leve) : sous-type nomme elabore dans un BLOC DECLARE
-- IMBRIQUE, borne haute fournie par un APPEL DE FONCTION pendant
-- l'elaboration. Sans REPORT : si P2 leve, le residu est reproduit
-- localement (m'envoyer CHK_ANON1.FINC, petit et dissecable) ; si tout
-- passe, le discriminant est du cote de REPORT ou d'autre chose dans
-- A54B02A (m'envoyer le NOUVEAU A54B02A.FINC).
with TEXT_IO; use TEXT_IO;

procedure CHK_ANON1 is

   function IDENT (X : INTEGER) return INTEGER is
   begin
      return X;
   end IDENT;

begin
   PUT_LINE ("CHK_ANON1 P0 avant bloc");

   declare
      subtype STAT is INTEGER range 1 .. 50;
      subtype DYN  is STAT range 1 .. IDENT (5);   -- borne par APPEL, bloc IMBRIQUE
      J : DYN;
   begin
      PUT_LINE ("CHK_ANON1 P1 elaboration du bloc passee");

      J := IDENT (2);
      PUT_LINE ("CHK_ANON1 P2 J affecte : pas de faux positif");

      begin
         J := IDENT (9);
         PUT_LINE ("CHK_ANON1 P3 KO pas de levee");
      exception
         when CONSTRAINT_ERROR =>
            PUT_LINE ("CHK_ANON1 P3 OK 9 hors 1..5 leve");
      end;
   end;

   PUT_LINE ("CHK_ANON1 P4 fin");
end CHK_ANON1;
