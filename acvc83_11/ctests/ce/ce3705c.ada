-- CE3705C.ADA

-- OBJECTIVE:
--     CHECK THAT THE LAST CHARACTER IN A FILE MAY BE READ WITHOUT
--     RAISING END_ERROR, AND THAT AFTER THE LAST CHARACTER OF THE
--     FILE HAS BEEN READ, ANY ATTEMPT TO READ FURTHER CHARACTERS
--     WILL RAISE END_ERROR.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 07/18/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3705C IS

     PACKAGE IIO IS NEW INTEGER_IO (INTEGER);
     USE IIO;

     FILE : FILE_TYPE;
     ITEM : INTEGER;
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3705C", "CHECK THAT THE LAST CHARACTER IN A FILE MAY " &
                      "BE READ WITHOUT RAISING END_ERROR, AND THAT " &
                      "AFTER THE LAST CHARACTER OF THE FILE HAS BEEN " &
                      "READ, ANY ATTEMPT TO READ FURTHER CHARACTERS " &
                      "WILL RAISE END_ERROR");

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
          PUT (FILE, 3);
          NEW_LINE (FILE);
          NEW_PAGE (FILE);
          PUT (FILE, 5);

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
          GET (FILE, ITEM);

          BEGIN
               GET (FILE, ITEM);
               IF ITEM /= 5 THEN
                    FAILED ("INCORRECT VALUE READ");
               END IF;
               BEGIN
                    GET (FILE, ITEM);
                    FAILED ("END_ERROR NOT RAISED AFTER LAST " &
                            "CHARACTER OF FILE HAS BEEN READ");
               EXCEPTION
                    WHEN END_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED ON GET");
               END;
          EXCEPTION
               WHEN END_ERROR =>
                    FAILED ("END_ERROR RAISED WHEN READING LAST " &
                            "CHARACTER OF FILE");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON GET - 2");
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

END CE3705C;
