-- C45114A.ADA

-- OBJECTIVE:
--     CHECK THAT THE LOGICAL OPERATORS ARE DEFINED FOR BOOLEAN ARRAYS
--     HAVING BOTH INTEGER'LAST COMPONENTS AND MORE THAN INTEGER'LAST
--     COMPONENTS.

-- HISTORY:
--     RJW  9/22/88  CREATED ORIGINAL TEST.

WITH  REPORT; USE REPORT;
PROCEDURE  C45114A  IS

     LEFT1 : INTEGER := IDENT_INT (INTEGER'LAST - 3);
     RIGHT1 : INTEGER := IDENT_INT (INTEGER'LAST);
     LEFT2 : INTEGER := IDENT_INT (1);
     RIGHT2 : INTEGER := IDENT_INT (4);
BEGIN

     TEST("C45114A", "CHECK THAT THE LOGICAL OPERATORS ARE " &
                     "DEFINED FOR BOOLEAN ARRAYS HAVING BOTH " &
                     "INTEGER'LAST COMPONENTS AND MORE THAN " &
                     "INTEGER'LAST COMPONENTS");

     BEGIN
          DECLARE

               TYPE ARR IS ARRAY (1 .. INTEGER'LAST) OF BOOLEAN;

          BEGIN
               DECLARE
                    A : ARR;
               BEGIN
                    A (LEFT1 .. RIGHT1) := (TRUE, TRUE, FALSE, FALSE);
                    A (LEFT2 .. RIGHT2) := (IDENT_BOOL (TRUE),
                                            IDENT_BOOL (FALSE),
                                            IDENT_BOOL (TRUE),
                                            IDENT_BOOL (FALSE));

                    IF (A (LEFT1 .. RIGHT1) AND A (LEFT2 .. RIGHT2)) /=
                       (TRUE, FALSE, FALSE, FALSE)
                         THEN
                         FAILED ("'AND' NOT CORRECTLY DEFINED " &
                                 "FOR ARRAYS HAVING INTEGER'LAST " &
                                 "COMPONENTS");
                    END IF;

                    IF (A (LEFT1 .. RIGHT1) OR A (LEFT2 .. RIGHT2)) /=
                       (TRUE, TRUE, TRUE, FALSE)
                         THEN
                         FAILED ("'OR' NOT CORRECTLY DEFINED " &
                                 "FOR ARRAYS HAVING INTEGER'LAST " &
                                 "COMPONENTS");
                    END IF;

                    IF (A (LEFT1 .. RIGHT1) XOR A (LEFT2 .. RIGHT2)) /=
                       (FALSE, TRUE, TRUE, FALSE)
                         THEN
                         FAILED ("'XOR' NOT CORRECTLY DEFINED " &
                                 "FOR ARRAYS HAVING INTEGER'LAST " &
                                 "COMPONENTS");
                    END IF;

                    IF NOT A (LEFT1 .. RIGHT1) /=
                       (IDENT_BOOL (FALSE),
                        IDENT_BOOL (FALSE), IDENT_BOOL (TRUE),
                        IDENT_BOOL (TRUE)) THEN
                        FAILED ("'NOT' NOT CORRECTLY DEFINED " &
                                "FOR ARRAYS HAVING INTEGER'LAST " &
                                "COMPONENTS");
                    END IF;
               EXCEPTION
                    WHEN NUMERIC_ERROR | CONSTRAINT_ERROR |
                         STORAGE_ERROR =>
                         FAILED ("NUMERIC_ERROR, CONSTRAINT_ERROR, " &
                                 "OR STORAGE_ERROR RAISED INSIDE OF " &
                                 "BLOCK FOR ARRAYS WITH " &
                                 "INTEGER'LAST COMPONENTS");
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED INSIDE OF BLOCK " &
                                 "FOR ARRAYS WITH INTEGER'LAST " &
                                 "COMPONENTS");
               END;
          EXCEPTION
               WHEN STORAGE_ERROR =>
                    COMMENT ("OBJECT DECLARATION OF ARRAYS WITH " &
                             "INTEGER'LAST COMPONENTS RAISES " &
                             "STORAGE_ERROR");
               WHEN NUMERIC_ERROR =>
                    COMMENT ("OBJECT DECLARATION OF ARRAYS WITH " &
                             "INTEGER'LAST COMPONENTS RAISES " &
                             "NUMERIC_ERROR");
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("OBJECT DECLARATION OF ARRAYS WITH " &
                             "INTEGER'LAST COMPONENTS RAISES " &
                             "CONSTRAINT_ERROR");
               WHEN OTHERS =>
                    FAILED  ("OBJECT DECLARATION OF ARRAYS WITH " &
                             "INTEGER'LAST COMPONENTS RAISES " &
                             "WRONG EXCEPTION");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("TYPE DECLARATION OF ARRAYS WITH " &
                        "INTEGER'LAST COMPONENTS RAISES " &
                        "CONSTRAINT_ERROR");
          WHEN NUMERIC_ERROR =>
               COMMENT ("TYPE DECLARATION OF ARRAYS WITH " &
                        "INTEGER'LAST COMPONENTS RAISES " &
                        "NUMERIC_ERROR");
          WHEN OTHERS =>
               FAILED  ("TYPE DECLARATION OF ARRAYS WITH " &
                        "INTEGER'LAST COMPONENTS RAISES " &
                        "WRONG EXCEPTION");
     END;

     BEGIN
          DECLARE

               TYPE ARR IS ARRAY (0 .. INTEGER'LAST) OF BOOLEAN;

          BEGIN
               DECLARE
                    A : ARR;
               BEGIN
                    A (LEFT1 .. RIGHT1) := (TRUE, TRUE, FALSE, FALSE);
                    A (LEFT2 .. RIGHT2) := (IDENT_BOOL (TRUE),
                                            IDENT_BOOL (FALSE),
                                            IDENT_BOOL (TRUE),
                                            IDENT_BOOL (FALSE));

                    IF (A (LEFT1 .. RIGHT1) AND A (LEFT2 .. RIGHT2)) /=
                       (TRUE, FALSE, FALSE, FALSE)
                         THEN
                         FAILED ("'AND' NOT CORRECTLY DEFINED " &
                                 "FOR ARRAYS HAVING MORE THAN " &
                                 "INTEGER'LAST COMPONENTS");
                    END IF;

                    IF (A (LEFT1 .. RIGHT1) OR A (LEFT2 .. RIGHT2)) /=
                       (TRUE, TRUE, TRUE, FALSE)
                         THEN
                         FAILED ("'OR' NOT CORRECTLY DEFINED " &
                                 "FOR ARRAYS HAVING MORE THAN " &
                                 "INTEGER'LAST COMPONENTS");
                    END IF;

                    IF (A (LEFT1 .. RIGHT1) XOR A (LEFT2 .. RIGHT2)) /=
                       (FALSE, TRUE, TRUE, FALSE)
                         THEN
                         FAILED ("'XOR' NOT CORRECTLY DEFINED " &
                                 "FOR ARRAYS HAVING MORE THAN " &
                                 "INTEGER'LAST COMPONENTS");
                    END IF;

                    IF NOT A (LEFT1 .. RIGHT1) /=
                       (IDENT_BOOL (FALSE),
                        IDENT_BOOL (FALSE), IDENT_BOOL (TRUE),
                        IDENT_BOOL (TRUE)) THEN
                        FAILED ("'NOT' NOT CORRECTLY DEFINED " &
                                "FOR ARRAYS MORE THAN " &
                                "INTEGER'LAST COMPONENTS");
                    END IF;
               EXCEPTION
                    WHEN NUMERIC_ERROR | CONSTRAINT_ERROR |
                         STORAGE_ERROR =>
                         FAILED ("NUMERIC_ERROR, CONSTRAINT_ERROR, " &
                                 "OR STORAGE_ERROR RAISED INSIDE " &
                                 "OF BLOCK FOR ARRAYS WITH MORE " &
                                 "THAN INTEGER'LAST COMPONENTS");
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED INSIDE OF BLOCK " &
                                 "FOR ARRAYS WITH MORE THAN " &
                                 "INTEGER'LAST COMPONENTS");
               END;
          EXCEPTION
               WHEN STORAGE_ERROR =>
                    COMMENT ("OBJECT DECLARATION OF ARRAYS WITH " &
                             "MORE THAN INTEGER'LAST COMPONENTS " &
                             "RAISES STORAGE_ERROR");
               WHEN NUMERIC_ERROR =>
                    COMMENT ("OBJECT DECLARATION OF ARRAYS WITH " &
                             "MORE THAN INTEGER'LAST COMPONENTS " &
                             "RAISES NUMERIC_ERROR");
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("OBJECT DECLARATION OF ARRAYS WITH " &
                             "MORE THAN INTEGER'LAST COMPONENTS " &
                             "RAISES CONSTRAINT_ERROR");
               WHEN OTHERS =>
                    FAILED  ("OBJECT DECLARATION OF ARRAYS WITH " &
                             "MORE THAN INTEGER'LAST COMPONENTS " &
                             "RAISES WRONG EXCEPTION");
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("TYPE DECLARATION OF ARRAYS WITH " &
                        "MORE THAN INTEGER'LAST COMPONENTS RAISES " &
                        "CONSTRAINT_ERROR");
          WHEN NUMERIC_ERROR =>
               COMMENT ("TYPE DECLARATION OF ARRAYS WITH " &
                        "MORE THAN INTEGER'LAST COMPONENTS RAISES " &
                        "NUMERIC_ERROR");
          WHEN OTHERS =>
               FAILED  ("TYPE DECLARATION OF ARRAYS WITH " &
                        "MORE THAN INTEGER'LAST COMPONENTS RAISES " &
                        "WRONG EXCEPTION");
     END;

     RESULT;
END C45114A;
