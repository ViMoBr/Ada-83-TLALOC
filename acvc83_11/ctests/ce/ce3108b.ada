-- CE3108B.ADA

-- OBJECTIVE:
--     CHECK THAT THE NAME RETURNED BY THE NAME FUNCTION CAN BE USED
--     IN A SUBSEQUENT OPEN.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     DLD 08/11/82
--     SPS 11/09/82
--     JBG 03/24/83
--     EG  05/16/85
--     GMT 08/17/87  REMOVED UNNECESSARY CODE AND ADDED A CHECK FOR
--                   USE_ERROR ON DELETE.

WITH TEXT_IO; USE TEXT_IO;
WITH REPORT; USE REPORT;

PROCEDURE CE3108B IS

     TYPE ACC_STR IS ACCESS STRING;

     TXT_FILE      : FILE_TYPE;
     TXT_FILE_NAME : ACC_STR;
     DIR_FILE_NAME : ACC_STR;
     VAR           : STRING(1..2);
     LAST          : INTEGER;
     INCOMPLETE    : EXCEPTION;

BEGIN

     TEST ("CE3108B", "CHECK THAT THE NAME RETURNED BY THE NAME-" &
                      "FUNCTION CAN BE USED IN A SUBSEQUENT OPEN");

     -- CREATE TEST FILES

     BEGIN
          BEGIN
               CREATE (TXT_FILE, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE - 1");
                    RAISE INCOMPLETE;
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE - 2");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               PUT (TXT_FILE, "14");
               TXT_FILE_NAME := NEW STRING'(NAME (TXT_FILE));
               CLOSE (TXT_FILE);

               -- ATTEMPT TO RE-OPEN TEXT TEST FILE USING RETURNED NAME
               -- VALUE

               BEGIN
                    OPEN (TXT_FILE, IN_FILE, TXT_FILE_NAME.ALL);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("USE_ERROR ON RE-OPEN - 3");
                         RAISE INCOMPLETE;
               END;

               GET (TXT_FILE, VAR);
               IF VAR /= "14" THEN
                    FAILED ("WRONG DATA RETURNED FROM READ - 4");
               END IF;

               -- CLOSE AND DELETE TEST FILES

               BEGIN
                    DELETE (TXT_FILE);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
               END;
          END;
     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3108B;
