-- C37306A.ADA

-- CHECK THAT IN A VARIANT PART OF A RECORD THE CHOICES WITHIN AND
-- BETWEEN ALTERNATIVES CAN APPEAR IN NON-MONOTONIC ORDER.

-- ASL 7/13/81
-- JWC 6/28/85   RENAMED TO -AB

WITH REPORT;
PROCEDURE C37306A IS

     USE REPORT;

BEGIN
     TEST ("C37306A","NON-MONOTONIC ORDER OF CHOICES IN VARIANT PARTS");

     DECLARE
          TYPE COLOR IS (WHITE,RED,ORANGE,YELLOW,GREEN,AQUA,BLUE,BLACK);

          TYPE REC(DISC : COLOR := BLUE) IS
               RECORD
                    CASE DISC IS
                         WHEN ORANGE => NULL;
                         WHEN GREEN | WHITE | BLACK => NULL;
                         WHEN YELLOW => NULL;
                         WHEN BLUE | RED => NULL;
                         WHEN OTHERS => NULL;
                    END CASE;
               END RECORD;

          R : REC;
     BEGIN
          R := (DISC => WHITE);

          IF EQUAL(3,4) THEN
               R := (DISC => RED);
          END IF;

          IF R.DISC /= WHITE THEN
               FAILED ("ASSIGNMENT FAILED");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED");
     END;

     RESULT;
END C37306A;
