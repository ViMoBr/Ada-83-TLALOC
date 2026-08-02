with TEXT_IO;  use TEXT_IO;

procedure CONV_DER1 is
--------------------------------------------------------------------------
-- Temoin C1 (BILAN_RECENSEMENT_TRIAGE, ecrit AVANT implantation, 30/07).
-- Conversions vers types composites DERIVES : LRM 4.6, entre type derive
-- et parent la representation est LA MEME -- la conversion est une
-- identite sur l'@doublet.  Miroirs corpus : set_util (record prive
-- derive), idl.adb (tableau contraint derive).
-- Auto-jugeant : CHECK(cond, section, test), verdict << CONV_DER1 PASSE >>.
-- HORS PERIMETRE (volontaire) : aucun appel de sous-programme DERIVE
-- (CODE_DERIVED_SUBPROG est un TROU distinct du carnet) ; les operations
-- du parent sont appelees via conversion explicite.
-- Le test 1.4 (conversion en PREFIXE selected) est un contre-temoin de
-- non-regression du chemin n. 120b (RECURSE_SELECTED), PAS un site C1.
--------------------------------------------------------------------------

  OK_COUNT	: INTEGER := 0;
  FAIL_COUNT	: INTEGER := 0;

  type R is
    record
      A : INTEGER;
      B : INTEGER;
      C : INTEGER;
    end record;
  type DR is new R;					-- record derive direct

  X	: R	:= ( A => 11, B => 22, C => 33 );
  DX	: DR	:= ( A => 44, B => 55, C => 66 );

  type VEC  is array ( 1 .. 5 ) of INTEGER;
  type DVEC is new VEC;					-- tableau contraint derive (miroir idl.adb)

  V	: VEC	:= ( 1, 2, 3, 4, 5 );
  DV	: DVEC	:= ( 10, 20, 30, 40, 50 );

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

  function SUM_R( P : R ) return INTEGER is
  begin
    return P.A + P.B + P.C;
  end SUM_R;

  package SETS is					-- miroir set_util : type PRIVE
    type SET is private;
    procedure MK ( N : INTEGER; S : out SET );		-- v2 : PROCEDURE, pas fonction --
    function VAL( S : SET ) return INTEGER;		-- le protocole appelant << lieu
							-- resultat >> des fonctions a
							-- resultat COMPOSITE est un
							-- chantier suspendu (segfault
							-- reproduit par v1, cf. carnet)
  private
    type SET is
      record
        LO : INTEGER;
        HI : INTEGER;
      end record;
  end SETS;

  package body SETS is
    procedure MK( N : INTEGER; S : out SET ) is
    begin
      S := ( LO => N, HI => N * 2 );
    end MK;
    function VAL( S : SET ) return INTEGER is
    begin
      return S.LO + S.HI;
    end VAL;
  end SETS;

begin
  PUT_LINE( "=== CONV_DER1 : conversions vers types derives ===" );

  -- S1 : record derive, aller-retour + comparaison de contenu
  declare
    Y : DR;
    Z : R;
  begin
    Y := DR( X );					-- parent -> derive		[site C1]
    CHECK( Y.A = 11 and Y.B = 22 and Y.C = 33, 1, 1 );
    Z := R( DX );					-- derive -> parent		[site C1]
    CHECK( Z.A = 44 and Z.B = 55 and Z.C = 66, 1, 2 );
    Z := R( DR( X ) );					-- aller-retour compose		[2 sites C1]
    CHECK( Z = X, 1, 3 );				-- egalite composite (pilier 3.7)
    CHECK( DR( X ).B = 22, 1, 4 );			-- prefixe selected : chemin n. 120b, hors C1
    CHECK( SUM_R( R( DX ) ) = 165, 1, 5 );		-- conversion en ACTUAL		[site C1]
  end;

  -- S2 : record PRIVE derive (miroir set_util) -- la conversion traverse
  --      le depliage DN_PRIVATE de CODE_CONVERSION avant le dispatch.
  declare
    type DSET is new SETS.SET;
    S	: SETS.SET;
    DS	: DSET;
    DS2	: DSET;
  begin
    SETS.MK( 7, S );					-- (7, 14) -- v2 : via procedure
    DS := DSET( S );					-- parent prive -> derive	[site C1]
    CHECK( SETS.VAL( SETS.SET( DS ) ) = 21, 2, 1 );	-- retour au parent		[site C1]
    S := SETS.SET( DS );				-- 				[site C1]
    CHECK( SETS.VAL( S ) = 21, 2, 2 );
    DS2 := DSET( S );					-- 				[site C1]
    CHECK( SETS.VAL( SETS.SET( DS2 ) ) = 21, 2, 3 );	-- 				[site C1]
  end;

  -- S3 : tableau contraint derive, aller-retour + contenu (meme profil
  --      d'index des deux cotes : la dette LRM 4.6(11) n'est PAS exercee)
  declare
    W	: DVEC;
    U	: VEC;
    SUM	: INTEGER := 0;
  begin
    W := DVEC( V );					-- parent -> derive		[site C1 tableau]
    CHECK( W( 1 ) = 1  and W( 5 ) = 5,  3, 1 );
    U := VEC( DV );					-- derive -> parent		[site C1 tableau]
    CHECK( U( 1 ) = 10 and U( 5 ) = 50, 3, 2 );
    U := VEC( DVEC( V ) );				-- aller-retour compose		[2 sites C1 tableau]
    for I in 1 .. 5 loop
      SUM := SUM + U( I );
    end loop;
    CHECK( SUM = 15, 3, 3 );
    CHECK( U = V, 3, 4 );				-- egalite composite
  end;

  PUT( "RESULTAT :" );
  INT_IO.PUT( OK_COUNT,   WIDTH => 3 );
  PUT( " OK," );
  INT_IO.PUT( FAIL_COUNT, WIDTH => 3 );
  PUT_LINE( " ECHECS" );
  if FAIL_COUNT = 0 then
    PUT_LINE( "CONV_DER1 PASSE" );
  end if;
end CONV_DER1;
