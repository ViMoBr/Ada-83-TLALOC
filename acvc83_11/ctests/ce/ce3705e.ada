-- CE3705E.ADA

-- OBJECTIVE:
--     CHECK THAT DATA_ERROR, NOT END_ERROR, IS RAISED WHEN FEWER THAN
--     WIDTH CHARACTERS REMAIN IN THE FILE, AND THE REMAINING CHARACTERS
--     SATISFY THE SYNTAX FOR A REAL LITERAL.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 07/20/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3705E IS

     PACKAGE IIO IS NEW INTEGER_IO (INTEGER);
     USE IIO;

     FILE : FILE_TYPE;
     ITEM : INTEGER;
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3705E", "CHECK THAT DATA_ERROR, NOT END_ERROR, IS " &
                      "RAISED WHEN FEWER THAN WIDTH CHARACTERS " &
                      "REMAIN IN THE FILE, AND THE REMAINING " &
                      "CHARACTERS SATISFY THE SYNTAX FOR A REAL " &
                      "LITERAL");

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

          PUT (FILE, "16#FFF#");
          NEW_LINE (FILE);
          PUT (FILE, "3.14159_26");

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
          IF ITEM /= 4095 THEN
               FAILED ("INCORRECT VALUE READ");
          END IF;

          BEGIN
               GET (FILE, ITEM, WIDTH => 11);
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

END CE3705E;
