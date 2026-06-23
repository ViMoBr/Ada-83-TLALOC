-- C9A009B.ADA

-- TEST ABORT DURING RENDEZVOUS

-- ABORT CALLING AND CALLED TASK FROM WITHIN A DEPENDENT TASK.

-- JEAN-PIERRE ROSEN 09 MARCH 1984
-- JBG 6/1/84

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE C9A009B IS

BEGIN 

     TEST("C9A009B", "ABORT CALLING AND CALLED TASK SIMULTANEOUSLY");

     DECLARE
     -- T2 CALLS ITS OWN ENTRY
     -- T3 CALLS T1'S ENTRY
     -- T2 ABORTS T1, T2, AND T3 WHILE T2 AND T3 ARE AWAITING RENDEVOUS

          TASK T1 IS
               PRAGMA PRIORITY(PRIORITY'LAST);
               ENTRY E1;
          END T1;
 
          TASK BODY T1 IS
               TASK T2 IS
                    PRAGMA PRIORITY(PRIORITY'FIRST);
                    ENTRY E1;
               END T2;

               TASK BODY T2 IS
                    TASK T3 IS
                         PRAGMA PRIORITY(PRIORITY'LAST);
                    END T3;

                    TASK BODY T3 IS
                    BEGIN
                         T1.E1;
                    END;
               BEGIN -- T3 ACTIVATED NOW
                    ABORT T2,T3,T1;
               END T2;
          BEGIN      -- T2 ACTIVATED NOW
               T2.E1;
          END T1;
     BEGIN           -- T1 ACTIVATED NOW OR ABORTED
          NULL;
     END;

     RESULT;

END C9A009B;
