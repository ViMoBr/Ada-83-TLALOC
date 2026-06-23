-- C95085J.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE APPROPRIATE
-- CIRCUMSTANCES FOR ACCESS PARAMETERS IN ENTRY CALLS, NAMELY WHEN
-- THE ACTUAL INDEX BOUNDS OR DISCRIMINANTS ARE NOT EQUAL
-- TO THE FORMAL CONSTRAINTS BEFORE THE CALL (FOR IN AND IN OUT
-- MODES), AND WHEN THE FORMAL CONSTRAINTS ARE NOT EQUAL TO THE
-- ACTUAL CONSTRAINTS UPON RETURN (FOR IN OUT AND OUT MODES).

--       (G) AFTER RETURN, OUT MODE, UNCONSTRAINED FORMAL, STATIC ONE
--           DIMENSIONAL BOUNDS.

-- JWC 10/23/85

WITH REPORT; USE REPORT;
PROCEDURE C95085J IS

BEGIN
     TEST ("C95085J", "CHECK THAT CONSTRAINT_ERROR IS RAISED " &
                      "APPROPRIATELY FOR ACCESS PARAMETERS");

     --------------------------------------------------

     DECLARE

          CALLED : BOOLEAN := FALSE;

          TYPE A IS ACCESS STRING;

          V : A (1..3) := NEW STRING (1..3);

          TASK TSK IS
               ENTRY E (X : OUT A);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (X : OUT A) DO
                         CALLED := TRUE;
                         X := NEW STRING (2..3);
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
              WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK BODY");
          END TSK;

     BEGIN

          TSK.E (V);
          FAILED ("EXCEPTION NOT RAISED AFTER RETURN");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT CALLED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL");
               END IF;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED");
     END;

     --------------------------------------------------

     RESULT;
END C95085J;
