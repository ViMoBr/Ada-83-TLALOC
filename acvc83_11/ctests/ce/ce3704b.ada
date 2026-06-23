-- CE3704B.ADA

-- OBJECTIVE:
--     CHECK THAT INTEGER_IO GET RAISES MODE_ERROR FOR FILES OF MODE
--     OUT_FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH
--     SUPPORT TEXT FILES.

-- HISTORY:
--     SPS 10/04/82
--     JBG 02/22/84  CHANGED TO .ADA TEST
--     RJW 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     DWC 09/09/87  CORRECTED EXCEPTION HANDLING.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3704B IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3704B", "CHECK THAT INTEGER_IO GET RAISES " &
                      "MODE_ERROR FOR FILES OF MODE OUT_FILE");

     DECLARE
          FT : FILE_TYPE;
          TYPE INT IS NEW INTEGER RANGE 1 .. 10;
          PACKAGE IIO IS NEW INTEGER_IO (INT);
          USE IIO;
          X : INT := 10;
     BEGIN

          BEGIN
               CREATE (FT, OUT_FILE);
               PUT (FT, '3');
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; TEXT CREATE " &
                                    "FOR TEMP FILE WITH OUT_FILE MODE");
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

END CE3704B;
