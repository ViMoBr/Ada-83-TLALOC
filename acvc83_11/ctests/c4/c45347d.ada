-- C45347D.ADA

-- CHECK THAT CATENATION IS DEFINED FOR ACCESS TYPES AS COMPONENT TYPES.

-- JWC 11/15/85

WITH REPORT; USE REPORT;

PROCEDURE C45347D IS

BEGIN

     TEST ("C45347D", "CHECK THAT CATENATION IS DEFINED " &
                      "FOR ACCESS TYPES AS COMPONENT TYPES");

     DECLARE

          SUBTYPE INT IS INTEGER RANGE 1 .. 4;
          TYPE ACC IS ACCESS INT;
          TYPE A IS ARRAY ( INT RANGE <>) OF ACC;

          AC1 : ACC := NEW INT'(1);
          AC2 : ACC := NEW INT'(2);
          AC3 : ACC := NEW INT'(3);
          AC4 : ACC := NEW INT'(4);

          A1 : A(1 .. 2) := (AC1, AC2);
          A2 : A(1 .. 2) := (AC3, AC4);
          A3 : A(1 .. 4) := (AC1, AC2, AC3, AC4);
          A4 : A(1 .. 4);
          A5 : A(1 .. 4) := (AC4, AC3, AC2, AC1);

     BEGIN

          A4 := A1 & A2;

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR TWO ARRAYS OF ACCESS");
          END IF;

          A4 := A5;

          A4 := A1 & A2(1) & AC4;

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR ARRAY OF ACCESS, " &
                       "AND ACCESS");
          END IF;

          A4 := A5;

          A4 := AC1 & (A1(2) & A2);

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR ACCESS, AND ARRAY " &
                       "OF ACCESS");
          END IF;

          A4 := A5;

          A4 := AC1 & A1(2) & (A2(1) & AC4);

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR ACCESS");
          END IF;

     END;

     RESULT;

END C45347D;
