-- CE3118A.ADA

-- OBJECTIVE:
--     CHECK THAT FORM RETURNS THE FORM STRING FOR THE EXTERNAL FILE FOR
--     TEXT_IO.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 07/07/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3118A IS

     FILE, FILE1, FILE2 : FILE_TYPE;
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3118A", "CHECK THAT FORM RETURNS THE FORM STRING FOR " &
                      "THE EXTERNAL FILE FOR TEXT_IO");

     BEGIN

          BEGIN
               CREATE (FILE, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                    "WITH MODE OUT_FILE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE " &
                                    "WITH MODE OUT_FILE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          PUT (FILE, 'A');

          BEGIN
               CREATE (FILE1, OUT_FILE, LEGAL_FILE_NAME(2), FORM(FILE));
          EXCEPTION
               WHEN USE_ERROR =>
                    FAILED ("USE_ERROR RAISED FOR CREATE WITH LEGAL " &
                            "FORM SPECIFICATION");
                    RAISE INCOMPLETE;
          END;

          CLOSE (FILE);
          PUT (FILE1, 'A');

          BEGIN
               OPEN (FILE2, IN_FILE, LEGAL_FILE_NAME, FORM(FILE1));
          EXCEPTION
               WHEN USE_ERROR =>
                    FAILED ("USE_ERROR RAISED FOR OPEN WITH DEFAULT " &
                            "FORM SPECIFICATION");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               DELETE (FILE1);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
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

END CE3118A;
