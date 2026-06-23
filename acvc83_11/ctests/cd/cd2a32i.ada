-- CD2A32I.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN A SIZE SPECIFICATION IS GIVEN FOR AN
--     INTEGER TYPE, THEN
--     SUCH A TYPE OF THE SMALLEST APPROPRIATE SIGNED SIZE CAN
--     BE PASSED AS AN ACTUAL PARAMETER TO GENERIC PROCEDURES.

-- HISTORY:
--     JET 08/12/87  CREATED ORIGINAL TEST.
--     DHH 04/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA', CHANGED
--                   SIZE CLAUSE VALUE TO 7, AND CHANGED OPERATOR ON
--                   'SIZE CHECKS.

WITH REPORT;  USE REPORT;
PROCEDURE CD2A32I IS

     TYPE BASIC_INT IS RANGE -63 .. 63;
     BASIC_SIZE : CONSTANT := 7;

     FOR BASIC_INT'SIZE USE BASIC_SIZE;

BEGIN

     TEST ("CD2A32I", "CHECK THAT WHEN A SIZE SPECIFICATION IS " &
                      "GIVEN FOR AN INTEGER TYPE, " &
                      "THEN SUCH A TYPE " &
                      "OF THE SMALLEST APPROPRIATE SIGNED SIZE " &
                      "CAN BE PASSED AS AN ACTUAL PARAMETER TO " &
                      "GENERIC PROCEDURES");

     DECLARE -- TYPE DECLARATION WITHIN GENERIC PROCEDURE.

          GENERIC
               TYPE GPARM IS RANGE <>;
          PROCEDURE GENPROC;

          PROCEDURE GENPROC IS

          SUBTYPE INT IS GPARM;

          I1 : INT := -63;
          I2 : INT :=    0;
          I3 : INT :=  63;

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
                       (IDENT (63) = I3))        THEN
                    FAILED ("INCORRECT RESULTS FOR RELATIONAL " &
                            "OPERATORS");
               END IF;

               FOR I IN IDENT (I1) .. IDENT (I3) LOOP
                    IF NOT (I IN I1 .. I3) OR
                       (I NOT IN IDENT(-63) .. IDENT(63)) THEN
                         FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                                 "OPERATORS");
                    END IF;
               END LOOP;

               IF NOT (((I1 + I3)  = I2)         AND
                       ((I2 - I3)  = I1)         AND
                       ((I3 * I2)  = I2)         AND
                       ((I2 / I1)  = I2)         AND
                       ((I1 ** 1)  = I1)         AND
                       ((I1 REM 10) = IDENT (-3)) AND
                       ((I3 MOD 10) = IDENT (3))) THEN
                    FAILED ("INCORRECT RESULTS FOR BINARY ARITHMETIC " &
                            "OPERATORS");
               END IF;

               IF NOT ((+I1 = I1)     AND
                       (-I3 = I1)     AND
                       (ABS I1 = I3)) THEN
                    FAILED ("INCORRECT RESULTS FOR UNARY ARITHMETIC " &
                            "OPERATORS");
               END IF;

               IF INT'FIRST /= IDENT (-63) THEN
                    FAILED ("INCORRECT VALUE FOR INT'FIRST");
               END IF;

               IF INT'LAST /= IDENT (63) THEN
                    FAILED ("INCORRECT VALUE FOR INT'LAST");
               END IF;

               IF INT'POS (I1) /= IDENT_INT (-63) OR
                  INT'POS (I2) /= IDENT_INT (   0) OR
                  INT'POS (I3) /= IDENT_INT ( 63) THEN
                    FAILED ("INCORRECT VALUE FOR INT'POS");
               END IF;

               IF INT'VAL (-63) /= IDENT (I1) OR
                  INT'VAL (0)    /= IDENT (I2) OR
                  INT'VAL (63)  /= IDENT (I3) THEN
                    FAILED ("INCORRECT VALUE FOR INT'VAL");
               END IF;

               IF INT'SUCC (I1) /= IDENT (-62) OR
                  INT'SUCC (I2) /= IDENT (1)   THEN
                    FAILED ("INCORRECT VALUE FOR INT'SUCC");
               END IF;

               IF INT'PRED (I2) /= IDENT (-1) OR
                  INT'PRED (I3) /= IDENT (62) THEN
                    FAILED ("INCORRECT VALUE FOR INT'PRED");
               END IF;

               IF INT'IMAGE (I1) /= IDENT_STR ("-63") OR
                  INT'IMAGE (I2) /= IDENT_STR (" 0")   OR
                  INT'IMAGE (I3) /= IDENT_STR (" 63") THEN
                    FAILED ("INCORRECT VALUE FOR INT'IMAGE");
               END IF;

               IF INT'VALUE ("-63") /= IDENT (I1) OR
                  INT'VALUE (" 0")   /= IDENT (I2) OR
                  INT'VALUE (" 63") /= IDENT (I3) THEN
                         FAILED ("INCORRECT VALUE FOR INT'VALUE");
               END IF;

          END GENPROC;

          PROCEDURE NEWPROC IS NEW GENPROC (BASIC_INT);

     BEGIN

          NEWPROC;

     END;

     RESULT;

END CD2A32I;
