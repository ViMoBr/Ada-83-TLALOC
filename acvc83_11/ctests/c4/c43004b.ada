-- C43004B.ADA

-- OBJECTIVE:
--     CHECK THAT CONSTRAINT_ERROR IS RAISED IF THE BOUNDS SPECIFIED
--     FOR AN ARRAY COMPONENT OF AN AGGREGATE DO NOT EQUAL THE BOUNDS
--     OF THE COMPONENT SUBTYPE'S INDEX RANGE.

-- HISTORY:
--     BCB 07/14/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE C43004B IS

     TYPE SUBINT IS RANGE 1 .. 10;

     ONE : INTEGER := IDENT_INT(1);
     TEN : INTEGER := IDENT_INT(10);

     STWO : INTEGER := IDENT_INT(2);
     SFOUR : INTEGER := IDENT_INT(4);

     TWO : SUBINT := SUBINT(IDENT_INT(INTEGER(2)));
     FOUR : SUBINT := SUBINT(IDENT_INT(INTEGER(4)));

     TYPE OTHER_ARRAY IS ARRAY(SUBINT RANGE <>) OF INTEGER;

     SUBTYPE OA IS OTHER_ARRAY(2..4);

     SUBTYPE OA2 IS OTHER_ARRAY(TWO..FOUR);

     SUBTYPE SUBINTEGER IS INTEGER RANGE ONE .. TEN;

     TYPE OTHER_ARRAY2 IS ARRAY(SUBINTEGER RANGE <>) OF BOOLEAN;

     SUBTYPE OA3 IS OTHER_ARRAY2(2..4);

     SUBTYPE OA4 IS OTHER_ARRAY2(STWO..SFOUR);

     TYPE ARR IS ARRAY(1..1) OF OA;

     TYPE NULL_ARRAY IS ARRAY(1..0) OF OA;

     TYPE ARR2 IS ARRAY(1..1) OF OA2;

     TYPE ARR3 IS ARRAY(1..1) OF OA3;

     TYPE ARR4 IS ARRAY(1..1) OF OA4;

     TYPE REC (D : SUBINT := 4) IS RECORD
          ARR_VAR : OTHER_ARRAY(2..D);
     END RECORD;

     A : ARR;

     B : REC;

     C : ARR2;

     D : NULL_ARRAY;

     E : ARR3;

     F : ARR4;

     GENERIC
          TYPE GP IS PRIVATE;
     FUNCTION GEN_EQUAL (X, Y : GP) RETURN BOOLEAN;

     FUNCTION GEN_EQUAL (X, Y : GP) RETURN BOOLEAN IS
     BEGIN
          RETURN X = Y;
     END GEN_EQUAL;

     FUNCTION ARR_EQUAL IS NEW GEN_EQUAL (ARR);
     FUNCTION REC_EQUAL IS NEW GEN_EQUAL (REC);
     FUNCTION ARR2_EQUAL IS NEW GEN_EQUAL (ARR2);
     FUNCTION NULL_EQUAL IS NEW GEN_EQUAL (NULL_ARRAY);
     FUNCTION ARR3_EQUAL IS NEW GEN_EQUAL (ARR3);
     FUNCTION ARR4_EQUAL IS NEW GEN_EQUAL (ARR4);

BEGIN
     TEST ("C43004B", "CHECK THAT CONSTRAINT_ERROR IS RAISED IF THE " &
                      "BOUNDS SPECIFIED FOR AN ARRAY COMPONENT OF AN " &
                      "AGGREGATE DO NOT EQUAL THE BOUNDS OF THE " &
                      "COMPONENT SUBTYPE'S INDEX RANGE");

     BEGIN
          A := (1 => (1 => 1, 2 => 2, 3 => 3));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 1");
          IF NOT ARR_EQUAL (A,A) THEN
               COMMENT ("DON'T OPTIMIZE A");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 1");
     END;

     BEGIN
          A := (1 => ((5, 10, 15)));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 2");
          IF NOT ARR_EQUAL (A,A) THEN
               COMMENT ("DON'T OPTIMIZE A");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 2");
     END;

     BEGIN
          B := (D => 4, ARR_VAR => (1 => 1, 2 => 2, 3 => 3));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 3");
          IF NOT REC_EQUAL (B,B) THEN
               COMMENT ("DON'T OPTIMIZE B");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 3");
     END;

     BEGIN
          B := (D => 4, ARR_VAR => ((1,2,3)));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 4");
          IF NOT REC_EQUAL (B,B) THEN
               COMMENT ("DON'T OPTIMIZE B");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 4");
     END;

     BEGIN
          C := (1 => (1 => 1, 2 => 2, 3 => 3));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 5");
          IF NOT ARR2_EQUAL (C,C) THEN
               COMMENT ("DON'T OPTIMIZE C");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 5");
     END;

     BEGIN
          C := (1 => ((5, 10, 15)));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 6");
          IF NOT ARR2_EQUAL (C,C) THEN
               COMMENT ("DON'T OPTIMIZE C");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 6");
     END;

     BEGIN
          D := (1 => (1 => 1, 2 => 2, 3 => 3));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 7");
          IF NOT NULL_EQUAL (D,D) THEN
               COMMENT ("DON'T OPTIMIZE D");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 7");
     END;

     BEGIN
          D := (1 => ((5, 10, 15)));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 8");
          IF NOT NULL_EQUAL (D,D) THEN
               COMMENT ("DON'T OPTIMIZE D");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 8");
     END;

     BEGIN
          E := (1 => (1 => TRUE, 2 => TRUE, 3 => FALSE));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 9");
          IF NOT ARR3_EQUAL (E,E) THEN
               COMMENT ("DON'T OPTIMIZE E");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 9");
     END;

     BEGIN
          E := (1 => ((FALSE, FALSE, TRUE)));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 10");
          IF NOT ARR3_EQUAL (E,E) THEN
               COMMENT ("DON'T OPTIMIZE E");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 10");
     END;

     BEGIN
          F := (1 => (1 => TRUE, 2 => TRUE, 3 => FALSE));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 11");
          IF NOT ARR4_EQUAL (F,F) THEN
               COMMENT ("DON'T OPTIMIZE F");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 11");
     END;

     BEGIN
          F := (1 => ((FALSE, TRUE, TRUE)));
          FAILED ("CONSTRAINT_ERROR WAS NOT RAISED - 11");
          IF NOT ARR4_EQUAL (F,F) THEN
               COMMENT ("DON'T OPTIMIZE F");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - 11");
     END;

     RESULT;
END C43004B;
