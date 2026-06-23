-- C43105B.ADA

-- OBJECTIVE:
--     IN A RECORD AGGREGATE (X => E, Y => E), WHERE E IS AN OVERLOADED
--     FUNCTION CALL, OVERLOADING RESOLUTION OCCURS SEPARATELY FOR THE
--     DIFFERENT OCCURRENCES OF E.

-- HISTORY:
--     DHH 09/07/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C43105B IS
BEGIN
     TEST ("C43105B", "IN A RECORD AGGREGATE (X => E, Y => E), WHERE " &
                      "E IS AN OVERLOADED FUNCTION CALL, OVERLOADING " &
                      "RESOLUTION OCCURS SEPARATELY FOR THE " &
                      "DIFFERENT OCCURRENCES OF E");

     DECLARE
          TYPE COLOR IS (RED, YELLOW, GREEN);
          TYPE PALETTE IS (GREEN, YELLOW, RED);

          TYPE REC IS
               RECORD
                    X : COLOR;
                    Y : PALETTE;
               END RECORD;

          TYPE RECD IS
               RECORD
                    X : PALETTE;
                    Y : COLOR;
               END RECORD;

          REC1 : REC;
          REC2 : RECD;

          FUNCTION IDENT_C(C : COLOR) RETURN COLOR IS
          BEGIN
               IF EQUAL(3,3) THEN
                    RETURN C;
               ELSE
                    RETURN GREEN;
               END IF;
          END IDENT_C;

          FUNCTION IDENT_C(P : PALETTE) RETURN PALETTE IS
          BEGIN
               IF EQUAL(3,3) THEN
                    RETURN P;
               ELSE
                    RETURN RED;
               END IF;
          END IDENT_C;

     BEGIN
          REC1 := (X => IDENT_C(YELLOW), Y => IDENT_C(YELLOW));
          REC2 := (X => IDENT_C(YELLOW), Y => IDENT_C(YELLOW));

          IF REC1.X /= REC2.Y THEN
               FAILED("COLOR FUNCTION RESOLUTION FAILED");
          END IF;

          IF REC1.Y /= REC2.X THEN
               FAILED("PALETTE FUNCTION RESOLUTION FAILED");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED("EXCEPTION RAISED");
     END;
     RESULT;
END C43105B;
