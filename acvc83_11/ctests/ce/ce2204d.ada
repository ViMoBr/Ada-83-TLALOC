-- CE2204D.ADA

-- OBJECTIVE:
--     CHECK THAT READ AND END_OF_FILE ARE FORBIDDEN FOR SEQUENTIAL
--     FILES OF MODE OUT_FILE.

--          B) CHECK TEMPORARY FILES.

-- APPLICABILITY CRITERIA:
--      THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--      THE CREATION OF TEMPORARY SEQUENTIAL FILES.

-- HISTORY:
--     GMT 07/24/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2204D  IS
BEGIN
     TEST ("CE2204D", "FOR A TEMPORARY SEQUENTIAL FILE, CHECK THAT " &
                      "MODE_ERROR IS RAISED BY READ AND END_OF_FILE " &
                      "WHEN THE MODE IS OUT_FILE");
     DECLARE
          PACKAGE SEQ_IO IS NEW SEQUENTIAL_IO (INTEGER);
          USE SEQ_IO;
          FT         : FILE_TYPE;
          X          : INTEGER;
          B          : BOOLEAN;
          INCOMPLETE : EXCEPTION;
     BEGIN
          BEGIN
               CREATE (FT);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE - 1");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED ON CREATE - 2");
                    RAISE INCOMPLETE;
          END;

          WRITE (FT, 5);

          BEGIN                    -- THIS IS ONLY
               RESET (FT);         -- AN ATTEMPT
          EXCEPTION                -- TO RESET,
               WHEN USE_ERROR =>   -- IF RESET
                    NULL;          -- N/A THEN
          END;                     -- TEST IS
                                   -- NOT AFFECTED.

          BEGIN
               READ (FT, X);
               FAILED ("MODE_ERROR NOT RAISED ON READ - 3");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED ON READ - 4");
          END;

          BEGIN
               B := END_OF_FILE (FT);
               FAILED ("MODE_ERROR NOT RAISED ON END_OF_FILE - 5");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - END_OF_FILE - 6");
          END;

          CLOSE (FT);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2204D;
