-- C35003D.ADA

-- OBJECTIVE:
--     CHECK THAT CONSTRAINT_ERROR IS RAISED FOR A FLOATING-POINT
--     SUBTYPE INDICATION WHEN THE LOWER OR UPPER BOUND OF A NON-NULL
--     RANGE LIES OUTSIDE THE RANGE OF THE TYPE MARK.

-- HISTORY:
--     JET 07/11/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C35003D IS

     SUBTYPE FLT1 IS FLOAT RANGE -100.0 .. 100.0;

BEGIN
     TEST ("C35003D", "CHECK THAT CONSTRAINT_ERROR IS RAISED FOR A " &
                      "FLOATING-POINT SUBTYPE INDICATION WHEN THE " &
                      "LOWER OR UPPER BOUND OF A NON-NULL RANGE LIES " &
                      "OUTSIDE THE RANGE OF THE TYPE MARK");
     BEGIN
          DECLARE
               SUBTYPE F IS FLT1 RANGE 0.0..101.0+FLT1(IDENT_INT(0));
          BEGIN
               FAILED ("NO EXCEPTION RAISED (F1)");
               DECLARE
                    Z : F := 1.0;
               BEGIN
                    IF NOT EQUAL(INTEGER(Z),INTEGER(Z)) THEN
                         COMMENT ("DON'T OPTIMIZE Z");
                    END IF;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN WRONG PLACE (F1)");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED (F1)");
     END;

     BEGIN
          DECLARE
               SUBTYPE F IS FLT1 RANGE -101.0..0.0;
          BEGIN
               FAILED ("NO EXCEPTION RAISED (F2)");
               DECLARE
                    Z : F := -1.0;
               BEGIN
                    IF NOT EQUAL(INTEGER(Z),INTEGER(Z)) THEN
                         COMMENT ("DON'T OPTIMIZE Z");
                    END IF;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN WRONG PLACE (F2)");
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED (F2)");
     END;

     RESULT;

END C35003D;
