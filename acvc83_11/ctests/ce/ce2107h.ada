-- CE2107H.ADA

-- OBJECTIVE:
--     DETERMINE WHETHER MORE THAN ONE INTERNAL FILE MAY BE ASSOCIATED
--     WITH THE SAME EXTERNAL FILE FOR DIRECT_IO WHEN ONE FILE IS
--     WRITING AND THE OTHER IS READING.

--          B) TEMPORARY FILE

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     MULTIPLE ACCESS OF EXTERNAL DIRECT FILES WHEN ONE FILE IS
--     WRITING AND THE OTHER IS READING.

-- HISTORY:
--     TBN 02/13/86
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     SPW 08/05/87  CORRECTED EXCEPTION HANDLING.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2107H IS
BEGIN

     TEST ("CE2107H", "DETERMINE WHETHER MORE THAN ONE FILE MAY BE " &
                      "ASSOCIATED WITH A TEMPORARY FILE WHEN READING " &
                      "AND WRITING FOR DIRECT_IO");

     DECLARE
          PACKAGE DIR IS NEW DIRECT_IO (CHARACTER);
          USE DIR;
          CH : CHARACTER;
          FT1, FT2 : FILE_TYPE;
     BEGIN
          CREATE (FT1);
          WRITE (FT1, 'A');

          BEGIN
               DECLARE
                    F_NAME : CONSTANT STRING := NAME (FT1);
               BEGIN
                    OPEN (FT2, IN_FILE, F_NAME);
                    READ (FT2, CH);
                    IF CH /= 'A' THEN
                         FAILED ("INCORRECT VALUE READ");
                    END IF;

                    BEGIN
                         CLOSE (FT2);
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ("CAN'T CLOSE SECOND FILE - DIR");
                    END;
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("CANNOT ASSOCIATE MORE THAN " &
                                         "ONE INTERNAL FILE WITH THE " &
                                         "SAME EXTERNAL FILE, WHEN " &
                                         "ONE FILE IS WRITING AND " &
                                         "THE OTHER IS READING");
                    WHEN NAME_ERROR =>
                         FAILED ("TEMP FILE NAME NOT USABLE IN OPEN - "&
                                 "DIR");
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION - DIR, OPEN");
               END;
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("TEMPORARY DIRECT FILES HAVE NO " &
                                    "NAME");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED");
          END;

          BEGIN
               CLOSE (FT1);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED("UNEXPECTED EXCEPTION RAISED FOR CLOSE");
          END;
     EXCEPTION
          WHEN USE_ERROR =>
               NOT_APPLICABLE ("USE_ERROR RAISED; DIRECT CREATE OF " &
                               "TEMP FILE WITH INOUT_FILE MODE");
          WHEN NAME_ERROR =>
               FAILED ("NAME_ERROR RAISED; DIRECT CREATE OF TEMP " &
                       "FILE WITH INOUT_FILE MODE");
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED; DIRECT CREATE");
     END;

     RESULT;
END CE2107H;
