-- C45411D.ADA

-- OBJECTIVE:
--     CHECK THAT UNARY "+" AND "-" YIELD CORRECT RESULTS FOR
--     OPERANDS OF DERIVED INTEGER TYPES.

-- HISTORY:
--     JET 07/11/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C45411D IS

     TYPE INT IS RANGE -100..100;

     TYPE DT1 IS NEW INTEGER;
     TYPE DT2 IS NEW INT;

     D1 : DT1 := 1;
     D2 : DT2 := 1;

     FUNCTION IDENT (A : DT1) RETURN DT1 IS
     BEGIN
          RETURN A * DT1(IDENT_INT(1));
     END IDENT;

     FUNCTION IDENT (A : DT2) RETURN DT2 IS
     BEGIN
          RETURN A * DT2(IDENT_INT(1));
     END IDENT;

BEGIN
     TEST ("C45411D", "CHECK THAT UNARY ""+"" AND ""-"" YIELD " &
                      "CORRECT RESULTS FOR OPERANDS OF DERIVED " &
                      "INTEGER TYPES");

     FOR I IN DT1'(1-2)..DT1'(1) LOOP
          IF "-"(RIGHT => D1) /= IDENT(I) THEN
               FAILED ("INCORRECT RESULT FOR ""-"" DT1 -" &
                       DT1'IMAGE(I+2));
          END IF;

          IF +D1 /= IDENT(D1) THEN
               FAILED ("INCORRECT RESULT FOR ""+"" DT1 -" &
                       DT1'IMAGE(I+2));
          END IF;
          D1 := D1 - 1;
     END LOOP;

     IF DT1'LAST + DT1'FIRST = 0 THEN
          IF IDENT(-DT1'LAST) /= DT1'FIRST THEN
               FAILED ("-DT1'LAST IS NOT EQUAL TO DT1'FIRST");
          END IF;
          IF IDENT(-DT1'FIRST) /= DT1'LAST THEN
               FAILED ("-DT1'FIRST IS NOT EQUAL TO DT1'LAST");
          END IF;
     ELSE
          IF IDENT(-DT1'LAST) /= DT1'FIRST+1 THEN
               FAILED ("-DT1'LAST IS NOT EQUAL TO DT1'FIRST+1");
          END IF;
     END IF;

     FOR I IN DT2'(1-2)..DT2'(1) LOOP
          IF -D2 /= IDENT(I) THEN
               FAILED ("INCORRECT RESULT FOR ""-"" DT2 -" &
                       DT2'IMAGE(I+2));
          END IF;

          IF "+"(RIGHT => D2) /= IDENT(D2) THEN
               FAILED ("INCORRECT RESULT FOR ""+"" DT2 -" &
                       DT2'IMAGE(I+2));
          END IF;
          D2 := D2 - 1;
     END LOOP;

     RESULT;

END C45411D;
