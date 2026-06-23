-- CE3405D.ADA

-- OBJECTIVE:
--     CHECK THAT NEW_PAGE INCREMENTS THE CURRENT PAGE NUMBER AND
--     SETS THE CURRENT COLUMN AND LINE NUMBERS TO ONE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH
--     SUPPORT TEXT FILES.

-- HISTORY:
--     SPS 08/28/82
--     TBN 11/10/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     DWC 09/23/87  CORRECTED EXCEPTION HANDLING AND ADDED CASES FOR
--                   CONSECUTIVE NEW_LINE AND NEW_PAGE.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;
WITH CHECK_FILE;

PROCEDURE CE3405D IS
     INCOMPLETE : EXCEPTION;
BEGIN

     TEST ("CE3405D", "CHECK THAT NEW_PAGE INCREMENTS PAGE COUNT " &
                      "AND SETS COLUMN AND LINE TO ONE");

     DECLARE
          FT : FILE_TYPE;
          CH : CHARACTER;
          PG_NUM : POSITIVE_COUNT;
     BEGIN

          BEGIN
               CREATE (FT, OUT_FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; TEXT CREATE " &
                                    "FOR TEMP FILE WITH OUT_FILE " &
                                    "MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED; TEXT CREATE");
                    RAISE INCOMPLETE;
          END;

          PUT (FT, "STRING");
          NEW_LINE (FT);
          PUT (FT, 'X');
          PG_NUM := PAGE (FT);

          NEW_PAGE (FT);

          IF COL(FT) /= 1 THEN
               FAILED ("COLUMN NUMBER NOT RESET - OUTPUT - 1");
          END IF;
          IF LINE (FT) /= 1 THEN
               FAILED ("LINE NUMBER NOT RESET - OUTPUT - 1");
          END IF;
          IF PAGE (FT) /= PG_NUM + 1 THEN
               FAILED ("PAGE NUMBER NOT INCREMENTED - OUTPUT - 1");
          END IF;

          PUT (FT, "MORE STUFF");
          NEW_LINE (FT);
          NEW_PAGE (FT);

          IF COL(FT) /= 1 THEN
               FAILED ("COLUMN NUMBER NOT RESET - OUTPUT - 2");
          END IF;
          IF LINE (FT) /= 1 THEN
               FAILED ("LINE NUMBER NOT RESET - OUTPUT - 2");
          END IF;
          IF PAGE (FT) /= PG_NUM + 2 THEN
               FAILED ("PAGE NUMBER NOT INCREMENTED - OUTPUT - 2");
          END IF;

          CHECK_FILE (FT, "STRING#X#@MORE STUFF#@%");

          CLOSE (FT);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3405D;
