-- CB3003A.ADA

-- CHECK THAT THE NON-SPECIFIC RAISE STATEMENT PROPAGATES THE EXCEPTION
--    FOR FURTHER PROCESSING(HANDLING) IN ANOTHER HANDLER.

-- DCB 04/01/80
-- JRK 11/19/80
-- SPS 11/2/82

WITH REPORT;
PROCEDURE CB3003A IS

     USE REPORT;

     FLOW_COUNT : INTEGER := 0;
     E1,E2 : EXCEPTION;

BEGIN
     TEST("CB3003A","CHECK THAT THE NON-SPECIFIC RAISE STATEMENT" &
          " PROPAGATES THE ERROR FOR FURTHER HANDLING IN ANOTHER" &
          " HANDLER");

     -------------------------------------------------------

     BEGIN
          BEGIN
               BEGIN
                    FLOW_COUNT := FLOW_COUNT + 1;
                    RAISE E1;
                    FAILED("EXCEPTION NOT RAISED (CASE 1)");
               EXCEPTION
                    WHEN OTHERS =>
                         FLOW_COUNT := FLOW_COUNT + 1;
                         RAISE;
                         FAILED("EXCEPTION NOT RERAISED (CASE 1; " &
                                "INNER)");
               END;

          EXCEPTION
          -- A HANDLER SPECIFIC TO THE RAISED EXCEPTION (E1).
               WHEN E1 =>
                    FLOW_COUNT := FLOW_COUNT + 1;
                    RAISE;
                    FAILED("EXCEPTION NOT RERAISED (CASE 1; OUTER)");
               WHEN OTHERS =>
                    FAILED("WRONG EXCEPTION RAISED (CASE 1)");
          END;

     EXCEPTION
          WHEN E1 =>
               FLOW_COUNT := FLOW_COUNT + 1;
          WHEN OTHERS =>
               FAILED("WRONG EXCEPTION PASSED (CASE 1)");
     END;

     -------------------------------------------------------

     BEGIN
          BEGIN
               BEGIN
                    FLOW_COUNT := FLOW_COUNT + 1;
                    RAISE E1;
                    FAILED("EXCEPTION NOT RAISED (CASE 2)");
               EXCEPTION
                    WHEN OTHERS =>
                         FLOW_COUNT := FLOW_COUNT + 1;
                         RAISE;
                         FAILED("EXCEPTION NOT RERAISED (CASE 2; " &
                                "INNER)");
               END;

          EXCEPTION
          -- A HANDLER FOR SEVERAL EXCEPTIONS INCLUDING THE ONE RAISED.
               WHEN CONSTRAINT_ERROR =>
                    FAILED("WRONG EXCEPTION RAISED (CONSTRAINT_ERROR)");
               WHEN E2 =>
                    FAILED("WRONG EXCEPTION RAISED (E2)");
               WHEN NUMERIC_ERROR =>
                    FAILED("WRONG EXCEPTION RAISED (NUMERIC_ERROR)");
               WHEN PROGRAM_ERROR | E1 | TASKING_ERROR =>
                    FLOW_COUNT := FLOW_COUNT + 1;
                    RAISE;
                    FAILED("EXCEPTION NOT RERAISED (CASE 2; OUTER)");
               WHEN STORAGE_ERROR =>
                    FAILED("WRONG EXCEPTION RAISED (STORAGE_ERROR)");
               WHEN OTHERS =>
                    FAILED("WRONG EXCEPTION RAISED (OTHERS)");
          END;

     EXCEPTION
          WHEN E1 =>
               FLOW_COUNT := FLOW_COUNT + 1;
          WHEN OTHERS =>
               FAILED("WRONG EXCEPTION PASSED (CASE 2)");
     END;

     -------------------------------------------------------

     BEGIN
          BEGIN
               BEGIN
                    FLOW_COUNT := FLOW_COUNT + 1;
                    RAISE E1;
                    FAILED("EXCEPTION NOT RAISED (CASE 3)");
               EXCEPTION
                    WHEN OTHERS =>
                         FLOW_COUNT := FLOW_COUNT + 1;
                         RAISE;
                         FAILED("EXCEPTION NOT RERAISED (CASE 3; " &
                                "INNER)");
               END;

          EXCEPTION
          -- A NON-SPECIFIC HANDLER.
               WHEN CONSTRAINT_ERROR | E2 =>
                    FAILED("WRONG EXCEPTION RAISED " &
                           "(CONSTRAINT_ERROR | E2)");
               WHEN OTHERS =>
                    FLOW_COUNT := FLOW_COUNT + 1;
                    RAISE;
                    FAILED("EXCEPTION NOT RERAISED (CASE 3; OUTER)");
          END;

     EXCEPTION
          WHEN E1 =>
               FLOW_COUNT := FLOW_COUNT + 1;
          WHEN OTHERS =>
               FAILED("WRONG EXCEPTION PASSED (CASE 3)");
     END;

     -------------------------------------------------------

     IF FLOW_COUNT /= 12 THEN
          FAILED("INCORRECT FLOW_COUNT VALUE");
     END IF;

     RESULT;
END CB3003A;
