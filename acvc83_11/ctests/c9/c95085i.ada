-- C95085I.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE APPROPRIATE
-- CIRCUMSTANCES FOR ACCESS PARAMETERS IN ENTRY CALLS, NAMELY WHEN
-- THE ACTUAL INDEX BOUNDS OR DISCRIMINANTS ARE NOT EQUAL
-- TO THE FORMAL CONSTRAINTS BEFORE THE CALL (FOR IN AND IN OUT
-- MODES), AND WHEN THE FORMAL CONSTRAINTS ARE NOT EQUAL TO THE
-- ACTUAL CONSTRAINTS UPON RETURN (FOR IN OUT AND OUT MODES).

--       (F) AFTER RETURN, IN OUT MODE, DYNAMIC THREE DIMENSIONAL
--           BOUNDS.

-- JWC 10/23/85

WITH REPORT; USE REPORT;
PROCEDURE C95085I IS

BEGIN
     TEST ("C95085I", "CHECK THAT CONSTRAINT_ERROR IS RAISED " &
                      "APPROPRIATELY FOR ACCESS PARAMETERS");

     --------------------------------------------------

     DECLARE

          CALLED : BOOLEAN := FALSE;

          TYPE E IS (E1, E2, E3);

          TYPE T IS ARRAY (CHARACTER RANGE <>,
                           E RANGE <>,
                           BOOLEAN RANGE <>
                          ) OF INTEGER;

          TYPE A IS ACCESS T;

          V : A ('A'..'Z', E1..E2, BOOLEAN) :=
                    NEW T ('A'..'Z', E1..E2, BOOLEAN);

          TASK TSK IS
               ENTRY E (X : IN OUT A);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (X : IN OUT A) DO
                         CALLED := TRUE;
                         IF EQUAL (3,3) THEN
                              X := NEW T ('A'..'Z', E2..E3, BOOLEAN);
                         END IF;
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
END C95085I;
