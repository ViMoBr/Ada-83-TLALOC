-- ARRAY_TEST1 v2 — Pilier LRM 3.6 : ACQUIS (filet de régression)
-- v2 (4 juillet, après verdict v1) :
--   * section 3 ré-armée : MATRICE a des bornes distinctes par dimension (1..3, 4..5),
--     sans quoi 'FIRST(2)/'LAST(2) sont justes par coïncidence ;
--   * section 9 : JOUR'IMAGE retiré (rendait la position ; consigné dette LRM 3.5.5).
-- Doit passer intégralement après les patchs A ('LENGTH(N)) et B (affectation tableau).

with TEXT_IO;  use TEXT_IO;

procedure ARRAY_TEST1 is

  package INT_IO is new INTEGER_IO( INTEGER );
  use INT_IO;

  type VECTEUR is array( INTEGER range <> ) of INTEGER;
  subtype VEC5 is VECTEUR( 1 .. 5 );

  type MATRICE is array( 1 .. 3, 4 .. 5 ) of INTEGER;   -- bornes distinctes par dimension

  type JOUR is ( LUNDI, MARDI, MERCREDI, JEUDI, VENDREDI, SAMEDI, DIMANCHE );
  type TAB_JOUR is array( JOUR ) of INTEGER;

  V   : VEC5;
  W   : VECTEUR( 1 .. 3 );
  M   : MATRICE;
  TJ  : TAB_JOUR;

  C1  : STRING( 1 .. 6 ) := "ABCDEF";
  C2  : STRING( 1 .. 6 );                     -- noeud partagé avec C1 (rég. A21001A)
  C3  : STRING( 1 .. 12 );

  S   : INTEGER;

  procedure AFFICHE( X : in STRING ) is
  begin
    PUT( X'FIRST );  PUT( X'LAST );  PUT( X'LENGTH );
    PUT( " [" );  PUT( X );  PUT_LINE( "]" );
  end AFFICHE;

  function SOMME( T : in VECTEUR ) return INTEGER is
    R : INTEGER := 0;
  begin
    for I in T'FIRST .. T'LAST loop
      R := R + T( I );
    end loop;
    return R;
  end SOMME;

begin
  PUT_LINE( "=== 1. Contraint 1D : indexation, FIRST/LAST/LENGTH ===" );
  for I in 1 .. 5 loop
    V( I ) := I * I;
  end loop;
  PUT( V( 1 ) );  PUT( V( 3 ) );  PUT( V( 5 ) );  NEW_LINE;      -- 1 9 25
  PUT( V'FIRST );  PUT( V'LAST );  PUT( V'LENGTH );  NEW_LINE;   -- 1 5 5

  PUT_LINE( "=== 2. Agrégats : positionnel, range, others ===" );
  V := ( 10, 20, 30, 40, 50 );
  PUT( V( 2 ) );  PUT( V( 4 ) );  NEW_LINE;                      -- 20 40
  V := ( 1 .. 5 => 3 );
  PUT( V( 1 ) );  PUT( V( 5 ) );  NEW_LINE;                      -- 3 3
  V := ( others => 7 );
  PUT( V( 3 ) );  NEW_LINE;                                      -- 7

  PUT_LINE( "=== 3. Matrice 2D : indexation, attributs dimensionnes ===" );
  for I in 1 .. 3 loop
    for J in 4 .. 5 loop
      M( I, J ) := 10 * I + J;
    end loop;
  end loop;
  PUT( M( 1, 4 ) );  PUT( M( 2, 4 ) );  PUT( M( 3, 5 ) );  NEW_LINE;   -- 14 24 35
  PUT( M'LENGTH( 1 ) );  PUT( M'LENGTH( 2 ) );  NEW_LINE;              -- 3 2
  PUT( M'FIRST( 1 ) );  PUT( M'FIRST( 2 ) );  NEW_LINE;                -- 1 4
  PUT( M'LAST( 1 ) );  PUT( M'LAST( 2 ) );  NEW_LINE;                  -- 3 5

  PUT_LINE( "=== 4. Index par type enumere ===" );
  for J in JOUR loop
    TJ( J ) := JOUR'POS( J );
  end loop;
  PUT( TJ( LUNDI ) );  PUT( TJ( JEUDI ) );  PUT( TJ( DIMANCHE ) );  NEW_LINE;  -- 0 3 6

  PUT_LINE( "=== 5. STRING : affectation litterale, concatenation ===" );
  C2 := "GHIJKL";                             -- patch B : littéral en source
  PUT_LINE( C2 );                                                 -- GHIJKL
  C3 := C1 & C2;                              -- patch B : concat en source (rég. A21001A)
  PUT_LINE( C3 );                                                 -- ABCDEFGHIJKL
  C3 := C2 & C1;
  PUT_LINE( C3 );                                                 -- GHIJKLABCDEF

  PUT_LINE( "=== 6. Tranches : lecture, affectation, parametre ===" );
  C3 := C1 & C2;
  PUT_LINE( C3( 4 .. 9 ) );                                       -- DEFGHI
  C1( 1 .. 3 ) := C3( 7 .. 9 );
  PUT_LINE( C1 );                                                 -- GHIDEF
  C2( 1 .. 3 ) := ( 'X', 'Y', 'Z' );
  PUT_LINE( C2 );                                                 -- XYZJKL
  C1 := C3( 4 .. 9 );                         -- patch B : tranche en source d'affectation complète
  PUT_LINE( C1 );                                                 -- DEFGHI
  AFFICHE( C3( 2 .. 5 ) );                                        -- 2 5 4 [BCDE]

  PUT_LINE( "=== 7. Parametres et fonction non contraints ===" );
  AFFICHE( C1 );                                                  -- 1 6 6 [DEFGHI]
  AFFICHE( "BONJOUR" );                                           -- 1 7 7 [BONJOUR]
  V := ( 10, 20, 30, 40, 50 );
  W := ( 5, 6, 7 );
  S := SOMME( V );  PUT( S );  NEW_LINE;                          -- 150
  S := SOMME( W );  PUT( S );  NEW_LINE;                          -- 18

  PUT_LINE( "=== 8. Attribut RANGE (prefixe objet) ===" );
  S := 0;
  for I in V'RANGE loop
    S := S + V( I );
  end loop;
  PUT( S );  NEW_LINE;                                            -- 150

  PUT_LINE( "=== 9. IMAGE ===" );
  PUT_LINE( INTEGER'IMAGE( 42 ) );                                --  42
  -- JOUR'IMAGE(MARDI) : consigné (rend la position hors générique — dette LRM 3.5.5)

  PUT_LINE( "=== FIN ARRAY_TEST1 v2 ===" );
end ARRAY_TEST1;
