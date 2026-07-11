with TEXT_IO; use TEXT_IO;
procedure FIX_TEST1 is

  -- Temoin auto-jugeant du pilier FIXED, etape F-3 (note v1.1 §6).
  -- Regime sem : small par defaut = delta/2 (consigne sem-1).
  -- T8 : small 1/16 ; T16 : small 1/32 ; T34 : small 3/4 ; TEQ : small 1/16.

  package INT_IO is new INTEGER_IO( INTEGER );

  type T8  is delta 0.125   range -100.0 .. 100.0;
  type T16 is delta 0.0625  range -100.0 .. 100.0;

  type T34 is delta 1.0     range -1000.0 .. 1000.0;
  for T34'SMALL use 3.0/4.0;

  type TEQ is delta 0.0625  range -100.0 .. 100.0;
  for TEQ'SMALL use 2.0/32.0;

  subtype S8 is T8 range -1.0 .. 1.0;

  NB_OK, NB_KO : INTEGER := 0;

  A   : T8  := 2.5;
  B   : T8  := 4.0;
  AN  : T8  := -2.5;
  C   : T16 := 0.0;
  D   : T34 := 6.0;
  E   : TEQ := 0.0;
  S   : S8  := 0.5;
  N   : INTEGER := 3;
  NZ  : INTEGER := 0;

  procedure CHECK( COND : BOOLEAN; SECTION : STRING; NUM : INTEGER ) is
  begin
    if COND then
      NB_OK := NB_OK + 1;
    else
      NB_KO := NB_KO + 1;
      PUT( "* ECHEC section " ); PUT( SECTION );
      PUT( " test" ); INT_IO.PUT( NUM ); NEW_LINE;
    end if;
  end CHECK;

begin
  PUT_LINE( "=== S1. Multiplicatif T(X*Y), T(X/Y), elision FIX.INT ===" );

  C := T16( A * B );                                 -- 40*64=2560, facteur 1/8
  CHECK( C = 10.0,      "S1", 1 );

  C := T16( A / B );                                 -- pre-scale *32, /64
  CHECK( C = 0.625,     "S1", 2 );

  C := T16( B / A );                                 -- 64*32/40 = 51.2 -> TRONQUE 51 (Q3)
  CHECK( C = 1.59375,   "S1", 3 );

  C := T16( AN * B );                                -- signe a travers imul
  CHECK( C = -10.0,     "S1", 4 );

  A := T8( A * T8( N ) );                            -- elision : 40*3, facteur 1
  CHECK( A = 7.5,       "S1", 5 );

  A := T8( A / T8( N ) );                            -- elision : 120/3
  CHECK( A = 2.5,       "S1", 6 );

  D := T34( D * D );                                 -- small 3/4 : 64 * 3/4 = 48
  CHECK( D = 36.0,      "S1", 7 );

  PUT_LINE( "=== S2. fixed -> fixed (rescale, identite, troncature) ===" );

  C := T16( A * B );                                 -- C = 10.0 (repr 320)
  E := TEQ( C );                                     -- 1/32 -> 1/16 : facteur 1/2
  CHECK( E = 10.0,      "S2", 8 );

  A := T8( T16( 0.1875 ) );                          -- litteral repr 6, puis 1/2
  CHECK( A = 0.1875,    "S2", 9 );

  D := T34( B );                                     -- 4.0 : 64*4/48 = 5.33 -> TRONQUE 5 = 3.75
  CHECK( D = 3.75,      "S2", 10 );

  D := T34( AN );                                    -- -2.5 : -3.33 -> TRONQUE VERS ZERO -3 = -2.25
  CHECK( D = -2.25,     "S2", 11 );

  PUT_LINE( "=== S3. Attributs plies, sous-type ===" );

  A := T8'DELTA;                                     -- SM_ACCURACY plie 1/8
  CHECK( A = 0.125,     "S3", 12 );

  A := T34'SMALL;                                    -- CD_IMPL_SMALL plie 3/4, contexte T8
  CHECK( A = 0.75,      "S3", 13 );

  CHECK( S = 0.5,       "S3", 14 );                  -- init via sous-type S8 elabore

  -- sem-3 CONSIGNE, non asserte : 'AFT/'FORE plies a 3 en dur par sem
  -- (valeurs vraies : AFT=1, FORE=4). Affiches pour trace :
  PUT( "  T8'AFT (sem-3, attendu 3) =" );  INT_IO.PUT( T8'AFT );  NEW_LINE;
  PUT( "  T8'FORE (sem-3, attendu 3) =" ); INT_IO.PUT( T8'FORE ); NEW_LINE;

  PUT_LINE( "=== S4. Division fixed par zero -> NUMERIC_ERROR (Q7) ===" );

  begin
    C := T16( A / T8( NZ ) );
    CHECK( FALSE,       "S4", 15 );                  -- pas d'exception = echec
  exception
    when NUMERIC_ERROR => CHECK( TRUE, "S4", 15 );
  end;

  PUT( "RESULTAT : " ); INT_IO.PUT( NB_OK ); PUT( " OK, " );
  INT_IO.PUT( NB_KO ); PUT_LINE( " ECHECS" );
  if NB_KO = 0 then
    PUT_LINE( "FIX_TEST1 PASSE" );
  end if;

end FIX_TEST1;
