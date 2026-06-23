-- C95085O.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED AFTER AN ENTRY CALL FOR THE
-- CASE OF A PRIVATE TYPE IMPLEMENTED AS AN ACCESS TYPE WHERE THE VALUE
-- OF THE FORMAL PARAMETER DOES NOT BELONG TO THE SUBTYPE OF THE ACTUAL
-- PARAMETER.

-- JWC 10/30/85
-- JRK 1/15/86      ENSURE THAT EXCEPTION RAISED AFTER CALL, NOT BEFORE
--                  CALL.

WITH REPORT; USE REPORT;
PROCEDURE C95085O IS

BEGIN

     TEST ("C95085O", "CHECK THAT PRIVATE TYPE (ACCESS) RAISES " &
                      "CONSTRAINT_ERROR AFTER CALL WHEN FORMAL " &
                      "PARAMETER VALUE IS NOT IN ACTUAL'S SUBTYPE");

     DECLARE

          CALLED : BOOLEAN := FALSE;

          PACKAGE P IS
               TYPE T IS PRIVATE;
               DC : CONSTANT T;

               GENERIC PACKAGE PP IS
               END PP;
          PRIVATE
               TYPE T IS ACCESS STRING;
               DC : CONSTANT T := NEW STRING'("AAA");
          END P;

          TASK TSK IS
               ENTRY E (X : IN OUT P.T);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (X : IN OUT P.T) DO
                         CALLED := TRUE;
                         X := P.DC;
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK BODY");
          END TSK;

          GENERIC
               Y : IN OUT P.T;
          PACKAGE CALL IS
          END CALL;

          PACKAGE BODY CALL IS
          BEGIN
               TSK.E (Y);
               FAILED ("EXCEPTION NOT RAISED AFTER RETURN");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    IF NOT CALLED THEN
                         FAILED ("EXCEPTION RAISED BEFORE CALL");
                    END IF;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED");
          END CALL;

          PACKAGE BODY P IS
               Z : T (1..5) := NEW STRING'("CCCCC");
               PACKAGE BODY PP IS
                    PACKAGE CALL_Q IS NEW CALL (Z);
               END PP;
          END P;

     BEGIN

          BEGIN
               DECLARE
                    PACKAGE CALL_Q_NOW IS NEW P.PP;    -- START HERE.
               BEGIN
                    NULL;
               END;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("WRONG HANDLER INVOKED");
          END;

     END;

     RESULT;
END C95085O;
