-- C45303A.ADA

-- CHECK THAT ADDITION AND SUBTRACTION YIELD RESULTS BELONGING TO THE
-- BASE TYPE.

-- JBG 2/24/84

WITH REPORT; USE REPORT;
PROCEDURE C45303A IS

     TYPE INT IS RANGE 1..10;

     X, Y : INT := INT(IDENT_INT(9));

BEGIN

     TEST ("C45303A", "CHECK SUBTYPE OF INTEGER ADDITION/SUBTRACTION");

     BEGIN

          IF X + Y - 10 /= INT(IDENT_INT(8)) THEN
               FAILED ("INCORRECT RESULT - ADDITION");
          END IF;

     EXCEPTION

          WHEN CONSTRAINT_ERROR =>
               IF INT'BASE'LAST >= INT'VAL(18) THEN
                    FAILED ("ADDITION DOES NOT YIELD RESULT " &
                            "BELONGING TO THE BASE TYPE");
               ELSE
                    COMMENT ("BASE TYPE HAS RANGE LESS THAN 18 - ADD");
               END IF;
          WHEN NUMERIC_ERROR =>
               IF INT'BASE'LAST >= INT'VAL(18) THEN
                    FAILED ("NUMERIC_ERROR RAISED FOR RESULT " &
                            "BELONGING TO THE BASE TYPE - ADD");
               ELSE
                    COMMENT ("BASE TYPE HAS RANGE LESS THAN 18 - " &
                             "NUMERIC_ERROR RAISED");
               END IF;
     END;

     BEGIN

          IF 2 - X - INT(IDENT_INT(1)) /= INT'VAL(IDENT_INT(-8)) THEN
               FAILED ("INCORRECT RESULT - SUBTRACTION");
          END IF;

     EXCEPTION

          WHEN CONSTRAINT_ERROR =>
               IF INT'BASE'LAST >= INT'VAL(18) THEN
                    FAILED ("SUBTRACTION DOES NOT YIELD RESULT " &
                            "BELONGING TO THE BASE TYPE");
               ELSE
                    COMMENT ("BASE TYPE HAS RANGE LESS THAN 18 - SUB");
               END IF;
          WHEN NUMERIC_ERROR =>
               IF INT'BASE'LAST >= INT'VAL(18) THEN
                    FAILED ("NUMERIC_ERROR RAISED FOR RESULT " &
                            "BELONGING TO THE BASE TYPE - SUB");
               ELSE
                    COMMENT ("BASE TYPE HAS RANGE LESS THAN 18 - " &
                             "NUMERIC_ERROR RAISED - SUB");
               END IF;
     END;

     RESULT;

END C45303A;
