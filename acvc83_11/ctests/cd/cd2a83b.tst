-- CD2A83B.TST

-- OBJECTIVE:
--     CHECK THAT WHEN SIZE AND COLLECTION SIZE SPECIFICATIONS
--     ARE GIVEN FOR AN ACCESS TYPE IN GENERIC PROCEDURES,
--     THEN OPERATIONS ON VALUES OF SUCH A TYPE ARE NOT
--     AFFECTED BY THE REPRESENTATION CLAUSES.

-- HISTORY:
--     JET 09/01/87  CREATED ORIGINAL TEST.
--     DHH 04/11/89  CHANGED OPERATOR ON 'SIZE CHECKS AND REMOVED
--                   APPLICABILITY CRITERIA.

--     $ACC_SIZE IS THE SIZE IN BITS FOR AN ACCESS VARAIBLE WHOSE
--     DESIGNATED TYPE IS A STRING TYPE.

WITH REPORT;  USE REPORT;

PROCEDURE CD2A83B IS

     BASIC_SIZE : CONSTANT := $ACC_SIZE;
     COLL_SIZE : CONSTANT := 256;

BEGIN

     TEST ("CD2A83B", "CHECK THAT WHEN SIZE AND COLLECTION SIZE " &
                      "SPECIFICATIONS ARE GIVEN FOR AN ACCESS " &
                      "TYPE IN GENERIC PROCEDURES, THEN OPERATIONS " &
                      "ON VALUES OF SUCH A TYPE ARE NOT AFFECTED " &
                      "BY THE REPRESENTATION CLAUSES");

     DECLARE -- SIZE SPECIFICATION GIVEN WITHIN GENERIC PROCEDURE.

          GENERIC
          PROCEDURE GENPROC;

          PROCEDURE GENPROC IS

               TYPE CHECK_ACC IS ACCESS STRING;

               FOR CHECK_ACC'STORAGE_SIZE USE COLL_SIZE;

               FOR CHECK_ACC'SIZE USE BASIC_SIZE;

               SUBTYPE SUB_CHECK IS
                    CHECK_ACC (IDENT_INT(1) .. IDENT_INT(3));

               A0 : CHECK_ACC := NULL;
               A1 : CHECK_ACC := NULL;
               A2 : CHECK_ACC := NULL;
               A3 : CHECK_ACC := NULL;

          BEGIN -- GENPROC.

               IF CHECK_ACC'SIZE /= IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR CHECK_ACC'SIZE");
               END IF;

               IF CHECK_ACC'STORAGE_SIZE < IDENT_INT (COLL_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR " &
                            "CHECK_ACC'STORAGE_SIZE");
               END IF;

               IF A1'SIZE < IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR A1'SIZE");
               END IF;

               A1 := NEW STRING (1 .. 3);
               A2 := NEW STRING'("BLUE");
               A3 := A1;

               A1.ALL := IDENT_STR ("RED");

               IF NOT ((A1 = A3) AND (A1 /= A2)) THEN
                    FAILED ("INCORRECT RESULTS FOR RELATIONAL " &
                            "OPERATORS");
               END IF;

               IF (A1 NOT IN SUB_CHECK) OR (A2 IN SUB_CHECK) THEN
                    FAILED ("INCORRECT RESULTS FOR MEMBERSHIP " &
                            "OPERATORS");
               END IF;

               IF NOT ((A1.ALL = IDENT_STR ("RED"))  AND
                       (A2.ALL = IDENT_STR ("BLUE")) AND
                       (A3.ALL = IDENT_STR ("RED"))) THEN
                    FAILED ("INCORRECT ACCESS TO OBJECTS");
               END IF;

               IF A1 (3) /= IDENT_CHAR ('D') OR
                  A2 (2) /= IDENT_CHAR ('L') THEN
                    FAILED ("INCORRECT ACCESS TO ARRAY INDICES");
               END IF;

               IF A1 (1 .. 3) /= IDENT_STR ("RED") OR
                  A2 (2 .. 3) /= IDENT_STR ("LU")  THEN
                    FAILED ("INCORRECT ACCESS TO ARRAY SLICES");
               END IF;

               IF NOT (A1'FIRST = 1 AND A2'FIRST = 1) THEN
                    FAILED ("INCORRECT VALUE OF ATTRIBUTE FIRST");
               END IF;

               IF NOT (A1'LAST = 3 AND A2'LAST = 4) THEN
                    FAILED ("INCORRECT VALUE OF ATTRIBUTE LAST");
               END IF;

               IF NOT (A1 (A1'RANGE) = IDENT_STR ("RED")   AND
                       A2 (A2'RANGE) = IDENT_STR ("BLUE")) THEN
                    FAILED ("INCORRECT VALUE OF ATTRIBUTE RANGE");
               END IF;

               IF NOT (A1'LENGTH = 3 AND A2'LENGTH = 4) THEN
                    FAILED ("INCORRECT VALUE OF ATTRIBUTE LENGTH");
               END IF;

          END GENPROC;

          PROCEDURE NEWPROC IS NEW GENPROC;

     BEGIN

          NEWPROC;

     END;

     RESULT;

END CD2A83B;
