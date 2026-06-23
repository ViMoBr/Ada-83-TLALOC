-- CE2107I.ADA

-- OBJECTIVE:
--     DETERMINE WHETHER FILES OF DIFFERENT ELEMENT TYPES MAY BE
--     ASSOCIATED WITH THE SAME EXTERNAL FILE FOR DIRECT_IO WHEN ONE
--     FILE CAN READ OR WRITE AND THE OTHER CAN WRITE.

--          B) TEMPORARY FILE

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     MULTIPLE ACCESSES OF EXTERNAL FILES WHEN ONE FILE CAN READ OR
--     WRITE AND THE OTHER CAN WRITE.

-- HISTORY:
--     TBN 02/13/86
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     SPW 08/05/87  CORRECTED EXCEPTION HANDLING.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2107I IS
BEGIN

     TEST ("CE2107I", "DETERMINE IF FILES OF DIFFERENT TYPES MAY BE " &
                      "ASSOCIATED WITH A TEMPORARY FILE FOR DIRECT_IO");

     DECLARE
          PACKAGE DIR1 IS NEW DIRECT_IO (CHARACTER);
          USE DIR1;
          PACKAGE DIR2 IS NEW DIRECT_IO (BOOLEAN);
          USE DIR2;
          CH1 : CHARACTER;
          INCOMPLETE : EXCEPTION;
          FT1 : DIR1.FILE_TYPE;
          FT2 : DIR2.FILE_TYPE;

     BEGIN
          BEGIN
               CREATE (FT1);
               WRITE (FT1, 'A');
               BEGIN
                    DECLARE
                         F_NAME : CONSTANT STRING := NAME (FT1);
                    BEGIN
                         OPEN (FT2, OUT_FILE, F_NAME);
                         WRITE (FT2, TRUE);
                         BEGIN
                              CLOSE (FT2);
                         EXCEPTION
                              WHEN OTHERS =>
                                   FAILED ("CAN'T CLOSE SECOND FILE " &
                                           "- DIR");
                         END;
                    EXCEPTION
                         WHEN DIR2.USE_ERROR =>
                              NOT_APPLICABLE ("CANNOT ASSOCIATE " &
                                              "MULTIPLE TEMPORARY " &
                                              "DIRECT INTERNAL FILES " &
                                              "WITH DIFFERENT " &
                                              "ELEMENT TYPES, WHEN " &
                                              "ONE FILE CAN READ OR " &
                                              "WRITE AND THE OTHER " &
                                              "CAN WRITE TO SAME " &
                                              "EXTERNAL FILE");
                              CLOSE (FT1);
                              RAISE INCOMPLETE;
                         WHEN DIR2.NAME_ERROR =>
                              FAILED ("TEMP FILE NAME NOT USABLE IN " &
                                      "OPEN - DIR");
                              CLOSE (FT1);
                              RAISE INCOMPLETE;
                         WHEN OTHERS =>
                              FAILED ("UNEXPECTED EXCEPTION - DIR, " &
                                      "OPEN");
                              CLOSE (FT1);
                              RAISE INCOMPLETE;
                    END;
               EXCEPTION
                    WHEN DIR1.USE_ERROR =>
                         NOT_APPLICABLE ("TEMPORARY DIRECT FILES " &
                                         "HAVE NO NAME");
                         CLOSE (FT1);
                         RAISE INCOMPLETE;
               END;

               BEGIN
                    DIR1.READ (FT1, CH1, 1);
                    FAILED ("DATA_ERROR NOT RAISED FOR DIRECT_IO READ");
               EXCEPTION
                    WHEN DIR1.DATA_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - READ");
               END;

               BEGIN
                    CLOSE (FT1);
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED("CAN'T CLOSE FIRST FILE - DIR");
               END;

          EXCEPTION
               WHEN DIR1.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; DIRECT CREATE " &
                                    "OF TEMP FILE WITH INOUT_FILE " &
                                    "MODE");
               WHEN DIR1.NAME_ERROR =>
                    FAILED ("NAME_ERROR RAISED; DIRECT CREATE OF " &
                            "TEMP FILE WITH INOUT_FILE MODE");
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;

     END;

     RESULT;

END CE2107I;
