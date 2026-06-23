-- C95040C.ADA

-- CHECKS THAT A TASK COMPLETED, BUT NOT TERMINATED (I.E. WAITING
-- FOR TERMINATION OF A DEPENDENT TASK) IS NEITHER 'TERMINATED NOR
-- 'CALLABLE.  CALLS TO ENTRIES BELONGING TO SUCH A TASK RAISE
-- TASKING_ERROR.

-- J.P. ROSEN, ADA PROJECT, NYU
-- JBG 6/1/84
-- JWC 6/28/85   RENAMED FROM C9A009A-B.ADA

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C95040C IS
BEGIN

     TEST ("C95040C", "TASKING_ERROR RAISED WHEN CALLING COMPLETED " &
                      "BUT UNTERMINATED TASK");

     DECLARE

          TASK T1 IS
               ENTRY E;
               PRAGMA PRIORITY(PRIORITY'LAST);
          END T1;

          TASK BODY T1 IS

               TASK T2 IS
                    PRAGMA PRIORITY(PRIORITY'FIRST);
               END T2;

               TASK BODY T2 IS
               BEGIN
                    COMMENT ("BEGIN T2");
                    T1.E;          -- T1 WILL COMPLETE BEFORE THIS CALL
                                   -- OR WHILE WAITING FOR THIS CALL TO
                                   -- BE ACCEPTED.  WILL DEADLOCK IF
                                   -- TASKING_ERROR IS NOT RAISED.
                    FAILED ("NO TASKING_ERROR RAISED");
               EXCEPTION
                    WHEN TASKING_ERROR =>
                         IF T1'CALLABLE THEN
                              FAILED ("T1 STILL CALLABLE");
                         END IF;

                         IF T1'TERMINATED THEN    -- T1 CAN'T TERMINATE
                                                  -- UNTIL T2 HAS
                                                  -- TERMINATED.
                              FAILED ("T1 TERMINATED");
                         END IF;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION");
               END T2;
          BEGIN
               NULL;
          END;

     BEGIN
          NULL;
     END;

     RESULT;

END C95040C;
