-- CE3411B.ADA

-- OBJECTIVE:
--     CHECK THAT COL RAISES LAYOUT_ERROR WHEN THE VALUE OF THE
--     COLUMN NUMBER EXCEEDS COUNT'LAST.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 09/10/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;


PROCEDURE CE3411B IS

     FILE : FILE_TYPE;
     INCOMPLETE : EXCEPTION;
     NUM, CN : POSITIVE_COUNT;
     CH : CHARACTER;
     ITEM : CHARACTER := 'A';

BEGIN

     TEST ("CE3411B", "CHECK THAT COL RAISES LAYOUT_ERROR WHEN THE " &
                      "VALUE OF THE COLUMN NUMBER EXCEEDS COUNT'LAST");

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
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON TEXT " &
                            "CREATE");
                    RAISE INCOMPLETE;
          END;

          SET_COL (FILE, POSITIVE_COUNT(COUNT'LAST));
          PUT (FILE, ITEM);

          BEGIN
               IF COL(FILE) <= POSITIVE_COUNT(COUNT'LAST) THEN
                    FAILED ("COLUMN NUMBER INCORRECT AFTER SET_COL " &
                            "- 1");
               END IF;
               FAILED ("LAYOUT_ERROR NOT RAISED - 1");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN NUMERIC_ERROR =>
                    FAILED ("NUMERIC_ERROR RAISED FOR COL - 1");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED FOR COL - 1");
          END;

          CLOSE (FILE);

          BEGIN
               OPEN (FILE, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT OPEN " &
                                    "WITH IN_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          SET_COL (FILE, POSITIVE_COUNT(COUNT'LAST));
          GET (FILE, CH);
          IF CH /= 'A' THEN
               FAILED ("INCORRECT VALUE READ");
          END IF;

          BEGIN
               IF COL(FILE) <= POSITIVE_COUNT(COUNT'LAST) THEN
                    FAILED ("COLUMN NUMBER INCORRECT AFTER SET_COL " &
                            "- 2");
               END IF;
               FAILED ("LAYOUT_ERROR NOT RAISED - 2");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN NUMERIC_ERROR =>
                    FAILED ("NUMERIC_ERROR RAISED FOR COL - 2");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED FOR COL - 2");
          END;

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

END CE3411B;
