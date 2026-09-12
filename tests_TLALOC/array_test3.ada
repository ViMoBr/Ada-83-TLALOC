-- ARRAY_TEST3 — Pilier LRM 3.6 : RELIQUAT non contraint (unconstrained arrays)
-- Format AUTO-JUGEANT (cf. ENUM_TEST) : CHECK(cond, section, num) ; verdict greppable.
-- Feuille de route = NOTE_MODELE_UNCONSTRAINED.md (7 trous). Sections U1..U9.
-- Oracle du filet : la ligne « ARRAY_TEST3 PASSE ». Toute régression → « ARRAY_TEST3 ECHOUE »
--   avec « * ECHEC section S test N » pour localiser.
-- Rappel dette 3.5.5 : 'IMAGE d'énuméré hors générique rend la position → on
--   compare des VALEURS, jamais des chaînes formatées d'énumérés.
--
-- Trous ciblés (numéros de la note) :
--   U1 marque de sous-type non contraint : 'FIRST/'LAST/'LENGTH/'RANGE            (trou 1)
--   U2 objet contraint d'un type non contraint : déclaration directe + subtype    (socle)
--   U3 objet non contraint initialisé par AGRÉGAT (bornes déduites)               (trou 3 — SIZ=-1 !)
--   U4 objet non contraint initialisé par littéral chaîne / valeur / fonction     (trou 4)
--   U5 STRING général : sous-types dynamiques STRING(1..N), N variable            (trou 5)
--   U6 composant NON scalaire : array of constrained array, array of record       (trou 2)
--   U7 paramètre/retour non contraints, multidimensionnel                          (conv. d'appel)
--   U8 retour STRING de longueur calculée (non-tranche)                            (trou 4/D6)
--   U9 conversion et re-étiquetage de bornes                                       (trou 7/D5)

with TEXT_IO;  use TEXT_IO;

procedure ARRAY_TEST3 is

  package INT_IO is new INTEGER_IO( INTEGER );
  use INT_IO;

  -- ---- Compteurs et verdict ---------------------------------------------
  NB_OK     : INTEGER := 0;
  NB_ECHECS : INTEGER := 0;

  -- ---- Types non contraints sous test -----------------------------------
  type VECTEUR is array( INTEGER range <> ) of INTEGER;          -- 1D non contraint
  subtype VEC5 is VECTEUR( 1 .. 5 );                             -- sous-type contraint nommé

  type GRILLE  is array( INTEGER range <>, INTEGER range <> )    -- 2D non contraint (U7)
                    of INTEGER;

  type LIGNE3  is array( 1 .. 3 ) of INTEGER;                    -- contraint, composant de U6
  type TABLEAU_DE_LIGNES is array( INTEGER range <> ) of LIGNE3; -- array of constrained array (U6)

  type POINT is record X, Y : INTEGER; end record;
  type NUAGE is array( INTEGER range <> ) of POINT;             -- array of record (U6)

  -- ---- Objets contraints d'un type non contraint (U2) -------------------
  VA : VECTEUR( 1 .. 5 );            -- contrainte directe à la déclaration d'objet
  VB : VEC5;                         -- via sous-type nommé
  G  : GRILLE( 1 .. 2, 4 .. 6 );     -- 2D contraint (bornes distinctes par dim)

-- ---- Objets non contraints à bornes DÉDUITES (U3 — trou n°3) ----------
  -- RM 3.6.1/4.3.2 : agrégat POSITIONNEL vers non contraint → bornes
  -- INDEX'FIRST .. INDEX'FIRST+n-1.  Ici INDEX=INTEGER → 'FIRST = INTEGER'FIRST.
  VC : VECTEUR := ( 10, 20, 30 );                  -- positionnel : 'FIRST = INTEGER'FIRST
  VD : VECTEUR := ( 1 => 100, 2 => 200, 3 => 300 );-- NOMMÉ : bornes explicites 1..3
  SC : STRING  := "abcdef";                        -- littéral : bornes 1..longueur (RM 3.6.3)
  -- ---- STRING général dynamique (U5) ------------------------------------
  N  : INTEGER := 4;
  SN : STRING( 1 .. N );                     -- borne haute variable
  SM : STRING( N .. 2 * N );                 -- bornes basse et haute variables

  -- ---- Composants non scalaires (U6) ------------------------------------
  TL : TABLEAU_DE_LIGNES( 1 .. 2 );
  NU : NUAGE( 1 .. 3 );

  S  : INTEGER;

  procedure CHECK( OK : in BOOLEAN; SECTION : in INTEGER; NUMERO : in INTEGER ) is
  begin
    if OK then
      NB_OK := NB_OK + 1;
    else
      NB_ECHECS := NB_ECHECS + 1;
      PUT( "* ECHEC section " );  PUT( SECTION, WIDTH => 1 );
      PUT( " test " );            PUT( NUMERO,  WIDTH => 1 );
      NEW_LINE;
    end if;
  end CHECK;

  -- ---- Sous-programmes non contraints (U7/U8) ---------------------------
  function SOMME( T : in VECTEUR ) return INTEGER is
    R : INTEGER := 0;
  begin
    for I in T'RANGE loop
      R := R + T( I );
    end loop;
    return R;
  end SOMME;

  function SOMME2D( M : in GRILLE ) return INTEGER is           -- U7 : formel 2D non contraint
    R : INTEGER := 0;
  begin
    for I in M'RANGE( 1 ) loop
      for J in M'RANGE( 2 ) loop
        R := R + M( I, J );
      end loop;
    end loop;
    return R;
  end SOMME2D;

  function REPETE( C : in CHARACTER; K : in INTEGER ) return STRING is  -- U8 : STRING de longueur calculée
    R : STRING( 1 .. K );
  begin
    for I in R'RANGE loop
      R( I ) := C;
    end loop;
    return R;
  end REPETE;

  function LONGUEUR( T : in VECTEUR ) return INTEGER is         -- U7 : 'LENGTH sur formel
  begin
    return T'LENGTH;
  end LONGUEUR;

begin
  ----------------------------------------------------------------------------
  PUT_LINE( "=== U1. Attributs sur MARQUE de sous-type non contraint ===" );
  -- Préfixe = marque de sous-type (VEC5), pas objet. Chemin distinct du dispatch objet.
  CHECK( VEC5'FIRST      = 1, 1, 1 );
  CHECK( VEC5'LAST       = 5, 1, 2 );
  CHECK( VEC5'LENGTH     = 5, 1, 3 );
  S := 0;
  for I in VEC5'RANGE loop S := S + I; end loop;               -- 1+2+3+4+5
  CHECK( S = 15, 1, 4 );

  ----------------------------------------------------------------------------
  PUT_LINE( "=== U2. Objet CONTRAINT d'un type non contraint ===" );
  for I in VA'RANGE loop VA( I ) := I * 2; end loop;
  CHECK( VA( 1 ) = 2  and VA( 5 ) = 10, 2, 1 );
  CHECK( VA'FIRST = 1 and VA'LAST = 5 and VA'LENGTH = 5, 2, 2 );
  for I in VB'RANGE loop VB( I ) := 100 - I; end loop;
  CHECK( VB( 1 ) = 99 and VB( 5 ) = 95, 2, 3 );
  CHECK( VB'LENGTH = 5, 2, 4 );

  ----------------------------------------------------------------------------
  PUT_LINE( "=== U3. Objet non contraint initialise par AGREGAT (bornes deduites) ===" );
  -- Sous-cas positionnel : bornes = INTEGER'FIRST.. ; on teste par offset relatif.
  CHECK( VC'FIRST = INTEGER'FIRST, 3, 1 );                     -- sémantique RM, pas 1
  CHECK( VC'LENGTH = 3, 3, 2 );
  CHECK( VC( VC'FIRST )     = 10, 3, 3 );
  CHECK( VC( VC'FIRST + 2 ) = 30, 3, 4 );
  -- Sous-cas nommé : bornes explicites 1..3.
  CHECK( VD'FIRST = 1 and VD'LAST = 3, 3, 5 );
  CHECK( VD( 1 ) = 100 and VD( 3 ) = 300, 3, 6 );

  ----------------------------------------------------------------------------
  PUT_LINE( "=== U4. Objet non contraint : litteral chaine ===" );
  CHECK( SC'FIRST = 1 and SC'LAST = 6, 4, 1 );
  CHECK( SC'LENGTH = 6, 4, 2 );
  CHECK( SC( 1 ) = 'a' and SC( 6 ) = 'f', 4, 3 );
  CHECK( SC = "abcdef", 4, 4 );

  ----------------------------------------------------------------------------
  PUT_LINE( "=== U5. STRING general : sous-types dynamiques ===" );
  for I in SN'RANGE loop SN( I ) := 'x'; end loop;
  CHECK( SN'FIRST = 1 and SN'LAST = 4, 5, 1 );                 -- 1 .. N, N=4
  CHECK( SN'LENGTH = 4, 5, 2 );
  CHECK( SN = "xxxx", 5, 3 );
  CHECK( SM'FIRST = 4 and SM'LAST = 8, 5, 4 );                 -- N .. 2N = 4 .. 8
  CHECK( SM'LENGTH = 5, 5, 5 );

  ----------------------------------------------------------------------------
  PUT_LINE( "=== U6. Composants NON scalaires ===" );
  for I in TL'RANGE loop
    for J in 1 .. 3 loop
      TL( I )( J ) := 10 * I + J;                              -- array of constrained array
    end loop;
  end loop;
  CHECK( TL( 1 )( 1 ) = 11 and TL( 2 )( 3 ) = 23, 6, 1 );
  CHECK( TL'LENGTH = 2, 6, 2 );
  for I in NU'RANGE loop
    NU( I ).X := I;  NU( I ).Y := -I;                          -- array of record
  end loop;
  CHECK( NU( 1 ).X = 1 and NU( 3 ).Y = -3, 6, 3 );
  CHECK( NU'LENGTH = 3, 6, 4 );

  ----------------------------------------------------------------------------
  PUT_LINE( "=== U7. Parametres et retours non contraints ===" );
  CHECK( SOMME( VA ) = 30, 7, 1 );                             -- 2+4+6+8+10
  CHECK( SOMME( VC ) = 60, 7, 2 );                             -- 10+20+30
  CHECK( LONGUEUR( VD ) = 3, 7, 3 );                           -- 'LENGTH sur formel
  for I in G'RANGE( 1 ) loop
    for J in G'RANGE( 2 ) loop
      G( I, J ) := I + J;
    end loop;
  end loop;
  -- G : (1,2)x(4,5,6) ; somme = Σ(i+j) = 6*(1..2 moy) ... calc direct :
  --   i=1: 5+6+7=18 ; i=2: 6+7+8=21 ; total 39
  CHECK( SOMME2D( G ) = 39, 7, 4 );
  CHECK( G'LENGTH( 1 ) = 2 and G'LENGTH( 2 ) = 3, 7, 5 );

  ----------------------------------------------------------------------------
  PUT_LINE( "=== U8. Retour STRING de longueur CALCULEE (non-tranche) ===" );
  CHECK( REPETE( 'z', 3 ) = "zzz", 8, 1 );                     -- longueur = argument
  CHECK( REPETE( 'a', 1 ) = "a", 8, 2 );

--  CHECK( REPETE( 'q', 5 )'LENGTH = 5, 8, 3 );                  -- 'LENGTH sur retour de fonction

-- U8.3 RETIRÉ (dette D10) : REPETE('q',5)'LENGTH — attribut sur préfixe appel de
  -- fonction (préfixe non nommé). Exercé au lot D10, hors reliquat non contraint.
  -- Le retour STRING de longueur calculée est déjà validé par U8.1/U8.2.
  declare
    Q5 : constant STRING := REPETE( 'q', 5 );                  -- nomme le résultat : contourne D10
  begin
    CHECK( Q5'LENGTH = 5, 8, 3 );                              -- 'LENGTH sur objet nommé (chemin acquis)
  end;
  ----------------------------------------------------------------------------
  PUT_LINE( "=== U9. Conversion et bornes ===" );
  declare
    type AUTRE is array( INTEGER range <> ) of INTEGER;
    subtype A3 is AUTRE( 7 .. 9 );
    RES : A3;
  begin
    RES := A3( VC );                                           -- conversion non contraint→contraint
    CHECK( RES( 7 ) = 10 and RES( 9 ) = 30, 9, 1 );           -- valeurs préservées, glissement d'indices
    CHECK( RES'FIRST = 7 and RES'LAST = 9, 9, 2 );
  end;

  ----------------------------------------------------------------------------
  -- VERDICT GREPPABLE
  ----------------------------------------------------------------------------
  NEW_LINE;
  PUT( "RESULTAT :  " );  PUT( NB_OK, WIDTH => 1 );  PUT( " OK,   " );
  PUT( NB_ECHECS, WIDTH => 1 );  PUT_LINE( " ECHECS" );
  if NB_ECHECS = 0 then
    PUT_LINE( "ARRAY_TEST3 PASSE" );
  else
    PUT_LINE( "ARRAY_TEST3 ECHOUE" );
  end if;

end ARRAY_TEST3;
