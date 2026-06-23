-- CE2107L.ADA

-- OBJECTIVE:
--     DETERMINE WHETHER AN EXTERNAL FILE MAY BE ASSOCIATED WITH BOTH AN
--     INTERNAL DIRECT FILE AND AN INTERNAL SEQUENTIAL FILE.

--          B) TEMPORARY FILES

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     A TEMPORARY DIRECT FILE WITH OUT_FILE MODE AND A TEMPORARY
--     SEQUENTIAL FILE WITH OUT_FILE MODE ASSOCIATED WITH THE SAME
--     EXTERANAL FILE.

-- HISTORY:
--     SPW 08/05/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;
WITH DIRECT_IO;

PROCEDURE CE2107L IS

BEGIN

     TEST ("CE2107L", "DETERMINE IF SEQUENTIAL AND DIRECT FILES MAY " &
                      "BE ASSOCIATED WITH THE SAME EXTERNAL FILE");

     DECLARE
          PACKAGE SEQ IS NEW SEQUENTIAL_IO (CHARACTER);
          USE SEQ;
          PACKAGE DIR IS NEW DIRECT_IO (CHARACTER);
          USE DIR;
          TYPE ACC_STR IS ACCESS STRING;
          ITEM : CHARACTER;
          INCOMPLETE : EXCEPTION;
          SFT2 : SEQ.FILE_TYPE;
          DFT2 : DIR.FILE_TYPE;
          F_NAME : ACC_STR;
     BEGIN
          CREATE (SFT2, OUT_FILE);
          SEQ.WRITE (SFT2, 'A');
          BEGIN
               F_NAME := NEW STRING'(SEQ.NAME (SFT2));
          EXCEPTION
               WHEN SEQ.USE_ERROR =>
                    NOT_APPLICABLE ("TEMPORARY SEQUENTIAL FILE HAS " &
                                    "NO NAME");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               OPEN (DFT2, OUT_FILE, F_NAME.ALL);
               DIR.WRITE (DFT2, 'B', 2);
               BEGIN
                    CLOSE (DFT2);
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("UNABLE TO CLOSE DIR TEMP FILE");
               END;

          EXCEPTION
               WHEN DIR.USE_ERROR =>
                    NOT_APPLICABLE ("UNABLE TO ASSOCIATE A TEMPORARY " &
                                    "SEQUENTIAL FILE AND A TEMPORARY " &
                                    "DIRECT FILE TO THE SAME " &
                                    "EXTERNAL FILE");
                    RAISE INCOMPLETE;
               WHEN DIR.NAME_ERROR =>
                    FAILED ("NAME_ERROR RAISED FOR OPEN - DIR");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION - OPEN, DIR");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               RESET (SFT2, IN_FILE);
               READ (SFT2, ITEM);
               IF ITEM /= 'A' THEN
                    FAILED ("INCORRECT VALUE READ AFTER RESET");
               END IF;
               CLOSE (SFT2);
          EXCEPTION
               WHEN SEQ.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON RESET FROM " &
                                    "OUT_FILE MODE TO IN_FILE MODE");
          END;

     EXCEPTION
          WHEN SEQ.USE_ERROR =>
               NOT_APPLICABLE ("USE_ERROR RAISED; SEQUENTIAL " &
                               "CREATE WITH OUT_FILE MODE");
          WHEN INCOMPLETE =>
                NULL;

     END;

     RESULT;

END CE2107L;
