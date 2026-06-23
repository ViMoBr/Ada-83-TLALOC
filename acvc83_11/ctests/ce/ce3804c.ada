-- CE3804C.ADA

-- HISTORY:
--     CHECK THAT GET FOR FLOAT_IO RAISES MODE_ERROR WHEN THE
--     MODE IS NOT IN_FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS ONLY APPLICABLE TO IMPLEMENTATIONS WHICH
--     SUPPORT TEXT FILES.

-- HISTORY:
--     SPS 09/07/82
--     JBG 02/22/84  CHANGED TO .ADA TEST
--     RJW 11/04/86  REVISED TEST TO OUTPUT A NON_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     DWC 09/11/87  SPLIT CASE FOR FIXED_IO INTO CE3804O.ADA
--                   AND CORRECTED EXCEPTION HANDLING.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;

PROCEDURE CE3804C IS
     INCOMPLETE : EXCEPTION;

BEGIN

     TEST ("CE3804C", "CHECK THAT GET FOR FLOAT_IO RAISES " &
                      "MODE_ERROR WHEN THE MODE IS NOT IN_FILE");

     DECLARE
          FT2 : FILE_TYPE;
     BEGIN

          BEGIN
               CREATE (FT2, OUT_FILE);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED; TEXT CREATE " &
                                    "FOR TEMP FILES WITH OUT_FILE " &
                                    "MODE - 1");
                    RAISE INCOMPLETE;
          END;

          DECLARE
               PACKAGE FL_IO IS NEW FLOAT_IO (FLOAT);
               USE FL_IO;
               X : FLOAT;
          BEGIN

               BEGIN
                    GET (FT2, X);
                    FAILED ("MODE_ERROR NOT RAISED - FLOAT " &
                            "UN-NAMED FILE");
               EXCEPTION
                    WHEN MODE_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - " &
                                 "FLOAT UN-NAMED FILE");
               END;

               BEGIN
                    GET (STANDARD_OUTPUT, X);
                    FAILED ("MODE_ERROR NOT RAISED - FLOAT " &
                            "STANDARD_OUTPUT");
               EXCEPTION
                    WHEN MODE_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - " &
                                 "FLOAT STANDARD_OUTPUT");
               END;

               BEGIN
                    GET (CURRENT_OUTPUT, X);
                    FAILED ("MODE_ERROR NOT RAISED - FLOAT " &
                            "CURRENT_OUTPUT");
               EXCEPTION
                    WHEN MODE_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("WRONG EXCEPTION RAISED - " &
                                 "FLOAT CURRENT_OUTPUT");
               END;

          END;

          CLOSE (FT2);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3804C;
