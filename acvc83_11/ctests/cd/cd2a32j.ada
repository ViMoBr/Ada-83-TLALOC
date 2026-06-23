-- CD2A32J.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN A SIZE SPECIFICATION IS GIVEN FOR AN
--     INTEGER TYPE IN GENERIC PROCEDURES, THEN
--     SUCH A TYPE OF THE SMALLEST APPROPRIATE UNSIGNED SIZE
--     CAN BE PASSED AS AN ACTUAL PARAMETER TO GENERIC
--     PROCEDURES.

-- HISTORY:
--     JET 08/12/87  CREATED ORIGINAL TEST.
--     DHH 04/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA', CHANGED
--                   SIZE CLAUSE VALUE TO 7, AND CHANGED OPERATOR ON
--                   'SIZE CHECKS.

WITH REPORT;  USE REPORT;

PROCEDURE CD2A32J IS

     TYPE BASIC_INT IS RANGE 0 .. 126;
     BASIC_SIZE : CONSTANT := 7;

     FOR BASIC_INT'SIZE USE BASIC_SIZE;

BEGIN

     TEST ("CD2A32J", "CHECK THAT WHEN A SIZE SPECIFICATION IS " &
                      "GIVEN FOR AN INTEGER TYPE IN GENERIC " &
                      "PROCEDURES, THEN SUCH A TYPE " &
                      "OF THE SMALLEST APPROPRIATE UNSIGNED SIZE " &
                      "CAN BE PASSED AS AN ACTUAL PARAMETER TO " &
                      "GENERIC PROCEDURES");

     DECLARE -- TYPE DECLARATION WITHIN GENERIC PROCEDURE.

          GENERIC
               TYPE GPARM IS RANGE <>;
          PROCEDURE GENPROC;

          PROCEDURE GENPROC IS

          SUBTYPE INT IS GPARM;

          I0 : INT :=   0;
          I1 : INT :=  63;
          I2 : INT := 126;

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

               IF I0'SIZE < IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR I0'SIZE");
               END IF;

               IF NOT ((I0 < IDENT (1))          AND
                       (IDENT (I2) > IDENT (I1)) AND
                       (I1 <= IDENT (63))       AND
                       (IDENT (126) = I2))       THEN
                    FAILED ("INCORRECT RESULTS FOR RELATIONAL " &
                            "OPERATORS");
               END IF;

               FOR I IN IDENT (I0) .. IDENT (I2) LOOP
                    IF NOT (I IN I0 .. I2) OR
                       (I NOT IN IDENT(0) .. IDENT(126)) THEN
                         FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                                 "OPERATORS");
                    END IF;
               END LOOP;

               IF NOT (((I0 + I2)  = I2)          AND
                       ((I2 - I1)  = I1)          AND
                       ((I1 * IDENT (2)) = I2)    AND
                       ((I2 / I1)  = IDENT (2))   AND
                       ((I1 ** 1)  = IDENT (63)) AND
                       ((I2 REM 10) = IDENT (6))   AND
                       ((I1 MOD 10) = IDENT (3)))  THEN
                    FAILED ("INCORRECT RESULTS FOR BINARY ARITHMETIC " &
                            "OPERATORS");
               END IF;

               IF NOT ((+I2 = I2)     AND
                       (-I1 = -63)   AND
                       (ABS I2 = I2)) THEN
                    FAILED ("INCORRECT RESULTS FOR UNARY ARITHMETIC " &
                            "OPERATORS");
               END IF;

               IF INT'POS (I0) /= IDENT_INT (0)   OR
                  INT'POS (I1) /= IDENT_INT (63) OR
                  INT'POS (I2) /= IDENT_INT (126) THEN
                    FAILED ("INCORRECT VALUE FOR INT'POS");
               END IF;

               IF INT'VAL (0)   /= IDENT (I0) OR
                  INT'VAL (63) /= IDENT (I1) OR
                  INT'VAL (126) /= IDENT (I2) THEN
                    FAILED ("INCORRECT VALUE FOR INT'VAL");
               END IF;

               IF INT'SUCC (I0) /= IDENT (1)   OR
                  INT'SUCC (I1) /= IDENT (64)  THEN
                    FAILED ("INCORRECT VALUE FOR INT'SUCC");
               END IF;

               IF INT'PRED (I1) /= IDENT (62)  OR
                  INT'PRED (I2) /= IDENT (125)  THEN
                    FAILED ("INCORRECT VALUE FOR INT'PRED");
               END IF;

               IF INT'IMAGE (I0) /= IDENT_STR (" 0")   OR
                  INT'IMAGE (I1) /= IDENT_STR (" 63") OR
                  INT'IMAGE (I2) /= IDENT_STR (" 126") THEN
                    FAILED ("INCORRECT VALUE FOR INT'IMAGE");
               END IF;

               IF INT'VALUE (" 0")   /= IDENT (I0) OR
                  INT'VALUE (" 63") /= IDENT (I1) OR
                  INT'VALUE (" 126") /= IDENT (I2) THEN
                         FAILED ("INCORRECT VALUE FOR INT'VALUE");
               END IF;

          END GENPROC;

          PROCEDURE NEWPROC IS NEW GENPROC (BASIC_INT);

     BEGIN

          NEWPROC;

     END;

     RESULT;

END CD2A32J;
