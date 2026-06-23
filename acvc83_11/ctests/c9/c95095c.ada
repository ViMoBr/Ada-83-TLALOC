-- C95095C.ADA

-- CHECK THAT OVERLOADED ENTRY DECLARATIONS
-- ARE PERMITTED IN WHICH THERE IS A MINIMAL
-- DIFFERENCE BETWEEN THE DECLARATIONS.

--     (C) THE BASE TYPE OF A PARAMETER IS DIFFERENT FROM THAT
--         OF THE CORRESPONDING ONE.

-- JWC 7/24/85

WITH REPORT; USE REPORT;
PROCEDURE C95095C IS

BEGIN
     TEST ("C95095C", "ENTRY OVERLOADING WITH " &
                      "MINIMAL DIFFERENCES");

     --------------------------------------------------

     -- THE BASE TYPE OF ONE PARAMETER IS
     -- DIFFERENT FROM THAT OF THE CORRESPONDING
     -- ONE.

     DECLARE

          TYPE NEWINT IS NEW INTEGER;

          I, J, K : INTEGER := 0;
          N : NEWINT;
          S : STRING (1..2) := "12";

          TASK T IS
               ENTRY E (I1 : INTEGER; N1 : OUT NEWINT;
                        I2 : IN OUT INTEGER);
               ENTRY E (I1 : INTEGER; N1 : OUT INTEGER;
                        I2 : IN OUT INTEGER);
          END T;

          TASK BODY T IS
          BEGIN
               LOOP
                    SELECT
                         ACCEPT E (I1 : INTEGER; N1 : OUT NEWINT;
                                   I2 : IN OUT INTEGER) DO
                              S (1) := 'A';
                              N1 := 0; -- THIS VALUE IS IRRELEVENT.
                         END E;
                    OR
                         ACCEPT E (I1 : INTEGER; N1 : OUT INTEGER;
                                   I2 : IN OUT INTEGER) DO
                              S (2) := 'B';
                              N1 := 0; -- THIS VALUE IS IRRELEVENT.
                         END E;
                    OR
                         TERMINATE;
                    END SELECT;
               END LOOP;
          END T;

     BEGIN
          T.E (I, N, K);
          T.E (I, J, K);

          IF S /= "AB" THEN
               FAILED ("ENTRIES DIFFERING ONLY BY " &
                       "THE BASE TYPE OF A PARAMETER " &
                       "CAUSED CONFUSION");
          END IF;
     END;

     --------------------------------------------------

     RESULT;
END C95095C;
