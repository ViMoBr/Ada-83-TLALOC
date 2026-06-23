-- CD2A91D.TST

-- OBJECTIVE:
--     CHECK THAT SIZE CLAUSES FOR THE FOLLOWING ARE ALLOWED IN A
--     GENERIC UNIT:
--          TASK TYPES,
--          DERIVED TASK TYPES,
--          A DERIVED PRIVATE TYPE WHOSE FULL DECLARATION IS A TASK
--          TYPE.

-- MACRO SUBSTITUTION:
--     $TASK_SIZE IS THE NUMBER OF BITS NEEDED BY THE IMPLEMENTATION TO
--     HOLD ANY POSSIBLE OBJECT OF THE TASK TYPE "BASIC_TYPE".

-- HISTORY:
--     BCB 09/08/87  CREATED ORIGINAL TEST.
--     RJW 05/12/89  MODIFIED CHECKS INVOLVING 'SIZE ATTRIBUTE.
--                   REMOVED APPLICABILTY CRITERIA.

WITH REPORT; USE REPORT;
PROCEDURE CD2A91D IS

     BASIC_SIZE : CONSTANT := $TASK_SIZE;
     B : BOOLEAN;

BEGIN

     TEST ("CD2A91D", "CHECK THAT SIZE CLAUSES FOR THE FOLLOWING " &
                      "ARE ALLOWED IN A GENERIC UNIT: TASK " &
                      "TYPES, DERIVED TASK TYPES, A DERIVED " &
                      "PRIVATE TYPE WHOSE FULL DECLARATION IS A " &
                      "TASK TYPE");

     DECLARE

          GENERIC
          FUNCTION FUNC RETURN BOOLEAN;

          FUNCTION FUNC RETURN BOOLEAN IS

               VAL : INTEGER := 1;

               TASK TYPE BASIC_TYPE IS
                    ENTRY HERE(NUM : IN OUT INTEGER);
               END BASIC_TYPE;

               FOR BASIC_TYPE'SIZE USE BASIC_SIZE;

               BASIC_TASK : BASIC_TYPE;

               TYPE DERIVED_TYPE IS NEW BASIC_TYPE;
               FOR DERIVED_TYPE'SIZE USE BASIC_SIZE;

               DERIVED_TASK : DERIVED_TYPE;

               PACKAGE P IS
                    TASK TYPE TASK_IN_P IS
                         ENTRY HERE(NUM : IN OUT INTEGER);
                    END TASK_IN_P;
                    FOR TASK_IN_P'SIZE USE BASIC_SIZE;
                    TYPE PRIVATE_TASK IS LIMITED PRIVATE;
                    TASK TYPE ALT_TASK_IN_P IS
                         ENTRY HERE(NUM : IN OUT INTEGER);
                    END ALT_TASK_IN_P;
               PRIVATE
                    TASK TYPE PRIVATE_TASK IS
                         ENTRY HERE(NUM : IN OUT INTEGER);
                    END PRIVATE_TASK;
                    FOR ALT_TASK_IN_P'SIZE USE BASIC_SIZE;
               END P;

               USE P;

               TYPE DERIVED_PRIV_TASK IS NEW PRIVATE_TASK;
               FOR DERIVED_PRIV_TASK'SIZE USE BASIC_SIZE;

               ALT_TASK : ALT_TASK_IN_P;
               IN_TASK : TASK_IN_P;

               TASK BODY BASIC_TYPE IS
               BEGIN
                    SELECT
                         ACCEPT HERE(NUM : IN OUT INTEGER) DO
                              NUM := 0;
                         END HERE;
                    OR
                         TERMINATE;
                    END SELECT;
               END BASIC_TYPE;

               PACKAGE BODY P IS
                    TASK BODY TASK_IN_P IS
                    BEGIN
                         SELECT
                              ACCEPT HERE(NUM : IN OUT INTEGER) DO
                                   NUM := 0;
                              END HERE;
                         OR
                              TERMINATE;
                         END SELECT;
                    END TASK_IN_P;
                    TASK BODY PRIVATE_TASK IS
                    BEGIN
                         SELECT
                              ACCEPT HERE(NUM : IN OUT INTEGER) DO
                                   NUM := 0;
                              END HERE;
                         OR
                              TERMINATE;
                         END SELECT;
                    END PRIVATE_TASK;
                    TASK BODY ALT_TASK_IN_P IS
                    BEGIN
                         SELECT
                              ACCEPT HERE(NUM : IN OUT INTEGER) DO
                                   NUM := 0;
                              END HERE;
                         OR
                              TERMINATE;
                         END SELECT;
                    END ALT_TASK_IN_P;
               END P;

          BEGIN -- FUNC.

               BASIC_TASK.HERE(VAL);

               IF VAL /= IDENT_INT (0) THEN
                    FAILED ("INCORRECT RESULTS FROM ENTRY CALL - 1");
               END IF;

               VAL := 1;

               DERIVED_TASK.HERE(VAL);

               IF VAL /= IDENT_INT (0) THEN
                    FAILED ("INCORRECT RESULTS FROM ENTRY CALL - 2");
               END IF;

               VAL := 1;

               ALT_TASK.HERE(VAL);

               IF VAL /= IDENT_INT (0) THEN
                    FAILED ("INCORRECT RESULTS FROM ENTRY CALL - 3");
               END IF;

               VAL := 1;

               IN_TASK.HERE(VAL);

               IF VAL /= IDENT_INT (0) THEN
                    FAILED ("INCORRECT RESULTS FROM ENTRY CALL - 4");
               END IF;

               VAL := 1;

               IF DERIVED_PRIV_TASK'SIZE /= IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR DERIVED_PRIV_TASK'" &
                            "SIZE");
               END IF;

               RETURN TRUE;

          END FUNC;

     FUNCTION NEWFUNC IS NEW FUNC;

     BEGIN
          B := NEWFUNC;
     END;

     RESULT;
END CD2A91D;
