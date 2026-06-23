-- CD2A24I.ADA

-- OBJECTIVE:
--     CHECK THAT IF A SIZE CLAUSE (SPECIFYING THE SMALLEST APPROPRIATE
--     SIZE FOR A SIGNED REPRESENTATION) AND AN ENUMERATION
--     REPRESENTATION CLAUSE ARE GIVEN FOR AN ENUMERATION TYPE,
--     THEN THE TYPE CAN BE USED AS AN ACTUAL PARAMETER IN AN
--     INSTANTIATION.

-- HISTORY:
--     JET 08/19/87 CREATED ORIGINAL TEST.
--     PWB 05/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA'.

WITH REPORT; USE REPORT;
PROCEDURE CD2A24I IS

     TYPE BASIC_ENUM IS (ZERO, ONE, TWO);
     BASIC_SIZE : CONSTANT := 4;

     FOR BASIC_ENUM USE (ZERO => 3, ONE => 4,
                         TWO => 5);

     FOR BASIC_ENUM'SIZE USE BASIC_SIZE;

BEGIN
     TEST ("CD2A24I", "IF A SIZE CLAUSE (SPECIFYING THE SMALLEST " &
                      "APPROPRIATE SIZE FOR A SIGNED " &
                      "REPRESENTATION) AND AN ENUMERATION " &
                      "REPRESENTATION CLAUSE ARE GIVEN FOR AN " &
                      "ENUMERATION TYPE, THEN THE TYPE CAN BE USED " &
                      "AS AN ACTUAL PARAMETER IN AN INSTANTIATION");


     DECLARE -- TYPE DECLARATION GIVEN WITHIN GENERIC PROCEDURE.

          GENERIC
               TYPE GPARM IS (<>);
          PROCEDURE GENPROC (C0, C1, C2: GPARM);

          PROCEDURE GENPROC (C0, C1, C2: GPARM) IS

               SUBTYPE CHECK_TYPE IS GPARM;

               FUNCTION IDENT (CH : CHECK_TYPE) RETURN CHECK_TYPE IS
               BEGIN
                    IF EQUAL (3, 3) THEN
                         RETURN CH;
                    ELSE
                         RETURN C1;
                    END IF;
               END IDENT;

          BEGIN -- GENPROC.

               IF CHECK_TYPE'SIZE /= IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'SIZE");
               END IF;

               IF C0'SIZE < IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR C0'SIZE");
               END IF;

               IF NOT ((C0 <  IDENT (C1)) AND
                       (IDENT (C2)  > IDENT (C1)) AND
                       (C1 <= IDENT (C1)) AND (IDENT (C2) = C2)) THEN
                    FAILED ("INCORRECT RESULTS FOR RELATIONAL " &
                            "OPERATORS");
               END IF;

               IF NOT ((IDENT (C1) IN C1 .. C2)       AND
                       (C0 NOT IN IDENT (C1) .. C2)) THEN
                    FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                            "OPERATORS");
               END IF;

               IF CHECK_TYPE'FIRST /= IDENT (C0) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_TYPE'FIRST");
               END IF;

               IF CHECK_TYPE'LAST /= IDENT (C2) THEN
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

          PROCEDURE NEWPROC IS NEW GENPROC (BASIC_ENUM);

     BEGIN

          NEWPROC (ZERO, ONE, TWO);

     END;

     RESULT;

END CD2A24I;
