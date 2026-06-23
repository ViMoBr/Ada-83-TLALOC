-- CE3208A.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN THE FILE USED AS A PARAMETER TO SET_INPUT OR
--     SET_OUTPUT IS CLOSED, THE CORRESPONDING DEFAULT FILE IS CLOSED.
--     ALSO CHECK THAT WHEN THE FILE SERVING AS A DEFAULT FILE IS CLOSED
--     AND REOPENED WITH A CHANGED MODE, THE MODE OF THE DEFAULT FILE
--     IS ALSO CHANGED.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     SPS 09/28/82
--     SPS 12/14/82
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 08/18/87  ADDED CASES FOR MODE_ERROR BEING RAISED FOR
--                   INPUT AND OUTPUT AND CHECKED FOR USE_ERROR
--                   ON DELETE.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3208A IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3208A", "CHECK THAT WHEN THE FILE USED AS A " &
                      "PARAMETER TO SET_INPUT OR SET_OUTPUT IS " &
                      "CLOSED, THE CORRESPONDING DEFAULT FILE IS " &
                      "CLOSED.  ALSO CHECK THAT WHEN THE FILE " &
                      "SERVING AS A DEFAULT FILE IS CLOSED AND " &
                      "REOPENED WITH  CHANGED MODE, THE MODE OF THE " &
                      "DEFAULT FILE IS ALSO CHANGED");

     DECLARE
          FT1, FT2 : FILE_TYPE;
          X : STRING (1..20);
          LEN : NATURAL;
     BEGIN

          BEGIN
               CREATE (FT1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE " &
                                    "FOR OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE " &
                                    "FOR OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          SET_OUTPUT (FT1);
          PUT ("INPUT STRING");
          CLOSE (FT1);

          BEGIN
               PUT ("OUTPUT STRING ");
               FAILED ("CURRENT OUTPUT NOT CLOSED");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - PUT");
          END;

-- AS A RESULT OF AI-00048, OPENING A FILE WITH IN_FILE MODE WHICH IS
-- THE DEFAULT OUTPUT FILE WILL RAISE MODE_ERROR.

          BEGIN
               OPEN (FT1, IN_FILE, LEGAL_FILE_NAME);
               FAILED ("MODE_ERROR NOT RAISED ON OPEN FOR IN_FILE " &
                       "MODE");
               BEGIN
                    DELETE (FT1);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
               END;
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON OPEN - 1");
          END;

          CREATE (FT2, OUT_FILE, LEGAL_FILE_NAME(2));

          PUT (FT2, "OUTPUT STRING");
          NEW_LINE (FT2);
          PUT_LINE (FT2, "LAST STRING");

          CLOSE (FT2);

          BEGIN
               OPEN (FT2, IN_FILE, LEGAL_FILE_NAME(2));
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN FOR " &
                                    "IN_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          SET_INPUT (FT2);

          GET_LINE (X, LEN);
          IF X (1..LEN) /= "OUTPUT STRING" THEN
               FAILED ("INCORRECT VALUE READ FOR X");
          END IF;

          CLOSE (FT2);

          BEGIN
               GET_LINE (X, LEN);
               FAILED ("CURRENT INPUT NOT CLOSED");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED - GET");
          END;

-- AS A RESULT OF AI-00048, OPENING A FILE WITH OUT_FILE MODE WHICH IS
-- THE DEFAULT INPUT FILE WILL RAISE MODE_ERROR.

          BEGIN
               OPEN (FT2, OUT_FILE, LEGAL_FILE_NAME(2));
               FAILED ("MODE_ERROR NOT RAISED ON OPEN FOR OUT_FILE " &
                       "MODE");
               BEGIN
                    DELETE (FT2);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
               END;
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON OPEN - 2");
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;

     END;

     RESULT;

END CE3208A;
