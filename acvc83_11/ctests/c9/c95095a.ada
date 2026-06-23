-- C95095A.ADA

-- CHECK THAT OVERLOADED SUBPROGRAM AND ENTRY DECLARATIONS
-- ARE PERMITTED IN WHICH THERE IS A MINIMAL
-- DIFFERENCE BETWEEN THE DECLARATIONS.

--     (A) A FUNCTION AND AN ENTRY.

-- JWC 7/24/85

WITH REPORT; USE REPORT;
PROCEDURE C95095A IS

BEGIN
     TEST ("C95095A", "SUBPROGRAM/ENTRY OVERLOADING WITH " &
                      "MINIMAL DIFFERENCES");

     --------------------------------------------------

     -- BOTH PARAMETERIZED AND PARAMETERLESS SUBPROGRAMS AND ENTRIES
     -- ARE TESTED.

     DECLARE
          I, J, K : INTEGER := 0;
          S : STRING (1..2) := "12";

          TASK T IS
               ENTRY E1 (I1, I2 : INTEGER);
               ENTRY E2;
          END T;

          TASK BODY T IS
          BEGIN
               LOOP
                    SELECT
                         ACCEPT E1 (I1, I2 : INTEGER) DO
                              S (1) := 'A';
                         END E1;
                    OR
                         ACCEPT E2 DO
                              S (1) := 'C';
                         END E2;
                    OR
                         TERMINATE;
                    END SELECT;
               END LOOP;
          END T;

          FUNCTION E1 (I1, I2 : INTEGER) RETURN INTEGER IS
          BEGIN
               S (2) := 'B';
               RETURN I1; -- RETURNED VALUE IS IRRELEVENT.
          END E1;


          FUNCTION E2 RETURN INTEGER IS
          BEGIN
               S (2) := 'D';
               RETURN I; -- RETURNED VALUE IS IRRELEVENT.
          END E2;

     BEGIN
          T.E1 (I, J);
          K := E1 (I, J);

          IF S /= "AB" THEN
               FAILED ("PARAMETERIZED OVERLOADED " &
                       "SUBPROGRAM AND ENTRY " &
                       "CAUSED CONFUSION");
          END IF;

          S := "12";
          T.E2;
          K := E2;

          IF S /= "CD" THEN
               FAILED ("PARAMETERLESS OVERLOADED " &
                       "SUBPROGRAM AND ENTRY " &
                       "CAUSED CONFUSION");
          END IF;
     END;

     --------------------------------------------------

     RESULT;
END C95095A;
