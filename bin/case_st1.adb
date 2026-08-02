with TEXT_IO;  use TEXT_IO;

procedure CASE_ST1 is
--------------------------------------------------------------------------
-- Temoin C2 (BILAN_RECENSEMENT_TRIAGE, ecrit AVANT implantation, 30/07).
-- case a choix MARQUE DE SOUS-TYPE : LRM 5.4, la marque denote son
-- intervalle ; les choix de case sont STATIQUES (LRM 5.4(4)).
-- Couvre (prescription du bilan) : premiere borne, derniere borne, hors
-- fenetre des deux cotes, melange marque + choix simples (alternatives
-- distinctes ET meme alternative), others present et absent (couverture
-- enum complete par deux marques), entier (bornes negatives comprises)
-- et enumere (chemin SM_REP).
-- Auto-jugeant : CHECK(cond, section, test), verdict << CASE_ST1 PASSE >>.
--------------------------------------------------------------------------

  OK_COUNT	: INTEGER := 0;
  FAIL_COUNT	: INTEGER := 0;

  subtype LOW is INTEGER range -5 .. 3;
  subtype MID is INTEGER range 10 .. 20;

  type COLOR is ( ROUGE, ORANGE, JAUNE, VERT, BLEU, INDIGO, VIOLET );
  subtype CHAUD is COLOR range ROUGE .. JAUNE;
  subtype FROID is COLOR range VERT  .. VIOLET;

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

  function CLASSE( N : INTEGER ) return INTEGER is
  begin
    case N is
      when LOW	=> return 1;			-- marque, bornes negatives	[site C2]
      when MID	=> return 2;			-- marque			[site C2]
      when 4 | 5	=> return 3;			-- choix simples entre fenetres
      when others	=> return 0;
    end case;
  end CLASSE;

  function TEMP( C : COLOR ) return INTEGER is
  begin						-- couverture COMPLETE par marques,
    case C is					-- PAS de others
      when CHAUD	=> return 1;			--				[site C2]
      when FROID	=> return 2;			--				[site C2]
    end case;
  end TEMP;

  function MIXTE( N : INTEGER ) return INTEGER is
  begin
    case N is
      when MID | 42	=> return 1;		-- marque ET simple, MEME alternative	[site C2]
      when others	=> return 0;
    end case;
  end MIXTE;

begin
  PUT_LINE( "=== CASE_ST1 : case a choix marque-de-sous-type ===" );

  -- S1 : marque entiere -- bornes exactes, interieur, hors fenetre
  CHECK( CLASSE( 10 ) = 2,  1, 1 );		-- premiere borne de MID
  CHECK( CLASSE( 20 ) = 2,  1, 2 );		-- derniere borne de MID
  CHECK( CLASSE( 15 ) = 2,  1, 3 );		-- interieur
  CHECK( CLASSE(  9 ) = 0,  1, 4 );		-- hors fenetre, sous la borne
  CHECK( CLASSE( 21 ) = 0,  1, 5 );		-- hors fenetre, au-dessus
  CHECK( CLASSE( -5 ) = 1,  1, 6 );		-- premiere borne de LOW (negative)
  CHECK( CLASSE(  3 ) = 1,  1, 7 );		-- derniere borne de LOW
  CHECK( CLASSE(  0 ) = 1,  1, 8 );		-- interieur de LOW
  CHECK( CLASSE(  4 ) = 3,  1, 9 );		-- choix simple entre les fenetres
  CHECK( CLASSE( -6 ) = 0,  1, 10 );		-- juste sous LOW

  -- S2 : marque enumeree, couverture complete sans others
  CHECK( TEMP( ROUGE  ) = 1,  2, 1 );		-- premiere borne de CHAUD = COLOR'FIRST
  CHECK( TEMP( JAUNE  ) = 1,  2, 2 );		-- derniere borne de CHAUD
  CHECK( TEMP( VERT   ) = 2,  2, 3 );		-- premiere borne de FROID
  CHECK( TEMP( VIOLET ) = 2,  2, 4 );		-- derniere borne de FROID = COLOR'LAST
  CHECK( TEMP( BLEU   ) = 2,  2, 5 );		-- interieur

  -- S3 : marque et choix simple dans la MEME alternative
  CHECK( MIXTE( 42 ) = 1,  3, 1 );		-- le simple de l'alternative mixte
  CHECK( MIXTE( 12 ) = 1,  3, 2 );		-- la marque de l'alternative mixte
  CHECK( MIXTE( 41 ) = 0,  3, 3 );		-- entre marque et simple : others

  PUT( "RESULTAT :" );
  INT_IO.PUT( OK_COUNT,   WIDTH => 3 );
  PUT( " OK," );
  INT_IO.PUT( FAIL_COUNT, WIDTH => 3 );
  PUT_LINE( " ECHECS" );
  if FAIL_COUNT = 0 then
    PUT_LINE( "CASE_ST1 PASSE" );
  end if;
end CASE_ST1;
