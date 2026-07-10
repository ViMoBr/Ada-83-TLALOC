-- CHK_DUMP0 : programme de TRAVAIL du pilier checks (etape E-0).
-- Objet : DUMP DIANA seulement -- confirmer les formes d'arbre aux sites
-- d'emission et trancher Q5 (fixed) / Q6 (generiques) AVANT tout codage.
-- Un site par section ; les violations de gamme sont DYNAMIQUES (variables,
-- pas de statique) pour que sem laisse passer et que le site soit exerce.
-- Ce programme n'est PAS le temoin auto-jugeant (CHK_TEST0/1 viendront apres).

with TEXT_IO; use TEXT_IO;

procedure CHK_DUMP0 is

   -- Section A : sous-type a bornes STATIQUES ------------------------------
   subtype SMALL is INTEGER range 1 .. 10;
   S : SMALL := 5;
   I : INTEGER := 7;

   -- Section B : sous-type a bornes DYNAMIQUES -----------------------------
   N : INTEGER := 8;
   subtype DYN is INTEGER range 1 .. N;
   D : DYN := 1;

   -- Section C : temoin SIGNE (negatif vers sous-type positif, cf. lot D2) -
   NEGV : INTEGER := -3;

   -- Section D : enumere contraint (CHARACTER) -----------------------------
   subtype UPPER is CHARACTER range 'A' .. 'Z';
   C  : UPPER := 'A';
   CH : CHARACTER := 'Q';

   -- Section E : index check (bornes du descripteur) ------------------------
   V : array (1 .. 5) of INTEGER;
   K : INTEGER := 3;

   -- Section F : FIXED (Q5 -- bornes scalees ou en unites du type ?) --------
   type FIX is delta 0.125 range -4.0 .. 4.0;
   subtype FPOS is FIX range 0.0 .. 2.0;
   F : FPOS := 0.5;
   G : FIX := 1.5;

   -- Section H : logiques composites (dette D3-controle) --------------------
   type BVEC is array (INTEGER range <>) of BOOLEAN;
   B3 : BVEC (1 .. 3) := (others => TRUE);
   B5 : BVEC (1 .. 5) := (others => FALSE);

   -- Section K : division par zero (site DIV utilisateur, futur ne_raise_) --
   Z : INTEGER := 0;

   -- Section G : generique (Q6 -- bornes du formel en corps partage) --------
   generic
      type ELEM is (<>);
   procedure GEN_ASSIGN (X : in out ELEM);

   procedure GEN_ASSIGN (X : in out ELEM) is
      Y : ELEM;
   begin
      Y := X;                    -- gamme du FORMEL : chemin __u ?
      X := Y;
   end GEN_ASSIGN;

   procedure S_ASSIGN is new GEN_ASSIGN (SMALL);

   -- Sections I/J : sites param in et return --------------------------------
   function TWICE (P : SMALL) return SMALL is
   begin
      return P + P;              -- J : check au return (P=7 -> 14, leverait)
   end TWICE;

begin
   S := I;                       -- A  : affectation, bornes statiques
   D := I;                       -- B  : affectation, bornes dynamiques
   S := NEGV;                    -- C  : temoin signe
   C := CH;                      -- D  : enumere
   V (K) := S;                   -- E  : index dynamique
   F := G;                       -- F  : fixed vers sous-type contraint
   B3 := B3 and B5;              -- H  : longueurs inegales (LEN_G /= LEN_D)
   S := SMALL (I);               -- I1 : conversion
   S := SMALL'(I);               -- I2 : qualification
   I := TWICE (S);               -- I3/J : param in + return
   S_ASSIGN (S);                 -- G  : instance generique
   I := I / Z;                   -- K  : division par zero
   PUT_LINE ("CHK_DUMP0 FIN");   -- (atteint tant que les checks n'existent pas)
end CHK_DUMP0;
