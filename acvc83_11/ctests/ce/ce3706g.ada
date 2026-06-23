-- CE3706G.ADA

-- OBJECTIVE:
--     CHECK THAT INTEGER_IO PUT USES THE MINIMUM FIELD REQUIRED IF
--     WIDTH IS TOO SMALL AND THE LINE LENGTH IS SUFFICIENTLY LARGE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     SPS 10/05/82
--     JLH 09/17/87  COMPLETELY REVISED TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3706G IS

BEGIN

     TEST ("CE3706G", "CHECK THAT INTEGER_IO PUT USES THE MINIMUM " &
                      "FIELD REQUIRED IF WIDTH IS TOO SMALL AND THE " &
                      "LINE LENGTH IS SUFFICIENTLY LARGE");

     DECLARE
          FILE : FILE_TYPE;
          PACKAGE IIO IS NEW INTEGER_IO (INTEGER);
          USE IIO;
          INCOMPLETE : EXCEPTION;
          NUM : INTEGER := 12345;
          CH : CHARACTER;

     BEGIN

          BEGIN
               CREATE (FILE, OUT_FILE, LEGAL_FILE_NAME);
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

          PUT (FILE, NUM, WIDTH => 3);
          TEXT_IO.PUT (FILE, ' ');

          CLOSE (FILE);

          BEGIN
               OPEN (FILE, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT OPEN " &
                                    "WITH IN_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          GET (FILE, NUM);
          GET (FILE, CH);
          IF CH /= ' ' AND COL(FILE) /= 7 THEN
               FAILED ("INTEGER_IO PUT DOES NOT USE MINIMUM FIELD " &
                       "REQUIRED WHEN WIDTH IS TOO SMALL");
          END IF;

          IF NUM /= 12345 THEN
               FAILED ("INCORREC VALUE READ");
          END IF;

          BEGIN
               DELETE (FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;

     END;

     RESULT;

END CE3706G;
