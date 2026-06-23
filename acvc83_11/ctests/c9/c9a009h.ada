-- C9A009H.ADA

-- CHECK THAT A TASK ABORTED DURING A RENDEVOUS IS NEITHER CALLABLE NOR
-- TERMINATED BEFORE THE END OF THE RENDEVOUS.

-- J.P ROSEN, ADA PROJECT, NYU
-- JBG 6/1/84

WITH REPORT; USE REPORT;
PROCEDURE C9A009H IS
BEGIN
     TEST ("C9A009H", "TASK ABORTED IN RENDEVOUS IS NOT CALLABLE OR " &
                      "TERMINATED");

     DECLARE

          TASK T1 IS
               ENTRY E1;
          END T1;

          TASK T2 IS
          END T2;

          TASK BODY T2 IS
          BEGIN
               T1.E1;
               FAILED ("T2 NOT ABORTED");
          EXCEPTION
               WHEN TASKING_ERROR =>
                    FAILED ("TASKING_ERROR RAISED IN ABORTED TASK");
               WHEN OTHERS =>
                    FAILED ("OTHER EXCEPTION RAISED");
          END T2;

          TASK BODY T1 IS
          BEGIN
               ACCEPT E1 DO
                    ABORT T2;
                    IF T2'CALLABLE THEN
                         FAILED ("T2 STILL CALLABLE");
                    END IF;

                    IF T2'TERMINATED THEN
                         FAILED ("T2 TERMINATED");
                    END IF;
               END E1;
          END T1;

     BEGIN
          NULL;
     END;

     RESULT;

END C9A009H;
