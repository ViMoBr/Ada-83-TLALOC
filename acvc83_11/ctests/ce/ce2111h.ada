-- CE2111H.ADA

-- OBJECTIVE:
--     CHECK THAT RESETTING ONE OF A MULTIPLE OF INTERNAL FILES
--     ASSOCIATED WITH THE SAME EXTERNAL FILE HAS NO EFFECT ON ANY
--     OF THE OTHER INTERNAL FILES.


-- APPLICABILITY CRITERIA:
--     THIS TEST APPLIES ONLY TO IMPLEMENTATIONS WHICH SUPPORT MULTIPLE
--     INTERNAL FILES ASSOCIATED WITH THE SAME EXTERNAL FILE AND
--     RESETTING OF THESE MULTIPLE INTERNAL FILES FOR DIRECT_IO.

-- HISTORY:
--     DLD 08/16/82
--     SPS 11/09/82
--     JBG 03/24/83
--     JBG 06/04/84
--     EG  11/09/84
--     EG  06/05/85
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 07/24/87  CHANGED THE FILE MODE IN THE INITIAL CREATE TO
--                   OUT_FILE; THEN CLOSED THE FILE AND REOPENED IT
--                   WITH MODE IN_FILE.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2111H IS

BEGIN

     TEST ("CE2111H", "CHECK THAT RESETTING ONE OF A MULTIPLE OF " &
                      "INTERNAL FILES ASSOCIATED WITH THE SAME " &
                      "EXTERNAL FILE HAS NO EFFECT ON ANY OF THE " &
                      "OTHER INTERNAL FILES");

     DECLARE -- DIR TEST

          PACKAGE DIR_IO IS NEW DIRECT_IO (INTEGER);
          USE DIR_IO;

          DIR_FILE_ONE  : DIR_IO.FILE_TYPE;
          DIR_FILE_TWO  : DIR_IO.FILE_TYPE;

          DATUM : INTEGER := 5;

          INCOMPLETE_DIR : EXCEPTION;

          PROCEDURE DIR_CLEANUP IS
               FILE1_OPEN : BOOLEAN := IS_OPEN (DIR_FILE_ONE);
               FILE2_OPEN : BOOLEAN := IS_OPEN (DIR_FILE_TWO);
          BEGIN
               IF FILE1_OPEN AND FILE2_OPEN THEN
                    CLOSE (DIR_FILE_TWO);
                    DELETE (DIR_FILE_ONE);
               ELSIF FILE1_OPEN THEN
                    DELETE (DIR_FILE_ONE);
               ELSIF FILE2_OPEN THEN
                    DELETE (DIR_FILE_TWO);
               END IF;
          EXCEPTION
               WHEN DIR_IO.USE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - DIR");
          END DIR_CLEANUP;

     BEGIN -- DIR TEST

          BEGIN -- CREATE FIRST FILE

               CREATE (DIR_FILE_ONE, OUT_FILE, LEGAL_FILE_NAME);
               WRITE (DIR_FILE_ONE, DATUM);

          EXCEPTION
               WHEN DIR_IO.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; CREATE WITH " &
                                    "OUT_FILE MODE IS NOT " &
                                    "SUPPORTED - DIR");
                    RAISE INCOMPLETE_DIR;
               WHEN DIR_IO.NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; CREATE WITH " &
                                    "OUT_FILE MODE IS NOT " &
                                    "SUPPORTED - DIR");
                    RAISE INCOMPLETE_DIR;

          END; -- CREATE FIRST FILE

          BEGIN -- OPEN SECOND FILE

               OPEN (DIR_FILE_TWO, IN_FILE, LEGAL_FILE_NAME);

          EXCEPTION

               WHEN DIR_IO.USE_ERROR =>
                    NOT_APPLICABLE ("MULTIPLE INTERNAL FILES ARE NOT " &
                                    "SUPPORTED WHEN ONE IS MODE " &
                                    "OUT_FILE AND THE OTHER IS MODE " &
                                    "IN_FILE");
                    DIR_CLEANUP;
                    RAISE INCOMPLETE_DIR;

          END; -- OPEN SECOND FILE

          DATUM := IDENT_INT(1);
          READ (DIR_FILE_TWO, DATUM);
          IF DATUM /= 5 THEN
               FAILED ("INCORRECT VALUE READ - 1");
          END IF;

          BEGIN -- INITIALIZE FIRST FILE TO CHECK POINTER RESETTING

               RESET (DIR_FILE_ONE);
               IF MODE (DIR_FILE_ONE) /= OUT_FILE THEN
                    FAILED ("FILE WAS NOT RESET - DIR");
               END IF;
               IF MODE (DIR_FILE_TWO) /= IN_FILE THEN
                    FAILED ("RESETTING OF ONE INTERNAL FILE " &
                            "AFFECTED THE OTHER INTERNAL FILE - DIR");
               END IF;

          EXCEPTION

               WHEN DIR_IO.USE_ERROR =>
                    NOT_APPLICABLE ("RESETTING OF EXTERNAL FILE FOR " &
                                    "OUT_FILE MODE IS NOT SUPPORTED " &
                                    "- DIR");
                    DIR_CLEANUP;
                    RAISE INCOMPLETE_DIR;

          END; -- INITIALIZE FIRST FILE TO CHECK POINTER RESETTING

          -- PERFORM SOME I/O ON THE FIRST FILE

          WRITE (DIR_FILE_ONE, 3);
          WRITE (DIR_FILE_ONE, 4);
          WRITE (DIR_FILE_ONE, 5);
          CLOSE (DIR_FILE_ONE);

          BEGIN
               OPEN (DIR_FILE_ONE, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("MULTIPLE INTERNAL FILES NOT " &
                                    "SUPPORTED WHEN BOTH FILES HAVE " &
                                    "IN_FILE MODE");
                    RAISE INCOMPLETE_DIR;
          END;

          READ (DIR_FILE_ONE, DATUM);
          READ (DIR_FILE_ONE, DATUM);

          BEGIN -- INITIALIZE SECOND FILE AND PERFORM SOME I/O

               CLOSE (DIR_FILE_TWO);
               OPEN (DIR_FILE_TWO, IN_FILE, LEGAL_FILE_NAME);
               READ (DIR_FILE_TWO, DATUM);

          EXCEPTION

               WHEN DIR_IO.USE_ERROR =>
                    FAILED ("MULTIPLE INTERNAL FILES SHOULD STILL " &
                            "BE ALLOWED - DIR");
                    DIR_CLEANUP;
                    RAISE INCOMPLETE_DIR;

          END; -- INITIALIZE SECOND FILE AND PERFORM SOME I/O

          BEGIN -- RESET FIRST FILE AND CHECK EFFECTS ON SECOND FILE

               RESET (DIR_FILE_ONE);
               READ (DIR_FILE_TWO, DATUM);
               IF DATUM /= 4 THEN
                    FAILED ("RESETTING INDEX OF ONE DIRECT FILE " &
                            "RESETS THE OTHER ASSOCIATED FILE "   &
                            "- DIR");
               END IF;

          EXCEPTION

               WHEN DIR_IO.USE_ERROR =>
                    FAILED ("RESETTING SHOULD STILL BE SUPPORTED " &
                            "- DIR");
                    DIR_CLEANUP;
                    RAISE INCOMPLETE_DIR;

          END; -- RESET FIRST FILE AND CHECK EFFECTS ON SECOND FILE

          DIR_CLEANUP;

     EXCEPTION

          WHEN INCOMPLETE_DIR =>
               NULL;

     END; -- DIR TEST

     RESULT;

END CE2111H;
