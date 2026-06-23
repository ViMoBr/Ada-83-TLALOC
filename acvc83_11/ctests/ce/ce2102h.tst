-- CE2102H.TST

-- OBJECTIVE:
--     CHECK THAT NAME_ERROR IS RAISED WHEN THE NAME STRING DOES NOT
--     IDENTIFY AN EXTERNAL FILE FOR AN OPEN OR CREATE OPERATION FOR
--     DIRECT_IO.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     CREATE WITH INOUT_FILE MODE FOR TEMPORARY DIRECT FILES.

-- HISTORY:
--     TBN 02/12/86
--     SPW 08/26/87  CORRECTED EXCEPTION HANDLING.
--     BCB 09/28/88  ADDED EXCEPTION HANDLERS FOR DELETE STATEMENTS.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;

PROCEDURE CE2102H IS

     NAME1 : CONSTANT STRING := "$ILLEGAL_EXTERNAL_FILE_NAME1";
               -- AN ILLEGAL EXTERNAL FILE NAME THAT EITHER (PREFERABLY)
               -- CONTAINS INVALID CHARACTERS OR IS TOO LONG.

     NAME2 : CONSTANT STRING := "$ILLEGAL_EXTERNAL_FILE_NAME2";
               -- AN ILLEGAL EXTERNAL FILE NAME THAT EITHER (PREFERABLY)
               -- CONTAINS A WILD CARD CHARACTER OR IS TOO LONG.

BEGIN

     TEST ("CE2102H", "CHECK THAT NAME_ERROR IS RAISED BY OPEN AND " &
                      "CREATE WHEN NAME DOES NOT IDENTIFY AN " &
                      "EXTERNAL FILE FOR DIRECT_IO");

     DECLARE
          PACKAGE DIR IS NEW DIRECT_IO (INTEGER);
          USE DIR;
          FILE1 : FILE_TYPE;
          INCOMPLETE : EXCEPTION;
     BEGIN

-- CHECK WHETHER CREATE RAISES USE_ERROR

          BEGIN
               CREATE (FILE1);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("TEMPORARY DIRECT FILES WITH " &
                                    "INOUT_FILE MODE NOT SUPPORTED");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED FOR CREATE");
                    RAISE INCOMPLETE;
          END;
          CLOSE (FILE1);

          BEGIN
               CREATE(FILE1, OUT_FILE, NAME1);
               FAILED ("NAME_ERROR NOT RAISED - CREATE DIR 1");
               BEGIN
                    DELETE (FILE1);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
               END;
          EXCEPTION
               WHEN NAME_ERROR =>
                    NULL;
               WHEN USE_ERROR =>
                    FAILED ("USE_ERROR RAISED - CREATE DIR 1");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CREATE DIR 1");
          END;

          BEGIN
               CREATE (FILE1, OUT_FILE, NAME2);
               FAILED("NAME_ERROR NOT RAISED - CREATE DIR 2");
               BEGIN
                    DELETE (FILE1);
               EXCEPTION
                    WHEN USE_ERROR =>
                         NULL;
               END;
          EXCEPTION
               WHEN NAME_ERROR =>
                    NULL;
               WHEN USE_ERROR =>
                    FAILED ("USE_ERROR RAISED - CREATE DIR 2");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CREATE DIR 2");
          END;

-- CHECK WHETHER OPEN RAISES NAME_ERROR IN THE CASE OF A LEGAL FILE NAME
-- BUT A NON-EXISTENT FILE.

          BEGIN
               OPEN (FILE1, IN_FILE, LEGAL_FILE_NAME);
               FAILED("NAME_ERROR NOT RAISED - OPEN DIR");
          EXCEPTION
               WHEN NAME_ERROR =>
                    NULL;
               WHEN USE_ERROR =>
                    FAILED ("USE_ERROR RAISED - OPEN DIR");
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - OPEN DIR");
          END;
     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;
END CE2102H;
