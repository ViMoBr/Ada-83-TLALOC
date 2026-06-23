-- CE2119B.ADA

-- OBJECTIVE:
--     CHECK THAT FORM RETURNS THE FORM STRING FOR THE EXTERNAL FILE FOR
--     DIRECT_IO.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     DIRECT FILES.

-- HISTORY:
--     JLH 07/07/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2119B IS

     PACKAGE DIR_IO IS NEW DIRECT_IO (INTEGER);
          USE DIR_IO;

     FILE, FILE1, FILE2 : FILE_TYPE;
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE2119B", "CHECK THAT FORM RETURNS THE FORM STRING FOR " &
                      "THE EXTERNAL FILE FOR DIRECT_IO");

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

          WRITE (FILE, 3);

          BEGIN
               CREATE (FILE1, OUT_FILE, LEGAL_FILE_NAME(2), FORM(FILE));
          EXCEPTION
               WHEN USE_ERROR =>
                    FAILED ("USE_ERROR RAISED FOR CREATE WITH LEGAL " &
                            "FORM SPECIFICATION");
                    RAISE INCOMPLETE;
          END;

          CLOSE (FILE);
          WRITE (FILE1, 3);

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

END CE2119B;
