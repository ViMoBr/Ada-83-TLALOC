-- CE3111C.ADA

-- OBJECTIVE:
--     CHECK WHETHER OR NOT MORE THAN ONE INTERNAL FILE MAY BE
--     ASSOCIATED WITH THE SAME EXTERNAL FILE IF BOTH FILES ARE
--     OPENED FOR WRITING.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH
--     SUPPORT TWO INTERNAL FILES ASSOCIATED WITH THE SAME
--     EXTERNAL FILE NAME FOR WRITING.

-- HISTORY:
--     ABW 08/13/82
--     SPS 11/09/82
--     JBG 03/24/83
--     JBG 10/24/83
--     JBG 06/05/84
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     DWC 08/18/87  REVISED EXCEPTION HANDLER FOR DELETION
--                   OF FILE.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3111C IS

     FILE_TEX1, FILE_TEX2 : TEXT_IO.FILE_TYPE;
     INCOMPLETE, SUBTEST : EXCEPTION;

BEGIN

     TEST( "CE3111C" , "CHECK WHETHER TWO INTERNAL " &
                       "FILES MAY BE ASSOCIATED WITH A SINGLE " &
                       "EXTERNAL FILE IF BOTH FILES ARE OPENED " &
                       "FOR WRITING");

     DECLARE
          TWO_CHARS : STRING (1..2);
     BEGIN

          BEGIN
               CREATE (FILE_TEX1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; TEXT CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; TEXT CREATE" &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED; TEXT CREATE");
                    RAISE INCOMPLETE;
          END;

          PUT (FILE_TEX1, "ABCD");

          BEGIN
               BEGIN
                    OPEN (FILE_TEX2, OUT_FILE, LEGAL_FILE_NAME);
                    COMMENT ("TWO INTERNAL FILES CAN SIMULTANEOUSLY " &
                             "WRITE TO THE SAME EXTERNAL FILE");
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("THIS IMPLEMENTATION DOES " &
                                         "NOT ALLOW TWO INTERNAL " &
                                         "TEXT FILES TO BE " &
                                         "ASSOCIATED WITH THE SAME " &
                                         "EXTERNAL FILE WHEN BOTH " &
                                         "ARE OPENED FOR WRITING");
                         RAISE SUBTEST;
               END;

               IF COL(FILE_TEX1) /= 5 THEN
                    FAILED ("COLUMN POSITION WRONG - TEX1");
               END IF;

               IF COL (FILE_TEX2) /= 1 THEN
                    FAILED ("COLUMN POSITION WRONG - TEX2");
               END IF;

               PUT (FILE_TEX2, "EF");
               IF COL (FILE_TEX2) /= 3 THEN
                    FAILED ("DIDN'T SET COL CORRECTLY FOR TEX2");
               END IF;

               IF COL(FILE_TEX1) /= 5 THEN
                    FAILED ("COL FOR TEX1 CHANGED BY WRITE TO " &
                            "TEX2 -- 1");
               END IF;

               CLOSE (FILE_TEX1);
               CLOSE (FILE_TEX2);

               BEGIN
                    OPEN (FILE_TEX1, IN_FILE, LEGAL_FILE_NAME);
                    OPEN (FILE_TEX2, IN_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("THIS IMPLEMENTATION DOES " &
                                         "NOT ALLOW TWO INTERNAL " &
                                         "TEXT FILES TO BE " &
                                         "ASSOCIATED WITH THE SAME " &
                                         "EXTERNAL FILE WHEN BOTH " &
                                         "ARE OPENED FOR READING");
                         RAISE INCOMPLETE;
               END;

               GET (FILE_TEX1, TWO_CHARS);

               IF TWO_CHARS /= "EF" THEN
                    FAILED ("DID NOT WRITE TEX1 CORRECTLY");
               END IF;

               GET (FILE_TEX2, TWO_CHARS);

               IF TWO_CHARS /= "CD" THEN
                    FAILED ("DID NOT WRITE TEX2 CORRECTLY");
               END IF;
          END;

          CLOSE (FILE_TEX2);

          BEGIN
               DELETE (FILE_TEX1);
          EXCEPTION
               WHEN USE_ERROR =>
                    COMMENT ("DELETION OF EXTERNAL FILE NOT " &
                             "SUPPORTED");
          END;
     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
          WHEN SUBTEST =>
               BEGIN
                    DELETE (FILE_TEX1);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
               END;
     END;

     RESULT;

END CE3111C;
