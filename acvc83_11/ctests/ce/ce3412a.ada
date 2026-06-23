-- CE3412A.ADA

-- OBJECTIVE:
--     CHECK THAT LINE RETURNS THE VALUE OF THE CURRENT LINE NUMBER.

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

PROCEDURE CE3412A IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3412A", "CHECK LINE RETURNS LINE NUMBER");

     DECLARE
          FT : FILE_TYPE;
          X : CHARACTER;
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

          IF LINE (FT) /= 1 THEN
               FAILED ("CURRENT LINE NUMBER NOT INITIALLY ONE");
          END IF;

          FOR I IN 1 .. 3 LOOP
               PUT (FT, "OUTPUT STRING");
               NEW_LINE (FT);
          END LOOP;
          IF LINE (FT) /= 4 THEN
               FAILED ("LINE INCORRECT AFTER PUT; IS" &
                       COUNT'IMAGE(LINE(FT)));
          END IF;

          NEW_PAGE (FT);
          IF LINE (FT) /= 1 THEN
               FAILED ("LINE INCORRECT AFTER NEW_PAGE; IS" &
                       COUNT'IMAGE(LINE(FT)));
          END IF;

          FOR I IN 1 .. 5 LOOP
               PUT (FT, "MORE OUTPUT");
               NEW_LINE(FT);
          END LOOP;

          CLOSE (FT);

          BEGIN
               OPEN (FT, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT OPEN " &
                                    "WITH IN_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          IF LINE (FT) /= 1 THEN
               FAILED ("LINE INCORRECT AFTER RESET; IS" &
                       COUNT'IMAGE(LINE(FT)));
          END IF;

          FOR I IN 1 .. 2 LOOP
               SKIP_LINE (FT);
          END LOOP;
          IF LINE (FT) /= 3 THEN
               FAILED ("LINE INCORRECT AFTER SKIP_LINE; IS" &
                       COUNT'IMAGE(LINE(FT)));
          END IF;

          SET_LINE (FT, 2);
          IF LINE (FT) /= 2 THEN
               FAILED ("LINE INCORRECT AFTER SET_LINE; IS" &
                       COUNT'IMAGE(LINE(FT)));
          END IF;

          SKIP_PAGE (FT);
          IF LINE (FT) /= 1 THEN
               FAILED ("LINE INCORRECT AFTER SKIP_PAGE; IS" &
                       COUNT'IMAGE(LINE(FT)));
          END IF;

          BEGIN
               DELETE (FT);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;

     END;

     RESULT;

END CE3412A;
