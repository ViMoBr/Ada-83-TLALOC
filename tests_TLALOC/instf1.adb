with TEXT_IO;  use TEXT_IO;

procedure INSTF1 is
--------------------------------------------------------------------------
-- Temoin C7 (BILAN_RECENSEMENT_TRIAGE, ecrit AVANT implantation, 30/07).
-- INSTANTIATION de fonction generique a resultat NON CONTRAINT (STRING) :
-- le wrapper synthetise par INSTANTIATION_SUBPROG_GENERIQUE tombe au TROU
-- << resultat type non contraint >> a son epilogue (10 traversees corpus :
-- page_man, idl_tbl, grmr_tbl, lib_phase, write_lib -- 2 chacun).
-- Modele vise (NOTE_MODELE_UNCONSTRAINED + reclassement n. 4, FINC
-- TO_CHN) : le resultat circule en @doublet par le slot ; l'epilogue du
-- wrapper n'a qu'a relayer le doublet, RTD prm_siz-8 le laisse a
-- l'appelant.
-- DEUX instanciations a actuels DIFFERENTS : les bornes du resultat
-- varient PAR INSTANCE (le vrai test du partage de modele).
-- Formes d'usage : affectation depuis l'appel, INIT de declaration par
-- l'appel (COMPILE_ARRAY_VAR, branche << appel retournant doublet >>
-- attestee par la NOTE), operande d'egalite (CODE_ARRAY_OPERAND classe
-- FUNCTION_CALL producteur de doublet).
-- Auto-jugeant : verdict << INSTF1 PASSE >>.
--------------------------------------------------------------------------

  OK_COUNT	: INTEGER := 0;
  FAIL_COUNT	: INTEGER := 0;

  S3	: STRING( 1 .. 3 );
  S5	: STRING( 1 .. 5 );

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

  generic
    WIDTH	: POSITIVE;
    FILL	: CHARACTER;
  function BAND return STRING;

  function BAND return STRING is
    S : STRING( 1 .. WIDTH );
  begin
    for I in 1 .. WIDTH loop
      S( I ) := FILL;
    end loop;
    return S;					-- retour d'un contraint LOCAL par
  end BAND;					-- resultat NON contraint (doublet)

  function B3 is new BAND( 3, '*' );		--				[site C7]
  function B5 is new BAND( 5, '+' );		--				[site C7]

begin
  PUT_LINE( "=== INSTF1 : instanciation, resultat non contraint ===" );

  -- S1 : affectation depuis l'appel (deux instances, bornes differentes)
  S3 := B3;
  CHECK( S3 = "***",     1, 1 );
  S5 := B5;
  CHECK( S5 = "+++++",   1, 2 );

  -- S2 : resultat d'appel en operande direct d'egalite
  CHECK( B3 = "***",     2, 1 );
  CHECK( B5 = "+++++",   2, 2 );
  CHECK( B3 = S3,        2, 3 );

  -- S3 : init de declaration par l'appel
  declare
    T3 : STRING( 1 .. 3 ) := B3;
    T5 : STRING( 1 .. 5 ) := B5;
  begin
    CHECK( T3 = "***",   3, 1 );
    CHECK( T5 = "+++++", 3, 2 );
    CHECK( T5( 1 ) = '+' and T5( 5 ) = '+',  3, 3 );
  end;

  PUT( "RESULTAT :" );
  INT_IO.PUT( OK_COUNT,   WIDTH => 3 );
  PUT( " OK," );
  INT_IO.PUT( FAIL_COUNT, WIDTH => 3 );
  PUT_LINE( " ECHECS" );
  if FAIL_COUNT = 0 then
    PUT_LINE( "INSTF1 PASSE" );
  end if;
end INSTF1;
