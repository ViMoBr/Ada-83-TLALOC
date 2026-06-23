-- C97201C.ADA

-- CHECK THAT A CONDITIONAL ENTRY CALL IS NOT ACCEPTED IF AN ACCEPT
-- STATEMENT FOR THE CALLED ENTRY HAS NOT YET BEEN REACHED.

-- WRG 7/11/86

WITH REPORT; USE REPORT;
PROCEDURE C97201C IS

BEGIN

     TEST ("C97201C", "CHECK THAT A CONDITIONAL ENTRY CALL IS NOT " &
                      "ACCEPTED IF AN ACCEPT STATEMENT FOR THE " &
                      "CALLED ENTRY HAS NOT YET BEEN REACHED");

     DECLARE

          TASK T IS
               ENTRY E;
               ENTRY BARRIER;
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT BARRIER;
               IF E'COUNT > 0 THEN
                    FAILED ("ENTRY CALL WAS QUEUED");
                    ACCEPT E;
               END IF;
          END T;

     BEGIN

          SELECT
               T.E;
               FAILED ("CONDITIONAL ENTRY CALL ACCEPTED");
          ELSE
               COMMENT ("ELSE PART EXECUTED");
          END SELECT;

          T.BARRIER;

     END;

     RESULT;

END C97201C;
