with TEXT_IO;	use TEXT_IO;
					-------
procedure				OUTARG1
is					-------

  -- Temoin dedie du defaut d'expandeur « actual out/in out compose »
  -- (8 juillet 2026, decouvert par TEXT14P/P14).
  --
  -- U1 : composant INDEXE en actual out et in out   (le cas demontre)
  -- U2 : composant SELECTIONNE en actual out/in out (fossile jumeau)
  -- U3 : composant indexe d'un formel non contraint (le cas TEXT_IO)
  --
  -- Independant du chemin fichier de TEXT_IO : tout se joue en memoire.
  -- Verdict greppable : "OUTARG1 PASSE".

  N_OK	: NATURAL	:= 0;
  N_KO	: NATURAL	:= 0;

  type REC	is record
		  C	: CHARACTER;
		  N	: INTEGER;
		end record;

  type INT_TAB	is array( 1 .. 3 ) of INTEGER;

  TAB	: STRING( 1 .. 5 )	:= "?????";
  ITAB	: INT_TAB		:= ( 0, 0, 0 );
  R	: REC			:= ( C => '?', N => 0 );

  package	I_IO	is new INTEGER_IO( INTEGER );

		-----
  procedure	CHECK	( LABEL :in STRING; COND :in BOOLEAN )
  is		-----
  begin
    if  COND  then
      N_OK := N_OK + 1;
    else
      N_KO := N_KO + 1;
      PUT( "* ECHEC " );
      PUT_LINE( LABEL );
    end if;

  end	CHECK;
	-----

		---------
  procedure	DONNE_CAR	( C :out CHARACTER )
  is		---------
  begin
    C := 'X';

  end	DONNE_CAR;
	---------

		---------
  procedure	DONNE_ENT	( N :out INTEGER )
  is		---------
  begin
    N := 42;

  end	DONNE_ENT;
	---------

		---------
  procedure	INCREMENTE	( N :in out INTEGER )
  is		---------
  begin
    N := N + 1;

  end	INCREMENTE;
	---------

		-----------
  procedure	REMPLIT_TOUT	( S :out STRING )				-- formel non contraint,
  is		-----------							-- boucle sur composant indexe
  begin										-- (le motif exact du GET(STRING) public)
    for  I  in  S'FIRST .. S'LAST  loop
      DONNE_CAR( S( I ) );
    end loop;

  end	REMPLIT_TOUT;
	-----------

begin

  PUT_LINE( "=== U1. Composant indexe en actual out / in out ===" );

  DONNE_CAR( TAB( 3 ) );
  CHECK( "U1.1 out vers TAB(3)",
         TAB( 1 ) = '?' and TAB( 2 ) = '?' and TAB( 3 ) = 'X'
                        and TAB( 4 ) = '?' and TAB( 5 ) = '?' );

  DONNE_ENT( ITAB( 2 ) );
  CHECK( "U1.2 out vers ITAB(2)",
         ITAB( 1 ) = 0 and ITAB( 2 ) = 42 and ITAB( 3 ) = 0 );

  INCREMENTE( ITAB( 2 ) );
  CHECK( "U1.3 in out vers ITAB(2)", ITAB( 2 ) = 43 );

  declare
    I	: INTEGER	:= 2;
  begin
    DONNE_ENT( ITAB( I + 1 ) );						-- indice calcule
    CHECK( "U1.4 out, indice calcule", ITAB( 3 ) = 42 );
  end;

  PUT_LINE( "=== U2. Composant selectionne en actual out / in out ===" );

  DONNE_CAR( R.C );
  CHECK( "U2.1 out vers R.C", R.C = 'X' and R.N = 0 );

  DONNE_ENT( R.N );
  CHECK( "U2.2 out vers R.N", R.N = 42 );

  INCREMENTE( R.N );
  CHECK( "U2.3 in out vers R.N", R.N = 43 );

  PUT_LINE( "=== U3. Indexe d'un formel non contraint (motif TEXT_IO) ===" );

  declare
    S	: STRING( 1 .. 4 )	:= "----";
  begin
    REMPLIT_TOUT( S );
    CHECK( "U3.1 boucle sur S(I) a travers le formel", S = "XXXX" );
  end;

  NEW_LINE;
  PUT( "RESULTAT : " );
  I_IO.PUT( N_OK, 2 );
  PUT( " OK, " );
  I_IO.PUT( N_KO, 2 );
  PUT_LINE( " ECHECS" );

  if  N_KO = 0  then
    PUT_LINE( "OUTARG1 PASSE" );
  else
    PUT_LINE( "OUTARG1 ECHOUE" );
  end if;

end	OUTARG1;
	-------
