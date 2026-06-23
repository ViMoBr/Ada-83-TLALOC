-- CE2102X.ADA

-- OBJECTIVE:
--     CHECK THAT USE_ERROR IS RAISED IF AN IMPLEMENTATION DOES NOT
--     SUPPORT DELETION OF AN EXTERNAL SEQUENTIAL FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     CREATION OF A SEQUENTIAL FILE WITH OUT_FILE MODE.

-- HISTORY:
--     TBN 09/15/87  CREATED ORIGINAL TEST.

WITH SEQUENTIAL_IO;
WITH REPORT; USE REPORT;
PROCEDURE CE2102X IS
     INCOMPLETE : EXCEPTION;
BEGIN
     TEST ("CE2102X", "CHECK THAT USE_ERROR IS RAISED IF AN " &
                      "IMPLEMENTATION DOES NOT SUPPORT DELETION " &
                      "OF AN EXTERNAL SEQUENTIAL FILE");
     DECLARE
          PACKAGE SEQ IS NEW SEQUENTIAL_IO (INTEGER);
          USE SEQ;
          FILE1 : FILE_TYPE;
          INT1 : INTEGER := IDENT_INT(1);
     BEGIN
          BEGIN
               CREATE (FILE1, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE OF " &
                                    "SEQUENTIAL FILE WITH OUT_FILE " &
                                    "MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE OF " &
                                    "SEQUENTIAL FILE WITH OUT_FILE " &
                                    "MODE");
                    RAISE INCOMPLETE;
          END;

          WRITE (FILE1, INT1);
          BEGIN
               DELETE (FILE1);
               COMMENT ("DELETION OF AN EXTERNAL SEQUENTIAL FILE IS " &
                        "ALLOWED");
          EXCEPTION
               WHEN USE_ERROR =>
                    COMMENT ("DELETION OF AN EXTERNAL SEQUENTIAL " &
                             "FILE IS NOT ALLOWED");
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED WHILE " &
                            "DELETING AN EXTERNAL FILE");
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;
END CE2102X;
