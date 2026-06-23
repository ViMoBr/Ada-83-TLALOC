-- CE3806A.ADA

-- OBJECTIVE:
--     CHECK THAT PUT FOR FLOAT_IO RAISES MODE_ERROR FOR FILES OF
--     MODE IN_FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     SPS 09/10/82
--     JBG 02/22/84  CHANGED TO .ADA TEST
--     RJW 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 09/11/87  REMOVED DEPENDENCE ON RESET AND CORRECTED
--                   EXCEPTION HANDLING.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3806A IS

BEGIN

     TEST ("CE3806A", "CHECK THAT PUT FOR FLOAT_IO RAISES MODE_ERROR " &
                      "FOR FILES OF MODE IN_FILE");

     DECLARE
          FT1 : FILE_TYPE;
          PACKAGE FL_IO IS NEW FLOAT_IO (FLOAT);
          USE FL_IO;
          INCOMPLETE : EXCEPTION;
          X : FLOAT := -34.267/19.2;

     BEGIN

          BEGIN
               CREATE (FT1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON TEXT " &
                                    "CREATE WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          PUT (FT1, 'A');
          CLOSE (FT1);

          BEGIN
               OPEN (FT1, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT OPEN " &
                                    "WITH IN_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               PUT (FT1, X);
               FAILED ("MODE_ERROR NOT RAISED - 1");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 1");
          END;

          BEGIN
               PUT (STANDARD_INPUT, X);
               FAILED ("MODE_ERROR NOT RAISED - 2");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 2");
          END;

          BEGIN
               PUT (CURRENT_INPUT, X);
               FAILED ("MODE_ERROR NOT RAISED - 3");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 3");
          END;

          BEGIN
               DELETE (FT1);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;

     END;

     RESULT;

END CE3806A;
