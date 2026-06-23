-- C64109C.ADA

-- CHECK THAT ARRAYS THAT ARE COMPONENTS OF RECORDS ARE PASSED CORRECTLY
-- TO SUBPROGRAMS.  SPECIFICALLY,
--   (C) CHECK RECORDS HAVING A DISCRIMINANT, WITH MORE THAN ONE ARRAY
--       COMPONENT, WHERE THE BOUNDS OF THE ARRAY DEPEND ON THE
--       DISCRIMINANT.

-- CPP 8/20/84

WITH REPORT;  USE REPORT;
PROCEDURE C64109C IS

BEGIN
     TEST ("C64109C", "CHECK THAT ARRAYS WHICH ARE COMPONENTS OF " &
           "RECORDS ARE PASSED CORRECTLY TO SUBPROGRAMS - " &
           "RECORDS WITH DISCRIMINANTS");

     DECLARE   -- (C)

          SUBTYPE SUBINT IS INTEGER RANGE 1..6;
          TYPE ARRAY_TYPE IS ARRAY (SUBINT RANGE <>) OF INTEGER;
          TYPE RECORD_TYPE (BOUND : INTEGER) IS
               RECORD
                    B : BOOLEAN;
                    A : ARRAY_TYPE (1..BOUND);
                    AA : ARRAY_TYPE (BOUND..6);
               END RECORD;
          REC : RECORD_TYPE (BOUND => IDENT_INT(4)) :=
                               (BOUND => 4,
                                B => TRUE,
                                A => (1..IDENT_INT(4) => 6),
                                AA => (4..6 => 8));
          BOOL : BOOLEAN;

          PROCEDURE P1 (ARR : ARRAY_TYPE) IS
          BEGIN
               IF ARR /= (6, 6, 6, 6) THEN
                    FAILED ("IN PARAM NOT PASSED CORRECTLY");
               END IF;

               IF ARR'FIRST /= 1 OR ARR'LAST /= IDENT_INT(4) THEN
                    FAILED ("WRONG BOUNDS - IN PARAMETER");
               END IF;
          END P1;

          FUNCTION F1 (ARR : ARRAY_TYPE) RETURN BOOLEAN IS
          BEGIN
               IF ARR /= (6, 6, 6, 6) THEN
                    FAILED ("IN PARAM NOT PASSED CORRECTLY TO FN");
               END IF;

               IF ARR'FIRST /= 1 OR ARR'LAST /= IDENT_INT(4) THEN
                    FAILED ("WRONG BOUNDS - IN PARAMETER FOR FN");
               END IF;
               RETURN TRUE;
          END F1;

          PROCEDURE P2 (ARR : IN OUT ARRAY_TYPE) IS
          BEGIN
               IF ARR /= (8, 8, 8) THEN
                    FAILED ("IN OUT PARAM NOT PASSED CORRECTLY");
               END IF;

               IF ARR'FIRST /= 4 OR ARR'LAST /= IDENT_INT(6) THEN
                    FAILED ("WRONG BOUNDS - IN OUT PARAMETER");
               END IF;

               ARR := (ARR'RANGE => 10);
          END P2;

          PROCEDURE P3 (ARR : OUT ARRAY_TYPE) IS
          BEGIN
               IF ARR'FIRST /= 1 OR ARR'LAST /= IDENT_INT(4) THEN
                    FAILED ("WRONG BOUNDS - OUT PARAMETER");
               END IF;
               ARR := (ARR'RANGE => 4);
          END P3;

     BEGIN     -- (C)

          P1 (REC.A);
          IF REC.A /= (6, 6, 6, 6) THEN
               FAILED ("IN PARAM CHANGED BY PROCEDURE");
          END IF;

          BOOL := F1 (REC.A);
          IF REC.A /= (6, 6, 6, 6) THEN
               FAILED ("IN PARAM CHANGED BY FUNCTION");
          END IF;

          P2 (REC.AA);
          IF REC.AA /= (10, 10, 10) THEN
               FAILED ("IN OUT PARAM NOT RETURNED CORRECTLY");
          END IF;

          P3 (REC.A);
          IF REC.A /= (4, 4, 4, 4) THEN
               FAILED ("OUT PARAM NOT RETURNED CORRECTLY");
          END IF;

     END; -- (C)

     RESULT;
END C64109C;
