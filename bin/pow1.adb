with TEXT_IO;  use TEXT_IO;

procedure POW1 is
--------------------------------------------------------------------------
-- Temoin C5 v2 (30/07).  Exponentielle ENTIERE GENERALE X**N hors le pli
-- 2**N (base litterale 2).
-- v2 : RESTRICTION FRONT-END caracterisee par pow_probe (30/07) -- la
-- resolution de "**" exige un exposant LITTERAL (universal_integer
-- apparie au seul litteral) ; variable, NATURAL, constante nommee et
-- expression sont rejetes << DESACCORD DE TYPE >>, contrairement au LRM
-- 4.5.6 (droite : INTEGER).  Le corpus (21 sites) est tout entier a
-- exposant litteral -- v2 s'y conforme.  DISPARAISSENT du v1 : la
-- fonction enveloppe P(X,N), les exposants variables, et le S4 exposant
-- negatif (inexprimable : les litteraux sont >= 0 et l'unaire est une
-- expression).  La garde N<0 de la primitive INTEGER_POW reste, LRM
-- oblige : verification structurelle NON EXERCABLE tant que la
-- restriction tient -- pow_probe est le temoin FUTUR du chantier
-- front-end, tout est au carnet.
-- Auto-jugeant : verdict << POW1 PASSE >>.
--------------------------------------------------------------------------

  OK_COUNT	: INTEGER := 0;
  FAIL_COUNT	: INTEGER := 0;

  A	: INTEGER := 3;
  B	: INTEGER := -3;
  ZERO	: INTEGER := 0;
  ONE	: INTEGER := 1;
  TWO	: INTEGER := 2;

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
  PUT_LINE( "=== POW1 v2 : exponentielle entiere, exposant litteral ===" );

  -- S1 : base variable, exposant litteral
  CHECK( A ** 5 = 243,           1, 1 );	--				[site C5]
  CHECK( A ** 0 = 1,             1, 2 );	-- X**0 = 1			[site C5]
  CHECK( A ** 1 = 3,             1, 3 );	-- X**1 = X			[site C5]
  CHECK( B ** 3 = -27,           1, 4 );	-- base negative, impair	[site C5]
  CHECK( B ** 4 = 81,            1, 5 );	-- base negative, pair		[site C5]
  CHECK( ZERO ** 0 = 1,          1, 6 );	-- 0**0 = 1 (LRM 4.5.6)		[site C5]
  CHECK( ZERO ** 4 = 0,          1, 7 );	--				[site C5]
  CHECK( ONE ** 30 = 1,          1, 8 );	--				[site C5]

  -- S2 : imbrication en expression
  CHECK( A ** 4 + A ** 2 * 2 = 99,  2, 1 );	--				[2 sites C5]

  -- S3 : base 2 -- le PLI (litteral 2) contre la voie generale (variable 2)
  CHECK( 2 ** 5 = 32,            3, 1 );	-- pli DEC/SHL, hors C5
  CHECK( 2 ** 10 = 1024,         3, 2 );	-- pli DEC/SHL, hors C5
  CHECK( TWO ** 5 = 32,          3, 3 );	-- base VARIABLE 2 : voie generale	[site C5]
  CHECK( 2 ** 5 = TWO ** 5,      3, 4 );	-- les deux voies s'accordent	[site C5]

  -- S4 : litteral ** litteral (peut etre plie statiquement par le front)
  CHECK( 3 ** 4 = 81,            4, 1 );	-- traversee non garantie (pli statique possible)

  PUT( "RESULTAT :" );
  INT_IO.PUT( OK_COUNT,   WIDTH => 3 );
  PUT( " OK," );
  INT_IO.PUT( FAIL_COUNT, WIDTH => 3 );
  PUT_LINE( " ECHECS" );
  if FAIL_COUNT = 0 then
    PUT_LINE( "POW1 PASSE" );
  end if;
end POW1;
