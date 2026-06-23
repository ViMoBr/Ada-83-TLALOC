-- C45411A.ADA

-- OBJECTIVE:
--     CHECK THAT UNARY "+" AND "-" YIELD CORRECT RESULTS FOR
--     PREDEFINED INTEGER OPERANDS.

-- HISTORY:
--     JET 01/25/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C45411A IS

     TYPE DT IS NEW INTEGER RANGE -3..3;
     I1 : INTEGER := 1;
     D1 : DT := 1;

BEGIN
     TEST ("C45411A", "CHECK THAT UNARY ""+"" AND ""-"" YIELD " &
                      "CORRECT RESULTS FOR PREDEFINED INTEGER " &
                      "OPERANDS");

     FOR I IN (1-2)..INTEGER(1) LOOP
          IF "-"(RIGHT => I1) /= IDENT_INT(I) THEN
               FAILED ("INCORRECT RESULT FOR ""-"" -" &
                       INTEGER'IMAGE(I+2));
          END IF;

          IF +I1 /= IDENT_INT(I1) THEN
               FAILED ("INCORRECT RESULT FOR ""+"" -" &
                       INTEGER'IMAGE(I+2));
          END IF;
          I1 := I1 - 1;
     END LOOP;

     FOR I IN (1-2)..INTEGER(1) LOOP
          IF -I /= IDENT_INT(0)-I THEN
               FAILED ("INCORRECT RESULT FOR ""-"" -" &
                       INTEGER'IMAGE(I+5));
          END IF;

          IF "+"(RIGHT => IDENT_INT(I)) /= I THEN
               FAILED ("INCORRECT RESULT FOR ""+"" -" &
                       INTEGER'IMAGE(I+5));
          END IF;
     END LOOP;

     IF -1 /= IDENT_INT(1)-2 THEN
          FAILED ("INCORRECT RESULT FOR ""-"" - 7");
     END IF;

     IF "-"(RIGHT => 0) /= IDENT_INT(0) THEN
          FAILED ("INCORRECT RESULT FOR ""-"" - 8");
     END IF;

     IF "-"(RIGHT => "-"(RIGHT => 1)) /= IDENT_INT(1) THEN
          FAILED ("INCORRECT RESULT FOR ""-"" - 9");
     END IF;

     IF "+"(RIGHT => 1) /= IDENT_INT(2)-1 THEN
          FAILED ("INCORRECT RESULT FOR ""+"" - 7");
     END IF;

     IF +0 /= IDENT_INT(0) THEN
          FAILED ("INCORRECT RESULT FOR ""+"" - 8");
     END IF;

     IF +(-1) /= IDENT_INT(1)-2 THEN
          FAILED ("INCORRECT RESULT FOR ""+"" - 9");
     END IF;

     FOR I IN (1-2)..INTEGER(1) LOOP
          IF "-"(RIGHT => D1) /= DT(IDENT_INT(I)) THEN
               FAILED ("INCORRECT RESULT FOR ""-"" -" &
                       INTEGER'IMAGE(I+11));
          END IF;

          IF +D1 /= DT(IDENT_INT(INTEGER(D1))) THEN
               FAILED ("INCORRECT RESULT FOR ""+"" -" &
                       INTEGER'IMAGE(I+11));
          END IF;
          D1 := D1 - 1;
     END LOOP;

     IF INTEGER'LAST + INTEGER'FIRST = 0 THEN
          IF IDENT_INT(-INTEGER'LAST) /= INTEGER'FIRST THEN
               FAILED ("-INTEGER'LAST IS NOT EQUAL TO INTEGER'FIRST");
          END IF;
          IF IDENT_INT(-INTEGER'FIRST) /= INTEGER'LAST THEN
               FAILED ("-INTEGER'FIRST IS NOT EQUAL TO INTEGER'LAST");
          END IF;
     ELSE
          IF IDENT_INT(-INTEGER'LAST) /= INTEGER'FIRST+1 THEN
               FAILED ("-INTEGER'LAST IS NOT EQUAL TO INTEGER'FIRST+1");
          END IF;
     END IF;

     RESULT;

END C45411A;
