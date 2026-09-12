-- CHK_PREDEF0 : lit les bornes des scalaires PREDEFINIS de STANDARD
-- par le chemin USE-INFO (generique partage, GENERIC_FIRST_LAST via
-- __u) -- exactement le chemin que le site generique d'E-D emploiera.
-- Verifie que _INTEGER/_CHARACTER/_BOOLEAN .FST/.LST sont vivants a
-- l'execution. Clot le rectificatif n 80-b par la preuve positive.
with TEXT_IO; use TEXT_IO;

procedure CHK_PREDEF0 is

   generic
      type ELEM is (<>);
   procedure SHOW_BOUNDS (LABEL : STRING);

   procedure SHOW_BOUNDS (LABEL : STRING) is
   begin
      PUT_LINE ("CHK_PREDEF0 " & LABEL
              & " FIRST =" & INTEGER'IMAGE (ELEM'POS (ELEM'FIRST))
              & " LAST ="  & INTEGER'IMAGE (ELEM'POS (ELEM'LAST)));
   end SHOW_BOUNDS;

   procedure SHOW_INT  is new SHOW_BOUNDS (INTEGER);
   procedure SHOW_CHAR is new SHOW_BOUNDS (CHARACTER);
   procedure SHOW_BOOL is new SHOW_BOUNDS (BOOLEAN);

begin
   SHOW_INT  ("INTEGER  ");
   SHOW_CHAR ("CHARACTER");
   SHOW_BOOL ("BOOLEAN  ");
end CHK_PREDEF0;
