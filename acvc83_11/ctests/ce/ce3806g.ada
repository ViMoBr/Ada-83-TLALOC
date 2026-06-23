-- CE3806G.ADA

-- OBJECTIVE:
--     CHECK THAT FIXED_IO PUT OPERATES ON FILES OF MODE OUT_FILE AND
--     IF NO FILE IS SPECIFIED THE CURRENT DEFAULT OUTPUT FILE IS USED.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 09/13/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3806G IS

BEGIN

     TEST ("CE3806G", "CHECK THAT FIXED_IO PUT OPERATES ON FILES " &
                      "OF MODE OUT_FILE AND IF NO FILE IS SPECIFIED " &
                      "THE CURRENT DEFAULT OUTPUT FILE IS USED");

     DECLARE
          FT1, FT2 : FILE_TYPE;
          TYPE FX IS DELTA 0.5 RANGE -10.0 .. 10.0;
          PACKAGE FXIO IS NEW FIXED_IO (FX);
          USE FXIO;
          INCOMPLETE : EXCEPTION;
          X : FX := -1.5;

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
                    FAILED ("VALUE INCORRECT - FIXED FROM FILE");
               END IF;
               X := 0.0;
               GET (FT2, X);
               IF X /= -0.5 THEN
                    FAILED ("VALUE INCORRECT - FIXED FROM DEFAULT");
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

END CE3806G;
