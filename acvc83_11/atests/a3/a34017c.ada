-- A34017C-B.ADA

-- CHECK THAT IF A DERIVED TYPE DEFINITION IS GIVEN IN THE VISIBLE PART
-- OF A PACKAGE, THE TYPE MAY BE USED AS THE PARENT TYPE IN A DERIVED
-- TYPE DEFINITION IN THE PRIVATE PART OF THE PACKAGE AND IN THE BODY.

-- CHECK THAT IF A TYPE IS DECLARED IN THE VISIBLE PART OF A PACKAGE,
-- AND IS NOT A DERIVED TYPE OR A PRIVATE TYPE, IT MAY BE USED AS THE
-- PARENT TYPE IN A DERIVED TYPE DEFINITION IN THE VISIBLE PART, PRIVATE
-- PART, AND BODY.


-- DSJ 4/27/83


WITH REPORT;
PROCEDURE A34017C IS

     USE REPORT;

BEGIN

     TEST( "A34017C", "CHECK THAT A DERIVED TYPE MAY BE USED AS A " &
                      "PARENT TYPE IN THE PRIVATE PART AND BODY.  " &
                      "CHECK THAT OTHER TYPES MAY BE USED AS PARENT " &
                      "TYPES IN VISIBLE PART ALSO");

     DECLARE

          TYPE REC IS
               RECORD
                    C : INTEGER;
               END RECORD;

          PACKAGE PACK1 IS

               TYPE T1 IS RANGE 1 .. 10;
               TYPE T2 IS NEW REC;

               TYPE T3 IS (A,B,C);
               TYPE T4 IS ARRAY ( 1 .. 2 ) OF INTEGER;
               TYPE T5 IS
                    RECORD
                         X : CHARACTER;
                    END RECORD;
               TYPE T6 IS ACCESS INTEGER;

               TYPE N1 IS NEW T3;
               TYPE N2 IS NEW T4;
               TYPE N3 IS NEW T5;
               TYPE N4 IS NEW T6;

          PRIVATE

               TYPE P1 IS NEW T1;
               TYPE P2 IS NEW T2;
               TYPE P3 IS NEW T3;
               TYPE P4 IS NEW T4;
               TYPE P5 IS NEW T5;
               TYPE P6 IS NEW T6;

          END PACK1;

          PACKAGE BODY PACK1 IS
     
               TYPE Q1 IS NEW T1;
               TYPE Q2 IS NEW T2;
               TYPE Q3 IS NEW T3;
               TYPE Q4 IS NEW T4;
               TYPE Q5 IS NEW T5;
               TYPE Q6 IS NEW T6;

          END PACK1;

     BEGIN

          NULL;

     END;

     RESULT;

END A34017C;
