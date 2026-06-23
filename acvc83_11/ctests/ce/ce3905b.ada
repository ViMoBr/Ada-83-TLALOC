-- CE3905B.ADA

-- OBJECTIVE:
--     CHECK THAT GET FOR ENUMERATION TYPES RAISE MODE_ERROR WHEN THE
--     MODE OF THE FILE SPECIFIED IS OUT_FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH
--     SUPPORT CREATE FOR TEMP FILES WITH OUT_FILE.

-- HISTORY:
--     SPS 10/07/82
--     JBG 02/22/84  CHANGED TO .ADA TEST.
--     TBN 11/10/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     DWC 09/16/87  CORRECTED EXCEPTION HANDLING.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3905B IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3905B", "CHECK THAT ENUMERATION_IO GET RAISES " &
                      "MODE_ERROR WHEN THE MODE OF THE FILE IS " &
                      "OUT_FILE");

     DECLARE
          FT : FILE_TYPE;
          TYPE COLOR IS (RED, BLUE, GREEN, YELLOW);
          X : COLOR;
          PACKAGE COLOR_IO IS NEW ENUMERATION_IO (COLOR);
          USE COLOR_IO;
     BEGIN

          BEGIN
               CREATE (FT, OUT_FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; TEXT CREATE " &
                                    "FOR TEMP FILES WITH OUT_FILE " &
                                    "MODE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               GET (FT, X);
               FAILED ("MODE_ERROR NOT RAISED - FILE");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FILE");
          END;

          BEGIN
               GET (STANDARD_OUTPUT, X);
               FAILED ("MODE_ERROR NOT RAISED - STANDARD_OUTPUT");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - STANDARD_OUTPUT");
          END;

          BEGIN
               GET (CURRENT_OUTPUT, X);
               FAILED ("MODE_ERROR NOT RAISED - CURRENT_OUTPUT");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CURRENT_OUTPUT");
          END;

          CLOSE (FT);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3905B;
