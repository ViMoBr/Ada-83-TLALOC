-- C45534A.ADA

-- OBJECTIVE:
--     CHECK THAT NUMERIC_ERROR (OR CONSTRAINT_ERROR) IS RAISED FOR
--     MULTIPLICATION OF A FIXED POINT VALUE BY AN INTEGER, OR FOR
--     DIVISION OF A FIXED POINT VALUE BY AN INTEGER, IF THE RESULT
--     LIES OUTSIDE THE RANGE OF THE FIXED POINT BASE TYPE.

-- HISTORY:
--     BCB 02/02/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH SYSTEM;

PROCEDURE C45534A IS

     DEL : CONSTANT := SYSTEM.FINE_DELTA;

     TYPE FIX IS DELTA DEL RANGE -1.0 .. 1.0;

     A, C : FIX := 0.5;

     F : FIX;

     B : INTEGER := 75;

     FN, FP, FAILED_ALREADY : BOOLEAN := FALSE;

     FUNCTION EQUAL_FIX(ONE, TWO : FIX) RETURN BOOLEAN IS
     BEGIN
          IF EQUAL(3,3) THEN
               RETURN ONE = TWO;
          ELSE
               RETURN ONE /= TWO;
          END IF;
     END EQUAL_FIX;

BEGIN
     TEST ("C45534A", "CHECK THAT NUMERIC_ERROR (OR CONSTRAINT_ERROR)" &
                      " IS RAISED FOR MULTIPLICATION OF A FIXED POINT" &
                      " VALUE BY AN INTEGER, OR FOR DIVISION OF A " &
                      "FIXED POINT VALUE BY AN INTEGER, IF THE " &
                      "RESULT LIES OUTSIDE THE RANGE OF THE FIXED " &
                      "POINT BASE TYPE");

     BEGIN
          C := A * B;
          FAILED ("NEITHER CONSTRAINT_ERROR OR NUMERIC_ERROR WAS " &
                  "RAISED FOR MULTIPLICATION");
          IF EQUAL_FIX(C,C*IDENT_INT(1)) THEN
               COMMENT ("DON'T OPTIMIZE C");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR WAS RAISED FOR " &
                        "MULTIPLICATION");
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR WAS RAISED FOR MULTIPLICATION");
          WHEN OTHERS =>
               FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_ERROR OR " &
                       "NUMERIC_ERROR WAS RAISED FOR MULTIPLICATION");
     END;

     BEGIN
          F := 1.0;
          IF EQUAL_FIX(F,F*IDENT_INT(1)) THEN
               COMMENT ("DON'T OPTIMIZE F");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               COMMENT ("NUMERIC_ERROR/CONSTRAINT_ERROR RAISED - 1.0 " &
                        "NOT IN RANGE");
               FP := TRUE;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - 1.0 NOT IN RANGE");
               FAILED_ALREADY := TRUE;
     END;

     BEGIN
          F := -1.0;
          IF EQUAL_FIX(F,F*IDENT_INT(1)) THEN
               COMMENT ("DON'T OPTIMIZE F");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               COMMENT ("NUMERIC_ERROR/CONSTRAINT_EROR RAISED - " &
                        "-1.0 NOT IN RANGE");
               FN := TRUE;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - -1.0 NOT IN RANGE");
               FAILED_ALREADY := TRUE;
     END;

     IF FAILED_ALREADY THEN
          COMMENT ("OTHER EXCEPTIONS WERE RAISED WHICH MAKES IT " &
                   "IMPOSSIBLE TO CHECK DIVISION");
     ELSE
          IF (FP AND NOT FN) THEN
               BEGIN
                    F := -1.0/(-1);
                    FAILED ("NEITHER CONSTRAINT_ERROR OR NUMERIC_" &
                            "ERROR WAS RAISED FOR DIVISION");
                    IF EQUAL_FIX(F,F*IDENT_INT(1)) THEN
                         COMMENT ("DON'T OPTIMIZE F");
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         COMMENT ("CONSTRAINT_ERROR WAS RAISED FOR " &
                                  "DIVISION");
                    WHEN NUMERIC_ERROR =>
                         COMMENT ("NUMERIC_ERROR WAS RAISED FOR " &
                                  "DIVISION");
                    WHEN OTHERS =>
                         FAILED ("AN EXCEPTION OTHER THAN NUMERIC_" &
                                 "ERROR OR CONSTRAINT_ERROR WAS " &
                                 "RAISED FOR DIVISION");
               END;
          ELSIF NOT FP AND FN THEN
               BEGIN
                    F := 1.0/(-1);
                    FAILED ("NEITHER CONSTRAINT_ERROR OR NUMERIC_" &
                            "ERROR WAS RAISED FOR DIVISION");
                    IF EQUAL_FIX(F,F*IDENT_INT(1)) THEN
                         COMMENT ("DON'T OPTIMIZE F");
                    END IF;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         COMMENT ("CONSTRAINT_ERROR WAS RAISED FOR " &
                                  "DIVISION");
                    WHEN NUMERIC_ERROR =>
                         COMMENT ("NUMERIC_ERROR WAS RAISED FOR " &
                                  "DIVISION");
                    WHEN OTHERS =>
                         FAILED ("AN EXCEPTION OTHER THAN CONSTRAINT_" &
                                 "ERROR OR NUMERIC_ERROR WAS RAISED " &
                                 "FOR DIVISION");
               END;
          ELSE COMMENT ("DIVISION CANNOT BE CHECKED DUE TO THE" &
                               " RANGE OF THE FIXED POINT TYPE");
          END IF;
     END IF;

     RESULT;
END C45534A;
