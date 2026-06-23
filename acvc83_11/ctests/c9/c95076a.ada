-- C95076A.ADA

-- CHECK THAT AN ACCEPT STATEMENT WITH AND WITHOUT A RETURN
-- STATEMENT RETURNS CORRECTLY.

-- GLH  7/11/85

WITH REPORT; USE REPORT;

PROCEDURE C95076A IS

     I : INTEGER;

     TASK T1 IS
          ENTRY E1 (N : IN OUT INTEGER);
     END T1;

     TASK BODY T1 IS
     BEGIN
          ACCEPT E1 (N : IN OUT INTEGER) DO
               IF (N = 5) THEN
                    N := N + 5;
               ELSE
                    N := 0;
               END IF;
          END E1;
     END T1;

     TASK T2 IS
          ENTRY E2 (N : IN OUT INTEGER);
     END T2;

     TASK BODY T2 IS
     BEGIN
          ACCEPT E2 (N : IN OUT INTEGER) DO
               IF (N = 10) THEN
                    N := N + 5;
                    RETURN;
               END IF;
               N := 0;
          END E2;
     END T2;

BEGIN

     TEST ("C95076A", "CHECK THAT AN ACCEPT STATEMENT WITH AND " &
                      "WITHOUT A RETURN STATEMENT RETURNS CORRECTLY");

     I := 5;
     T1.E1 (I);
     IF (I /= 10) THEN
          FAILED ("INCORRECT RENDEVOUS WITHOUT A RETURN");
     END IF;

     I := 10;
     T2.E2 (I);
     IF (I /= 15) THEN
          FAILED ("INCORRECT RENDEVOUS WITH A RETURN");
     END IF;

     RESULT;

END C95076A;
