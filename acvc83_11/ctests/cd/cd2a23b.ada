-- CD2A23B.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN A SIZE SPECIFICATION AND AN ENUMERATION
--     SPECIFICATION CLAUSE ARE GIVEN FOR AN ENUMERATION TYPE
--     WITHIN A GENERIC UNIT, THEN OPERATIONS ON VALUES OF SUCH
--     A TYPE ARE NOT AFFECTED BY THE REPRESENTATION CLAUSES.

-- HISTORY:
--     JET 08/18/87  CREATED ORIGINAL TEST.
--     DHH 04/18/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA', CHANGED
--                   OPERATORS ON 'SIZE TESTS, AND ADDED CHECK ON
--                   REPRESENTATION CLAUSE.

WITH REPORT; USE REPORT;
WITH LENGTH_CHECK;                      -- CONTAINS A CALL TO 'FAILED'.
PROCEDURE CD2A23B IS

     BASIC_SIZE : CONSTANT := INTEGER'SIZE/2;

BEGIN
     TEST ("CD2A23B", "CHECK THAT WHEN A SIZE SPECIFICATION AND AN " &
                      "ENUMERATION REPRESENTATION CLAUSE ARE " &
                      "GIVEN FOR AN ENUMERATION TYPE WITHIN A " &
                      "GENERIC UNIT, THEN OPERATIONS ON VALUES OF " &
                      "SUCH A TYPE ARE NOT AFFECTED BY THE " &
                      "REPRESENTATION CLAUSES");

     DECLARE -- SIZE SPECIFICATION GIVEN WITHIN GENERIC PROCEDURE.

          GENERIC
          PROCEDURE GENPROC;

          PROCEDURE GENPROC IS

               TYPE CHECK_TYPE IS (ZERO, ONE, TWO);

               FOR CHECK_TYPE USE (ZERO => 3, ONE => 4, TWO => 5);

               FOR CHECK_TYPE'SIZE USE BASIC_SIZE;

               C0 : CHECK_TYPE := ZERO;
               C1 : CHECK_TYPE := ONE;
               C2 : CHECK_TYPE := TWO;

               FUNCTION IDENT (CH : CHECK_TYPE) RETURN CHECK_TYPE IS
               BEGIN
                    IF EQUAL (3, 3) THEN
                         RETURN CH;
                    ELSE
                         RETURN ONE;
                    END IF;
               END IDENT;

               PROCEDURE CHECK_1 IS NEW LENGTH_CHECK (CHECK_TYPE);

          BEGIN -- GENPROC.
               CHECK_1 (C0, BASIC_SIZE, "CHECK_TYPE");

               IF CHECK_TYPE'SIZE /= IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'SIZE");
               END IF;

               IF C0'SIZE < IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR C0'SIZE");
               END IF;

               IF NOT ((C0 <  IDENT (ONE)) AND
                       (IDENT (C2)  > IDENT (C1)) AND
                       (C1 <= IDENT (ONE)) AND (IDENT (TWO) = C2)) THEN
                    FAILED ("INCORRECT RESULTS FOR RELATIONAL " &
                            "OPERATORS");
               END IF;

               IF NOT ((IDENT (C1) IN C1 .. C2)       AND
                       (C0 NOT IN IDENT (ONE) .. C2)) THEN
                    FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                            "OPERATORS");
               END IF;

               IF CHECK_TYPE'FIRST /= IDENT (ZERO) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'FIRST");
               END IF;

               IF CHECK_TYPE'LAST /= IDENT (TWO) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'LAST");
               END IF;

               IF CHECK_TYPE'POS (C0) /= IDENT_INT (0) OR
                  CHECK_TYPE'POS (C1) /= IDENT_INT (1) OR
                  CHECK_TYPE'POS (C2) /= IDENT_INT (2) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'POS");
               END IF;

               IF CHECK_TYPE'VAL (0) /= IDENT (C0) OR
                  CHECK_TYPE'VAL (1) /= IDENT (C1) OR
                  CHECK_TYPE'VAL (2) /= IDENT (C2) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'VAL");
               END IF;

               IF CHECK_TYPE'SUCC (C0) /= IDENT (C1) OR
                  CHECK_TYPE'SUCC (C1) /= IDENT (C2) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'SUCC");
               END IF;

               IF CHECK_TYPE'PRED (C1) /= IDENT (C0) OR
                  CHECK_TYPE'PRED (C2) /= IDENT (C1) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'PRED");
               END IF;

               IF CHECK_TYPE'IMAGE (C0) /= IDENT_STR ("ZERO") OR
                  CHECK_TYPE'IMAGE (C1) /= IDENT_STR ("ONE")  OR
                  CHECK_TYPE'IMAGE (C2) /= IDENT_STR ("TWO")  THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'IMAGE");
               END IF;

               IF CHECK_TYPE'VALUE ("ZERO") /= IDENT (C0)  OR
                  CHECK_TYPE'VALUE ("ONE")  /=  IDENT (C1) OR
                  CHECK_TYPE'VALUE ("TWO")  /=  IDENT (C2) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'VALUE");
               END IF;

          END GENPROC;

          PROCEDURE NEWPROC IS NEW GENPROC;

     BEGIN

          NEWPROC;

     END;

     RESULT;

END CD2A23B;
