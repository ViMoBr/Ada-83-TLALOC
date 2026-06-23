-- C35503B.ADA

-- CHECK THAT 'WIDTH' YIELDS THE CORRECT RESULT WHEN THE PREFIX IS A
-- GENERIC FORMAL DISCRETE TYPE WHOSE ACTUAL PARAMETER IS AN INTEGER 
-- TYPE.

-- RJW 3/17/86

WITH REPORT; USE REPORT;

PROCEDURE C35503B IS

BEGIN
     TEST ("C35503B", "CHECK THAT 'WIDTH' YIELDS THE CORRECT " &
                      "RESULT WHEN THE PREFIX IS A GENERIC FORMAL "  &
                      "DISCRETE TYPE WHOSE ACTUAL PARAMETER IS AN " &
                      "INTEGER TYPE" );

     DECLARE

          TYPE INT IS RANGE -1000 .. 1000;
          TYPE INT2 IS NEW INT RANGE 0E8 .. 1E3;
          SUBTYPE SINT1 IS INT RANGE 00000 .. 300;
          SUBTYPE SINT2 IS INT RANGE 16#E#E1 .. 2#1111_1111#;

          GENERIC
               TYPE I IS (<>);
               W : INTEGER;
          PROCEDURE P (STR : STRING);

          PROCEDURE P (STR : STRING) IS
               SUBTYPE SUBI IS I 
                    RANGE I'VAL (IDENT_INT(224)) .. I'VAL (255);
               SUBTYPE NORANGE IS I 
                    RANGE I'VAL (255) .. I'VAL (IDENT_INT(224));
          BEGIN
               IF IDENT_INT(I'WIDTH) /= W THEN 
                    FAILED ( "INCORRECT I'WIDTH FOR " & STR );
               END IF;

               IF IDENT_INT(SUBI'WIDTH) /= 4 THEN
                    FAILED ( "INCORRECT SUBI'WIDTH FOR " & STR );
               END IF;

               IF IDENT_INT(NORANGE'WIDTH) /= 0 THEN
                    FAILED ( "INCORRECT NORANGE'WIDTH FOR " & STR );
               END IF;
          END P;

          PROCEDURE P_INTEGER IS NEW P (INTEGER, INTEGER'WIDTH);
          PROCEDURE P_INT     IS NEW P (INT, 5);
          PROCEDURE P_INT2    IS NEW P (INT2, 5);
          PROCEDURE P_SINT1   IS NEW P (SINT1, 4);
          PROCEDURE P_SINT2   IS NEW P (SINT2, 4);

     BEGIN
          P_INTEGER ("'INTEGER'");
          P_INT     ("'INT'");
          P_INT2    ("'INT2'");
          P_SINT1   ("'SINT1'");
          P_SINT2   ("'SINT2'");
     END;

     RESULT;
END C35503B;
