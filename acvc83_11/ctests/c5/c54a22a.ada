-- C54A22A.ADA

-- CHECK ALL FORMS OF CHOICE IN CASE CHOICES.

-- DAT 1/29/81
-- SPS 1/21/83

WITH REPORT;
PROCEDURE C54A22A IS

     USE REPORT;

     TYPE T IS RANGE 1 .. 10;
     C5 : CONSTANT T := 5;
     SUBTYPE S1 IS T RANGE 1 .. 5;
     SUBTYPE S2 IS T RANGE C5 + 1 .. 7;
     SUBTYPE SN IS T RANGE C5 + 4 .. C5 - 4 + 7;  -- NULL RANGE.
     SUBTYPE S10 IS T RANGE C5 + 5 .. T'LAST;

BEGIN
     TEST ("C54A22A", "CHECK ALL FORMS OF CASE CHOICES");

     CASE T'(C5 + 3) IS
          WHEN SN                       -- 9..8
          | S1 RANGE 1 .. 0             -- 1..0
          | S2 RANGE C5 + 2 .. C5 + 1   -- 7..6
          | 3 .. 2                      -- 3..2
               => FAILED ("WRONG CASE 1");

          WHEN  S1 RANGE 4 .. C5        -- 4..5
          | S1 RANGE C5 - 4 .. C5 / 2   -- 1..2
          | 3 .. 1 + C5 MOD 3           -- 3..3
          | SN                          -- 9..8
          | S1 RANGE 5 .. C5 - 1        -- 5..4
          | 6 .. 7                      -- 6..7
          | S10                         -- 10..10
          | 9                           -- 9
          | S10 RANGE 10 .. 9 =>        -- 10..9
               FAILED ("WRONG CASE 2");

          WHEN C5 + C5 - 2 .. 8         -- 8
               => NULL;
     END CASE;

     RESULT;
END C54A22A;
