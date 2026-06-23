-- CE2108D.ADA

-- OBJECTIVE:
--     CHECK THAT AN EXTERNAL DIRECT FILE SPECIFIED BY A NULL STRING
--     NAME IS NOT ACCESSIBLE AFTER THE COMPLETION OF THE MAIN PROGRAM.

--     THIS TEST CHECKS THE DIRECT FILE AND TEXT FILE CREATED IN
--     CE2108C.ADA

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMNTATIONS WHICH SUPPORT
--     TEXT FILES AND DIRECT FILES IN WHICH TEMPORARY FILES HAVE NAMES
--     THAT ARE NOT MORE THAN 255 CHARACTERS LONG.

-- HISTORY:
--     ABW 08/16/82
--     SPS 09/24/82
--     SPS 11/09/82
--     SPS 12/08/82
--     JBG 02/22/84  CHANGE TO .ADA TEST.
--     JBG 12/03/84
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     TBN 07/16/87  COMPLETELY REVISED TEST.

WITH REPORT; USE REPORT;
WITH DIRECT_IO;
WITH TEXT_IO;

PROCEDURE CE2108D IS

     PACKAGE DIR IS NEW DIRECT_IO (INTEGER);
     DIR_NAME, FILE_NULL_NAME : DIR.FILE_TYPE;
     TEXT_NAME, NAMES_FILE : TEXT_IO.FILE_TYPE;
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE2108D", "CHECK THAT DIRECT FILES WITH NULL STRING " &
                      "NAMES ARE NOT ACCESSIBLE AFTER COMPLETION OF " &
                      "THE PROGRAM WHICH CREATES THEM");

     -- CHECK FOR SUPPORT OF DIRECT FILES.

     BEGIN
          DIR.CREATE (DIR_NAME);
          DIR.CLOSE (DIR_NAME);
     EXCEPTION
          WHEN DIR.USE_ERROR | DIR.NAME_ERROR =>
               NOT_APPLICABLE ("TEMPORARY DIRECT FILES NOT " &
                               "SUPPORTED");
               RAISE INCOMPLETE;
     END;

     -- CHECK FOR SUPPORT OF TEXT FILES.

     BEGIN
          TEXT_IO.CREATE (TEXT_NAME);
          TEXT_IO.CLOSE (TEXT_NAME);
     EXCEPTION
          WHEN TEXT_IO.USE_ERROR | TEXT_IO.NAME_ERROR =>
               NOT_APPLICABLE ("TEMPORARY TEXT FILES NOT SUPPORTED");
               RAISE INCOMPLETE;
     END;

     -- BEGIN ACTUAL TEST OBJECTIVE.

     BEGIN
          TEXT_IO.OPEN (NAMES_FILE, TEXT_IO.IN_FILE,
                        LEGAL_FILE_NAME(1, "CE2108C"));
     EXCEPTION
          WHEN TEXT_IO.USE_ERROR =>
               NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN FOR TEXT " &
                               "FILE WITH IN_FILE MODE");
               RAISE INCOMPLETE;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED ON OPENING " &
                       "OF TEXT FILE, WHICH SHOULD HAVE BEEN " &
                       "CREATED BY TEST CE2108C.ADA");
               RAISE INCOMPLETE;
     END;

     DECLARE
          TEMP_LEN : NATURAL;
          TEMP_NAME : STRING (1 .. 255);
     BEGIN
          TEXT_IO.GET_LINE (NAMES_FILE, TEMP_NAME, TEMP_LEN);
          IF TEMP_NAME(1..3) = "HAS" THEN
               TEXT_IO.GET_LINE (NAMES_FILE, TEMP_NAME, TEMP_LEN);
               BEGIN
                    DIR.OPEN (FILE_NULL_NAME, DIR.IN_FILE,
                              TEMP_NAME (1 .. TEMP_LEN));
                    FAILED ("DIR TEMP FILE ACCESSIBLE AFTER " &
                            "MAIN PROGRAM COMPLETED");
                    BEGIN
                         DIR.DELETE (FILE_NULL_NAME);
                    EXCEPTION
                         WHEN DIR.USE_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED ("UNEXPECTED EXCEPTION RAISED " &
                                      "ON DELETE OF TEMP DIR FILE");
                    END;
               EXCEPTION
                    WHEN DIR.NAME_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                                 "ATTEMPT TO OPEN DIR TEMP FILE");
               END;
          ELSIF TEMP_NAME(1..3) = "TOO" THEN
               NOT_APPLICABLE ("A TEMPORARY DIRECT FILE HAS A " &
                               "NAME LONGER THAN 255 CHARACTERS");
          ELSE
               NOT_APPLICABLE ("A TEMPORARY DIRECT FILE HAS NO " &
                               "NAME");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - UNABLE TO READ TEMP " &
                       "FILE NAME");
     END;

     BEGIN
          TEXT_IO.DELETE (NAMES_FILE);
     EXCEPTION
          WHEN TEXT_IO.USE_ERROR =>
               NULL;
     END;

     RESULT;

EXCEPTION
     WHEN INCOMPLETE =>
          RESULT;
END CE2108D;
