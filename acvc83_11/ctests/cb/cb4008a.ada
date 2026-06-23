-- CB4008A.ADA

-- CHECK THAT NESTED LAST WISHES EXCEPTION HANDLERS WORK 
-- (FOR PROCEDURES).

-- DAT 4/15/81
-- SPS 3/28/83

WITH REPORT; USE REPORT;

PROCEDURE CB4008A IS

     C : INTEGER := 0;

     E : EXCEPTION;

     DEPTH : CONSTANT := 99;

     PROCEDURE F;

     PROCEDURE I IS
     BEGIN
          C := C + 1;
          IF C >= DEPTH THEN
               RAISE E;
          END IF;
     END I;

     PROCEDURE O IS
     BEGIN
          C := C - 1;
     END O;

     PROCEDURE X IS
          PROCEDURE X1 IS
               PROCEDURE X2 IS
               BEGIN
                    F;
               END X2;

               PROCEDURE X3 IS
               BEGIN
                    I;
                    X2;
               EXCEPTION
                    WHEN E => O; RAISE;
               END X3;
          BEGIN
               I;
               X3;
          EXCEPTION
               WHEN E => O; RAISE;
          END X1;

          PROCEDURE X1A IS
          BEGIN
               I;
               X1;
               FAILED ("INCORRECT EXECUTION SEQUENCE");
          EXCEPTION
               WHEN E => O; RAISE;
          END X1A;
     BEGIN
          I;
          X1A;
     EXCEPTION
          WHEN E => O; RAISE;
     END X;

     PROCEDURE Y IS
     BEGIN
          I;
          X;
     EXCEPTION WHEN E => O; RAISE;
     END Y;

     PROCEDURE F IS
          PROCEDURE F2;

          PROCEDURE F1 IS
          BEGIN
               I;
               F2;
          EXCEPTION WHEN E => O; RAISE;
          END F1;

          PROCEDURE F2 IS
          BEGIN
               I;
               Y;
          EXCEPTION WHEN E => O; RAISE;
          END F2;
     BEGIN
          I;
          F1;
     EXCEPTION WHEN E => O; RAISE;
     END F;

BEGIN
     TEST ("CB4008A", "(PROCEDURE) LAST WISHES UNWIND PROPERLY");

     BEGIN
          I;
          Y;
          FAILED ("INCORRECT EXECUTION SEQUENCE 2");
     EXCEPTION
          WHEN E =>
               O;
               IF C /= 0 THEN
                    FAILED ("EXCEPTION HANDLER MISSED SOMEWHERE");
               END IF;
     END;

     RESULT;
END CB4008A;
