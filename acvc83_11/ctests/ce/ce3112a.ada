-- CE3112A.ADA

-- OBJECTIVE:
--     CHECK THAT AN EXTERNAL TEXT FILE SPECIFIED BY A NULL STRING
--     NAME IS NOT ACCESSIBLE AFTER THE COMPLETION OF THE MAIN PROGRAM.
--     ALSO CHECK WHETHER A TEMPORARY FILE IS DELETED AFTER IT IS
--     CLOSED.

--     THIS TEST CREATES TEXT FILES WHICH CE3112B TRYS TO READ.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     CREATION OF AN EXTERNAL TEXT FILE AND CREATION OF A TEXT_IO
--     TEMPORARY FILE WITH A NAME LENGTH NOT MORE THAN 255 CHARACTERS
--     LONG.

-- HISTORY:
--     GMT 08/13/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO;

PROCEDURE CE3112A IS

     INCOMPLETE         : EXCEPTION;
     UN_NAMED_FILE      : TEXT_IO.FILE_TYPE;
     NAMED_FILE         : TEXT_IO.FILE_TYPE;
     TEMP_NAME          : STRING (1..255);
     TEMP_LEN           : NATURAL;
     TEMP_FILE_HAS_NAME : BOOLEAN := FALSE;
     STRING_VAR         : STRING (1..5) := "HELLO";

BEGIN
     TEST ("CE3112A", "CHECK THAT AN EXTERNAL TEXT FILE SPECIFIED BY " &
                      "A NULL STRING NAME IS NOT ACCESSIBLE AFTER " &
                      "THE COMPLETION OF THE MAIN PROGRAM");
     BEGIN
          BEGIN
               TEXT_IO.CREATE (UN_NAMED_FILE);
          EXCEPTION
               WHEN TEXT_IO.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT_IO " &
                                    "CREATE FOR AN UNNAMED FILE WITH " &
                                    "OUT_FILE MODE - 1");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                            "TEXT_IO CREATE FOR AN UNNAMED FILE - 2");
                    RAISE INCOMPLETE;
          END;

          TEXT_IO.PUT (UN_NAMED_FILE, STRING_VAR);

          BEGIN
               TEXT_IO.CREATE (NAMED_FILE, TEXT_IO.OUT_FILE,
                               LEGAL_FILE_NAME);
          EXCEPTION
               WHEN TEXT_IO.USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT " &
                                    "CREATE WITH OUT_FILE MODE FOR " &
                                    "A NAMED FILE - 3");
                    RAISE INCOMPLETE;
               WHEN TEXT_IO.NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON TEXT " &
                                    "CREATE WITH OUT_FILE MODE FOR " &
                                    "A NAMED FILE - 4");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON TEXT " &
                            "CREATE - 5");
                    RAISE INCOMPLETE;
          END;

          BEGIN
               TEMP_LEN := TEXT_IO.NAME (UN_NAMED_FILE)'LENGTH;
               IF TEMP_LEN > TEMP_NAME'LAST THEN
                    NOT_APPLICABLE ("TEMP FILE NAME GREATER THAN 255 " &
                                    "CHARACTERS - 6");
                    TEXT_IO.PUT_LINE (NAMED_FILE, "TOO LONG");
               ELSE
                    TEMP_NAME(1..TEMP_LEN) := TEXT_IO.NAME
                                                      (UN_NAMED_FILE);
                    TEXT_IO.PUT_LINE (NAMED_FILE, "HAS NAME");
                    TEXT_IO.PUT (NAMED_FILE, TEMP_NAME(1..TEMP_LEN));
                    TEMP_FILE_HAS_NAME := TRUE;
               END IF;

          EXCEPTION
               WHEN TEXT_IO.USE_ERROR =>
                    TEXT_IO.PUT (NAMED_FILE, "NO NAME");
                    TEMP_FILE_HAS_NAME := FALSE;
          END;

          TEXT_IO.CLOSE (UN_NAMED_FILE);

          IF TEMP_FILE_HAS_NAME THEN
               BEGIN
                    TEXT_IO.OPEN (UN_NAMED_FILE, TEXT_IO.IN_FILE,
                                  TEMP_NAME(1..TEMP_LEN));
                    COMMENT ("TEMP FILE NOT DELETED AFTER CLOSE - 7");
                    TEXT_IO.CLOSE (UN_NAMED_FILE);
               EXCEPTION
                    WHEN TEXT_IO.NAME_ERROR =>
                         COMMENT ("TEMP FILE DELETED AFTER CLOSE - 8");
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION FOR " &
                                 "RE-OPEN - 9");
               END;
          END IF;

          TEXT_IO.CLOSE (NAMED_FILE);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3112A;
