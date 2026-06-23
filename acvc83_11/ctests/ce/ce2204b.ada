-- CE2204B.ADA

-- OBJECTIVE:
--     CHECK THAT READ AND END_OF_FILE ARE FORBIDDEN FOR SEQUENTIAL
--     FILES OF MODE OUT_FILE.

--          A) CHECK NON-TEMPORARY FILES.

-- APPLICABILITY CRITERIA:
--      THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--      THE CREATION OF SEQUENTIAL FILES.

-- HISTORY:
--     DLD 08/17/82
--     SPS 08/24/82
--     SPS 110/9/82
--     JBG 02/22/84  CHANGE TO .ADA TEST.
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     GMT 07/24/87  SPLIT THIS TEST BY MOVING THE CODE FOR CHECKING
--                   TEMPORARY FILES INTO CE2204D.ADA.

WITH REPORT; USE REPORT;
WITH SEQUENTIAL_IO;

PROCEDURE CE2204B IS
BEGIN
     TEST ("CE2204B", "FOR A NON-TEMPORARY SEQUENTIAL FILE, CHECK " &
                      "THAT MODE_ERROR IS RAISED BY READ AND " &
                      "END_OF_FILE WHEN THE MODE IS OUT_FILE");
     DECLARE
          PACKAGE SEQ_IO IS NEW SEQUENTIAL_IO (INTEGER);
          USE SEQ_IO;
          SEQ_FILE   : FILE_TYPE;
          X          : INTEGER;
          B          : BOOLEAN;
          INCOMPLETE : EXCEPTION;
     BEGIN
          BEGIN
               CREATE (SEQ_FILE, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON CREATE - 1");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON CREATE - 2");
                    RAISE INCOMPLETE;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED ON CREATE - 3");
                    RAISE INCOMPLETE;
          END;

          WRITE (SEQ_FILE, 5);

          BEGIN                    -- THIS IS ONLY
               RESET (SEQ_FILE);   -- AN ATTEMPT
          EXCEPTION                -- TO RESET,
               WHEN USE_ERROR =>   -- IF RESET
                    NULL;          -- N/A THEN
          END;                     -- TEST IS
                                   -- NOT AFFECTED.
          BEGIN
               READ (SEQ_FILE, X);
               FAILED ("MODE_ERROR NOT RAISED ON READ - 4");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED ON READ - 5");
          END;

          BEGIN
               B := END_OF_FILE (SEQ_FILE);
               FAILED ("MODE_ERROR NOT RAISED ON END_OF_FILE - 6");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - END_OF_FILE - 7");
          END;

          BEGIN
               DELETE (SEQ_FILE);
          EXCEPTION
               WHEN  USE_ERROR =>
                     NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE2204B;
