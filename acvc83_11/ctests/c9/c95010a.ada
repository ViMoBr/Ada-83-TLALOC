-- C95010A.ADA

-- CHECK THAT A TASK MAY CONTAIN MORE THAN ONE ACCEPT_STATEMENT
--   FOR AN ENTRY.

-- THIS TEST CONTAINS SHARED VARIABLES.

-- JRK 11/5/81
-- JWC 6/28/85   RENAMED TO -AB

WITH REPORT; USE REPORT;
PROCEDURE C95010A IS

     V : INTEGER := 0;

BEGIN
     TEST ("C95010A", "CHECK THAT A TASK MAY CONTAIN MORE THAN " &
                      "ONE ACCEPT_STATEMENT FOR AN ENTRY");

     DECLARE

          SUBTYPE INT IS INTEGER RANGE 1..5;

          TASK T IS
               ENTRY E;
               ENTRY EF (INT) (I : INTEGER);
          END T;

          TASK BODY T IS
          BEGIN
               V := 1;
               ACCEPT E;
               V := 2;
               ACCEPT E;
               V := 3;
               ACCEPT EF (2) (I : INTEGER) DO
                    V := I;
               END EF;
               V := 5;
               ACCEPT EF (2) (I : INTEGER) DO
                    V := I;
               END EF;
               V := 7;
          END T;

     BEGIN

          T.E;
          T.E;
          T.EF (2) (4);
          T.EF (2) (6);

     END;

     IF V /= 7 THEN
          FAILED ("WRONG CONTROL FLOW VALUE");
     END IF;

     RESULT;
END C95010A;
