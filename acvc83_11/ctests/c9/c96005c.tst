-- C96005C.TST

-- CHECK THE CORRECTNESS OF THE ADDITION AND SUBTRACTION FUNCTIONS IN
-- THE PREDEFINED PACKAGE CALENDAR, AND APPROPRIATE EXCEPTION HANDLING.
-- SPECIFICALLY,
--   (C) A VALUE LESS THAN DURATION'BASE'FIRST OR GREATER THAN
--       DURATION'BASE'LAST WILL RAISE NUMERIC ERROR WHEN USED AS AN
--       ARGUMENT TO EITHER THE ADDITION OR THE SUBTRACTION FUNCTIONS.

-- CPP 08/16/84
-- EG  10/30/85  FIX NUMERIC_ERROR/CONSTRAINT_ERROR ACCORDING TO
--               AI-00387.

WITH CALENDAR;  USE CALENDAR;
WITH REPORT;  USE REPORT;
PROCEDURE C96005C IS

BEGIN
     TEST ("C96005C", "CHECK THAT THE ADDITION AND SUBTRACTION " &
                      "FUNCTIONS RAISE NUMERIC_ERROR/" &
                      "CONSTRAINT_ERROR APPROPRIATELY");

     --------------------------------------------

     BEGIN     -- (C)

          DECLARE
               BEFORE : TIME := CLOCK;
          BEGIN
               BEFORE := BEFORE + ($LESS_THAN_DURATION_BASE_FIRST);
               FAILED ("EXCEPTION NOT RAISED - (C)1");
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    COMMENT ("NUMERIC_ERROR RAISED FOR + OF < " &
                             "DURATION'BASE'FIRST");
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("CONSTRAINT_ERROR RAISED FOR + OF < " &
                             "DURATION'BASE'FIRST");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - (C)1");
          END;


          DECLARE
               BEFORE : TIME := CLOCK;
          BEGIN
               BEFORE := $GREATER_THAN_DURATION_BASE_LAST + BEFORE;
               FAILED ("EXCEPTION NOT RAISED - (C)2");
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    COMMENT ("NUMERIC_ERROR RAISED FOR + OF > " &
                             "DURATION'BASE'LAST");
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("CONSTRAINT_ERROR RAISED FOR + OF > " &
                             "DURATION'BASE'LAST");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - (C)2");
          END;

          DECLARE
               BEFORE : TIME := CLOCK;
          BEGIN
               BEFORE := BEFORE - ($LESS_THAN_DURATION_BASE_FIRST);
               FAILED ("EXCEPTION NOT RAISED - (C)3");
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    COMMENT ("NUMERIC_ERROR RAISED FOR - OF < " &
                             "DURATION'BASE'FIRST");
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("CONSTRAINT_ERROR RAISED FOR - OF < " &
                             "DURATION'BASE'FIRST");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - (C)3");
          END;


          DECLARE
               BEFORE : TIME := CLOCK;
          BEGIN
               BEFORE := BEFORE - $GREATER_THAN_DURATION_BASE_LAST;
               FAILED ("EXCEPTION NOT RAISED - (C)4");
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    COMMENT ("NUMERIC_ERROR RAISED FOR - OF > " &
                             "DURATION'BASE'LAST");
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("CONSTRAINT_ERROR RAISED FOR - OF > " &
                             "DURATION'BASE'LAST");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - (C)4");
          END;

     END; -- (C)

     --------------------------------------------

     RESULT;
END C96005C;
