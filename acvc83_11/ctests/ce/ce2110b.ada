-- CE2110B.ADA

-- OBJECTIVE:
--     CHECK WHETHER OR NOT AN EXTERNAL FILE ASSOCIATED WITH MORE THAN
--     ONE INTERNAL FILE MAY BE DELETED.

-- APPLICABLILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     MULTIPLE ACCESS TO SEQUENTIAL EXTERNAL FILES.

-- HISTORY:
--     SPS 08/25/82
--     SPS 11/09/82
--     JBG 06/04/84
--     JLH 07/21/87  EXPANDED LOGIC FOR OTHER POSSIBLE DELETE ACTIONS.

WITH REPORT;
USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2110B IS
BEGIN

     TEST ("CE2110B", "CHECK EFFECT OF DELETE FOR EXTERNAL FILE " &
                      "ASSOCIATED WITH MULTIPLE INTERNAL FILES " &
                      "FOR SEQUENTIAL FILES");

     DECLARE
          PACKAGE SEQ IS NEW SEQUENTIAL_IO (INTEGER);
          USE SEQ;
          FILE1, FILE2 : FILE_TYPE;
          CONT : BOOLEAN :=TRUE;
     BEGIN
          BEGIN
               CREATE (FILE1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR | NAME_ERROR  =>
                    NOT_APPLICABLE ("CREATE WITH OUT_FILE MODE NOT " &
                                    "SUPPORTED FOR SEQUENTIAL FILES");
                    CONT := FALSE;
          END;

          IF CONT THEN
               BEGIN
                    OPEN (FILE2, IN_FILE, LEGAL_FILE_NAME);
                    BEGIN
                         DELETE (FILE1);
                         COMMENT ("EXTERNAL FILE DELETED");
                    EXCEPTION
                         WHEN USE_ERROR =>
                              COMMENT ("UNABLE TO DELETE AN EXTERNAL" &
                                       "FILE ASSOCIATED WITH MORE " &
                                       "THAN ONE INTERNAL FILE");
                         WHEN OTHERS =>
                              FAILED ("UNEXPECTED EXCEPTION RAISED " &
                                      "ON DELETE");
                    END;
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("UNABLE TO CREATE MULTIPLE " &
                                         "ACCESS TO EXTERNAL SEQ " &
                                         "FILE");
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

END CE2110B;
