-- C41308A.ADA

-- OBJECTIVE:
--     IF F IS THE NAME OF A FUNCTION RETURNING A RECORD WITH
--     COMPONENT X AND X IS ALSO DECLARED WITHIN F, THEN CHECK F.X,
--     WHERE F.X OCCURS WITHIN F (THE FUNCTION SHOULD NOT BE CALLED).

-- HISTORY:
--     BCB 07/14/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C41308A IS

BEGIN
     TEST ("C41308A", "IF F IS THE NAME OF A FUNCTION RETURNING A " &
                      "RECORD WITH COMPONENT X AND X IS ALSO " &
                      "DECLARED WITHIN F, THEN CHECK F.X, WHERE F.X " &
                      "OCCURS WITHIN F (THE FUNCTION SHOULD NOT BE " &
                      "CALLED)");

     DECLARE
          TYPE REC IS RECORD
               X : INTEGER;
          END RECORD;

          A : INTEGER;

          FUNCTION F RETURN REC IS
               X : INTEGER := 3;
               Z : INTEGER := F.X;
               Y : REC := (X => 5);
          BEGIN
               IF NOT EQUAL(Z,IDENT_INT(3)) THEN
                    FAILED ("IMPROPER VALUE FOR Z");
               END IF;

               RETURN Y;
          END;
     BEGIN
          A := F.X;

          IF NOT EQUAL(A,IDENT_INT(5)) THEN
               FAILED ("IMPROPER VALUE FOR A");
          END IF;
     END;

     RESULT;
END C41308A;
