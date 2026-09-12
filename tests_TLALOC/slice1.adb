with TEXT_IO;  use TEXT_IO;

procedure SLICE1 is
--------------------------------------------------------------------------
-- Temoin C6 (NOTE_C6_TRANCHES validee le 30/07 ; ecrit AVANT implantation).
-- Tranches a prefixe INDEXE (miroir expander-utils 795/810 : destination
-- ET source, composant STRING contraint) et a prefixe DEREFERENCE
-- (designe CONTRAINT, cf. Q1b -- miroir des acces .all d'idl/page_man).
-- Controle central (risque du bilan : adresse de base) : les composants
-- et elements VOISINS restent INTACTS apres chaque ecriture par tranche.
-- Auto-jugeant : verdict << SLICE1 PASSE >>.
--------------------------------------------------------------------------

  OK_COUNT	: INTEGER := 0;
  FAIL_COUNT	: INTEGER := 0;

  type ROW is array ( 1 .. 3 ) of STRING( 1 .. 8 );
  subtype LIN is STRING( 1 .. 8 );
  type PLIN is access LIN;

  GA	: ROW;
  P	: PLIN;
  S3	: STRING( 1 .. 3 ) := "xyz";

  type BOOL_ARRAY is array ( INTEGER range <> ) of BOOLEAN;

  BA	: BOOL_ARRAY( 1 .. 8 )	:= ( TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE );

  BT	: BOOL_ARRAY( 1 .. 3 )	:= ( TRUE, TRUE, TRUE );


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
  PUT_LINE( "=== SLICE1 : tranches indexees et dereferencees ===" );

  GA( 1 ) := "AAAAAAAA";
  GA( 2 ) := "BBBBBBBB";
  GA( 3 ) := "CCCCCCCC";

  -- S1 : prefixe INDEXE (formes exactes du corpus)
  GA( 2 )( 2 .. 4 ) := S3;			-- DESTINATION (miroir utils:795)	[site C6]

  PUT_LINE( GA( 2 ) & " = GA(2) = ""BxyzBBBB"" ? "  );
  CHECK( GA( 2 ) = "BxyzBBBB",           1, 1 );

  PUT_LINE( GA( 2 )( 2 .. 4 ) & " = GA( 2 )( 2 .. 4 ) = ""xyz"" ? "  );
  CHECK( GA( 2 )( 2 .. 4 ) = S3,         1, 2 );	-- SOURCE (miroir utils:810)	[site C6]

  PUT_LINE( GA( 2 )( 1 .. 1 ) & " = GA( 2 )( 1 .. 1 ) = ""B"" ? "  );
  CHECK( GA( 2 )( 1 .. 1 ) = "B",        1, 3 );	-- bord gauche			[site C6]

  PUT_LINE( GA( 2 )( 5 .. 8 ) & " GA( 2 )( 5 .. 8 ) = ""BBBB"" ? "  );
  CHECK( GA( 2 )( 5 .. 8 ) = "BBBB",     1, 4 );	-- bord droit			[site C6]

  PUT_LINE( GA( 1 ) & " = GA( 1 ) = ""AAAAAAAA"" ? "  );
  CHECK( GA( 1 ) = "AAAAAAAA",           1, 5 );	-- VOISIN 1 intact

  PUT_LINE( GA( 3 ) & " = GA( 3 ) = ""CCCCCCCC"" ? "  );
  CHECK( GA( 3 ) = "CCCCCCCC",           1, 6 );	-- VOISIN 3 intact

  PUT_LINE( GA( 3 )( 1 .. 8 ) & " = GA( 3 )( 1 .. 8 ) = ""CCCCCCCC"" ? "  );
  CHECK( GA( 3 )( 1 .. 8 ) = "CCCCCCCC", 1, 7 );	-- tranche pleine		[site C6]


  -- S2 : prefixe DEREFERENCE (designe contraint)
  PUT_LINE( "P := new LIN'( ""ABCDEFGH"" );" );
  P := new LIN'( "ABCDEFGH" );
  PUT_LINE( "P.all( 2 .. 4 ) := S3" );
  P.all( 2 .. 4 ) := S3;			-- DESTINATION			[site C6]

  PUT_LINE( P.all & " = P.all = ""AxyzEFGH"" ? "  );
  CHECK( P.all = "AxyzEFGH",             2, 1 );

  PUT_LINE( P.all( 2 .. 4 ) & " = P.all( 2 .. 4 ) = ""xyz"" ? "  );
  CHECK( P.all( 2 .. 4 ) = S3,           2, 2 );	-- SOURCE			[site C6]

  PUT_LINE( P.all( 1 .. 1 ) & " = P.all( 1 .. 1 ) = ""A"" ? "  );
  CHECK( P.all( 1 .. 1 ) = "A",          2, 3 );	-- bord gauche			[site C6]

  PUT_LINE( P.all( 5 .. 8 ) & " = P.all( 5 .. 8 ) = ""EFGH"" ? "  );
  CHECK( P.all( 5 .. 8 ) = "EFGH",       2, 4 );	-- bord droit			[site C6]

  PUT_LINE( P.all( 8 ) & " = P.all( 8 ) = ""H"" ? "  );
  CHECK( P.all( 8 ) = 'H',               2, 5 );	-- element voisin (indexe sur .all)

  -- S3 : BOOLEAN
  BA( 3 .. 5 ) := BT;
  CHECK( BA( 1 ) = TRUE and BA( 2 ) = FALSE and BA( 3 ) = TRUE and BA( 4 ) = TRUE
    and BA( 5 ) = TRUE and BA( 6 ) = TRUE, 3, 1 );


  PUT( "RESULTAT :" );
  INT_IO.PUT( OK_COUNT,   WIDTH => 3 );
  PUT( " OK," );
  INT_IO.PUT( FAIL_COUNT, WIDTH => 3 );
  PUT_LINE( " ECHECS" );
  if FAIL_COUNT = 0 then
    PUT_LINE( "SLICE1 PASSE" );
  end if;
end SLICE1;
