-- C34018A.ADA

-- CHECK THAT CALLS OF DERIVED SUBPROGRAMS CHECK CONSTRAINTS OF THE
-- PARENT SUBPROGRAM, NOT THE CONSTRAINTS OF THE DERIVED SUBTYPE.

-- JBG 11/15/85
-- JRK 2/12/86   CORRECTED ERROR: RESOLVED AMBIGUOUS CALL G(41) TO
--               TYPE NEW_INT.

WITH REPORT; USE REPORT;
PROCEDURE C34018A IS

     PACKAGE P IS
          TYPE INT IS RANGE 1..100;
          SUBTYPE INT_50 IS INT RANGE 1..50;
          SUBTYPE INT_51 IS INT RANGE 51..100;

          FUNCTION "+" (L, R : INT) RETURN INT;
          FUNCTION G (X : INT_50) RETURN INT_51;

          TYPE STR IS ARRAY (1..10) OF CHARACTER;
          FUNCTION F (X : STR) RETURN STR;
     END P;

     USE P;

     TYPE NEW_STR IS NEW P.STR;
     TYPE NEW_INT IS NEW P.INT RANGE 51..90;

     PACKAGE BODY P IS

          FUNCTION "+" (L, R : INT) RETURN INT IS
          BEGIN
               RETURN INT(INTEGER(L) + INTEGER(R));
          END "+";

          FUNCTION G (X : INT_50) RETURN INT_51 IS
          BEGIN
               RETURN X + 10;
          END G;

          FUNCTION F (X : STR) RETURN STR IS
          BEGIN
               RETURN X;
          END F;

     END P;

BEGIN

     TEST ("C34018A", "CHECK CONSTRAINTS PROCESSED CORRECTLY FOR " &
                      "CALLS OF DERIVED SUBPROGRAMS");

     DECLARE

          Y : NEW_STR := F("1234567890");    -- UNAMBIGUOUS.

     BEGIN
          IF Y /= "1234567890" THEN
               FAILED ("DERIVED F");
          END IF;
     END;

     DECLARE

          A : INT := 51;
          B : NEW_INT := NEW_INT(IDENT_INT(90));

     BEGIN

          BEGIN
               A := A + 0;
               FAILED ("NO EXCEPTION - A + 0");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION - 1");
          END;

          BEGIN
               IF B + 2 /= 92 THEN      -- 92 IN INT.
                    FAILED ("WRONG RESULT - B + 2");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED ("WRONG CONSTRAINT FOR DERIVED ""+""");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION - 2");
          END;

          BEGIN
               IF B + 14 > 90 THEN      -- 104 NOT IN INT.
                    FAILED ("NO EXCEPTION RAISED FOR DERIVED ""+""");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION - 3");
          END;


          BEGIN
               IF G(B) > 90 THEN        -- 90 NOT IN INT_50.
                    FAILED ("NO EXCEPTION RAISED FOR DERIVED G");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION - 4");
          END;

          BEGIN
               IF C34018A.G(41) /= 51 THEN  -- 41 CONVERTED TO
                                            --    NEW_INT'BASE.
                                            -- 41 IN INT_50.
                                            -- 51 IN INT_51.
                    FAILED ("WRONG RESULT - G(41)");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED ("C_E RAISED FOR LITERAL ARGUMENT");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION - 5");
          END;
     END;

     RESULT;
END C34018A;
