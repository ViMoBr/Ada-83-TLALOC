-- CE3104B.ADA

-- OBJECTIVE:
--     CHECK THAT THE FILE REMAINS OPEN AFTER A RESET.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     DWC 08/13/87  CREATED ORIGINAL TEST.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3104B IS

     INCOMPLETE : EXCEPTION;
     FILE   : FILE_TYPE;
     ITEM1  : STRING (1..5) := "STUFF";

BEGIN

     TEST ("CE3104B", "CHECK THAT THE FILE REMAINS OPEN AFTER " &
                      "A RESET");

     BEGIN
          CREATE (FILE, OUT_FILE, LEGAL_FILE_NAME);
          PUT_LINE (FILE, ITEM1);
          CLOSE (FILE);
     EXCEPTION
          WHEN USE_ERROR | NAME_ERROR =>
               NOT_APPLICABLE ("CREATE WITH OUT_FILE MODE " &
                               "NOT SUPPORTED");
               RAISE INCOMPLETE;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED DURING " &
                       "FILE I/O");
               RAISE INCOMPLETE;
     END;

     BEGIN
          OPEN (FILE, IN_FILE, LEGAL_FILE_NAME);
     EXCEPTION
          WHEN USE_ERROR =>
               NOT_APPLICABLE ("OPEN WITH IN_FILE MODE NOT " &
                               "SUPPORTED");
               RAISE INCOMPLETE;
     END;

     BEGIN
          RESET (FILE);
     EXCEPTION
          WHEN USE_ERROR =>
               NULL;
     END;

     IF IS_OPEN (FILE) THEN
          CLOSE (FILE);
     ELSE
          FAILED ("RESET FOR IN_FILE, CLOSED FILE");
     END IF;

     BEGIN
          OPEN (FILE, OUT_FILE, LEGAL_FILE_NAME);
     EXCEPTION
          WHEN USE_ERROR =>
               NOT_APPLICABLE ("OPEN WITH OUT_FILE MODE NOT " &
                               "SUPPORTED");
               RAISE INCOMPLETE;
     END;

     BEGIN
          RESET (FILE);
     EXCEPTION
          WHEN USE_ERROR =>
               NULL;
     END;

     IF IS_OPEN (FILE) THEN
          BEGIN
               DELETE (FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;
     ELSE
          FAILED ("RESET FOR OUT_FILE CLOSED FILE");
     END IF;

     RESULT;

EXCEPTION
     WHEN INCOMPLETE =>
          RESULT;
END CE3104B;
