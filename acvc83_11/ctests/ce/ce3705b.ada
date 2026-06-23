-- CE3705B.ADA

-- OBJECTIVE:
--     IF WIDTH IS ZERO, CHECK THAT END_ERROR IS RAISED IF THE ONLY
--     REMAINING CHARACTERS IN THE FILE CONSIST OF LINE TERMINATORS,
--     PAGE TERMINATORS, SPACES, AND HORIZONTAL TABULATION CHARACTERS.
--     AFTER END_ERROR IS RAISED, THE FILE SHOULD BE POSITIONED BEFORE
--     THE FILE TERMINATOR AND END_OF_FILE SHOULD BE TRUE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS THAT SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 07/15/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3705B IS

     PACKAGE IIO IS NEW INTEGER_IO (INTEGER);
     USE IIO;

     FILE : FILE_TYPE;
     ITEM : INTEGER;
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3705B", "IF WIDTH IS ZERO, CHECK THAT END_ERROR IS " &
                      "RAISED IF THE ONLY REMAINING CHARACTERS IN " &
                      "THE FILE CONSIST OF LINE TERMINATORS, PAGE " &
                      "TERMINATORS, SPACES, AND HORIZONTAL TAB " &
                      "CHARACTERS. AFTER END_ERROR IS RAISED, THE " &
                      "FILE SHOULD BE POSITIONED BEFORE THE FILE " &
                      "TERMINATOR AND END_OF_FILE SHOULD BE TRUE");

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

          PUT (FILE, 2);
          NEW_LINE (FILE);
          PUT (FILE, 3);
          NEW_LINE (FILE);
          NEW_PAGE (FILE);
          PUT (FILE, ASCII.HT);
          NEW_LINE (FILE);
          NEW_LINE (FILE);
          NEW_PAGE (FILE);
          PUT (FILE, ' ');
          PUT (FILE, ASCII.HT);
          PUT (FILE, ' ');

          CLOSE (FILE);

          BEGIN
               OPEN (FILE, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN WITH " &
                                    "MODE IN_FILE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON OPEN");
                    RAISE INCOMPLETE;
          END;

          GET (FILE, ITEM);
          IF ITEM /= 2 THEN
               FAILED ("INCORRECT VALUE READ - 1");
          END IF;

          GET (FILE, ITEM);
          IF ITEM /= 3 THEN
               FAILED ("INCORRECT VALUE READ - 2");
          END IF;

          BEGIN
               GET (FILE, ITEM, WIDTH => 0);
               FAILED ("END_ERROR NOT RAISED FOR GET");
          EXCEPTION
               WHEN END_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON GET");
          END;

          IF NOT END_OF_FILE(FILE) THEN
               FAILED ("END_OF_FILE NOT TRUE AFTER RAISING EXCEPTION");
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

END CE3705B;
