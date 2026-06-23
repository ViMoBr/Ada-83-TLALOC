-- A35801E.ADA

-- OBJECTIVE:
--     WHEN THE PREFIX IS A STATIC SUBTYPE OF A FLOATING POINT TYPE,
--     CHECK THAT THE ATTRIBUTES DIGITS, MANTISSA, EMAX, AND
--     SAFE_EMAX, SMALL, LARGE, EPSILON, SAFE_SMALL, SAFE_LARGE,
--     FIRST, AND LAST CAN BE USED IN STATIC EXPRESSIONS.

-- HISTORY:
--     RJW 8/21/86  CREATED ORIGINAL TEST.
--     RJW 2/08/88  INITIALIZED THE CASE-SELECTOR. REVISED HEADING.

WITH REPORT; USE REPORT;
PROCEDURE A35801E IS

BEGIN
     TEST ( "A35801E", "WHEN THE PREFIX IS A STATIC SUBTYPE OF A " &
                       "FLOATING POINT TYPE, CHECK THAT THE " &
                       "ATTRIBUTES DIGITS, MANTISSA, EMAX, AND " &
                       "SAFE_EMAX, SMALL, LARGE, EPSILON, " &
                       "SAFE_SMALL, SAFE_LARGE, FIRST, AND LAST " &
                       "CAN BE USED IN STATIC EXPRESSIONS" );

     DECLARE
          SUBTYPE SFLT IS FLOAT RANGE -10.0 .. 10.0;

          TYPE INT IS RANGE FLOAT'DIGITS .. FLOAT'DIGITS;

          NUM : CONSTANT := FLOAT'MANTISSA;

          TYPE REC (B : INTEGER) IS
               RECORD
                    CASE B IS
                         WHEN FLOAT'SAFE_EMAX =>
                              X : INTEGER;
                         WHEN OTHERS =>
                              Y : BOOLEAN;
                    END CASE;
               END RECORD;

          J : CONSTANT := INTEGER'POS (FLOAT'SAFE_EMAX);

          TYPE FLT1 IS DIGITS FLOAT'DIGITS
                       RANGE FLOAT'FIRST .. FLOAT'LAST;

          TYPE FLT2 IS DIGITS FLT1'DIGITS
                       RANGE FLT1'SMALL .. FLT1'LARGE;

          TYPE FLT3 IS DIGITS FLT2'DIGITS
                       RANGE FLT2'SAFE_SMALL .. FLT2'SAFE_LARGE;

          RNUM : CONSTANT := FLT1'EPSILON;

          I : INTEGER := IDENT_INT (1);

     BEGIN
          CASE I IS
               WHEN FLT3'DIGITS =>
                    NULL;
               WHEN FLT3'MANTISSA =>
                    NULL;
               WHEN FLT3'EMAX =>
                    NULL;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;

     RESULT;
END A35801E;
