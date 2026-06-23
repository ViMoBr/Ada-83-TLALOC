-- CE3801B.ADA

-- OBJECTIVE:
--     CHECK THAT EACH FIXED_IO OPERATION RAISES STATUS_ERROR
--     WHEN CALLED WITH A FILE PARAMETER DESIGNATING AN UN-OPEN FILE.

-- HISTORY:
--     DWC 09/11/87  CREATED ORIGINAL TEST.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3801B IS
BEGIN

     TEST ("CE3801B", "CHECK THAT EACH FIXED_IO " &
                      "OPERATION RAISES STATUS_ERROR WHEN CALLED " &
                      "WITH A FILE PARAMETER DESIGNATING AN " &
                      "UN-OPEN FILE");

     DECLARE
          TYPE FIX IS DELTA 0.1 RANGE 1.0 .. 10.0;
          PACKAGE FIX_IO IS NEW FIXED_IO (FIX);
          USE FIX_IO;
          X : FIX := FIX'LAST;
          FT : FILE_TYPE;

     BEGIN
          BEGIN
               GET (FT, X);
               FAILED ("STATUS_ERROR NOT RAISED - GET FIXED_IO - 1");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET " &
                            "FIXED_IO - 1");
          END;

          BEGIN
               PUT (FT, X);
               FAILED ("STATUS_ERROR NOT RAISED - PUT FIXED_IO - 1");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT " &
                            "FIXED_IO - 1");
          END;

          BEGIN
               CREATE (FT, OUT_FILE);   -- THIS IS JUST AN ATTEMPT TO
               CLOSE (FT);              -- CREATE A FILE.  OBJECTIVE
          EXCEPTION                     -- IS MET EITHER WAY.
               WHEN USE_ERROR =>
                    NULL;
          END;

          BEGIN
               GET (FT, X);
               FAILED ("STATUS_ERROR NOT RAISED - GET FIXED_IO - 2");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - GET " &
                            "FIXED_IO - 2");
          END;

          BEGIN
               PUT (FT, X);
               FAILED ("STATUS_ERROR NOT RAISED - PUT FIXED_IO - 2");
          EXCEPTION
               WHEN STATUS_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - PUT " &
                            "FIXED_IO - 2");
          END;
     END;

     RESULT;

END CE3801B;
