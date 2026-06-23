-- CE2401K.ADA

-- OBJECTIVE:
--     CHECK THAT DATA CAN BE OVERWRITTEN IN THE DIRECT FILE AND
--     THE CORRECT VALUES CAN LATER BE READ.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     CREATION OF INOUT_FILE MODE AND OPENING OF OUT_FILE MODE FOR
--     DIRECT FILES.

-- HISTORY:
--     DWC 08/12/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2401K IS
     END_SUBTEST: EXCEPTION;
BEGIN

     TEST ("CE2401K" , "CHECK THAT DATA CAN BE OVERWRITTEN IN " &
                       "THE DIRECT FILE AND THE CORRECT VALUES " &
                       "CAN LATER BE READ.");

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
               IN_ITEM   : INTEGER;
               ONE : POSITIVE_COUNT := 1;
               TWO : POSITIVE_COUNT := 2;
          BEGIN
               BEGIN
                    WRITE (FILE, OUT_ITEM1, ONE);
                    WRITE (FILE, OUT_ITEM2, TWO);
                    WRITE (FILE, OUT_ITEM2, ONE);
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED ON WRITE " &
                                 "IN INOUT_FILE MODE");
                         RAISE END_SUBTEST;
               END;

               BEGIN
                    READ (FILE, IN_ITEM, ONE);
                    IF OUT_ITEM2 /= IN_ITEM THEN
                         FAILED ("INCORRECT INTEGER VALUE READ - 1");
                         RAISE END_SUBTEST;
                    END IF;
               END;

               BEGIN
                    READ (FILE, IN_ITEM, TWO);
                    IF OUT_ITEM2 /= IN_ITEM THEN
                         FAILED ("INCORRECT INTEGER VALUE READ - 2");
                         RAISE END_SUBTEST;
                    END IF;
               END;

               CLOSE (FILE);

               BEGIN
                    OPEN (FILE, OUT_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN USE_ERROR =>
                         RAISE END_SUBTEST;
               END;

               BEGIN
                    WRITE (FILE, OUT_ITEM1, ONE);
                    WRITE (FILE, OUT_ITEM2, TWO);
                    WRITE (FILE, OUT_ITEM1, TWO);
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("EXCEPTION RAISED ON WRITE " &
                                 "IN OUT_FILE MODE");
                         RAISE END_SUBTEST;
               END;

               BEGIN
                    RESET (FILE, IN_FILE);
               EXCEPTION
                    WHEN USE_ERROR =>
                         RAISE END_SUBTEST;
               END;

               BEGIN
                    READ (FILE, IN_ITEM, ONE);
                    IF OUT_ITEM1 /= IN_ITEM THEN
                         FAILED ("INCORRECT INTEGER VALUE READ - 3");
                         RAISE END_SUBTEST;
                    END IF;
               EXCEPTION
                    WHEN USE_ERROR =>
                         FAILED ("READ IN IN_FILE MODE - 1");
               END;

               BEGIN
                    READ (FILE, IN_ITEM, TWO);
                    IF OUT_ITEM1 /= IN_ITEM THEN
                         FAILED ("INCORRECT INTEGER VALUE READ - 4");
                         RAISE END_SUBTEST;
                    END IF;
               EXCEPTION
                    WHEN USE_ERROR =>
                         FAILED ("READ IN IN_FILE MODE - 2");
               END;
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

END CE2401K;
