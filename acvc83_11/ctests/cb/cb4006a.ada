
-- CB4006A.ADA

-- OBJECTIVE:
--     CHECK THAT EXCEPTIONS IN A BLOCK IN A HANDLER
--     ARE HANDLED CORRECTLY.

-- HISTORY:
--     DAT 04/15/81
--     SPS 11/02/82
--     JET 01/06/88  UPDATED HEADER FORMAT AND ADDED CODE TO
--                   PREVENT OPTIMIZATION.

WITH REPORT;
USE REPORT;

PROCEDURE CB4006A IS

     I1 : INTEGER RANGE 1 .. 2 := 1;

     PROCEDURE P IS
     BEGIN
          IF EQUAL(3,3) THEN
               RAISE PROGRAM_ERROR;
          END IF;
     EXCEPTION
          WHEN PROGRAM_ERROR =>
               DECLARE
                    I : INTEGER RANGE 1 .. 1 := I1;
               BEGIN
                    I := I1 + 1;
                    FAILED ("EXCEPTION NOT RAISED 1");

                    IF NOT EQUAL(I,I) THEN
                         COMMENT ("CAN'T OPTIMIZE THIS");
                    END IF;

               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I1 /= 1 THEN
                              FAILED ("WRONG HANDLER 1");
                         ELSE
                              I1 := I1 + 1;
                         END IF;
               END;
          WHEN CONSTRAINT_ERROR =>
               FAILED ("WRONG HANDLER 3");
     END P;

BEGIN
     TEST ("CB4006A", "CHECK THAT EXCEPTIONS IN BLOCKS IN " &
                      "HANDLERS WORK");

     P;
     IF IDENT_INT(I1) /= 2 THEN
          FAILED ("EXCEPTION NOT HANDLED CORRECTLY");
     ELSE
          BEGIN
               P;
               FAILED ("EXCEPTION NOT RAISED CORRECTLY 2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR => NULL;
          END;
     END IF;

     RESULT;

EXCEPTION
     WHEN OTHERS => FAILED ("WRONG HANDLER 2");
          RESULT;

END CB4006A;
