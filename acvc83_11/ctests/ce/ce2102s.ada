-- CE2102S.ADA

-- OBJECTIVE:
--     CHECK THAT USE_ERROR IS RAISED WHEN RESETTING A FILE OF MODE
--     INOUT_FILE, WHEN INOUT_FILE MODE IS NOT SUPPORTED FOR RESET BY
--     THE IMPLEMENTATION FOR DIRECT FILES.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH DO NOT
--     SUPPORT RESET WITH INOUT_FILE MODE FOR DIRECT FILES.

-- HISTORY:
--     TBN 07/23/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2102S IS
BEGIN

     TEST ("CE2102S", "CHECK THAT USE_ERROR IS RAISED WHEN RESETTING " &
                      "A FILE OF MODE INOUT_FILE, WHEN INOUT_FILE " &
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

          BEGIN
               RESET (FILE1);
               NOT_APPLICABLE ("RESET FOR INOUT_FILE MODE IS " &
                               "SUPPORTED");
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON RESET");
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

END CE2102S;
