-- C43105A.ADA

-- OBJECTIVE:
--     IN A RECORD AGGREGATE, (X => E, Y => E), WHERE E IS AN OVERLOADED
--     ENUMERATION LITERAL, OVERLOADING RESOLUTION OCCURS SEPARATELY FOR
--     THE DIFFERENT OCCURRENCES OF E.

-- HISTORY:
--     DHH 08/10/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C43105A IS

BEGIN
     TEST("C43105A", "IN A RECORD AGGREGATE, (X => E, Y => E), WHERE " &
                     "E IS AN OVERLOADED ENUMERATION LITERAL, " &
                     "OVERLOADING RESOLUTION OCCURS SEPARATELY FOR " &
                     "THE DIFFERENT OCCURRENCES OF E");

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

          FUNCTION IDENT_P(P : PALETTE) RETURN PALETTE IS
          BEGIN
               IF EQUAL(3,3) THEN
                    RETURN P;
               ELSE
                    RETURN RED;
               END IF;
          END IDENT_P;


     BEGIN
          REC1 := (X => YELLOW, Y => YELLOW);
          REC2 := (X => YELLOW, Y => YELLOW);

          IF REC1.X /= IDENT_C(REC2.Y) THEN
               FAILED("COLOR RESOLUTION FAILED");
          END IF;

          IF REC1.Y /= IDENT_P(REC2.X) THEN
               FAILED("PALETTE RESOLUTION FAILED");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED("EXCEPTION RAISED");
     END;

     RESULT;
END C43105A;
