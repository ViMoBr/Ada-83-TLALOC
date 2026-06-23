-- CE2107E.ADA

-- OBJECTIVE:
--     DETERMINE WHETHER AN EXTERNAL FILE MAY BE ASSOCIATED WITH BOTH AN
--     INTERNAL DIRECT FILE AND AN INTERNAL SEQUENTIAL FILE.

--          A) PERMANENT EXTERNAL FILES

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     A DIRECT FILE WITH OUT_FILE MODE AND A SEQUENTIAL FILE WITH
--     OUT_FILE MODE ASSOCIATED WITH THE SAME EXTERNAL FILE.

-- HISTORY:
--     SPS 09/28/82
--     SPS 11/09/82
--     JBG 06/04/84
--     JBG 12/03/84  ALLOW USE_ERROR FOR NAME FUNCTION.
--     JRK 11/21/85  INITIALIZED VARIABLE TEMP_HAS_NAME.
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     SPW 08/05/87  SPLIT CASE FOR TEMPORARY FILES INTO
--                   CE2107L.ADA.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;
WITH DIRECT_IO;

PROCEDURE CE2107E IS

BEGIN

     TEST ("CE2107E", "DETERMINE IF SEQUENTIAL AND DIRECT FILES MAY " &
                      "BE ASSOCIATED WITH THE SAME EXTERNAL FILE");

     DECLARE
          PACKAGE SEQ IS NEW SEQUENTIAL_IO (CHARACTER);
          USE SEQ;
          PACKAGE DIR IS NEW DIRECT_IO (CHARACTER);
          USE DIR;
          INCOMPLETE : EXCEPTION;
          ITEM : CHARACTER;
          SFT1 : SEQ.FILE_TYPE;
          DFT1 : DIR.FILE_TYPE;

     BEGIN

          BEGIN
               CREATE (SFT1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN SEQ.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; SEQUENTIAL " &
                                    "CREATE WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN SEQ.NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; SEQUENTIAL " &
                                    "CREATE WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          WRITE (SFT1, 'A');

          BEGIN

               BEGIN
                    OPEN (DFT1, OUT_FILE, LEGAL_FILE_NAME);
                    WRITE (DFT1, 'B', 2);
                    BEGIN
                         CLOSE (DFT1);
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ("UNABLE TO CLOSE DIR FILE");
                    END;
               EXCEPTION
                    WHEN DIR.USE_ERROR =>
                         NOT_APPLICABLE ("UNABLE TO ASSOCIATE A " &
                                         "SEQUENTIAL FILE AND A " &
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

               CLOSE (SFT1);

               BEGIN
                    OPEN (SFT1, IN_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN SEQ.USE_ERROR =>
                         NOT_APPLICABLE ("USE_ERROR RAISED; " &
                                         "SEQUENTIAL OPEN WITH " &
                                         "IN_FILE MODE");
                         RAISE INCOMPLETE;
               END;

               READ (SFT1, ITEM);
               IF ITEM /= 'A' THEN
                    FAILED ("INCORRECT VALUE READ");
               END IF;

          EXCEPTION
               WHEN INCOMPLETE =>
                    NULL;
          END;

          BEGIN
               DELETE (SFT1);
          EXCEPTION
               WHEN SEQ.USE_ERROR =>
                    COMMENT ("DELETION OF EXTERNAL FILE NOT SUPPORTED");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED FOR DELETE");
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;

     END;

     RESULT;

END CE2107E;
