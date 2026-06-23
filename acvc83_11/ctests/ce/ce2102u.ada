-- CE2102U.ADA

-- OBJECTIVE:
--     CHECK THAT USE_ERROR IS RAISED WHEN RESETTING A FILE OF MODE
--     IN_FILE, WHEN IN_FILE MODE IS NOT SUPPORTED FOR RESET BY
--     THE IMPLEMENTATION FOR DIRECT FILES.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH DO NOT
--     SUPPORT RESET WITH IN_FILE MODE FOR DIRECT FILES.

-- HISTORY:
--     TBN 07/23/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2102U IS
BEGIN

     TEST ("CE2102U", "CHECK THAT USE_ERROR IS RAISED WHEN RESETTING " &
                      "A FILE OF MODE IN_FILE, WHEN IN_FILE " &
                      "MODE IS NOT SUPPORTED FOR RESET BY THE " &
                      "IMPLEMENTATION FOR DIRECT FILES");

     DECLARE
          PACKAGE DIR IS NEW DIRECT_IO (BOOLEAN);
          USE DIR;
          FILE1 : FILE_TYPE;
          INCOMPLETE : EXCEPTION;
          VAR1 : BOOLEAN := FALSE;
     BEGIN
          BEGIN
               CREATE (FILE1, INOUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE FOR " &
                                    "INOUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE FOR " &
                                    "INOUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          WRITE (FILE1, VAR1);
          CLOSE (FILE1);

          BEGIN
               BEGIN
                    OPEN (FILE1, IN_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("OPEN WITH IN_FILE MODE " &
                                         "NOT SUPPORTED");
                         RAISE INCOMPLETE;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED ON OPEN");
                         RAISE INCOMPLETE;
               END;

               BEGIN
                    RESET (FILE1);
                    NOT_APPLICABLE ("RESET FOR IN_FILE MODE IS " &
                                    "SUPPORTED");
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                                 "RESET");
               END;
          EXCEPTION
               WHEN INCOMPLETE =>
                    NULL;
          END;

          BEGIN
               DELETE (FILE1);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2102U;
