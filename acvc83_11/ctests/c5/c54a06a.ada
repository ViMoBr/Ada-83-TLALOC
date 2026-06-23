-- C54A06A.ADA

-- CHECK THAT CASE EXPRESSIONS MAY BE COMPLEX STATIC EXPRESSIONS.

-- DAT 3/18/81
-- SPS 11/1/82
-- VKG 1/10/83

WITH REPORT; USE REPORT;

PROCEDURE C54A06A IS

     SUBTYPE I3 IS INTEGER RANGE 1 .. 1 + 1 + 1;  -- 1 .. 3

     C3 : CONSTANT I3 := I3'LAST + INTEGER(0.3);  -- 3
     TYPE ARR IS ARRAY (I3) OF I3;
     TYPE R1 IS
          RECORD
               C : ARR;
          END RECORD;

     AG : CONSTANT ARRAY (I3) OF I3
          := (1, 2, C3 * C3 / C3);                -- (1, 2, 3)

     AGG : CONSTANT R1 := (C => (C3 - 2, C3, C3 / C3));  -- ((1, 3, 1))

BEGIN
     TEST ("C54A06A", "CASE EXPRESSIONS MAY BE STATIC AND"
          & " COMPLICATED");

     CASE I3'(AGG.C(AG(C3) - AGG.C(I3'FIRST)) - AG(2) / AG(3)) IS  -- 3
          WHEN 3/(1+1+2-1) ..                          -- 1 ..
               I3'(4+9-12)                             -- 1
            |  I3 RANGE INTEGER'(1 + 1) ..             -- 2 ..
               ABS(I3'LAST - 1)             -- 2
            => FAILED ("WRONG CASE CHOICE");
          WHEN OTHERS => NULL;                  -- 3
     END CASE;

     RESULT;
END C54A06A;
