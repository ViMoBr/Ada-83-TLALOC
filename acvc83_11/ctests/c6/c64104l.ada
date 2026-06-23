-- C64104L.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE APPROPRIATE
--   CIRCUMSTANCES FOR ACCESS PARAMETERS, NAMELY WHEN THE
--   ACTUAL INDEX BOUNDS OR DISCRIMINANTS ARE NOT EQUAL
--   TO THE FORMAL CONSTRAINTS BEFORE THE CALL (FOR IN AND IN OUT
--   MODES), AND WHEN THE FORMAL CONSTRAINTS ARE NOT EQUAL TO THE 
--   ACTUAL CONSTRAINTS UPON RETURN (FOR IN OUT AND OUT MODES).

--       (I) AFTER RETURN, OUT MODE, CONSTRAINED FORMAL, STATIC
--           PRIVATE DISCRIMINANTS.

-- JRK 3/18/81
-- NL 10/13/81
-- SPS 10/26/82

WITH REPORT;
PROCEDURE C64104L IS

     USE REPORT;

BEGIN
     TEST ("C64104L", "CHECK THAT CONSTRAINT_ERROR IS RAISED " &
           "APPROPRIATELY FOR ACCESS PARAMETERS");

     --------------------------------------------------

     DECLARE

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
          SUBTYPE SA IS A(E2, TRUE);
          V : A (E2, FALSE) := NEW T (E2, FALSE);

          ENTERED : BOOLEAN := FALSE;

          PROCEDURE P (X : OUT SA ) IS
          BEGIN
               ENTERED := TRUE;
               X := NEW T (E2, TRUE);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE");
          END P;

     BEGIN

          P (V);
          FAILED ("EXCEPTION NOT RAISED AFTER RETURN");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT ENTERED THEN
                    FAILED ("CONSTRAINT_ERROR RAISED BEFORE " & 
                            "CALL");
               END IF;
          WHEN OTHERS =>
               IF NOT ENTERED THEN
                   FAILED ("OTHER EXCEPTION RAISED BEFORE CALL");
               ELSE FAILED ("WRONG EXCEPTION RAISED AFTER " & 
                            "RETURN");
               END IF;
     END;

     ------------------------------------------------

     RESULT;

END C64104L;
