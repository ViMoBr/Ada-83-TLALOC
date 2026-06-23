-- CE3207A.ADA

-- OBJECTIVE:
--     CHECK THAT MODE_ERROR IS RAISED IF THE PARAMETER TO SET_INPUT HAS
--     MODE OUT_FILE OR THE PARAMETER TO SET_OUTPUT HAS MODE IN_FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 07/07/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3207A IS

     FILE1, FILE2 : FILE_TYPE;
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3207A", "CHECK THAT MODE_ERROR IS RAISED IF THE " &
                      "PARAMETER TO SET_INPUT HAS MODE OUT_FILE " &
                      "OR THE PARAMETER TO SET_OUTPUT HAS MODE " &
                      "IN_FILE");

     BEGIN

          BEGIN
               CREATE (FILE1, OUT_FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                    "WITH MODE OUT_FILE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               SET_INPUT (FILE1);
               FAILED ("MODE_ERROR NOT RAISED FOR SET_INPUT WITH " &
                       "MODE OUT_FILE");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED FOR SET_INPUT");
          END;

          CREATE (FILE2, OUT_FILE, LEGAL_FILE_NAME);

          PUT (FILE2, "OUTPUT STRING");
          CLOSE (FILE2);
          OPEN (FILE2, IN_FILE, LEGAL_FILE_NAME);

          BEGIN
               SET_OUTPUT (FILE2);
               FAILED ("MODE_ERROR NOT RAISED FOR SET_OUTPUT WITH " &
                       "MODE IN_FILE");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED FOR SET_OUTPUT");
          END;

          BEGIN
               DELETE (FILE2);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3207A;
