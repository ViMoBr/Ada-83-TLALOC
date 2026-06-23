-- C64105E.ADA

-- CHECK THAT CONSTRAINT_ERROR IS NOT RAISED BEFORE OR AFTER THE CALL
-- FOR IN OUT ARRAY PARAMETERS, WHERE THE ACTUAL PARAMETER HAS THE FORM
-- OF A TYPE CONVERSION.  THE FOLLOWING CASES ARE TESTED:
--   (A) OK CASE.
--   (B) FORMAL CONSTRAINED, BOTH FORMAL AND ACTUAL HAVE SAME NUMBER
--       COMPONENTS PER DIMENSION, BUT ACTUAL INDEX BOUNDS LIE OUTSIDE
--       FORMAL INDEX SUBTYPE.
--   (C) FORMAL CONSTRAINED, FORMAL AND ACTUAL HAVE DIFFERENT NUMBER
--       COMPONENTS PER DIMENSION, BOTH FORMAL AND ACTUAL ARE NULL
--       ARRAYS.
--   (D) FORMAL CONSTRAINED, ACTUAL NULL, WITH INDEX BOUNDS OUTSIDE
--       FORMAL INDEX SUBTYPE.
--   (E) FORMAL UNCONSTRAINED, ACTUAL NULL, WITH INDEX BOUNDS OUTSIDE
--       FORMAL INDEX SUBTYPE FOR NULL DIMENSIONS ONLY.

-- CPP 8/8/84
-- JBG 6/5/85

WITH REPORT;  USE REPORT;
PROCEDURE C64105E IS

BEGIN
     TEST ("C64105E", "CHECK THAT CONSTRAINT_ERROR IS NOT RAISED " &
           "BEFORE OR AFTER THE CALL FOR IN OUT ARRAY PARAMETERS, " &
           "WITH THE ACTUAL HAVING THE FORM OF A TYPE CONVERSION");

     ---------------------------------------------

     DECLARE -- (A)

          SUBTYPE INDEX IS INTEGER RANGE 1..5;
          TYPE ARRAY_TYPE IS ARRAY (INDEX RANGE <>, INDEX RANGE <>) 
               OF BOOLEAN;
          SUBTYPE FORMAL IS ARRAY_TYPE (1..3, 1..3);
          SUBTYPE ACTUAL IS ARRAY_TYPE (1..3, 1..3);
          AR : ACTUAL := (1..3 => (1..3 => TRUE));
          CALLED : BOOLEAN := FALSE;

          PROCEDURE P1 (X : IN OUT FORMAL) IS
          BEGIN
               CALLED := TRUE;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (A)");
          END P1;

     BEGIN -- (A)

          P1 (FORMAL (AR));

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT CALLED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (A)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (A)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (A)");
     END; -- (A)

     ---------------------------------------------

     DECLARE -- (B)

          SUBTYPE INDEX IS INTEGER RANGE 1..3;
          TYPE FORMAL IS ARRAY (INDEX, INDEX) OF BOOLEAN;
          TYPE ACTUAL IS ARRAY (3..5, 3..5) OF BOOLEAN;
          AR : ACTUAL := (3..5 => (3..5 => FALSE));
          CALLED : BOOLEAN := FALSE;

          PROCEDURE P2 (X : IN OUT FORMAL) IS
          BEGIN
               CALLED := TRUE;
               X(3, 3) := TRUE;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (B)");
          END P2;

     BEGIN -- (B)

          P2 (FORMAL (AR));
          IF AR(5, 5) /= TRUE THEN
               FAILED ("INCORRECT RETURNED VALUE - (B)");
          END IF;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT CALLED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (B)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (B)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (B)");
     END; -- (B)

     ---------------------------------------------

     DECLARE -- (C)

          SUBTYPE INDEX IS INTEGER RANGE 1..5;
          TYPE ARRAY_TYPE IS ARRAY (INDEX RANGE <>, INDEX RANGE <>)
               OF CHARACTER;
          SUBTYPE FORMAL IS ARRAY_TYPE (2..0, 1..3);
          AR : ARRAY_TYPE (2..1, 1..2) := (2..1 => (1..2 => ' '));
          CALLED : BOOLEAN := FALSE;

          PROCEDURE P3 (X : IN OUT FORMAL) IS
          BEGIN
               IF X'LAST /= 0 AND X'LAST(2) /= 3 THEN
                    FAILED ("WRONG BOUNDS PASSED - (C)");
               END IF;
               CALLED := TRUE;
               X := (2..0 => (1..3 => 'A'));
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (C)");
          END P3;

     BEGIN -- (C)

          P3 (FORMAL (AR));
          IF AR'LAST /= 1 AND AR'LAST(2) /= 2 THEN
               FAILED ("BOUNDS CHANGED - (C)");
          END IF;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT CALLED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (C)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (C)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (C)");
     END; -- (C)

     ---------------------------------------------

     DECLARE -- (D)

          SUBTYPE INDEX IS INTEGER RANGE 1..3;
          TYPE FORMAL IS ARRAY (INDEX RANGE 1..3, INDEX RANGE 3..1)
               OF CHARACTER;
          TYPE ACTUAL IS ARRAY (5..3, 3..5) OF CHARACTER;
          AR : ACTUAL := (5..3 => (3..5 => ' '));
          CALLED : BOOLEAN := FALSE;

          PROCEDURE P4 (X : IN OUT FORMAL) IS
          BEGIN
               IF X'LAST /= 3 AND X'LAST(2) /= 1 THEN
                    FAILED ("WRONG BOUNDS PASSED - (D)");
               END IF;
               CALLED := TRUE;
               X := (1..3 => (3..1 => 'A'));
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (D)");
          END P4;

     BEGIN -- (D)

          P4 (FORMAL (AR));
          IF AR'LAST /= 3 AND AR'LAST(2) /= 5 THEN
               FAILED ("BOUNDS CHANGED - (D)");
          END IF;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT CALLED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (D)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (D)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (D)");
     END; -- (D)

     ---------------------------------------------

     DECLARE -- (E)

          SUBTYPE INDEX IS INTEGER RANGE 1..3;
          TYPE FORMAL IS ARRAY (INDEX RANGE <>, INDEX RANGE <>)
               OF CHARACTER;
          TYPE ACTUAL IS ARRAY (POSITIVE RANGE 5..2, 
                                POSITIVE RANGE 1..3) OF CHARACTER;
          AR : ACTUAL := (5..2 => (1..3 => ' '));
          CALLED : BOOLEAN := FALSE;

          PROCEDURE P5 (X : IN OUT FORMAL) IS
          BEGIN
               IF X'LAST /= 2 AND X'LAST(2) /= 3 THEN
                    FAILED ("WRONG BOUNDS PASSED - (E)");
               END IF;
               CALLED := TRUE;
               X := (1..3 => (3..0 => ' '));
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (E)");
          END P5;

     BEGIN -- (E)

          P5 (FORMAL (AR));
          IF AR'LAST /= 2 AND AR'LAST(2) /= 3 THEN
               FAILED ("BOUNDS CHANGED - (E)");
          END IF;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT CALLED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (E)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (E)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (E)");
     END; -- (E)

     ---------------------------------------------

     RESULT;
END C64105E;
