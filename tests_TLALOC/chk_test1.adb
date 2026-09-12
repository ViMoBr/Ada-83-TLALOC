----------------------------------------------------------------------
-- CHK_TEST1 : temoin E-D, une section par site. VERDISSEMENT
-- PROGRESSIF : avant la pose du site n, sa section imprime
-- "KO pas de levee" -- ATTENDU. Tout vert = E-D complete.
with TEXT_IO; use TEXT_IO;
procedure CHK_TEST1
is
   subtype SMALL is INTEGER range 1 .. 10;

   S : SMALL := 5;
   B : INTEGER := 7;                     -- valeur licite pour §1..§5 in-range
   R : INTEGER := 0;

   N : INTEGER := 20;
   function CLIP (P : SMALL) return SMALL is
   begin
      return P;
   end CLIP;
   function GROW (P : INTEGER) return SMALL is
   begin
      declare
         D : INTEGER := P + P;
      begin
         return D;                       -- §3 : return depuis un bloc
      end;
   end GROW;
   generic
      type ELEM is (<>);
   procedure GSET (X : in out ELEM; SRC : in out ELEM);
   procedure GSET (X : in out ELEM; SRC : in out ELEM) is
   begin
      X := SRC;                          -- §6 : affectation en corps partage
   end GSET;
   procedure SSET is new GSET (SMALL);

begin
   begin                                 -- §1 : init de declaration
      declare
         X : SMALL := N;                 -- 20 hors 1..10
      begin
         R := X;
         PUT_LINE ("CHK_TEST1 1 KO pas de levee");
      end;
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_TEST1 1 OK init de declaration");
   end;
   begin                                 -- §2 : parametre in
      R := CLIP (N);
      PUT_LINE ("CHK_TEST1 2 KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_TEST1 2 OK parametre in");
   end;
   begin                                 -- §3 : return (7+7=14 hors 1..10)
      R := GROW (B);
      PUT_LINE ("CHK_TEST1 3 KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_TEST1 3 OK return");
   end;
   begin                                 -- §4 : conversion
      R := SMALL (N);
      PUT_LINE ("CHK_TEST1 4 KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_TEST1 4 OK conversion");
   end;
   begin                                 -- §5 : qualification
      R := SMALL'(N);
      PUT_LINE ("CHK_TEST1 5 KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_TEST1 5 OK qualification");
   end;
   begin                                 -- §6 : corps generique partage
      declare
         T : SMALL := 3;
         U : SMALL := 9;
      begin
         SSET (T, U);                    -- licite : U=9 dans 1..10
         PUT_LINE ("CHK_TEST1 6a OK generique licite, T =" & INTEGER'IMAGE (T));
      end;
      SSET (S, S);                       -- licite aussi ; le cas HORS bornes
      PUT_LINE ("CHK_TEST1 6b consigne : violation generique testable");
      -- quand un moyen licite Ada de passer une valeur hors bornes du
      -- formel existera (via base non contrainte), etendre ce temoin.
   end;
   -- §7 : rien n'a leve a tort, valeurs saines
   if  R = 0  and  S = 5  then
      PUT_LINE ("CHK_TEST1 7 OK aucune levee parasite");
   else
      PUT_LINE ("CHK_TEST1 7 KO R =" & INTEGER'IMAGE (R));
   end if;
   -- §8 : non rattrapee -> sentinelle (DERNIERE section)
   PUT_LINE ("CHK_TEST1 8 attendu : EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR, $? = 1");
   R := CLIP (N) + 1;
   PUT_LINE ("CHK_TEST1 8 KO ligne atteinte");
end CHK_TEST1;
