-- C45252B.ADA

-- OBJECTIVE:
--     CHECK THAT NO EXCEPTION IS RAISED WHEN A FIXED POINT LITERAL
--     OPERAND IN A COMPARISON OR A FIXED POINT LITERAL LEFT OPERAND
--     IN A MEMBERSHIP TEST BELONGS TO THE BASE TYPE BUT IS OUTSIDE
--     THE RANGE OF THE SUBTYPE.

-- HISTORY:
--     PWB 09/04/86 CREATED ORIGINAL TEST.
--     DHH 10/19/87 SHORTENED LINES CONTAINING MORE THAN 72 CHARACTERS.

WITH REPORT, SYSTEM; USE REPORT;
PROCEDURE C45252B IS

BEGIN

     TEST ("C45252B", "NO EXCEPTION IS RAISED WHEN A FIXED " &
                      "LITERAL USED IN A COMPARISON OR AS THE " &
                      "LEFT OPERAND IN A MEMBERSHIP TEST " &
                      "BELONGS TO THE BASE TYPE BUT IS OUTSIDE " &
                      "THE RANGE OF THE SUBTYPE");

     DECLARE
          TYPE FIXED IS DELTA 0.25 RANGE -10.0 .. 10.0;
          SUBTYPE FIXED_1 IS FIXED RANGE -1.0 .. 1.0;
          NUM : FIXED_1 := 0.0;
     BEGIN    -- FIXED COMPARISON

          IF EQUAL(3,3) THEN
               NUM := FIXED_1'(0.5);
          END IF;

          IF 2.0 > NUM THEN
               COMMENT ("NO EXCEPTION RAISED FOR FIXED " &
                        "COMPARISON");
          ELSE
               FAILED ("WRONG RESULT FROM FIXED " &
                       "COMPARISON");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               FAILED ("NUMERIC_ERROR RAISED FOR " &
                       "FIXED COMPARISON");
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED FOR " &
                       "FIXED COMPARISON");
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED FOR " &
                       "FIXED COMPARISON");
     END;  -- FIXED COMPARISON

     DECLARE
          TYPE FIXED IS DELTA 0.25 RANGE -10.0 .. 10.0;
          SUBTYPE FIXED_1 IS FIXED RANGE -1.0 .. 1.0;
     BEGIN    -- FIXED MEMBERSHIP

          IF 2.0 IN FIXED_1 THEN
               FAILED ("WRONG RESULT FROM FIXED " &
                       "MEMBERSHIP");
          ELSE
               COMMENT ("NO EXCEPTION RAISED FOR FIXED " &
                        "MEMBERSHIP");
          END IF;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               FAILED ("NUMERIC_ERROR RAISED FOR  " &
                       "FIXED MEMBERSHIP");
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED FOR  " &
                       "FIXED MEMBERSHIP");
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED FOR  " &
                       "FIXED MEMBERSHIP");
     END;  -- FIXED MEMBERSHIP

     DECLARE -- PRECISE FIXED COMPARISON
          TYPE FINE_FIXED IS DELTA SYSTEM.FINE_DELTA RANGE -1.0 .. 1.0;
          SUBTYPE SUB_FINE IS FINE_FIXED RANGE -0.5 .. 0.5;
          NUM : SUB_FINE := 0.0;
     BEGIN
          IF EQUAL(3,3) THEN
               NUM := 0.25;
          END IF;

          IF 0.75 > NUM THEN
               COMMENT ("NO EXCEPTION RAISED FOR FINE_FIXED " &
                        "COMPARISON");
          ELSE
               FAILED ("WRONG RESULT FROM FINE_FIXED COMPARISON");
          END IF;

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               FAILED ("NUMERIC_ERROR RAISED FOR " &
                       "FINE_FIXED COMPARISON");
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED FOR " &
                       "FINE_FIXED COMPARISON");
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED FOR  " &
                       "FINE_FIXED COMPARISON");
     END;  --  FINE_FIXED COMPARISON

     DECLARE -- PRECISE FIXED MEMBERSHIP
          TYPE FINE_FIXED IS DIGITS SYSTEM.MAX_DIGITS;
          SUBTYPE SUB_FINE IS FINE_FIXED RANGE -0.5 .. 0.5;
     BEGIN

          IF 0.75 IN SUB_FINE THEN
               FAILED ("WRONG RESULT FROM FINE_FIXED MEMBERSHIP");
          ELSE
               COMMENT ("NO EXCEPTION RAISED FOR FINE_FIXED " &
                        "MEMBERSHIP");
          END IF;

     EXCEPTION
          WHEN NUMERIC_ERROR =>
               FAILED ("NUMERIC_ERROR RAISED FOR " &
                       "FINE_FIXED MEMBERSHIP");
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED FOR " &
                       "FINE_FIXED MEMBERSHIP");
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED FOR  " &
                       "FINE_FIXED MEMBERSHIP");
     END;  --  FINE_FIXED MEMBERSHIP

     RESULT;

END C45252B;
