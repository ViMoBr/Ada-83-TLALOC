-- C95085E.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE APPROPRIATE
-- CIRCUMSTANCES FOR ACCESS PARAMETERS IN ENTRY CALLS, NAMELY WHEN
-- THE ACTUAL INDEX BOUNDS OR DISCRIMINANTS ARE NOT EQUAL
-- TO THE FORMAL CONSTRAINTS BEFORE THE CALL (FOR IN AND IN OUT
-- MODES), AND WHEN THE FORMAL CONSTRAINTS ARE NOT EQUAL TO THE
-- ACTUAL CONSTRAINTS UPON RETURN (FOR IN OUT AND OUT MODES).

--       (B) BEFORE CALL, IN MODE, DYNAMIC TWO DIMENSIONAL BOUNDS.

-- JWC 10/23/85

WITH REPORT; USE REPORT;
PROCEDURE C95085E IS

BEGIN
     TEST ("C95085E", "CHECK THAT CONSTRAINT_ERROR IS RAISED " &
                      "APPROPRIATELY FOR ACCESS PARAMETERS");

     --------------------------------------------------

     DECLARE

          TYPE T IS ARRAY (BOOLEAN RANGE <>, CHARACTER RANGE <>) OF
                    INTEGER;

          TYPE A IS ACCESS T;
          SUBTYPE A1 IS A (BOOLEAN, 'A'..'C');
          V : A := NEW T (BOOLEAN, 'A'..IDENT_CHAR('B'));

          TASK TSK IS
               ENTRY E (X : A1);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (X : A1) DO
                         FAILED ("EXCEPTION NOT RAISED ON CALL");
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
          FAILED ("EXCEPTION NOT RAISED BEFORE CALL");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
                FAILED ("WRONG EXCEPTION RAISED");
     END;

     --------------------------------------------------

     RESULT;
END C95085E;
