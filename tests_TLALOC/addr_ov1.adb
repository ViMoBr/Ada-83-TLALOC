with TEXT_IO;  use TEXT_IO;

procedure ADDR_OV1 is
--------------------------------------------------------------------------
-- Temoin C8 v2 (CHANTIER_ADDRESS_OVERLAY, ecrit AVANT implantation).
-- Clause d'adresse d'objet << for X use at Y'ADDRESS >> = OVERLAY
-- (LRM 13.5), resolution PAR NOM deleguee a fasmg : l'expander emet une
-- EQUATION DE SYMBOLE ( X_disp = Y_disp ) au lieu d'allouer -- meme
-- cellule de frame, zero code runtime. Seul schema couvrant aussi les
-- SCALAIRES (acces par valeur directe : aucune indirection a detourner).
-- S5 exerce ce cas scalaire (TEST_ADDRESS du mainteneur : raise avant
-- correctif). S2/S3 ENCODENT le layout maison (PAIR = deux entiers
-- contigus, miroir STATOFS) : hypothese meme de l'idiome univ_ops.
-- __u de l'objet overlay = descripteur de SA vue (reinterpretation).
-- S6 = motif print_nod : tableau de CHARACTER sur cible SCALAIRE, AVEC
-- initialisation A TRAVERS l'overlay (detection d'endianite). Sortes
-- ASYMETRIQUES : le slot scalaire porte sa VALEUR -> pas d'equation,
-- data_ptr := @slot cible (LVA/Sa). S6 DEPEND du petit-boutisme x86_64,
-- comme print_nod lui-meme.
-- S7 = motif univ_ops exact : overlay RECORD sur PARAMETRE in (record).
-- Le slot du parametre porte l'@doublet de l'ACTUEL (n 91/94) :
-- data_ptr := [[-ofs]+0]. 7.2 ecrit A TRAVERS l'overlay et relit chez
-- l'appelant -- il asserte AUSSI le passage par reference des
-- composites (convention maison). 7.5/7.6 = motif SPREAD : parametre
-- in out, lecture ET ecriture a travers l'overlay puis par la vue
-- normale dans le MEME appel (slot @doublet identique pour tous les
-- modes composites). 7.4 pose l'overlay DANS UN BLOC
-- (declare -> INC_LEVEL, region BLOCK_LOOP) : la declaration est un
-- niveau AU-DESSUS du parametre -- la geometrie exacte d'univ_ops, le
-- La s'adresse au niveau de la CIBLE.
-- Auto-jugeant : verdict << ADDR_OV1 PASSE >>.
--------------------------------------------------------------------------

  OK_COUNT	: INTEGER := 0;
  FAIL_COUNT	: INTEGER := 0;

  package INT_IO is new TEXT_IO.INTEGER_IO( INTEGER );

  type PAIR is
    record
      LO	: INTEGER;
      HI	: INTEGER;
    end record;

  type VECTOR		is array( 1 .. 8 ) of INTEGER;
  type VECTOR_PAIRS	is array( 1 .. 4 ) of PAIR;

  V	: VECTOR;

  V2	: VECTOR;
  for V2  use at V'ADDRESS;			-- alias meme type		[site C8]

  VDP	: VECTOR_PAIRS;
  for VDP use at V'ADDRESS;			-- reinterpretation (univ_ops)	[site C8]

  R	: PAIR;
  for R   use at V'ADDRESS;			-- overlay record		[site C8]

  N	: INTEGER;
  NA	: INTEGER;
  for NA  use at N'ADDRESS;			-- overlay SCALAIRE		[site C8]

  E	: INTEGER;
  EB	: array( 1 .. 4 ) of CHARACTER		-- motif print_nod : composite	[site C8]
	  := ( CHARACTER'VAL( 1 ), ASCII.NUL, ASCII.NUL, ASCII.NUL );
  for EB  use at E'ADDRESS;			-- sur SCALAIRE, init A TRAVERS

  type COPAIR is
    record
      FST	: INTEGER;
      SND	: INTEGER;
    end record;

  P1	: PAIR;

  function VIEW_FST( X : PAIR ) return INTEGER is
    XC	: COPAIR;
    for XC use at X'ADDRESS;			-- record sur PARAMETRE in	[site C8, univ_ops]
  begin
    return XC.FST;
  end VIEW_FST;

  procedure POKE_SND( X : PAIR ) is
    XC	: COPAIR;
    for XC use at X'ADDRESS;			--				[site C8, univ_ops]
  begin
    XC.SND := 99;				-- ecrit l'ACTUEL (composite par reference)
  end POKE_SND;

  procedure SPREAD_B( X : in out PAIR ) is	-- motif SPREAD d'univ_ops	[site C8]
  begin
    declare
      XC	: COPAIR;
      for XC use at X'ADDRESS;			-- sur parametre IN OUT, dans un bloc
    begin
      XC.FST := XC.FST + 1;			-- lit ET ecrit a travers l'overlay
      XC.SND := 500;
    end;
    X.LO := X.LO + 1;				-- puis par la vue normale : coherence des deux vues
  end SPREAD_B;

  function VIEW_SND_B( X : PAIR ) return INTEGER is
    R	: INTEGER;
  begin
    declare					-- INC_LEVEL : la clause vit UN NIVEAU
      XC	: COPAIR;			-- au-dessus du parametre, comme le VDP
      for XC use at X'ADDRESS;			-- d'univ_ops (region BLOCK_LOOP)	[site C8, univ_ops]
    begin
      R := XC.SND;
    end;
    return R;
  end VIEW_SND_B;

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
  PUT_LINE( "=== ADDR_OV1 : clause d'adresse d'objet (overlay) ===" );

  for I in 1 .. 8 loop
    V( I ) := 10 * I;
  end loop;

  -- S1 : alias meme type, les deux sens
  CHECK( V2( 1 ) = 10,			1, 1 );
  CHECK( V2( 8 ) = 80,			1, 2 );
  V2( 3 ) := 333;
  CHECK( V( 3 ) = 333,			1, 3 );

  -- S2 : reinterpretation tableau de records (motif univ_ops)
  CHECK( VDP( 1 ).LO = 10,		2, 1 );
  CHECK( VDP( 1 ).HI = 20,		2, 2 );
  CHECK( VDP( 2 ).LO = 333,		2, 3 );	-- V(3) via S1
  CHECK( VDP( 4 ).HI = 80,		2, 4 );
  VDP( 3 ).LO := 555;
  CHECK( V( 5 ) = 555,			2, 5 );

  -- S3 : overlay record simple (COMPILE_RECORD_VAR)
  CHECK( R.LO = 10,			3, 1 );
  CHECK( R.HI = 20,			3, 2 );
  R.HI := 777;
  CHECK( V( 2 ) = 777,			3, 3 );
  CHECK( VDP( 1 ).HI = 777,		3, 4 );	-- trois vues, une memoire

  -- S4 : attributs de l'objet overlay = SA vue
  CHECK( VDP'FIRST = 1 and VDP'LAST = 4,	4, 1 );
  CHECK( VDP'LENGTH = 4,		4, 2 );
  CHECK( V2'LENGTH = 8,			4, 3 );

  -- S5 : overlay SCALAIRE (equation fasmg, meme slot de frame)
  N := 42;
  CHECK( NA = 42,			5, 1 );
  NA := 7;
  CHECK( N = 7,				5, 2 );
  N := N + NA;
  CHECK( NA = 14,			5, 3 );

  -- S6 : motif print_nod -- l'ELABORATION de EB a ecrit (1,0,0,0) dans E
  CHECK( E = 1,				6, 1 );	-- petit-boutiste (comme print_nod)
  E := 65;
  CHECK( EB( 1 ) = 'A',			6, 2 );
  CHECK( EB( 4 ) = ASCII.NUL,		6, 3 );

  -- S7 : overlay record sur parametre in (motif univ_ops exact)
  P1.LO := 3;
  P1.HI := 4;
  CHECK( VIEW_FST( P1 ) = 3,		7, 1 );
  POKE_SND( P1 );
  CHECK( P1.HI = 99,			7, 2 );	-- ecrit a travers l'overlay, relu chez l'appelant
  CHECK( VIEW_FST( P1 ) = 3,		7, 3 );	-- LO intact
  CHECK( VIEW_SND_B( P1 ) = 99,		7, 4 );	-- overlay pose dans un BLOC (niveau > parametre)
  SPREAD_B( P1 );				-- LO : 3 -> 4 (overlay) -> 5 (vue normale) ; HI -> 500
  CHECK( P1.LO = 5,			7, 5 );
  CHECK( P1.HI = 500,			7, 6 );

  PUT( "RESULTAT :" );
  INT_IO.PUT( OK_COUNT,   WIDTH => 3 );
  PUT( " OK," );
  INT_IO.PUT( FAIL_COUNT, WIDTH => 3 );
  PUT_LINE( " ECHECS" );
  if FAIL_COUNT = 0 then
    PUT_LINE( "ADDR_OV1 PASSE" );
  end if;
end ADDR_OV1;
