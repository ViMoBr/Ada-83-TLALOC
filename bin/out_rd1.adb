with TEXT_IO;  use TEXT_IO;

procedure OUT_RD1 is
--------------------------------------------------------------------------
-- Temoin C3 (BILAN_RECENSEMENT_TRIAGE, ecrit AVANT implantation, 30/07).
-- RELECTURE d'un parametre OUT apres ecriture, toleree par le front-end
-- TLALOC (le corpus en vit : types_decls, 2 traversees).  Protocole
-- n. 91/94 : le slot d'un out scalaire contient l'ADRESSE de la valeur,
-- exactement comme in out -- meme chemin de lecture.
-- NOTE dialecte : la lecture d'un out est ILLEGALE en Ada 83 strict
-- (LRM 6.2) -- ce temoin est ecrit dans le dialecte tolere par TLALOC ;
-- la contre-epreuve GNAT se fait en mode par defaut (Ada >= 95, ou la
-- lecture d'un out est legale), PAS en -gnat83.
-- Auto-jugeant : verdict << OUT_RD1 PASSE >>.
--------------------------------------------------------------------------

  OK_COUNT	: INTEGER := 0;
  FAIL_COUNT	: INTEGER := 0;

  Q, R, C, A	: INTEGER := -999;
  B		: BOOLEAN := FALSE;

  package INT_IO is new TEXT_IO.INTEGER_IO( INTEGER );

  procedure CHECK( COND : BOOLEAN; SECTION : INTEGER; NUM : INTEGER ) is
  begin
    if COND then
      OK_COUNT := OK_COUNT + 1;
    else
      FAIL_COUNT := FAIL_COUNT + 1;
      PUT( "* ECHEC section" );
      INT_IO.PUT( SECTION, WIDTH => 2 );
      PUT( " test" );
      INT_IO.PUT( NUM, WIDTH => 3 );
      NEW_LINE;
    end if;
  end CHECK;

  procedure SPLIT( N : INTEGER; Q : out INTEGER; R : out INTEGER ) is
  begin
    Q := N / 10;
    R := N - Q * 10;				-- RELIT Q (out, entier)		[site C3]
  end SPLIT;

  procedure BUMP( B : out BOOLEAN; CNT : out INTEGER ) is
  begin
    B   := TRUE;
    CNT := 0;
    if B then					-- RELIT B (out, enumere)		[site C3]
      CNT := CNT + 1;				-- RELIT CNT (out, entier)		[site C3]
    end if;
  end BUMP;

  procedure ACCUM( N : INTEGER; S : out INTEGER ) is
  begin
    S := 0;
    for I in 1 .. N loop
      S := S + I;				-- RELIT S a chaque tour		[site C3]
    end loop;
  end ACCUM;

begin
  PUT_LINE( "=== OUT_RD1 : relecture d'un parametre out ===" );

  SPLIT( 37, Q, R );
  CHECK( Q = 3,   1, 1 );
  CHECK( R = 7,   1, 2 );
  SPLIT( 140, Q, R );
  CHECK( Q = 14,  1, 3 );
  CHECK( R = 0,   1, 4 );
  SPLIT( 5, Q, R );
  CHECK( Q = 0,   1, 5 );
  CHECK( R = 5,   1, 6 );

  BUMP( B, C );
  CHECK( B,       2, 1 );
  CHECK( C = 1,   2, 2 );

  ACCUM( 4, A );
  CHECK( A = 10,  3, 1 );
  ACCUM( 0, A );
  CHECK( A = 0,   3, 2 );

  PUT( "RESULTAT :" );
  INT_IO.PUT( OK_COUNT,   WIDTH => 3 );
  PUT( " OK," );
  INT_IO.PUT( FAIL_COUNT, WIDTH => 3 );
  PUT_LINE( " ECHECS" );
  if FAIL_COUNT = 0 then
    PUT_LINE( "OUT_RD1 PASSE" );
  end if;
end OUT_RD1;
