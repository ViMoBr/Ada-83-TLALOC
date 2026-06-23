-- CE2108C.ADA

-- OBJECTIVE:
--     CHECK THAT AN EXTERNAL DIRECT FILE SPECIFIED BY A NULL STRING
--     NAME IS NOT ACCESSIBLE AFTER THE COMPLETION OF THE MAIN PROGRAM.
--     ALSO CHECK WHETHER A TEMPORARY FILE IS DELETED AFTER IT IS
--     CLOSED.

--     THIS TEST CREATES A DIRECT FILE AND A TEXT FILE;  CE2108D.ADA
--     TRIES TO READ THEM.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     CREATION OF AN EXTERNAL TEXT FILE AND CREATION OF A DIRECT
--     TEMPORARY FILE WITH A NAME LENGTH NOT MORE THAN 255 CHARACTERS
--     LONG.

-- HISTORY:
--     TBN 07/16/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;
WITH TEXT_IO;

PROCEDURE CE2108C IS

     PACKAGE DIR IS NEW DIRECT_IO (INTEGER);
     INCOMPLETE : EXCEPTION;
     FILE_NULL_NAME : DIR.FILE_TYPE;
     NAMES_FILE : TEXT_IO.FILE_TYPE;
     TEMP_NAME : STRING (1..255);
     TEMP_LEN : NATURAL;
     TEMP_FILE_HAS_NAME : BOOLEAN := FALSE;
     VAR1 : INTEGER := 5;

BEGIN
     TEST ("CE2108C", "CHECK THAT AN EXTERNAL DIRECT FILE SPECIFIED " &
                      "BY A NULL STRING NAME IS NOT ACCESSIBLE AFTER " &
                      "THE COMPLETION OF THE MAIN PROGRAM");
     BEGIN
          BEGIN
               DIR.CREATE (FILE_NULL_NAME);
          EXCEPTION
               WHEN DIR.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON DIRECT " &
                                    "CREATE FOR NULL FILE NAME " &
                                    "WITH INOUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                            "DIRECT CREATE FOR NULL FILE NAME");
                    RAISE INCOMPLETE;
          END;

          DIR.WRITE (FILE_NULL_NAME, VAR1);

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
               TEMP_LEN := DIR.NAME (FILE_NULL_NAME)'LENGTH;
               IF TEMP_LEN > TEMP_NAME'LAST THEN
                    NOT_APPLICABLE ("TEMP FILE NAME GREATER THAN 255 " &
                                    "CHARACTERS");
                    TEXT_IO.PUT_LINE (NAMES_FILE, "TOO LONG");
               ELSE
                    TEMP_NAME(1..TEMP_LEN) := DIR.NAME (FILE_NULL_NAME);
                    TEXT_IO.PUT_LINE (NAMES_FILE, "HAS NAME");
                    TEXT_IO.PUT (NAMES_FILE, TEMP_NAME(1..TEMP_LEN));
                    TEMP_FILE_HAS_NAME := TRUE;
               END IF;

          EXCEPTION
               WHEN DIR.USE_ERROR =>
                    TEXT_IO.PUT (NAMES_FILE, "NO NAME");
                    TEMP_FILE_HAS_NAME := FALSE;
          END;

          DIR.CLOSE (FILE_NULL_NAME);

          IF TEMP_FILE_HAS_NAME THEN
               BEGIN
                    DIR.OPEN (FILE_NULL_NAME, DIR.IN_FILE,
                              TEMP_NAME(1..TEMP_LEN));
                    COMMENT ("TEMP FILE NOT DELETED AFTER CLOSE");
                    DIR.CLOSE (FILE_NULL_NAME);
               EXCEPTION
                    WHEN DIR.NAME_ERROR =>
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

END CE2108C;
