-- C45523A.ADA

-- OBJECTIVE:
--     FOR FLOATING POINT TYPES, IF MACHINE_OVERFLOWS IS TRUE AND
--     EITHER THE RESULT OF MULTIPLICATION LIES OUTSIDE THE RANGE OF THE
--     BASE TYPE, OR AN ATTEMPT IS MADE TO DIVIDE BY ZERO, THEN
--     NUMERIC_ERROR OR CONSTRAINT_ERROR IS RAISED.  THIS TESTS
--     DIGITS 5.

-- HISTORY:
--     BCB 02/09/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C45523A IS

     TYPE FLT IS DIGITS 5;

     F : FLT;

     FUNCTION IDENT_FLT(X : FLT) RETURN FLT IS
     BEGIN
          IF EQUAL(3,3) THEN
               RETURN X;
          ELSE
               RETURN 0.0;
          END IF;
     END IDENT_FLT;

     FUNCTION EQUAL_FLT(ONE, TWO : FLT) RETURN BOOLEAN IS
     BEGIN
          RETURN ONE = TWO * FLT (IDENT_INT(1));
     END EQUAL_FLT;

BEGIN
     TEST ("C45523A", "FOR FLOATING POINT TYPES, IF MACHINE_" &
                      "OVERFLOWS IS TRUE AND EITHER THE RESULT OF " &
                      "MULTIPLICATION LIES OUTSIDE THE RANGE OF THE " &
                      "BASE TYPE, OR AN ATTEMPT IS MADE TO DIVIDE BY " &
                      "ZERO, THEN NUMERIC_ERROR OR CONSTRAINT_ERROR " &
                      "IS RAISED.  THIS TESTS DIGITS 5");

     IF FLT'MACHINE_OVERFLOWS THEN
          BEGIN
               F := (FLT'BASE'LAST) * IDENT_FLT (2.0);
               FAILED ("NEITHER NUMERIC_ERROR OR CONSTRAINT_ERROR " &
                       "WAS RAISED FOR MULTIPLICATION");
               IF EQUAL_FLT(F,F**IDENT_INT(1)) THEN
                    COMMENT ("DON'T OPTIMIZE F");
               END IF;
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    COMMENT ("NUMERIC_ERROR WAS RAISED FOR " &
                             "MULTIPLICATION");
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("CONSTRAINT_ERROR WAS RAISED FOR " &
                             "MULTIPLICATION");
               WHEN OTHERS =>
                    FAILED ("AN EXCEPTION OTHER THAN NUMERIC_ERROR " &
                            "OR CONSTRAINT_ERROR WAS RAISED FOR " &
                            "MULTIPLICATION");
          END;
          BEGIN
               F := (FLT'SAFE_LARGE) / IDENT_FLT (0.0);
               FAILED ("NEITHER NUMERIC_ERROR OR CONSTRAINT_ERROR " &
                       "WAS RAISED FOR DIVISION BY ZERO");
               IF EQUAL_FLT(F,F**IDENT_INT(1)) THEN
                    COMMENT ("DON'T OPTIMIZE F");
               END IF;
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    COMMENT ("NUMERIC_ERROR WAS RAISED FOR DIVISION " &
                             "BY ZERO");
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("CONSTRAINT_ERROR WAS RAISED FOR " &
                             "DIVISION BY ZERO");
               WHEN OTHERS =>
                    FAILED ("AN EXCEPTION OTHER THAN NUMERIC_ERROR " &
                            "OR CONSTRAINT_ERROR WAS RAISED FOR " &
                            "DIVISION BY ZERO");
          END;
     ELSE
          NOT_APPLICABLE ("THIS TEST IS NOT APPLICABLE DUE TO " &
                          "MACHINE_OVERFLOWS BEING FALSE");
     END IF;

     RESULT;
END C45523A;
