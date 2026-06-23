-- CE3706F.ADA

-- OBJECTIVE:
--     CHECK THAT INTEGER_IO PUT RAISES LAYOUT_ERROR WHEN THE NUMBER OF
--     CHARACTERS TO BE OUTPUT EXCEEDS THE MAXIMUM LINE LENGTH.  CHECK
--     THAT IT IS NOT RAISED WHEN THE NUMBER OF CHARACTERS TO BE OUTPUT
--     ADDED TO THE CURRENT COLUMN NUMBER EXCEEDS THE MAXIMUM LINE
--     LENGTH.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     CREATION OF TEMPORARY TEXT FILES WITH OUT_FILE MODE.

-- HISTORY:
--     SPS 10/05/82
--     VKG 01/14/83
--     SPS 02/18/83
--     JBG 08/30/83
--     EG  05/22/85
--     RJW 11/04/86  REVISED TEST TO OUTPUT A NOT_APPLICABLE
--                   RESULT WHEN FILES ARE NOT SUPPORTED.
--     JLH 09/10/87  REMOVED UNNECESSARY CODE, CORRECTED EXCEPTION
--                   HANDLING, AND ADDED CASE USING WIDTH OF FIVE.

WITH REPORT; USE REPORT;
WITH TEXT_IO; USE TEXT_IO;
WITH CHECK_FILE;

PROCEDURE CE3706F IS

BEGIN

     TEST ("CE3706F", "CHECK THAT LAYOUT_ERROR IS RAISED CORRECTLY");

     DECLARE
          FT : FILE_TYPE;
          PACKAGE IIO IS NEW INTEGER_IO (INTEGER);
          USE IIO;
          INCOMPLETE : EXCEPTION;
     BEGIN

          BEGIN
               CREATE (FT);
          EXCEPTION
               WHEN USE_ERROR =>
                    NOT_APPLICABLE ("USE_ERROR RAISED ON TEXT CREATE " &
                                    "FOR TEMPORARY FILE WITH " &
                                    "OUT_FILE MODE");
                    RAISE INCOMPLETE;
          END;

          SET_LINE_LENGTH (FT, 4);

          BEGIN
               PUT (FT, 32_000, WIDTH => 0);
               FAILED ("LAYOUT_ERROR NOT RAISED - 1");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 1");
          END;

          BEGIN
               PUT (FT, 32_000, WIDTH => 5);
               FAILED ("LAYOUT_ERROR NOT RAISED - 2");
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - 2");
          END;

          PUT (FT, 123, WIDTH => 0);  -- "123"

          BEGIN
               PUT (FT, 457, WIDTH => 0);  -- "123#457"
               IF LINE (FT) /= 2 THEN
                    FAILED ("OUTPUT INCORRECT");
               END IF;
          EXCEPTION
               WHEN LAYOUT_ERROR =>
                    FAILED ("LAYOUT_ERROR RAISED INCORRECTLY");
          END;

          CHECK_FILE (FT, "123#457#@%");

          CLOSE (FT);

     EXCEPTION
          WHEN INCOMPLETE =>
               NULL;
     END;

     RESULT;

END CE3706F;
