-- CE2205B.ADA

-- OBJECTIVE:
--     CHECK WHETHER READ FOR A SEQUENTIAL FILE RAISES DATA_ERROR
--     WHEN AN INVALID ELEMENT IS READ AND CHECK THAT READING CAN
--     CONTINUE AFTER THE EXCEPTION HAS BEEN HANDLED.

--          B) WRITE TO THE FILE ELEMENTS OF ONE TYPE AND READ THEM BACK
--             AS ELEMENTS OF ANOTHER TYPE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH
--     SUPPORT SEQUENTIAL FILES.

-- HISTORY:
--     JLH 08/25/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2205B IS

     TYPE DWARFS IS (SLEEPY, DOC, HAPPY, GRUMPY, DOPEY, BASHFUL,
                     SNEEZY);

     TYPE LAKES IS (HURON, ONTARIO, MICHIGAN, ERIE, SUPERIOR);

     PACKAGE DWARFS_IO IS NEW SEQUENTIAL_IO (DWARFS);
     USE DWARFS_IO;

     PACKAGE LAKES_IO IS NEW SEQUENTIAL_IO (LAKES);
     USE LAKES_IO;

     FILE1 : DWARFS_IO.FILE_TYPE;
     FILE2 : LAKES_IO.FILE_TYPE;
     LAKE : LAKES;
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE2205B", "CHECK WHETHER READ FOR A SEQUENTIAL FILE " &
                      "RAISES DATA_ERROR WHEN AN INVALID ELEMENT " &
                      "IS READ AND CHECK THAT " &
                      "READING CAN CONTINUE AFTER THE EXCEPTION HAS " &
                      "BEEN HANDLED");

     BEGIN

          BEGIN
               CREATE (FILE1, DWARFS_IO.OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN DWARFS_IO.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN DWARFS_IO.NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          WRITE (FILE1, SLEEPY);
          WRITE (FILE1, SNEEZY);
          WRITE (FILE1, DOC);
          WRITE (FILE1, HAPPY);

          CLOSE (FILE1);

          BEGIN
               OPEN  (FILE2, LAKES_IO.IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN LAKES_IO.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN WITH " &
                                    "MODE IN_FILE");
                    RAISE INCOMPLETE;
          END;

          READ (FILE2, LAKE);
          IF LAKE /= HURON THEN
               FAILED ("INCORRECT VALUE FOR READ - 1");
          END IF;

          BEGIN
               READ (FILE2, LAKE);
               COMMENT ("NO EXCEPTION RAISED FOR READ WITH INVALID " &
                        "ELEMENT");
          EXCEPTION
               WHEN LAKES_IO.DATA_ERROR =>
                    COMMENT ("DATA_ERROR RAISED FOR READ WITH " &
                             "INVALID ELEMENT");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED");
          END;

          BEGIN
               READ (FILE2, LAKE);
               IF LAKE /= ONTARIO THEN
                    FAILED ("INCORRECT VALUE FOR READ - 2");
               END IF;

               READ (FILE2, LAKE);
               IF LAKE /= MICHIGAN THEN
                    FAILED ("INCORRECT VALUE FOR READ - 3");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("UNABLE TO CONTINUE READING");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               DELETE (FILE2);
          EXCEPTION
               WHEN LAKES_IO.USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2205B;
