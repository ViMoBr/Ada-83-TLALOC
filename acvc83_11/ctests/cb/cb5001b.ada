-- CB5001B.ADA

-- CHECK THAT AN EXCEPTION RAISED IN A RENDEVOUS IS PROPAGATED BOTH TO
-- THE CALLER AND TO THE CALLED TASK.

-- THIS VERSION CHECKS THAT THE EXCEPTION IS PROPAGATED THROUGH TWO
-- LEVELS OF RENDEVOUS.

-- JEAN-PIERRE ROSEN 09 MARCH 1984
-- JBG 6/1/84

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE CB5001B IS

BEGIN

     TEST("CB5001B", "CHECK THAT AN EXCEPTION IN A RENDEVOUS IS " &
                     "PROPAGATED TO CALLER AND CALLED TASKS -- TWO " &
                     "LEVELS");

     DECLARE
          TASK T1 IS
               ENTRY E1;
          END T1;
     
          TASK T2 IS
               ENTRY E2;
          END T2;
     
          TASK BODY T1 IS
          BEGIN
               ACCEPT E1 DO 
                    T2.E2; 
               END E1;
               FAILED ("T1: EXCEPTION NOT RAISED");
          EXCEPTION
               WHEN CONSTRAINT_ERROR | NUMERIC_ERROR | PROGRAM_ERROR =>
                    FAILED ("PREDEFINED EXCEPTION RAISED IN T1");
               WHEN TASKING_ERROR =>
                    FAILED ("TASKING_ERROR RAISED IN T1");
               WHEN OTHERS => 
                    NULL;
          END T1;
     
          TASK BODY T2 IS
               MY_EXCEPTION: EXCEPTION;
          BEGIN
               ACCEPT E2 DO 
                    IF EQUAL (1,1) THEN
                         RAISE MY_EXCEPTION; 
                    END IF;
               END E2;
               FAILED ("T2: EXCEPTION NOT RAISED");
          EXCEPTION
               WHEN MY_EXCEPTION => 
                    NULL;
               WHEN TASKING_ERROR =>
                    FAILED ("TASKING_ERROR RAISED IN T2");
               WHEN OTHERS =>
                    FAILED ("T2 RECEIVED ABNORMAL EXCEPTION");
          END T2;
     
     BEGIN 
          T1.E1;
          FAILED ("MAIN: EXCEPTION NOT RAISED");
     EXCEPTION
          WHEN CONSTRAINT_ERROR | NUMERIC_ERROR | PROGRAM_ERROR =>
               FAILED ("PREDEFINED ERROR RAISED IN MAIN");
          WHEN TASKING_ERROR =>
               FAILED ("TASKING_ERROR RAISED IN MAIN");
          WHEN OTHERS => 
               NULL;
     END;

     RESULT;

END CB5001B;
