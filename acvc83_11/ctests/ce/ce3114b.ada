-- CE3114B.ADA

-- OBJECTIVE:
--     CHECK WHETHER OR NOT AN EXTERNAL TEXT FILE ASSOCIATED WITH
--     MORE THAN ONE INTERNAL FILE MAY BE DELETED.

-- APPLICABLILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     MULTIPLE ACCESS TO EXTERNAL TEXT FILES.

-- HISTORY:
--     SPG 08/25/82
--     SPS 11/09/82
--     JBG 06/04/84
--     EG  11/19/85  MADE TEST INAPPLICABLE IF CREATE RAISES USE_ERROR.
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NON-APPLICABLE RESULT WHEN
--                   FILES ARE NOT SUPPORTED.
--     GMT 09/23/87  CORRECTED EXCEPTION HANDLING.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3114B IS
BEGIN

     TEST ("CE3114B", "CHECK WHETHER OR NOT AN EXTERNAL TEXT FILE " &
                      "ASSOCIATED WITH MORE THAN ONE INTERNAL " &
                      "FILE MAY BE DELETED");
     DECLARE
          FILE1, FILE2   : FILE_TYPE;
          OK_TO_CONTINUE : BOOLEAN :=TRUE;
     BEGIN
          BEGIN
               CREATE (FILE1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE WITH " &
                                    "OUT_FILE MODE - 1");
                    OK_TO_CONTINUE := FALSE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE " &
                                    "WITH OUT_FILE MODE - 2");
                    OK_TO_CONTINUE := FALSE;
          END;

          IF OK_TO_CONTINUE THEN
               BEGIN
                    OPEN (FILE2, IN_FILE, LEGAL_FILE_NAME);
                    BEGIN
                         DELETE (FILE1);
                         COMMENT ("EXTERNAL TEXT FILE DELETED - 3");
                    EXCEPTION
                         WHEN USE_ERROR =>
                              COMMENT ("UNABLE TO DELETE AN EXTERNAL" &
                                       "TEXT FILE ASSOCIATED WITH " &
                                       "MORE THAN ONE INTERNAL " &
                                       "FILE - 4");
                         WHEN OTHERS =>
                              FAILED ("UNEXPECTED EXCEPTION RAISED " &
                                      "ON TEXT FILE DELETE - 5");
                    END;
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("UNABLE TO CREATE MULTIPLE " &
                                         "ACCESS TO EXTERNAL TEXT " &
                                         "FILE WHEN ONE FILE IS " &
                                         "WRITING AND THE OTHER IS " &
                                         "READING - 6");
                         BEGIN
                              DELETE (FILE1);
                         EXCEPTION
                              WHEN USE_ERROR =>
                                   NULL;
                         END;
               END;
          END IF;
     END;

     RESULT;

END CE3114B;
