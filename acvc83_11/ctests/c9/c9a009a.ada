-- C9A009A.ADA

-- TEST ABORT DURING RENDEZVOUS

-- CALLING TASK IN RENDEVOUS IS NAMED IN ABORT STATEMENT.

-- JEAN-PIERRE ROSEN 09 MARCH 1984
-- JBG 6/1/84
-- JWC 6/28/85   RENAMED FROM C9A009D-B.ADA

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE C9A009A IS

BEGIN

     TEST("C9A009A", "CALLING TASK IS ABORTED DIRECTLY");

     DECLARE
     -- T1 CALLS T2, WHICH ABORTS T1 WHILE IN RENDEVOUS

          T2_CONTINUED : BOOLEAN := FALSE;

          TASK CONTINUED IS
               ENTRY GET (T2_CONTINUED : OUT BOOLEAN);
               ENTRY PUT (T2_CONTINUED : IN  BOOLEAN);
          END CONTINUED;

          TASK BODY CONTINUED IS
               CONTINUED : BOOLEAN := FALSE;
          BEGIN
               LOOP
                    SELECT
                         ACCEPT GET (T2_CONTINUED : OUT BOOLEAN) DO
                              T2_CONTINUED := CONTINUED;
                         END GET;
                    OR
                         ACCEPT PUT (T2_CONTINUED : IN BOOLEAN) DO
                              CONTINUED := T2_CONTINUED;
                         END PUT;
                    OR
                         TERMINATE;
                    END SELECT;
               END LOOP;
          END CONTINUED;

     BEGIN     -- THIS BLOCK WILL MAKE SURE T2 IS TERMINATED, AND SO,
               -- T2_CONTINUED IS ASSIGNED A VALUE IF T2 CONTINUES
               -- EXECUTION CORRECTLY.

          DECLARE

               TASK T1;

               TASK T2 IS
                    ENTRY E1;
               END T2;

               TASK BODY T1 IS
               BEGIN
                    T2.E1;
                    FAILED ("T1 NOT ABORTED");
               EXCEPTION
                    WHEN TASKING_ERROR =>
                         FAILED ("TASKING_ERROR RAISED IN T1");
                    WHEN OTHERS =>
                         FAILED ("OTHER EXCEPTION RAISED - T1");
               END T1;

               TASK BODY T2 IS
               BEGIN
                    ACCEPT E1 DO
                         ABORT T1;
                         ABORT T1;
                         ABORT T1; -- WHY NOT?
                         IF T1'TERMINATED THEN
                              FAILED ("T1 PREMATURELY TERMINATED");
                         END IF;
                    END E1;
                    CONTINUED.PUT (T2_CONTINUED => TRUE);
               END T2;
          BEGIN
               NULL;
          END;
     -- T2 NOW TERMINATED
          CONTINUED.GET (T2_CONTINUED);
          IF NOT T2_CONTINUED THEN
               FAILED ("WHEN CALLER WAS ABORTED IN RENDEVOUS, CALLED " &
                       "TASK DID NOT CONTINUE");
          END IF;
     END;

     RESULT;

END C9A009A;
