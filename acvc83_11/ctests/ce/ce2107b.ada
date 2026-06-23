-- CE2107B.ADA

-- OBJECTIVE:
--     CHECK THAT TWO INTERNAL FILES WITH DIFFERENT ELEMENT_TYPES
--     MAY BE ASSOCIATED WITH THE SAME EXTERNAL FILE FOR WRITING.

--          A) SEQUENTIAL FILES.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     MULTIPLE ACCESS OF EXTERNAL SEQUENTIAL FILES FOR WRITING.

-- HISTORY:
--     ABW 08/13/82
--     SPS 11/09/82
--     JBG 06/04/84
--     TBN 02/12/86  SPLIT TEST.  PUT DIRECT_IO INTO CE2107G.ADA.
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     SPW 08/04/87  CORRECTED EXCEPTION HANDLING.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2107B IS

     PACKAGE SEQ1 IS NEW SEQUENTIAL_IO (INTEGER);
     PACKAGE SEQ2 IS NEW SEQUENTIAL_IO (BOOLEAN);
     USE SEQ1, SEQ2;
     FILE_SEQ1 : SEQ1.FILE_TYPE;
     FILE_SEQ2 : SEQ2.FILE_TYPE;
     INCOMPLETE, SUBTEST : EXCEPTION;
     VAR1 : BOOLEAN := FALSE;

BEGIN

     TEST ( "CE2107B", "CHECK THAT TWO INTERNAL FILES " &
                       "WITH DIFFERENT ELEMENT_TYPES MAY " &
                       "BE ASSOCIATED WITH THE SAME " &
                       "EXTERNAL FILE FOR WRITING WITH SEQ_IO");

     BEGIN

          CREATE (FILE_SEQ1, OUT_FILE, LEGAL_FILE_NAME);
          WRITE (FILE_SEQ1, IDENT_INT(1));

          BEGIN
               OPEN (FILE_SEQ2, OUT_FILE, LEGAL_FILE_NAME);
               WRITE (FILE_SEQ2, IDENT_BOOL(TRUE));
               BEGIN
                    CLOSE (FILE_SEQ2);
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("UNABLE TO CLOSE SECOND SEQ FILE");
               END;
          EXCEPTION
               WHEN SEQ2.USE_ERROR =>
                    NOT_APPLICABLE ("THIS IMPLEMENTATION DOES NOT " &
                                    "ALLOW TWO INTERNAL SEQUENTIAL " &
                                    "FILES OF DIFFERENT TYPES TO BE " &
                                    "ASSOCIATED WITH THE SAME " &
                                    "EXTERNAL FILE FOR WRITING");
                    RAISE SUBTEST;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION ON OPEN");
                    RAISE SUBTEST;
          END;

          CLOSE (FILE_SEQ1);

          BEGIN
               OPEN (FILE_SEQ2, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN SEQ2.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN WITH " &
                                    "IN_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON SECOND " &
                            "OPEN");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               DELETE (FILE_SEQ2);
          EXCEPTION
               WHEN SEQ2.USE_ERROR =>
                    COMMENT ("DELETION OF EXTERNAL FILE NOT " &
                             "SUPPORTED - 1");
               WHEN OTHERS =>
                    FAILED ("UNABLE TO DELETE SEQ FILE - 1");
          END;
     EXCEPTION
          WHEN SEQ1.USE_ERROR =>
               NOT_APPLICABLE ("USE_ERROR RAISED; SEQUENTIAL CREATE " &
                               "WITH OUT_FILE MODE");
          WHEN SEQ1.NAME_ERROR =>
               NOT_APPLICABLE ("NAME_ERROR RAISED; SEQUENTIAL CREATE " &
                               "WITH OUT_FILE MODE");
          WHEN SUBTEST =>
               BEGIN
                    DELETE (FILE_SEQ1);
               EXCEPTION
                    WHEN SEQ1.USE_ERROR =>
                         COMMENT ("DELETION OF EXTERNAL FILE NOT " &
                                  "SUPPORTED - 2");
                    WHEN OTHERS =>
                         FAILED ("UNABLE TO DELETE SEQ FILE - 2");
               END;
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2107B;
