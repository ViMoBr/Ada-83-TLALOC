-- C45347A.ADA

-- CHECK THAT CATENATION IS DEFINED FOR RECORD TYPES AS COMPONENT TYPES.

-- JWC 11/15/85

WITH REPORT; USE REPORT;

PROCEDURE C45347A IS

BEGIN

     TEST ("C45347A", "CHECK THAT CATENATION IS DEFINED " &
                      "FOR RECORD TYPES AS COMPONENT TYPES");

     DECLARE

          TYPE REC IS
               RECORD
                    X : INTEGER;
               END RECORD;

          SUBTYPE INT IS INTEGER RANGE 1 .. 4;
          TYPE A IS ARRAY ( INT RANGE <>) OF REC;

          R1 : REC := (X => 4);
          R2 : REC := (X => 1);

          A1 : A(1 .. 2) := ((X => 1), (X => 2));
          A2 : A(1 .. 2) := ((X => 3), (X => 4));
          A3 : A(1 .. 4) := ((X => 1), (X => 2), (X => 3), (X => 4));
          A4 : A(1 .. 4);
          A5 : A(1 .. 4) := ((X => 4), (X => 3), (X => 2), (X => 1));

     BEGIN

          A4 := A1 & A2;

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR TWO ARRAYS OF " &
                       "RECORDS");
          END IF;

          A4 := A5;

          A4 := A1 & A2(1) & R1;

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR ARRAY OF RECORD, " &
                       "AND RECORDS");
          END IF;

          A4 := A5;

          A4 := R2 & (A1(2) & A2);

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR RECORDS, " &
                       "AND ARRAY OF RECORDS");
          END IF;

          A4 := A5;

          A4 := R2 & A1(2) & (A2(1) & R1);

          IF A3 /= A4 THEN
               FAILED ("INCORRECT CATENATION FOR RECORDS");
          END IF;

     END;

     RESULT;

END C45347A;
