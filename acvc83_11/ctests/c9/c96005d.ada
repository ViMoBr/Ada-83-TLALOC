-- C96005D.ADA

-- CHECK THE CORRECTNESS OF THE ADDITION AND SUBTRACTION FUNCTIONS IN
-- THE PREDEFINED PACKAGE CALENDAR, AND APPROPRIATE EXCEPTION HANDLING.
-- SPECIFICALLY,
--   (D) THE EXCEPTION TIME_ERROR IS RAISED WHEN THE FUNCTION "-"
--       RETURNS A VALUE NOT IN THE SUBTYPE RANGE DURATION.

-- CPP 8/16/84

WITH CALENDAR;  USE CALENDAR;
WITH REPORT;  USE REPORT;
PROCEDURE C96005D IS

BEGIN
     TEST ("C96005D", "CHECK THAT THE SUBTRACTION OPERATOR RAISES " &
           "TIME_ERROR APPROPRIATELY");

     ---------------------------------------------

     BEGIN     -- (D)

          DECLARE
               NOW, LATER : TIME;
               WAIT : DURATION;
          BEGIN
               NOW := TIME_OF (1984, 8, 13, 0.0);
               LATER := (NOW + DURATION'LAST) + 1.0;
               WAIT := LATER - NOW;
               FAILED ("EXCEPTION NOT RAISED - (D)1");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - (D)1");
          END;


          DECLARE
               NOW, LATER : TIME;
               WAIT : DURATION;
          BEGIN
               NOW := TIME_OF (1984, 8, 13, 0.0);
               LATER := (NOW + DURATION'FIRST) - 1.0;
               WAIT := NOW - LATER;
               FAILED ("EXCEPTION NOT RAISED - (D)2");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - (D)2");
          END;

     END; -- (D)

     ---------------------------------------------

     RESULT;
END C96005D;
