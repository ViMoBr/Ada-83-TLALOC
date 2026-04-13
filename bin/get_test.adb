with TEXT_IO; use TEXT_IO;
procedure GET_TEST is
  package FIO is new FLOAT_IO( FLOAT );
  X : FLOAT;
  CHN : STRING( 1 .. 40 );
  LEN : NATURAL;
  C	: CHARACTER;
begin
  PUT("Entrez un flottant : ");
  GET_LINE( CHN, LEN );
  PUT("Lu : [");
  PUT( CHN(1..LEN) );
  PUT_LINE("]");
  -- maintenant tester le GET depuis fichier
  -- ecrire un flottant dans un fichier, relire
  declare
    F : FILE_TYPE;
  begin
    -- === Test 1 : ecriture avec FIO.PUT dans un fichier ===
    PUT_LINE("=== Test 1 : FIO.PUT 3.14159 dans fichier ===");
    CREATE( F, OUT_FILE, "ftest.dat" );
    FIO.PUT( F, 3.14159, FORE=>2, AFT=>5, EXP=>3 );
    NEW_LINE( F );
    CLOSE( F );
    PUT_LINE("Ecriture OK");

    -- === Test 2 : relecture du 3.14159 avec FIO.GET depuis fichier ===
    PUT_LINE("=== Test 2 : FIO.GET depuis fichier ===");
    OPEN( F, IN_FILE, "ftest.dat" );
    FIO.GET( F, X );
    CLOSE( F );
    PUT("Relu depuis fichier : ");
    FIO.PUT( X, FORE=>2, AFT=>6, EXP=>3 );
    NEW_LINE;

    -- === Test 3 : relecture du 3.14159 avec GET_LINE pour verification ===
    PUT_LINE("=== Test 3 : verification GET_LINE ===");
    OPEN( F, IN_FILE, "ftest.dat" );
    GET_LINE( F, CHN, LEN );
    CLOSE( F );
    PUT("Contenu brut : [");
    PUT( CHN(1..LEN) );
    PUT_LINE("]");

    -- === Test 4 : FIO.PUT 2.71828 sur stdout ===
    PUT_LINE("=== Test 4 : FIO.PUT stdout ===");
    FIO.PUT( 2.71828, FORE=>2, AFT=>5, EXP=>3 );
    NEW_LINE;
  end;
end GET_TEST;
