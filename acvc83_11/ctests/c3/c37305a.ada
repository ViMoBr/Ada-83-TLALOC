-- C37305A.ADA

-- CHECK THAT CHOICES DENOTING A NULL RANGE OF VALUES ARE PERMITTED,
-- AND THAT FOR CHOICES CONSISTING OF A SUBTYPE NAME FOLLOWED BY A
-- RANGE CONSTRAINT WHERE THE LOWER BOUND IS GREATER THAN THE UPPER
-- BOUND, THE BOUNDS NEED NOT BE IN THE RANGE OF THE SUBTYPE VALUES.

-- CHECK THAT AN OTHERS ALTERNATIVE CAN BE PROVIDED EVEN IF ALL VALUES
-- OF THE CASE EXPRESSION HAVE BEEN COVERED BY PRECEDING ALTERNATIVES.

-- ASL 7/14/81
-- JWC 6/28/85   RENAMED TO -AB

WITH REPORT;
PROCEDURE C37305A IS

     USE REPORT;

BEGIN
     TEST ("C37305A","NULL RANGES ALLOWED IN CHOICES FOR VARIANT " &
           "PARTS.  OTHERS ALTERNATIVE ALLOWED AFTER ALL VALUES " &
           "PREVIOUSLY COVERED");

     DECLARE
          SUBTYPE ST IS INTEGER RANGE 1..10;

          TYPE REC(DISC : ST := 1) IS
               RECORD
                    CASE DISC IS
                         WHEN 0..-1 => NULL;
                         WHEN 1..-3 => NULL;
                         WHEN 6..5 =>
                              COMP : INTEGER;
                         WHEN 11..10 => NULL;
                         WHEN 15..12 => NULL;
                         WHEN 11..0 => NULL;
                         WHEN 1..10 => NULL;
                         WHEN OTHERS => NULL;
                    END CASE;
               END RECORD;

          R : REC;
     BEGIN
          R := (DISC => 4);

          IF EQUAL(3,4) THEN
               R := (DISC => 7);
          END IF;

          IF R.DISC /= 4 THEN
               FAILED ("ASSIGNMENT FAILED");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED");
     END;

     RESULT;

END C37305A;
