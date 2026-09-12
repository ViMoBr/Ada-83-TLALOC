with TEXT_IO;
use  TEXT_IO;
			-----------
procedure			INT_IO_TEST
is			-----------

  F		: FILE_TYPE;
  I_VAL		: INTEGER;
  L_VAL		: LONG_INTEGER;

  package INT_IO	is new INTEGER_IO( NUM => INTEGER );
  package LONG_IO	is new INTEGER_IO( NUM => LONG_INTEGER );


  begin

    -- =========================================================
    PUT_LINE( "=== 1. INTEGER_IO PUT base 10 ===" );
    -- =========================================================

    PUT( "  zero      : " ); INT_IO.PUT(  0,          WIDTH=>1  ); NEW_LINE;
    -- Attendu : 0

    PUT( "  positif   : " ); INT_IO.PUT(  42,         WIDTH=>1  ); NEW_LINE;
    -- Attendu : 42

    PUT( "  negatif   : " ); INT_IO.PUT( -42,         WIDTH=>1  ); NEW_LINE;
    -- Attendu : -42

    PUT( "  grand     : " ); INT_IO.PUT(  2147483647, WIDTH=>1  ); NEW_LINE;
    -- Attendu : 2147483647  (INTEGER'LAST)

    PUT( "  petit     : " ); INT_IO.PUT( -2147483648, WIDTH=>1  ); NEW_LINE;
    -- Attendu : -2147483648  (INTEGER'FIRST)

    PUT( "  WIDTH pad : " ); INT_IO.PUT(  42,         WIDTH=>8  ); NEW_LINE;
    -- Attendu : "      42"  (6 espaces)

    PUT( "  WIDTH=neg : " ); INT_IO.PUT( -42,         WIDTH=>8  ); NEW_LINE;
    -- Attendu : "     -42"  (5 espaces)

    -- =========================================================
    PUT_LINE( "=== 2. INTEGER_IO PUT bases diverses ===" );
    -- =========================================================

    PUT( "  16#FF#    : " ); INT_IO.PUT( 255, WIDTH=>1, BASE=>16 ); NEW_LINE;
    -- Attendu : 16#FF#

    PUT( "  2#1010#   : " ); INT_IO.PUT( 10,  WIDTH=>1, BASE=>2  ); NEW_LINE;
    -- Attendu : 2#1010#

    PUT( "  8#77#     : " ); INT_IO.PUT( 63,  WIDTH=>1, BASE=>8  ); NEW_LINE;
    -- Attendu : 8#77#

    PUT( "  16#neg#   : " ); INT_IO.PUT( -255, WIDTH=>1, BASE=>16 ); NEW_LINE;
    -- Attendu : -16#FF#

    PUT( "  base+pad  : " ); INT_IO.PUT( 255, WIDTH=>10, BASE=>16 ); NEW_LINE;
    -- Attendu : "    16#FF#"  (4 espaces)

    -- =========================================================
    PUT_LINE( "=== 3. LONG_INTEGER PUT ===" );
    -- =========================================================

    PUT( "  grand L   : " );
    LONG_IO.PUT( 9223372036854775807, WIDTH=>1 ); NEW_LINE;
    -- Attendu : 9223372036854775807  (LONG_INTEGER'LAST)

    PUT( "  petit L   : " );
    LONG_IO.PUT( -9223372036854775808, WIDTH=>1 ); NEW_LINE;
    -- Attendu : -9223372036854775808

    PUT( "  16#DEAD#  : " );
    LONG_IO.PUT( 16#DEAD#, WIDTH=>1, BASE=>16 ); NEW_LINE;
    -- Attendu : 16#DEAD#

    -- =========================================================
    PUT_LINE( "=== 4. INTEGER_IO GET depuis fichier base 10 ===" );
    -- =========================================================

    CREATE( F, OUT_FILE, "int_test.dat" );
    INT_IO.PUT( F, 42,          WIDTH=>1 ); NEW_LINE( F );
    INT_IO.PUT( F, -42,         WIDTH=>1 ); NEW_LINE( F );
    INT_IO.PUT( F, 0,           WIDTH=>1 ); NEW_LINE( F );
    INT_IO.PUT( F, 2147483647,  WIDTH=>1 ); NEW_LINE( F );
    INT_IO.PUT( F, -2147483648, WIDTH=>1 ); NEW_LINE( F );
    CLOSE( F );

    OPEN( F, IN_FILE, "int_test.dat" );
    INT_IO.GET( F, I_VAL );
    PUT( "  42        : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : 42

    INT_IO.GET( F, I_VAL );
    PUT( "  -42       : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : -42

    INT_IO.GET( F, I_VAL );
    PUT( "  zero      : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : 0

    INT_IO.GET( F, I_VAL );
    PUT( "  max       : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : 2147483647

    INT_IO.GET( F, I_VAL );
    PUT( "  min       : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : -2147483648

    CLOSE( F );

    -- =========================================================
    PUT_LINE( "=== 5. INTEGER_IO GET depuis fichier based literals ===" );
    -- =========================================================
    -- Le GET doit reconnaitre la syntaxe Ada 83 base#chiffres#.

    CREATE( F, OUT_FILE, "int_based.dat" );
    PUT( F, "16#FF#"   ); NEW_LINE( F );   -- 255
    PUT( F, "2#1010#"  ); NEW_LINE( F );   -- 10
    PUT( F, "8#77#"    ); NEW_LINE( F );   -- 63
    PUT( F, "16#DEAD#" ); NEW_LINE( F );   -- 57005
    PUT( F, "-16#FF#"  ); NEW_LINE( F );   -- -255
    CLOSE( F );

    OPEN( F, IN_FILE, "int_based.dat" );

    INT_IO.GET( F, I_VAL );
    PUT( "  16#FF#    : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : 255

    INT_IO.GET( F, I_VAL );
    PUT( "  2#1010#   : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : 10

    INT_IO.GET( F, I_VAL );
    PUT( "  8#77#     : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : 63

    INT_IO.GET( F, I_VAL );
    PUT( "  16#DEAD#  : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : 57005

    INT_IO.GET( F, I_VAL );
    PUT( "  -16#FF#   : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : -255

    CLOSE( F );

    -- =========================================================
    PUT_LINE( "=== 6. INTEGER_IO GET WIDTH depuis fichier ===" );
    -- =========================================================
    -- Deux entiers colles sans separateur, decoupes par WIDTH exact.

    CREATE( F, OUT_FILE, "int_width.dat" );
    PUT( F, "00042-0007" );
    CLOSE( F );

    OPEN( F, IN_FILE, "int_width.dat" );

    INT_IO.GET( F, I_VAL, WIDTH => 5 );
    PUT( "  WIDTH=5   : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : 42

    INT_IO.GET( F, I_VAL, WIDTH => 5 );
    PUT( "  WIDTH=5   : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : -7

    CLOSE( F );

    -- =========================================================
    PUT_LINE( "=== 7. GET roundtrip deux entiers sur une ligne ===" );
    -- =========================================================
    -- Valide le look-ahead : apres le premier GET (WIDTH=0),
    -- le caractere espace separateur doit rester disponible
    -- pour que le second GET le saute correctement.

    CREATE( F, OUT_FILE, "int_roundtrip.dat" );
    PUT( F, "  1234 -5678" );
    NEW_LINE( F );
    CLOSE( F );

    OPEN( F, IN_FILE, "int_roundtrip.dat" );

    INT_IO.GET( F, I_VAL );
    PUT( "  val1      : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : 1234

    INT_IO.GET( F, I_VAL );
    PUT( "  val2      : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;
    -- Attendu : -5678

    CLOSE( F );

    -- =========================================================
    PUT_LINE( "=== 8. GET trois entiers sur trois lignes ===" );
    -- =========================================================
    -- Valide le saut de LF comme separateur (WIDTH=0).

    CREATE( F, OUT_FILE, "int_lines.dat" );
    INT_IO.PUT( F,  100, WIDTH=>1 ); NEW_LINE( F );
    INT_IO.PUT( F, -200, WIDTH=>1 ); NEW_LINE( F );
    INT_IO.PUT( F,  300, WIDTH=>1 ); NEW_LINE( F );
    CLOSE( F );

    OPEN( F, IN_FILE, "int_lines.dat" );

    INT_IO.GET( F, I_VAL );
    PUT( "  100       : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;

    INT_IO.GET( F, I_VAL );
    PUT( "  -200      : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;

    INT_IO.GET( F, I_VAL );
    PUT( "  300       : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;

    CLOSE( F );

    -- =========================================================
    PUT_LINE( "=== 9. GET console ===" );
    -- =========================================================

    PUT( "  Entrer un entier (ex: -42) : " );
    INT_IO.GET( I_VAL );
    PUT( "  Lu : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;

    PUT( "  Entrer un based (ex: 16#FF#) : " );
    INT_IO.GET( I_VAL );
    PUT( "  Lu : " ); INT_IO.PUT( I_VAL, WIDTH=>1 ); NEW_LINE;

    -- =========================================================
    PUT_LINE( "=== FIN ===" );
    -- =========================================================

  end	INT_IO_TEST;
	-----------
