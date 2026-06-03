with TEXT_IO;
use  TEXT_IO;
				-------------------
procedure				FLOAT_FIXED_IO_TEST
is				-------------------

  -- Instanciations FLOAT_IO
  package LF_IO	is new FLOAT_IO( NUM => LONG_FLOAT );
  package F_IO	is new FLOAT_IO( NUM => FLOAT );

  -- DURATION : type pre-defini Ada 83, point fixe delta 0.020 (SYSTEM)
  -- Instanciation FIXED_IO
  package DUR_IO is new FIXED_IO( NUM => DURATION );

    F		: FILE_TYPE;
    LF_VAL	: LONG_FLOAT;
    F_VAL		: FLOAT;
    D_VAL		: DURATION;

  begin

    -- =========================================================
    PUT_LINE( "=== 1. FLOAT_IO PUT LONG_FLOAT — formats ===" );
    -- =========================================================
    -- Verifie FORE/AFT/EXP sur des valeurs representatives.
    -- Format scientifique : 1 chiffre avant le point, AFT apres,
    -- EXP chiffres d'exposant.

    PUT( "  pi        : " );
    LF_IO.PUT( 3.14159265358979,  FORE=>1, AFT=>6, EXP=>2 );
    NEW_LINE;
    -- Attendu : 3.141593E+00

    PUT( "  grand     : " );
    LF_IO.PUT( 1.23456789E+15,    FORE=>1, AFT=>4, EXP=>2 );
    NEW_LINE;
    -- Attendu : 1.2346E+15

    PUT( "  petit     : " );
    LF_IO.PUT( -4.56789E-08,      FORE=>1, AFT=>4, EXP=>2 );
    NEW_LINE;
    -- Attendu : -4.5679E-08

    PUT( "  zero      : " );
    LF_IO.PUT( 0.0,               FORE=>1, AFT=>3, EXP=>2 );
    NEW_LINE;
    -- Attendu : 0.000E+00

    PUT( "  un        : " );
    LF_IO.PUT( 1.0,               FORE=>1, AFT=>2, EXP=>2 );
    NEW_LINE;
    -- Attendu : 1.00E+00

    PUT( "  negatif   : " );
    LF_IO.PUT( -1.0,              FORE=>1, AFT=>2, EXP=>2 );
    NEW_LINE;
    -- Attendu : -1.00E+00

    PUT( "  FORE pad  : " );
    LF_IO.PUT( 2.5,               FORE=>4, AFT=>2, EXP=>2 );
    NEW_LINE;
    -- Attendu : "   2.50E+00"  (3 espaces avant le 2)

    -- =========================================================
    PUT_LINE( "=== 2. FLOAT_IO PUT FLOAT ===" );
    -- =========================================================

    PUT( "  e         : " );
    F_IO.PUT( 2.71828,            FORE=>1, AFT=>4, EXP=>2 );
    NEW_LINE;
    -- Attendu : 2.7183E+00

    PUT( "  negatif   : " );
    F_IO.PUT( -0.001,             FORE=>1, AFT=>3, EXP=>2 );
    NEW_LINE;
    -- Attendu : -1.000E-03

    -- =========================================================
    PUT_LINE( "=== 3. FIXED_IO PUT DURATION ===" );
    -- =========================================================
    -- DURATION : point fixe, delta = 0.020 s (SYSTEM.TICK).
    -- PUT sans exposant (EXP=0) : format decimal pur.

    PUT( "  1.5 s     : " );
    DUR_IO.PUT( 1.5,              FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;
    -- Attendu : 1.500

    PUT( "  0.02 s    : " );
    DUR_IO.PUT( 0.020,            FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;
    -- Attendu : 0.020

    PUT( "  negatif   : " );
    DUR_IO.PUT( -3.14,            FORE=>1, AFT=>2, EXP=>0 );
    NEW_LINE;
    -- Attendu : -3.14

    PUT( "  zero      : " );
    DUR_IO.PUT( 0.0,              FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;
    -- Attendu : 0.000

    PUT( "  FORE pad  : " );
    DUR_IO.PUT( 12.5,             FORE=>4, AFT=>2, EXP=>0 );
    NEW_LINE;
    -- Attendu : "  12.50"  (2 espaces avant le 1)

    -- =========================================================
    PUT_LINE( "=== 4. FLOAT_IO GET depuis fichier ===" );
    -- =========================================================
    -- Ecriture d'un fichier contenant plusieurs reels, un par ligne,
    -- puis relecture et comparaison.

    CREATE( F, OUT_FILE, "float_test.dat" );
    LF_IO.PUT( F, 3.14159265358979, FORE=>1, AFT=>10, EXP=>2 );
    NEW_LINE( F );
    LF_IO.PUT( F, -2.71828182845905, FORE=>1, AFT=>10, EXP=>2 );
    NEW_LINE( F );
    LF_IO.PUT( F, 1.0E+20,           FORE=>1, AFT=>4,  EXP=>2 );
    NEW_LINE( F );
    LF_IO.PUT( F, -1.0E-10,          FORE=>1, AFT=>4,  EXP=>2 );
    NEW_LINE( F );
    LF_IO.PUT( F, 0.0,               FORE=>1, AFT=>3,  EXP=>2 );
    NEW_LINE( F );
    CLOSE( F );

    OPEN( F, IN_FILE, "float_test.dat" );

    LF_IO.GET( F, LF_VAL );
    PUT( "  pi        : " ); LF_IO.PUT( LF_VAL, FORE=>1, AFT=>6, EXP=>2 );
    NEW_LINE;
    -- Attendu : 3.141593E+00

    LF_IO.GET( F, LF_VAL );
    PUT( "  -e        : " ); LF_IO.PUT( LF_VAL, FORE=>1, AFT=>6, EXP=>2 );
    NEW_LINE;
    -- Attendu : -2.718282E+00

    LF_IO.GET( F, LF_VAL );
    PUT( "  1E+20     : " ); LF_IO.PUT( LF_VAL, FORE=>1, AFT=>2, EXP=>2 );
    NEW_LINE;
    -- Attendu : 1.00E+20

    LF_IO.GET( F, LF_VAL );
    PUT( "  -1E-10    : " ); LF_IO.PUT( LF_VAL, FORE=>1, AFT=>2, EXP=>2 );
    NEW_LINE;
    -- Attendu : -1.00E-10

    LF_IO.GET( F, LF_VAL );
    PUT( "  zero      : " ); LF_IO.PUT( LF_VAL, FORE=>1, AFT=>3, EXP=>2 );
    NEW_LINE;
    -- Attendu : 0.000E+00

    CLOSE( F );

    -- =========================================================
    PUT_LINE( "=== 5. FLOAT_IO GET WIDTH depuis fichier ===" );
    -- =========================================================
    -- Un fichier d'une seule ligne contenant "3.14159" colle contre
    -- "-2.718" sans separateur de ligne entre eux (WIDTH exact).
    -- WIDTH=7 : lit exactement "3.14159".
    -- WIDTH=6 : lit exactement "-2.718".

    CREATE( F, OUT_FILE, "float_width.dat" );
    PUT( F, "3.14159-2.718" );
    CLOSE( F );

    OPEN( F, IN_FILE, "float_width.dat" );
    LF_IO.GET( F, LF_VAL, WIDTH => 7 );
    PUT( "  WIDTH=7   : " ); LF_IO.PUT( LF_VAL, FORE=>1, AFT=>4, EXP=>2 );
    NEW_LINE;
    -- Attendu : 3.1416E+00

    LF_IO.GET( F, LF_VAL, WIDTH => 6 );
    PUT( "  WIDTH=6   : " ); LF_IO.PUT( LF_VAL, FORE=>1, AFT=>3, EXP=>2 );
    NEW_LINE;
    -- Attendu : -2.718E+00

    CLOSE( F );

    -- =========================================================
    PUT_LINE( "=== 6. FLOAT_IO GET console ===" );
    -- =========================================================
    -- Lecture interactive : l'utilisateur tape un reel.
    -- Le programme reaffiche la valeur lue.

    PUT( "  Entrer un reel (ex: -1.5E+2) : " );
    LF_IO.GET( LF_VAL );
    PUT( "  Lu : " );
    LF_IO.PUT( LF_VAL, FORE=>1, AFT=>4, EXP=>2 );
    NEW_LINE;

    -- =========================================================
    PUT_LINE( "=== 7. FIXED_IO GET depuis fichier ===" );
    -- =========================================================
    -- Ecriture d'un fichier avec des durees, relecture et
    -- reaffichage. On ecrit en format decimal pur (EXP=0),
    -- on relit avec le nouveau GET.

    CREATE( F, OUT_FILE, "fixed_test.dat" );
    DUR_IO.PUT( F, 1.5,    FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE( F );
    DUR_IO.PUT( F, 0.02,   FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE( F );
    DUR_IO.PUT( F, -3.14,  FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE( F );
    DUR_IO.PUT( F, 0.0,    FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE( F );
    CLOSE( F );

    OPEN( F, IN_FILE, "fixed_test.dat" );

    DUR_IO.GET( F, D_VAL );
    PUT( "  1.5 s     : " ); DUR_IO.PUT( D_VAL, FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;
    -- Attendu : 1.500

    DUR_IO.GET( F, D_VAL );
    PUT( "  0.02 s    : " ); DUR_IO.PUT( D_VAL, FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;
    -- Attendu : 0.020

    DUR_IO.GET( F, D_VAL );
    PUT( "  -3.14 s   : " ); DUR_IO.PUT( D_VAL, FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;
    -- Attendu : -3.140

    DUR_IO.GET( F, D_VAL );
    PUT( "  zero      : " ); DUR_IO.PUT( D_VAL, FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;
    -- Attendu : 0.000

    CLOSE( F );

    -- =========================================================
    PUT_LINE( "=== 8. FIXED_IO GET avec exposant dans fichier ===" );
    -- =========================================================
    -- Le GET de FIXED_IO accepte un exposant decimal optionnel
    -- (LRM 14.3.9 renvoie a 14.3.8). On verifie que 2.5E-1
    -- est bien lu comme 0.25 s.

    CREATE( F, OUT_FILE, "fixed_exp.dat" );
    PUT( F, "2.5E-1" );
    NEW_LINE( F );
    PUT( F, "1.0E+1" );
    NEW_LINE( F );
    CLOSE( F );

    OPEN( F, IN_FILE, "fixed_exp.dat" );

    DUR_IO.GET( F, D_VAL );
    PUT( "  2.5E-1    : " ); DUR_IO.PUT( D_VAL, FORE=>1, AFT=>4, EXP=>0 );
    NEW_LINE;
    -- Attendu : 0.2500

    DUR_IO.GET( F, D_VAL );
    PUT( "  1.0E+1    : " ); DUR_IO.PUT( D_VAL, FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;
    -- Attendu : 10.000

    CLOSE( F );

    -- =========================================================
    PUT_LINE( "=== 9. FIXED_IO GET WIDTH depuis fichier ===" );
    -- =========================================================
    -- Meme principe que la section 5 pour FLOAT_IO.

    CREATE( F, OUT_FILE, "fixed_width.dat" );
    PUT( F, "1.500-3.140" );
    CLOSE( F );

    OPEN( F, IN_FILE, "fixed_width.dat" );

    DUR_IO.GET( F, D_VAL, WIDTH => 5 );
    PUT( "  WIDTH=5   : " ); DUR_IO.PUT( D_VAL, FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;
    -- Attendu : 1.500

    DUR_IO.GET( F, D_VAL, WIDTH => 6 );
    PUT( "  WIDTH=6   : " ); DUR_IO.PUT( D_VAL, FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;
    -- Attendu : -3.140

    CLOSE( F );

    -- =========================================================
    PUT_LINE( "=== 10. FIXED_IO GET console ===" );
    -- =========================================================

    PUT( "  Entrer une duree (ex: 1.5) : " );
    DUR_IO.GET( D_VAL );
    PUT( "  Lu : " );
    DUR_IO.PUT( D_VAL, FORE=>1, AFT=>3, EXP=>0 );
    NEW_LINE;

    -- =========================================================
    PUT_LINE( "=== 11. GET roundtrip — deux valeurs sur une ligne ===" );
    -- =========================================================
    -- Test du comportement look-ahead apres GET WIDTH=0 :
    -- deux reels separes par un espace sur la meme ligne,
    -- le second GET doit sauter l'espace et trouver la valeur.

    CREATE( F, OUT_FILE, "roundtrip.dat" );
    PUT( F, "  1.41421 2.71828" );
    NEW_LINE( F );
    CLOSE( F );

    OPEN( F, IN_FILE, "roundtrip.dat" );

    LF_IO.GET( F, LF_VAL );
    PUT( "  val1      : " ); LF_IO.PUT( LF_VAL, FORE=>1, AFT=>4, EXP=>2 );
    NEW_LINE;
    -- Attendu : 1.4142E+00

    LF_IO.GET( F, LF_VAL );
    PUT( "  val2      : " ); LF_IO.PUT( LF_VAL, FORE=>1, AFT=>4, EXP=>2 );
    NEW_LINE;
    -- Attendu : 2.7183E+00

    CLOSE( F );

    PUT_LINE( "=== FIN ===" );

end	FLOAT_FIXED_IO_TEST;
	-------------------
