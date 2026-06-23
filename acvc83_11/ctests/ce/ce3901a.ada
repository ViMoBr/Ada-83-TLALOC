-- CE3901A.ADA

-- OBJECTIVE:
--     CHECK THAT GET AND PUT FOR ENUMERATED TYPES RAISE STATUS ERROR
--     IF THE FILE IS NOT OPEN.

-- HISTORY:
--     SPS 10/07/82
--     JBG 02/22/84  CHANGED TO .ADA TEST
--     DWC 09/16/87  ADDED AN ATTEMPT TO CREATE A FILE AND THEN
--                   RETESTED OBJECTIVE.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3901A IS
BEGIN

     TEST ("CE3901A", "CHECK THAT GET AND PUT FOR ENUMERATED TYPES " &
                      "RAISE STATUS ERROR IF THE FILE IS NOT OPEN.");

     DECLARE
          TYPE COLOR IS (RED, BLUE, GREEN, ORANGE, YELLOW);
          FT : FILE_TYPE;
          PACKAGE COLOR_IO IS NEW ENUMERATION_IO (COLOR);
          USE COLOR_IO;
          X : COLOR;
     BEGIN
          BEGIN
               PUT (FT, RED);
               FAILED ("STATUS_ERROR NOT RAISED - PUT - 1");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT - 1");
          END;

          BEGIN
               GET (FT, X);
               FAILED ("STATUS_ERROR NOT RAISED - GET - 1");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET - 1");
          END;

          BEGIN
               CREATE (FT, OUT_FILE, LEGAL_FILE_NAME);  -- THIS IS JUST
               CLOSE (FT);                   -- AN ATTEMPT TO CREATE A
          EXCEPTION                          -- FILE.  OBJECTIVE IS MET
               WHEN USE_ERROR =>             -- EITHER WAY.
                    NULL;
          END;

          BEGIN
               PUT (FT, RED);
               FAILED ("STATUS_ERROR NOT RAISED - PUT - 2");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT - 2");
          END;

          BEGIN
               GET (FT, X);
               FAILED ("STATUS_ERROR NOT RAISED - GET - 2");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET - 2");
          END;
     END;

     RESULT;

END CE3901A;
