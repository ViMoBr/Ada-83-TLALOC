-- C64104C.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE
--   APPROPRIATE CIRCUMSTANCES FOR ARRAY PARAMETERS, NAMELY
--   WHEN THE ACTUAL BOUNDS DON'T MATCH THE FORMAL BOUNDS
--   (BEFORE THE CALL FOR ALL MODES).
--   SUBTESTS ARE:
--      (A) IN MODE, ONE DIMENSION, STATIC AGGREGATE.
--      (B) IN MODE, TWO DIMENSIONS, DYNAMIC AGGREGATE.
--      (C) IN MODE, TWO DIMENSIONS, DYNAMIC VARIABLE.
--      (D) IN OUT MODE, THREE DIMENSIONS, STATIC VARIABLE.
--      (E) OUT MODE, ONE DIMENSION, DYNAMIC VARIABLE.
--      (F) IN OUT MODE, NULL STRING AGGREGATE.
--      (G) IN OUT MODE, TWO DIMENSIONS, NULL AGGREGATE (OK CASE).
--          IN OUT MODE, TWO DIMENSIONS, NULL AGGREGATE.

-- JRK 3/17/81
-- SPS 10/26/82
-- CPP 8/6/84

WITH REPORT;
PROCEDURE C64104C IS

     USE REPORT;

BEGIN
     TEST ("C64104C", "CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN " &
           "ACTUAL ARRAY BOUNDS DON'T MATCH FORMAL BOUNDS");

     --------------------------------------------------

     DECLARE -- (A)
          SUBTYPE ST IS STRING (1..3);

          PROCEDURE P (A : ST) IS
          BEGIN
               FAILED ("EXCEPTION NOT RAISED ON CALL - (A)");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (A)");
          END P;

     BEGIN -- (A)

          P ("AB");
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

          PROCEDURE P (A : T) IS
          BEGIN
               FAILED ("EXCEPTION NOT RAISED ON CALL - (B)");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (B)");
          END P;

     BEGIN -- (B)

          P ((1..3 => (1..IDENT_INT(2) => 0)));
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

          PROCEDURE P (A :ST) IS
          BEGIN
               FAILED ("EXCEPTION NOT RAISED ON CALL - (C)");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (C)");
          END P;

     BEGIN -- (C)

          P (V);
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

          PROCEDURE P (A : IN OUT ST) IS
          BEGIN
               FAILED ("EXCEPTION NOT RAISED ON CALLL - (D)");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (D)");
          END P;

     BEGIN -- (D)

          P (V);
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

          PROCEDURE P (A : OUT STR) IS
          BEGIN
               FAILED ("EXCEPTION NOT RAISED ON CALL - (E)");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (E)");
          END P;

     BEGIN -- (E)

          P (V);
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

          PROCEDURE P (A : IN OUT NULL_STR2) IS
          BEGIN
               FAILED ("EXCEPTION NOT RAISED ON CALL - (F)");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (F)");
          END P;

     BEGIN -- (F)

          P(V);
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

          PROCEDURE P (A : IN OUT ST) IS
          BEGIN
               COMMENT ("OK CASE CALLED CORRECTLY");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (G)");
          END P;

     BEGIN -- (G)

          P (V);

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

          PROCEDURE P (A : IN OUT NEW_ARR) IS
          BEGIN
               FAILED ("EXCEPTION NOT RAISED ON CALL - (G1)");
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (G1)");
          END P;

     BEGIN -- (G1)

          P (V);
          FAILED ("EXCEPTION NOT RAISED BEFORE CALL - (G1)");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - (G1)");
     END; -- (G1)

     --------------------------------------------------

     RESULT;
END C64104C;
