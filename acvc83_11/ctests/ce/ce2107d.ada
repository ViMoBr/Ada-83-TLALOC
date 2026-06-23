-- CE2107D.ADA

-- OBJECTIVE:
--     CHECK WHETHER FILES OF DIFFERENT ELEMENT TYPES MAY BE ASSOCIATED
--     WITH THE SAME TEMPORARY SEQUENTIAL FILE WHEN BOTH FILES ARE
--     WRITING.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     MULTIPLE ACCESS OF TEMPORARY SEQUENTIAL FILES WHEN BOTH
--     FILES ARE WRITING.

-- HISTORY:
--     SPS 09/27/82
--     SPS 11/09/82
--     JBG 06/04/84
--     JBG 12/03/84  ALLOW USE_ERROR FOR NAME FUNCTION.
--     TBN 02/13/86  SPLIT TEST.  PUT DIRECT_IO INTO CE2107I.ADA.
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     SPW 08/04/87  CORRECTED EXCEPTION HANDLING.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2107D IS

BEGIN

     TEST ("CE2107D", "CHECK WHETHER FILES OF DIFFERENT ELEMENT " &
                      "TYPES MAY BE ASSOCIATED WITH THE SAME " &
                      "TEMPORARY SEQUENTIAL FILE WHEN BOTH FILES " &
                      "ARE WRITING");

     DECLARE
          PACKAGE SEQ1 IS NEW SEQUENTIAL_IO (CHARACTER);
          USE SEQ1;
          PACKAGE SEQ2 IS NEW SEQUENTIAL_IO (BOOLEAN);
          USE SEQ2;
          INCOMPLETE : EXCEPTION;
          FT1 : SEQ1.FILE_TYPE;
          FT2 : SEQ2.FILE_TYPE;
     BEGIN
          BEGIN
               CREATE (FT1);
          EXCEPTION
               WHEN SEQ1.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; SEQUENTIAL " &
                                    "CREATE FOR TEMPORARY FILE WITH " &
                                    "OUT_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          WRITE (FT1, 'A');

          BEGIN
               DECLARE
                    F_NAME : CONSTANT STRING := NAME (FT1);
               BEGIN
                    OPEN (FT2, OUT_FILE, F_NAME);

                    BEGIN
                         WRITE (FT2, IDENT_BOOL(TRUE));
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ("UNEXPECTED EXCEPTION RAISED " &
                                      "- WRITE");
                    END;

                    BEGIN
                         CLOSE (FT2);
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ("CAN'T CLOSE SECOND FILE - SEQ");
                    END;
               EXCEPTION
                    WHEN SEQ2.USE_ERROR =>
                         NOT_APPLICABLE ("CANNOT ASSOCIATE MORE THAN " &
                                         "ONE INTERNAL FILE WITH THE " &
                                         "SAME TEMPORARY SEQUENTIAL " &
                                         "FILE, WHEN BOTH FILES ARE " &
                                         "WRITING");
                    WHEN SEQ2.NAME_ERROR =>
                         FAILED ("TEMP FILE NAME NOT USABLE IN OPEN " &
                                 "- SEQ");
                    WHEN SEQ2.STATUS_ERROR =>
                         FAILED ("STATUS_ERROR RAISED EVEN THOUGH " &
                                 "INTERNAL FILE IS NOT OPEN - SEQ");
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION - SEQ, OPEN");
               END;
          EXCEPTION
               WHEN SEQ1.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED BY NAME " &
                                    "FUNCTION FOR TEMPORARY FILE");
          END;

          CLOSE (FT1);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2107D;
