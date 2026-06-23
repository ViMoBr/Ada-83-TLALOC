-- C93004B.ADA

-- CHECK THAT WHEN AN EXCEPTION IS RAISED DURING THE ACTIVATION OF A
-- TASK, OTHER TASKS ARE UNAFFECTED.

-- THE ENCLOSING BLOCK RECEIVES TASKING_ERROR.

-- CHECK THAT TASKS WAITING ON ENTRIES OF SUCH TASKS RECEIVE
-- TASKING_ERROR

-- JEAN-PIERRE ROSEN 09-MAR-1984
-- JBG 06/01/84
-- JBG 05/23/85
-- EG  10/29/85 ELIMINATE THE USE OF NUMERIC_ERROR IN TEST.

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C93004B IS
     PRAGMA PRIORITY (PRIORITY'FIRST);

BEGIN
     TEST("C93004B", "EXCEPTIONS DURING ACTIVATION");

     DECLARE

          TASK TYPE T1 IS
               PRAGMA PRIORITY(PRIORITY'LAST);
          END T1;

          TASK TYPE T2 IS
               ENTRY E;
               PRAGMA PRIORITY(PRIORITY'FIRST);
          END T2;

          ARR_T2: ARRAY(INTEGER RANGE 1..1) OF T2;

          TYPE AT1 IS ACCESS T1;

          PACKAGE START_T1 IS  -- THIS PACKAGE TO AVOID ACCESS BEFORE
          END START_T1;        -- ELABORATION ON T1.

          TASK BODY T1 IS
          BEGIN
               DECLARE    -- THIS BLOCK TO CHECK THAT T1BIS TERMINATES.
                    TASK T1BIS IS
                         PRAGMA PRIORITY(PRIORITY'LAST);
                    END T1BIS;

                    TASK BODY T1BIS IS
                    BEGIN
                         ARR_T2(IDENT_INT(1)).E;
                         FAILED ("RENDEZVOUS COMPLETED - T1BIS");
                    EXCEPTION
                         WHEN TASKING_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED("ABNORMAL EXCEPTION - T1BIS");
                    END T1BIS;
               BEGIN
                    NULL;
               END;

               ARR_T2(IDENT_INT(1)).E;  -- ARR_T2(1) IS NOW TERMINATED.

               FAILED ("RENDEZVOUS COMPLETED WITHOUT ERROR - T1");

          EXCEPTION
               WHEN TASKING_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("ABNORMAL EXCEPTION - T1");
          END;

          PACKAGE BODY START_T1 IS
               V_AT1 : AT1 := NEW T1;
          END START_T1;

          TASK BODY T2 IS
               I : POSITIVE := IDENT_INT(0); -- RAISE CONSTRAINT_ERROR.
          BEGIN
               IF I /= IDENT_INT(2) OR I = IDENT_INT(1) + 1 THEN
                    FAILED("T2 ACTIVATED OK");
               END IF;
          END T2;

          TASK T3 IS
               ENTRY E;
          END T3;

          TASK BODY T3 IS
          BEGIN     -- T3 MUST BE ACTIVATED OK.
               ACCEPT E;
          END T3;

     BEGIN
          FAILED ("TASKING_ERROR NOT RAISED IN MAIN");
          T3.E;          -- CLEAN UP.
     EXCEPTION
          WHEN TASKING_ERROR =>
               BEGIN
                    T3.E;
               EXCEPTION
                    WHEN TASKING_ERROR =>
                         FAILED ("T3 NOT ACTIVATED");
               END;
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED IN MAIN");
          WHEN OTHERS =>
               FAILED ("ABNORMAL EXCEPTION IN MAIN-2");
     END;

     RESULT;
END C93004B;
