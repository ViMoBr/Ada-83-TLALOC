-- C95080B.ADA

-- CHECK THAT PARAMETERLESS ENTRIES CAN BE CALLED WITH THE APPROPRIATE
-- NOTATION.

-- JWC 7/15/85
-- JRK 8/21/85

WITH REPORT; USE REPORT;
PROCEDURE C95080B IS

     I : INTEGER := 1;

     TASK T IS
          ENTRY E;
          ENTRY EF (1..3);
     END T;

     TASK BODY T IS
     BEGIN
          ACCEPT E DO
               I := 15;
          END E;
          ACCEPT EF (2) DO
               I := 20;
          END EF;
     END T;

BEGIN

     TEST ("C95080B", "CHECK THAT PARAMETERLESS ENTRIES CAN BE " &
                      "CALLED");

     T.E;
     IF I /= 15 THEN
          FAILED ("PARAMETERLESS ENTRY CALL YIELDS INCORRECT " &
                  "RESULT");
     END IF;

     I := 0;
     T.EF (2);
     IF I /= 20 THEN
          FAILED ("PARAMETERLESS ENTRY FAMILY CALL YIELDS " &
                  "INCORRECT RESULT");
     END IF;

     RESULT;

END C95080B;
