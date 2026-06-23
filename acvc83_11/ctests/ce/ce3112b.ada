-- CE3112B.ADA

-- OBJECTIVE:
--     CHECK THAT AN EXTERNAL TEXT FILE SPECIFIED BY A NULL STRING
--     NAME IS NOT ACCESSIBLE AFTER THE COMPLETION OF THE MAIN PROGRAM.

--     THIS TEST CHECKS THE TEXT FILES CREATED BY CE3112A.ADA.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES AND TEMPORARY FILES WHICH HAVE NAMES THAT ARE NOT
--     MORE THAN 255 CHARACTERS LONG.

-- HISTORY:
--     ABW 08/16/82
--     SPS 09/24/82
--     SPS 11/09/82
--     SPS 12/08/82
--     JBG 12/03/84
--     EG  05/16/85
--     GMT 08/13/87  COMPLETELY REVISED TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO;

PROCEDURE CE3112B IS

     NAMED_FILE      : TEXT_IO.FILE_TYPE;
     FILE_NULL_NAME  : TEXT_IO.FILE_TYPE;
     INCOMPLETE      : EXCEPTION;

BEGIN

     TEST ("CE3112B", "CHECK THAT TEXT FILES WITH NULL STRING NAMES " &
                      "ARE NOT ACCESSIBLE AFTER COMPLETION OF THE " &
                      "PROGRAM WHICH CREATES THEM");

     -- CHECK FOR SUPPORT OF UNNAMED TEXT FILES.

     BEGIN
          TEXT_IO.CREATE (FILE_NULL_NAME);
          TEXT_IO.CLOSE (FILE_NULL_NAME);
     EXCEPTION
          WHEN TEXT_IO.USE_ERROR | TEXT_IO.NAME_ERROR =>
               NOT_APPLICABLE ("TEMPORARY TEXT FILES NOT " &
                               "SUPPORTED - 1");
               RAISE INCOMPLETE;
     END;

     -- BEGIN ACTUAL TEST OBJECTIVE.

     BEGIN
          TEXT_IO.OPEN (NAMED_FILE, TEXT_IO.IN_FILE,
                        LEGAL_FILE_NAME (1, "CE3112A"));
     EXCEPTION
          WHEN TEXT_IO.USE_ERROR =>
               NOT_APPLICABLE ("USE_ERROR RAISED ON OPEN OF TEXT " &
                               "FILE WITH IN_FILE MODE");
               RAISE INCOMPLETE;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED ON OPENING " &
                       "OF TEXT FILE, WHICH SHOULD HAVE " &
                       "BEEN CREATED BY TEST CE3112A.ADA - 2");
               RAISE INCOMPLETE;
     END;

     DECLARE
          TEMP_LEN  : NATURAL;
          TEMP_NAME : STRING (1 .. 255);
     BEGIN
          TEXT_IO.GET_LINE (NAMED_FILE, TEMP_NAME, TEMP_LEN);
          IF TEMP_NAME(1..3) = "HAS" THEN
               TEXT_IO.GET_LINE (NAMED_FILE, TEMP_NAME, TEMP_LEN);
               BEGIN
                    TEXT_IO.OPEN (FILE_NULL_NAME, TEXT_IO.IN_FILE,
                                  TEMP_NAME (1 .. TEMP_LEN));
                    FAILED ("TEMP FILE IS STILL ACCESSIBLE AFTER " &
                            "MAIN PROGRAM HAS COMPLETED - 3");
                    BEGIN
                         TEXT_IO.DELETE (FILE_NULL_NAME);
                    EXCEPTION
                         WHEN TEXT_IO.USE_ERROR =>
                              NULL;
                         WHEN OTHERS =>
                              FAILED ("UNEXPECTED EXCEPTION RAISED " &
                                      "ON DELETE OF TEMP FILE - 4");
                    END;
               EXCEPTION
                    WHEN TEXT_IO.NAME_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED ON " &
                                 "ATTEMPT TO OPEN TEMP FILE - 5");
               END;
          ELSIF TEMP_NAME(1..3) = "TOO" THEN
               NOT_APPLICABLE ("A TEMPORARY TEXT_IO FILE HAS A " &
                               "NAME LONGER THAN 255 CHARACTERS - 6");
          ELSE
               NOT_APPLICABLE ("A TEMPORARY TEXT_IO FILE HAS NO " &
                               "NAME - 7");
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - UNABLE TO READ TEMP " &
                       "FILE NAME - 8");
     END;

     BEGIN
          TEXT_IO.DELETE (NAMED_FILE);
     EXCEPTION
          WHEN TEXT_IO.USE_ERROR =>
               NULL;
     END;

     RESULT;

EXCEPTION
     WHEN INCOMPLETE =>
          RESULT;

END CE3112B;
