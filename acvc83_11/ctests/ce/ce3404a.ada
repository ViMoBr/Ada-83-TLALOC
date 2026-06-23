-- CE3404A.ADA

-- OBJECTIVE:
--     CHECK THAT END_OF_LINE RAISES MODE_ERROR WHEN APPLIED TO
--     AN OUT_FILE.

-- HISTORY:
--     ABW 08/26/82
--     SPS 09/17/82
--     TBN 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     GMT 29/28/87  COMPLETELY REVISED.

WITH REPORT;  USE REPORT;
WITH TEXT_IO; USE TEXT_IO;

PROCEDURE CE3404A IS

     MY_FILE : FILE_TYPE;
     BOOL    : BOOLEAN;

BEGIN

     TEST ("CE3404A", "CHECK THAT END_OF_LINE RAISES MODE_ERROR " &
                      "WHEN APPLIED TO AN OUT_FILE");

     BEGIN
          BOOL := END_OF_FILE (CURRENT_OUTPUT);
          FAILED ("MODE_ERROR NOT RAISED FOR CURRENT_OUTPUT - 1");
     EXCEPTION
          WHEN MODE_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED FOR " &
                       "CURRENT_OUTPUT - 2");
     END;

     BEGIN
          BOOL := END_OF_FILE (STANDARD_OUTPUT);
          FAILED ("MODE_ERROR NOT RAISED FOR STANDARD_OUTPUT - 3");
     EXCEPTION
          WHEN MODE_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED FOR " &
                       "STANDARD_OUTPUT - 4");
     END;

     BEGIN
          CREATE (MY_FILE);
          BEGIN
               BOOL := END_OF_FILE (MY_FILE);
               FAILED ("MODE_ERROR NOT RAISED FOR MY_FILE - 5");
          EXCEPTION
               WHEN MODE_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("UNEXPECTED EXCEPTION RAISED FOR " &
                            "MY_FILE - 6");

          END;

          CLOSE (MY_FILE);

     EXCEPTION
          WHEN USE_ERROR =>
               NULL;
     END;

     RESULT;

END CE3404A;
