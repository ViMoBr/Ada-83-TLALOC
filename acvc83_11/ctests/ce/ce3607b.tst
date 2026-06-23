-- CE3607B.TST

-- OBJECTIVE:
--     CHECK WHETHER A CONTROL CHARACTER REPRESENTING A LINE TERMINATOR
--     CAN BE WRITTEN.  IF SO, CHECK THAT THE WRITTEN CHARACTER
--     ACTUALLY SERVES AS A LINE TERMINATOR ON INPUT.

-- MACRO SUBSTITUTION:
--     $LINE_TERMINATOR IS A SEQUENCE OF ONE OR MORE CONTROL CHARACTERS
--     USED TO REPRESENT THE END OF LINE FOR FILE INPUT AND OUTPUT.
--     EXAMPLE:  ASCII.LF    OR    ASCII.CR & ASCII.LF

--     IF NO CONTROL CHARACTER EXISTS TO REPRESENT END OF LINE, THEN A
--     SUBSTITUTION OF ONE BLANK (' ') SHOULD BE MADE.

-- HISTORY:
--     BCB 09/19/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3607B IS

     FILE : FILE_TYPE;

     CH : CHARACTER;

     INCOMPLETE : EXCEPTION;

BEGIN
     TEST ("CE3607B", "CHECK WHETHER A CONTROL CHARACTER " &
                      "REPRESENTING A LINE TERMINATOR CAN BE WRITTEN" &
                      ".  IF SO, CHECK THAT THE WRITTEN CHARACTER " &
                      "ACTUALLY SERVES AS A LINE TERMINATOR ON INPUT");

     IF ($LINE_TERMINATOR) & ' ' = "  " THEN
          COMMENT ("NO CONTROL CHARACTER REPRESENTING A LINE " &
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
               PUT (FILE, $LINE_TERMINATOR);
               PUT (FILE, 'C');

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

               IF NOT END_OF_LINE (FILE) THEN
                    FAILED ("LINE TERMINATOR NOT RECOGNIZED");
               END IF;

               GET (FILE, CH);

               IF CH /= 'C' THEN
                    FAILED ("INCORRECT VALUE IN FILE");
               END IF;

               IF COL (FILE) /= 2 THEN
                    FAILED ("INCORRECT COLUMN NUMBER");
               END IF;

               IF LINE (FILE) /= 2 THEN
                    FAILED ("INCORRECT LINE NUMBER");
               END IF;

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
END CE3607B;
