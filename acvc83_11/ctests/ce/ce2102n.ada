-- CE2102N.ADA

-- OBJECTIVE:
--     CHECK THAT USE_ERROR IS RAISED WHEN OPENING A FILE OF MODE
--     IN_FILE, WHEN IN_FILE MODE IS NOT SUPPORTED FOR OPEN BY THE
--     IMPLEMENTATION FOR SEQUENTIAL_IO.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH DO NOT
--     SUPPORT OPEN WITH IN_FILE MODE FOR SEQUENTIAL FILES.

-- HISTORY:
--     TBN 07/23/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2102N IS
BEGIN

     TEST ("CE2102N", "CHECK THAT USE_ERROR IS RAISED WHEN MODE " &
                      "IN_FILE IS NOT SUPPORTED FOR THE OPERATION " &
                      "OF OPEN FOR SEQUENTIAL FILES");
     DECLARE
          PACKAGE SEQ IS NEW SEQUENTIAL_IO (BOOLEAN);
          USE SEQ;
          FILE1 : FILE_TYPE;
          INCOMPLETE : EXCEPTION;
          VAR1 : BOOLEAN := FALSE;
     BEGIN
          BEGIN
               CREATE (FILE1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE FOR " &
                                    "OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE FOR " &
                                    "OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON CREATE");
                    RAISE INCOMPLETE;
          END;

          WRITE (FILE1, VAR1);
          CLOSE (FILE1);

          BEGIN
               OPEN (FILE1, IN_FILE, LEGAL_FILE_NAME);
               NOT_APPLICABLE ("OPEN FOR IN_FILE MODE ALLOWED");
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED ON OPEN");
          END;

          IF IS_OPEN (FILE1) THEN
               BEGIN
                    DELETE (FILE1);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
               END;
          END IF;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2102N;
