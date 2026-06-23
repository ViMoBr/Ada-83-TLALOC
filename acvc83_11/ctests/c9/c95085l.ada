-- C95085L.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE APPROPRIATE
-- CIRCUMSTANCES FOR ACCESS PARAMETERS IN ENTRY CALLS, NAMELY WHEN
-- THE ACTUAL INDEX BOUNDS OR DISCRIMINANTS ARE NOT EQUAL
-- TO THE FORMAL CONSTRAINTS BEFORE THE CALL (FOR IN AND IN OUT
-- MODES), AND WHEN THE FORMAL CONSTRAINTS ARE NOT EQUAL TO THE
-- ACTUAL CONSTRAINTS UPON RETURN (FOR IN OUT AND OUT MODES).

--       (I) AFTER RETURN, OUT MODE, CONSTRAINED FORMAL, STATIC
--           PRIVATE DISCRIMINANTS.

-- JWC 10/24/85

WITH REPORT; USE REPORT;
PROCEDURE C95085L IS

BEGIN
     TEST ("C95085L", "CHECK THAT CONSTRAINT_ERROR IS RAISED " &
                      "APPROPRIATELY FOR ACCESS PARAMETERS");

     --------------------------------------------------

     DECLARE

          CALLED : BOOLEAN := FALSE;

          PACKAGE PKG IS
               TYPE E IS (E1, E2, E3);
               TYPE T (D : E := E1; B : BOOLEAN := FALSE) IS
                    PRIVATE;
          PRIVATE
               TYPE ARR IS ARRAY (E RANGE <>) OF INTEGER;
               TYPE T (D : E := E1; B : BOOLEAN := FALSE) IS
                    RECORD
                         I : INTEGER;
                         CASE B IS
                              WHEN FALSE =>
                                   J : INTEGER;
                              WHEN TRUE =>
                                   A : ARR (E1 .. D);
                         END CASE;
                    END RECORD;
          END PKG;
          USE PKG;

          TYPE A IS ACCESS T;
          SUBTYPE SA IS A (E2, TRUE);
          V : A (E2, FALSE) := NEW T (E2, FALSE);

          TASK TSK IS
               ENTRY E (X : OUT SA);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (X : OUT SA) DO
                         CALLED := TRUE;
                         X := NEW T (E2, TRUE);
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

     ------------------------------------------------

     RESULT;
END C95085L;
