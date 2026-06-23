-- C94020A.ADA

-- CHECK THAT THE CONDITIONS FOR TERMINATION ARE RECOGNIZED WHEN THE
-- LAST MISSING TASK TERMINATES DUE TO AN ABORT

-- JEAN-PIERRE ROSEN 08-MAR-1984
-- JBG 6/1/84

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE C94020A IS

     TASK TYPE T2 IS
          PRAGMA PRIORITY(PRIORITY'LAST);
     END T2;
     
     TASK TYPE T3 IS
          PRAGMA PRIORITY(PRIORITY'LAST);
          ENTRY E;
     END T3;
     
     TASK BODY T2 IS
     BEGIN
          COMMENT("T2");
     END;
     
     TASK BODY T3 IS
     BEGIN
          COMMENT("T3");
          SELECT
               ACCEPT E;
          OR TERMINATE;
          END SELECT;
          FAILED("T3 EXITED SELECT OR TERMINATE");
     END;

BEGIN

     TEST ("C94020A", "TEST OF TASK DEPENDENCES, TERMINATE, ABORT");

     DECLARE
          TASK TYPE T1 IS
               PRAGMA PRIORITY(PRIORITY'LAST);
          END T1;
          
          V1 : T1;
          TYPE A_T1 IS ACCESS T1;

          TASK BODY T1 IS
          BEGIN
               ABORT T1;
               DELAY 0.0;          --SYNCHRONIZATION POINT
               FAILED("T1 NOT ABORTED");
          END;
          
     BEGIN
          DECLARE
               V2 : T2;
               A1 : A_T1;
          BEGIN
               DECLARE
                    V3 : T3;
                    TASK T4 IS
                         PRAGMA PRIORITY(PRIORITY'LAST);
                    END T4;
                    TASK BODY T4 IS
                         TASK T41 IS
                              PRAGMA PRIORITY(PRIORITY'FIRST);
                         END T41;
                         TASK BODY T41 IS
                         BEGIN
                              COMMENT("T41");
                              ABORT T4;
                              DELAY 0.0;       --SYNCHRONIZATION POINT
                              FAILED("T41 NOT ABORTED");
                         END;
                    BEGIN  --T4
                         COMMENT("T4");
                    END;
               BEGIN
                    COMMENT("BLOC 3");
               END;
               COMMENT("BLOC 2");
               A1 := NEW T1;
          END;
          COMMENT("BLOC 1");
     EXCEPTION
          WHEN OTHERS => FAILED("SOME EXCEPTION RAISED");
     END;

     RESULT;

END C94020A;
