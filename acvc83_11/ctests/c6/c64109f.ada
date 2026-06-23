-- C64109F.ADA

-- CHECK THAT ARRAYS THAT ARE COMPONENTS OF RECORDS ARE PASSED CORRECTLY
-- TO SUBPROGRAMS.  SPECIFICALLY,
--   (F) CHECK THAT A FORMAL PARAMETER CAN BE USED AS AN ACTUAL IN
--       ANOTHER CALL.

-- CPP 8/20/84

WITH REPORT;  USE REPORT;
PROCEDURE C64109F IS

BEGIN
     TEST ("C64109F", "CHECK THAT ARRAYS WHICH ARE COMPONENTS OF " &
           "RECORDS ARE PASSED CORRECTLY TO SUBPROGRAMS - " &
           "FORMAL AS AN ACTUAL");

     DECLARE   -- (F)

          TYPE ARRAY_TYPE IS ARRAY (POSITIVE RANGE <>) OF INTEGER;
          SUBTYPE ARRAY_SUBTYPE IS 
                    ARRAY_TYPE (IDENT_INT(1)..IDENT_INT(5));
          TYPE RECORD_TYPE IS
               RECORD
                    I : INTEGER;
                    A : ARRAY_SUBTYPE;
               END RECORD;
          REC : RECORD_TYPE := (I => 23,
                                A => (1..3 => 7, 4..5 => 9));
          BOOL : BOOLEAN;

          PROCEDURE P_CALLED (A : IN OUT ARRAY_TYPE) IS
          BEGIN
               IF A /= (7, 7, 7, 9, 9) THEN
                    FAILED ("IN OUT PARAM NOT RECEIVED CORRECTLY");
               END IF;
               IF A'FIRST /= 1 OR A'LAST /= 5 THEN
                    FAILED ("BOUNDS WRONG - IN OUT");
               END IF;
               A := (6, 6, 6, 6, 6);
          END P_CALLED;

          PROCEDURE P (A : IN OUT ARRAY_TYPE) IS
          BEGIN
               P_CALLED (A);
          END P;

          FUNCTION F_CALLED (A : ARRAY_SUBTYPE) RETURN BOOLEAN IS
               GOOD : BOOLEAN;
          BEGIN
               GOOD := (A = (7, 7, 7, 9, 9));
               IF NOT GOOD THEN
                    FAILED ("IN PARAMETER NOT RECEIVED CORRECTLY");
               END IF;
               IF A'FIRST /= 1 OR A'LAST /= IDENT_INT(5) THEN
                    FAILED ("BOUNDS WRONG - FUNCTION");
               END IF;
               RETURN GOOD;
          END F_CALLED;

          FUNCTION F (A : ARRAY_TYPE) RETURN BOOLEAN IS
          BEGIN
               RETURN (F_CALLED (A));
          END F;

          PROCEDURE P_OUT_CALLED (A : OUT ARRAY_TYPE) IS
          BEGIN
               IF A'FIRST /= 1 OR A'LAST /= 5 THEN
                    FAILED ("BOUNDS WRONG - OUT");
               END IF;
               A := (8, 8, 8, 8, 8);
          END P_OUT_CALLED;

          PROCEDURE P_OUT (A : OUT ARRAY_TYPE) IS
          BEGIN
               P_OUT_CALLED (A);
               A := (9, 9, 9, 9, 9);
          END P_OUT;

     BEGIN     -- (F)

          P (REC.A);
          IF REC.A /= (6, 6, 6, 6, 6) THEN
               FAILED ("IN OUT PARAM NOT RETURNED CORRECTLY");
          END IF;

          REC.A := (7, 7, 7, 9, 9);
          BOOL := F (REC.A);
          IF NOT BOOL THEN
               FAILED ("IN PARAM NOT RETURNED CORRECTLY");
          END IF;

          REC.A := (7, 7, 7, 9, 9);
          P_OUT (REC.A);
          IF REC.A /= (9, 9, 9, 9, 9) THEN
               FAILED ("OUT PARAM NOT RETURNED CORRECTLY - 2");
          END IF;

     END; -- (F)

     --------------------------------------------

     RESULT;
END C64109F;
