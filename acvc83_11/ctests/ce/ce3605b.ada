-- CE3605B.ADA

-- OBJECTIVE;
--     CHECK THAT PUT OUTPUTS A LINE TERMINATOR, RESETS THE COLUMN
--     NUMBER AND INCREMENTS THE LINE NUMBER WHEN THE LINE LENGTH IS
--     BOUNDED AND THE COLUMN NUMBER EQUALS THE LINE LENGTH WHEN PUT
--     IS CALLED.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     SPS 09/02/82
--     JBG 12/28/82
--     JBG 02/22/84  CHANGED TO .ADA TEST
--     RJW 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 09/08/87  GAVE FILE A NAME AND REMOVED CODE WHICH RESETS
--                   THE FILE.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;
PROCEDURE CE3605B IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3605B", "CHECK THAT PUT PROPERLY MAINTAINS THE " &
                      "LINE NUMBER AND COLUMN NUMBER WHEN THE " &
                      "LINE LENGTH IS BOUNDED");

     DECLARE
          FILE1 : FILE_TYPE;
          LN_CNT : POSITIVE_COUNT;
     BEGIN

          BEGIN
               CREATE (FILE1, OUT_FILE, LEGAL_FILE_NAME);
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
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                            "TEXT CREATE");
                    RAISE INCOMPLETE;
          END;

          SET_LINE_LENGTH (FILE1, 5);
          LN_CNT := LINE (FILE1);

          FOR I IN 1 .. 5 LOOP
               PUT (FILE1, 'X');
          END LOOP;

          IF COL(FILE1) /= 6 THEN
               FAILED ("COLUMN NUMBER NOT INCREMENTED - PUT; " &
                       "VALUE WAS" & COUNT'IMAGE(COL(FILE1)));
          END IF;

          IF LINE(FILE1) /= LN_CNT THEN
               FAILED ("LINE COUNT MODIFIED - PUT CHARACTER; " &
                       "VALUE WAS" & COUNT'IMAGE(LINE(FILE1)));
          END IF;

          PUT (FILE1, 'X');
          IF COL(FILE1) /= 2 THEN
               FAILED ("COLUMN NUMBER NOT RESET - PUT CHARACTER; " &
                       "VALUE WAS" & COUNT'IMAGE(COL(FILE1)));
          END IF;

          IF LINE(FILE1) /= LN_CNT + 1 THEN
               FAILED("LINE NUMBER NOT INCREMENTED - PUT CHARACTER; " &
                       "VALUE WAS" & COUNT'IMAGE(LINE(FILE1)));
          END IF;

          NEW_LINE (FILE1);

          SET_LINE_LENGTH (FILE1, 4);
          LN_CNT := LINE (FILE1);

          PUT (FILE1, "XXXX");

          IF COL(FILE1) /= 5 THEN
               FAILED ("COLUMN NUMBER NOT INCREMENTED - PUT STRING; " &
                       "VALUE WAS" & COUNT'IMAGE(COL(FILE1)));
          END IF;

          IF LINE (FILE1) /= LN_CNT THEN
               FAILED ("LINE NUMBER INCREMENTED - PUT STRING; " &
                       "VALUE WAS" & COUNT'IMAGE(LINE (FILE1)));
          END IF;

          PUT (FILE1, "STR");

          IF COL(FILE1) /= 4 THEN
               FAILED ("COLUMN NUMBER NOT SET CORRECTLY - PUT" &
                       "STRING; VALUE WAS" & COUNT'IMAGE(COL(FILE1)));
          END IF;

          IF LINE (FILE1) /= LN_CNT + 1 THEN
               FAILED ("LINE NUMBER NOT INCREMENTED - PUT STRING; " &
                       "VALUE WAS" & COUNT'IMAGE(LINE (FILE1)));
          END IF;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;

     END;

     RESULT;

END CE3605B;
