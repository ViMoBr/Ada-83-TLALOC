-- CHK_CSTPRM2 : temoin du n 81 ter. Constante DIFFEREE d'un type PRIVE
-- en actuel direct -- le motif exact de TREE_VOID. Paquet imbrique
-- dans la procedure (si cette forme posait probleme au frontend,
-- repli : sortir P en unite de bibliotheque, meme contenu).
with TEXT_IO; use TEXT_IO;

procedure CHK_CSTPRM2 is

   R : INTEGER := 0;

   package P is
      type T is private;
      C : constant T;                                -- constante DIFFEREE
      function GET (V : T) return INTEGER;
   private
      type T is record
         VAL : INTEGER;
      end record;
      C : constant T := (VAL => 42);
   end P;

   package body P is
      function GET (V : T) return INTEGER is
      begin
         return V.VAL;
      end GET;
   end P;

   use P;

begin
   R := GET (C);                                     -- actuel = constante privee
   if  R = 42  then
      PUT_LINE ("CHK_CSTPRM2 1 OK constante privee differee en actuel");
   else
      PUT_LINE ("CHK_CSTPRM2 1 KO valeur" & INTEGER'IMAGE (R));
   end if;
end CHK_CSTPRM2;
