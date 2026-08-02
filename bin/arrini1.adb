with TEXT_IO;  use TEXT_IO;

procedure ARRINI1 is
--------------------------------------------------------------------------
-- Temoin C4 (BILAN_RECENSEMENT_TRIAGE, ecrit AVANT implantation, 30/07).
-- COMPILE_ARRAY_VAR, initialisation par OBJET ENTIER : X : ARR := Y --
-- allocation puis copie BLKMOV, modele de la branche tranche ; @SRC par
-- la regle unique CCDA.  Couvre aussi la CONVERSION en initialiseur
-- (X : VEC := VEC(Z), Z derive) : la regle est transparente aux
-- conversions depuis C1-ter.  L'init par APPEL DE FONCTION est EXCLUE
-- (protocole << lieu resultat >> suspendu, carnet, preuve CONV_DER1 v1)
-- -- le bilan la prescrivait, il precedait cette preuve.
-- Verifie la SEMANTIQUE DE COPIE (pas d'alias) : modifier la source
-- apres init ne change pas la destination.
-- Auto-jugeant : verdict << ARRINI1 PASSE >>.
--------------------------------------------------------------------------

  OK_COUNT	: INTEGER := 0;
  FAIL_COUNT	: INTEGER := 0;

  type VEC  is array ( 1 .. 5 ) of INTEGER;
  type DVEC is new VEC;

  Y	: VEC	:= ( 1, 2, 3, 4, 5 );
  DW	: DVEC	:= ( 9, 8, 7, 6, 5 );

  X	: VEC	:= Y;				-- init par OBJET			[site C4]
  Z	: VEC	:= VEC( DW );			-- init par CONVERSION d'objet		[site C4]

  T	: STRING( 1 .. 3 ) := "abc";
  S	: STRING( 1 .. 3 ) := T;		-- init par OBJET (STRING)		[site C4]

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

begin
  PUT_LINE( "=== ARRINI1 : init tableau par objet entier ===" );

  -- S1 : contenu copie
  CHECK( X( 1 ) = 1 and X( 5 ) = 5,  1, 1 );
  CHECK( X = Y,                      1, 2 );
  CHECK( Z( 1 ) = 9 and Z( 5 ) = 5,  1, 3 );
  CHECK( S = "abc",                  1, 4 );

  -- S2 : semantique de COPIE (pas d'alias)
  Y( 1 ) := 100;
  CHECK( X( 1 ) = 1,                 2, 1 );
  CHECK( Y( 1 ) = 100,               2, 2 );
  T( 1 ) := 'z';
  CHECK( S( 1 ) = 'a',               2, 3 );
  DW( 5 ) := 55;
  CHECK( Z( 5 ) = 5,                 2, 4 );

  -- S3 : parcours complet
  declare
    SUM : INTEGER := 0;
  begin
    for I in 1 .. 5 loop
      SUM := SUM + Z( I );
    end loop;
    CHECK( SUM = 35,                 3, 1 );
  end;

  PUT( "RESULTAT :" );
  INT_IO.PUT( OK_COUNT,   WIDTH => 3 );
  PUT( " OK," );
  INT_IO.PUT( FAIL_COUNT, WIDTH => 3 );
  PUT_LINE( " ECHECS" );
  if FAIL_COUNT = 0 then
    PUT_LINE( "ARRINI1 PASSE" );
  end if;
end ARRINI1;
