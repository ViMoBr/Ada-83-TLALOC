-- C35003F.ADA

-- OBJECTIVE:
--     CHECK THAT CONSTRAINT_ERROR IS RAISED FOR A FIXED-POINT SUBTYPE
--     INDICATION WHEN THE LOWER OR UPPER BOUND OF A NON-NULL RANGE
--     LIES OUTSIDE THE RANGE OF THE TYPE MARK.

-- HISTORY:
--     JET 07/11/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C35003F IS

     TYPE FIX1 IS DELTA 2#0.01# RANGE -100.0 .. 100.0;

BEGIN
     TEST ("C35003F", "CHECK THAT CONSTRAINT_ERROR IS RAISED FOR A " &
                      "FIXED-POINT SUBTYPE INDICATION WHEN THE LOWER " &
                      "OR UPPER BOUND OF A NON-NULL RANGE LIES " &
                      "OUTSIDE THE RANGE OF THE TYPE MARK");
     BEGIN
          DECLARE
               SUBTYPE F IS FIX1 RANGE -101.0..0.0;
          BEGIN
               FAILED ("NO EXCEPTION RAISED (X1)");
               DECLARE
                    Z : F := -1.0;
               BEGIN
                    IF NOT EQUAL(INTEGER(Z),INTEGER(Z)) THEN
                         COMMENT ("DON'T OPTIMIZE Z");
                    END IF;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN WRONG PLACE (X1)");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED (X1)");
     END;

     BEGIN
          DECLARE
               SUBTYPE F IS FIX1 RANGE 0.0..101.0+FIX1(IDENT_INT(0));
          BEGIN
               FAILED ("NO EXCEPTION RAISED (X2)");
               DECLARE
                    Z : F := 1.0;
               BEGIN
                    IF NOT EQUAL(INTEGER(Z),INTEGER(Z)) THEN
                         COMMENT ("DON'T OPTIMIZE Z");
                    END IF;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN WRONG PLACE (X2)");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED (X2)");
     END;

     RESULT;

END C35003F;
