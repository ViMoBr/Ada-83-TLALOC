-- CE3804O.ADA

-- HISTORY:
--     CHECK THAT GET FOR FIXED_IO RAISES MODE_ERROR WHEN THE
--     MODE IS NOT IN_FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH
--     SUPPORT TEXT FILES.

-- HISTORY:
--     DWC 09/14/87  CREATED ORIGINAL TEST.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3804O IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3804O", "CHECK THAT GET FOR FIXED_IO RAISES " &
                      "MODE_ERROR WHEN THE MODE IS NOT IN_FILE");

     DECLARE
          FT: FILE_TYPE;
     BEGIN
          BEGIN
               CREATE (FT, OUT_FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; TEXT " &
                                    "CREATE FOR TEMP FILES " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          DECLARE
               TYPE FIXED IS DELTA 0.25 RANGE 1.0 .. 3.0;
               PACKAGE FX_IO IS NEW FIXED_IO (FIXED);
               USE FX_IO;
               X : FIXED;
          BEGIN

               BEGIN
                    GET (FT, X);
                    FAILED ("MODE_ERROR NOT RAISED - FIXED " &
                            "UN-NAMED FILE");
               EXCEPTION
                    WHEN MODE_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - " &
                                 "FIXED UN-NAMED FILE");
               END;

               BEGIN
                    GET (STANDARD_OUTPUT, X);
                    FAILED ("MODE_ERROR NOT RAISED - FIXED " &
                            "STANDARD_OUTPUT");
               EXCEPTION
                    WHEN MODE_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - " &
                                 "FIXED STANDARD_OUTPUT");
               END;

               BEGIN
                    GET (CURRENT_OUTPUT, X);
                    FAILED ("MODE_ERROR NOT RAISED - FIXED " &
                            "CURRENT_OUTPUT");
               EXCEPTION
                    WHEN MODE_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - " &
                                 "FIXED CURRENT_OUTPUT");
               END;

          END;

          BEGIN
               DELETE (FT);
          EXCEPTION
               WHEN USE_ERROR =>
                    NULL;
          END;

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3804O;
