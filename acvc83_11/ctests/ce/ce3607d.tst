-- CE3607D.TST

-- OBJECTIVE:
--     CHECK WHETHER A CONTROL CHARACTER REPRESENTING A FILE TERMINATOR
--     CAN BE WRITTEN.  IF SO, CHECK THAT THE WRITTEN CHARACTER
--     ACTUALLY SERVES AS A FILE TERMINATOR ON INPUT.

-- MACRO SUBSTITUTION:
--     $FILE_TERMINATOR IS A SEQUENCE OF ONE OR MORE CONTROL CHARACTERS
--     USED TO REPRESENT THE END OF FILE FOR FILE INPUT AND OUTPUT.
--     EXAMPLE:  ASCII.LF    OR    ASCII.CR & ASCII.LF

--     IF NO CONTROL CHARACTER EXISTS TO REPRESENT END OF FILE, THEN A
--     SUBSTITUTION OF ONE BLANK (' ') SHOULD BE MADE.

-- HISTORY:
--     BCB 09/20/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3607D IS

     FILE : FILE_TYPE;

     CH : CHARACTER;

     INCOMPLETE : EXCEPTION;

BEGIN
     TEST ("CE3607D", "CHECK WHETHER A CONTROL CHARACTER " &
                      "REPRESENTING A FILE TERMINATOR CAN BE WRITTEN" &
                      ".  IF SO, CHECK THAT THE WRITTEN CHARACTER " &
                      "ACTUALLY SERVES AS A FILE TERMINATOR ON INPUT");

     IF ($FILE_TERMINATOR) & ' ' = "  " THEN
          COMMENT ("NO CONTROL CHARACTER REPRESENTING A FILE " &
                   "TERMINATOR EXISTS");
     ELSE
          BEGIN
               BEGIN
                    CREATE (FILE, OUT_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                         "WITH OUT_FILE MODE");
                         RAISE INCOMPLETE;
                    WHEN NAME_ERROR =>
                         NOT_APPLICABLE ("NAME_ERROR RAISED ON " &
                                         "CREATE WITH OUT_FILE MODE");
                         RAISE INCOMPLETE;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                                 "CREATE");
                         RAISE INCOMPLETE;
               END;

               PUT (FILE, 'A');
               PUT (FILE, 'B');
               PUT (FILE, $FILE_TERMINATOR);

               BEGIN
                    PUT (FILE, 'C');
                    FAILED ("NO EXCEPTION RAISED FOR ATTEMPTED WRITE " &
                            "AFTER FILE TERMINATOR");
               EXCEPTION
                    WHEN OTHERS =>
                         COMMENT ("ATTEMPT TO WRITE TO FILE WITH " &
                                  "FILE TERMINATOR WAS UNSUCCESSFUL");
               END;

               CLOSE (FILE);

               BEGIN
                    OPEN (FILE, IN_FILE, LEGAL_FILE_NAME);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN " &
                                         "WITH IN_FILE MODE");
                         RAISE INCOMPLETE;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED ON OPEN");
                         RAISE INCOMPLETE;
               END;

               GET (FILE, CH);
               GET (FILE, CH);

               IF CH /= 'B' THEN
                    FAILED ("INCORRECT VALUE READ FROM FILE");
               END IF;

               IF NOT END_OF_FILE (FILE) THEN
                    FAILED ("FILE TERMINATOR NOT RECOGNIZED");
               END IF;

               BEGIN
                    GET (FILE, CH);
                    FAILED ("NO EXCEPTION RAISED FOR ATTEMPTED READ " &
                            "AFTER FILE TERMINATOR");
               EXCEPTION
                    WHEN OTHERS =>
                         COMMENT ("ATTEMPT TO READ FROM FILE AFTER " &
                                  "FILE TERMINATOR WAS UNSUCCESSFUL");
               END;

               BEGIN
                    DELETE (FILE);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
               END;
          EXCEPTION
               WHEN INCOMPLETE =>
                    NULL;
          END;
     END IF;

     RESULT;
END CE3607D;
