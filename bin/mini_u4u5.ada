-- MINI_U4U5 — isole U4 (littéral chaîne) et U5 (STRING dynamique) de toute
-- corruption amont. But : décider si la branche DN_STRING_LITERAL de
-- COMPILE_ARRAY_VAR est SAINE (hypothèse) ou porte le même bug que l'agrégat.
-- Aucun objet non contraint initialisé par AGRÉGAT n'est déclaré avant.
-- Attendu si la branche littéral est saine : U4U5 PASSE.

with TEXT_IO;  use TEXT_IO;

procedure MINI_U4U5 is

  package INT_IO is new INTEGER_IO( INTEGER );
  use INT_IO;

  NB_OK     : INTEGER := 0;
  NB_ECHECS : INTEGER := 0;

  N  : INTEGER := 4;

  SC : STRING := "abcdef";           -- U4 : littéral → objet non contraint (bornes 1..6)
  SN : STRING( 1 .. N );             -- U5 : borne haute variable
  SM : STRING( N .. 2 * N );         -- U5 : bornes basse et haute variables

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

begin
  PUT_LINE( "=== U4. Objet non contraint : litteral chaine ===" );
  CHECK( SC'FIRST = 1 and SC'LAST = 6, 4, 1 );
  CHECK( SC'LENGTH = 6, 4, 2 );
  CHECK( SC( 1 ) = 'a' and SC( 6 ) = 'f', 4, 3 );
  CHECK( SC = "abcdef", 4, 4 );

  PUT_LINE( "=== U5. STRING general : sous-types dynamiques ===" );
  for I in SN'RANGE loop SN( I ) := 'x'; end loop;
  CHECK( SN'FIRST = 1 and SN'LAST = 4, 5, 1 );
  CHECK( SN'LENGTH = 4, 5, 2 );
  CHECK( SN = "xxxx", 5, 3 );
  CHECK( SM'FIRST = 4 and SM'LAST = 8, 5, 4 );
  CHECK( SM'LENGTH = 5, 5, 5 );

  NEW_LINE;
  PUT( "RESULTAT :  " );  PUT( NB_OK, WIDTH => 1 );  PUT( " OK,   " );
  PUT( NB_ECHECS, WIDTH => 1 );  PUT_LINE( " ECHECS" );
  if NB_ECHECS = 0 then
    PUT_LINE( "U4U5 PASSE" );
  else
    PUT_LINE( "U4U5 ECHOUE" );
  end if;
end MINI_U4U5;
