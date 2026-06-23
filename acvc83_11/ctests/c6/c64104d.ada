-- C64104D.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE APPROPRIATE
--   CIRCUMSTANCES FOR ACCESS PARAMETERS, NAMELY WHEN THE
--   ACTUAL INDEX BOUNDS OR DISCRIMINANTS ARE NOT EQUAL
--   TO THE FORMAL CONSTRAINTS BEFORE THE CALL (FOR IN AND IN OUT
--   MODES), AND WHEN THE FORMAL CONSTRAINTS ARE NOT EQUAL TO THE 
--   ACTUAL CONSTRAINTS UPON RETURN (FOR IN OUT AND OUT MODES).

--       (A) BEFORE CALL, IN MODE, STATIC PRIVATE DISCRIMINANT.

-- JRK 3/18/81
-- NL 10/13/81
-- ABW 6/11/82
-- SPS 10/26/82

WITH REPORT;
PROCEDURE C64104D IS

     USE REPORT;

BEGIN
     TEST ("C64104D", "CHECK THAT CONSTRAINT_ERROR IS RAISED " &
           "APPROPRIATELY FOR ACCESS PARAMETERS");

     --------------------------------------------------

     DECLARE

          PACKAGE PKG IS
               TYPE E IS (E1, E2, E3);
               TYPE T (D : E := E1) IS PRIVATE;
               TYPE AR IS ARRAY (E1 .. E3) OF INTEGER;
          PRIVATE
               TYPE T (D : E := E1) IS
                    RECORD
                         I : INTEGER;
                         A : AR;
                    END RECORD;
          END PKG;
          USE PKG;

          TYPE A IS ACCESS T;
          SUBTYPE A1 IS A(E3);
          V : A (E2) := NEW T (E2);

          PROCEDURE P (X : A1) IS
          BEGIN
               FAILED ("EXCEPTION NOT RAISED ON CALL");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE");
          END P;

     BEGIN

          P (V);
          FAILED ("EXCEPTION NOT RAISED BEFORE CALL");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED");
     END;

     ------------------------------------------------

     RESULT;

END C64104D;
