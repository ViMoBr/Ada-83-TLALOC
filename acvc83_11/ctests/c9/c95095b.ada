-- C95095B.ADA

-- CHECK THAT OVERLOADED ENTRY DECLARATIONS
-- ARE PERMITTED IN WHICH THERE IS A MINIMAL
-- DIFFERENCE BETWEEN THE DECLARATIONS.

--     (B) ONE ENTRY HAS ONE LESS PARAMETER THAN THE OTHER.

-- JWC 7/24/85
-- JRK 10/2/85

WITH REPORT; USE REPORT;
PROCEDURE C95095B IS

BEGIN
     TEST ("C95095B", "ENTRY OVERLOADING WITH " &
                      "MINIMAL DIFFERENCES");

     --------------------------------------------------

     -- ONE ENTRY HAS ONE MORE PARAMETER
     -- THAN THE OTHER.  THIS IS TESTED IN THE
     -- CASE IN WHICH THAT PARAMETER HAS A DEFAULT
     -- VALUE, AND THE CASE IN WHICH IT DOES NOT.

     DECLARE
          I, J : INTEGER := 0;
          B : BOOLEAN := TRUE;
          S : STRING (1..2) := "12";

          TASK T IS
               ENTRY E1 (I1, I2 : INTEGER; B1 : IN OUT BOOLEAN);
               ENTRY E1 (I1, I2 : INTEGER);
               ENTRY E2 (B1 : IN OUT BOOLEAN; I1 : INTEGER := 0);
               ENTRY E2 (B1 : IN OUT BOOLEAN);
          END T;

          TASK BODY T IS
          BEGIN
               LOOP
                    SELECT
                         ACCEPT E1 (I1, I2 : INTEGER;
                                    B1 : IN OUT BOOLEAN) DO
                              S (1) := 'A';
                         END E1;
                    OR
                         ACCEPT E1 (I1, I2 : INTEGER) DO
                              S (2) := 'B';
                         END E1;
                    OR
                         ACCEPT E2 (B1 : IN OUT BOOLEAN;
                                    I1 : INTEGER := 0) DO
                              S (1) := 'C';
                         END E2;
                    OR
                         ACCEPT E2 (B1 : IN OUT BOOLEAN) DO
                              S (2) := 'D';
                         END E2;
                    OR
                         TERMINATE;
                    END SELECT;
               END LOOP;
          END T;

     BEGIN
          T.E1 (I, J, B);
          T.E1 (I, J);

          IF S /= "AB" THEN
               FAILED ("ENTRIES DIFFERING ONLY IN " &
                       "NUMBER OF PARAMETERS (NO DEFAULTS) " &
                       "CAUSED CONFUSION");
          END IF;

          S := "12";
          T.E2 (B, I);
          -- NOTE THAT A CALL TO T.E2 WITH ONLY
          -- ONE PARAMETER IS AMBIGUOUS.

          IF S /= "C2" THEN
               FAILED ("ENTRIES DIFFERING ONLY IN " &
                       "EXISTENCE OF ONE PARAMETER (WITH " &
                       "DEFAULT) CAUSED CONFUSION");
          END IF;
     END;

     --------------------------------------------------

     RESULT;
END C95095B;
