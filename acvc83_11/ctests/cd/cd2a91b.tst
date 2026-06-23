-- CD2A91B.TST

-- OBJECTIVE:
--     CHECK THAT IF A SIZE CLAUSE IS GIVEN FOR A
--     TASK TYPE IN A GENERIC UNIT, THEN OPERATIONS OF THE TYPE
--     ARE NOT AFFECTED BY THE REPRESENTATION CLAUSE.

-- MACRO SUBSTITUTION:
--     $TASK_SIZE IS THE NUMBER OF BITS NEEDED BY THE IMPLEMENTATION TO
--     HOLD ANY POSSIBLE OBJECT OF THE TASK TYPE "BASIC_TYPE".

-- HISTORY:
--     BCB 09/04/87  CREATED ORIGINAL TEST.
--     RJW 05/12/89  MODIFIED CHECKS INVOLVING 'SIZE ATTRIBUTE.
--                   REMOVED APPLICABILTY CRITERIA.

WITH REPORT; USE REPORT;
PROCEDURE CD2A91B IS

     BASIC_SIZE : CONSTANT := $TASK_SIZE;

     B : BOOLEAN;

BEGIN

     TEST ("CD2A91B", "CHECK THAT IF A SIZE CLAUSE IS " &
                      "GIVEN FOR A TASK TYPE IN A GENERIC UNIT, THEN " &
                      "OPERATIONS ON VALUES OF SUCH A TYPE ARE NOT " &
                      "AFFECTED BY THE REPRESENTATION CLAUSE");

     DECLARE -- SIZE CLAUSES GIVEN WITHIN GENERIC FUNCTION.

          GENERIC
          FUNCTION FUNC RETURN BOOLEAN;

          FUNCTION FUNC RETURN BOOLEAN IS

               TASK TYPE BASIC_TYPE IS
                    ENTRY HERE(NUM : IN OUT INTEGER);
               END BASIC_TYPE;

               FOR BASIC_TYPE'SIZE USE BASIC_SIZE;

               TYPE REC_TYPE IS RECORD
                    COMPF : BASIC_TYPE;
               END RECORD;

               TYPE ARRAY_TYPE IS ARRAY (0 .. 3) OF BASIC_TYPE;

               CHREC : REC_TYPE;

               CHARRAY : ARRAY_TYPE;

               CHECK_TASK : BASIC_TYPE;

               CHECK_PARAM : BASIC_TYPE;

               VAL : INTEGER := 1;

               TASK BODY BASIC_TYPE IS
               BEGIN
                    SELECT
                         ACCEPT HERE(NUM : IN OUT INTEGER) DO
                              NUM := IDENT_INT (0);
                         END HERE;
                    OR
                         TERMINATE;
                    END SELECT;
               END BASIC_TYPE;

               PROCEDURE PROC (CP : BASIC_TYPE; CV : IN OUT INTEGER) IS

               BEGIN

                    CP.HERE(CV);

                    IF CV /= IDENT_INT (0) THEN
                         FAILED ("INCORRECT RESULTS FROM ENTRY CALL " &
                                 " - 1");
                    END IF;

               END PROC;

     BEGIN -- FUNC.

          PROC (CHECK_PARAM,VAL);

          IF BASIC_TYPE'SIZE /= IDENT_INT (BASIC_SIZE) THEN
               FAILED ("INCORRECT VALUE FOR BASIC_TYPE'SIZE");
          END IF;

          IF CHECK_TASK'SIZE < IDENT_INT (BASIC_SIZE) THEN
               FAILED ("INCORRECT VALUE FOR CHECK_TASK'SIZE");
          END IF;

          VAL := 1;

          CHECK_TASK.HERE(VAL);

          IF VAL /= IDENT_INT (0) THEN
               FAILED ("INCORRECT RESULTS FROM ENTRY CALL - 2");
          END IF;

          VAL := 1;

          CHARRAY (1).HERE(VAL);

          IF VAL /= IDENT_INT (0) THEN
               FAILED ("INCORRECT RESULTS FROM ENTRY CALL - 3");
          END IF;

          VAL := 1;

          CHREC.COMPF.HERE(VAL);

          IF VAL /= IDENT_INT (0) THEN
               FAILED ("INCORRECT RESULTS FROM ENTRY CALL - 4");
          END IF;

          RETURN TRUE;

     END FUNC;

     FUNCTION NEWFUNC IS NEW FUNC;

     BEGIN
          B := NEWFUNC;
     END;

     RESULT;
END CD2A91B;
