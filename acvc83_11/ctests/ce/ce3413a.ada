-- CE3413A.ADA

-- OBJECTIVE:
--     CHECK THAT PAGE RETURNS THE VALUE OF THE CURRENT PAGE NUMBER.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     SPS 09/29/82
--     JBG 08/30/83
--     RJW 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 09/04/87  REMOVED DEPENDENCE ON RESET AND CHECKED FOR
--                   USE_ERROR ON DELETE.


WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3413A IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3413A", "CHECK THAT PAGE RETURNS THE CORRECT PAGE " &
                      "NUMBER");

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
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                            "TEXT CREATE");
                    RAISE INCOMPLETE;
          END;

          IF PAGE (FT) /= 1 THEN
               FAILED ("CURRENT PAGE NOT INITIALLY ONE");
          END IF;

          FOR I IN 1 .. 6 LOOP
               PUT (FT, "OUTPUT STRING");
               NEW_PAGE (FT);
          END LOOP;
          IF PAGE (FT) /= 7 THEN
               FAILED ("PAGE INCORRECT AFTER PUT; IS" &
                       COUNT'IMAGE(PAGE(FT)));
          END IF;

          CLOSE (FT);

          BEGIN
               OPEN (FT, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT OPEN " &
                                    "WITH IN_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          IF PAGE (FT) /= 1 THEN
               FAILED ("PAGE INCORRECT AFTER OPEN IS" &
                       COUNT'IMAGE(PAGE(FT)));
          END IF;

          FOR I IN 1 .. 4 LOOP
               SKIP_PAGE (FT);
          END LOOP;
          IF PAGE (FT) /= 5 THEN
               FAILED ("PAGE INCORRECT AFTER SKIP_PAGE; IS" &
                       COUNT'IMAGE(PAGE(FT)));
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

END CE3413A;
