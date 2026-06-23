-- AE3101A.ADA

-- OBJECTIVE:
--     CHECK THAT CREATE, OPEN, CLOSE, DELETE, RESET, MODE, NAME,
--     FORM, IS_OPEN, AND END_OF_FILE ARE AVAILABLE FOR TEXT FILES.
--     ALSO CHECK THAT FORMAL PARAMETER NAMES ARE CORRECT.

-- HISTORY:
--     ABW 08/24/82
--     SPS 09/16/82
--     SPS 11/09/82
--     DWC 09/24/87  REMOVED DEPENDENCE ON FILE SUPPORT.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE AE3101A IS

     FILE1 : FILE_TYPE;

BEGIN

     TEST ("AE3101A" , "CHECK THAT CREATE, OPEN, DELETE, " &
                       "RESET, MODE, NAME, FORM, IS_OPEN, " &
                       "AND END_OF_FILE ARE AVAILABLE " &
                       "FOR TEXT FILE");

     BEGIN
          CREATE (FILE => FILE1,
                  MODE => OUT_FILE,
                  NAME => LEGAL_FILE_NAME,
                  FORM => "");
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          RESET (FILE => FILE1, MODE => IN_FILE);
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          CLOSE (FILE => FILE1);
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          OPEN (FILE => FILE1,
                MODE => IN_FILE,
                NAME => LEGAL_FILE_NAME,
                FORM => "");
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     IF IS_OPEN (FILE => FILE1) THEN
          NULL;
     END IF;

     BEGIN
          IF MODE (FILE => FILE1) /= IN_FILE THEN
               NULL;
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          IF NAME (FILE => FILE1) /= LEGAL_FILE_NAME THEN
               NULL;
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          IF FORM (FILE => FILE1) /= "" THEN
               NULL;
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          IF END_OF_FILE (FILE => FILE1) THEN
               NULL;
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          DELETE (FILE => FILE1);
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     RESULT;

END AE3101A;
