-- CB1010D.ADA

-- CHECK THAT STORAGE_ERROR IS RAISED WHEN STORAGE FOR THE EXECUTION OF
-- A SUBPROGRAM IS INSUFFICIENT.

-- PNH 8/26/85
-- JRK 8/30/85

WITH REPORT; USE REPORT;

PROCEDURE CB1010D IS

     N : INTEGER := IDENT_INT (1);
     M : INTEGER := IDENT_INT (0);

     PROCEDURE OVERFLOW_STACK IS
     BEGIN
          N := N + M;
          IF N > M THEN       -- ALWAYS TRUE.
               OVERFLOW_STACK;
          END IF;
          N := N - M;         -- TO PREVENT TAIL RECURSION OPTIMIZATION.
     END OVERFLOW_STACK;

BEGIN
     TEST ("CB1010D", "CHECK THAT STORAGE_ERROR IS RAISED WHEN " &
                      "STORAGE FOR THE EXECUTION OF A SUBPROGRAM " &
                      "IS INSUFFICIENT");

     -- CHECK HANDLING OF STORAGE_ERROR IN MAIN PROGRAM.

     BEGIN
          OVERFLOW_STACK;
          FAILED ("EXCEPTION NOT RAISED BY STACK OVERFLOW - 1");
     EXCEPTION
          WHEN STORAGE_ERROR =>
               IF N /= 1 THEN
                    FAILED ("VALUE OF VARIABLE N ALTERED - 1");
               END IF;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED BY STACK OVERFLOW - 1");
     END;

     -- CHECK HANDLING OF STORAGE_ERROR IN SUBPROGRAM.

     DECLARE

          PROCEDURE P IS
          BEGIN
               OVERFLOW_STACK;
               FAILED ("EXCEPTION NOT RAISED BY STACK OVERFLOW - 2");
          EXCEPTION
               WHEN STORAGE_ERROR =>
                    IF N /= 1 THEN
                         FAILED ("VALUE OF VARIABLE N ALTERED - 2");
                    END IF;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED BY STACK " &
                            "OVERFLOW - 2");
          END P;

     BEGIN

          N := IDENT_INT (1);
          P;

     END;

     RESULT;
END CB1010D;
