with TEXT_IO;
use  TEXT_IO;
procedure ENUM_TEST
is

  type COULEUR	is ( BLEU, BLANC, ROUGE );
  type JOUR	is ( LUNDI, MARDI, MERCREDI, JEUDI, VENDREDI, SAMEDI, DIMANCHE );

  package IO_COULEUR	is new ENUMERATION_IO( COULEUR );
  package IO_JOUR		is new ENUMERATION_IO( JOUR );
  package IO_MODE		is new ENUMERATION_IO( FILE_MODE );

  C	: COULEUR;
  J	: JOUR;

  G	: FILE_TYPE;

begin

  -- === 1. PUT basique ===
  PUT_LINE( "=== 1. PUT basique ===" );
  IO_COULEUR.PUT( BLEU );	NEW_LINE;
  IO_COULEUR.PUT( BLANC );	NEW_LINE;
  IO_COULEUR.PUT( ROUGE );	NEW_LINE;

  -- === 2. PUT avec WIDTH ===
  PUT_LINE( "=== 2. PUT avec WIDTH ===" );
  PUT( "[" );  IO_COULEUR.PUT( BLEU, WIDTH => 10 );   PUT_LINE( "]" );
  PUT( "[" );  IO_COULEUR.PUT( ROUGE, WIDTH => 10 );  PUT_LINE( "]" );

  -- === 3. PUT LOWER_CASE ===
  PUT_LINE( "=== 3. PUT LOWER_CASE ===" );
  IO_COULEUR.PUT( BLEU,  SET => LOWER_CASE );	NEW_LINE;
  IO_COULEUR.PUT( BLANC, SET => LOWER_CASE );	NEW_LINE;
  IO_COULEUR.PUT( ROUGE, SET => LOWER_CASE );	NEW_LINE;

  -- === 4. PUT via variable ===
  PUT_LINE( "=== 4. PUT via variable ===" );
  C := BLANC;  IO_COULEUR.PUT( C );  NEW_LINE;
  C := ROUGE;  IO_COULEUR.PUT( C );  NEW_LINE;

  -- === 5. PUT sans FILE ===
  PUT_LINE( "=== 5. PUT sans FILE ===" );
  IO_COULEUR.PUT( BLEU );  NEW_LINE;

  -- === 6. Type JOUR ===
  PUT_LINE( "=== 6. Type JOUR ===" );
  IO_JOUR.PUT( LUNDI );     NEW_LINE;
  IO_JOUR.PUT( MERCREDI );  NEW_LINE;
  IO_JOUR.PUT( DIMANCHE );  NEW_LINE;

  -- === 7. JOUR WIDTH+LOWER_CASE ===
  PUT_LINE( "=== 7. JOUR WIDTH+LOWER_CASE ===" );
  PUT( "[" );
  IO_JOUR.PUT( SAMEDI, WIDTH => 12, SET => LOWER_CASE );
  PUT_LINE( "]" );

  -- === 8. FILE_MODE ===
  PUT_LINE( "=== 8. FILE_MODE ===" );
  IO_MODE.PUT( IN_FILE );   NEW_LINE;
  IO_MODE.PUT( OUT_FILE );  NEW_LINE;

  -- === 9. Boucle couleurs ===
  PUT_LINE( "=== 9. Boucle couleurs ===" );
  for  I in COULEUR'FIRST .. COULEUR'LAST  loop
    IO_COULEUR.PUT( I );  PUT( " " );
  end loop;
  NEW_LINE;

  -- === 10. Boucle jours ===
  PUT_LINE( "=== 10. Boucle jours ===" );
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
  PUT( "lecture 1..." ); IO_COULEUR.GET( G, C );
  PUT( "Lu 1 : " );  IO_COULEUR.PUT( C );  NEW_LINE;
  PUT( "lecture 2..." ); IO_COULEUR.GET( G, C );
  PUT( "Lu 2 : " );  IO_COULEUR.PUT( C );  NEW_LINE;
  PUT( "lecture 3..." ); IO_COULEUR.GET( G, C );
  PUT( "Lu 3 : " );  IO_COULEUR.PUT( C );  NEW_LINE;
  CLOSE( G );


  -- === 12. GET casse mixte ===
  PUT_LINE( "=== 12. GET casse mixte ===" );
  CREATE( G, OUT_FILE, "enum_data2.dat" );
  PUT_LINE( G, "Rouge" );
  PUT_LINE( G, "blanc" );
  PUT_LINE( G, "BLEU" );
  CLOSE( G );

  OPEN( G, IN_FILE, "enum_data2.dat" );
  PUT( "lecture 1..." ); IO_COULEUR.GET( G, C );
  PUT( "Lu 1 : " );  IO_COULEUR.PUT( C );  NEW_LINE;
  PUT( "lecture 2..." ); IO_COULEUR.GET( G, C );
  PUT( "Lu 2 : " );  IO_COULEUR.PUT( C );  NEW_LINE;
  PUT( "lecture 3..." ); IO_COULEUR.GET( G, C );
  PUT( "Lu 3 : " );  IO_COULEUR.PUT( C );  NEW_LINE;
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
  PUT( "Lu 1 : " );  IO_JOUR.PUT( J );  NEW_LINE;
  IO_JOUR.GET( G, J );
  PUT( "Lu 2 : " );  IO_JOUR.PUT( J );  NEW_LINE;
  IO_JOUR.GET( G, J );
  PUT( "Lu 3 : " );  IO_JOUR.PUT( J );  NEW_LINE;
  CLOSE( G );

  -- === 14. Roundtrip PUT-GET ===
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
    IO_COULEUR.PUT( C );  PUT( " " );
  end loop;
  NEW_LINE;
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
    IO_JOUR.PUT( J );  PUT( " " );
  end loop;
  NEW_LINE;
  CLOSE( G );

  -- === 16. Boucle couleurs avec GET ===
  PUT_LINE( "=== 16. Boucle GET couleurs ===" );
  CREATE( G, OUT_FILE, "enum_data.dat" );
  IO_COULEUR.PUT( G, ROUGE );  NEW_LINE( G );
  IO_COULEUR.PUT( G, BLEU );   NEW_LINE( G );
  IO_COULEUR.PUT( G, BLANC );  NEW_LINE( G );
  CLOSE( G );

  OPEN( G, IN_FILE, "enum_data.dat" );
  for  I in 1 .. 3  loop
    IO_COULEUR.GET( G, C );
    IO_COULEUR.PUT( C );  PUT( " " );
  end loop;
  NEW_LINE;
  CLOSE( G );

  -- === 17. GET sans FILE (console) - commente pour automatiser ===
   PUT_LINE( "=== 17. GET console ===" );
   PUT( "Entrez une couleur : " );
   IO_COULEUR.GET( C );
   PUT( "Lu : " ); IO_COULEUR.PUT( C ); NEW_LINE;

  -- === 18. PUT (string) ===
  PUT_LINE( "=== 18. PUT (string) ===" );
  declare
    S1	: STRING( 1 .. 10 );
    S2	: STRING( 1 .. 10 );
  begin
    IO_COULEUR.PUT( S1, BLEU );
    PUT( '[' ); PUT( S1 ); PUT( ']' ); NEW_LINE;
    IO_COULEUR.PUT( S2, ROUGE, LOWER_CASE );
    PUT( '[' ); PUT( S2 ); PUT( ']' ); NEW_LINE;
  end;

  -- === 19. GET (string) ===
  PUT_LINE( "=== 19. GET (string) ===" );
  declare
    C	: COULEUR;
    L	: POSITIVE;
  begin
    IO_COULEUR.GET( "  rouge suite", C, L );
    IO_COULEUR.PUT( C );
    NEW_LINE;
  end;

  PUT_LINE( "=== FIN ===" );

end	ENUM_TEST;
