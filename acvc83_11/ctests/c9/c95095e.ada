-- C95095E.ADA

-- CHECK THAT OVERLOADED SUBPROGRAM AND ENTRY DECLARATIONS
-- ARE PERMITTED IN WHICH THERE IS A MINIMAL
-- DIFFERENCE BETWEEN THE DECLARATIONS.

--     (E) A SUBPROGRAM IS DECLARED IN AN OUTER DECLARATIVE PART,
--         AN ENTRY IN A TASK, AND ONE HAS ONE MORE PARAMETER
--         THAN THE OTHER; THE OMITTED PARAMETER HAS A DEFAULT VALUE.

-- JWC 7/30/85
-- JRK 10/2/85

WITH REPORT; USE REPORT;
PROCEDURE C95095E IS

BEGIN
     TEST ("C95095E", "SUBPROGRAM/ENTRY OVERLOADING WITH " &
                      "MINIMAL DIFFERENCES ALLOWED");

     --------------------------------------------------

     -- A SUBPROGRAM IS IN AN OUTER DECLARATIVE
     -- PART, AN ENTRY IN A TASK, AND ONE
     -- HAS ONE MORE PARAMETER (WITH A DEFAULT
     -- VALUE) THAN THE OTHER.

     DECLARE
          S : STRING (1..3) := "123";

          PROCEDURE E (I1, I2, I3 : INTEGER := 1) IS
               C : CONSTANT STRING := "CXA";
          BEGIN
               S (I3) := C (I3);
          END E;

          TASK T IS
               ENTRY E (I1, I2 : INTEGER := 1);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (I1, I2 : INTEGER := 1) DO
                    S (2) := 'B';
               END E;
          END T;

     BEGIN

          E (1, 2, 3);
          T.E (1, 2);
          E (1, 2);

          IF S /= "CBA" THEN
               FAILED ("PROCEDURES/ENTRIES DIFFERING " &
                       "ONLY IN EXISTENCE OF ONE " &
                       "DEFAULT-VALUED PARAMETER CAUSED " &
                       "CONFUSION");
          END IF;

     END;

     --------------------------------------------------

     RESULT;
END C95095E;
