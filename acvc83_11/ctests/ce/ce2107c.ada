-- CE2107C.ADA

-- OBJECTIVE:
--     CHECK WHETHER MORE THAN ONE INTERNAL FILE MAY BE ASSOCIATED
--     WITH THE SAME TEMPORARY SEQUENTIAL FILE WHEN ONE FILE IS
--     READING AND THE OTHER IS WRITING.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     MULTIPLE ACCESS OF TEMPORARY SEQUENTIAL FILES WHEN ONE FILE
--     IS READING AND THE OTHER IS WRITING.

-- HISTORY:
--     SPS 09/27/82
--     SPS 11/09/82
--     JBG 06/04/84
--     JBG 12/03/84  ALLOW USE_ERROR FOR NAME FUNCTION.
--     TBN 02/13/86  SPLIT TEST.  PUT DIRECT_IO INTO CE2107H.ADA.
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     SPW 08/04/87  CORRECTED EXCEPTION HANDLING.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2107C IS

BEGIN

     TEST ("CE2107C", "CHECK WHETHER MORE THAN ONE INTERNAL FILE MAY " &
                      "BE ASSOCIATED WITH THE SAME TEMPORARY " &
                      "SEQUENTIAL FILE WHEN ONE FILE IS READING AND " &
                      "THE OTHER IS WRITING");

     DECLARE
          PACKAGE SEQ IS NEW SEQUENTIAL_IO (CHARACTER);
          USE SEQ;
          INCOMPLETE : EXCEPTION;
          CH : CHARACTER;
          FT1, FT2 : FILE_TYPE;
     BEGIN
          BEGIN
               CREATE (FT1);
          EXCEPTION
               WHEN USE_ERROR =>
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
                    OPEN (FT2, IN_FILE, F_NAME);

                    -- AN IMPLEMENTATION SHOULD BE AT THE BEGINNING OF
                    -- THE FILE OR THE END; DEPENDING UPON THE MEMORY
                    -- DEVICES USED.

                    BEGIN
                         READ (FT2, CH);
                         IF CH /= 'A' THEN
                              FAILED ("INCORRECT VALUE READ");
                         END IF;
                    EXCEPTION
                         WHEN END_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED ("UNEXPECTED EXCEPTION RAISED " &
                                      "WHILE READING");
                    END;

                    BEGIN
                         CLOSE (FT2);
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ("CAN'T CLOSE SECOND FILE - SEQ");
                    END;
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("CANNOT ASSOCIATE MORE THAN " &
                                         "ONE INTERNAL FILE WITH THE " &
                                         "SAME TEMPORARY SEQUENTIAL " &
                                         "FILE, WHEN ONE FILE IS " &
                                         "READING AND THE OTHER IS " &
                                         "WRITING");
                    WHEN NAME_ERROR =>
                         FAILED ("TEMP FILE NAME NOT USABLE IN OPEN - "&
                                 "SEQ");
                    WHEN STATUS_ERROR =>
                         FAILED ("STATUS_ERROR RAISED EVEN THOUGH " &
                                 "INTERNAL FILE IS NOT OPEN - SEQ");
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION - SEQ, OPEN");
               END;
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED BY NAME " &
                                    "FUNCTION FOR TEMPORARY FILE");
          END;

          CLOSE (FT1);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2107C;
