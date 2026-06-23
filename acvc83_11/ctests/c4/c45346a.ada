-- C45346A.ADA

-- OBJECTIVE:
--     CHECK THAT NUMERIC_ERROR IS NOT RAISED IF THE LENGTH OF THE
--     RESULT OF CATENATION EXCEEDS INTEGER'LAST OR SYSTEM.MAX_INT
--     AND THAT CONSTRAINT_ERROR OR STORAGE_ERROR IS RAISED INSTEAD.

-- HISTORY:
--     JET 01/25/88  CREATED ORIGINAL TEST.

WITH SYSTEM, REPORT; USE SYSTEM, REPORT;
PROCEDURE C45346A IS

     TYPE PTR IS ACCESS BOOLEAN;
     TEST_MAX_INT : BOOLEAN := FALSE;

BEGIN
     TEST("C45346A", "CHECK THAT NUMERIC_ERROR IS NOT RAISED IF " &
                     "THE LENGTH OF THE RESULT OF CATENATION " &
                     "EXCEEDS INTEGER'LAST OR SYSTEM.MAX_INT AND " &
                     "THAT CONSTRAINT_ERROR OR STORAGE_ERROR IS " &
                     "RAISED INSTEAD");

     DECLARE
          TYPE ARR IS ARRAY (INTEGER RANGE <>) OF PTR;
          PRAGMA PACK (ARR);

          FUNCTION IDENT (X : ARR) RETURN ARR IS
          BEGIN
               IF EQUAL (3,3) THEN
                    RETURN X;
               ELSE
                    RETURN (1..2 => NULL);
               END IF;
          END IDENT;

     BEGIN
          DECLARE
               L : INTEGER := IDENT_INT(INTEGER'LAST) / 2 + 1;
               A : ARR(1..L);
          BEGIN
               IF IDENT(A) & A /= A & IDENT(A) THEN
                    FAILED("BAD RESULT FROM CATENATION (1)");
               END IF;

               COMMENT("LENGTH EXCEEDED INTEGER'LAST WITHOUT RAISING " &
                       "EXCEPTION");

               TEST_MAX_INT := TRUE;
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    FAILED ("NUMERIC_ERROR RAISED WHEN LENGTH OF " &
                            "CATENATION EXCEEDED INTEGER'LAST");
               WHEN STORAGE_ERROR | CONSTRAINT_ERROR =>
                    COMMENT ("STORAGE/CONSTRAINT_ERROR RAISED WHEN " &
                             "LENGTH OF CATENATION EXCEEDED " &
                             "INTEGER'LAST");
               WHEN OTHERS =>
                    FAILED("UNEXPECTED EXCEPTION RAISED (1)");
          END;
     EXCEPTION
          WHEN STORAGE_ERROR =>
               NOT_APPLICABLE ("STORAGE_ERROR RAISED WHEN ARRAY OF " &
                               "LENGTH INTEGER'LAST/2 + 1 WAS " &
                               "DECLARED");
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               NOT_APPLICABLE ("NUMERIC/CONSTRAINT_ERROR RAISED WHEN " &
                               "ARRAY OF LENGTH INTEGER'LAST/2 + 1 " &
                               "WAS DECLARED");
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION WHEN ARRAY OF LENGTH " &
                       "INTEGER'LAST/2 + 1 WAS DECLARED");
     END;

     IF TEST_MAX_INT THEN
          DECLARE
               TYPE INT IS RANGE MIN_INT .. MAX_INT;
               TYPE ARR IS ARRAY (INT RANGE <>) OF PTR;
               PRAGMA PACK (ARR);

               FUNCTION IDENT (X : ARR) RETURN ARR IS
               BEGIN
                    IF EQUAL (3,3) THEN
                         RETURN X;
                    ELSE
                         RETURN (1..2 => NULL);
                    END IF;
               END IDENT;

          BEGIN
               DECLARE
                    L : INT := MAX_INT/2 + INT(IDENT_INT(1));
                    A : ARR(1..L);
               BEGIN
                    IF IDENT(A) & A /= A & IDENT(A) THEN
                         FAILED("BAD RESULT FROM CATENATION (2)");
                    END IF;

                    FAILED("LENGTH EXCEEDED SYSTEM.MAX_INT WITHOUT " &
                           "RAISING EXCEPTION");
               EXCEPTION
                    WHEN NUMERIC_ERROR =>
                         FAILED ("NUMERIC_ERROR RAISED WHEN LENGTH " &
                                 "OF CATENATION EXCEEDED SYSTEM." &
                                 "MAX_INT");
                    WHEN STORAGE_ERROR | CONSTRAINT_ERROR =>
                         COMMENT ("STORAGE/CONSTRAINT_ERROR RAISED " &
                                  "WHEN LENGTH OF CATENATION " &
                                  "EXCEEDED SYSTEM.MAX_INT");
                    WHEN OTHERS =>
                         FAILED("UNEXPECTED EXCEPTION RAISED WHEN " &
                                "LENGTH OF CATENATION EXCEEDED " &
                                "SYSTEM.MAX_INT");
               END;
          EXCEPTION
               WHEN STORAGE_ERROR =>
                    COMMENT ("STORAGE_ERROR RAISED WHEN " &
                             "ARRAY OF LENGTH SYSTEM.MAX_INT/2 + 1 " &
                             "WAS DECLARED");
               WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
                    COMMENT ("NUMERIC/CONSTRAINT_ERROR RAISED WHEN " &
                             "ARRAY OF LENGTH SYSTEM.MAX_INT/2 + 1 " &
                             "WAS DECLARED");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION WHEN ARRAY OF LEN" &
                            "GTH SYSTEM.MAX_INT/2 + 1 WAS DECLARED");
          END;
     END IF;

     RESULT;
END C45346A;
