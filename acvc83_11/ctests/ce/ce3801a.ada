-- CE3801A.ADA

-- OBJECTIVE:
--     CHECK THAT EACH FLOAT_IO OPERATION RAISES STATUS_ERROR WHEN
--     CALLED WITH A FILE PARAMETER DESIGNATING AN UN-OPEN FILE.

-- HISTORY:
--     SPS 09/07/82
--     SPS 12/22/82
--     DWC 09/11/87  CORRECTED EXCEPTION HANDLING AND REVISED IFS
--                   TO CHECK FOR CASE WHEN VALUE IS NEGATIVE OF
--                   WHAT IS EXPECTED.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3801A IS
BEGIN

     TEST ("CE3801A", "CHECK THAT EACH FLOAT_IO AND FIXED_IO " &
                      "OPERATION RAISES STATUS_ERROR WHEN CALLED " &
                      "WITH A FILE PARAMETER DESIGNATING AN " &
                      "UN-OPEN FILE");

     DECLARE
          TYPE FLT IS NEW FLOAT RANGE 1.0 .. 10.0;
          PACKAGE FLT_IO IS NEW FLOAT_IO (FLT);
          USE FLT_IO;
          X : FLT := FLT'FIRST;
          FT : FILE_TYPE;
     BEGIN

          BEGIN
               GET (FT, X);
               FAILED ("STATUS_ERROR NOT RAISED - GET FLOAT_IO - 1");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET " &
                            "FLOAT_IO - 1");
          END;

          BEGIN
               PUT (FT, X);
               FAILED ("STATUS_ERROR NOT RAISED - PUT FLOAT_IO - 1");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT " &
                            "FLOAT_IO - 1");
          END;

          BEGIN
               CREATE (FT, OUT_FILE);    -- THIS IS JUST AN ATTEMPT
               CLOSE (FT);               -- TO CREATE A FILE.
          EXCEPTION                      -- OBJECTIVE MET EITHER WAY.
               WHEN USE_ERROR =>
                    NULL;
          END;

          BEGIN
               GET (FT, X);
               FAILED ("STATUS_ERROR NOT RAISED - GET FLOAT_IO - 2");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET " &
                            "FLOAT_IO - 2");
          END;

          BEGIN
               PUT (FT, X);
               FAILED ("STATUS_ERROR NOT RAISED - PUT FLOAT_IO - 2");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT " &
                            "FLOAT_IO - 2");
          END;
     END;

     RESULT;

END CE3801A;
