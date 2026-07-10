-- CHK_IDX0 : temoin E-C. Une section par variante de CODE_INDEXED :
-- variable locale (__u), NEGATIF (temoin signe), parametre non
-- contraint (bornes du DESCRIPTEUR), composante de record (type
-- direct), multi-dim (dim 1 ET dim 2), access implicite P(I) et
-- explicite P.all(I), indexe imbrique T2(1)(I). Les sections 1 et 10
-- jugent l'ABSENCE de faux positifs et l'exactitude des valeurs.
with TEXT_IO; use TEXT_IO;

procedure CHK_IDX0 is
   type VEC   is array (INTEGER range <>) of INTEGER;
   type MAT   is array (1 .. 2, 1 .. 3) of INTEGER;
   type ROW   is array (1 .. 3) of INTEGER;
   type TAB2  is array (1 .. 2) of ROW;
   type VEC5C is array (1 .. 5) of INTEGER;
   type PV    is access VEC5C;
   type REC   is record
      A : ROW;
   end record;

   V  : VEC (1 .. 3) := (10, 20, 30);
   M  : MAT  := ((1, 2, 3), (4, 5, 6));
   T2 : TAB2 := ((1, 2, 3), (4, 5, 6));
   P  : PV   := new VEC5C'(others => 0);
   R  : REC  := (A => (7, 8, 9));

   K  : INTEGER := 2;
   KH : INTEGER := 9;
   KN : INTEGER := -1;

   function GET (X : VEC; I : INTEGER) return INTEGER is
   begin
      return X (I);              -- chemin IS_PARAM (bornes du descripteur)
   end GET;

begin
   -- 1 : lecture/ecriture dans les bornes, index dynamique -> valeurs justes
   V (K) := V (K) + 5;
   if  V (2) = 25  then
      PUT_LINE ("CHK_IDX0 1 OK indexation dans les bornes, valeurs justes");
   else
      PUT_LINE ("CHK_IDX0 1 KO valeurs fausses");
   end if;

   -- 2 : variable locale, hors bornes par le HAUT (ecriture)
   begin
      V (KH) := 0;
      PUT_LINE ("CHK_IDX0 2 KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_IDX0 2 OK variable, haut");
   end;

   -- 3 : variable locale, index NEGATIF (temoin signe)
   begin
      V (KN) := 0;
      PUT_LINE ("CHK_IDX0 3 KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_IDX0 3 OK variable, negatif");
   end;

   -- 4 : parametre non contraint -> bornes lues dans le DESCRIPTEUR
   begin
      if  GET (V, 4) = 0  then null; end if;
      PUT_LINE ("CHK_IDX0 4 KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_IDX0 4 OK parametre, descripteur");
   end;

   -- 5 : composante de record R.A(I) -> infos du type, chemin direct
   begin
      R.A (KH) := 0;
      PUT_LINE ("CHK_IDX0 5 KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_IDX0 5 OK composante de record");
   end;

   -- 6a : multi-dim, violation en DIMENSION 1
   begin
      M (KH, 1) := 0;
      PUT_LINE ("CHK_IDX0 6a KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_IDX0 6a OK multi-dim, dim 1");
   end;

   -- 6b : multi-dim, violation en DIMENSION 2 (dim 1 valide)
   begin
      M (1, KH) := 0;
      PUT_LINE ("CHK_IDX0 6b KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_IDX0 6b OK multi-dim, dim 2");
   end;

   -- 7a : access, dereference IMPLICITE P(I)
   begin
      P (KH) := 0;
      PUT_LINE ("CHK_IDX0 7a KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_IDX0 7a OK access implicite");
   end;

   -- 7b : access, dereference EXPLICITE P.all(I)
   begin
      P.all (KH) := 0;
      PUT_LINE ("CHK_IDX0 7b KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_IDX0 7b OK access explicite");
   end;

   -- 8 : indexe imbrique T2(1)(I)
   begin
      T2 (1)(KH) := 0;
      PUT_LINE ("CHK_IDX0 8 KO pas de levee");
   exception
      when CONSTRAINT_ERROR => PUT_LINE ("CHK_IDX0 8 OK indexe imbrique");
   end;

   -- 9 : apres toutes les levees, tout est intact et dans les bornes
   P.all (5) := 55;
   T2 (2)(1) := 44;
   if  M (2, 3) = 6  and  V (2) = 25  and  GET (V, 3) = 30
       and  P (5) = 55  and  T2 (2)(1) = 44  and  R.A (2) = 8
   then
      PUT_LINE ("CHK_IDX0 9 OK etat intact apres les levees");
   else
      PUT_LINE ("CHK_IDX0 9 KO etat altere");
   end if;

   -- 10 : non rattrapee -> sentinelle (DERNIERE section)
   PUT_LINE ("CHK_IDX0 10 attendu : EXCEPTION NON RATTRAPEE : CONSTRAINT_ERROR, $? = 1");
   V (KH) := 0;
   PUT_LINE ("CHK_IDX0 10 KO ligne atteinte apres violation");
end CHK_IDX0;
