-- CE3604A.ADA

-- OBJECTIVE:
--     CHECK THAT GET_LINE MAY BE CALLED TO RETURN AN ENTIRE LINE.  ALSO
--     CHECK THAT GET_LINE MAY BE CALLED TO RETURN THE REMAINDER OF A
--     PARTLY READ LINE.  ALSO CHECK THAT GET_LINE RETURNS IN THE
--     PARAMETER LAST, THE INDEX VALUE OF THE LAST CHARACTER READ.
--     WHEN NO CHARACTERS ARE READ, LAST IS ONE LESS THAN ITEM'S LOWER
--     BOUND.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 09/25/87  COMPLETELY REVISED TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3604A IS

BEGIN

     TEST ("CE3604A", "CHECK THAT GET_LINE READS LINES APPROPRIATELY " &
                      "AND CHECK THAT LAST RETURNS THE CORRECT INDEX " &
                      "VALUE");

     DECLARE
          FILE : FILE_TYPE;
          STR : STRING (1 .. 25);
          LAST : NATURAL;
          ITEM1 : STRING (2 .. 6);
          ITEM2 : STRING (3 .. 6);
          CH : CHARACTER;
          INCOMPLETE : EXCEPTION;

     BEGIN
          BEGIN
               CREATE (FILE, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON TEXT " &
                                    "CREATE WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON TEXT " &
                            "CREATE");
                    RAISE INCOMPLETE;
          END;

          PUT (FILE, "FIRST LINE OF INPUT");
          NEW_LINE (FILE);
          PUT (FILE, "SECOND LINE OF INPUT");
          NEW_LINE (FILE);
          PUT (FILE, "THIRD LINE OF INPUT");
          NEW_LINE (FILE);
          NEW_LINE (FILE);

          CLOSE (FILE);

          BEGIN
               OPEN (FILE, IN_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT OPEN " &
                                    "WITH IN_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          GET_LINE (FILE, STR, LAST);

          BEGIN
               IF STR(1..LAST) /= "FIRST LINE OF INPUT" THEN
                    FAILED ("GET_LINE - RETURN OF ENTIRE LINE");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED ("CONSTRAINT_ERROR RAISED AFTER " &
                            "GET_LINE - 1");
          END;

          GET (FILE, ITEM1);
          GET_LINE (FILE, STR, LAST);

          BEGIN
               IF STR(1..LAST) /= "D LINE OF INPUT" THEN
                    FAILED ("GET_LINE - REMAINDER OF PARTLY READ LINE");
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED ("CONSTRAINT_ERROR RAISED AFTER " &
                            "GET_LINE - 2");
          END;

          GET_LINE (FILE, ITEM1, LAST);
          IF LAST /= 6 THEN
               FAILED ("INCORRECT VALUE FOR LAST PARAMETER - 1");
          END IF;

          WHILE NOT END_OF_LINE (FILE) LOOP
               GET (FILE, CH);
          END LOOP;

          GET_LINE (FILE, ITEM1, LAST);
          IF LAST /= 1 THEN
               FAILED ("INCORRECT VALUE FOR LAST PARAMETER - 2");
          END IF;

          IF NOT END_OF_LINE (FILE) THEN
               FAILED ("END_OF_LINE NOT TRUE");
          END IF;

          GET_LINE (FILE, ITEM2, LAST);
          IF LAST /= 2 THEN
               FAILED ("INCORRECT VALUE FOR LAST PARAMETER - 3");
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

     RESULT;

END CE3604A;
