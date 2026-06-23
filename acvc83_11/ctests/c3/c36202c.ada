-- C36202C.ADA

-- CHECK THAT 'LENGTH DOES NOT RAISE NUMERIC_ERROR (OR ANY OTHER 
-- EXCEPTION) WHEN APPLIED TO A NULL ARRAY A, EVEN IF A'LAST - A'FIRST 
-- WOULD RAISE NUMERIC_ERROR/CONSTRAINT_ERROR.

-- L.BROWN  07/29/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;

PROCEDURE C36202C IS

     TYPE LRG_INT IS RANGE MIN_INT .. MAX_INT;

     BEGIN
          TEST("C36202C", "NO EXCEPTION IS RAISED FOR 'LENGTH "&
                          "WHEN APPLIED TO A NULL ARRAY");
              
          DECLARE
               TYPE LRG_ARR IS ARRAY
                              (LRG_INT RANGE MAX_INT .. MIN_INT)
                                     OF INTEGER;
               LRG_OBJ : LRG_ARR;

          BEGIN
               IF LRG_OBJ'LENGTH /= 0  THEN
                    FAILED("INCORRECT VALUE RETURNED BY 'LENGTH " &
                           "FOR ONE-DIM NULL ARRAY");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED("CONSTRAINT_ERROR WAS RAISED " &
                           "FOR ONE-DIM NULL ARRAY");
               WHEN NUMERIC_ERROR =>
                    FAILED("NUMERIC_ERROR WAS RAISED FOR " &
                           "ONE-DIM NULL ARRAY");
               WHEN OTHERS =>
                    FAILED("EXCEPTION RAISED FOR ONE-DIM " &
                           "NULL ARRAY");
          END;

          DECLARE
               TYPE LRG2_ARR IS ARRAY (LRG_INT RANGE 1 .. 3 ,
                                LRG_INT RANGE MAX_INT .. MIN_INT)
                                OF INTEGER;
          BEGIN
               IF LRG2_ARR'LENGTH(2) /= 0  THEN
                    FAILED("INCORRECT VALUE RETURNED BY 'LENGTH " &
                           "FOR TWO-DIM NULL ARRAY");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED("CONSTRAINT_ERROR WAS RAISED " &
                           "FOR TWO-DIM NULL ARRAY");
               WHEN NUMERIC_ERROR =>
                    FAILED("NUMERIC_ERROR WAS RAISED FOR " &
                           "TWO-DIM NULL ARRAY");
               WHEN OTHERS =>
                    FAILED("EXCEPTION RAISED FOR TWO-DIM " &
                           "NULL ARRAY");
          END;

     RESULT;

     END C36202C;
