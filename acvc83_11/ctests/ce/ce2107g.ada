-- CE2107G.ADA

-- OBJECTIVE:
--     CHECK THAT TWO INTERNAL FILES WITH DIFFERENT ELEMENT_TYPES MAY
--     BE ASSOCIATED WITH THE SAME EXTERNAL FILE FOR DIRECT_IO.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     MULTIPLE ACCESS OF EXTERNAL DIRECT FILES WITH DIFFERENT ELEMENT
--     TYPES.

-- HISTORY:
--     TBN 02/12/86
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     SPW 07/30/87  CORRECTED EXCEPTION HANDLING.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2107G IS

     PACKAGE DIR1 IS NEW DIRECT_IO (INTEGER);
     PACKAGE DIR2 IS NEW DIRECT_IO (BOOLEAN);
     USE DIR1, DIR2;
     ITEM : BOOLEAN := FALSE;
     INCOMPLETE, SUBTEST : EXCEPTION;
     FILE_DIR1 : DIR1.FILE_TYPE;
     FILE_DIR2 : DIR2.FILE_TYPE;

BEGIN

     TEST ( "CE2107G", "CHECK THAT TWO INTERNAL FILES " &
                       "WITH DIFFERENT ELEMENT_TYPES MAY " &
                       "BE ASSOCIATED WITH THE SAME " &
                       "EXTERNAL FILE FOR WRITING FOR DIRECT_IO");

     BEGIN

          BEGIN
               CREATE (FILE_DIR1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN DIR1.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; DIRECT CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN DIR1.NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED; DIRECT " &
                                    "CREATE WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          WRITE (FILE_DIR1, 1);

          BEGIN

               BEGIN
                    OPEN (FILE_DIR2, OUT_FILE, LEGAL_FILE_NAME);
                    WRITE (FILE_DIR2, TRUE);
                    BEGIN
                         CLOSE (FILE_DIR2);
                    EXCEPTION
                         WHEN OTHERS =>
                              FAILED ("UNABLE TO CLOSE SECOND DIR " &
                                      "FILE");
                    END;
               EXCEPTION
                    WHEN DIR2.USE_ERROR =>
                         NOT_APPLICABLE ("THIS IMPLEMENTATION DOES " &
                                         "NOT ALLOW INTERNAL DIRECT " &
                                         "FILES WITH DIFFERENT " &
                                         "ELEMENT_TYPES TO BE " &
                                         "ASSOCIATED WITH THE SAME " &
                                         "EXTERNAL FILE FOR WRITING");
                         RAISE SUBTEST;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION - OPEN, DIR");
                         RAISE SUBTEST;
               END;

               CLOSE (FILE_DIR1);

               BEGIN
                    OPEN (FILE_DIR2, IN_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN DIR2.USE_ERROR =>
                         NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN " &
                                         "WITH IN_FILE MODE");
                         RAISE INCOMPLETE;
               END;

               BEGIN
                    READ (FILE_DIR2, ITEM);
                    IF NOT ITEM THEN
                         FAILED ("INCORRECT VALUE READ");
                    END IF;
               EXCEPTION
                    WHEN DIR2.DATA_ERROR =>
                         FAILED ("DATA_ERROR RAISED FOR READ");
               END;

               BEGIN
                    DELETE (FILE_DIR2);
               EXCEPTION
                    WHEN DIR2.USE_ERROR =>
                         COMMENT ("DELETION OF EXTERNAL FILE NOT " &
                                  "SUPPORTED - 1");
                    WHEN OTHERS =>
                         FAILED ("UNABLE TO DELETE DIRECT FILE");
               END;

          EXCEPTION
               WHEN SUBTEST =>
                    BEGIN
                         DELETE (FILE_DIR1);
                    EXCEPTION
                         WHEN DIR1.USE_ERROR =>
                              COMMENT ("DELETION OF EXTERNAL FILE " &
                                       "NOT SUPPORTED - 2");
                    END;

          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;

     END;

     RESULT;

END CE2107G;
