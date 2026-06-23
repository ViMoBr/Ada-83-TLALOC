-- CE3412B.ADA

-- OBJECTIVE:
--     CHECK THAT LINE RAISES LAYOUT_ERROR WHEN THE VALUE OF THE
--     LINE NUMBER EXCEEDS COUNT'LAST.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 07/27/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3412B IS

     FILE : FILE_TYPE;
     INCOMPLETE, INAPPLICABLE : EXCEPTION;
     ITEM : STRING(1..3) := "ABC";
     LST : NATURAL;

BEGIN

     TEST ("CE3412B", "CHECK THAT LINE RAISES LAYOUT_ERROR WHEN THE " &
                      "VALUE OF THE LINE NUMBER EXCEEDS COUNT'LAST");

     BEGIN

          IF COUNT'LAST > 300000 THEN
               RAISE INAPPLICABLE;
          END IF;

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

          SET_LINE (FILE, POSITIVE_COUNT(COUNT'LAST));
          PUT_LINE (FILE, ITEM);
          PUT (FILE, 'A');

          BEGIN
               IF LINE(FILE) <= POSITIVE_COUNT(COUNT'LAST) THEN
                    FAILED ("LINE NUMBER INCORRECT AFTER SET_LINE - 1");
               END IF;
               FAILED ("LAYOUT_ERROR NOT RAISED FOR LINE - 1");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN NUMERIC_ERROR =>
                    FAILED ("NUMERIC_ERROR RAISED FOR LINE - 1");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED FOR LINE - 1");
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

          SET_LINE (FILE, POSITIVE_COUNT(COUNT'LAST));
          GET_LINE (FILE, ITEM, LST);
          IF ITEM /= "ABC" THEN
               FAILED ("INCORRECT VALUE READ");
          END IF;

          SKIP_LINE (FILE);

          BEGIN
               IF LINE(FILE) <= POSITIVE_COUNT(COUNT'LAST) THEN
                    FAILED ("LINE NUMBER INCORRECT AFTER SET_LINE - 2");
               END IF;
               FAILED ("LAYOUT_ERROR NOT RAISED FOR LINE - 2");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN NUMERIC_ERROR =>
                    FAILED ("NUMERIC_ERROR RAISED FOR LINE - 2");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED FOR LINE - 2");
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
          WHEN INAPPLICABLE =>
               NOT_APPLICABLE ("THE VALUE OF COUNT'LAST IS GREATER " &
                               "THAN 300000.  THE CHECKING OF THIS " &
                               "OBJECTIVE IS IMPRACTICAL");

     END;

     RESULT;

END CE3412B;
