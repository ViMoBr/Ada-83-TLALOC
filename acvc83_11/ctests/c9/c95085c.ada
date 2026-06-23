-- C95085C.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE
-- APPROPRIATE CIRCUMSTANCES FOR ARRAY PARAMETERS IN ENTRY CALLS,
-- NAMELY WHEN THE ACTUAL BOUNDS DON'T MATCH THE FORMAL BOUNDS
-- (BEFORE THE CALL FOR ALL MODES).
-- SUBTESTS ARE:
--      (A) IN MODE, ONE DIMENSION, STATIC AGGREGATE.
--      (B) IN MODE, TWO DIMENSIONS, DYNAMIC AGGREGATE.
--      (C) IN MODE, TWO DIMENSIONS, DYNAMIC VARIABLE.
--      (D) IN OUT MODE, THREE DIMENSIONS, STATIC VARIABLE.
--      (E) OUT MODE, ONE DIMENSION, DYNAMIC VARIABLE.
--      (F) IN OUT MODE, NULL STRING AGGREGATE.
--      (G) IN OUT MODE, TWO DIMENSIONS, NULL AGGREGATE (OK CASE).
--          IN OUT MODE, TWO DIMENSIONS, NULL AGGREGATE.

-- JWC 10/28/85

WITH REPORT; USE REPORT;
PROCEDURE C95085C IS

BEGIN
     TEST ("C95085C", "CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN " &
                      "ACTUAL ARRAY BOUNDS DON'T MATCH FORMAL BOUNDS");

     --------------------------------------------------

     DECLARE -- (A)
          SUBTYPE ST IS STRING (1..3);

          TASK TSK IS
               ENTRY E (A : ST);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (A : ST) DO
                         FAILED ("EXCEPTION NOT RAISED ON CALL - (A)");
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (A)");
          END TSK;

     BEGIN -- (A)

          TSK.E ("AB");
          FAILED ("EXCEPTION NOT RAISED BEFORE CALL - (A)");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - (A)");
     END; -- (A)

     --------------------------------------------------

     DECLARE -- (B)

          SUBTYPE S IS INTEGER RANGE 1..3;
          TYPE T IS ARRAY (S,S) OF INTEGER;

          TASK TSK IS
               ENTRY E (A : T);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (A : T) DO
                         FAILED ("EXCEPTION NOT RAISED ON CALL - (B)");
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (B)");
          END TSK;

     BEGIN -- (B)

          TSK.E ((1..3 => (1..IDENT_INT(2) => 0)));
          FAILED ("EXCEPTION NOT RAISED BEFORE CALL - (B)");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - (B)");
     END; -- (B)

     --------------------------------------------------

     DECLARE -- (C)

          SUBTYPE S IS INTEGER RANGE 1..5;
          TYPE T IS ARRAY (S RANGE <>, S RANGE <>) OF INTEGER;
          SUBTYPE ST IS T (1..3,1..3);
          V : T (1..IDENT_INT(2), 1..3) :=
                (1..IDENT_INT(2) => (1..3 => 0));

          TASK TSK IS
               ENTRY E (A :ST);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (A :ST) DO
                         FAILED ("EXCEPTION NOT RAISED ON CALL - (C)");
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (C)");
          END TSK;

     BEGIN -- (C)

          TSK.E (V);
          FAILED ("EXCEPTION NOT RAISED BEFORE CALL - (C)");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - (C)");
     END; -- (C)

     --------------------------------------------------

     DECLARE -- (D)

          SUBTYPE S IS INTEGER RANGE 1..5;
          TYPE T IS ARRAY (S RANGE <>, S RANGE <>, S RANGE <>) OF
                    INTEGER;
          SUBTYPE ST IS T (1..3, 1..3, 1..3);
          V : T (1..3, 1..2, 1..3) :=
                (1..3 => (1..2 => (1..3 => 0)));

          TASK TSK IS
               ENTRY E (A : IN OUT ST);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (A : IN OUT ST) DO
                         FAILED ("EXCEPTION NOT RAISED ON CALL - (D)");
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (D)");
          END TSK;

     BEGIN -- (D)

          TSK.E (V);
          FAILED ("EXCEPTION NOT RAISED BEFORE CALL - (D)");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - (D)");
     END; -- (D)

     --------------------------------------------------

     DECLARE -- (E)

          SUBTYPE STR IS STRING(1..3);
          V : STRING (IDENT_INT(2) .. IDENT_INT(4));

          TASK TSK IS
               ENTRY E (A : OUT STR);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (A : OUT STR) DO
                         FAILED ("EXCEPTION NOT RAISED ON CALL - (E)");
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (E)");
          END TSK;

     BEGIN -- (E)

          TSK.E (V);
          FAILED ("EXCEPTION NOT RAISED BEFORE CALL - (E)");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - (E)");
     END; -- (E)

     --------------------------------------------------

     DECLARE -- (F)

          TYPE NULL_TYPE IS NEW STRING;
          SUBTYPE NULL_STR IS NULL_TYPE (3..INTEGER'FIRST);
          SUBTYPE NULL_STR2 IS NULL_TYPE (1..INTEGER'FIRST);
          V : NULL_STR := "";

          TASK TSK IS
               ENTRY E (A : IN OUT NULL_STR2);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (A : IN OUT NULL_STR2) DO
                         FAILED ("EXCEPTION NOT RAISED ON CALL - (F)");
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (F)");
          END TSK;

     BEGIN -- (F)

          TSK.E (V);
          FAILED ("EXCEPTION NOT RAISED BEFORE CALL - (F)");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - (F)");
     END; -- (F)

     --------------------------------------------------

     DECLARE -- (G)

          SUBTYPE S IS INTEGER RANGE 1..5;
          TYPE T IS ARRAY (S RANGE <>, S RANGE <>) OF CHARACTER;
          SUBTYPE ST IS T (2..1, 2..1);
          V : T (2..1, 2..1) := (2..1 => (2..1 => ' '));

          TASK TSK IS
               ENTRY E (A : IN OUT ST);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (A : IN OUT ST)  DO
                         COMMENT ("OK CASE CALLED CORRECTLY");
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (G)");
          END TSK;

     BEGIN -- (G)

          TSK.E (V);

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED ON OK CASE - (G)");
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED ON OK CASE - (G)");
     END; -- (G)

     --------------------------------------------------

     DECLARE -- (G1)

          SUBTYPE S IS INTEGER RANGE 1..5;
          TYPE T IS ARRAY (S RANGE <>, S RANGE <>) OF CHARACTER;
          SUBTYPE NEW_ARR IS T (-6 .. -8, -6 .. -8);
          V : T (2..1, 2..1) := (2..1 => (2..1 => ' '));

          TASK TSK IS
               ENTRY E (A : IN OUT NEW_ARR);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (A : IN OUT NEW_ARR) DO
                         FAILED ("EXCEPTION NOT RAISED ON CALL - (G1)");
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK - (G1)");
          END TSK;

     BEGIN -- (G1)

          TSK.E (V);
          FAILED ("EXCEPTION NOT RAISED BEFORE CALL - (G1)");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - (G1)");
     END; -- (G1)

     --------------------------------------------------

     RESULT;
END C95085C;
