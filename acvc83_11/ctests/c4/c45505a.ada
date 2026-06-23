-- C45505A.ADA

-- CHECK THAT MULTIPLICATION FOR INTEGER SUBTYPES YIELDS A RESULT
-- BELONGING TO THE BASE TYPE.

-- JBG 2/24/84

WITH REPORT; USE REPORT;
PROCEDURE C45505A IS

     TYPE INT IS RANGE 1..10;

     X, Y : INT := INT(IDENT_INT(5));

BEGIN

     TEST ("C45505A", "CHECK SUBTYPE OF INTEGER MULTIPLICATION");

     BEGIN

          IF X * Y / 5 /= INT(IDENT_INT(5)) THEN
               FAILED ("INCORRECT RESULT");
          END IF;

     EXCEPTION

          WHEN CONSTRAINT_ERROR =>
               IF INT'BASE'LAST >= INT'VAL(25) THEN
                    FAILED ("MULTIPLICATION DOES NOT YIELD RESULT " &
                            "BELONGING TO THE BASE TYPE");
               ELSE
                    COMMENT ("BASE TYPE HAS RANGE LESS THAN 25");
               END IF;
          WHEN NUMERIC_ERROR =>
               IF INT'BASE'LAST >= INT'VAL(25) THEN
                    FAILED ("NUMERIC_ERROR RAISED FOR RESULT " &
                            "BELONGING TO THE BASE TYPE");
               ELSE
                    COMMENT ("BASE TYPE HAS RANGE LESS THAN 25 - " &
                             "NUMERIC_ERROR RAISED");
               END IF;
     END;

     RESULT;

END C45505A;
