-- ENUM_TEST (version auto-jugeante) -- TEXT_IO.ENUMERATION_IO
-- Chaque section verifie mecaniquement ses resultats via CHECK ; le verdict
-- final est greppable par le filet : "ENUM_TEST PASSE" / "ENUM_TEST ECHOUE".
-- Sections purement visuelles conservees (formats WIDTH console) : V2, V7, V10.
-- La section console interactive (17) est placee APRES le verdict ; le filet
-- peut l'alimenter par un pipe ("rouge") ou l'ignorer.

with TEXT_IO;
use  TEXT_IO;
procedure ENUM_TEST
is

  type COULEUR	is ( BLEU, BLANC, ROUGE );
  type JOUR	is ( LUNDI, MARDI, MERCREDI, JEUDI, VENDREDI, SAMEDI, DIMANCHE );

  package IO_COULEUR	is new ENUMERATION_IO( COULEUR );
  package IO_JOUR	is new ENUMERATION_IO( JOUR );
  package IO_MODE	is new ENUMERATION_IO( FILE_MODE );
  package IO_ENT	is new INTEGER_IO( INTEGER );

  C	: COULEUR;
  J	: JOUR;

  G	: FILE_TYPE;

  NB_OK		: INTEGER := 0;
  NB_ECHECS	: INTEGER := 0;

  procedure CHECK ( OK : in BOOLEAN; SECTION : in INTEGER; NUMERO : in INTEGER )
  is
  begin
    if  OK  then
      NB_OK := NB_OK + 1;
    else
      NB_ECHECS := NB_ECHECS + 1;
      PUT( "* ECHEC section" );
      IO_ENT.PUT( SECTION, WIDTH => 3 );
      PUT( " test" );
      IO_ENT.PUT( NUMERO, WIDTH => 3 );
      NEW_LINE;
    end if;
  end CHECK;

