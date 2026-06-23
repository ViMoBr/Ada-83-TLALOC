-- C96005E.ADA

-- CHECK THE CORRECTNESS OF THE ADDITION AND SUBTRACTION FUNCTIONS IN
-- THE PREDEFINED PACKAGE CALENDAR, AND APPROPRIATE EXCEPTION HANDLING.
-- SPECIFICALLY,
--   (E) THE EXCEPTION TIME_ERROR IS RAISED WHEN THE FUNCTIONS "+" OR
--       "-" ATTEMPT TO PRODUCE A VALUE WHOSE YEAR NUMBER IS NOT IN THE
--       SUBTYPE RANGE YEAR_NUMBER.

-- CPP 8/16/84

WITH CALENDAR;  USE CALENDAR;
WITH REPORT;  USE REPORT;
PROCEDURE C96005E IS

BEGIN
     TEST ("C96005E", "CHECK THAT THE ADDITION AND SUBTRACTION " &
            "FUNCTIONS RAISE TIME_ERROR APPROPRIATELY");

     --------------------------------------------

     BEGIN     -- (E)

          DECLARE
               NOW, LATER : TIME;
          BEGIN
               NOW := TIME_OF (2099, 12, 31, 86_399.0);
               LATER := NOW + 10.9;
               FAILED ("TIME_ERROR NOT RAISED - (E)1");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - (E)1");
          END;


          DECLARE
               NOW, LATER : TIME;
          BEGIN
               NOW := TIME_OF (2099, 12, 31, 86_399.0);
               LATER := 10.9 + NOW;
               FAILED ("TIME_ERROR NOT RAISED - (E)2");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - (E)2");
          END;


          DECLARE
               NOW, LATER : TIME;
          BEGIN
               NOW := TIME_OF (1901, 1, 1, 1.0);
               LATER := NOW - 10.9;
               FAILED ("TIME_ERROR NOT RAISED - (E)3");
          EXCEPTION
               WHEN TIME_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - (E)3");
          END;

     END; -- (E)

     -----------------------------------------------

     RESULT;
END C96005E;
