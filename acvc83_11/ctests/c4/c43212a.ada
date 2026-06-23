-- C43212A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF ALL SUBAGGREGATES FOR A
-- PARTICULAR DIMENSION DO NOT HAVE THE SAME BOUNDS.

-- EG  02/06/1984
-- JBG 3/30/84
-- JRK 4/18/86   CORRECTED ERROR TO ALLOW CONSTRAINT_ERROR TO BE
--               RAISED EARLIER.

WITH REPORT;

PROCEDURE C43212A IS

     USE REPORT;

BEGIN

     TEST ("C43212A", "CHECK THAT CONSTRAINT_ERROR IS RAISED IF ALL " &
                      "SUBAGGREGATES FOR A PARTICULAR DIMENSION DO "  &
                      "NOT HAVE THE SAME BOUNDS");

     DECLARE

          TYPE CHOICE_INDEX IS (H, I);
          TYPE CHOICE_CNTR  IS ARRAY(CHOICE_INDEX) OF INTEGER;

          CNTR : CHOICE_CNTR := (CHOICE_INDEX => 0);

          FUNCTION CALC (A : CHOICE_INDEX; B : INTEGER)
                                             RETURN INTEGER IS
          BEGIN
               CNTR(A) := CNTR(A) + 1;
               RETURN IDENT_INT(B);
          END CALC;

     BEGIN

CASE_1 :  DECLARE

               TYPE T IS ARRAY(INTEGER RANGE <>, INTEGER RANGE <>)
                                                   OF INTEGER;

               A1 : T(1 .. 3, 2 .. 5);

          BEGIN

               CNTR := (CHOICE_INDEX => 0);
               A1 := (1 => (CALC(H,2) .. CALC(I,5) => -4),
                      2 => (CALC(H,3) .. CALC(I,6) => -5),
                      3 => (CALC(H,2) .. CALC(I,5) => -3));
               FAILED ("CASE 1 : CONSTRAINT_ERROR NOT RAISED");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    IF CNTR(H) < 2 AND CNTR(I) < 2 THEN
                         FAILED ("CASE 1 : BOUNDS OF SUBAGGREGATES " &
                                 "NOT DETERMINED INDEPENDENTLY");
                    END IF;

               WHEN OTHERS =>
                    FAILED ("CASE 1 : WRONG EXCEPTION RAISED");

          END CASE_1;

CASE_1A : DECLARE

               TYPE T IS ARRAY(INTEGER RANGE <>, INTEGER RANGE <>)
                                                  OF INTEGER;

               A1 : T(1 .. 3, 2 .. 3) := (1 .. 3 => (2 .. 3 => 1));

          BEGIN

               IF (1 .. 2 => (3 .. 4 => 0), 3 => (1, 2)) = A1 THEN
                    NULL;
               END IF;
               FAILED ("CASE 1A : CONSTRAINT_ERROR NOT RAISED");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("CASE 1A : WRONG EXCEPTION RAISED");

          END CASE_1A;

CASE_2 :  DECLARE

               TYPE T IS ARRAY(INTEGER RANGE <>, INTEGER RANGE <>)
                                                   OF INTEGER;

               A2 : T(1 .. 3, 4 .. 2);

          BEGIN

               CNTR := (CHOICE_INDEX => 0);
               A2 := (1 => (CALC(H,5) .. CALC(I,3) => -4),
                      3 => (CALC(H,4) .. CALC(I,2) => -5),
                      2 => (CALC(H,4) .. CALC(I,2) => -3));
               FAILED ("CASE 2 : CONSTRAINT_ERROR NOT RAISED");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    IF CNTR(H) < 2 AND CNTR(I) < 2 THEN
                         FAILED ("CASE 2 : BOUNDS OF SUBAGGREGATES " &
                                 "NOT DETERMINED INDEPENDENTLY");
                    END IF;

               WHEN OTHERS =>
                    FAILED ("CASE 2 : WRONG EXCEPTION RAISED");

          END CASE_2;

     END;

     RESULT;

END C43212A;
