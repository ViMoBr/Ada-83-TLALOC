-- C95075A.ADA

-- CHECK THAT CALLS TO ENTRIES THAT DO NOT ASSIGN VALUES TO SCALAR
-- COMPONENTS OF FORMAL OUT PARAMETERS ARE ALLOWED.

-- GLH 7/29/85
-- JRK 9/9/85

WITH REPORT; USE REPORT;
PROCEDURE C95075A IS

BEGIN
     TEST ("C95075A", "CHECK THAT CALLS TO ENTRIES THAT DO NOT " &
                      "ASSIGN VALUES TO SCALAR COMPONENTS OF FORMAL " &
                      "OUT PARAMETERS ARE ALLOWED");

     DECLARE
          TYPE A IS ARRAY (1..3) OF INTEGER;
          A1 : A := (1,2,3);

          TASK T IS
               ENTRY E (A1 : OUT A);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (A1 : OUT A) DO
                    NULL;
               END E;
          EXCEPTION
               WHEN OTHERS => FAILED ("EXCEPTION RAISED IN TASK T");
          END T;

     BEGIN

          T.E (A1);
          IF IDENT_BOOL (FALSE) THEN         -- NEVER TRUE.
               IF A1 /= (1,2,3) THEN         -- TO PREVENT DEAD VARIABLE
                                             -- OPTIMIZATION.
                    FAILED ("BAD IF_STATEMENT");
               END IF;
          END IF;

     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED BY T.E");
     END;

     RESULT;
END C95075A;
