-- CE3411A.ADA

-- OBJECTIVE:
--     CHECK THAT COL RETURNS THE VALUE OF THE CURRENT COLUMN NUMBER.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     SPS 09/29/82
--     JBG 08/30/83
--     TBN 11/10/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 09/02/87  REMOVED DEPENDENCE ON RESET AND CHECKED FOR
--                   USE_ERROR ON DELETE.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3411A IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3411A", "CHECK THAT COL RETURNS THE VALUE OF THE " &
                      "CURRENT COLUMN NUMBER");

     DECLARE
          FT        : FILE_TYPE;
          X         : CHARACTER;
          NUM_CHARS : POSITIVE_COUNT;
     BEGIN

          BEGIN
               CREATE (FT, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON TEXT " &
                                    "CREATE WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON TEXT " &
                            "CREATE");
                    RAISE INCOMPLETE;
          END;

          PUT (FT, "OUTPUT STRING");
          IF COL (FT) /= 14 THEN
               FAILED ("COL INCORRECT AFTER PUT; IS" &
                       COUNT'IMAGE(COL(FT)));
          END IF;

          NEW_LINE (FT);
          IF COL (FT) /= 1 THEN
               FAILED ("COL INCORRECT AFTER NEW_LINE; IS" &
                       COUNT'IMAGE(COL(FT)));
          END IF;

          PUT (FT, "MORE OUTPUT");
          NEW_PAGE (FT);
          IF COL (FT) /= 1 THEN
               FAILED ("COL INCORRECT AFTER NEW_PAGE; IS" &
                       COUNT'IMAGE(COL(FT)));
          END IF;

          PUT (FT, "FINAL");

          CLOSE (FT);

          BEGIN
               OPEN (FT, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT OPEN " &
                                    "WITH IN_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          IF COL (FT) /= 1 THEN
               FAILED ("COL INCORRECT AFTER REOPEN; IS" &
                       COUNT'IMAGE(COL(FT)));
          END IF;

          FOR I IN 1 .. 4 LOOP
               GET (FT, X);
          END LOOP;
          IF COL (FT) /= 5 THEN
               FAILED ("COL INCORRECT AFTER GET; IS" &
                       COUNT'IMAGE(COL(FT)));
          END IF;

          NUM_CHARS := COL(FT);
          WHILE NOT END_OF_LINE(FT) LOOP
               GET (FT, X);
               NUM_CHARS := NUM_CHARS + 1;
          END LOOP;

          IF COL(FT) /= NUM_CHARS THEN
               FAILED ("COL INCORRECT BEFORE END OF LINE; IS" &
                       COUNT'IMAGE(COL(FT)));
          END IF;

          SKIP_LINE (FT);
          IF COL(FT) /= 1 THEN
               FAILED ("COL INCORRECT AFTER SKIP_LINE; IS" &
                       COUNT'IMAGE(COL(FT)));
          END IF;

          SET_COL (FT, 2);
          IF COL (FT) /= 2 THEN
               FAILED ("COL INCORRECT AFTER SET_COL; IS" &
                       COUNT'IMAGE(COL(FT)));
          END IF;

          SKIP_PAGE (FT);
          IF COL(FT) /= 1 THEN
               FAILED ("COL INCORRECT AFTER SKIP_PAGE; IS" &
                       COUNT'IMAGE(COL(FT)));
          END IF;

          BEGIN
               DELETE (FT);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     END;

     RESULT;

EXCEPTION
     WHEN INCOMPLETE =>
          RESULT;
END CE3411A;
