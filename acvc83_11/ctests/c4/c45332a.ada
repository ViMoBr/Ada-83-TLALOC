-- C45332A.ADA

-- OBJECTIVE:
--     CHECK WHETHER, FOR FIXED POINT TYPES, NUMERIC_ERROR OR
--     CONSTRAINT_ERROR IS RAISED IF 'MACHINE_OVERFLOWS IS TRUE AND
--     THE RESULT OF ADDITION OR SUBTRACTION LIES OUTSIDE THE RANGE
--     OF THE BASE TYPE.

-- HISTORY:
--     WRG  9/10/86  CREATED ORIGINAL TEST.
--     RJW 11/13/87  MODIFIED CODE SO THAT THE TEST DOES NOT REPORT
--                   "FAILED" IF A WIDER RANGE IS CHOSEN FOR THE
--                   FIXED-POINT CALCULATIONS.

WITH REPORT; USE REPORT;
PROCEDURE C45332A IS

     -- THE NAME OF EACH TYPE OR SUBTYPE ENDS WITH THAT TYPE'S
     -- 'MANTISSA VALUE.

BEGIN

     TEST ("C45332A", "CHECK WHETHER, FOR FIXED POINT TYPES, " &
                      "NUMERIC_ERROR OR CONSTRAINT_ERROR IS RAISED " &
                      "IF 'MACHINE_OVERFLOWS IS TRUE AND THE " &
                      "RESULT OF ADDITION OR SUBTRACTION LIES " &
                      "OUTSIDE THE RANGE OF THE BASE TYPE");

     -------------------------------------------------------------------

A:   DECLARE
          TYPE LIKE_DURATION_M23 IS DELTA 0.020
               RANGE -86_400.0 .. 86_400.0;
          TYPE LIKE_DURATION_M23_BASE IS
               DELTA LIKE_DURATION_M23'SAFE_SMALL
               RANGE -LIKE_DURATION_M23'SAFE_LARGE ..
                      LIKE_DURATION_M23'SAFE_LARGE;

          MAX : LIKE_DURATION_M23_BASE := 0.5;
          X   : LIKE_DURATION_M23_BASE := 0.0;
     BEGIN
          COMMENT ("LIKE_DURATION_M23_BASE'MACHINE_OVERFLOWS IS " &
                   BOOLEAN'IMAGE (LIKE_DURATION_M23_BASE'
                                  MACHINE_OVERFLOWS));

          COMMENT ("LIKE_DURATION_M23_BASE'MANTISSA =" &
                   POSITIVE'IMAGE (LIKE_DURATION_M23_BASE'MANTISSA));

          -- INITIALIZE "CONSTANTS":
          IF EQUAL (3, 3) THEN
               MAX := LIKE_DURATION_M23_BASE'LAST;
          END IF;

          BEGIN
               IF EQUAL (3, 3) THEN
                    X := MAX;
               END IF;
               IF (X + MAX) * IDENT_INT (0) /= 0.0 THEN
                    FAILED ("<EXPRESSION IN A> * 0 /= 0.0");
               END IF;
               IF LIKE_DURATION_M23_BASE'MACHINE_OVERFLOWS THEN
                    COMMENT ("NO EXCEPTION RAISED FOR ADDITION " &
                            "RESULT NOT IN BASE TYPE'S RANGE, AND " &
                            "'MACHINE_OVERFLOWS IS TRUE - A");
               ELSE
                    COMMENT ("NO EXCEPTION RAISED FOR ADDITION " &
                             "RESULT NOT IN BASE TYPE'S RANGE, AND " &
                             "'MACHINE_OVERFLOWS IS FALSE - A");
               END IF;
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    COMMENT ("NUMERIC_ERROR RAISED FOR ADDITION " &
                             "RESULT NOT IN BASE TYPE'S RANGE - A");
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("CONSTRAINT_ERROR RAISED FOR ADDITION " &
                             "RESULT NOT IN BASE TYPE'S RANGE - A");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED FOR ADDITION " &
                            "RESULT NOT IN BASE TYPE'S RANGE - A");
          END;

     END A;

     -------------------------------------------------------------------

B:   DECLARE

          TYPE DECIMAL_M4 IS DELTA 100.0 RANGE -1000.0 .. 1000.0;
          TYPE DECIMAL_M4_BASE IS DELTA DECIMAL_M4'SAFE_SMALL
               RANGE -DECIMAL_M4'SAFE_LARGE .. DECIMAL_M4'SAFE_LARGE;

          MAX, MIN : DECIMAL_M4_BASE := 256.0;
          X        : DECIMAL_M4_BASE :=   0.0;
     BEGIN
          COMMENT ("DECIMAL_M4_BASE'MACHINE_OVERFLOWS IS " &
                   BOOLEAN'IMAGE (DECIMAL_M4_BASE'MACHINE_OVERFLOWS));

          COMMENT ("DECIMAL_M4_BASE'MANTISSA =" &
                   POSITIVE'IMAGE (DECIMAL_M4_BASE'MANTISSA));

          -- INITIALIZE "CONSTANTS":
          IF EQUAL (3, 3) THEN
               MAX := DECIMAL_M4_BASE'LAST;
               MIN := DECIMAL_M4_BASE'FIRST;
          END IF;

          BEGIN
               IF EQUAL (3, 3) THEN
                    X := MIN;
               END IF;
               IF (X - MAX) * IDENT_INT (0) /= 0.0 THEN
                    FAILED ("<EXPRESSION IN B> * 0 /= 0.0");
               END IF;
               IF DECIMAL_M4_BASE'MACHINE_OVERFLOWS THEN
                    COMMENT ("NO EXCEPTION RAISED FOR SUBTRACTION " &
                            "RESULT NOT IN BASE TYPE'S RANGE, AND " &
                            "'MACHINE_OVERFLOWS IS TRUE - B");
               ELSE
                    COMMENT ("NO EXCEPTION RAISED FOR SUBTRACTION " &
                             "RESULT NOT IN BASE TYPE'S RANGE, AND " &
                             "'MACHINE_OVERFLOWS IS FALSE - B");
               END IF;
          EXCEPTION
               WHEN NUMERIC_ERROR =>
                    COMMENT ("NUMERIC_ERROR RAISED FOR SUBTRACTION " &
                             "RESULT NOT IN BASE TYPE'S RANGE - B");
               WHEN CONSTRAINT_ERROR =>
                    COMMENT ("CONSTRAINT_ERROR RAISED FOR SUBTRACTION "&
                             "RESULT NOT IN BASE TYPE'S RANGE - B");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED FOR SUBTRACTION " &
                            "RESULT NOT IN BASE TYPE'S RANGE - B");
          END;

     END B;

     -------------------------------------------------------------------

     RESULT;

END C45332A;
