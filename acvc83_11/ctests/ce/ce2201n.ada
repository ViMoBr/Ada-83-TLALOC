-- CE2201N.ADA

-- OBJECTIVE:
--     CHECK THAT READ, WRITE, AND END_OF_FILE ARE SUPPORTED FOR
--     SEQUENTIAL FILES WITH ELEMENT_TYPE CONSTRAINED RECORD TYPES.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     SEQUENTIAL FILES WITH ELEMENT_TYPE CONSTRAINED RECORD TYPES.

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

PROCEDURE CE2201N IS

BEGIN

     TEST ("CE2201N", "CHECK THAT READ, WRITE, AND " &
                      "END_OF_FILE ARE SUPPORTED FOR " &
                      "SEQUENTIAL FILES - CONSTRAINED RECORDS");

     DECLARE
          TYPE REC_DEF (DISCR : INTEGER := 18) IS
               RECORD
                    ONE : INTEGER := 1;
                    TWO : INTEGER := 2;
                    THREE : INTEGER := 17;
                    FOUR : INTEGER := 2;
               END RECORD;
          SUBTYPE REC_DEF_2 IS REC_DEF(2);
          PACKAGE SEQ_REC_DEF IS NEW SEQUENTIAL_IO (REC_DEF_2);
          USE SEQ_REC_DEF;
          FILE_REC_DEF : FILE_TYPE;
          INCOMPLETE : EXCEPTION;
          REC3 : REC_DEF(2);
          ITEM_REC3 : REC_DEF(2);
     BEGIN
          BEGIN
               CREATE (FILE_REC_DEF, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR | NAME_ERROR =>
                    NOT_APPLICABLE ("CREATE OF SEQUENTIAL FILE WITH " &
                                    "MODE OUT_FILE NOT SUPPORTED");
                    RAISE INCOMPLETE;
          END;

          WRITE (FILE_REC_DEF, REC3);
          CLOSE (FILE_REC_DEF);

          BEGIN
               OPEN (FILE_REC_DEF, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("OPEN OF SEQUENTIAL FILE WITH " &
                                    "MODE IN_FILE NOT SUPPORTED");
                    RAISE INCOMPLETE;
          END;

          IF END_OF_FILE (FILE_REC_DEF) THEN
               FAILED ("WRONG END_OF_FILE VALUE FOR RECORD" &
                       "WITH DEFAULT");
          END IF;

          READ (FILE_REC_DEF, ITEM_REC3);

          IF ITEM_REC3 /= (2, IDENT_INT(1),2,17,2) THEN
               FAILED ("READ WRONG VALUE - RECORD WITH DEFAULT");
          END IF;

          IF NOT END_OF_FILE (FILE_REC_DEF) THEN
               FAILED ("END OF FILE NOT TRUE - RECORD WITH DEFAULT");
          END IF;

          BEGIN
               DELETE (FILE_REC_DEF);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2201N;