begin

  -- === 1. PUT vers chaine : littéraux de base ===
  PUT_LINE( "=== 1. PUT vers chaine ===" );
  declare
    S : STRING( 1 .. 10 );
  begin
    IO_COULEUR.PUT( S, BLEU );
    CHECK( S = "BLEU      ", 1, 1 );
    IO_COULEUR.PUT( S, BLANC );
    CHECK( S = "BLANC     ", 1, 2 );
    IO_COULEUR.PUT( S, ROUGE );
    CHECK( S = "ROUGE     ", 1, 3 );
  end;

  -- === V2. PUT avec WIDTH (visuel) ===
  PUT_LINE( "=== V2. PUT avec WIDTH (attendu [      BLEU] [     ROUGE]) ===" );
  PUT( "[" );  IO_COULEUR.PUT( BLEU, WIDTH => 10 );   PUT_LINE( "]" );
  PUT( "[" );  IO_COULEUR.PUT( ROUGE, WIDTH => 10 );  PUT_LINE( "]" );

  -- === 3. LOWER_CASE vers chaine ===
  PUT_LINE( "=== 3. LOWER_CASE ===" );
  declare
    S : STRING( 1 .. 10 );
  begin
    IO_COULEUR.PUT( S, BLEU,  LOWER_CASE );
    CHECK( S = "bleu      ", 3, 1 );
    IO_COULEUR.PUT( S, ROUGE, LOWER_CASE );
    CHECK( S = "rouge     ", 3, 2 );
  end;

  -- === 4. PUT via variable ===
  PUT_LINE( "=== 4. PUT via variable ===" );
  declare
    S : STRING( 1 .. 8 );
  begin
    C := BLANC;
    IO_COULEUR.PUT( S, C );
    CHECK( S = "BLANC   ", 4, 1 );
  end;

  -- === 5. PUT console sans FILE (visuel court, attendu BLEU) ===
  PUT_LINE( "=== 5. PUT console (attendu BLEU) ===" );
  IO_COULEUR.PUT( BLEU );  NEW_LINE;

  -- === 6. Type JOUR vers chaine ===
  PUT_LINE( "=== 6. Type JOUR ===" );
  declare
    S : STRING( 1 .. 10 );
  begin
    IO_JOUR.PUT( S, LUNDI );
    CHECK( S = "LUNDI     ", 6, 1 );
    IO_JOUR.PUT( S, MERCREDI );
    CHECK( S = "MERCREDI  ", 6, 2 );
    IO_JOUR.PUT( S, DIMANCHE );
    CHECK( S = "DIMANCHE  ", 6, 3 );
  end;

  -- === V7. JOUR WIDTH+LOWER_CASE (visuel, attendu [      samedi]) ===
  PUT_LINE( "=== V7. JOUR WIDTH+LOWER_CASE ===" );
  PUT( "[" );
  IO_JOUR.PUT( SAMEDI, WIDTH => 12, SET => LOWER_CASE );
  PUT_LINE( "]" );

  -- === 8. FILE_MODE vers chaine ===
  PUT_LINE( "=== 8. FILE_MODE ===" );
  declare
    S : STRING( 1 .. 10 );
  begin
    IO_MODE.PUT( S, IN_FILE );
    CHECK( S = "IN_FILE   ", 8, 1 );
    IO_MODE.PUT( S, OUT_FILE );
    CHECK( S = "OUT_FILE  ", 8, 2 );
  end;

  -- === 9. Boucle couleurs : POS et bornes ===
  PUT_LINE( "=== 9. Boucle couleurs ===" );
  declare
    N : INTEGER := 0;
  begin
    for  I in COULEUR'FIRST .. COULEUR'LAST  loop
      N := N + 1;
    end loop;
    CHECK( N = 3, 9, 1 );
    CHECK( COULEUR'FIRST = BLEU  and COULEUR'LAST = ROUGE, 9, 2 );
  end;

  -- === V10. Boucle jours WIDTH (visuel) ===
  PUT_LINE( "=== V10. Boucle jours WIDTH=10 ===" );
  for  I in JOUR'FIRST .. JOUR'LAST  loop
    IO_JOUR.PUT( I, WIDTH => 10 );
  end loop;
  NEW_LINE;

  -- === 11. GET fichier ===
  PUT_LINE( "=== 11. GET fichier ===" );
  CREATE( G, OUT_FILE, "enum_data.dat" );
  PUT_LINE( G, "ROUGE" );
  PUT_LINE( G, "BLANC" );
  PUT_LINE( G, "BLEU" );
  CLOSE( G );

  OPEN( G, IN_FILE, "enum_data.dat" );
  IO_COULEUR.GET( G, C );
  CHECK( C = ROUGE, 11, 1 );
  IO_COULEUR.GET( G, C );
  CHECK( C = BLANC, 11, 2 );
  IO_COULEUR.GET( G, C );
  CHECK( C = BLEU,  11, 3 );
  CLOSE( G );

  -- === 12. GET casse mixte ===
  PUT_LINE( "=== 12. GET casse mixte ===" );
  CREATE( G, OUT_FILE, "enum_data2.dat" );
  PUT_LINE( G, "Rouge" );
  PUT_LINE( G, "blanc" );
  PUT_LINE( G, "BLEU" );
  CLOSE( G );

  OPEN( G, IN_FILE, "enum_data2.dat" );
  IO_COULEUR.GET( G, C );
  CHECK( C = ROUGE, 12, 1 );
  IO_COULEUR.GET( G, C );
  CHECK( C = BLANC, 12, 2 );
  IO_COULEUR.GET( G, C );
  CHECK( C = BLEU,  12, 3 );
  CLOSE( G );

  -- === 13. GET JOUR ===
  PUT_LINE( "=== 13. GET JOUR ===" );
  CREATE( G, OUT_FILE, "jour_data.dat" );
  PUT_LINE( G, "LUNDI" );
  PUT_LINE( G, "vendredi" );
  PUT_LINE( G, "Dimanche" );
  CLOSE( G );

  OPEN( G, IN_FILE, "jour_data.dat" );
  IO_JOUR.GET( G, J );
  CHECK( J = LUNDI,    13, 1 );
  IO_JOUR.GET( G, J );
  CHECK( J = VENDREDI, 13, 2 );
  IO_JOUR.GET( G, J );
  CHECK( J = DIMANCHE, 13, 3 );
  CLOSE( G );

  -- === 14. Roundtrip PUT-GET couleurs ===
  PUT_LINE( "=== 14. Roundtrip ===" );
  CREATE( G, OUT_FILE, "roundtrip.dat" );
  for  I in COULEUR'FIRST .. COULEUR'LAST  loop
    IO_COULEUR.PUT( G, I );
    NEW_LINE( G );
  end loop;
  CLOSE( G );

  OPEN( G, IN_FILE, "roundtrip.dat" );
  for  I in COULEUR'FIRST .. COULEUR'LAST  loop
    IO_COULEUR.GET( G, C );
    CHECK( C = I, 14, COULEUR'POS( I ) + 1 );
  end loop;
  CLOSE( G );

  -- === 15. Roundtrip JOUR ===
  PUT_LINE( "=== 15. Roundtrip JOUR ===" );
  CREATE( G, OUT_FILE, "jour_rt.dat" );
  for  I in JOUR'FIRST .. JOUR'LAST  loop
    IO_JOUR.PUT( G, I );
    NEW_LINE( G );
  end loop;
  CLOSE( G );

  OPEN( G, IN_FILE, "jour_rt.dat" );
  for  I in JOUR'FIRST .. JOUR'LAST  loop
    IO_JOUR.GET( G, J );
    CHECK( J = I, 15, JOUR'POS( I ) + 1 );
  end loop;
  CLOSE( G );

  -- === 16. Boucle GET couleurs (ordre different de la declaration) ===
  PUT_LINE( "=== 16. Boucle GET couleurs ===" );
  CREATE( G, OUT_FILE, "enum_data.dat" );
  IO_COULEUR.PUT( G, ROUGE );  NEW_LINE( G );
  IO_COULEUR.PUT( G, BLEU );   NEW_LINE( G );
  IO_COULEUR.PUT( G, BLANC );  NEW_LINE( G );
  CLOSE( G );

  OPEN( G, IN_FILE, "enum_data.dat" );
  IO_COULEUR.GET( G, C );
  CHECK( C = ROUGE, 16, 1 );
  IO_COULEUR.GET( G, C );
  CHECK( C = BLEU,  16, 2 );
  IO_COULEUR.GET( G, C );
  CHECK( C = BLANC, 16, 3 );
  CLOSE( G );

  -- === 18. PUT (string) : cadrage et casse ===
  PUT_LINE( "=== 18. PUT (string) ===" );
  declare
    S1	: STRING( 1 .. 10 );
    S2	: STRING( 1 .. 10 );
  begin
    IO_COULEUR.PUT( S1, BLEU );
    CHECK( S1 = "BLEU      ", 18, 1 );
    IO_COULEUR.PUT( S2, ROUGE, LOWER_CASE );
    CHECK( S2 = "rouge     ", 18, 2 );
  end;

  -- === 19. GET (string) : token, casse, index de fin ===
  PUT_LINE( "=== 19. GET (string) ===" );
  declare
    CL	: COULEUR;
    L	: POSITIVE;
  begin
    IO_COULEUR.GET( "  rouge suite", CL, L );
    CHECK( CL = ROUGE, 19, 1 );
    CHECK( L = 7,      19, 2 );			-- dernier caractere lu : le 'e' de rouge

    IO_COULEUR.GET( "BLEU", CL, L );
    CHECK( CL = BLEU, 19, 3 );
    CHECK( L = 4,     19, 4 );
  end;

  -- === VERDICT ===
  NEW_LINE;
  PUT( "RESULTAT :" );
  IO_ENT.PUT( NB_OK, WIDTH => 4 );
  PUT( " OK," );
  IO_ENT.PUT( NB_ECHECS, WIDTH => 4 );
  PUT_LINE( " ECHECS" );

  if  NB_ECHECS = 0  then
    PUT_LINE( "ENUM_TEST PASSE" );
  else
    PUT_LINE( "ENUM_TEST ECHOUE" );
  end if;

  -- === 17. GET console (manuel, apres le verdict ; pipe possible) ===
  PUT_LINE( "=== 17. GET console : tapez rouge ===" );
  IO_COULEUR.GET( C );
  if  C = ROUGE  then
    PUT_LINE( "console OK" );
  else
    PUT_LINE( "console ECHEC" );
  end if;

end	ENUM_TEST;
