-- CE2201M.ADA

-- OBJECTIVE:
--     CHECK THAT READ, WRITE, AND END_OF_FILE ARE SUPPORTED
--     FOR SEQUENTIAL FILES WITH ELEMENT_TYPE RECORD WITHOUT
--     DISCRIMINANTS.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH
--     SUPPORT SEQUENTIAL FILES WITH ELEMENT_TYPE RECORD WITHOUT
--     DISCRIMINANTS.

-- HISTORY:
--     ABW 08/17/82
--     SPS 09/15/82
--     SPS 11/09/82
--     JBG 05/02/83
--     EG  05/08/85
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 07/28/87  REMOVED THE DEPENDENCE OF RESET BEING SUPPORTED
--                   AND CREATED EXTERNAL FILES RATHER THAN TEMPORARY
--                   FILES.

WITH REPORT;
USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2201M IS

BEGIN

     TEST ("CE2201M", "CHECK THAT READ, WRITE, AND " &
                      "END_OF_FILE ARE SUPPORTED FOR " &
                      "SEQUENTIAL FILES - RECORD WITHOUT " &
                      "DISCRIMINANTS");

     DECLARE
          TYPE REC IS
               RECORD
                    ONE : INTEGER;
                    TWO : INTEGER;
               END RECORD;
          PACKAGE SEQ_REC IS NEW SEQUENTIAL_IO (REC);
          USE SEQ_REC;
          FILE_REC : FILE_TYPE;
          INCOMPLETE : EXCEPTION;
          REC1 : REC := (ONE=>18, TWO=>36);
          ITEM_REC1 : REC;
     BEGIN

          BEGIN
               CREATE (FILE_REC, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR | NAME_ERROR =>
                    NOT_APPLICABLE ("CREATE OF SEQUENTIAL FILE WITH " &
                                    "MODE OUT_FILE NOT SUPPORTED");
                    RAISE INCOMPLETE;
          END;

          WRITE (FILE_REC, REC1);
          CLOSE (FILE_REC);

          BEGIN
               OPEN (FILE_REC, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("OPEN OF SEQUENTIAL FILE WITH " &
                                    "MODE IN_FILE NOT SUPPORTED");
                    RAISE INCOMPLETE;
          END;

          IF END_OF_FILE (FILE_REC) THEN
               FAILED ("WRONG END_OF_FILE VALUE FOR TYPE RECORD");
          END IF;

          READ (FILE_REC, ITEM_REC1);

          IF ITEM_REC1 /= (18, IDENT_INT(36)) THEN
               FAILED ("READ WRONG VALUE - RECORD");
          END IF;

          IF NOT END_OF_FILE (FILE_REC) THEN
               FAILED ("END OF FILE NOT TRUE - RECORD");
          END IF;

          BEGIN
               DELETE (FILE_REC);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2201M;
