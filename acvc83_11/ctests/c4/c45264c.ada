-- C45264C.ADA

-- CHECK THAT COMPARING ARRAYS OF DIFFERENT LENGTHS DOES NOT RAISE AN
-- EXCEPTION.

-- TBN  7/21/86

WITH REPORT; USE REPORT;
PROCEDURE C45264C IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 10;
     TYPE ARRAY_TYPE_1 IS ARRAY (INT RANGE <>) OF INTEGER;
     TYPE ARRAY_TYPE_2 IS ARRAY (INT RANGE <>, INT RANGE <>) OF INTEGER;
     TYPE ARRAY_TYPE_3 IS ARRAY (INT RANGE <>, INT RANGE <>,
                                               INT RANGE <>) OF INTEGER;

     ARRAY_1 : ARRAY_TYPE_1 (1..5) := (1..5 => 1);
     ARRAY_2 : ARRAY_TYPE_1 (1..7) := (1..7 => 1);
     ARRAY_3 : ARRAY_TYPE_2 (1..5, 1..4) := (1..5 => (1..4 => 1));
     ARRAY_4 : ARRAY_TYPE_2 (1..2, 1..3) := (1..2 => (1..3 => 1));
     ARRAY_5 : ARRAY_TYPE_3 (1..2, 1..3, 1..2) := (1..2 => (1..3 =>
                                                  (1..2 => 2)));
     ARRAY_6 : ARRAY_TYPE_3 (1..1, 1..2, 1..3) := (1..1 => (1..2 =>
                                                  (1..3 => 2)));
     ARRAY_7 : ARRAY_TYPE_2 (1..5, 1..4) := (1..5 => (1..4 => 3));
     ARRAY_8 : ARRAY_TYPE_2 (1..5, 1..3) := (1..5 => (1..3 => 3));
     ARRAY_9 : ARRAY_TYPE_2 (1..3, 1..2) := (1..3 => (1..2 => 4));
     ARRAY_10 : ARRAY_TYPE_2 (1..2, 1..2) := (1..2 => (1..2 => 4));

BEGIN
     TEST ("C45264C", "CHECK THAT COMPARING ARRAYS OF DIFFERENT " &
                      "LENGTHS DOES NOT RAISE AN EXCEPTION");

     BEGIN     -- (A)
          IF "=" (ARRAY_1 (1..INTEGER'FIRST), ARRAY_2) THEN
               FAILED ("INCORRECT RESULTS FROM COMPARING ONE " &
                       "DIMENSIONAL ARRAYS - 1");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED EVALUATING - 1");
     END;     -- (A)

     BEGIN     -- (B)
          IF ARRAY_1 /= ARRAY_2 THEN
               NULL;
          ELSE
               FAILED ("INCORRECT RESULTS FROM COMPARING ONE " &
                       "DIMENSIONAL ARRAYS - 2");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED EVALUATING - 2");
     END;     -- (B)

     BEGIN     -- (C)
          IF ARRAY_3 = ARRAY_4 THEN
               FAILED ("INCORRECT RESULTS FROM COMPARING MULTI-" &
                       "DIMENSIONAL ARRAYS - 3");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED EVALUATING - 3");
     END;     -- (C)

     BEGIN     -- (D)
          IF "/=" (ARRAY_3, ARRAY_4) THEN
               NULL;
          ELSE
               FAILED ("INCORRECT RESULTS FROM COMPARING MULT-" &
                       "DIMENSIONAL ARRAYS - 4");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - 4");
     END;     -- (D)

     BEGIN     -- (E)
          IF "=" (ARRAY_5, ARRAY_6) THEN
               FAILED ("INCORRECT RESULTS FROM COMPARING MULTI-" &
                       "DIMENSIONAL ARRAYS - 5");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED EVALUATING - 5");
     END;     -- (E)

     BEGIN     -- (F)
          IF ARRAY_6 /= ARRAY_5 THEN
               NULL;
          ELSE
               FAILED ("INCORRECT RESULTS FROM COMPARING MULT-" &
                       "DIMENSIONAL ARRAYS - 6");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - 6");
     END;     -- (F)

     BEGIN     -- (G)
          IF ARRAY_7 = ARRAY_8 THEN
               FAILED ("INCORRECT RESULTS FROM COMPARING MULTI-" &
                       "DIMENSIONAL ARRAYS - 7");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED EVALUATING - 7");
     END;     -- (G)

     BEGIN     -- (H)
          IF ARRAY_9 /= ARRAY_10 THEN
               NULL;
          ELSE
               FAILED ("INCORRECT RESULTS FROM COMPARING MULTI-" &
                       "DIMENSIONAL ARRAYS - 8");
          END IF;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED EVALUATING - 8");
     END;     -- (H)

     RESULT;
END C45264C;
