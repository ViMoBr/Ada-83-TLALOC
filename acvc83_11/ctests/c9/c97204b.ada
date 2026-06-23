-- C97204B.ADA

-- CHECK THAT TASKING_ERROR IS RAISED IF THE CALLED TASK IS ABORTED
-- BEFORE THE CONDITIONAL ENTRY CALL IS EXECUTED.

-- WRG 7/13/86

WITH REPORT; USE REPORT;
PROCEDURE C97204B IS

BEGIN

     TEST ("C97204B", "CHECK THAT TASKING_ERROR IS RAISED IF THE " &
                      "CALLED TASK IS ABORTED BEFORE THE CONDITIONAL " &
                      "ENTRY CALL IS EXECUTED");

     DECLARE

          TASK T IS
               ENTRY E (I : INTEGER);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (I : INTEGER);
               FAILED ("ENTRY CALL ACCEPTED");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED");
          END T;

          FUNCTION F RETURN INTEGER IS
          BEGIN
               ABORT T;
               RETURN 1;
          END F;

     BEGIN

          SELECT
               T.E (F);
               FAILED ("CONDITIONAL ENTRY CALL MADE");
          ELSE
               FAILED ("ELSE PART EXECUTED");
          END SELECT;

          FAILED ("EXCEPTION NOT RAISED");

     EXCEPTION

          WHEN TASKING_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED");

     END;

     RESULT;

END C97204B;
