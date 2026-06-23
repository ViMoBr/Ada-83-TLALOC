-- C36172A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED APPROPRIATELY
-- ON DISCRETE_RANGES USED AS INDEX_CONSTRAINTS.

-- DAT 2/9/81
-- SPS 4/7/82
-- JBG 6/5/85

WITH REPORT;
PROCEDURE C36172A IS

     USE REPORT;

     SUBTYPE INT_10 IS INTEGER RANGE 1 .. 10;
     TYPE A IS ARRAY (INT_10 RANGE <> ) OF INTEGER;

     SUBTYPE INT_11 IS INTEGER RANGE 0 .. 11;
     SUBTYPE NULL_6_4 IS INTEGER RANGE 6 .. 4;
     SUBTYPE NULL_11_10 IS INTEGER RANGE 11 .. 10;
     SUBTYPE INT_9_11 IS INTEGER RANGE 9 .. 11;

     TYPE A_9_11 IS ARRAY (9..11) OF BOOLEAN;
     TYPE A_11_10 IS ARRAY (11 .. 10) OF INTEGER;
     SUBTYPE A_1_10 IS A(INT_10);

BEGIN
     TEST ("C36172A", "CONSTRAINT_ERROR IS RAISED APPROPRIATELY" &
           " FOR INDEX_RANGES");

     BEGIN
          DECLARE
               V : A (9 .. 11);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    FAILED ("OUT-OF-BOUNDS INDEX_RANGE 1");
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS => FAILED ("WRONG EXCEPTION 1");
     END;

     BEGIN
          DECLARE
               V : A (11 .. 10);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    NULL;
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => FAILED ("CONSTRAINT_ERROR " &
               "RAISED INAPPROPRIATELY 2");
          WHEN OTHERS => FAILED ("EXCEPTION RAISED WHEN NONE " &
               "SHOULD BE 2");
     END;

     BEGIN
          DECLARE
               V : A (6 .. 4);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    NULL;
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => FAILED ("CONSTRAINT_ERROR " &
               "RAISED INAPPROPRIATELY 3");
          WHEN OTHERS => FAILED ("EXCEPTION RAISED WHEN NONE " &
               "SHOULD BE 3");
     END;

     BEGIN
          DECLARE
               V : A (INT_9_11);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    FAILED ("OUT-OF-BOUNDS INDEX RANGE 4");
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS => FAILED ("WRONG EXCEPTION 4");
     END;

     BEGIN
          DECLARE
               V : A (NULL_11_10);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    NULL;
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => FAILED ("CONSTRAINT_ERROR " &
               "RAISED INAPPROPRIATELY 5");
          WHEN OTHERS => FAILED ("EXCEPTION RAISED WHEN NONE " &
               "SHOULD BE 5");
     END;

     BEGIN
          DECLARE
               V : A (NULL_6_4);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    NULL;
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => FAILED ("CONSTRAINT_ERROR " &
               "RAISED INAPPROPRIATELY 6");
          WHEN OTHERS => FAILED ("EXCEPTION RAISED WHEN NONE " &
               "SHOULD BE 6");
     END;

     BEGIN
          DECLARE
               V : A (INT_9_11 RANGE 10 .. 11);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    FAILED ("BAD NON-NULL INDEX RANGE 7");
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS => FAILED ("WRONG EXCEPTION 7");
     END;

     BEGIN
          DECLARE
               V : A (NULL_11_10 RANGE 11 .. 10);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    NULL;
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => FAILED ("CONSTRAINT_ERROR " &
               "RAISED INAPPROPRIATELY 8");
          WHEN OTHERS => FAILED ("EXCEPTION RAISED WHEN NONE " &
               "SHOULD BE 8");
     END;

     BEGIN
          DECLARE
               V : A (NULL_6_4 RANGE 6 .. 4);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    NULL;
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => FAILED ("CONSTRAINT_ERROR " &
               "RAISED INAPPROPRIATELY 9");
          WHEN OTHERS => FAILED ("EXCEPTION RAISED WHEN NONE " &
               "SHOULD BE 9");
     END;

     BEGIN
          DECLARE
               V : A (A_9_11'RANGE);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    FAILED ("BAD INDEX RANGE 10");
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS => FAILED ("WRONG EXCEPTION 10");
     END;

     BEGIN
          DECLARE
               V : A (A_11_10'RANGE);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    NULL;
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => FAILED ("CONSTRAINT_ERROR " &
               "RAISED INAPPROPRIATELY 11");
          WHEN OTHERS => FAILED ("EXCEPTION RAISED WHEN NONE " &
               "SHOULD BE 11");
     END;

     BEGIN
          DECLARE
               V : A (6 .. 4);
          BEGIN
               IF EQUAL (V'FIRST, V'FIRST) THEN
                    NULL;
               ELSE
                    FAILED ("IMPOSSIBLE");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => FAILED ("CONSTRAINT_ERROR " &
               "RAISED INAPPROPRIATELY 12");
          WHEN OTHERS => FAILED ("EXCEPTION RAISED WHEN NONE " &
               "SHOULD BE 12");
     END;

     RESULT;
END C36172A;
