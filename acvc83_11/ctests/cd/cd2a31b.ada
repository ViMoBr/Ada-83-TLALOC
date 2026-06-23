-- CD2A31B.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN A SIZE SPECIFICATION IS GIVEN FOR AN
--     INTEGER TYPE IN GENERIC PROCEDURES, THEN
--     OPERATIONS ON VALUES OF SUCH A TYPE ARE NOT AFFECTED BY
--     THE REPRESENTATION CLAUSE.

-- HISTORY:
--     JET 08/06/87  CREATED ORIGINAL TEST.
--     DHH 04/06/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA', CHANGED
--                   SIZE CLAUSE VALUE TO 9, AND ADDED REPRESENTAION
--                   CLAUSE CHECK.

WITH REPORT;  USE REPORT;
WITH LENGTH_CHECK;                      -- CONTAINS A CALL TO 'FAILED'.
PROCEDURE CD2A31B IS

     BASIC_SIZE : CONSTANT := 9;

BEGIN

     TEST ("CD2A31B", "CHECK THAT WHEN A SIZE SPECIFICATION IS " &
                      "GIVEN FOR AN INTEGER TYPE IN GENERIC " &
                      "PROCEDURES, THEN OPERATIONS ON " &
                      "VALUES OF SUCH A TYPE ARE " &
                      "NOT AFFECTED BY THE REPRESENTATION CLAUSE");

     DECLARE -- SIZE SPECIFICATION GIVEN WITHIN GENERIC PROCEDURE.

          GENERIC
          PROCEDURE GENPROC;

          PROCEDURE GENPROC IS

          TYPE INT IS RANGE -100 .. 100;
          FOR INT'SIZE USE BASIC_SIZE;

          I1 : INT := -100;
          I2 : INT :=    0;
          I3 : INT :=  100;
          PROCEDURE CHECK_1 IS NEW LENGTH_CHECK (INT);

          FUNCTION IDENT (I : INT) RETURN INT IS
          BEGIN
               IF EQUAL (0,0) THEN
                    RETURN I;
               ELSE
                    RETURN 0;
               END IF;
          END IDENT;

          BEGIN -- GENPROC.

               IF INT'SIZE /= IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR INT'SIZE");
               END IF;

               IF I1'SIZE < IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR I1'SIZE");
               END IF;

               IF NOT ((I1 < IDENT (0))           AND
                       (IDENT (I3) > IDENT (I2))  AND
                       (I2 <= IDENT (0))          AND
                       (IDENT (100) = I3))        THEN
                    FAILED ("INCORRECT RESULTS FOR RELATIONAL " &
                            "OPERATORS");
               END IF;

               FOR I IN IDENT (I1) .. IDENT (I3) LOOP
                    IF NOT (I IN I1 .. I3) OR
                       (I NOT IN IDENT(-100) .. IDENT(100)) THEN
                         FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                                 "OPERATORS");
                    END IF;
               END LOOP;

               IF NOT (((I1 + I3)  = I2)         AND
                       ((I2 - I3)  = I1)         AND
                       ((I3 * I2)  = I2)         AND
                       ((I2 / I1)  = I2)         AND
                       ((I1 ** 1)  = I1)         AND
                       ((I1 REM 9) = IDENT (-1)) AND
                       ((I3 MOD 9) = IDENT (1))) THEN
                    FAILED ("INCORRECT RESULTS FOR BINARY ARITHMETIC " &
                            "OPERATORS");
               END IF;

               IF NOT ((+I1 = I1)     AND
                       (-I3 = I1)     AND
                       (ABS I1 = I3)) THEN
                    FAILED ("INCORRECT RESULTS FOR UNARY ARITHMETIC " &
                            "OPERATORS");
               END IF;

               IF INT'FIRST /= IDENT (-100) THEN
                    FAILED ("INCORRECT VALUE FOR INT'FIRST");
               END IF;

               IF INT'LAST /= IDENT (100) THEN
                    FAILED ("INCORRECT VALUE FOR INT'LAST");
               END IF;

               IF INT'POS (I1) /= IDENT_INT (-100) OR
                  INT'POS (I2) /= IDENT_INT (   0) OR
                  INT'POS (I3) /= IDENT_INT ( 100) THEN
                    FAILED ("INCORRECT VALUE FOR INT'POS");
               END IF;

               IF INT'VAL (-100) /= IDENT (I1) OR
                  INT'VAL (0)    /= IDENT (I2) OR
                  INT'VAL (100)  /= IDENT (I3) THEN
                    FAILED ("INCORRECT VALUE FOR INT'VAL");
               END IF;

               IF INT'SUCC (I1) /= IDENT (-99) OR
                  INT'SUCC (I2) /= IDENT (1)   THEN
                    FAILED ("INCORRECT VALUE FOR INT'SUCC");
               END IF;

               IF INT'PRED (I2) /= IDENT (-1) OR
                  INT'PRED (I3) /= IDENT (99) THEN
                    FAILED ("INCORRECT VALUE FOR INT'PRED");
               END IF;

               IF INT'IMAGE (I1) /= IDENT_STR ("-100") OR
                  INT'IMAGE (I2) /= IDENT_STR (" 0")    OR
                  INT'IMAGE (I3) /= IDENT_STR (" 100")  THEN
                    FAILED ("INCORRECT VALUE FOR INT'IMAGE");
               END IF;

               IF INT'VALUE ("-100") /= IDENT (I1) OR
                  INT'VALUE (" 0")   /= IDENT (I2) OR
                  INT'VALUE (" 100") /= IDENT (I3) THEN
                         FAILED ("INCORRECT VALUE FOR INT'VALUE");
               END IF;
          CHECK_1 (I1, 9, "INT");

          END GENPROC;

          PROCEDURE NEWPROC IS NEW GENPROC;

     BEGIN

          NEWPROC;

     END;

     RESULT;
END CD2A31B;
