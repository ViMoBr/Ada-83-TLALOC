
-- CE2201L.ADA

-- OBJECTIVE:
--     CHECK THAT READ, WRITE, AND END_OF_FILE ARE SUPPORTED FOR
--     SEQUENTIAL FILES WITH ELEMENT TYPE FIXED.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     SEQUENTIAL FILES.

-- HISTORY:
--     JLH 08/03/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2201L IS
BEGIN

     TEST ("CE2201L", "CHECK THAT READ, WRITE, AND END_OF_FILE " &
                      "ARE SUPPORTED FOR SEQUENTIAL FILES - FIXED");

     DECLARE
          TYPE FIX IS DELTA 0.5 RANGE -10.0 .. 255.0;
          PACKAGE SEQ_FIX IS NEW SEQUENTIAL_IO (FIX);
          USE SEQ_FIX;
          FILE_FIX : FILE_TYPE;
          INCOMPLETE : EXCEPTION;
          FX : FIX := -8.5;
          ITEM_FIX : FIX;
     BEGIN
          BEGIN
               CREATE (FILE_FIX, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR | NAME_ERROR =>
                    NOT_APPLICABLE ("CREATE OF SEQUENTIAL FILE WITH " &
                                    "MODE OUT_FILE NOT SUPPORTED");
                    RAISE INCOMPLETE;
          END;

          WRITE (FILE_FIX, FX);
          CLOSE (FILE_FIX);

          BEGIN
               OPEN (FILE_FIX, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("OPEN OF SEQUENTIAL FILE WITH " &
                                    "MODE IN_FILE NOT SUPPORTED");
                    RAISE INCOMPLETE;
          END;

          IF END_OF_FILE (FILE_FIX) THEN
               FAILED ("WRONG END_OF_FILE VALUE FOR FIXED POINT");
          END IF;

          READ (FILE_FIX, ITEM_FIX);

          IF NOT END_OF_FILE (FILE_FIX) THEN
               FAILED ("END OF FILE NOT TRUE - FIXED");
          END IF;

          IF ITEM_FIX /= -8.5 THEN
               FAILED ("READ WRONG VALUE - STRING");
          END IF;

          BEGIN
               DELETE (FILE_FIX);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2201L;
