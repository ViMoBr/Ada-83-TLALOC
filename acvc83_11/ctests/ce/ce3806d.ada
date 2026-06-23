-- CE3806D.ADA

-- OBJECTIVE:
--     CHECK THAT FLOAT_IO PUT OPERATES ON FILES OF MODE OUT_FILE AND
--     IF NO FILE IS SPECIFIED THE CURRENT DEFAULT OUTPUT FILE IS USED.

--- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     SPS 10/06/82
--     VKG 02/15/83
--     JBG 02/22/84  CHANGED TO .ADA TEST
--     RJW 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 09/14/87  REMOVED DEPENDENCE ON RESET AND CORRECT EXCEPTION
--                   HANDLING.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3806D IS

BEGIN

     TEST ("CE3806D", "CHECK THAT FLOAT_IO OPERATES ON FILES OF MODE " &
                      "OUT_FILE AND IF NO FILE IS SPECIFIED THE " &
                      "CURRENT DEFAULT OUTPUT FILE IS USED");

     DECLARE
          FT1, FT2 : FILE_TYPE;
          TYPE FL IS DIGITS 3;
          PACKAGE FLIO IS NEW FLOAT_IO (FL);
          USE FLIO;
          INCOMPLETE : EXCEPTION;
          X : FL := -1.5;

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

          CREATE (FT2, OUT_FILE, LEGAL_FILE_NAME(2));

          SET_OUTPUT (FT2);

          BEGIN
               PUT (FT1, X);
               PUT (X + 1.0);
               CLOSE (FT1);

               BEGIN
                    OPEN (FT1, IN_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT " &
                                         "OPEN WITH IN_FILE MODE");
                         RAISE INCOMPLETE;
               END;

               SET_OUTPUT (STANDARD_OUTPUT);

               CLOSE (FT2);
               OPEN (FT2, IN_FILE, LEGAL_FILE_NAME(2));

               X := 0.0;
               GET (FT1, X);
               IF X /= -1.5 THEN
                    FAILED ("VALUE INCORRECT - FLOAT FROM FILE");
               END IF;
               X := 0.0;
               GET (FT2, X);
               IF X /= -0.5 THEN
                    FAILED (" VVALUE INCORRECT - FLOAT FROM DEFAULT");
               END IF;
          END;

          BEGIN
               DELETE (FT1);
               DELETE (FT2);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;

     END;

     RESULT;

END CE3806D;
