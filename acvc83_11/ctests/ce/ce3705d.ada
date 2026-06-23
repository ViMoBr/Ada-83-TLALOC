-- CE3705D.ADA

-- OBJECTIVE:
--     CHECK THAT DATA_ERROR, NOT END_ERROR, IS RAISED WHEN WIDTH > 0,
--     FEWER THAN WIDTH CHARACTERS REMAIN IN THE FILE, A BASED LITERAL
--     IS BEING READ, AND THE CLOSING # OR : HAS NOT YET BEEN FOUND.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 07/19/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3705D IS

     PACKAGE IIO IS NEW INTEGER_IO (INTEGER);
     USE IIO;

     FILE : FILE_TYPE;
     ITEM : INTEGER;
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3705D", "CHECK THAT DATA_ERROR, NOT END_ERROR, IS " &
                      "RAISED WHEN WIDTH > 0, FEWER THAN WIDTH " &
                      "CHARACTERS REMAIN IN THE FILE, A BASED " &
                      "LITERAL IS BEING READ, AND THE CLOSING # " &
                      "OR : HAS NOT YET BEEN FOUND");

     BEGIN

          BEGIN
               CREATE (FILE, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                    "WITH MODE OUT_FILE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE " &
                                    "WITH MODE OUT_FILE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          PUT (FILE, "2#1111_1111#");
          NEW_LINE (FILE);
          PUT (FILE, "16#FFF");

          CLOSE (FILE);

          BEGIN
               OPEN (FILE, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN " &
                                    "WITH MODE IN_FILE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON OPEN");
                    RAISE INCOMPLETE;
          END;

          GET (FILE, ITEM);
          IF ITEM /= 255 THEN
               FAILED ("INCORRECT VALUE READ");
          END IF;

          BEGIN
               GET (FILE, ITEM, WIDTH => 7);
               FAILED ("DATA_ERROR NOT RAISED");
          EXCEPTION
               WHEN END_ERROR =>
                    FAILED ("END_ERROR INSTEAD OF DATA_ERROR RAISED");
               WHEN DATA_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON GET");
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

END CE3705D;
