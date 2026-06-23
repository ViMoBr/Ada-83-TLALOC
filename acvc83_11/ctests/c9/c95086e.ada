-- C95086E.ADA

-- CHECK THAT CONSTRAINT_ERROR IS NOT RAISED BEFORE OR AFTER THE ENTRY
-- CALL FOR IN OUT ARRAY PARAMETERS, WHERE THE ACTUAL PARAMETER HAS THE
-- FORM OF A TYPE CONVERSION.  THE FOLLOWING CASES ARE TESTED:
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

-- RJW 2/3/86

WITH REPORT; USE REPORT;
PROCEDURE C95086E IS

BEGIN
     TEST ("C95086E", "CHECK THAT CONSTRAINT_ERROR IS NOT RAISED " &
           "BEFORE OR AFTER THE ENTRY CALL FOR IN OUT ARRAY " &
           "PARAMETERS, WITH THE ACTUAL HAVING THE FORM OF A TYPE " &
           "CONVERSION");

     ---------------------------------------------

     DECLARE -- (A)

          SUBTYPE INDEX IS INTEGER RANGE 1..5;
          TYPE ARRAY_TYPE IS ARRAY (INDEX RANGE <>, INDEX RANGE <>)
               OF BOOLEAN;
          SUBTYPE FORMAL IS ARRAY_TYPE (1..3, 1..3);
          SUBTYPE ACTUAL IS ARRAY_TYPE (1..3, 1..3);
          AR : ACTUAL := (1..3 => (1..3 => TRUE));
          CALLED : BOOLEAN := FALSE;

          TASK T IS
               ENTRY E (X : IN OUT FORMAL);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (X : IN OUT FORMAL) DO
                    CALLED := TRUE;
               END E;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (A)");
          END T;

     BEGIN -- (A)

          T.E (FORMAL (AR));

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

          TASK T IS
               ENTRY E (X : IN OUT FORMAL);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (X : IN OUT FORMAL) DO
                    CALLED := TRUE;
                    X(3, 3) := TRUE;
               END E;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (B)");
          END T;

     BEGIN -- (B)

          T.E (FORMAL (AR));
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

          TASK T IS
               ENTRY E (X : IN OUT FORMAL);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (X : IN OUT FORMAL) DO
                    IF X'LAST /= 0 AND X'LAST(2) /= 3 THEN
                         FAILED ("WRONG BOUNDS PASSED - (C)");
                    END IF;
                    CALLED := TRUE;
                    X := (2..0 => (1..3 => 'A'));
               END E;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (C)");
          END T;

     BEGIN -- (C)

          T.E (FORMAL (AR));
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

          TASK T IS
               ENTRY E (X : IN OUT FORMAL);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (X : IN OUT FORMAL) DO
                    IF X'LAST /= 3 AND X'LAST(2) /= 1 THEN
                         FAILED ("WRONG BOUNDS PASSED - (D)");
                    END IF;
                    CALLED := TRUE;
                    X := (1..3 => (3..1 => 'A'));
               END E;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (D)");
          END T;

     BEGIN -- (D)

          T.E (FORMAL (AR));
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

          TASK T IS
               ENTRY E (X : IN OUT FORMAL);
          END T;

          TASK BODY T IS
          BEGIN
               ACCEPT E (X : IN OUT FORMAL) DO
                    IF X'LAST /= 2 AND X'LAST(2) /= 3 THEN
                         FAILED ("WRONG BOUNDS PASSED - (E)");
                    END IF;
                    CALLED := TRUE;
                    X := (1..3 => (3..0 => ' '));
               END E;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (E)");
          END T;

     BEGIN -- (E)

          T.E (FORMAL (AR));
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
END C95086E;
