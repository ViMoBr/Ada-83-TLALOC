-- C64104G.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE APPROPRIATE
--   CIRCUMSTANCES FOR ACCESS PARAMETERS, NAMELY WHEN THE
--   ACTUAL INDEX BOUNDS OR DISCRIMINANTS ARE NOT EQUAL
--   TO THE FORMAL CONSTRAINTS BEFORE THE CALL (FOR IN AND IN OUT
--   MODES), AND WHEN THE FORMAL CONSTRAINTS ARE NOT EQUAL TO THE 
--   ACTUAL CONSTRAINTS UPON RETURN (FOR IN OUT AND OUT MODES).

--       (D) BEFORE CALL, IN OUT MODE, DYNAMIC RECORD DISCRIMINANTS.

-- JRK 3/18/81
-- NL 10/13/81
-- SPS 10/26/82

WITH REPORT;
PROCEDURE C64104G IS

     USE REPORT;

BEGIN
     TEST ("C64104G", "CHECK THAT CONSTRAINT_ERROR IS RAISED " &
           "APPROPRIATELY FOR ACCESS PARAMETERS");

     --------------------------------------------------

     DECLARE
          SUBTYPE INT IS INTEGER RANGE 0..10;
          TYPE T (C : CHARACTER := 'A';
                  B : BOOLEAN := FALSE;
                  I : INT := 0
                 ) IS
               RECORD
                    J : INTEGER;
                    CASE B IS
                         WHEN FALSE =>
                              K : INTEGER;
                         WHEN TRUE =>
                              S : STRING (1 .. I);
                    END CASE;
               END RECORD;

          TYPE A IS ACCESS T;
          SUBTYPE SA IS A ('Z', TRUE, 5);
          V : A := NEW T ('Z', IDENT_BOOL(FALSE), 5);

          PROCEDURE P (X : IN OUT SA ) IS
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

     --------------------------------------------------

     RESULT;

END C64104G;
