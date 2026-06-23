-- CE2111D.ADA

-- OBJECTIVE:
--     CHECK THAT RESETTING AN INTERNAL FILE HAS NO EFFECT ON THE
--     MODE OF ANY INTERNAL FILES ACCESSING THE SAME EXTERNAL FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST APPLIES ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     MULTIPLE INTERNAL FILES ASSOCIATED WITH THE SAME EXTERNAL FILE
--     AND RESETTING OF THESE MULTIPLE INTERNAL FILES FOR SEQUENTIAL_IO.

-- HISTORY:
--     DLD 08/16/82
--     SPS 11/09/82
--     JBG 03/24/83
--     JBG 06/04/84
--     EG  11/09/84
--     EG  06/05/85
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 07/23/87  CHANGED METHOD OF OPENING FIRST INTERNAL FILE TO
--                   MATCH THAT OF CE2107A.  WROTE TO FILE TO PREVENT
--                   EMPTY FILE.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2111D IS

BEGIN

     TEST ("CE2111D", "CHECK THAT RESETTING AN INTERNAL FILE HAS " &
                      "NO EFFECT ON THE MODE OF ANY INTERNAL FILES " &
                      "ACCESSING THE SAME EXTERNAL FILE");

     DECLARE -- SEQ TEST

          PACKAGE SEQ_IO IS NEW SEQUENTIAL_IO (INTEGER);
          USE SEQ_IO;

          VAR1 : INTEGER := 5;
          SEQ_FILE_ONE  : SEQ_IO.FILE_TYPE;
          SEQ_FILE_TWO  : SEQ_IO.FILE_TYPE;

          INCOMPLETE_SEQ : EXCEPTION;

          PROCEDURE SEQ_CLEANUP IS
               FILE1_OPEN : BOOLEAN := IS_OPEN (SEQ_FILE_ONE);
               FILE2_OPEN : BOOLEAN := IS_OPEN (SEQ_FILE_TWO);
          BEGIN
               IF FILE1_OPEN AND FILE2_OPEN THEN
                    CLOSE (SEQ_FILE_TWO);
                    DELETE (SEQ_FILE_ONE);
               ELSIF FILE1_OPEN THEN
                    DELETE (SEQ_FILE_ONE);
               ELSIF FILE2_OPEN THEN
                    DELETE (SEQ_FILE_TWO);
               END IF;
          EXCEPTION
               WHEN SEQ_IO.USE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - SEQ");
          END SEQ_CLEANUP;

     BEGIN -- SEQ TEST

          BEGIN -- CREATE FIRST FILE

               CREATE (SEQ_FILE_ONE, OUT_FILE, LEGAL_FILE_NAME);
               WRITE (SEQ_FILE_ONE, VAR1);
               CLOSE (SEQ_FILE_ONE);

          EXCEPTION

               WHEN SEQ_IO.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; CREATE OF " &
                                    "EXTERNAL FILENAME IS NOT " &
                                    "SUPPORTED - SEQ");
                    RAISE INCOMPLETE_SEQ;
               WHEN SEQ_IO.NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; CREATE OF " &
                                    "EXTERNAL FILENAME IS NOT " &
                                    "SUPPORTED - SEQ");
                    RAISE INCOMPLETE_SEQ;

          END; -- CREATE FIRST FILE

          BEGIN
               OPEN (SEQ_FILE_ONE, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("OPEN WITH IN_FILE MODE NOT " &
                                    "SUPPORTED");
                    SEQ_CLEANUP;
                    RAISE INCOMPLETE_SEQ;
          END;

          BEGIN -- OPEN SECOND FILE

               OPEN (SEQ_FILE_TWO, IN_FILE, LEGAL_FILE_NAME);

          EXCEPTION

               WHEN SEQ_IO.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; MULTIPLE " &
                                    "INTERNAL FILES NOT ALLOWED TO " &
                                    "ACCESS THE SAME EXTERNAL FILE - " &
                                    "SEQ");
                    SEQ_CLEANUP;
                    RAISE INCOMPLETE_SEQ;

          END; -- OPEN SECOND FILE

          BEGIN -- RESET MODE OF FIRST FILE

               RESET (SEQ_FILE_ONE, OUT_FILE);
               IF MODE (SEQ_FILE_ONE) /= OUT_FILE THEN
                    FAILED ("FILE WAS NOT RESET - SEQ");
               END IF;
               IF MODE (SEQ_FILE_TWO) /= IN_FILE THEN
                    FAILED ("RESETTING ONE INTERNAL FILE AFFECTED " &
                            "THE MODE OF ANOTHER INTERNAL FILE - SEQ");
               END IF;

          EXCEPTION

               WHEN SEQ_IO.USE_ERROR =>
                    NOT_APPLICABLE ("RESETTING OF EXTERNAL FILE FROM " &
                                    "IN_FILE TO OUT_FILE NOT " &
                                    "SUPPORTED - SEQ");
                    SEQ_CLEANUP;
                    RAISE INCOMPLETE_SEQ;

          END; -- RESET MODE OF FIRST FILE

          SEQ_CLEANUP;

     EXCEPTION

          WHEN INCOMPLETE_SEQ =>
               NULL;

     END; -- SEQ TEST

     RESULT;

END CE2111D;
