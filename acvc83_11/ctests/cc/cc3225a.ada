-- CC3225A.ADA

-- OBJECTIVE:
--     CHECK THAT A FORMAL ACCESS TYPE DENOTES ITS ACTUAL
--     PARAMETER, AND THAT OPERATIONS OF THE FORMAL TYPE ARE THOSE
--     IDENTIFIED WITH THE CORRESPONDING OPERATIONS OF THE ACTUAL TYPE.

-- HISTORY:
--     DHH 10/21/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CC3225A IS

     GENERIC
          TYPE NODE IS PRIVATE;
          TYPE T IS ACCESS NODE;
     PACKAGE P IS
          SUBTYPE SUB_T IS T;
          PAC_VAR : SUB_T;
     END P;

BEGIN
     TEST ("CC3225A", "CHECK THAT A FORMAL ACCESS TYPE DENOTES ITS " &
                      "ACTUAL PARAMETER, AND THAT OPERATIONS OF THE " &
                      "FORMAL TYPE ARE THOSE IDENTIFIED WITH THE " &
                      "CORRESPONDING OPERATIONS OF THE ACTUAL TYPE");

     DECLARE
          SUBTYPE INT IS INTEGER RANGE 1 .. 3;
          TYPE ARR IS ARRAY(1 .. 3) OF INTEGER;
          TYPE ACC_ARR IS ACCESS ARR;

          Q : ACC_ARR := NEW ARR;

          PACKAGE P1 IS NEW P (ARR, ACC_ARR);
          USE P1;

     BEGIN
          PAC_VAR := NEW ARR'(1, 2, 3);
          IF PAC_VAR'FIRST /= Q'FIRST THEN
               FAILED("'FIRST ATTRIBUTE FAILED");
          END IF;
          IF PAC_VAR'LAST /= Q'LAST THEN
               FAILED("'LAST ATTRIBUTE FAILED");
          END IF;
          IF PAC_VAR'FIRST(1) /= Q'FIRST(1) THEN
               FAILED("'FIRST(N) ATTRIBUTE FAILED");
          END IF;
          IF NOT (PAC_VAR'LAST(1) = Q'LAST(1)) THEN
               FAILED("'LAST(N) ATTRIBUTE FAILED");
          END IF;
          IF 2 NOT IN PAC_VAR'RANGE THEN
               FAILED("'RANGE ATTRIBUTE FAILED");
          END IF;
          IF 3 NOT IN PAC_VAR'RANGE(1) THEN
               FAILED("'RANGE(N) ATTRIBUTE FAILED");
          END IF;
          IF PAC_VAR'LENGTH /= Q'LENGTH THEN
               FAILED("'LENGTH ATTRIBUTE FAILED");
          END IF;
          IF PAC_VAR'LENGTH(1) /= Q'LENGTH(1) THEN
               FAILED("'LENGTH(N) ATTRIBUTE FAILED");
           END IF;
          IF ABS(SUB_T'BASE'SIZE) /= ACC_ARR'BASE'SIZE THEN
               FAILED("'BASE'SIZE ATTRIBUTE FAILED");
          END IF;

          PAC_VAR.ALL := (1, 2, 3);
          IF IDENT_INT(3) /= PAC_VAR(3) THEN
               FAILED("ASSIGNMENT FAILED");
          END IF;

          IF SUB_T'(PAC_VAR) NOT IN SUB_T THEN
               FAILED("QUALIFIED EXPRESSION FAILED");
          END IF;

          Q.ALL := PAC_VAR.ALL;
          IF SUB_T(Q) = PAC_VAR THEN
               FAILED("EXPLICIT CONVERSION FAILED");
          END IF;
          IF Q(1) /= PAC_VAR(1) THEN
               FAILED("INDEXING FAILED");
          END IF;
          IF (1, 2) /= PAC_VAR(1 .. 2) THEN
               FAILED("SLICE FAILED");
          END IF;
          IF (1, 2) & PAC_VAR(3) /= PAC_VAR.ALL THEN
               FAILED("CATENATION FAILED");
          END IF;
     END;

     DECLARE
          TASK TYPE TSK IS
               ENTRY ONE;
          END TSK;

          GENERIC
               TYPE T IS ACCESS TSK;
          PACKAGE P IS
               SUBTYPE SUB_T IS T;
               PAC_VAR : SUB_T;
          END P;

          TYPE ACC_TSK IS ACCESS TSK;

          PACKAGE P1 IS NEW P(ACC_TSK);
          USE P1;

          GLOBAL : INTEGER := 5;

          TASK BODY TSK IS
          BEGIN
               ACCEPT ONE DO
                    GLOBAL := 1;
               END ONE;
          END;
     BEGIN
          PAC_VAR := NEW TSK;
          PAC_VAR.ONE;
          IF GLOBAL /= 1 THEN
               FAILED("TASK ENTRY SELECTION FAILED");
          END IF;
     END;

     DECLARE
          TYPE REC IS
               RECORD
                    I : INTEGER;
                    B : BOOLEAN;
               END RECORD;

          TYPE ACC_REC IS ACCESS REC;

          PACKAGE P1 IS NEW P (REC, ACC_REC);
          USE P1;

     BEGIN
          PAC_VAR := NEW REC'(4, (PAC_VAR IN ACC_REC));
          IF PAC_VAR.I /= IDENT_INT(4) AND NOT PAC_VAR.B THEN
               FAILED("RECORD COMPONENT SELECTION FAILED");
          END IF;
     END;

     DECLARE
          TYPE REC(B : BOOLEAN := FALSE) IS
               RECORD
                    NULL;
               END RECORD;

          TYPE ACC_REC IS ACCESS REC;

          PACKAGE P1 IS NEW P (REC, ACC_REC);
          USE P1;

     BEGIN
          PAC_VAR := NEW REC'(B => PAC_VAR IN ACC_REC);
          IF NOT PAC_VAR.B THEN
               FAILED("DISCRIMINANT SELECTION FAILED");
          END IF;
     END;

     RESULT;
END CC3225A;
