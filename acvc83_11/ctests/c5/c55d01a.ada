-- C55D01A.ADA

-- OBJECTIVE:
--     CHECK THAT LOOP ... END LOOP IS EXECUTED UNTIL EXIT, GOTO,
--     OR RETURN OR AN EXCEPTION IS RAISED.

-- HISTORY:
--     DAT 01/29/81  CREATED ORIGINAL TEST.
--     JET 01/06/88  UPDATED HEADER FORMAT AND ADDED CODE TO
--                   DEFEAT OPTIMIZATION.

WITH REPORT;
PROCEDURE C55D01A IS

     USE REPORT;

     I : INTEGER := 0;
     J : INTEGER := 0;

BEGIN

     TEST ("C55D01A", "CHECK THAT LOOP ... END LOOP IS EXECUTED " &
                      "UNTIL EXIT, GOTO, OR RETURN OR AN " &
                      "EXCEPTION IS RAISED");

     LOOP
          I := I + 1;
          IF IDENT_INT(I) = 10 THEN
               GOTO OUT_1;
          END IF;
     END LOOP;
     FAILED ("BAD LOOP FLOW 1");

<<OUT_1>>
     IF I /= 10 THEN
          FAILED ("BAD LOOP FLOW 2");
     END IF;

     I := 10;
     LOOP
          J := IDENT_INT(J) + 1;
          I := IDENT_INT(I) - 1;
          EXIT WHEN J = 10;
     END LOOP;
     IF I /= 0 THEN
          FAILED ("BAD LOOP FLOW 3");
     END IF;

     DECLARE

          PROCEDURE P IS
          BEGIN

               LOOP
                    I := IDENT_INT(I) + 1;
                    J := IDENT_INT(J) - 1;
                    IF I = 10 THEN
                         RETURN;
                    END IF;
               END LOOP;
               FAILED ("BAD LOOP FLOW 4");
          END P;

     BEGIN

          I := 0;
          J := 10;
          P;
          IF J /= 0 THEN
               FAILED ("BAD LOOP FLOW 5");
          END IF;
     END;

     DECLARE

          I10: INTEGER RANGE 1 .. 10 := 10;

     BEGIN

          J := 20;
          LOOP
               J := IDENT_INT (J) + 1;
               I10 := IDENT_INT (I10) - 1;
          END LOOP;
          FAILED ("BAD LOOP FLOW 10");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF J /= 30 THEN
                    FAILED ("BAD LOOP FLOW 11");
               END IF;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED");
     END;

     IF J /= 30 THEN
          FAILED ("BAD LOOP FLOW 13");
     END IF;

     RESULT;
END C55D01A;
