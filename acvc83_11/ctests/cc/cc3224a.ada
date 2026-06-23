-- CC3224A.ADA

-- OBJECTIVE:
--     CHECK THAT A FORMAL ARRAY TYPE DENOTES ITS ACTUAL
--     PARAMETER, AND THAT OPERATIONS OF THE FORMAL TYPE ARE THOSE
--     IDENTIFIED WITH THE CORRESPONDING OPERATIONS OF THE ACTUAL TYPE.

-- HISTORY:
--     DHH 09/19/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CC3224A IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 3;
     TYPE ARR IS ARRAY(1 .. 3) OF INTEGER;
     TYPE B_ARR IS ARRAY(1 .. 3) OF BOOLEAN;

     Q : ARR;
     R : B_ARR;
     GENERIC
          TYPE T IS ARRAY(INT) OF INTEGER;
     PACKAGE P IS
          SUBTYPE SUB_T IS T;
          X : SUB_T := (1, 2, 3);
     END P;

     GENERIC
          TYPE T IS ARRAY(INT) OF BOOLEAN;
     PACKAGE BOOL IS
          SUBTYPE SUB_T IS T;
     END BOOL;

BEGIN
     TEST ("CC3224A", "CHECK THAT A FORMAL ARRAY TYPE DENOTES ITS " &
                      "ACTUAL PARAMETER, AND THAT OPERATIONS OF THE " &
                      "FORMAL TYPE ARE THOSE IDENTIFIED WITH THE " &
                      "CORRESPONDING OPERATIONS OF THE ACTUAL TYPE");

     DECLARE

          PACKAGE P1 IS NEW P (ARR);
          USE P1;

          TYPE NEW_T IS NEW SUB_T;
          OBJ_NEWT : NEW_T;
     BEGIN
          IF NEW_T'FIRST /= ARR'FIRST THEN
               FAILED("'FIRST ATTRIBUTE FAILED");
          END IF;
          IF NEW_T'LAST /= ARR'LAST THEN
               FAILED("'LAST ATTRIBUTE FAILED");
          END IF;
          IF NEW_T'FIRST(1) /= ARR'FIRST(1) THEN
               FAILED("'FIRST(N) ATTRIBUTE FAILED");
          END IF;
          IF NOT (NEW_T'LAST(1) = ARR'LAST(1)) THEN
               FAILED("'LAST(N) ATTRIBUTE FAILED");
          END IF;
          IF 2 NOT IN NEW_T'RANGE THEN
               FAILED("'RANGE ATTRIBUTE FAILED");
          END IF;
          IF 3 NOT IN NEW_T'RANGE(1) THEN
               FAILED("'RANGE(N) ATTRIBUTE FAILED");
          END IF;
          IF NEW_T'LENGTH /= ARR'LENGTH THEN
               FAILED("'LENGTH ATTRIBUTE FAILED");
          END IF;
          IF NEW_T'LENGTH(1) /= ARR'LENGTH(1) THEN
               FAILED("'LENGTH(N) ATTRIBUTE FAILED");
           END IF;
          IF ABS(NEW_T'BASE'SIZE) /= ARR'BASE'SIZE THEN
               FAILED("'BASE'SIZE ATTRIBUTE FAILED");
          END IF;

          OBJ_NEWT := (1, 2, 3);
          IF IDENT_INT(3) /= OBJ_NEWT(3) THEN
               FAILED("ASSIGNMENT FAILED");
          END IF;

          IF NEW_T'(1, 2, 3) NOT IN NEW_T THEN
               FAILED("QUALIFIED EXPRESSION FAILED");
          END IF;

          Q := (1, 2, 3);
          IF NEW_T(Q) /= OBJ_NEWT THEN
               FAILED("EXPLICIT CONVERSION FAILED");
          END IF;
          IF Q(1) /= OBJ_NEWT(1) THEN
               FAILED("INDEXING FAILED");
          END IF;
          IF (1, 2) /= OBJ_NEWT(1 .. 2) THEN
               FAILED("SLICE FAILED");
          END IF;
          IF (1, 2) & OBJ_NEWT(3) /= NEW_T(Q)THEN
               FAILED("CATENATION FAILED");
          END IF;
          IF NOT (X IN ARR) THEN
               FAILED ("FORMAL DOES NOT DENOTE ACTUAL");
          END IF;
     END;

     DECLARE

          PACKAGE B1 IS NEW BOOL (B_ARR);
          USE B1;

          TYPE NEW_T IS NEW SUB_T;
          OBJ_NEWT : NEW_T;
     BEGIN

          OBJ_NEWT := (TRUE, TRUE, TRUE);
          R := (TRUE, TRUE, TRUE);

          IF (NEW_T'((TRUE, TRUE, TRUE)) XOR OBJ_NEWT) /=
             NEW_T'((FALSE, FALSE, FALSE)) THEN
               FAILED("XOR FAILED - BOOLEAN");
          END IF;
          IF (NEW_T'((FALSE, FALSE, TRUE)) AND OBJ_NEWT) /=
             NEW_T'((FALSE, FALSE, TRUE)) THEN
               FAILED("AND FAILED - BOOLEAN");
          END IF;
          IF (NEW_T'((FALSE, FALSE, FALSE)) OR OBJ_NEWT) /=
             NEW_T'((TRUE, TRUE, TRUE)) THEN
               FAILED("OR FAILED - BOOLEAN");
          END IF;
     END;

     RESULT;
END CC3224A;
