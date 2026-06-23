-- CE3806E.ADA

-- OBJECTIVE:
--     CHECK THAT FLOAT_IO PUT RAISE LAYOUT_ERROR WHEN THE NUMBER
--     OF CHARACTERS TO BE OUTPUT EXCEEDS THE MAXIMUM LINE LENGTH.
--     CHECK THAT IT IS NOT RAISED, BUT RATHER NEW_LINE IS CALLED,
--     WHEN THE NUMBER DOES NOT EXCEED THE MAX, BUT WHEN ADDED TO
--     THE CURRENT COLUMN NUMBER, THE TOTAL EXCEEDS THE MAX.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     TEXT FILES.

-- HISTORY:
--     SPS 10/07/82
--     SPS 12/14/82
--     VKG 01/13/83
--     SPS 02/18/83
--     JBG 08/30/83
--     RJW 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 09/14/87  REMOVED DEPENDENCE ON RESET AND CORRECTED
--                   EXCEPTION HANDLING.

WITH REPORT;
USE REPORT;
WITH TEXT_IO;
USE TEXT_IO;
WITH CHECK_FILE;

PROCEDURE CE3806E IS

BEGIN

     TEST ("CE3806E", "CHECK THAT FLOAT_IO PUT RAISES " &
                      "LAYOUT_ERROR CORRECTLY");

     DECLARE
          TYPE FL IS DIGITS 3 RANGE 100.0 .. 200.0;
          PACKAGE FLIO IS NEW FLOAT_IO (FL);
          USE FLIO;
          X : FL := 126.0;
          Y : FL := 134.0;
          Z : FL := 120.0;
          INCOMPLETE : EXCEPTION;
          FT : FILE_TYPE;
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

          SET_LINE_LENGTH (FT, 8);

          BEGIN
               PUT (FT, X);        -- " 1.26E+02"
               FAILED ("LAYOUT_ERROR NOT RAISED - FLOAT");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - FLOAT");

          END;

          BEGIN
               PUT (FT, Y, FORE => 1); -- "1.34E+02"
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    FAILED ("LAYOUT_ERROR RAISED SECOND PUT " &
                            "- FLOAT");
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED SECOND PUT - FLOAT");
          END;

          BEGIN
               PUT (FT,Z, FORE => 1, AFT => 0); -- "1.2E+02"
               IF LINE (FT) /= 2 THEN
                    FAILED ("NEW_LINE NOT CALLED - FLOAT");
               END IF;
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    FAILED ("LAYOUT_ERROR RAISED THIRD " &
                            "PUT - FLOAT");
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED THIRD PUT - FLOAT");
          END;

          SET_LINE_LENGTH ( FT,7);

          BEGIN
               PUT (FT, "X");
               PUT (FT, Y, FORE => 1, AFT => 2,
                    EXP => 1);          -- 1.34E+2
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    FAILED ("LAYOUT_ERROR RAISED - 3 FLOAT");
          END;

          BEGIN
               PUT (FT, "Z");
               PUT (FT, Z, FORE => 1);
               FAILED ("LAYOUT_ERROR NOT RAISED - FLOAT 2");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("SOME EXCEPTION RAISED - 3 FLOAT");
          END;

          CHECK_FILE (FT, "1.34E+02#1.2E+02#X#1.34E+2#Z#@%");

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

END CE3806E;
