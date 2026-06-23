-- CE2401L.ADA

-- OBJECTIVE:
--     CHECK THAT REWRITING AN ELEMENT DOES NOT CHANGE THE SIZE OF
--     THE FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     CREATE WITH INOUT_FILE MODE FOR DIRECT FILES.

-- HISTORY:
--     DWC 08/12/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2401L IS
     END_SUBTEST: EXCEPTION;
BEGIN

     TEST ("CE2401L" , "CHECK THAT REWRITING AN ELEMENT DOES NOT " &
                       "CHANGE THE SIZE OF THE FILE");

     DECLARE
          PACKAGE DIR_IO IS NEW DIRECT_IO (INTEGER);
          USE DIR_IO;
          FILE : FILE_TYPE;
     BEGIN
          BEGIN
               CREATE (FILE, INOUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR | NAME_ERROR =>
                    NOT_APPLICABLE ("CREATE WITH INOUT_FILE MODE " &
                                    "NOT SUPPORTED");
                    RAISE END_SUBTEST;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED ERROR RAISED ON " &
                            "CREATE");
                    RAISE END_SUBTEST;
          END;

          DECLARE
               OUT_ITEM1 : INTEGER := 10;
               OUT_ITEM2 : INTEGER := 21;
               OUT_ITEM4 : INTEGER := 43;
               IN_ITEM   : INTEGER;
               ONE  : POSITIVE_COUNT := 1;
               TWO  : POSITIVE_COUNT := 2;
               FOUR : POSITIVE_COUNT := 4;
               OLD_FILE_SIZE : POSITIVE_COUNT;
          BEGIN
               BEGIN
                    WRITE (FILE, OUT_ITEM1, ONE);
                    WRITE (FILE, OUT_ITEM4, FOUR);
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED ON WRITE " &
                                 "IN INOUT_FILE MODE");
                         RAISE END_SUBTEST;
               END;

               OLD_FILE_SIZE := SIZE (FILE);

               WRITE (FILE, OUT_ITEM1, ONE);
               WRITE (FILE, OUT_ITEM4, FOUR);

               IF OLD_FILE_SIZE /= SIZE (FILE) THEN
                    FAILED ("FILE SIZE CHANGED DURING REWRITE - 1");
                    RAISE END_SUBTEST;
               END IF;

               WRITE (FILE, OUT_ITEM1, ONE);
               WRITE (FILE, OUT_ITEM2, TWO);
               WRITE (FILE, OUT_ITEM4, FOUR);

               OLD_FILE_SIZE := SIZE (FILE);

               WRITE (FILE, OUT_ITEM1, FOUR);

               IF OLD_FILE_SIZE /= SIZE (FILE) THEN
                    FAILED ("FILE SIZE CHANGED DURING REWRITE - 2");
                    RAISE END_SUBTEST;
               END IF;
          EXCEPTION
               WHEN END_SUBTEST =>
                    NULL;
          END;

          BEGIN
               DELETE (FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN END_SUBTEST =>
               NULL;
     END;

     RESULT;

END CE2401L;
