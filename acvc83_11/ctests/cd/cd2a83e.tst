-- CD2A83E.TST

-- OBJECTIVE:
--     CHECK THAT WHEN SIZE AND COLLECTION SIZE SPECIFICATIONS ARE
--     GIVEN FOR AN ACCESS TYPE IN GENERIC PROCEDURES, THEN
--     SUCH A TYPE CAN BE PASSED AS AN ACTUAL PARAMETER TO
--     GENERIC PROCEDURES.

-- HISTORY:
--     JET 09/02/87  CREATED ORIGINAL TEST.
--     DHH 04/11/89  CHANGED OPERATOR ON 'SIZE CHECKS AND REMOVED
--                   APPLICABILITY CRITERIA.

--     $ACC_SIZE IS THE SIZE IN BITS FOR AN ACCESS VARIABLE WHOSE
--     DESIGNATED TYPE IS A STRING TYPE.

WITH REPORT;  USE REPORT;
PROCEDURE CD2A83E IS

     TYPE BASIC_ACC IS ACCESS STRING;

     BASIC_SIZE : CONSTANT := $ACC_SIZE;
     COLL_SIZE : CONSTANT := 256;

     FOR BASIC_ACC'STORAGE_SIZE USE COLL_SIZE;
     FOR BASIC_ACC'SIZE USE BASIC_SIZE;

BEGIN

     TEST ("CD2A83E", "CHECK THAT WHEN SIZE AND COLLECTION SIZE " &
                      "SPECIFICATIONS ARE GIVEN FOR AN ACCESS " &
                      "TYPE IN GENERIC PROCEDURES, THEN SUCH A " &
                      "TYPE CAN BE PASSED AS AN ACTUAL PARAMETER " &
                      "TO GENERIC PROCEDURES");

     DECLARE -- TYPE DECLARATION WITHIN GENERIC PROCEDURE.

          GENERIC
               TYPE GPARM IS ACCESS STRING;
          PROCEDURE GENPROC;

          PROCEDURE GENPROC IS

               SUBTYPE SUB_CHECK IS
                    GPARM (IDENT_INT(1) .. IDENT_INT(3));

               A0 : GPARM := NULL;
               A1 : GPARM := NULL;
               A2 : GPARM := NULL;
               A3 : GPARM := NULL;

          BEGIN -- GENPROC.

               IF GPARM'SIZE /= IDENT_INT (BASIC_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR GPARM'SIZE");
               END IF;

               IF GPARM'STORAGE_SIZE < IDENT_INT (COLL_SIZE) THEN
                    FAILED ("INCORRECT VALUE FOR GPARM'STORAGE_SIZE");
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

          PROCEDURE NEWPROC IS NEW GENPROC (BASIC_ACC);

     BEGIN

          NEWPROC;

     END;

     RESULT;

END CD2A83E;
