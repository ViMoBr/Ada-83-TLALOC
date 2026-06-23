-- C9A009G.ADA

-- CHECK THAT A MASTER ABORTED WITH SUBTASKS IN AN ENTRY CALL BECOMES
-- COMPLETED, BUT NOT TERMINATED, BEFORE THE END OF THE RENDEZVOUS.

-- JEAN-PIERRE ROSEN 16-MAR-1984
-- JBG 6/1/84

WITH REPORT,SYSTEM; 
USE REPORT,SYSTEM;
PROCEDURE C9A009G IS

     PRAGMA PRIORITY(PRIORITY'FIRST);

     TASK BLOCKING IS
          ENTRY START;
          ENTRY STOP;
          ENTRY RESTART;
          ENTRY NO_CALL;
     END BLOCKING;

     TASK BODY BLOCKING IS
     BEGIN
          SELECT
               ACCEPT STOP DO
                    ACCEPT START;
                    ACCEPT RESTART;
               END;
          OR TERMINATE;
          END SELECT;
     END;

BEGIN

     TEST("C9A009G", "MASTER COMPLETED BUT NOT TERMINATED");

     DECLARE         -- T1 ABORTED WHILE DEPENDENT TASK IN RENDEVOUS 9C?

          TASK T1 IS
               ENTRY LOCK;
               PRAGMA PRIORITY(PRIORITY'LAST); -- THIS PRIORITY TO MAX
          END T1;                              -- THE CHANCE OF T1 BEING
                                               -- (WRONGLY) TERMINATED
     
          TASK BODY T1 IS
               TASK T2;
     
               TASK BODY T2 IS
               BEGIN
                    BLOCKING.STOP;
                    FAILED ("T2 NOT ABORTED");
               END;
          BEGIN
               BLOCKING.NO_CALL;          -- WILL DEADLOCK UNTIL ABORT
          END T1;
     
     BEGIN
          BLOCKING.START;
          ABORT T1;

          IF T1'CALLABLE THEN
               FAILED("T1 STILL CALLABLE - 2");
          END IF;

          IF T1'TERMINATED THEN    -- T1'S DEPENDENT TASK, T2, STILL IN
                                   -- RENDEVOUS 
               FAILED("T1 PREMATURELY TERMINATED - 2");
          END IF;

          BLOCKING.RESTART;
     END;

     RESULT;

END C9A009G;
