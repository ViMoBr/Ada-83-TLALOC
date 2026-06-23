-- CE2110C.ADA

-- OBJECTIVE:
--     CHECK THAT AN EXTERNAL FILE CEASES TO EXIST AFTER A SUCCESSFUL
--     DELETE.

-- APPLICABILITY CRITERIA:
--    THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--    CREATION AND DELETION OF DIRECT FILES.

-- HISTORY:
--     SPS 08/25/82
--     SPS 11/09/82
--     JBG 04/01/83
--     EG  05/31/85
--     JLH 07/21/87  ADDED A CALL TO NOT_APPLICABLE IF EXCEPTION
--                   USE_ERROR IS RAISED ON DELETE.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2110C IS
BEGIN

     TEST ("CE2110C", "CHECK THAT THE EXTERNAL FILE CEASES TO EXIST " &
                      "AFTER A SUCCESSFUL DELETE");

     DECLARE
          PACKAGE DIR IS NEW DIRECT_IO (INTEGER);
          USE DIR;
          FL1, FL2 : FILE_TYPE;
          VAR1 : INTEGER := 5;
          INCOMPLETE : EXCEPTION;
     BEGIN
          BEGIN
               CREATE (FL1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXCEPTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               WRITE (FL1, VAR1);     -- THIS WRITES TO THE FILE IF IT
          EXCEPTION                   -- CAN, NOT NECESSARY FOR THE
               WHEN OTHERS =>         -- OBJECTIVE.
                    NULL;
          END;

          BEGIN
               DELETE (FL1);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("DELETION OF EXTERNAL FILE NOT " &
                                    "SUPPORTED");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               OPEN (FL2, IN_FILE, LEGAL_FILE_NAME);
               FAILED ("EXTERNAL FILE STILL EXISTS AFTER " &
                       "A SUCCESSFUL DELETION - DIR");
          EXCEPTION
               WHEN NAME_ERROR =>
                    NULL;
          END;
     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2110C;
