-- C45347B.ADA

-- CHECK THAT CATENATION IS DEFINED FOR ARRAY TYPES AS COMPONENT TYPES.

-- JWC 11/15/85

WITH REPORT; USE REPORT;

PROCEDURE C45347B IS

BEGIN

     TEST ("C45347B", "CHECK THAT CATENATION IS DEFINED " &
                      "FOR ARRAY TYPES AS COMPONENT TYPES");

     DECLARE

          TYPE ARR IS ARRAY (1 .. 2) OF INTEGER;
          TYPE A IS ARRAY ( INTEGER RANGE <>) OF ARR;

          AR1 : ARR := (4,1);
          AR2 : ARR := (1,1);

          A1 : A(1 .. 2) := ((1,1), (2,1));
          A2 : A(1 .. 2) := ((3,1), (4,1));
          A3 : A(1 .. 4) := ((1,1), (2,1), (3,1), (4,1));
          A4 : A(1 .. 4);
          A5 : A(1 .. 4) := ((4,1), (3,1), (2,1), (1,1));

     BEGIN

          A4 := A1 & A2;

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR ARRAYS OF ARRAYS");
          END IF;

          A4 := A5;

          A4 := A1 & A2(1) & AR1;

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR ARRAY OF ARRAYS " &
                       "WITH ARRAYS");
          END IF;

          A4 := A5;

          A4 := AR2 & (A1(2) & A2);

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR ARRAYS WITH ARRAYS " &
                       "OF ARRAYS");
          END IF;

          A4 := A5;

          A4 := A'(AR2 & A1(2)) & A'(A2(1) & AR1);

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR ARRAYS");
          END IF;

     END;

     RESULT;

END C45347B;
