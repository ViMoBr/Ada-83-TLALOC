-- CB3003B.ADA

-- CHECK THAT A NON-EXPLICIT RAISE STATEMENT MAY APPEAR IN A BLOCK
-- STATEMENT WITHIN AN EXCEPTION HANDLER; IF THE BLOCK STATEMENT
-- INCLUDES A HANDLER FOR THE CURRENT EXCEPTION, THEN THE INNER
-- HANDLER RECEIVES CONTROL.

-- L.BROWN  10/08/86

WITH REPORT; USE REPORT;

PROCEDURE  CB3003B  IS

     MY_ERROR : EXCEPTION;

BEGIN
     TEST("CB3003B","A NON-EXPLICIT RAISE STATEMENT MAY APPEAR IN A "&
                    "BLOCK STATEMENT WITHIN AN EXCEPTION HANDLER");

     BEGIN
          BEGIN
               IF EQUAL(3,3) THEN
                    RAISE MY_ERROR;
               END IF;
               FAILED("MY_ERROR WAS NOT RAISED 1");
          EXCEPTION
               WHEN MY_ERROR =>
                    BEGIN
                         IF EQUAL(3,3) THEN
                              RAISE;
                         END IF;
                         FAILED("MY_ERROR WAS NOT RAISED 2");
                    EXCEPTION
                         WHEN MY_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED("WRONG EXCEPTION RAISED 1");
                    END;
               WHEN OTHERS =>
                    FAILED("WRONG EXCEPTION RAISED 2");
          END;
     EXCEPTION
          WHEN MY_ERROR =>
               FAILED("CONTROL PASSED TO OUTER HANDLER 1");
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED 1");
     END;

     BEGIN
          BEGIN
               IF EQUAL(3,3) THEN
                    RAISE MY_ERROR;
               END IF;
               FAILED("MY_ERROR WAS NOT RAISED 3");
          EXCEPTION
               WHEN CONSTRAINT_ERROR | MY_ERROR | NUMERIC_ERROR =>
                    BEGIN
                         IF EQUAL(3,3) THEN
                              RAISE;
                         END IF;
                         FAILED("MY_ERROR WAS NOT RAISED 4");
                    EXCEPTION
                         WHEN MY_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED("WRONG EXCEPTION RAISED 3");
                    END;
               WHEN OTHERS =>
                    FAILED("WRONG EXCEPTION RAISED 4");
          END;
     EXCEPTION
          WHEN MY_ERROR =>
               FAILED("CONTROL PASSED TO OUTER HANDLER 2");
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED 2");
     END;

     BEGIN
          BEGIN
               IF EQUAL(3,3) THEN
                    RAISE MY_ERROR;
               END IF;
               FAILED("MY_ERROR WAS NOT RAISED 5");
          EXCEPTION
               WHEN OTHERS =>
                    BEGIN
                         IF EQUAL(3,3) THEN
                              RAISE;
                         END IF;
                         FAILED("MY_ERROR WAS NOT RAISED 6");
                    EXCEPTION
                         WHEN MY_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED("WRONG EXCEPTION RAISED 5");
                    END;
          END;
     EXCEPTION
          WHEN MY_ERROR =>
               FAILED("CONTROL PASSED TO OUTER HANDLER 3");
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED 3");
     END;

     RESULT;

END CB3003B;
