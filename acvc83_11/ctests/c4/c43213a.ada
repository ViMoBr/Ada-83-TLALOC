-- C43213A.ADA

-- CHECK THAT SLIDING OCCURS FOR A MULTIDIMENSIONAL AGGREGATE, BUT
-- NOT FOR THE COMPONENT EXPRESSION OF AN IDENTICAL ARRAY OF ARRAY
-- AGGREGATE.

-- EG  02/06/1984

WITH REPORT;

PROCEDURE C43213A IS

     USE REPORT;

BEGIN

     TEST("C43213A","CHECK THAT SLIDING OCCURS FOR A MULTI"   &
                    "DIMENSIONAL AGGREGATE, BUT NOT FOR THE " &
                    "COMPONENT EXPRESSION OF AN IDENTICAL "   &
                    "ARRAY OF ARRAY AGGREGATE");

     BEGIN

CASE_1 :  DECLARE

               TYPE T1 IS ARRAY(INTEGER RANGE <>) OF INTEGER;
               TYPE T2 IS ARRAY(1 .. 2) OF T1(2 .. 3);

               A : T2;

          BEGIN

               A := (1 => (3 .. 4 => -1), 2 => (3 => -2, 4 => -3));
               FAILED ("CASE 1 : CONSTRAINT_ERROR NOT RAISED");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("CASE 1 : WRONG EXCEPTION RAISED");

          END CASE_1;

CASE_2 :  DECLARE

               TYPE T2 IS ARRAY(INTEGER RANGE <>, INTEGER RANGE <>)
                                                        OF INTEGER;

               A : T2(1 .. 2, 2 .. 3);

          BEGIN

               A := (1 => (3 .. 4 => -1), 2 => (3 => -2, 4 => -3));
               IF A'FIRST(1) /= 1 OR A'LAST(1) /= 2 OR
                  A'FIRST(2) /= 2 OR A'LAST(2) /= 3 THEN
                    FAILED ("CASE 2 : INCORRECT BOUNDS");
               ELSE
                    IF A /= (1 => (2 => -1, 3 => -1), 
                             2 => (2 => -2, 3 => -3)) THEN
                         FAILED ("CASE 2 : INCORRECT VALUES");
                    END IF;
               END IF;

          END CASE_2;

     END;

     RESULT;

END C43213A;
