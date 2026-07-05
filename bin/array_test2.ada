-- ARRAY_TEST2 v2 — Pilier LRM 3.6 : OBJECTIF (dette D1..D9 de la note de pilier)
-- v2 (après pose de CLAMP0) : section D7 ré-armée. La forme C1(N..N-1)'LENGTH est
-- retirée : CODE_ATTRIBUTE exige un préfixe nommé (LX_SYMREP lu à l'entrée) — consigné
-- comme dette D10 « attributs à préfixe non nommé (tranche, indexé, appel) ».
-- La section D7 exerce les mêmes sites de bornage via des objets nuls déclarés.
-- Activer les sections au fil des étapes (ordre : D7, D1, D2, D3, D4, D5, D8, D9).

with TEXT_IO;  use TEXT_IO;

procedure ARRAY_TEST2 is

  package INT_IO is new INTEGER_IO( INTEGER );
  use INT_IO;

  type VECTEUR is array( INTEGER range <> ) of INTEGER;
  subtype VEC3 is VECTEUR( 1 .. 3 );

  type LIGNE   is array( 1 .. 3 )   of INTEGER;
  type COLONNE is array( 11 .. 13 ) of INTEGER;      -- D5 : conversion avec glissement

  type BVEC is array( 1 .. 4 ) of BOOLEAN;           -- D3

  type MAT2 is array( 1 .. 2, 1 .. 3 ) of INTEGER;   -- D9 : agrégat 2D imbriqué

  N   : INTEGER := 3;

  C1  : STRING( 1 .. 6 ) := "ABCDEF";
  C2  : STRING( 1 .. 6 ) := "ABCDEZ";
  C3  : STRING( 1 .. 12 );
  P2  : STRING( 1 .. 2 ) := "AB";
  P3  : STRING( 1 .. 3 ) := "ABC";

  S0  : STRING( 3 .. 2 );                            -- D7 : tableau nul, bornes statiques
  SD  : STRING( N .. N - 1 );                        -- D7 : tableau nul, bornes dynamiques

  U, X, Y : VEC3;
  L    : LIGNE;
  CO   : COLONNE;
  B1, B2, B3 : BVEC;
  M    : MAT2;

  procedure AFFICHE( Y : in STRING ) is              -- exerce le chemin paramètre de 'LENGTH
  begin
    PUT( Y'FIRST );  PUT( Y'LAST );  PUT( Y'LENGTH );
    PUT( " [" );  PUT( Y );  PUT_LINE( "]" );
  end AFFICHE;

  procedure VRAI_FAUX( B : in BOOLEAN ) is
  begin
    if B then PUT_LINE( "VRAI" ); else PUT_LINE( "FAUX" ); end if;
  end VRAI_FAUX;

  function MILIEU( S : in STRING ) return STRING is  -- D8 : retour de tranche
  begin
    return S( S'FIRST + 1 .. S'LAST - 1 );
  end MILIEU;

begin
  PUT_LINE( "=== D7. Tableaux et tranches nuls (longueur bornee a 0) ===" );
  PUT( S0'LENGTH );  NEW_LINE;                 -- chemin variable, bornes statiques   -- 0
  PUT( SD'LENGTH );  NEW_LINE;                 -- chemin variable, descripteur (site 13) -- 0
  AFFICHE( SD );                               -- chemin paramètre (site 3)           -- 3 2 0 []
  C3 := SD & "ABCDEFGHIJKL";                   -- concat, opérande nul (sites 6/7)    -- (C3 :)
  PUT_LINE( C3 );                                                                     -- ABCDEFGHIJKL
  C3 := C1( N .. N - 1 ) & "ABCDEFGHIJKL";     -- concat, tranche nulle (sites 1,6,7)
  PUT_LINE( C3 );                                                                     -- ABCDEFGHIJKL
  C1( N .. N - 1 ) := C2( N .. N - 1 );        -- affectation de tranche nulle : no-op
  PUT_LINE( C1 );                                                                     -- ABCDEF

  PUT_LINE( "=== D1. Egalite et inegalite de tableaux ===" );
  VRAI_FAUX( C1 = "ABCDEF" );                                     -- VRAI
  VRAI_FAUX( C1 = C2 );                                           -- FAUX
  VRAI_FAUX( C1 /= C2 );                                          -- VRAI
  VRAI_FAUX( P2 = P3 );                        -- longueurs differentes => FAUX (pas d'erreur)
                                                                  -- FAUX
  U := ( 1, 2, 3 );
  X := ( 1, 2, 3 );
  VRAI_FAUX( U = X );                                             -- VRAI
  X( 3 ) := 4;
  VRAI_FAUX( U = X );                                             -- FAUX

  PUT_LINE( "=== D2. Ordre lexicographique (composants discrets) ===" );
  VRAI_FAUX( C1 < C2 );                        -- "ABCDEF" < "ABCDEZ"        -- VRAI
  VRAI_FAUX( P2 < P3 );                        -- prefixe plus court         -- VRAI
  VRAI_FAUX( P3 <= "ABC" );                                       -- VRAI
  VRAI_FAUX( C2 > C1 );                                           -- VRAI
  VRAI_FAUX( S0 < P2 );                        -- tableau nul < non nul      -- VRAI
  VRAI_FAUX( U < X );                          -- (1,2,3) < (1,2,4)          -- VRAI
  Y := ( -5, 2, 3 );
  VRAI_FAUX( Y < U );                          -- (-5,..) < (1,..)           -- VRAI
  PUT_LINE( "=== D3. Operateurs logiques sur tableaux booleens ===" );
  B1 := ( TRUE,  TRUE,  FALSE, FALSE );
  B2 := ( TRUE,  FALSE, TRUE,  FALSE );
  B3 := B1 and B2;
  VRAI_FAUX( B3( 1 ) );  VRAI_FAUX( B3( 2 ) );                    -- VRAI FAUX
  B3 := B1 or B2;
  VRAI_FAUX( B3( 3 ) );  VRAI_FAUX( B3( 4 ) );                    -- VRAI FAUX
  B3 := B1 xor B2;
  VRAI_FAUX( B3( 2 ) );  VRAI_FAUX( B3( 1 ) );                    -- VRAI FAUX
  B3 := not B1;
  VRAI_FAUX( B3( 1 ) );  VRAI_FAUX( B3( 4 ) );                    -- FAUX VRAI

  PUT_LINE( "=== D4. Catenation, formes composant (4.5.3) ===" );
  PUT_LINE( 'X' & P2 );                        -- composant & tableau        -- XAB
  PUT_LINE( P2 & 'Y' );                        -- tableau & composant        -- ABY
  PUT_LINE( 'X' & 'Y' );                       -- composant & composant      -- XY
  PUT_LINE( 'X' & P2 & 'Y' & C1( 1 .. 2 ) );                      -- XABYAB

  PUT_LINE( "=== D5. Conversion entre types tableaux (glissement) ===" );
  L  := ( 100, 200, 300 );
  CO := COLONNE( L );
  PUT( CO( 11 ) );  PUT( CO( 13 ) );  NEW_LINE;                   -- 100 300
  PUT( CO'FIRST );  PUT( CO'LAST );  NEW_LINE;                    -- 11 13
  L := LIGNE( CO );
  PUT( L( 1 ) );  NEW_LINE;                                       -- 100

  PUT_LINE( "=== D8. Retour de tranche depuis une fonction ===" );
  PUT_LINE( MILIEU( "PONTS" ) );                                  -- ONT
  PUT_LINE( MILIEU( C1 ) );                                       -- BCDE

  PUT_LINE( "=== D9. Confirmations (peuvent se reveler acquises) ===" );
  M := ( ( 1, 2, 3 ), ( 4, 5, 6 ) );           -- agrégat 2D imbriqué
  PUT( M( 1, 3 ) );  PUT( M( 2, 1 ) );  NEW_LINE;                 -- 3 4
  U := ( 1 | 3 => 9, 2 => 0 );                 -- choix multiples
  PUT( U( 1 ) );  PUT( U( 2 ) );  PUT( U( 3 ) );  NEW_LINE;       -- 9 0 9
  U := VEC3'( 1 => 5, others => 8 );           -- nommé + others : légal seulement qualifié (RM83 4.3.2(6))
  PUT( U( 1 ) );  PUT( U( 3 ) );  NEW_LINE;                       -- 5 8
  for I in VEC3'RANGE loop                     -- RANGE avec préfixe marque de sous-type
    U( I ) := I;
  end loop;
  PUT( U( 1 ) );  PUT( U( 3 ) );  NEW_LINE;                       -- 1 3

  PUT_LINE( "=== FIN ARRAY_TEST2 v2 ===" );
end ARRAY_TEST2;
