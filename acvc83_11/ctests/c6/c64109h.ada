-- C64109H.ADA

-- OBJECTIVE:
--    CHECK THAT SLICES OF ARRAYS WHICH ARE COMPONENTS OF RECORDS ARE
--    PASSED CORRECTLY TO SUBPROGRAMS.  SPECIFICALLY,
--       (A) CHECK ALL PARAMETER MODES.

-- HISTORY:
--    TBN 07/11/86          CREATED ORIGINAL TEST.
--    JET 08/04/87          MODIFIED REC.A REFERENCES.

WITH REPORT; USE REPORT;
PROCEDURE C64109H IS

BEGIN
     TEST ("C64109H", "CHECK THAT SLICES OF ARRAYS WHICH ARE " &
                      "COMPONENTS OF RECORDS ARE PASSED CORRECTLY " &
                      "TO SUBPROGRAMS");

     DECLARE   -- (A)

          TYPE ARRAY_TYPE IS ARRAY (POSITIVE RANGE <>) OF INTEGER;
          SUBTYPE ARRAY_SUBTYPE IS ARRAY_TYPE(1..IDENT_INT(5));
          TYPE RECORD_TYPE IS
               RECORD
                    I : INTEGER;
                    A : ARRAY_SUBTYPE;
               END RECORD;
          REC : RECORD_TYPE := (I => 23,
                                A => (1..3 => IDENT_INT(7), 4..5 => 9));
          BOOL : BOOLEAN;

          PROCEDURE P1 (ARR : ARRAY_TYPE) IS
          BEGIN
               IF ARR /= (7, 9, 9) THEN
                    FAILED ("IN PARAMETER NOT PASSED CORRECTLY");
               END IF;

               IF ARR'FIRST /= IDENT_INT(3) OR
                  ARR'LAST /= IDENT_INT(5) THEN
                    FAILED ("WRONG BOUNDS FOR IN PARAMETER");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE P1");
          END P1;

          FUNCTION F1 (ARR : ARRAY_TYPE) RETURN BOOLEAN IS
          BEGIN
               IF ARR /= (7, 7, 9) THEN
                    FAILED ("IN PARAMETER NOT PASSED CORRECTLY TO FN");
               END IF;
               IF ARR'FIRST /= IDENT_INT(2) OR
                  ARR'LAST /= IDENT_INT(4) THEN
                    FAILED ("WRONG BOUNDS FOR IN PARAMETER FOR FN");
               END IF;

               RETURN TRUE;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN FUNCTION F1");
          END F1;

          PROCEDURE P2 (ARR : IN OUT ARRAY_TYPE) IS
          BEGIN
               IF ARR /= (7, 7, 7, 9) THEN
                    FAILED ("IN OUT PARAMETER NOT PASSED " &
                            "CORRECTLY");
               END IF;
               IF ARR'FIRST /= IDENT_INT(1) OR
                  ARR'LAST /= IDENT_INT(4) THEN
                    FAILED ("WRONG BOUNDS FOR IN OUT PARAMETER");
               END IF;
               ARR := (ARR'RANGE => 5);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE P2");
          END P2;

          PROCEDURE P3 (ARR : OUT ARRAY_TYPE) IS
          BEGIN
               IF ARR'FIRST /= IDENT_INT(3) OR
                  ARR'LAST /= IDENT_INT(4) THEN
                    FAILED ("WRONG BOUNDS FOR OUT PARAMETER");
               END IF;

               ARR := (ARR'RANGE => 3);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE P3");
          END P3;

     BEGIN     -- (A)

          BEGIN     -- (B)
               P1 (REC.A (3..5));
               IF REC.A /= (7, 7, 7, 9, 9) THEN
                    FAILED ("IN PARAM CHANGED BY PROCEDURE");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED DURING CALL OF P1");
          END;     -- (B)

          BEGIN     -- (C)
               BOOL := F1 (REC.A (2..4));
               IF REC.A /= (7, 7, 7, 9, 9) THEN
                    FAILED ("IN PARAM CHANGED BY FUNCTION");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED DURING CALL OF F1");
          END;     -- (C)

          BEGIN     -- (D)
               P2 (REC.A (1..4));
               IF REC.A /= (5, 5, 5, 5, 9) THEN
                    FAILED ("IN OUT PARAM RETURNED INCORRECTLY");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED DURING CALL OF P2");
          END;     -- (D)

          BEGIN     -- (E)
               P3 (REC.A (3..4));
               IF REC.A /= (5, 5, 3, 3, 9) THEN
                    FAILED ("OUT PARAM RETURNED INCORRECTLY");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED DURING CALL OF P3");
          END;     -- (E)

     END; -- (A)

     RESULT;
END C64109H;
