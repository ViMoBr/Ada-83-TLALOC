-- C45672A.ADA

-- CHECK THAT "NOT" YIELDS THE CORRECT RESULTS WHEN APPLIED TO
-- ONE-DIMENSIONAL BOOLEAN ARRAYS.

-- JWC 11/15/85

WITH REPORT;USE REPORT;

PROCEDURE C45672A IS
BEGIN

     TEST ("C45672A", "CHECK THE UNARY OPERATOR 'NOT' APPLIED TO " &
                      "ONE-DIMENSIONAL BOOLEAN ARRAYS");

     DECLARE

          TYPE ARR1 IS ARRAY (INTEGER RANGE 1 .. 4) OF BOOLEAN;
          TYPE ARR2 IS ARRAY (INTEGER RANGE 1 .. 40) OF BOOLEAN;
          TYPE ARR3 IS ARRAY (INTEGER RANGE <>) OF BOOLEAN;
          TYPE ARR4 IS ARRAY (INTEGER RANGE 1 .. 4) OF BOOLEAN;
          TYPE ARR5 IS ARRAY (INTEGER RANGE 1 .. 40) OF BOOLEAN;

          PRAGMA PACK (ARR4);
          PRAGMA PACK (ARR5);

          A1 : ARR1 := ARR1'(1 | 3 => TRUE, OTHERS => FALSE);
          A2 : ARR2 := ARR2'(1 | 14 .. 18 | 30 .. 33 | 35 .. 37 => TRUE,
                             OTHERS => FALSE);
          A3 : ARR3(IDENT_INT(3) .. IDENT_INT(4)) := ARR3'(TRUE, FALSE);
          A4 : ARR4 := ARR4'(1 | 3 => TRUE, OTHERS => FALSE);
          A5 : ARR5 := ARR5'(1 | 14 .. 18 | 30 .. 33 | 35 .. 37 => TRUE,
                             OTHERS => FALSE);
          A6 : ARR3 (IDENT_INT(9) .. IDENT_INT(7));

          PROCEDURE P (A : ARR3; F : INTEGER; L : INTEGER) IS
          BEGIN
               IF A'FIRST /= F OR A'LAST /= L THEN
                    FAILED ("'NOT' YIELDED THE WRONG BOUNDS");
               END IF;
          END P;

     BEGIN

          P (NOT A3, 3, 4);
          P (NOT A6, 9, 7);

          IF NOT A1 /= ARR1'(1 | 3 => FALSE, OTHERS => TRUE) THEN
               FAILED ("WRONG RESULT WHEN 'NOT' APPLIED " &
                       "TO SMALL ARRAY");
          END IF;

          IF NOT A2 /= ARR2'(1 | 14 .. 18 | 30 .. 33 | 35 .. 37
                             => FALSE, OTHERS => TRUE) THEN
               FAILED ("WRONG RESULT WHEN 'NOT' APPLIED " &
                       "TO LARGE ARRAY");
          END IF;

          IF NOT A4 /= ARR4'(1 | 3 => FALSE, OTHERS => TRUE) THEN
               FAILED ("WRONG RESULT WHEN 'NOT' APPLIED " &
                       "TO SMALL PACKED ARRAY");
          END IF;

          IF NOT A5 /= ARR5'(1 | 14 .. 18 | 30 .. 33 | 35 .. 37
                             => FALSE, OTHERS => TRUE) THEN
               FAILED ("WRONG RESULT WHEN 'NOT' APPLIED " &
                       "TO LARGE PACKED ARRAY");
          END IF;

          IF "NOT" (RIGHT => A1) /= ARR1'(1 | 3 => FALSE,
                                          OTHERS => TRUE) THEN
               FAILED ("WRONG RESULT WHEN 'NOT' APPLIED " &
                       "TO SMALL ARRAY USING NAMED NOTATION");
          END IF;

          IF "NOT" (RIGHT => A5) /= ARR5'(1 | 14 .. 18 | 30 .. 33 |
                                          35 .. 37 => FALSE,
                                          OTHERS => TRUE) THEN
               FAILED ("WRONG RESULT WHEN 'NOT' APPLIED TO LARGE " &
                       "PACKED ARRAY USING NAMED NOTATION");
          END IF;

     END;

     RESULT;

END C45672A;
