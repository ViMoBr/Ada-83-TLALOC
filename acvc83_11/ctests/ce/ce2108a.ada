-- CE2108A.ADA

-- OBJECTIVE:
--     CHECK THAT AN EXTERNAL SEQUENTIAL FILE SPECIFIED BY A NULL STRING
--     NAME IS NOT ACCESSIBLE AFTER THE COMPLETION OF THE MAIN PROGRAM.
--     ALSO CHECK WHETHER A TEMPORARY FILE IS DELETED AFTER IT IS
--     CLOSED.

--     THIS TEST CREATES A SEQUENTIAL FILE AND A TEXT FILE;  CE2108B
--     TRIES TO READ THEM.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     CREATION OF AN EXTERNAL TEXT FILE AND CREATION OF A SEQUENTIAL
--     TEMPORARY FILE WITH A NAME LENGTH NOT MORE THAN 255 CHARACTERS
--     LONG.

-- HISTORY:
--     TBN 07/16/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;
WITH TEXT_IO;

PROCEDURE CE2108A IS

     PACKAGE SEQ IS NEW SEQUENTIAL_IO (INTEGER);
     INCOMPLETE : EXCEPTION;
     FILE_NULL_NAME : SEQ.FILE_TYPE;
     NAMES_FILE : TEXT_IO.FILE_TYPE;
     TEMP_NAME : STRING (1..255);
     TEMP_LEN : NATURAL;
     TEMP_FILE_HAS_NAME : BOOLEAN := FALSE;
     VAR1 : INTEGER := 5;

BEGIN
     TEST ("CE2108A" , "CHECK THAT AN EXTERNAL SEQUENTIAL FILE " &
                       "SPECIFIED BY A NULL STRING NAME IS NOT " &
                       "ACCESSIBLE AFTER THE COMPLETION OF THE MAIN " &
                       "PROGRAM");
     BEGIN
          BEGIN
               SEQ.CREATE (FILE_NULL_NAME);
          EXCEPTION
               WHEN SEQ.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON SEQUENTIAL " &
                                    "CREATE FOR NULL FILE NAME WITH " &
                                    "OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                            "SEQUENTIAL CREATE FOR NULL FILE NAME");
                    RAISE INCOMPLETE;
          END;

          SEQ.WRITE (FILE_NULL_NAME, VAR1);

          BEGIN
               TEXT_IO.CREATE (NAMES_FILE, TEXT_IO.OUT_FILE,
                               LEGAL_FILE_NAME);
          EXCEPTION
               WHEN TEXT_IO.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN TEXT_IO.NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON TEXT " &
                                    "CREATE WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON TEXT " &
                            "CREATE");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               TEMP_LEN := SEQ.NAME (FILE_NULL_NAME)'LENGTH;
               IF TEMP_LEN > TEMP_NAME'LAST THEN
                    NOT_APPLICABLE ("TEMP FILE NAME GREATER THAN 255 " &
                                    "CHARACTERS");
                    TEXT_IO.PUT_LINE (NAMES_FILE, "TOO LONG");
               ELSE
                    TEMP_NAME(1..TEMP_LEN) := SEQ.NAME (FILE_NULL_NAME);
                    TEXT_IO.PUT_LINE (NAMES_FILE, "HAS NAME");
                    TEXT_IO.PUT (NAMES_FILE, TEMP_NAME(1..TEMP_LEN));
                    TEMP_FILE_HAS_NAME := TRUE;
               END IF;

          EXCEPTION
               WHEN SEQ.USE_ERROR =>
                    TEXT_IO.PUT (NAMES_FILE, "NO NAME");
                    TEMP_FILE_HAS_NAME := FALSE;
          END;

          SEQ.CLOSE (FILE_NULL_NAME);

          IF TEMP_FILE_HAS_NAME THEN
               BEGIN
                    SEQ.OPEN (FILE_NULL_NAME, SEQ.IN_FILE,
                              TEMP_NAME(1..TEMP_LEN));
                    COMMENT ("TEMP FILE NOT DELETED AFTER CLOSE");
                    SEQ.CLOSE (FILE_NULL_NAME);
               EXCEPTION
                    WHEN SEQ.NAME_ERROR =>
                         COMMENT ("TEMP FILE DELETED AFTER CLOSE");
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION FOR RE-OPEN");
               END;
          END IF;

          TEXT_IO.CLOSE (NAMES_FILE);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2108A;
