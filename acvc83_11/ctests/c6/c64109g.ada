-- C64109G.ADA

-- CHECK THAT SLICES OF ARRAYS ARE PASSED CORRECTLY TO SUBPROGRAMS.
-- SPECIFICALLY,
--   (A) CHECK ALL PARAMETER MODES.

-- CPP 8/28/84

WITH REPORT;  USE REPORT;
PROCEDURE C64109G IS

BEGIN
     TEST ("C64109G", "CHECK THAT SLICES OF ARRAYS ARE PASSED " &
           "CORRECTLY TO SUBPROGRAMS");

     --------------------------------------------

     DECLARE   -- (A)

          SUBTYPE SUBINT IS INTEGER RANGE 1..5;
          TYPE ARRAY_TYPE IS ARRAY (SUBINT RANGE <>) OF INTEGER;
          ARR : ARRAY_TYPE (1..5) := (1..3 => 7, 4..5 => 9);
          BOOL : BOOLEAN;

          PROCEDURE P1 (S : ARRAY_TYPE) IS
          BEGIN
               IF S(IDENT_INT(3)) /= 7 THEN
                    FAILED ("IN PARAMETER NOT PASSED CORRECTLY - (A)");
               END IF;
               IF S(4) /= 9 THEN
                    FAILED ("IN PARAMETER NOT PASSED CORRECTLY - (A)2");
               END IF;
          END P1;

          FUNCTION F1 (S : ARRAY_TYPE) RETURN BOOLEAN IS
          BEGIN
               IF S(3) /= 7 THEN
                    FAILED ("IN PARAMETER NOT PASSED CORRECTLY - (A)");
               END IF;
               IF S(IDENT_INT(4)) /= 9 THEN
                    FAILED ("IN PARAMETER NOT PASSED CORRECTLY - (A)2");
               END IF;
               RETURN TRUE;
          END F1;

          PROCEDURE P2 (S : IN OUT ARRAY_TYPE) IS
          BEGIN
               IF S(3) /= 7 THEN
                    FAILED ("IN OUT PARAM NOT PASSED CORRECTLY - (A)");
               END IF;
               IF S(4) /= 9 THEN
                    FAILED ("IN OUT PARAM NOT PASSED CORRECTLY - (A)2");
               END IF;
               FOR I IN 3 .. 4 LOOP
                    S(I) := 5;
               END LOOP;
          END P2;

          PROCEDURE P3 (S : OUT ARRAY_TYPE) IS
          BEGIN
               FOR I IN 3 .. 4 LOOP
                    S(I) := 3;
               END LOOP;
          END P3;

     BEGIN     -- (A)

          P1 (ARR(3..4));
          IF ARR(3) /= 7 THEN
               FAILED ("IN PARAM CHANGED BY PROCEDURE - (A)");
          END IF;
          IF ARR(4) /= 9 THEN
               FAILED ("IN PARAM CHANGED BY PROCEDURED - (A)2");
          END IF;

          BOOL := F1 (ARR(IDENT_INT(3)..IDENT_INT(4)));
          IF ARR(3) /= 7 THEN
               FAILED ("IN PARAM CHANGED BY FUNCTION - (A)");
          END IF;
          IF ARR(4) /= 9 THEN
               FAILED ("IN PARAM CHANGED BY FUNCTION - (A)2");
          END IF;

          P2 (ARR(3..4));
          FOR I IN 3 .. 4 LOOP
               IF ARR(I) /= 5 THEN
                    FAILED ("IN OUT PARAM RETURNED INCORRECTLY - (A)");
               END IF;
          END LOOP;

          P3 (ARR(IDENT_INT(3)..4));
          FOR I IN 3 .. 4 LOOP
               IF ARR(I) /= 3 THEN
                    FAILED ("OUT PARAM RETURNED INCORRECTLY - (A)");
               END IF;
          END LOOP;

     END;

     RESULT;

END C64109G;
