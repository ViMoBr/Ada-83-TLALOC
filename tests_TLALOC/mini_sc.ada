-- MINI_SC — SC (littéral) SEUL, un seul CHECK. Décide entre :
--   H1 : collision de symbole STR SC / VAR SC_disp (branche littéral) → 0 0 persiste
--   H2 : interaction avec d'autres objets → 0 0 disparaît ici
-- Attendu si branche littéral saine ET pas de collision : "SC PASSE", 0 échec, aucun 0 0.

with TEXT_IO;  use TEXT_IO;

procedure MINI_SC is

  package INT_IO is new INTEGER_IO( INTEGER );
  use INT_IO;

  NB_OK     : INTEGER := 0;
  NB_ECHECS : INTEGER := 0;

  SC : STRING := "abcdef";           -- unique objet non contraint, init littéral

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
  CHECK( SC'FIRST = 1,    4, 1 );
  CHECK( SC'LAST  = 6,    4, 2 );
  CHECK( SC( 1 ) = 'a',   4, 3 );
  CHECK( SC( 6 ) = 'f',   4, 4 );
  CHECK( SC = "abcdef",   4, 5 );

  NEW_LINE;
  PUT( "RESULTAT :  " );  PUT( NB_OK, WIDTH => 1 );  PUT( " OK,   " );
  PUT( NB_ECHECS, WIDTH => 1 );  PUT_LINE( " ECHECS" );
  if NB_ECHECS = 0 then
    PUT_LINE( "SC PASSE" );
  else
    PUT_LINE( "SC ECHOUE" );
  end if;
end MINI_SC;
