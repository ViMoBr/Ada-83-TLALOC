-- CD2A31E.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN A SIZE SPECIFICATION IS GIVEN FOR AN
--     INTEGER TYPE, THEN SUCH A TYPE CAN BE PASSED AS AN ACTUAL
--     PARAMETER TO GENERIC PROCEDURES.

-- HISTORY:
--     JET 08/12/87  CREATED ORIGINAL TEST.
--     BCB 10/18/88  MODIFIED HEADER AND ENTERED IN ACVC.
--     DHH 04/06/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA', CHANGED
--                   SIZE CLAUSE VALUE TO 9, AND CHANGED 'SIZE CLAUSE
--                   CHECKS.

WITH REPORT;  USE REPORT;

PROCEDURE CD2A31E IS

     TYPE BASIC_INT IS RANGE -100 .. 100;
     BASIC_SIZE : CONSTANT := 9;

     FOR BASIC_INT'SIZE USE BASIC_SIZE;

BEGIN

     TEST ("CD2A31E", "CHECK THAT WHEN A SIZE SPECIFICATION IS " &
                      "GIVEN FOR AN INTEGER TYPE, THEN SUCH A TYPE " &
                      "CAN BE PASSED AS AN ACTUAL PARAMETER TO " &
                      "GENERIC PACKAGES AND PROCEDURES");

     DECLARE -- TYPE DECLARATION WITHIN GENERIC PROCEDURE.

          GENERIC
               TYPE GPARM IS RANGE <>;
          PROCEDURE GENPROC;

          PROCEDURE GENPROC IS

          SUBTYPE INT IS GPARM;

          I1 : INT := -100;
          I2 : INT :=    0;
          I3 : INT :=  100;

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

          END GENPROC;

          PROCEDURE NEWPROC IS NEW GENPROC (BASIC_INT);

     BEGIN

          NEWPROC;

     END;

     RESULT;

END CD2A31E;
