-- CE3806H.ADA

-- OBJECTIVE:
--     CHECK THAT FIXED_IO PUT RAISES LAYOUT_ERROR WHEN THE NUMBER OF
--     CHARACTERS TO BE OUTPUT EXCEEDS THE MAXIMUM LINE LENGTH.  CHECK
--     THAT IT IS NOT RAISED, BUT RATHER NEW_LINE IS CALLED, WHEN THE
--     NUMBER DOES NOT EXCEED THE MAX, BUT WHEN ADDED TO THE CURRENT
--     COLUMN NUMBER, THE TOTAL EXCEEDS THE MAX.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     JLH 09/15/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;
WITH CHECK_FILE;

PROCEDURE CE3806H IS

BEGIN

     TEST ("CE3806H", "CHECK THAT FIXED_IO PUT RAISES " &
                      "LAYOUT_ERROR CORRECTLY");

     DECLARE
          FT : FILE_TYPE;
          TYPE FX IS DELTA 0.01 RANGE -200.0 .. 200.0;
          PACKAGE FXIO IS NEW FIXED_IO (FX);
          USE FXIO;
          INCOMPLETE : EXCEPTION;
          X : FX := 126.5;
          Y : FX := -134.0;
          Z : FX := 120.0;

     BEGIN

          BEGIN
               CREATE (FT, OUT_FILE, LEGAL_FILE_NAME);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT CREATE " &
                                    "WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
               WHEN NAME_ERROR =>
                    NOT_APPLICABLE ("NAME_ERROR RAISED ON TEXT " &
                                    "CREATE WITH OUT_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          SET_LINE_LENGTH (FT, 4);

          BEGIN
               PUT (FT, X, FORE => 3, AFT => 1);
               FAILED ("LAYOUT_ERROR NOT RAISED - FIXED");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FIXED");
          END;

          SET_LINE_LENGTH (FT,7);

          BEGIN
               PUT (FT, Y, FORE => 3, AFT => 2);
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    FAILED ("LAYOUT_ERROR RAISED SECOND PUT - " &
                            "FIXED");
               WHEN OTHERS =>
                    FAILED ("SOME EXCEPTION RAISED SECOND PUT - " &
                            "FIXED");
          END;

          BEGIN
               PUT (FT,Z, FORE => 4, AFT => 2);
               IF LINE (FT) /= 2 THEN
                    FAILED ("NEW_LINE NOT CALLED - FIXED");
               END IF;
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    FAILED ("LAYOUT_ERROR RAISED THIRD PUT - " &
                            "FIXED");
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED THIRD PUT - FIXED");
          END;

          BEGIN
               PUT (FT, "Y");
               PUT (FT, Z, FORE => 3, AFT => 0);
               NEW_LINE (FT);
               PUT (FT, "Z");
               PUT (FT, Y, FORE => 3, AFT => 2);
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    FAILED ("LAYOUT_ERROR RAISED LAST PUT - " &
                            "FIXED");
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED LAST PUT - FIXED ");
          END;

          CHECK_FILE (FT, "-134.00# 120.00#Y120.0#Z#-134.00#@%");

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

END CE3806H;
