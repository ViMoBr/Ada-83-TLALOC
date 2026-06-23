-- AE2113B.ADA

-- CHECK THAT THE SUBPROGRAMS CREATE, OPEN, CLOSE, DELETE, RESET, MODE,
-- NAME, FORM, AND IS_OPEN ARE AVAILABLE FOR SEQUENTIAL_IO AND THAT
-- SUBPROGRAMS HAVE THE CORRECT FORMAL PARAMETER NAMES.

-- TBN  9/30/86

WITH SEQUENTIAL_IO;
WITH REPORT; USE REPORT;
PROCEDURE AE2113B IS

     PACKAGE SEQ_IO IS NEW SEQUENTIAL_IO (INTEGER);
     USE SEQ_IO;

     TEMP : FILE_TYPE;

BEGIN
     TEST ("AE2113B", "CHECK THAT THE SUBPROGRAMS CREATE, OPEN, " &
                      "CLOSE, DELETE, RESET, MODE, NAME, FORM, AND " &
                      "IS_OPEN ARE AVAILABLE FOR SEQUENTIAL_IO AND " &
                      "THAT SUBPROGRAMS HAVE THE CORRECT FORMAL " &
                      "PARAMETER NAMES");
     BEGIN
          CREATE (FILE=> TEMP, MODE=> OUT_FILE,
                  NAME=> "AE2113B.DAT", FORM=> "");
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          RESET (FILE=> TEMP, MODE=> OUT_FILE);
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          CLOSE (FILE=> TEMP);
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          OPEN (FILE=> TEMP, MODE=> OUT_FILE,
                  NAME=> "AE2113B.DAT", FORM=> "");
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          IF IS_OPEN (FILE=> TEMP) THEN
               NULL;
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          IF MODE (FILE=> TEMP) /= OUT_FILE THEN
               NULL;
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          IF NAME (FILE=> TEMP) /= "AE2113B.DAT" THEN
               NULL;
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          IF FORM (FILE=> TEMP) /= "" THEN
               NULL;
          END IF;
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     BEGIN
          DELETE (FILE=> TEMP);
     EXCEPTION
          WHEN OTHERS =>
               NULL;
     END;

     RESULT;
END AE2113B;
