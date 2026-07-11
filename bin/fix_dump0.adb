with TEXT_IO; use TEXT_IO;
procedure FIX_DUMP0 is

  -- SMALL puissance de 2, NUMER = 1 (cas nominal, celui de DURATION)
  type T8  is delta 0.125   range -100.0 .. 100.0;     -- small attendu 1/8 ou 1/16
  type T16 is delta 0.0625  range -100.0 .. 100.0;     -- small attendu 1/16

  -- SMALL explicite NUMER /= 1  (Q4)  : 3/4 n'est PAS 1/2^k
  type T34 is delta 1.0     range -1000.0 .. 1000.0;
  for T34'SMALL use 3.0/4.0;

  -- SMALL explicite equivalent par reduction : 2/32 == 1/16  (Q6)
  type TEQ is delta 0.0625  range -100.0 .. 100.0;
  for TEQ'SMALL use 2.0/32.0;

  subtype S8 is T8 range -1.0 .. 1.0;              -- Q1b-bis : sous-type fixed = le PAS FAIT
  S : S8 := 0.5;                                   --   (cas DAY_DURATION), forme du subtype_decl

  A : T8  := 2.5;
  B : T8  := 4.0;
  C : T16 := 0.0;
  D : T34 := 6.0;
  E : TEQ := 0.0;
  N : INTEGER := 3;

begin
  -- (1) Q1/Q2 : SM_EXP_TYPE de A*B ?  universal_fixed ?  arbre sous conversion ?
  C := T16( A * B );                 -- 2.5 * 4.0 = 10.0   attendu C = 10.0
  C := T16( A / B );                 -- 2.5 / 4.0 = 0.625  attendu C = 0.625

--  A := A * N;          -- Q1d : FIX*INT NU, sans conversion englobante (4.5.5 : resultat T8 direct)
--  A := A / N;          -- Q1d : FIX/INT nu
--  A := N * A;          -- Q1d : INT*FIX, entier a GAUCHE (symetrie)

  A := T8'DELTA;       -- Q1e : attribut consomme -- SM_VALUE plie par sem, ou DN_ATTRIBUTE a coder ?
  A := T34'SMALL;      -- Q1e : small 3/4 consomme (universal_real -> fixed implicite)
  N := T8'AFT;         -- Q1e : AFT/FORE plies statiquement par sem, ou a calculer ?
  N := T8'FORE;

  -- (2) F-B : FIX op INT  (deja correct ?  a juger)
  A := T8( A * T8( N ) );                        -- 2.5 * 3 = 7.5
  A := T8( A / T8( N ) );                        -- retour a 2.5

  -- (3) Q4 : NUMER /= 1 traverse-t-il ?
  D := T34( D * D );                 -- 36.0

  -- (4) Q6 : SMALL egaux apres reduction (1/16 vs 2/32) -> conversion identite ?
  E := TEQ( C );                     -- doit etre une IDENTITE, pas un rescale

  -- (5) Q5 : troncature ou arrondi ?  0.1875 n'est pas representable en 1/8
  A := T8( T16(0.1875) );            -- 1.5/8 : tronque -> 0.125 ; arrondi -> 0.25

end FIX_DUMP0;
